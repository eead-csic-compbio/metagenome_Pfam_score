#!/usr/bin/perl -w

use strict;
use Getopt::Long;
use FindBin '$Bin';

# ---------------------------------------------------------
# Name:           mebs.pl
# Purpose:        General script that depends on pfam_score.pl to compute MEBS from input data
# Authors:        B Contreras-Moreira (bcontreras@eead.csic.es) and V de Anda (valdeanda@ciencias.unam.mx) 
# Created:        2018
# Licence:        GNU GENERAL PUBLIC LICENSE 
# Description:    For each omic file (either genome, metagenome, mag in fasta .aa format), 
#                 mebs.pl will run hmmsearch against the databases located in /cycles directory
#                 to compute MEBS scores and completeness.
#
# Last updated:   July 2019  
# Version:        v1.3 (KEGG option) 
# Custom option added February 2019 (v1.2)
# KEGG option added July 2019 (v1.3)
# ---------------------------------------------------------

#Main variables 

my $VERSION = 'v1.3';
my $DEBUG = 0;

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
my ($INP_help,$INP_folder,$INP_cycles,$INP_type,$INP_FDR, $INP_comp,$INP_pfam, $INP_kegg) = (0,'',0,'',$FDR,0,0,0);

#custom option to compute completeness using current Pfam db  (MEBS v1.2) 

my $WGETEXE           = 'wget'; # add path if required, likely not pre-installed in MacOS
my $BINTGZFILE        = 'bin.tgz';
my $PFAMSERVERURL     = 'ftp.ebi.ac.uk';
my $PFAMFOLDER        = 'pub/databases/Pfam/current_release/';
my $PFAMHMMFILE       = 'Pfam-A.hmm.gz';
my $PFAMHMMDECO       = 'Pfam-A.hmm'; 
my $PFAMNAME          = 'my_Pfam.pfam.hmm';
my $PFAMDIR           = $Bin.'/cycles/pfam_custom';
my $PFAM_HMMS         = $Bin.'/cycles/pfam_custom/my_Pfam.pfam.hmm';
my $PFAMCUSTOM_FILE   = $Bin.'/cycles/pfam_custom/pfam2kegg.tab';

#custom option to compute completeness using KEGG db (MEBS v1.3) 

my $KEGGSERVERURL   = 'ftp://ftp.genome.jp/pub/db/kofam/';
my $KEGGFOLDER      = 'profiles.tar.gz';
my $KEGG_HMMS       = $Bin.'/cycles/kegg/my_Pfam.kegg.hmm';
my $KEGGDIR         = $Bin.'/cycles/kegg_custom';
my $KEGGCUSTOM_FILE = $Bin.'/cycles/kegg_custom/pfam2kegg.tab';

#---------------------------------------------------------

GetOptions
(
  'help|h|?'    => \$INP_help,
  'input|in=s'  => \$INP_folder,
  'type|t=s'    => \$INP_type,
  'cycles|c'    => \$INP_cycles,
  'fdr|r=f'     => \$INP_FDR,
  'comp|mc'     => \$INP_comp,
  'pfam|p'      => \$INP_pfam,
  'kegg|k'      => \$INP_kegg, 
);


if (-t STDIN && ($INP_help || $INP_folder eq '' || $INP_type eq '') && 
	!$INP_cycles  &&! $INP_pfam &&! $INP_kegg)
{
  die<<EODOC;

  Program to compute MEBS or completeness for a set of FASTA files in a given input folder.
  Version: $VERSION

  usage: $0 [options] 

   -help   Brief help message
   
   -input  Folder containing FASTA peptide files ($VALIDEXT).                 (required)

   -type   Nature of input sequences, either 'genomic' or 'metagenomic'. (required)
           If you have Metagenome-Assembled Genomes (MAGs) we recommend
           to use the 'genomic' option.

   -fdr    Score cycles with False Discovery Rate (FDR).                 (optional, default=$FDR)
           Computes whether input peptides are enriched in a given cycle.
           The most restrictive FDR (i.e 0.0001) the less false positives.
           Cycles matching precalculated FDR-based cutoffs are indicated with asterisks. 
           Valid options are: @validFDR 

   -cycles Show supported biogeochemical cycles/pathways.
   
   -comp   Compute the metabolic completeness of supported cycles        (optional) 
           or pathways. We define metabolic completenness as the full
           set of protein domains involved in a given metabolic pathway,
           such as sulfate reduction or methanogenesis. 
           This option is required for visualization with mebs_output.py		

   -pfam   Compute presence/absence of custom PFAMs.                     (optional, requires -comp)
           Please modify the cycles/pfam_custom/pfam2kegg.tab file
           if you want to define your own custom set of PFAM domains.   
           This option involves downloading PFAM db (large file >1GB)
           and does not evaluate MEBS score.	

   -kegg   Compute presence/absence of KOs in the input data.            (optional, requires -comp)
           Please modify the cycles/kegg_custom/pfam2kegg.tab file
           if you want to define your own custom set of KO orthogroups.   
           This option involves downloading KEGG hmms (large file >1GB) 
           and does not evaluate MEBS score.			

EODOC
}


