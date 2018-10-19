![MEBS](./images/MEBS.png) 

Authors: Valerie de Anda (1), Cesar Poot-Hernandez (2), Bruno Contreras-Moreira (3)

1. [Instituto de Ecologia](http://web.ecologia.unam.mx), UNAM, Mexico
2. [Instituto de Investigaciones Matematicas Aplicadas y en Sistemas](http://www.iimas.unam.mx), UNAM, Mexico
3. [Fundacion ARAID](http://www.araid.es) & [EEAD-CSIC](http://www.eead.csic.es), Zaragoza, Spain

# Manual and Readme 

**MEBS's** documentation is  available  in the folowing [README](https://eead-csic-compbio.github.io/metagenome_Pfam_score/READMEv1.html)   


# Basic usage

MEBS uses a few  command line options that can  be viewed by typing mebs.pl -h on the command line

```
perl mebs.pl -h 

  Program to compute MEBS for a set of genomic/metagenomic FASTA files in input folder.
  Version: v1.0

  usage: mebs.pl [options] 

   -help    Brief help message
   
   -input   Folder containing FASTA peptide files (.faa)                  (required)

   -type    Nature of input sequences, either 'genomic' or 'metagenomic'  (required)

   -fdr     Score cycles with False Discovery Rate 0.1 0.01 0.001 0.0001  (optional, default=0.01)

   -cycles  Show currently supported biogeochemical cycles
   
   -comp    Compute the metabolic completeness      
   
```


# UPDATES 
---

**10/18/18: Nitrogen and Iron pathways are included.**

[Nitrogen Pathways](https://eead-csic-compbio.github.io/metagenome_Pfam_score/nitrogen.html). 
See file mappping file [here](https://github.com/eead-csic-compbio/metagenome_Pfam_score/blob/master/cycles/nitrogen/pfam2kegg.tab) 

**10/05/18: The sulfur cycle has been updated to include the metabolic completeness of the following pathways:**
[Sulfur Pathways](https://eead-csic-compbio.github.io/metagenome_Pfam_score/sulfur.html)   
Since the sulfur pathways described in [MEBS's manuscript](https://academic.oup.com/gigascience/article/6/11/gix096/4561660) were assembled from many pathways found in a variety of organisms, whose purpose is to provide an overview of the metabolic capabilities of entire ecosystems/metagenomic samples, we suggest the  above mentioned division that represents pathways from single organisms to  evaluate genomes/bins. 
Please note that the old file can be still used  for the analysis of metagenomic samples but it has been moved to the [mapping directory](https://github.com/eead-csic-compbio/metagenome_Pfam_score/blob/master/mapping/pfam2kegg.tab) 
See file mappping file [here](https://github.com/eead-csic-compbio/metagenome_Pfam_score/blob/master/cycles/sulfur/pfam2kegg.tab) 

---

**09/28/18:  The methane cycle has been updated to include the metabolic completeness of only 6 major pathways:**

1. coB/coM regeneration
2. methane oxidation 
3. methanogenesis
4. methanogenesis(methanol) 
5. methylamine degradation
6. mcrABC 
---
