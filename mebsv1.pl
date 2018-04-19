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
   
   -input   Folder containing FASTA peptide files ($VALIDEXT)                  (required)

   -type    Nature of input sequences, either 'genomic' or 'metagenomic'  (required)

   -fdr     Score cycles with False Discovery Rate @validFDR  (optional, default=$FDR)

   -cycles  Show currently supported biogeochemical cycles

EODOC
}

## 1) Checking binaries
if(!$HMMSEARCHEXE )
{
  die "#ERROR:  hmmsearch not found, please install or set \$HMMSEARCHEXE correctly\n";
}

## 2) Checking parameters
my (@valid_infiles, @cycles, @config, @paths, @MSL);
my ($path,$cycle,$msl,$hmmfile,$hmmsearchfile,$entropyfile,$scorefile);

# Read config file
open(CONFIG,$CONFIGFILE) || die "# ERROR: cannot read $CONFIGFILE\n";
while(my $line = <CONFIG>)
{
  next if($line =~ /^Cycle/);
  @config = split(/\t/,$line);
  push(@cycles, $config[0]);
  push(@paths, $config[1]);
}
close(CONFIG);

if ($INP_cycles)
{
  print  "# Available cycles:\n". join("\n",@cycles);
  exit (0);
}
else
{
  print "# $0 -input $INP_folder -type $INP_type -fdr $INP_FDR\n\n";
}

# check required sequence type
if(!$INP_type || ($INP_type ne 'genomic' && $INP_type ne 'metagenomic'))
{
      die "# ERROR : type of input must be indicated; valid options are [genomic|metagenomic]\n";
}

# check required sequence folder
if(!$INP_folder)
{
  die   "# ERROR : need valid -input folder\n";
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
    print "# Computing Mean Size Length (MSL) ...\n";

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
          print "# $infile MSL=$mean MSLbin=$validMSL[$c]\n";

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

print "# $0 -input $INP_folder -type $INP_type -fdr $INP_FDR\n\n";


## 3) scan input sequences with selected Pfam HMMs for each cycle
foreach my $c (0 .. $#cycles)
{
  $path = $paths[$c];
  $cycle = $cycles[$c];

  $hmmfile = $path . 'my_Pfam.'. $cycle . $VALIDHMMEXT;
  $entropyfile = $path . 'entropies' . $VALIDENT;

  print "# $cycle $path\n";

  foreach my $f (0 .. $#valid_infiles)
  {
    my $infile = $valid_infiles[$f];
    $hmmsearchfile = $INP_folder . '/' . $infile . '.' . $cycle . $HMMOUTEXT;
    $scorefile = $INP_folder . '/' . $infile . '.' . $cycle . '.score';

    system("$HMMSEARCHEXE --cut_ga -o /dev/null --tblout $hmmsearchfile $hmmfile $INP_folder/$infile");

    if(-s $hmmsearchfile)
    {
      if($INP_type eq 'metagenomic')
      {
        #print "$Bin/scripts/pfam_score.pl -input $hmmsearchfile -entropyfile $entropyfile -size $MSL[$f] > $scorefile";
        system("$Bin/scripts/pfam_score.pl -input $hmmsearchfile -entropyfile $entropyfile -size $MSL[$f] > $scorefile");
      }
      else
      {
        system("$Bin/scripts/pfam_score.pl -input $hmmsearchfile -entropyfile $entropyfile > $scorefile");
      }  
    }
    else
    {
      print "# ERROR: failed to generate $hmmsearchfile\n";
    }
  }

}


























