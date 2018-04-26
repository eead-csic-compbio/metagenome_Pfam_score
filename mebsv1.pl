#!/usr/bin/perl -w

use strict;
use Getopt::Long;
use FindBin '$Bin';

# General script to score biogeochem cycles in bth genomic and metagenomic data.
# B Contreras-Moreira, V de Anda 2018

my $HMMSEARCHEXE = 'hmmsearch'; # please edit if not in path

my $CONFIGDIR   = $Bin.'/config/';
my $CONFIGFILE  = $CONFIGDIR . 'config.txt';
my $VALIDEXT    = '.faa';
my $VALIDENT    = '.tab'; # valid extension for pre-computed entropy files
my $VALIDHMMEXT = '.hmm'; # valid extension for HMM files
my $HMMOUTEXT   = '.hmmsearch.tab'; # default extension for hmmsearch tbl output
my $FDR         = 0.01;
my @validFDR    = qw(0.1 0.01 0.001 0.0001);
my @validMSL    = qw(30 60 100 150 200 250 300);
my ($INP_help,$INP_folder,$INP_cycles,$INP_type,$INP_FDR) = (0,'',0,'',$FDR);
my $INP_comp   = '';

GetOptions
(
  'help|h|?'    => \$INP_help,
  'input|in=s'  => \$INP_folder,
  'type|t=s'    => \$INP_type,
  'cycles|c'    => \$INP_cycles,
  'fdr|r=f'     => \$INP_FDR,
  'comp|t=s'    => \$INP_comp,
);


if (-t STDIN && ($INP_help || $INP_folder eq '' || $INP_type eq '') && !$INP_cycles)
{
  die<<EODOC;

  Program to compute MEBS for a set of genomic/metagenomic FASTA files in input folder.

  usage: $0 [options] 

   -help    Brief help message
   
   -input   Folder containing FASTA peptide files ($VALIDEXT)                  (required)

   -type    Nature of input sequences, either 'genomic' or 'metagenomic'  (required)

   -fdr     Score cycles with False Discovery Rate @validFDR  (optional, default=$FDR)

   -cycles  Show currently supported biogeochemical cycles

   -comp   Compute the metabolic completeness. (Currently only the sulfur cycle is supported)

EODOC
}

## 1) Checking binaries
if(!$HMMSEARCHEXE )
{
  die "#ERROR:  hmmsearch not found, please install or set \$HMMSEARCHEXE correctly\n";
}

## 2) Checking parameters
my (@valid_infiles, @cycles, @config, @paths, @MSL, %FDRcutoff, %col2fdr);
my ($c,$f,$path,$cycle,$msl,$score);
my ($hmmfile,$hmmsearchfile,$entropyfile,$scorefile,$infile);

