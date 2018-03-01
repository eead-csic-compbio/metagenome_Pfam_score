#!/usr/bin/perl -w
use strict;
use Getopt::Long;
use FindBin '$Bin';

# General script to score biogeochem cycles in bth genomic and metagenomic data.
# B Contreras-Moreira, V de Anda 2018

my $HMMSEARCHEXE = 'hmmsearch'; # please edit if not in path

my $CONFIGDIR   = $Bin.'/config/'; 
my $CONFIGPATHS = $CONFIGDIR . 'config.txt';
my $VALIDEXT    = '.faa'; 
my $VALIDHMMEXT = '.hmm';
my $FDR         = 0.01;

my @validFDR    = qw(0.1 0.01 0.001 0.0001);

my ($INP_help,$INP_folder,$INP_cycles,$INP_type,$INP_FDR) = (0,'',0,'',$FDR);

GetOptions
(
  'help|h|?'    => \$INP_help,
  'input|in=s'  => \$INP_folder,
  'type|t=s'    => \$INP_type,
  'cycles|c'    => \$INP_cycles,
  'fdr|r=f'     => \$INP_FDR
);


if (-t STDIN && ($INP_help || $INP_folder eq '' || $INP_type eq '') && !$INP_cycles)
{
  die<<EODOC;

  Program to compute MEBS for a set of genomic/metagenomic FASTA files in input folder.

  usage: $0 [options] 

   -help    Brief help message
   
   -input   Folder containing FASTA peptide files ($VALIDEXT), 1 / genome or metagenome (required)

   -type    Nature of inputed sequences, either 'genomic' or 'metagenomic'              (required)

   -fdr     Score cycles with False Discovery Rate (0.1, 0.01, 0.001 & 0.0001)          (optional)
            Default: $FDR

   -cycles  Show currently supported biogeochemical cycles

EODOC
}

# main variables
my (@valid_infiles,%cycles);
my ($cycle,$infile,$HMMfile);

## 1) check input options #########################

# optional show cycles
if($INP_cycles)
{
  open(PATHS,$CONFIGPATHS) || die "# ERROR: cannot read $CONFIGPATHS\n";
  while(<PATHS>)
  {
    print;
  }
  close(PATHS);
  exit(0);
}

# check required input
if(!$INP_folder)
{
  die "# ERROR : need valid folder\n";
###agregue esta opcion para que hubiera un warning en caso de que solo diera un input, pero no se si va dentro de este if por que no funciona.. 

if ($INP_folder ne '')
  {
  die "#ERROR: require both -input and -type options\n";
  }

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

}


if(!$INP_type || ($INP_type ne 'genomic' && $INP_type ne 'metagenomic'))
{
    die "# ERROR : type of input must be indicated; valid options are [genomic|metagenomic]\n";
}

# other options
if(defined($INP_FDR))
{
  my $is_valid = 0;
  foreach my $fdr (@validFDR)
  {
    if($fdr eq $INP_FDR){ $is_valid = 1; last }
  }

  if(!$is_valid)
  {
    die "# ERROR: FDR value is not valid; please choose from ".join(', ',@validFDR)."\n";
  }
}

print "#call:\n# -input $INP_folder -type $INP_type -fdr $INP_FDR"

#########################################################################
###Check that hmmsearch is installed 
###Diferencia entre ! y eq '' (no está y vacio?) 

if  (!$HMMSEARCHEXE )
  {
  die "#ERROR:  hmmsearch not found, please install\n"
  }


## 2) scan input sequences with selected Pfam HMMs for each cycle

