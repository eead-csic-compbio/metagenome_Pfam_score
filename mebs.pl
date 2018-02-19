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

# Get Pfam domain composition for all cycles
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


#$HMMSEARCHEXE

#  if [ ! -f $i.out.hmmsearch.tab ]; then \
#        type hmmsearch >/dev/null 2>&1 || { echo >&2 "# hmmsearch not found, please install"; exit 1; }
#            hmmsearch  --cut_ga -o /dev/null --tblout \
#                  $i.out.hmmsearch.tab $datadir/my_Pfam.sulfur.hmm $i; \
#                    fi

