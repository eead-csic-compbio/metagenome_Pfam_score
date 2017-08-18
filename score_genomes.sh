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

#define which file mapping Pfam domains to KEGG KO nombers should ne used, leave empty otherwise
#keggmap=
keggmap=$datadir/input_sulfur_data/sulfur_score_kegg_list

echo "# parameters:"
echo "# pathway=$pathway"
echo "# datadir=$datadir"
echo "# keggmap=$keggmap"
echo
echo -e "#metagenome\tMSL\tGenF\tMEBS_Score\t<completeness>\tper_pathway"

  # 1) Get the Pfam domain composition of proteins
  for i in $inputdir/*.faa; do \
   if [ ! -f $i.out.hmmsearch.tab ]; then \
    type hmmsearch >/dev/null 2>&1 || { echo >&2 "# hmmsearch not found, please install"; exit 1; }
    hmmsearch  --cut_ga -o /dev/null --tblout \
      $i.out.hmmsearch.tab $datadir/my_Pfam.sulfur.hmm $i; \
  fi
  done


  # 2) Get their Sulfur Score   
  if [ -z "$keggmap" ]
  then
#loop despues!  
 for file in $inputdir/*.tab; do \
  perl scripts/pfam_score.pl -input $file \
  -entropyfile $datadir/entropies_matrix_entropies.tab -size real  > $file.score;


 if [ -z "$keggmap" ]
  then

   MEBS_Score=`perl -lne 'if(/Pfam entropy score: (\S+)/){ print $1 }' $file.score`;
  echo -e "$i\t$MSL\t$GENF\t$MEBS_Score\tNA\tNA"
  else

   perl scripts/pfam_score.pl -input $file \
  -entropyfile $datadir/entropies_matrix_entropies.tab -size real -keggmap  > $file.score

  MEBS_Score=`perl -lne 'if(/Pfam entropy score: (\S+)/){ print $1 }' $file.score`;
  MEANCOMP=`perl -lne 'if(/# mean pathway completeness: (\S+)/){ print $1 }' $file.score`;
  COMPVALUES=`perl -F'\t' -ane 'print "$F[4]\t" if($#F>=5 && !/^#/)' $file.score`;
  echo -e "$i\t$MSL\t$GENF\t$MEBS_Score\t$MEANCOMP\t$COMPVALUES"
 
done

echo 
echo "-----------------------------------------------------------------"
echo
echo "NOTE: According to our $pathway benchmarks, a score > $cutoff indicates"
echo "that your genome is most likely involved in the $pathway . " 
echo "The maximum expcted $pathway score is $maxscore ." 
