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

echo "                    Sulfur domain composition done" 
echo "------------------------------------------------------------------"
# 2) Get their Sulfur Score   
echo "                    Computing MEBS final Score" 
echo "------------------------------------------------------------------"
for file in $inputdir/*.tab; do \
  perl scripts/pfam_score.pl -input $file \
  -entropyfile $datadir/entropies_matrix_entropies.tab -size real > $file.score; \
MEBS_Score=`grep "Pfam entropy score" $file.score`
#  echo $file.score; grep "Pfam entropy score" $file.score; \
echo "The MEBS Score of"
echo "your $file"
echo "is = $MEBS_Score"
echo "Done"
echo "------------------------------------------------------------------"
done
echo "                    MEBS final Score done"
echo "------------------------------------------------------------------"
echo "NOTE: According to our benchmark, a Score >8.705 the most likely"
echo "that your genome is closely involved in the Sulfur cycle" 
echo "The highest  SS value you can get is 9.491" 
echo "Thanks for using MEBS" 
