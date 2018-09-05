############### Author : 		Rémi d'Annunzio {mailto:remi.dannunzio@fao.org}
############### Last update :	10/08/2015
#### Script pour recoder les valeurs du produit GEZ USGS

#### 
$rootdir = `pwd`;
chomp($rootdir);
$txtdir = "$rootdir/input/gez";
$in_dir = "$rootdir/output/gez";
$outdir = "$rootdir/output/gez_reclass";

$base = `basename @ARGV[0]`;
chomp($base); 
print "$base\n";

#system "oft-reclass -oi $outdir/$base\_tmp.tif $in_dir/$base\_gez.tif <<eof \n $txtdir/reclass_strata.txt \n 1 \n 1 \n 2 \n 0 \n eof";
#system "gdal_translate -ot Byte -co \"COMPRESS=LZW\" $outdir/$base\_tmp.tif $outdir/$base\_gez_rcl_strata.tif";
#system "rm $outdir/$base\_tmp.tif";

#system "oft-reclass -oi $outdir/$base\_tmp.tif $in_dir/$base\_gez.tif <<eof \n $txtdir/reclass_strata.txt \n 1 \n 1 \n 3 \n 0 \n eof";
#system "gdal_translate -ot Byte -co \"COMPRESS=LZW\" $outdir/$base\_tmp.tif $outdir/$base\_gez_rcl_GLC.tif";
#system "rm $outdir/$base\_tmp.tif";

#system "oft-reclass -oi $outdir/$base\_tmp.tif $in_dir/$base\_gez.tif <<eof \n $txtdir/reclass_strata.txt \n 1 \n 1 \n 4 \n 0 \n eof";
#system "gdal_translate -ot Byte -co \"COMPRESS=LZW\" $outdir/$base\_tmp.tif $outdir/$base\_gez_rcl_ELU.tif";
#system "rm $outdir/$base\_tmp.tif";

system "oft-reclass -oi $outdir/$base\_tmp.tif $in_dir/$base\_gez.tif <<eof \n $txtdir/reclass_strata.txt \n 1 \n 1 \n 5 \n 0 \n eof";
system "gdal_translate -ot Byte -co \"COMPRESS=LZW\" $outdir/$base\_tmp.tif $outdir/$base\_gez_rcl_ELU_all.tif";
system "rm $outdir/$base\_tmp.tif";
