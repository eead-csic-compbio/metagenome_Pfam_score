#!/usr/bin/perl -w
use strict;

#Input file .tab from hmmsearch an list of sulphur sps
if(!$ARGV[0]){  die "# $0 : usage: $0 ||<pfam.tab> <optional, list of species/Genre to select> <optional, pfam2.tab>\n"; }
my ($dom_assign_file,$list_file,$dom_assign_file2) = @ARGV;
print "# dom_assign_file=$dom_assign_file list_file=$list_file dom_assign_file2=$dom_assign_file2\n\n";
my ($seqid,$domid,$taxonid,$spid,$line,$total_obs,$total_exp,$freq_obs,$freq_exp,$entropy);
my (%taxa,%hmm,%matrix,%list_matrix,@taxon_list,%matched_taxa,%matched_assign_file,%matched_assign_file2);
my ($listOK,$genusOK) = (0,0);
# read list file only if required and passed correctly
if($list_file && -s $list_file)
{
    open(LIST,$list_file) || die "# $0 : cannot read $list_file\n";
    while(<LIST>)
    {
        #List of sulphur sps
        #species\toccurrence
        chomp;
        $taxonid = (split(/\t/,$_))[0];
        next if ($taxonid =~ /^#/);
        $taxonid =~ s/\s+$//g;
        $taxonid =~ s/\.$//g; #next if($taxonid =~ /sp\./ || /^[a-z]/);
        #my @taxon_name = split(/\s+/,$taxonid); next if(scalar(@taxon_name<2)); #$taxonid = join(' ',@taxon_name[0,1]);

        if (grep(/^$taxonid/,@taxon_list)){} # no puede haber en la lista especies de un genero que tb esta
        else
        {
            push(@taxon_list,$taxonid);
            #printf("# %s %d\n",$taxonid,$#taxon_list+1);
        }
    }
    close(LIST);

    printf("# number of taxa in %s = %d\n\n",$list_file,scalar(@taxon_list));
    $listOK = 1;
}

# lee archivo de salida de hmmer3 tblout (DOMFILE)
open(DOMFILE,$dom_assign_file) || die "# $0 : cannot read $dom_assign_file\n";
while($line = <DOMFILE>)
{
    #gi|15669207|ref|NP_248012.1|     -            524 2-Hacid_dh           PF00389.25   133   1.3e-43  156.6   0.6   1   1   1.2e-46   1.3e-43  156.6   0.4     1   133     4   312     4   312 1.00 D*3-phosphoglycerate dehydrogenase [Methanocaldococcus jannaschii DSM 2661]

    next if($line =~ /^#/); #print $line;

    my @data = split(/\s+/,$line);

    ($seqid,$domid) = ($data[0],$data[3]);

    $domid = (split(/\./,$domid))[0];

    if(!$hmm{$domid}){ $hmm{$domid}++ }
    # encuentra en la linea algo como [genero especie lo que sea] y lo asignas a $taxonid   
    $line = reverse($line);
    if($line =~ /\](.+?)\[/)
    {
        $taxonid = reverse($1);

        # adhoc rules to filter out common annotations such as:
        # [5'-phosphate] , [3-hydroxymyristoyl] ,
        # [acyl-carrier-protein] , [NAD(P)H] , [Cu-Zn]
        if(!$taxa{$taxonid}){ $taxa{$taxonid}++ }
    }
    else{ next; }
    # si se paso una lista de nombres de bichos busca coincidencias entre las lineas de esa lista
    # y el nombre de la especie ($taxonid) de la linea actual del archivo DOMFILE
    if($listOK)
    {
    my @matched = grep(/^$taxonid/,@taxon_list); # especies completas, incluso a nivel de cepa
    if(@matched)
    {
        $list_matrix{$taxonid}{$domid}++; #print "mira:$taxonid\n";    
        foreach $spid (@matched){ $matched_assign_file{$spid} = 1 }
    }
    else # ahora generos o nombres incompletos
    {
        $genusOK = 0;
        foreach $spid (@taxon_list)
        {
            if($taxonid =~ /^$spid/)
            {
                $genusOK = 1;
                $matched_assign_file{$spid} = 1; # recuerda lineas de la lista que ya encontraste
                last;
            }
        }
       
        # recuerda la occurencia de este dominio/HMM en esta especie dentro de las especies encontradas en la lista
        if($genusOK){ $list_matrix{$taxonid}{$domid}++; }
    }   
    }   

    # recuerda la occurencia de este dominio/HMM en esta especie entre todas las especies (no redundantes)
    $matrix{$taxonid}{$domid}++; #print "$domid\t$taxonid\t$spid\n";
}
close(DOMFILE);

## imprime en formato TAB/CVS matriz binaria de presencia/ausencia de dominios/HMMs en todas las especies (no redundantes)

# imprime cabecera
foreach $domid (sort keys(%hmm))
{
    print "\t$domid";
} print "\n";

# imprime datos
foreach $taxonid (sort keys(%taxa))
{
    #$spid = join(' ',(split(/\s+/,$taxonid))[0,1]);
    print "$taxonid";
    foreach $domid (sort keys(%hmm))
    {
        if($matrix{$taxonid}{$domid})
    {
        print "\t1";
        $matrix{'total'}{$domid}++;
        if($list_matrix{$taxonid})
        {
            $list_matrix{'total'}{$domid}++;
            $matched_taxa{$taxonid}++;
        }
    }
        else{ print "\t0" }
    } print "\n";
}

# imprime frecuencias relativas esperadas de cada dominio/HMM estimadas sobre todas las especies (no redundantes)
printf("\n\nexpfreq(%d)",scalar(keys(%taxa))-1);
foreach $domid (sort keys(%hmm))
{
    $total_exp = $matrix{'total'}{$domid} || 0; 
    printf("\t%1.3f",$total_exp/(scalar(keys(%taxa))-1));
} print "\n";

## si se paso como segunda argumento una lista calcula frecuencias para las especies encontradas en ella
if($listOK)
{
    # imprime especies encontradas en la lista
    printf("\n\nmatched list taxa in %s (%d) : ",$dom_assign_file,scalar(keys(%matched_taxa)));
        foreach $taxonid (sort keys(%matched_taxa))
        {
        print "\t$taxonid"
        }
        print "\n";

    # imprime frecuencias relativas observadas de cada dominio/HMM entre las especies encontradas en la lista
    printf("\n\nlistfreq(%d)",scalar(keys(%matched_taxa)));
    foreach $domid (sort keys(%hmm))
        {
        $total_obs = $list_matrix{'total'}{$domid} || 0;
        printf("\t%1.3f",$total_obs/scalar(keys(%matched_taxa)));
    }
    print "\n";

    # imprime entropias relativas: valores alejados de cero implican dominios/HMMs que informan de la presencia de especies incluidas en la lista
    # en las pruebas en Jul2014 en ZGZ no se observan apenas casos <0, la mayoria son > 0 y por tanto cuanto mayores mas interesantes
    printf("\n\nrel_entropy(%d)",scalar(keys(%matched_taxa)));
    foreach $domid (sort keys(%hmm))
    {   
        $total_exp = $matrix{'total'}{$domid} || 0;
        $freq_exp = $total_exp/(scalar(keys(%taxa))-1);

        $total_obs = $list_matrix{'total'}{$domid} || 0; # TODO: probar a sumar pseudo conteos
        $freq_obs = $total_obs/scalar(keys(%matched_taxa));

        if($freq_obs && $freq_exp)
        {
            $entropy = sprintf("%1.3f",$freq_obs * (log($freq_obs/$freq_exp)/log(2)));
        }
        else{  $entropy = 'NA' }

        print "\t$entropy";
    }   
    print "\n";

    # en caso de pasar como tercer argumento un segundo archivo de asignaciones de dominios de hmmer3
    # ver si hay especies de la lista todavia no encontradas para recalcular las frecuencias observadas incluyendolas a ellas
    if($dom_assign_file2 && -s $dom_assign_file2)
    {
        # encuentra especies de la lista que no se hayan encontrado todavia       
        my (@unmatched_list,$matchedOK);       
        foreach $spid (@taxon_list)
        {
            $matchedOK = $matched_assign_file{$spid} || 0;
            if(!$matchedOK){ push(@unmatched_list,$spid) }
            #print "# $spid $matchedOK\n";
        }

        if(!@unmatched_list)
        {
            print "# no more taxa in list to search\n";
            exit;
        }

        # lee el otro archivo de salida de hmmer3, opcional (DOMFILE2)
        # (ver comentarios en codigo similar mas arriba)
        open(DOMFILE2,$dom_assign_file2) || die "# $0 : cannot read $dom_assign_file2\n";
        while($line = <DOMFILE2>)
        {       
            next if($line =~ /^#/);
            my @data = split(/\s+/,$line);
            ($seqid,$domid) = ($data[0],$data[3]); # 3 vale para WGS_sulphur_genomes.pf.tab
            $domid = (split(/\./,$domid))[0];

            # asigna $taxonid      
            $line = reverse($line);
            if($line =~ /\](.+?)\[/)
                {
                    $taxonid = reverse($1);
                    $matched_taxa{$taxonid}++;
                }
                else{ next; }

            # busca este nuevo taxon en la lista de las especies todavia sin encontrar
            my @matched = grep(/^$taxonid/,@unmatched_list);
                if(@matched)
                {
                if(!$hmm{$domid})
                {
                    print "# WARNING: domain $domid was only found among genome $taxonid in $dom_assign_file2\n";
                    $hmm{$domid}++;
                }

                        $list_matrix{$taxonid}{$domid}++;
                        foreach $spid (@matched){ $matched_assign_file2{$spid} = 1 }
                }
                else
                {
                        $genusOK = 0;
                        foreach $spid (@unmatched_list)
                        {
                                if($taxonid =~ /^$spid/)
                                    {
                                        $genusOK = 1;
                                        $matched_assign_file2{$spid} = 1;
                                        last;
                                }
                }
           
                        # recuerda la ocurrencia de este dominio/HMM en esta nueva especie
              if($genusOK)
                {
                    if(!$hmm{$domid})
                                    {
                                            print "# WARNING: domain $domid was only found among genome $taxonid in $dom_assign_file2\n";
                        $hmm{$domid}++;
                                    }

                    $list_matrix{$taxonid}{$domid}++;
                }
                }
        }
        close(DOMFILE2);

        # imprime especies de la lista encontradas en algunos de los dos archivos de hmmer (argumentos 1 y 3)
            printf("\n\nmatched list taxa in %s and %s (%d) : ",$dom_assign_file,$dom_assign_file2,scalar(keys(%matched_taxa)));
            foreach $taxonid (sort keys(%matched_taxa))
            {
                    print "\t$taxonid";
            }
            print "\n";

            # imprime frecuencias relativas observadas de cada dominio/HMM entre las especies encontradas en la lista
            printf("\n\nlistfreq(%d)",scalar(keys(%matched_taxa)));
            foreach $domid (sort keys(%hmm))
            {
                    $total_obs = $list_matrix{'total'}{$domid} || 0;
                    printf("\t%1.3f",$total_obs/scalar(keys(%matched_taxa)));
            }
            print "\n";

            # imprime entropias relativas
            printf("\n\nrel_entropy(%d)",scalar(keys(%matched_taxa)));
            foreach $domid (sort keys(%hmm))
            {
                    $total_exp = $matrix{'total'}{$domid} || 0;
                    $freq_exp = $total_exp/(scalar(keys(%taxa))-1);
   
                    $total_obs = $list_matrix{'total'}{$domid} || 0;
                    $freq_obs = $total_obs/scalar(keys(%matched_taxa));
   
                    if($freq_obs && $freq_exp)
                    {
                            $entropy = sprintf("%1.3f",$freq_obs * (log($freq_obs/$freq_exp)/log(2)));
                    }
                    else{  $entropy = 'NA' }
   
                    print "\t$entropy";
            }
            print "\n";
    }
}
