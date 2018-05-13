![MEBS](./images/MEBS.png) 


Authors: Valerie de Anda (1), Cesar Poot-Hernandez (2), Bruno Contreras-Moreira (3)

1. [Instituto de Ecologia](http://web.ecologia.unam.mx), UNAM, Mexico
2. [Instituto de Investigaciones Matematicas Aplicadas y en Sistemas](http://www.iimas.unam.mx), UNAM, Mexico
3. [Fundacion ARAID](http://www.araid.es) & [EEAD-CSIC](http://www.eead.csic.es), Zaragoza, Spain


# About MEBS

The main goal of MEBS is capture with a single value  the importance of complex metabolic pathways or biogeochemical cycles in a large omic datasets (either genomes or metagenomes). The algortithm has been thoroughly tested with the [sulfur cycle](https://academic.oup.com/gigascience/article/6/11/1/4561660), but currently other cycles are also supported. The script [mebsv1.pl](./mebsv1.pl) allows you to score your  own genome/metagenome in terms of biogeochemical cycles. 
All that is required is a directory containing peptide FASTA files of encoded proteins/fragments with **.faa** extension.
Note that [hmmsearch](http://hmmer.org/download.html) must be installed first.

# MEBS installation 

The MEBS software is available as an open-source package distributed from a GitHub repository. Thus,
the natural way of installing it is by cloning the repository via the following commands:

```
git clone https://github.com/eead-csic-compbio/metagenome_Pfam_score

#Alternatively, a ZIP file can be downloaded and then unpacked:

unzip metagenome_Pfam_score-master.zip
```


# Manual and Readme 

Instructions and full documentation of MEBS are available on [html](https://eead-csic-compbio.github.io/metagenome_Pfam_score/READMEv1.html) and [pdf](https://eead-csic-compbio.github.io/metagenome_Pfam_score/manual.v1.pdf)


# Quick start  
Have a look at the options of the main script mebsv1.pl


```
perl mebsv1.pl

  usage: mebsv1.pl [options] 

   -help    Brief help message
   
   -input   Folder containing FASTA peptide files (.faa)                  (required)

   -type    Nature of input sequences, either 'genomic' or 'metagenomic'  (required)

   -fdr     Score cycles with False Discovery Rate 0.1 0.01 0.001 0.0001  (optional, default=0.01)

   -cycles  Show currently supported biogeochemical cycles
```

## MEBS supported cycles

 The following biogeochemical cycles  are ready to use with MEBS:
 
1. [sulfur](./cycles/sulfur): Includes the  mobilization of inorganic and inorganic sulfur compounds
2. [carbon](./cycles/carbon):Usage of CH4 compounds  by methanotrophs, methanogens, and methylotrophs
3. [oxygen](./cles/oxygen): Represented by oxygenic photosynthesis
4. [iron](./cycles/iron): The Fe reduction and oxidation including also  siderophores uptake
5. [nitrogen](./cycles/nitrogen): We included the pathways involved in the reduction and oxidation of both inorganic (nitrate(+5) to ammonia(-3) ) and organic nitrogen compounds (i.e taurine, urea, and choline degradation)


```
perl mebsv1.pl  -cycles 
# Available cycles:
sulfur
carbon
oxygen
iron
nitrogen

# Available files to compute completeness:
cycles/sulfur/pfam2kegg.tab
cycles/carbon/pfam2kegg.tab
```

# Running MEBS   

To run MEBS you only need to specifyt the input folder and the  type of data  (either genomic or metagenomic). The latter is  required for MEBS to allocate the  pre-computed entropies  for each type of data considering the fragmentary nature of the metagenomic sequences. 


```
perl mebsv1.pl  -input test_genomes/ -type genomic 
	   sulfur	carbon	oxygen	iron	nitrogen
Enterococcus_durans.faa	-0.063	0.284	0.883	0.214	3.044
Archaeoglobus_profundus_DSM_5631.faa	11.434*	24.834*	1.493	0.765	6.873
```

The scores that meets the criteria of specific  FDR  are shown in asterisc, yet the score will be the same regardless of the FDR that is used. If the Score if greater or equal to the FDR, then an asterisc  will be shown in the output. In the case of using the  default FDR (0.01), more false positive will be obtained, for example the genome *Archaeoglobus profundus* a well known microorgnism involved in the S-cycle, could seem to have a CH4 metabolism by using a default FDR,however if we increase to FDR 0.001, the C cycle asterisc is gone and only the  S-cycle ramain. Therefore,  we recomend a more restrictive FDR in order to eliminate false positives.


```
perl mebsv1.pl  -input test_genomes/ -type genomic -fdr 0.001

           sulfur       carbon  oxygen  iron    nitrogen
Enterococcus_durans.faa -0.063  0.284   0.883   0.214   3.044
Archaeoglobus_profundus_DSM_5631.faa    11.434	24.834* 1.493   0.765   6.873
```  

If you attempt to benchmark your own metabolism, we recomend to add your own FDR values in this [config file](./config.txt) at the end of this file. 
In a 16.04 Ubuntu system, 16Gb RAM, intel Inside i7 the time to run the scritpt  in the example folder is less than 20 seconds. 

```
real	0m14.183s
user	0m22.961s
sys	0m0.865s
```

# Maximum scores 

To compare your data with the maximum  scores that you can obtain from the entropy data, have a look at the following data
If you are computing MEBS in genomes compare your results with the row "Genomic data". In the case that you are computing MEBS in metagenomes see the corresponding MSL and MSLbin to you compare your results. 


|      | sulfur | methane | oxygen | iron   | nitrogen |
|------|--------|---------|--------|--------|----------|
| Genomic data | 16.018 | 85.332  | 10.703 | 10.464 | 22.079   |
| 30   | 13.676 | 84.503  | 10.438 | 8.843  | 20.642   |
| 60   | 16.818 | 85.347  | 11.253 | 9.567  | 22.148   |
| 100  | 15.566 | 85.221  | 9.965  | 10.676 | 21.43    |
| 150  | 15.848 | 84.81   | 10.152 | 10.316 | 21.379   |
| 200  | 15.887 | 84.765  | 10.463 | 9.832  | 21.938   |
| 250  | 16.031 | 85.057  | 10.387 | 10.215 | 21.853   |
| 300  | 15.929 | 84.942  | 10.569 | 10.284 | 21.968   |



# Support and Development

Planned feature improvements are publicly catalogued at the main MEBS development site on github. Bug reports and problems using MEBS  are welcome on the [issues tracker](https://github.com/eead-csic-compbio/metagenome_Pfam_score/issues). We prefer posting to the issue tracker over email as these posts are searchable by other users who may experience the same problems.


# Links related to MEBS 

<sub style="font-size: 12px !important;">
[Semifinalist of the GigaScience Prize Track ICG-12](http://www.eead.csic.es/compbio/pics/GigaSciencePrizeTrack.html)".
</sub>
<p align="center">
  <img width="300" height="300" src="https://eead-csic-compbio.github.io/metagenome_Pfam_score/images/china.png">
</p>


<sub style="font-size: 12px !important;">
[Winner of the Bioinformatics Peer Prize II: student category ](https://the-bioinformatics-peer-prize-ii.thinkable.org/)".
</sub>
<p align="center">
  <img width="300" height="300" src="https://eead-csic-compbio.github.io/metagenome_Pfam_score//images/thinkable.png">
</p>


# Cite us
If you find this software usefull please cite us as: 

+ De Anda V, Zapata-Penasco I, Poot Hernandez AC, Fruns LE, Contreras Moreira B, Souza V (2017) MEBS, a software platform to evaluate large (meta)genomic collections according to their metabolic machinery: unraveling the sulfur cycle. [doi:10.1093/gigascience/gigascience/gix096/4561660](https://academic.oup.com/gigascience/advance-article/doi/10.1093/gigascience/gix096/4561660)
<!--[doi:10.1101/191288 ](https://www.biorxiv.org/content/early/2017/09/20/191288)-->






