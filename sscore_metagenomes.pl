#!/usr/bin/perl -w
use strict;
use Getopt::Long;
use FindBin '$Bin';

my $DEFAULTFRAGSIZE  = 100;
my $DEFAULTMATRIXDIR = $Bin.'/Home2/sulfur_score/matrices_curadas_sep/';
my $DEFAULTMATRIXFILENAME = 'GENOMAS_NCBI_nr_24042014_sizeXXX_cover10.faa.pf.tab.csv';
my $DEFAULTMINRELENTROPY  = 0;

my @COLORS = ( '#FF9999', '#FF6666',  '#FF3333', '#FF0000', '#CC0000' );

my ($INP_pfamsearchfile,$INP_infile_bzipped,$INP_matrixdir) = ('',0,$DEFAULTMATRIXDIR);
my ($INP_fragment_size,$INP_help,$INP_keggmapfile,$INP_minentropy) = ($DEFAULTFRAGSIZE,0,'',$DEFAULTMINRELENTROPY);
my ($INP_pathways,@user_pathways,$pw) = ('');

GetOptions
(
    'help|h|?'        => \$INP_help,
    'input|in=s'      => \$INP_pfamsearchfile,
    'size|s:i'        => \$INP_fragment_size,
	 'bzip|b'          => \$INP_infile_bzipped,
	 'matrixdir|dir=s' => \$INP_matrixdir,
	 'keggmap|km=s'    => \$INP_keggmapfile,
	 'minentropy|min=f'=> \$INP_minentropy,
	 'pathway|pw=s'    => \$INP_pathways
);

if (-t STDIN && ($INP_help || $INP_pfamsearchfile eq ''))
{
die<<EODOC;

Program to produce random fragments of proteins in input file with size and coverage set by user.

usage: $0 [options] 

 -help             brief help message
 
 -input            input file with HMM matches created by hmmsearch, tbl format

 -size             desired size for produced random fragments    (integer, default $INP_fragment_size)
 
 -bzip             input file is bzip2-compressed
 
 -matrixdir        directory containing hmm matrices from fragments of variable size (string, \n                    default $DEFAULTMATRIXDIR)
 
 -minentropy       min relative entropy of HMMs to be considered (float)
						 
 -keggmap          file with HMM to KEGG mappings
 
 -pathway          comma-separated pathway numbers from -keggmap file to consider only member HMMs  (string, by default all pathways are used, requires -keggmap)

EODOC
}
   
if(!-s $INP_pfamsearchfile)
{
    die "# ERROR : cannot locate input file -input $INP_pfamsearchfile\n";
}  

if($INP_fragment_size < 1)
{
    die "# ERROR : invalid value for fragment size ($INP_fragment_size)\n";
}

if($INP_keggmapfile && !-s $INP_keggmapfile)
{
    die "# ERROR : cannot locate input file -keggmap $INP_keggmapfile\n";
}
elsif($INP_keggmapfile)
{
	if($INP_pathways)
	{
		foreach $pw (split(/,/,$INP_pathways))
		{
			push(@user_pathways,$pw);
		}
	}
}

print "# $0 call:\n# -input $INP_pfamsearchfile -size $INP_fragment_size -bzip $INP_infile_bzipped ".
	"-matrixdir $INP_matrixdir -minentropy $INP_minentropy -keggmap $INP_keggmapfile -pathway $INP_pathways\n\n";

################################################

my (%HMMentropy,@HMMs,%matchedHMMs,%KEGGmap,$hmm,$KEGGid,$entropy);

## locate appropriate hmm matrix containing relative entropies 
my $matrixfile = $DEFAULTMATRIXFILENAME;
$matrixfile =~ s/XXX/$INP_fragment_size/;

open(HMMMATRIX,"$INP_matrixdir/$matrixfile") || 
	die "# $0 : cannot find $INP_matrixdir/$matrixfile, please check paths and re-run\n";
