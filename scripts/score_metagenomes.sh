#!/bin/bash

if [ $# -eq 0 ] 
  then 
    echo "# Need the name of folder containing .faa metagenome files";
    exit;
fi

inputdir=$1
pathway="Sulfur cycle"
datadir=sulfur_data_test

#define which file mapping Pfam domains to KEGG KO nombers should ne used, leave empty otherwise
#keggmap=
keggmap=$datadir/input_sulfur_data/sulfur_score_kegg_list

echo "# parameters:"
echo "# pathway=$pathway"
echo "# datadir=$datadir"
echo "# keggmap=$keggmap"
echo
echo -e "#metagenome\tMSL\tGenF\tMEBS_Score\t<completeness>\tper_pathway"

for i in $inputdir/*.faa; do \
  
  #1) Get the Mean Size Length of peptides encoded in metagenome
  MSL=`perl -lne 'if(/^(>.*)/){$nseq++;$m+=$l;$l=0}else{$l+=length($_)} END{ $m+=$l; printf("%1.0f\n",$m/$nseq) }' $i`
 
  # 2) Find out appropriate fragment size of classifier (genF)
  GENF=`perl -e 'BEGIN{@bins=(30,60,100,150,200,250,300);@th=(45,80,125,175,225,275,300)} foreach $i (0 .. $#th){ if($ARGV[0]<=$th[$i]){ print $bins[$i]; exit }}' $MSL`
  
  #3) Get the Pfam domain composition of metagenomic peptides
  if [ ! -f $i.out.hmmsearch.tab ]; then \
    type hmmsearch >/dev/null 2>&1 || { echo >&2 "# hmmsearch not found, please install"; exit 1; }

    hmmsearch  --cut_ga -o /dev/null --tblout \
      $i.out.hmmsearch.tab $datadir/my_Pfam.sulfur.hmm $i; \
  fi
  
  #4) Get the Sulfur Score specifying the MSL of your input metagenome 
  if [ -z "$keggmap" ]
  then
    perl scripts/pfam_score.pl -input $i.out.hmmsearch.tab \
      -size $GENF -entropyfile $datadir/entropies_matrix_entropies.tab > $i.out.hmmsearch.tab.score
    MEBS_Score=`perl -lne 'if(/Pfam entropy score: (\S+)/){ print $1 }' $i.out.hmmsearch.tab.score`;
    echo -e "$i\t$MSL\t$GENF\t$MEBS_Score\tNA\tNA"
  else
    perl scripts/pfam_score.pl -input $i.out.hmmsearch.tab \
      -size $GENF -entropyfile $datadir/entropies_matrix_entropies.tab \
      -keggmap $keggmap > $i.out.hmmsearch.tab.score
    MEBS_Score=`perl -lne 'if(/Pfam entropy score: (\S+)/){ print $1 }' $i.out.hmmsearch.tab.score`;
    MEANCOMP=`perl -lne 'if(/# mean pathway completeness: (\S+)/){ print $1 }' $i.out.hmmsearch.tab.score`;
    COMPVALUES=`perl -F'\t' -ane 'print "$F[4]\t" if($#F>=5 && !/^#/)' $i.out.hmmsearch.tab.score`;
    echo -e "$i\t$MSL\t$GENF\t$MEBS_Score\t$MEANCOMP\t$COMPVALUES"
  fi
done

echo 
echo "-----------------------------------------------------------------"
echo 
echo "NOTE: According to our $pathway benchmarks, depending on the Mean Size Length "
echo "of the input metagenome, the Maximum Theoretical Scores (MTS) and the selected "
echo "cutoff values (95th percentiles) are:"
echo
echo "	GenF	MTS	95th"
echo "	30	13.67	7.66 "
echo "	60	16.81	9.70"
echo "	100	15.56	8.81"
echo "	150	15.84	8.51"
echo "	200	15.88	8.18"
echo "	250	16.03	8.98"
echo "	300	15.92	7.61"









