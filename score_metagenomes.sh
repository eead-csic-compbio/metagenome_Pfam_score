#!/bin/bash

if [ $# -eq 0 ] 
  then 
    echo "# Need the name of folder containing .faa metagenome files";
    exit;
fi

inputdir=$1

datadir=sulfur_data_test

for i in $inputdir/*.faa; do \
  
  #1) Get the Mean Size Length of peptides encoded in metagenome
  echo $i
  perl -lne 'if(/^(>.*)/){$h=$1}else{$fa{$h}.=$_} END{ foreach $h (keys(%fa)){$m+=length($fa{$h})}; printf("MSL = %1.0f\n",$m/scalar(keys(%fa))) }' $i > $i.msl
  cat $i.msl

  # 2) Find out appropriate fragment size of classifier (genF)
  perl -lne 'BEGIN{@bins=(30,60,100,150,200,250,300);@th=(45,80,125,175,225,275,300)} if(/^MSL = (\S+)/){ $msl=$1; foreach $i (0 .. $#th){ if($msl<=$th[$i]){ print "genF = $bins[$i]"; exit } } }' $i.msl > $i.genF
  cat $i.genF

  #3) Get the Pfam domain composition of metagenomic peptides
  if [ ! -f $i.out.hmmsearch.tab ]; then \
    type hmmsearch >/dev/null 2>&1 || { echo >&2 "# hmmsearch not found, please install"; exit 1; }

    hmmsearch  --cut_ga -o /dev/null --tblout \
      $i.out.hmmsearch.tab $datadir/my_Pfam.sulfur.hmm $i; \
  fi

  #4) Get the Sulfur Score specifying the MSL of your input metagenome 
  genF=`perl -lne 'if(/genF = (\S+)/){ print $1 }' $i.genF`
  perl scripts/pfam_score.pl -input $i.out.hmmsearch.tab \
    -size $genF -entropyfile $datadir/entropies_matrix_entropies.tab > $i.out.hmmsearch.tab.score

  echo $i.out.hmmsearch.tab.score
  echo "..."
  tail $i.out.hmmsearch.tab.score;
done