while(<HMMMATRIX>)
{	
	#	PF00005	PF00009	...
	if(/^\tPF\d+\t/)
	{
		chomp;
		@HMMs = split(/\t/,$_); #print;
	}
	elsif(/^rel_entropy/)
	{
		chomp;
		my @entropies = split(/\t/,$_);
		foreach $hmm (1 .. $#HMMs)
		{
			$HMMentropy{$HMMs[$hmm]} = $entropies[$hmm];
		}
		
		last;
	}
}
close(HMMMATRIX);

printf("# total HMMs with assigned entropy in %s : %d\n\n",
	"$INP_matrixdir/$matrixfile",scalar(keys(%HMMentropy)));
	
## parse HMM2KEGG2pathway mappings file if required
my %pathways;

if($INP_keggmapfile)
{
	open(KEGGMAP,$INP_keggmapfile);
	while(<KEGGMAP>)
	{
		#pfam 	ko	pathway
		#PF00171	K00135 12
		if(/^(PF\d+)\t(K\d+)\t(\d+)/)
		{ 
			push(@{$KEGGmap{$1}},$2); 			
			$pathways{$1}{$3} = 1;
		}
	}
	close(KEGGMAP);
}
	
	
## read input file with hmmsearch output in tab-separated format
my $maxmatches = 0;
my $pathwayOK;
if($INP_infile_bzipped)
{
	open(INFILE,"bzcat $INP_pfamsearchfile|") ||
		die "# $0 : cannot find $INP_pfamsearchfile, please check paths and re-run\n";
}
else
{
	open(INFILE,$INP_pfamsearchfile) ||
		die "# $0 : cannot find $INP_pfamsearchfile, please check paths and re-run\n";
}

while(<INFILE>)
{
	#5723145_1_98_+          -          2-Hacid_dh           PF00389.25   1.9e-08   36.7   0.1   1.9e-08   36.7   0.1   1.0   1   0   0   1   1   1   1 -
	#SRR000281.13791_1_100_+ -          2-Hacid_dh           PF00389.25   6.1e-06   28.6   0.1   6.1e-06   28.6   0.0   1.0   1   0   0   1   1   1   1 -
	chomp;
	next if(/^#/ || /^\s+$/);

	my @data = split(/\s+/,$_);
	$hmm = $data[3]; #print "$hmm\n"; 
	$hmm = (split(/\.\d+/,$hmm))[0]; #print "$hmm\n"; exit;
	
	if($INP_pathways)
	{
		$pathwayOK = 0;
		foreach $pw (@user_pathways)
		{
			if($pathways{$hmm}{$pw}){ $pathwayOK = 1; last } 
		}
		next if($pathwayOK == 0);
	}
	
	if($HMMentropy{$hmm} && $HMMentropy{$hmm} >= $INP_minentropy)
	{
		$matchedHMMs{$hmm}++;
		if($matchedHMMs{$hmm} > $maxmatches){ $maxmatches = $matchedHMMs{$hmm} }
		#print "$hmm $entropy\n";
	}
}
close(INFILE);


## produce final scores based on observed matched HMMs

my ($qualscore,$matches,$mapscript,$color,%previous) = (0,0,'');
foreach $hmm (@HMMs)
{
	$matches = $matchedHMMs{$hmm} || 0;
	$entropy = $HMMentropy{$hmm};
	
	if($matches>0)
	{
		$qualscore += $entropy;
		$color = $COLORS[ int(($matches/$maxmatches)*$#COLORS) ];
		
		# prepare KEGG mappings for http://www.genome.jp/kegg-bin/show_pathway
		foreach $KEGGid (@{$KEGGmap{$hmm}})
		{
			next if($previous{$KEGGid});
			$mapscript .= "$KEGGid $color,black\n";
			$previous{$KEGGid}++;
		}
	}
	#else{}
	
	print "$hmm\t$entropy\t$matches\n";	
}

print "\nqualscore: $qualscore\n\n$mapscript";
