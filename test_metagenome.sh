#!/bin/bash

#1) Get the Mean Size Length of peptides encoded in metagenome 
echo test/4511045.3_metagenome.faa
perl -lne 'if(/^(>.*)/){$h=$1}else{$fa{$h}.=$_} END{ foreach $h (keys(%fa)){$m+=length($fa{$h})}; printf("MSL = %1.1f\n",$m/scalar(keys(%fa))) }' test/4511045.3_metagenome.faa > test/4511045.3_metagenome.faa.msl
cat test/4511045.3_metagenome.faa.msl

# 2) Find out appropriate fragment size of classifier (genF)
perl -lne 'BEGIN{@bins=(30,60,100,150,200,250,300);@th=(45,80,125,175,225,275,300)} if(/^MSL = (\S+)/){ $msl=$1; foreach $i (0 .. $#th){ if($msl<=$th[$i]){ print "genF = $bins[$i]"; exit } } }' test/4511045.3_metagenome.faa.msl > test/4511045.3_metagenome.faa.genF
cat test/4511045.3_metagenome.faa.genF


#3) Get the Pfam domain composition of metagenomic peptides
i=test/4511045.3_metagenome.faa
if [ ! -f $i.out.hmmsearch.tab ]; then \
  type hmmsearch >/dev/null 2>&1 || { echo >&2 "# hmmsearch not found, please install"; exit 1; }

  hmmsearch  --cut_ga -o /dev/null --tblout \
    $i.out.hmmsearch.tab data/my_Pfam.sulfur.hmm $i; \
fi

#4) Get the Sulfur Score specifying the MSL of your input metagenome 
genF=`perl -lne 'if(/genF = (\S+)/){ print $1 }' test/4511045.3_metagenome.faa.genF`
perl scripts/pfam_score.pl -input $i.out.hmmsearch.tab \
  -size $genF -matrixdir data/entropies_matrix > $i.out.hmmsearch.tab.score

echo $i.out.hmmsearch.tab.score
echo "..."
tail $i.out.hmmsearch.tab.score