# Read config file
open(CONFIG,$CONFIGFILE) || die "# ERROR: cannot read $CONFIGFILE\n";
while(my $line = <CONFIG>)
{
  #Cycle Path  Input Genes Input Genomes   Domains AUC Score(FDR0.1) Score(FDR0.01)  Score(FDR0.001) Score(FDR0.0001)
  #sulfur  cycles/sulfur/  152 161 112 0.985 4.045 5.231 6.328 8.198
  @config = split(/\t/,$line);
  if($config[0] =~ /^Cycle/)
  {
    # check which columns in config match which FDR-based cutoffs
    foreach $c (1 .. $#config)
    {
      if($config[$c] =~ /Score\(FDR(0\.\d+)/)
      {
        $col2fdr{$c} = $1;
      }
    }
  }
  else
  {
    push(@cycles, $config[0]);
    push(@paths, $config[1]);
    # save score FDR cutoffs
    foreach $c (keys(%col2fdr))
    {
      $FDRcutoff{$config[0]}{$col2fdr{$c}} = $config[$c];
    }
  }  
}
close(CONFIG);

if ($INP_cycles)
{
  print "# Available cycles:\n". join("\n",@cycles)."\n\n";
  exit(0);
}
else
{
  warn "# $0 -input $INP_folder -type $INP_type -fdr $INP_FDR\n\n";
}

# check required sequence type
if(!$INP_type || ($INP_type ne 'genomic' && $INP_type ne 'metagenomic'))
{
  die "# ERROR : type of input must be indicated; valid options are [genomic|metagenomic]\n";
}

# check required sequence folder
if(!$INP_folder)
{
  die "# ERROR : need valid -input folder\n";
}
else
{
  opendir(DIR,$INP_folder) || die "# ERROR: cannot list $INP_folder\n";
  @valid_infiles = grep{/$VALIDEXT$/} readdir(DIR);
  closedir(DIR);
  if(scalar(@valid_infiles) == 0)
  {
    die "# ERROR: cannot find files with extension $VALIDEXT in folder $INP_folder\n";
  }
  elsif($INP_type eq 'metagenomic')
  {
    # compute Mean Size Length for this metagenomic sequence set
    warn "# Computing Mean Size Length (MSL) ...\n";

    my ($c,$nseq,$mean,$len,$cutoff,@MSLcutoffs);
    for(my $bin=0;$bin<scalar(@validMSL)-1;$bin++)
    {
      $cutoff = $validMSL[$bin] + (($validMSL[$bin+1]-$validMSL[$bin])/2);
      push(@MSLcutoffs,$cutoff);#print "$validMSL[$bin] $cutoff\n";
    }
    push(@MSLcutoffs,$validMSL[$#validMSL]); # add last MSL

    foreach my $infile (@valid_infiles)
    {
      ($nseq,$mean,$len) = (0,0,0);
      open(FAAFILE,"<","$INP_folder/$infile") || 
        die "# ERROR: cannot read files $INP_folder/$infile\n";
      while(<FAAFILE>)
      {
        if(/^>/)
        {
          $nseq++;
          $mean += $len;
          $len=0;
        }
        else
        {
          chomp;
          $len += length($_);
        }
      }
      close(FAAFILE);

      $mean = sprintf("%1.0f",$mean/$nseq);

      # find out which pre-defined MSL bin matches the estimated MSL for this sequence set
      foreach $c (0 .. $#MSLcutoffs)
      {
        $cutoff = $MSLcutoffs[$c];
        if($mean <= $cutoff)
        {
          push(@MSL,$validMSL[$c]);
          warn "# $infile MSL=$mean MSLbin=$validMSL[$c]\n";

          last;
        }
      }
    }
  } print "\n";
}

## check optional FDR 
if($INP_FDR)   
{
  if(!grep (/^$INP_FDR$/, @validFDR))
  {
    die "# ERROR: FDR value is not valid; please choose from ".join(', ',@validFDR)."\n";
  }
}

## 3) scan input sequences with selected Pfam HMMs for each input file & cycle

# print header
foreach $c (0 .. $#cycles)
{
  print "\t$cycles[$c]";
} print "\n";

foreach $f (0 .. $#valid_infiles)
{
  $infile = $valid_infiles[$f];

  print "$infile"; # rowname

  foreach $c (0 .. $#cycles)
  {
    $path = $paths[$c];
    $cycle = $cycles[$c];
    $score = 'NA';

    $hmmsearchfile = $INP_folder . '/' . $infile . '.' . $cycle . $HMMOUTEXT;
    $scorefile = $INP_folder . '/' . $infile . '.' . $cycle . '.score';
    $hmmfile = $path . 'my_Pfam.'. $cycle . $VALIDHMMEXT;
    $entropyfile = $path . 'entropies' . $VALIDENT;

    system("$HMMSEARCHEXE --cut_ga -o /dev/null --tblout $hmmsearchfile $hmmfile $INP_folder/$infile");

    if(-s $hmmsearchfile)
    {
      if($INP_type eq 'metagenomic')
      {
        system("$Bin/scripts/pfam_score.pl -input $hmmsearchfile -entropyfile $entropyfile -size $MSL[$f] > $scorefile");
      }
      else
      {
        system("$Bin/scripts/pfam_score.pl -input $hmmsearchfile -entropyfile $entropyfile > $scorefile");
      }
      
      if(-s $scorefile)
      {
        $score = -1;
        open(SCORE,"<",$scorefile) || warn "# ERROR: cannot read $scorefile\n";
        while(<SCORE>)
        {
          if(/Pfam entropy score: (\S+)/){ $score = sprintf("%1.3f",$1) } 
        }
        close(SCORE);  
      }
      else { warn "# ERROR: failed to generate $scorefile\n"  }
    }
    else { warn "# ERROR: failed to generate $hmmsearchfile\n" }

    # compare score to FDR-based cutoff
    if($score ne 'NA' && $score >= $FDRcutoff{$cycle}{$INP_FDR})
    {
      $score .= '*';
    }

    print "\t$score";
  }
  print "\n";
}


























