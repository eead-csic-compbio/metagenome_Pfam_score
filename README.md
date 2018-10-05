![MEBS](./images/MEBS.png) 

Authors: Valerie de Anda (1), Cesar Poot-Hernandez (2), Bruno Contreras-Moreira (3)

1. [Instituto de Ecologia](http://web.ecologia.unam.mx), UNAM, Mexico
2. [Instituto de Investigaciones Matematicas Aplicadas y en Sistemas](http://www.iimas.unam.mx), UNAM, Mexico
3. [Fundacion ARAID](http://www.araid.es) & [EEAD-CSIC](http://www.eead.csic.es), Zaragoza, Spain

# Manual and Readme 

**MEBS'S documentation is  available  in the folowing [READMEL](https://eead-csic-compbio.github.io/metagenome_Pfam_score/READMEv1.html)   


# Basic usage

MEBS uses a few  command line optionse that can  be viewed by typing mebs.pl -h on the command line

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

**10/05/18: The sulfur cycle has been updated to include the metabolic completeness of the following pathways:**
Since the sulfur pathways described in MEBS's manuscript were assembled from many pathways found in a variety of organisms, whose purpose is to provide an overview of the metabolic capabilities of entire ecosystems/metagenomic samples, we suggest the following pathways that represent pathways from single organisms to  evaluate genomes/bins. The old file can be still used  for the analysis of metagenomic samples but it has been moved to the [mapping directory](https://github.com/eead-csic-compbio/metagenome_Pfam_score/mapping/pfam2kegg.tab) 

1. aprAB: Present in sulfur oxidation and reduction pathways
2. apt/sat: Present in sulfur oxidation and reduction pathways
3. dsrABC	S O/R: Present in sulfur oxidation and reduction pathways
4. Sox system: [Sulfur oxidation](https://metacyc.org/META/NEW-IMAGE?type=PATHWAY&object=PWY-5296)
fur oxidation 
5. Sor system	[Sulfur oxidation](https://metacyc.org/META/NEW-IMAGE?type=PATHWAY&object=PWY-5302)
6. fccB	[Sulfur oxidation](https://metacyc.org/META/NEW-IMAGE?type=PATHWAY&object=PWY-5274)
7. doxAD	[Sulfur oxidation](https://metacyc.org/META/NEW-IMAGE?type=PATHWAY&object=PWY-5303)
8. DsrEFH	[Sulfur oxidation](https://metacyc.org/META/NEW-IMAGE?type=ENZYME&object=CPLX-8192)
9. dsrKMJOP: Present in sulfur oxidation and reduction pathways
10. QmoABC	[S reduction](https://www.frontiersin.org/articles/10.3389/fmicb.2011.00069/full)
11. Puf reaction center	Sulfur oxidation 
12. cysACDJNPQU	Sulfur assimilation
13. asrABC: [Tetrathionate reduction](https://metacyc.org/META/NEW-IMAGE?type=ENZYME&object=CPLX-7189)
14. ttrABC: [Tetrathionate reduction](https://metacyc.org/META/NEW-IMAGE?type=PATHWAY&object=PWY-5358)
15. phsABC	[Thiosulfate disproportionation (quinone)] (https://metacyc.org/META/NEW-IMAGE?type=PATHWAY&object=PWY-7813)
16. Rhodanase [Thiosulfate disproportionation] (https://metacyc.org/META/NEW-IMAGE?type=PATHWAY&object=PWY-5350)
17. Elemental sulfur reduction (hydACD): [Elemental sulfur reduction](https://metacyc.org/META/NEW-IMAGE?type=ENZYME&object=CPLX-8264) 
18. Elemental sulfur reduction (sreABC)[Elemental sulfur reducion (https://metacyc.org/META/NEW-IMAGE?type=PATHWAY&object=PWY-5332)
19. ddhABC [DMS degradation](https://metacyc.org/META/NEW-IMAGE?type=PATHWAY&object=PWY-6057)
20. dsoABCDEF	[DMS degradation](https://metacyc.org/META/NEW-IMAGE?type=ENZYME&object=CPLX-7669)
21. dmoAB	[DMS degradation](https://metacyc.org/META/NEW-IMAGE?type=PATHWAY&object=PWY-6047)
22.	[Saulfoacetaldehyde degradation](https://metacyc.org/META/NEW-IMAGE?type=PATHWAY&object=PWY-6718)
23.	[Methanesulfonate degradation](https://metacyc.org/META/NEW-IMAGE?type=PATHWAY&object=PWY-6044)
24.	[Sulfolactate degradation](https://metacyc.org/META/NEW-IMAGE?type=PATHWAY&object=PWY-6616)
25.	[Sulfoacetaldehyde degradation](https://metacyc.org/META/NEW-IMAGE?type=PATHWAY&object=PWY-1281)
26. [Taurine degradation](https://metacyc.org/META/NEW-IMAGE?type=PATHWAY&object=PWY-1541)

See file mappping file [here](https://github.com/eead-csic-compbio/metagenome_Pfam_score/blob/master/cycles/sulfur/pfam2kegg.tab) 



**09/28/18:  The methane cycle has been updated to include the metabolic completeness of only 6 major pathways:**

1. coB/coM regeneration
2. methane oxidation 
3. methanogenesis
4. methanogenesis(methanol) 
5. methylamine degradation
6. mcrABC 
---
