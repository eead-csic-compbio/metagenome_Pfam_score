#!/bin/bash

# 1) Get the Pfam domain composition of proteins
# encoded in test genomes 

for i in test/*.faa; do \
  if [ ! -f $i.out.hmmsearch.tab ]; then \
    type hmmsearch >/dev/null 2>&1 || { echo >&2 "# hmmsearch not found, please install"; exit 1; }

    hmmsearch  --cut_ga -o /dev/null --tblout \
      $i.out.hmmsearch.tab data/my_Pfam.sulfur.hmm $i; \
  fi
done  

echo "Domain composition done" 

# 2) Get their Sulfur Score   

for file in test/*.tab; do \
  perl scripts/pfam_score.pl -input $file \
  -matrixdir  sulfur_data_test/entropies_matrix -size 500 > $file.score; \
  echo $file.score; tail $file.score; \
done







