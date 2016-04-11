# Metagenome Pfam score

This computational pipeline was developed by B Contreras-Moreira, C Poot and V De Anda .  

We propose this computational approach (written  in perl and python) to compare, at molecular level, the importance of sulfur cycle (SC) by using a multigenomic scale, gathering all the taxa, genes and enzymatic numbers as well as the protein families involved in the SC to estimate the relative entropies, in order to generate a dimensionless Sulfur Score (SS), which allows evaluating the importance of the SC as well as its ecological weight in a global scale. The advantage of this algorithm is that can be used with subsets of gene families from particular metabolic pathways to search specific ecological capabilities, belonging either to different habitats or biogeochemical cycles


###The algoritm is dividen in four main stages:

##STAGE 1. Compilation of datasets and databases:

a) Genes of metabolism of interest in this case our database is called SuCy  (Sulfur Cycle) that includes the bulk of genes involved in metabolic mobilization of sulfur compounds. 

b) List of non redundant  genomes involved in the mobilization of the metabolism of interest. In our casem werely on the the information on the  metabolic guilds found in microbial mats, and described in primary literature and manually curated databases (MetaCyc and KEGG)  (Caspi et al., 2012; Kanehisa and Goto, 2000), we generate a comprehensive list of all the genomes described as sulfur associate (SuLy), which currently contains n=156 completely sequenced prokariotes. In order define a microorganism as sulfur associated, we chose only those with experimental evidence of its physiology of the degradation, reduction, oxidation or disproportion or organic/inorganic sulfur compounds.

c) Random List (RList) is the list of randomly sampled genomes. In order to build negative control sets of organisms, not particularly enriched on metabolic preferences, 1000 random lists of species and strains from the Genomic dataset were drawn with the same number of microorganisms in SuLy (n=156).

d) Genomic dataset.  Due to the genomic redundancy in complete genomes deposited at the NCBI repository (2759 genomes at the moment of the analysis in July 2014), we decided to reduce the set of genomic data using a web-based tool that uses "genomic similarity scores" (Moreno-Hagelsieb, Wang, Walsh, & ElSherbiny, 2013), selecting threshold values of genomic similarity of 0.95 and 0.01 of DNA signature. With those, we obtain a list of identifiers belonging to 1528 non-redundant genomes, which were downloaded from ftp://ftp.ncbi.nlm.nih.gov 


e) Genomic dataset fragmented. Taking into account the fragmented nature of the metagenomes  the detection of a protein family in a genomic dataset does not necessarily suggest that the same family could be detected in a metagenomic dataset due to its fragmentary nature. In order to account for this, the amino acid FASTA-format files of non-redundant genomes were fragmented in different sizes (30, 60,100,150,200,250,300).

f) Metagenomic dataset  A set of 935 metagenomes available from MG-RAST (3.6) was downloaded from http://api.metagenomics.anl.gov/api.html. The distribution of fragment lengths within each metagenome was calculated with custom Perl scripts, observing that their sizes ranged from 30 to 300 amino acids. 



##STAGE 2. Searching for the protein domains (hmmsearch) 

##STAGE 3. Knowing the relative entropy

##STAGE 4. Sulfur Score (SS) origin and interpretation


