#!/bin/bash

if [ $# -eq 0 ] 
  then 
    echo "# Need the name of folder containing .faa genome files";
    exit;
fi

inputdir=$1
pathway="Sulfur cycle"
datadir=sulfur_data_test
cutoff=8.705
maxscore=16.01

# 1) Get the Pfam domain composition of proteins
for i in $inputdir/*.faa; do \
  echo "# Annotating $pathway Pfam domains in $i ..."
  if [ ! -f $i.out.hmmsearch.tab ]; then \
    type hmmsearch >/dev/null 2>&1 || { echo >&2 "# hmmsearch not found, please install"; exit 1; }
    hmmsearch  --cut_ga -o /dev/null --tblout \
      $i.out.hmmsearch.tab $datadir/my_Pfam.sulfur.hmm $i; \
  fi
done

echo "$pathway domain composition done"
echo 

# 2) Get their Sulfur Score   
echo "Computing Multigenomic Entropy-Based Score (MEBS) final score ..." 
for file in $inputdir/*.tab; do \
  perl scripts/pfam_score.pl -input $file \
  -entropyfile $datadir/entropies_matrix_entropies.tab -size real > $file.score; \
  MEBS_Score=`grep "Pfam entropy score" $file.score`
  echo "# $file" 
  echo $MEBS_Score 
done

echo "MEBS final Score done"
echo 
echo "NOTE: According to our $pathway benchmarks, a score > $cutoff indicates"
echo "that your genome is most likely involved in the $pathway . " 
echo "The maximum expcted $pathway score is $maxscore ." 
echo "Thanks for using MEBS" 
