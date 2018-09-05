############### Author : 		Rémi d'Annunzio {mailto:remi.dannunzio@fao.org}
############### Last update :	27/04/2015
#### Calculer les statistiaues par province

$base = `basename @ARGV[0]`;
chomp($base); 
print "$base\n";

$rootdir = `pwd`;
chomp($rootdir);
$maskdir	= "$rootdir/output/prov";
$dt_rd_dir 	= "$rootdir/output/sortie_arbre_route";
$dt_ly_dir 	= "$rootdir/output/sortie_arbre_route_pertes_11_12_stratif";
$gfcdir		= "$rootdir/output/gfc";
$gafdir		= "$rootdir/output/gaf_recode";
$fctdir		= "$rootdir/output/facet";
#$statdir 	= "$rootdir/output/stats_provinces";
$gezdir		= "$rootdir/output/gez";
$statdir 	= "$rootdir/output/stats_gez";

print "$gezdir\n";

######## Calculer les histogrammes pour
#system "oft-his -um  $maskdir/$base\_prov.tif -i $gfcdir/$base\_gfc_lossyear.tif 	-o $statdir/$base\_stat_gfc.txt -maxval 13";
#system "oft-his -um  $maskdir/$base\_prov.tif -i $gafdir/$base\_gaf_change0010.tif 	-o $statdir/$base\_stat_gaf.txt -maxval 9";
#system "oft-his -um  $maskdir/$base\_prov.tif -i $fctdir/$base\_facet.tif 		-o $statdir/$base\_stat_fct.txt -maxval 12";
#system "oft-his -um  $maskdir/$base\_prov.tif -i $dt_rd_dir/$base\_out_dt_road.tif 	-o $statdir/$base\_stat_out_dt_rd.txt -maxval 34";
#system "oft-his -um  $maskdir/$base\_prov.tif -i $dt_ly_dir/$base\_out_dt_road_ly1112.tif -o $statdir/$base\_stat_out_dt_road_ly1112_strat.txt -maxval 37";
system "oft-his -um  $gezdir/$base\_gez.tif -i $dt_ly_dir/$base\_out_dt_road_ly1112.tif -o $statdir/$base\_stat_gez_utcatf.txt -maxval 37";
