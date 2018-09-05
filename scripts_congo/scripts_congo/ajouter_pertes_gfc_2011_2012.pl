############### Author : 		Rémi d'Annunzio {mailto:remi.dannunzio@fao.org}
############### Last update :	27/04/2015
#### Script pour extraire les valeurs des pertes GFC pour les annees 2011, 2012

$base = `basename @ARGV[0]`;
chomp($base); 
print "$base\n";

$rootdir = `pwd`;
chomp($rootdir);
$in_dir = "$rootdir/output/sortie_arbre_route";
$fctdir = "$rootdir/output/facet";
$ly_dir = "$rootdir/output/gfc";
$outdir = "$rootdir/output/sortie_arbre_route_pertes_11_12_stratif";

print "$outdir\n";

######## Filtrer les pixels isoles dans GFC_lossyear > 2010
system "oft-calc -ot Byte -um $fctdir/$base\_facet.tif $ly_dir/$base\_gfc_lossyear.tif $outdir/$base\_tmp.tif <<aof \n 1 \n #1 10 > 0 #1 13 < 0 #1 ? ? \n aof";
system "gdal_sieve.py 	-st 5 -4 $outdir/$base\_tmp.tif $outdir/$base\_tmp_sieve.tif";

system "oft-clump $outdir/$base\_tmp_sieve.tif $outdir/$base\_tmp_clump.tif";
system "oft-his -i $outdir/$base\_tmp_sieve.tif -o $outdir/$base\_tmp_sieve.txt -um $outdir/$base\_tmp_clump.tif -maxval 13";
system "oft-his -i $fctdir/$base\_facet.tif     -o $outdir/$base\_tmp_fct.txt   -um $outdir/$base\_tmp_clump.tif -maxval 12";

system "Rscript --verbose $rootdir/scripts_congo/filter_pertes_mmu_stratif.R $outdir/$base\_tmp_sieve.txt $outdir/$base\_tmp_fct.txt $outdir/$base\_tmp_sieve_reclassed.txt";

system "oft-reclass -oi $outdir/$base\_tmp_filter.tif $outdir/$base\_tmp_clump.tif <<eof \n $outdir/$base\_tmp_sieve_reclassed.txt \n 1 \n 1 \n 7 \n 0 \n eof";

system "gdal_translate -co \"COMPRESS=LZW\" $outdir/$base\_tmp_filter.tif $outdir/$base\_ly1112_sieve.tif";

######## Empiler la sortie Arbre+Route avec les Pertes 2011-2012
system "oft-stack -o $outdir/$base\_tmp2.tif $in_dir/$base\_out_dt_road.tif $outdir/$base\_ly1112_sieve.tif ";

######## Ecrire les valeurs
system "oft-calc -ot Byte $outdir/$base\_tmp2.tif $outdir/$base\_tmp_3.tif  <<aof \n 1 \n #2 10 > #1 #2 ? \n aof";
system "gdal_translate -co \"COMPRESS=LZW\" $outdir/$base\_tmp_3.tif $outdir/$base\_out_dt_road_ly1112.tif";
system "rm $outdir/$base\_tmp*";

