############### Author : 		Rémi d'Annunzio {mailto:remi.dannunzio@fao.org}
############### Last update :	27/04/2015
#### Script pour extraire les valeurs 24 (routes en 2010) du produit GAF et creer un masque

$base = `basename @ARGV[0]`;
chomp($base); 
print "$base\n";

$rootdir = `pwd`;
chomp($rootdir);
$in_dir = "$rootdir/output/sortie_arbre";
$outdir = "$rootdir/output/sortie_arbre_route";
$roaddir = "$rootdir/output/masque_routes";
print "$out_dir\n";

system "oft-stack -o $outdir/$base\_tmp.tif $in_dir/$base\_out.tif $roaddir/$base\_route_masque.tif ";

system "oft-calc -ot Byte $outdir/$base\_tmp.tif $outdir/$base\_tmp_2.tif  <<aof \n 1 \n #2 0 = 34 #1 ? \n aof";
system "gdal_translate -co \"COMPRESS=LZW\" $outdir/$base\_tmp_2.tif $outdir/$base\_out_dt_road.tif";
system "rm $outdir/$base\_tmp*.tif";
