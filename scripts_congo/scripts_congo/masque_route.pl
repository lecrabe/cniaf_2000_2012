############### Author : 		Rémi d'Annunzio {mailto:remi.dannunzio@fao.org}
############### Last update :	27/04/2015
#### Script pour extraire les valeurs 24 (routes en 2010) du produit GAF et creer un masque

$base = `basename @ARGV[0]`;
chomp($base); 
print "$base\n";

$indir= "/media/xubuntu/data_ofgt/output/gaf_recode";
$outdir= "/media/xubuntu/data_ofgt/output/masque_routes";

system "oft-calc -ot Byte $indir/$base\_gaf_change_0010.tif $outdir/$base\_temp.tif  <<aof \n 1 \n #1 24 = 0 1 ? \n aof";
system "gdal_translate -co \"COMPRESS=LZW\" $outdir/$base\_temp.tif $outdir/$base\_route_masque.tif";
system "rm $outdir/$base\_temp.tif";
