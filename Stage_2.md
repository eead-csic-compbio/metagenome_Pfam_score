#STAGE 2. Searching for the protein domains (hmmsearch) 

**Requirements**  
interproscan (https://www.ebi.ac.uk/interpro/interproscan.html)  
hmmsearch (http://hmmer.org/)

**Datasets**  

 	a) sucy_database_uniprot.fasta    
 	b) Non redundant interest genomes GENOMAS_NCBI_nr_24042014.faa  (#no subí este archivo por que pesa demasiado#)     
 	c) hidden markov models *.hmm     
 	
1) Run interproscan against PFAM database (modificar el comando por que solo se va a usar la base de datos pfam)   
`
compbio_db/interproscan-5.4-47.0/bin/superfamily/1.75/ass3.pl GENOMAS_NCBI_nr_24042014.faa GENOMAS_NCBI_nr_24042014.sf.tab GENOMAS_NCBI_nr_24042014.sf -s /compbio_db/interproscan-5.4-47.0/data/superfamily/1.75/self_hits.tab 
-r /compbio_db/interproscan-5.4-47.0/data/superfamily/1.75/dir.cla.scop.txt_1.75
-m /compbio_db/interproscan-5.4-47.0/data/superfamily/1.75/model.tab 
-p /compbio_db/interproscan-5.4-47.0/data/superfamily/1.75/pdbj95d -f 12`

2) output:      

Q54506    6cbba7cb557879dfe57c62e4e0c8bfe1    437    TIGRFAM    TIGR00339    sopT: sulfate adenylyltransferase    4    386    3.4E-141    T    10-07-2014    IPR002650    Sulphate adenylyltransferase    KEGG: 00230+2.7.7.4|KEGG: 00450+2.7.7.4|KEGG: 00920+2.7.7.4|MetaCyc: PWY-5278|MetaCyc: PWY-5340|MetaCyc: PWY-6683|MetaCyc: PWY-6932|Reactome: REACT_13433|UniPathway: UPA00140

3) From the output file we are interested in the PFAMs ids, copy third and fourht column in a new file *.txt   
4) Using the script extra_hmms.pl, we generate the database that contains the hidden markov models of each family.   
   
`perl extrae_hmms.pl`  

5) otuput : my_Pfam.hmm  my_SUPERFAMILY.hmm  my_TIGRFAM.hmm  

###Este se tendrá que modificar por que al final solo se trabajo con los modelos de PFAM###


#Searching PFAMs  


Run hmmsearch  with --cut_ga option 

`hmmsearch --cut_ga --tblout file.tab /pfam_metagenomes/datasets/myPfam.hmm  GENOMAS_NCBI_nr_24042014.faa` 


#Relative entropy  

**Requirements**
1) hmmsearch output tabular format  file.tab  
2) curated list of genomes of metabolism of interest  (b)nr_sucy) 



`perl  matrix.pl   *.tab nr_sucy > matrix.csv `