# check available cycles
open(PATHS,$CONFIGPATHS) || die "# ERROR: cannot read $CONFIGPATHS\n";
while(my $line = <PATHS>)
{
  next if($line =~ /^$/ || $line =~ /^#/ || $line =~ /^Pathway/);
  my @data = split(/\t/,$line);
  $cycle = shift(@data);
  $cycles{$cycle} = [ @data ];
}
close(PATHS);

# Get Pfam domain composition (current databases in MEBS) for all cycles
foreach $cycle (keys(%cycles))
{
  opendir(CYCLEDIR,$cycles{$cycle}[0]) || die "# ERROR: cannot list $cycles{$cycle}[0], please check $CONFIGPATHS\n";
  my @HMM_files = grep{/$VALIDHMMEXT$/} readdir(CYCLEDIR);
  closedir(DIR);

  foreach $HMMfile (@HMM_files)
  { 

    print "## $cycle $HMMfile\n";

    foreach $infile (@valid_infiles)
    {
      print "# $infile\n";
    }
  }
}


### Get Pfam domain composition of input data against MEBS databases

opendir(DIR,$INP_folder) || die "# $0 : ERROR : cannot list $INP_dir\n";
foreach my $fasta (@DIR)
    {
###foreach cycle(@INP_cycle) (abrir la linea de config, y entrar a cada  cycle=*hmm,) 

###Decirle que  ejecute como un comando de bash?

hmmsearch  --cut_ga -o /dev/null --tblout $fasta.$cycle.hmmsearch.tab $cycle $fasta 

###guardar los hmmsearch de cada fasta con otra variable $fasta.tab? 
closedir()

   }


###Una vez que hace los hmmseearch,si es genoma se calcula directo el score, si no 
### si es metagenoma se tiene que medir MSL 

### Para calcular el score primero se necesita guardar en una variable los archivos de entropias de cada cyclo , imagino que se puede hacer en un  if, aprovechando que entramos a la carpeta de cada ciclo con el archivo config, los datos que necesitamos son  los archivos hmm y el archivo de entropias  



if($INP_cycles)
{
  open(PATHS,$CONFIGPATHS) || die "# ERROR: cannot read $CONFIGPATHS\n";
  while(<PATHS>)
  {
  next if (/^#/);
  chomp;
  $cyle =(split(/\t/,$_)[1];
  ##la segunda columna tiene los paths
  ## ejemplo cycles/sulfur
  ## todas las entropies se llaman entropies.tab 
  ## seria lgo asi?
  ### entropies= $BIN./cycle/entropies.tab
  }
  close(PATHS);

##Una vez que tenemos las variables se calcula el score para archivo .tab de $INP_type
##Guardar en otra variable lo archivos de salida (score)  

if ($INP_type='genomic')

  {  

#perl $BIN/scripts/pfam_score.pl -input $gen.$cycle.tab \
#      -entropyfile $cycle.entropy > $gen.$cycle.score
  }

     else

     {
     }
      opendir (DIR,$INP_folder)
      foreach my $met(@DIR)
       {
       }
     
####Este es el codigo que teniamos antes,(para cada fasta hacia este perl -lne , hagria que modificarlo para que lo haga para cda met, recuerdo que lo ptimizaste para que no tardara mucho en correr
###     my $MSL=if(/^(>.*)/){$nseq++;$m+=$l;$l=0}else{$l+=length($_)} END{ $m+=$l; printf("%1.0f\n",$m/$nseq) }' 

### 2) Find out appropriate fragment size of classifier (genF), recomiendas que esto se defina aqui o desde el principio?, es decir si o ponemos como variables generals?
#  GENF=`perl -e 'BEGIN{@bins=(30,60,100,150,200,250,300);@th=(45,80,125,175,225,275,300)} foreach $i (0 .. $#th){ if($ARGV[0]<=$th[$i]){ print $bins[$i]; exit }}' $MSL`
      
   
###Get the Score for each cycle
###Para esto necesitamos guardar los hmmsearch en una variable y diferenciar entre cada cyclo ($cycle.tab) 
###Guardar el msl en otra variable 
###correr desde bash

      #perl $BIN/scripts/pfam_score.pl -input $cycle.tab \
      #-size $GENF -entropyfile $cycle.entropy > $met.$cycle.score

    
##Finalmente se hace un grep al score de cada  file, si se tomo en cuenta un FDR hacer un if, si no da directamente el resultado.. 

#Yo creo que seria mas facil hacer este if para cada tipo de archivo (genoma o metagenoma) para que sepa diferenciar que archivos de score tiene que abrir, pero seria el mismo codigo para los dos,  o lo hacemos en otro if general... ?
  
if ($INP_FDR eq '')

{
foreach $score(@scores) 
#Grep de cada score 
#valuescore=if(/Pfam entropy score: (\S+)/){ print $1 }' `
#print  $valuescore
}

else 
{


foreach $myfdr{@validFDR}
open(PATHS,$CONFIGPATHS) || die "# ERROR: cannot read $CONFIGPATHS\n";
  while(<PATHS>)
  {
  next if (/^#/);
  chomp;
  if ($myfdr = 0.1) 
  {
  $fdr =(split(/\t/,$_)[6];
  } 
  if ($myfdr =0.01)
  {
  $fdr =(split(/\t/,$_)[7];
  } 
  if ($myfdr=0.001)
  {
  $fdr =(split(/\t/,$_)[8];
  }
  if ($myfdr=0.0001)
  {
  $fdr =(split(/\t/,$_)[9];
  }
}








