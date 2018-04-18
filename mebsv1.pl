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
my $VALIDENT    = '.tab';
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
   
   -input   Folder containing FASTA peptide files ($VALIDEXT),/ genome or metagenome (required)

   -type    Nature of inputed sequences, either 'genomic' or 'metagenomic'              (required)

   -fdr     Score cycles with False Discovery Rate (0.1, 0.01, 0.001 & 0.0001)          (optional)
            Default: $FDR

   -cycles  Show currently supported biogeochemical cycles

EODOC
}

##Checking parameters

if  (!$HMMSEARCHEXE )
  {
  die "#ERROR:  hmmsearch not found, please install\n"
  }


my (@valid_infiles);
my @cycle;
my @config;

if ($INP_cycles)
 {
 open(PATHS,$CONFIGPATHS) || die "# ERROR: cannot read $CONFIGPATHS\n";
 print  print  "#Available cycles:\n";
   while(my $line = <PATHS>)
    { 
      next if($line =~  /^Cycle/);
      chomp $line;
      @config = split(/\t/,$line);
      my $cycle=$config[0];
      print "$cycle\n";
    }

close(PATHS);
exit (0);
   }

# check required input
if(!$INP_folder)
   {
    die   "# ERROR : need valid folder\n";
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

## Optional FDR 

if ($INP_FDR)   
 {
   if (grep (/^$INP_FDR$/, @validFDR))
   {
    print "#Default FDR\n"; 
   }
    else  
      {
     die "# ERROR: FDR value is not valid; please choose from ".join(', ',@validFDR)."\n";
      }
 }

print "#call:\n# -input $INP_folder -type $INP_type -fdr $INP_FDR\n";


## Parameters check 



# 2) scan input sequences with selected Pfam HMMs for each cycle


 open(PATHS,$CONFIGPATHS) || die "# ERROR: cannot read $CONFIGPATHS\n";
 #print  "#Available cycles:\n";
   while(my $line = <PATHS>)
    {
      next if($line =~  /^Cycle/);
      chomp $line;
      @config = split(/\t/,$line);
      my @paths=$config[1];
  
    foreach  my $path(@paths)
    {
    #print "$path\n";
 

opendir(CYCLEDIR,$path) || die "# ERROR: cannot list $path, please check $CONFIGPATHS\n";
my @HMM_files = grep{/$VALIDHMMEXT$/} readdir(CYCLEDIR);
closedir(CYCLEDIR);

## LO TUVE QUE HACER DOS VECES *** IMPROVE WITH BRUNO 
opendir(CYCLEDIR,$path) || die "# ERROR: cannot list $path, please check $CONFIGPATHS\n";
my @ent_files = grep{/$VALIDENT$/} readdir(CYCLEDIR);
closedir(CYCLEDIR);
print  "#Using curated database: @HMM_files and entropy file: @ent_files\n";

   }
}
close(PATHS);

#Para hacer mañana con bruno 

#primero hmmserach de los files.... tengo dudas  de si calcularla de nuevo siempre o usar el previo... 
#yo digo que calcularlo siempre por que el nombre puede cambiar... (Bruno?)

#hmmsearch  --cut_ga -o /dev/null --tblout $fasta.$cycle.hmmsearch.tab $cycle $fasta



if ($INP_type eq 'genomic')

  {


#perl $BIN/scripts/pfam_score.pl -input $gen.$cycle.tab \
#      -entropyfile $cycle.entropy > $gen.$cycle.score
  }

else 

{

print ("#Computing mean size length (MSL)  of your $INP_folder files  to allocate the  proper entropy\n");
#Este es el codigo que teniamos en el bash 

#  MSL=`perl -lne 'if(/^(>.*)/){$nseq++;$m+=$l;$l=0}else{$l+=length($_)} END{ $m+=$l; printf("%1.0f\n",$m/$nseq) }' $i`



}

























