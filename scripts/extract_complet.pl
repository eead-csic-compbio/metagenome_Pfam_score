#!/usr/bin/perl -w
use strict;
use Getopt::Long;
use FindBin '$Bin';

# This script takes a folder and reads the output from pfam_score.pl using the -keggmap option 

#Output 

# 1) TAB-separated file with rows containing the input file name and columns the 
# metabolic pathways 

# B Contreras-Moreira, V de Anda 2016

my ($INP_help, $INP_dir)=('','');

GetOptions
(
  'help|h|?'        => \$INP_help,
  'dir|dir=s'      => \$INP_dir,
);

if (-t STDIN && ($INP_help)
{
die<<EODOC;

Program to parse the output of pfam_score.pl using the option -keggmap to compute some statistics 

usage: $0 [options] 

 -help        Brief help message

 -dir         Directory containing the output of th   
 -tax         NCBI file to add taxonomy (package Complete_lists::NCBI_Taxonomy)
EODOC
}
if (!-s $INP_dir)
{
 die "#ERROR: cannot locate directory contaning score ouptus $INP_dir\n";
}
print "# $0 call:\n#" ;

##1) Find the score file 

my $scores;

	opendir(SCORES, $INP_dir) || die "#$0: ERROR: cannot list $INP_dir\n"; 

##2) Parse score files 

	open(INFILE, "$INP_dir/$scores") || die "#$0: ERROR: cannot list $INP_dir/$scores\n"; 
	while(<INFILE>)
	chomp;
	next if (/^#/) || /^PF/;
	my  @score = grep {/"Pfam entropy score:"/} $_;
        
my @path_out = split(/\t/);
	$pathways=$path_out[0]
	$complet=$path_out[5]




       1 .... 29 mean_com median_compl percent_75  SS 
bichoa
bichob
bichoc 
