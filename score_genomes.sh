#!/bin/bash

if [ $# -eq 0 ] 
  then 
    echo "# Need the name of folder containing .faa genome files";
    exit;
fi

inputdir=$1

datadir=sulfur_data_test

# 1) Get the Pfam domain composition of proteins
# encoded in test genomes 

for i in $inputdir/*.faa; do \
  if [ ! -f $i.out.hmmsearch.tab ]; then \
    type hmmsearch >/dev/null 2>&1 || { echo >&2 "# hmmsearch not found, please install"; exit 1; }

    hmmsearch  --cut_ga -o /dev/null --tblout \
      $i.out.hmmsearch.tab $datadir/my_Pfam.sulfur.hmm $i; \
  fi
done  

echo "Domain composition done" 

# 2) Get their Sulfur Score   

for file in $inputdir/*.tab; do \
  perl scripts/pfam_score.pl -input $file \
  -entropyfile $datadir/entropies_matrix_entropies.tab -size real > $file.score; \
  echo $file.score; tail $file.score; \
done







