 #!/bin/bash

#1) Get the Mean Size Legth of your metagenome 


perl -lne 'if(/^(>.*)/){$h=$1}else{$fa{$h}.=$_} \
END{ foreach $h (keys(%fa)){$m+=length($fa{$h})}; 
printf("%1.0f\t",$m/scalar(keys(%fa))) }' test/4511045.3; echo 4511045.3


#2) Get the Pfam domain composition 

hmmsearch  --cut_ga -o /dev/null --tblout \
test/4511045.3  4511045.3.out.hmmsearch.tab data/my_Pfam.sulfur.hmm  


#3) Get the Sulfur Score specifying the MSL of your input metagenome 


perl scripts/pfam_score.pl -input test/4511045.3.out.hmmsearch.tab \
-size 30  -matrixdir  data/entropies_matrix  4511045.3.out.hmmsearch.tab.score 



#1) Get the Pfam domain composition of your input genome 


#for i in test/*.faa; do  hmmsearch  --cut_ga -o /dev/null --tblout 
#$i.out.hmmsearch.tab data/my_Pfam.sulfur.hmm  $i; done  

#echo "Domain composition done" 

#2) Get the Sulfur Score using of the input genomes  


#for file in test/*.tab; do perl scripts/pfam_score.pl -input $file  
#-size 0 -matrixdir  data/entropies_matrix -size 500 > $file.score 







