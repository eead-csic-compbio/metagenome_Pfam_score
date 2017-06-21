#!/bin/bash

# 1) Get the Pfam domain composition of proteins
# encoded in test genomes 

for i in test/*.faa; do \
  


  hmmsearch  --cut_ga -o /dev/null --tblout \
  $i.out.hmmsearch.tab data/my_Pfam.sulfur.hmm $i; \
done  

echo "Domain composition done" 

# 2) Get the Sulfur Score using of the input genomes  


for file in test/*.tab; do \
  perl scripts/pfam_score.pl -input $file \
  -matrixdir  data/entropies_matrix -size 500 > $file.score; \
  echo $file.score; tail $file.score; \
done







