#!/usr/bin/perl -w
use strict;
use Getopt::Long;
use FindBin '$Bin';

# This script takes 3 different inputs : 
# 1) folder  contaning the computed Scores for all the different MSL (i.e 30,60,100,150,200,300)

#	4510165.3.27122016.hmmsearch.tab.100.score
#	4510165.3.27122016.hmmsearch.tab.150.score
#	4510165.3.27122016.hmmsearch.tab.200.score
#	4510165.3.27122016.hmmsearch.tab.250.score
#	4510165.3.27122016.hmmsearch.tab.300.score
#	4510165.3.27122016.hmmsearch.tab.30.score
#	4510165.3.27122016.hmmsearch.tab.60.score

# 2) Tab delimiter file contaning the MSL e for each metagenome (MSL.tab) derived from Stage 1, using the following perl lne command:

#for FILE in *; do perl -lne 'if(/^(>.*)/){$h=$1}else{$fa{$h}.=$_} 
#END{ foreach $h (keys(%fa)){$m+=length($fa{$h})}; 
#printf("%1.0f\t",$m/scalar(keys(%fa))) }' $FILE; echo $FILE; done > 
#MSL.tab

#3) MSL to consider the correct Score for each metagenome (MSL.selection.tab) 

#size   msl of each metagenome (Range) 
#30      0..45
#60      46..80
#100     81..125
#150     26..175
#200     176..225
#250     226..275
#300     276..300

# Output:
#1)  TAB-separated output with metagenomes and the corresponding score  (using the table selection) and the scores computed in each size 


# B Contreras-Moreira, V de Anda 2016


my $DEFAULTSCOREDIR = $Bin.'/../data/metagenomic_dataset/computed_scores/';
#my $FILENAMEPATTERN = 'metagenome.faa.date.hmmsearch.tab(\d+)\.score';                 


#Debido a que cada vez que se corrio hmmsearch se cambio el nombre (varios servidores), posiblemente este patron no sea lo adecuado....  
#Lo mejor será abrir el archivo y parsear la primeras linea donde está indicado el tamaño para cada uno 

# -input /media/val/0412BA8912BA7F6C/ROW_DATA/SS_2016/output_hmmsearch_metagenomes/JP5WATER110514AMP.faa.27122016.
#hmmsearch.tab -size 30 -bzip 0 -matrixdir ../data/entropies_matrix/ -minentropy 0 -keggmap  -pathway 


##4510165.3.27122016.hmmsearch.tab.100.score
##JP5WATER110514AMP.faa.27122016.hmmsearch.tab.100.score

my ($INP_help,$INP_scoredir) =(0, $DEFAULTSCOREDIR);
my ( $INP_mslfile, $INP_mslselec) = ('','');

GetOptions
(
    'help|h|?'        => \$INP_help,
         'scoredir|dir=s' => \$INP_scoredir,
         'msl|msl=s'    => \$INP_mslfile,
         'msl_selec|mslss=s'    => \$INP_mslselec
);

if (-t STDIN && ($INP_help || $INP_scoredir || $INP_mslfile || $INP_mslselec eq ''))
{
die<<EODOC;

Program to extract all the Score values computed for metagenomes of different MSL.

usage: $0 [options] 

 -help             brief help message
 
 -scoredir        directory containing computed scores of  several metagenomes  default $DEFAULTSCOREDIR)
                                                
 -MSL.tab         tab separated file with the  MSL of each metagenome in the containing folder directory  
 
 -MSL.selection.tab         comma-separated file with the range to select the correct Score according to the MSL size 

EODOC
}
if(!-s $INP_scoredir)
{
    die "# ERROR : cannot locate directory containing score -scoredir  $INP_scoredir\n";
}  

if(!-s $INP_mslfile)
{
    die "# ERROR : cannot locate input MSL file  ($INP_mslfile)\n";
}

if(!-s $INP_mslselec )
{
    die "# ERROR : cannot locate input MSL selection file  $INP_mslselec\n";
}

print "# $0 call:\n# -scoredir $INP_scoredir -MSL.tab  $INP_mslfile -MSL.selection.tab  $INP_mslselec\n\n";


###########################################################################

## 1) find score files 

my %sizes;
my $size;
my %idnames;

opendir (SCORES, $INP_scoredir) || die "# $0 : ERROR : cannot list $INP_scoredir\n"; 
#my @scorefile = grep{/$FILENAMEPATTERN/}readdir (SCORES);
#modificar para que lea todos los scores 


##2) parse all files 
 
	open(INFILE,"$INP_scoredir/$scores") || die "# $0 : cannot find $INP_scoredir/$scores\n";
	while (<INFILE>)
{
##3) extract size  name and  MSL from FILENAME 

	if ($scores =~m/(^[0-9]{9})|[^a-zA-Z0-9$]/)
	{
##Regex that match the first 9 characteres     ^[0-9]{9}
## Regex that match alphabet or digit before   [^a-zA-Z0-9$]  
##in the case of privates metagenomes 
	$idnames =$1
	
	if ($scores =~m/(\d+)\.score/)
	{
	$sizes  =$1

	}

##4) store metagenomes and sizes 
	
$idnames{$idnames}{$sizes}



##5) Read each score file 

#in bash only grep "Pfam entropy score" *.score 
#4510165.3.27122016.hmmsearch.tab.100.score
#JP5WATER110514AMP.faa.27122016.hmmsearch.tab.100.score:Pfam entropy score: 10.855
#JP5WATER110514AMP.faa.27122016.hmmsearch.tab.150.score:Pfam entropy score: 11.043
#JP5WATER110514AMP.faa.27122016.hmmsearch.tab.200.score:Pfam entropy score: 11.013


 while (<INFILE>)
 {
	next if (/^#/ || /^PF/);
	chomp;	
	my  @match_score = grep {/"Pfam entropy score:"/} $_;
	print @match_score;
	
 }
 close (INFILE);
	



}


#6) Parse third argument (MSL selection) $INP_mslselec

my %size 

if ($INP_mslselec)
{ 	
	open ($INP_mslselec);
	while (<SELECT>)
	{
	chomp;
	:w
my @sizes = split (/\t/);
	$size =$sizes[0]
	$msl = $sizes[0]
$sizes{$size}=$msl
        }

foreach $size (@sizes)

	{



	}	

}

	

