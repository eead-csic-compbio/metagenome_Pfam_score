#STAGE 4. Sulfur Score (SS) origin and interpretation
We propose to evaluate the SC in a quantitative and comparative way using one single value that we call Sulfur Score (SS).
By this approach, information-rich (H’) protein families (114) will contribute to higher Sulfur Scores,
whereas non-informative families will decrease SS. 
 
Therefore, if we compare total Sulfur Scores across different metagenomic datasets,
sampled from different environments, those wherein the mobilization of sulfur compounds is most significant,
will have a high SS; in contrast, environments where the SC is marginal will have low SS scores. Using this approach 
we calculated SS in genomic and metagenomic datasets of different mean fragment length.  


 How to run sulfur score
1) Create a directory with the output tab format of hmmsearch output.tab 
      # metagenomic dataset output's

        /Home2/sulfur_score/hmmers/*.tab 


        # Genomic  dataset output's

        /Home2/sulfur_score/genomas_cover10/pfam_cover10/GENOMAS_NCBI_nr_24042014.fa.pf.tab


2)There are two scripts to run sulfur score, one for each data set 

in /Home2/sulfur_score 
perl sscore_genomes.pl # for genomic datset
perl sccore_metagenomes.pl # for metagenomic dataset 

      usage: sscore_genomes.pl [options]      

      -help             brief help message
 
      -input            input file with HMM matches created by hmmsearch, tbl format

      -size             desired size of genomic datset    (integer, default 500)
 
      -bzip             input file is bzip2-compressed
 
      -matrixdir        directory containing hmm matrices from fragments of variable size (string, 
                    default /Home2/sulfur_score/matrices_curadas_sep)
 
      -minentropy       min relative entropy of HMMs to be considered (float)
                                                 
      -keggmap          file with HMM to KEGG mappings
 
      -pathway          comma-separated pathway numbers from -keggmap file to consider only member HMMs  (string, by default all pathways are used, requires -keggmap)

     

`for file in hmmers/*.tab; do perl sscore_metagenomes.pl -input $file -size 30 -matrixdir /Home2/sulfur_score/matrices_curadas_sep -keggmap sulfur_score_kegg_list  > $file.30..score; done` 

