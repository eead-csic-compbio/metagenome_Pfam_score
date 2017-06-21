 #!/bin/bash

#1) Get the Pfam domain composition of your input genome 


for i in test/*.faa; do  hmmsearch  --cut_ga -o /dev/null --tblout 
$i.out.hmmsearch.tab data/my_Pfam.sulfur.hmm  $i; done  

echo "Domain composition done" 

#2) Get the Sulfur Score using of the input genomes  


for file in test/*.tab; do perl scripts/pfam_score.pl -input $file  
-size 0 -matrixdir  data/entropies_matrix -size 500 > $file.score 