## 1) Checking binaries
my $sample_output = `$HMMSEARCHEXE -h 2>&1 `;
if(!$HMMSEARCHEXE || !$sample_output || $sample_output !~ /Usage/)
{
  die "#ERROR:  hmmsearch not found, please install or set \$HMMSEARCHEXE correctly\n";
}

## 2) Checking parameters
my (@valid_infiles, @cycles, @config, @paths, @completeness);
my (@MSL, %FDRcutoff, %col2fdr, %pathways);
my ($c,$f,$path,$cycle,$msl,$score,$comp,$pw);
my ($hmmfile,$hmmsearchfile,$entropyfile,$scorefile,$infile,$pfam2keggfile);


# Read config file

open(CONFIG,$CONFIGFILE) || die "# ERROR: cannot read $CONFIGFILE\n";
while(my $line = <CONFIG>)
{
  #Cycle   Path    Comple  Input Genes     Input Genomes   Domains AUC     Score(FD..
  #sulfur  cycles/sulfur/  cycles/sulfur/pfam2kegg.tab     152     161     112    ..
  #oxygen  cycles/oxygen/    50  53  55  ...

  next if($line =~ m/^\s+/);

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
    if($DEBUG == 1){ print "$config[0],$config[1],$config[2]\n" }
    push(@cycles, $config[0]);
    push(@paths, $config[1]);
    push(@completeness, $config[2]); # $config[2] might be '' if not curated 


    # save score FDR cutoffs
    foreach $c (keys(%col2fdr))
    {
      $FDRcutoff{$config[0]}{$col2fdr{$c}} = $config[$c];
    }

  }  
}
close(CONFIG); 

if ($INP_kegg)
{
  print "You selected option -kegg... \n ";  
  print "Veryfing database..\n"; 
}

if ($INP_pfam)
{
  print "You selected option -pfam... \n ";
  print "Veryfing database..\n";

  #code from  https://github.com/eead-csic-compbio/get_homologues/blob/master/install.pl
  if(!-s $PFAM_HMMS)
  {
    print "# $PFAMNAME not found \n";
    print "# connecting to $PFAMSERVERURL ...\n";
    eval{ require Net::FTP; };

    my ($ftp,$downsize);
    if($ftp = Net::FTP->new($PFAMSERVERURL,Passive=>1,Debug =>0,Timeout=>60))
    {
      $ftp->login("anonymous",'-anonymous@') || die "# cannot login ". $ftp->message();
      $ftp->cwd($PFAMFOLDER) || warn "# cannot change working directory to $PFAMFOLDER ". $ftp->message();
      $ftp->binary();
      $downsize = $ftp->size($PFAMHMMFILE);
      $ftp->hash(\*STDOUT,$downsize/20) if($downsize);
      printf("# downloading Pfam database, please wait........\n");
      printf("# downloading ftp://%s/%s/%s (%1.1fMb) ...\n",
	      $PFAMSERVERURL,$PFAMFOLDER,$PFAMHMMFILE,$downsize/(1024*1024));
      print "# [        50%       ]\n# ";

      if(!$ftp->get($PFAMHMMFILE))
      {
        warn "# cannot download file $PFAMHMMFILE ". $ftp->message() ."\n\n";
        warn "<< You might download $PFAMHMMFILE from $PFAMSERVERURL/$PFAMFOLDER to $PFAMFOLDER\n".
              "<< Then re-run\n";
      }
    }  
    else
    {
      warn "# cannot connect to $PFAMSERVERURL: $@\n\n";
      warn "<< You might download $PFAMHMMFILE from $PFAMSERVERURL/$PFAMFOLDER to $PFAMFOLDER>>";
    }
 
    print "\n";
    exit(0);
  }
}


if ($INP_cycles)
{
  print "# Available cycles:\n". join("\n",@cycles)."\n\n";
  print "# Available files to compute completeness:\n". join("\n",@completeness)."\n\n";
  exit(0);
}
else
{
  warn "# $0 -input $INP_folder -type $INP_type -fdr $INP_FDR -comp $INP_comp\n\n";
}
 
# check required sequence type
#

