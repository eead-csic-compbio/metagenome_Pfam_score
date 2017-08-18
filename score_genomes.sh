#!/bin/bash

if [ $# -eq 0 ] 
  then 
    echo "# Need the name of folder containing .faa genome files";
    exit;
fi

inputdir=$1
pathway="Sulfur cycle"
datadir=sulfur_data_test
# please edit for other pathways
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
echo -e "#metagenome\tMEBS_Score\t<completeness>\tper_pathway"

for i in $inputdir/*.faa; do \

  # 1) Get the Pfam domain composition of proteins
  if [ ! -f $i.out.hmmsearch.tab ]; then \
    type hmmsearch >/dev/null 2>&1 || { echo >&2 "# hmmsearch not found, please install"; exit 1; }
    hmmsearch  --cut_ga -o /dev/null --tblout \
      $i.out.hmmsearch.tab $datadir/my_Pfam.sulfur.hmm $i; \
  fi

  # 2) Get their Sulfur Score   
  if [ -z "$keggmap" ]
  then
    perl scripts/pfam_score.pl -input $i.out.hmmsearch.tab \
      -entropyfile $datadir/entropies_matrix_entropies.tab -size real  > $i.out.hmmsearch.tab.score;
    MEBS_Score=`perl -lne 'if(/Pfam entropy score: (\S+)/){ print $1 }' $i.out.hmmsearch.tab.score`;
    echo -e "$i\t$MEBS_Score\tNA\tNA"
  else
    perl scripts/pfam_score.pl -input $i.out.hmmsearch.tab \
      -entropyfile $datadir/entropies_matrix_entropies.tab -size real -keggmap $keggmap > $i.out.hmmsearch.tab.score
    MEBS_Score=`perl -lne 'if(/Pfam entropy score: (\S+)/){ print $1 }' $i.out.hmmsearch.tab.score`;
    MEANCOMP=`perl -lne 'if(/# mean pathway completeness: (\S+)/){ print $1 }' $i.out.hmmsearch.tab.score`;
    COMPVALUES=`perl -F'\t' -ane 'print "$F[4]\t" if($#F>=5 && !/^#/)' $i.out.hmmsearch.tab.score`;
    echo -e "$i\t$MEBS_Score\t$MEANCOMP\t$COMPVALUES"
  fi
 
done

echo 
echo "-----------------------------------------------------------------"
echo
echo "NOTE: According to our $pathway benchmarks, a score > $cutoff indicates"
echo "that your genome is most likely involved in the $pathway. " 
echo "The Maximum Theoretical Score (MTS) score is $maxscore ."
 
