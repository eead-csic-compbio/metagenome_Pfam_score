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

1. FASTA file with peptides sequences of proteins involved in the cycle/pathway of interest.
2. List of RefSeq accesions of (curated) genomes known to be involved in the cycle/pathway of interest.

These inputs are processed in order to train a classifier which internally uses [Pfam](http://pfam.xfam.org) domains.

Optionally, genomes or metagenomes provided by the user can be scored with the trained classifier.

The algoritm is divided in four stages, which are explained in detail in the [manual](./manual/manualv1.pdf).
Once a classifier has been trained, such as the Sulfur cycle, stages 1 and 3 can be skipped. 

![flowchart](./manual/flowchart.png)

<!--
Falta figura con leyenda y talvez ligas a las 4 etapas en el manual

STAGE 1. Compilation of datasets and databases 

STAGE 2. Annotating protein domains

STAGE 3. Estimating relative entropy of protein domains

STAGE 4. Sulfur Score (SS) and interpretation
 -->