if(!$INP_type || ($INP_type ne 'genomic' && $INP_type ne 'metagenomic'))
{
  die "# ERROR : type of input must be indicated; valid options are [genomic|metagenomic]\n";
}





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

# check optional FDR 
if($INP_FDR)   
{
  if(!grep (/^$INP_FDR$/, @validFDR))
  {
    die "# ERROR: FDR value is not valid; please choose from ".join(', ',@validFDR)."\n";
  }
}

#
## 3) scan input sequences with selected Pfam HMMs for each input file & cycle

# print header
my $pathways_header = '';
foreach $c (0 .. $#cycles)
{
  print "\t$cycles[$c]";

  # print completeness header if required
  $comp = $completeness[$c] || "";  
  
  if($INP_comp && $comp ne "" && -s $comp)
  {
    open(COMPFILE,"<",$comp) || warn "# ERROR: cannot read $comp\n";
    while(<COMPFILE>)
    {
      #PFAM  KO  PATHWAY   PATHWAY NAME 
      #PF00890 K00394  1 Sulfite oxidation 
      if(/^PF\d+\t.*?\t(\d+)\t/)
      {
        $pathways{$cycles[$c]}{$1} = 1; 
      }
    }
    close(COMPFILE);
     
    $pathways_header .="\t<$cycles[$c] comp>";
    foreach $pw (sort {$a<=>$b} keys(%{$pathways{$cycles[$c]}}))
    {
      $pathways_header .= "\t$cycles[$c]_$pw";
    }
  }
} print "$pathways_header\n"; 

foreach $f (0 .. $#valid_infiles)
{
  $infile = $valid_infiles[$f];

  print "$infile"; # rowname

  # compute & print scores per cycle
  foreach $c (0 .. $#cycles)
  {
    $path = $paths[$c];
    $cycle = $cycles[$c];
    $comp = $completeness[$c];
    $score = 'NA';

    $hmmsearchfile = $INP_folder . '/' . $infile . '.' . $cycle . $HMMOUTEXT;
    $scorefile = $INP_folder . '/' . $infile . '.' . $cycle . '.score';
    $hmmfile = $path . 'my_Pfam.'. $cycle . $VALIDHMMEXT;
    $entropyfile = $path . 'entropies' . $VALIDENT;

    if(!-s $hmmsearchfile)
    {
      system("$HMMSEARCHEXE --cut_ga -o /dev/null --tblout $hmmsearchfile $hmmfile $INP_folder/$infile");
    }

    if(-s $hmmsearchfile)
    {
      if($INP_type eq 'metagenomic')
      {
        if($INP_comp && $comp ne "" && -s $comp)
        { 
          system("$Bin/scripts/pfam_score.pl -input $hmmsearchfile -entropyfile $entropyfile -size $MSL[$f] -keggmap $comp > $scorefile");
        }
        else
        {
          system("$Bin/scripts/pfam_score.pl -input $hmmsearchfile -entropyfile $entropyfile -size $MSL[$f] > $scorefile");
        }
      }
      else
      {
        if ($INP_comp && $comp ne "" && -s $comp)
        {
          system("$Bin/scripts/pfam_score.pl -input $hmmsearchfile -entropyfile $entropyfile -size real -keggmap $comp > $scorefile");
        }
        else
        {
          system("$Bin/scripts/pfam_score.pl -input $hmmsearchfile -entropyfile $entropyfile -size real > $scorefile");
        }  
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

  # print completeness summary per cycle
  if ($INP_comp)
  {
    foreach $c (0 .. $#cycles)
    {
      $cycle = $cycles[$c];

      # parse score file and check whether completeness report is there
      my ($compOK,%comp_scores) = (0);
      $scorefile = $INP_folder . '/' . $infile . '.' . $cycle . '.score';
      open(COMPL,"<",$scorefile);
      while(<COMPL>)
      {   
        # path_number path_name total_domains matched %completeness matched_Pfam_domains
        #1 Sulfite oxidation   9 3 33.3  PF00890,PF12838,PF01087
        # mean pathway completeness: 37.9
        if(/^# path_number/){ $compOK = 1 }
        elsif($compOK && /^(\d+)\t.*?\t\d+\t\d+\t(\S+)/)
        {
          $comp_scores{$1} = $2;
        }
        elsif(/^# mean pathway completeness: (\S+)/)
        {
          print "\t$1"; # print mean 
        }
      }
      close(COMPL);
    
      # print completeness for all sorted pathways
      foreach $pw (sort {$a<=>$b} keys(%{$pathways{$cycle}}))
      {
        print "\t$comp_scores{$pw}";
      }  
    }
  }    


  print "\n";
}























