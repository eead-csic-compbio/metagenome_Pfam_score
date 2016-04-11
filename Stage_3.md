#STAGE 3. Knowing the relative entropy



In order to get an estimate of how protein families are represented in sulfur-related genomes,
we used a derivative of the Kullback-Leibler divergence also known as relative entropy, 
to measure of the difference between two probability distributions P and Q.  
In this context  P(i) represents the total number of occurrences of protein family i in sulfur-related genomes 
(observed frequency) and  Q(i) is the total number of occurrences of that family in the Genomic dataset (1528 genomes),
which is the expected frequency.  
The relative entropy H then captures to what extent a family informs specifically about sulfur metabolism. 
H values close to 1 correspond to most informative families (enriched among sulfur-related genomes), whereas low values of H,
close to cero, describe non-informative families. 

The relative entropy is bias by the number of whole-genome sequenced sulfur microorganism (SuLy),
therefore we re-calculate H’ substituting SuLy with equally sized lists of random genomes (Rlist).
If there really is no such bias, then we expected to obtain low information PFAM domains in the random test. 
With these procedures we evaluated the variation of relative entropy of
each PFAM in order to short-list those that could be used as markers in metagenomic datasets regardless
on the average length, and to generate a measure to be used as a way to compare the importance of sulfur metabolisms
in metagenomes derived from any environment.  


The scripts matrix.pl calculate the relative entropy of each PFAM, to obtain the entropies and  plot them, we need two scripts:
1) extrac_entropies.py :uses as input a folder containing the matrix of Relative entropy calculated from the fragmented genomic dataset, and the real dataset. 
2) barras.py with the output of th latter script (matrices_pfam_entropies.tab), creates a heatmap and barplot of the relative entropie of the protein families  

`python extract_entropies.py /folder/containing/matrix/with/relative/entropies/`
`python barras.py matrices_pfam_entropies.tab`

