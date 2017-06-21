# Multigenomic Entropy-Based Score (MEBS)

Valerie de Anda (1), Cesar Poot-Hernandez (2), Bruno Contreras-Moreira (3)

1. [Instituto de Ecologia](http://web.ecologia.unam.mx), UNAM, Mexico
2. [Instituto de Investigaciones Matematicas Aplicadas y en Sistemas](http://www.iimas.unam.mx), UNAM, Mexico
3. [Fundacion ARAID](http://www.araid.es) & [EEAD-CSIC](http://www.eead.csic.es), Zaragoza, Spain

--

This computational pipeline was designed to evaluate the importance of global biogeochemical cycles in multigenomic scale. 
It has been thoroughly tested with the Sulfur cycle (see [benchmark](./scripts/MEBS.figures.ipynb)) 
but also with some other cycles. These data are currently being described in papers in preparation. 
We hope it can be of help to other researchers. The scripts are written in perl5 and python3.

The required input data are:

i.   FASTA file with peptides sequences of proteins involved in the cycle/pathway of interest.
ii.  List of RefSeq accesions of (curated) genomes known to be involved in the cycle/pathway of interest.

These inputs are processed in order to train a classifier which internally uses Pfam domains.

Optionally, genomes or metagenomes provided by the user can be scored with the trained classifier.


The algoritm is divided in four stages. 
Steps 1 and 3 can be skipped if a classifier was previously trained, such as the Sulfur cycle:

## STAGE 1. Compilation of datasets and databases 
<!-- Source: [Stage 1](Stage1.Rmd) -->

##STAGE 2. Annotating protein domains
<!-- Source: [Stage 2](Stage2.Rmd) -->

##STAGE 3. Estimating relative entropy of protein domains
<!-- Source: [Stage 3](Stage3.Rmd) -->

##STAGE 4. Sulfur Score (SS) and interpretation
<!-- Source: [Stage 4 ](Stage4.Rmd) -->
