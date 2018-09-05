############### Author : 		Rémi d'Annunzio {mailto:remi.dannunzio@fao.org}
############### Last update :	27/04/2015
# Segmentation multitemporelle de deux images landsat, sur les bandes 3 4 5 

###########  Define your path & set parameters
$base = `basename @ARGV[0]`;
chomp($base); 
print "$base\n";
#die;
$rootdir = `pwd`;
chomp($rootdir);
$dir2000 = "$rootdir/input/lsat_2000";
$dir2010 = "$rootdir/input/lsat_2010";
$dirsegs = "$rootdir/output/segments";

system "gdal_translate 	-b 1 -b 2 -b 3 		 $dir2000/$base\_2000_b3457.tif 	$dirsegs/$base\_3b.tif";
system "oft-stack 	-ot Int16 -o 		 $dirsegs/$base\_stack.tif 	$dirsegs/$base\_3b.tif 	$dir2010/$base\_2010_b345.tif";
#die;
system "oft-seg 	-region -th 3 $dirsegs/$base\_stack.tif 	$dirsegs/$base\_seg.tif <<aof \n 0 \n 0 \n aof";
system "gdal_sieve.py 	-st 5 -4 		 $dirsegs/$base\_seg.tif 	$dirsegs/$base\_sieve.tif";
system "oft-clump 	-ot UInt16 		 $dirsegs/$base\_sieve.tif 	$dirsegs/$base\_clump.tif";
system "gdal_polygonize.py -f \"ESRI Shapefile\" $dirsegs/$base\_clump.tif 	$dirsegs/$base\_poly.shp";

system "rm $dirsegs/$base\_stack.tif && rm $dirsegs/$base\_seg.tif && rm $dirsegs/$base\_sieve.tif && rm $dirsegs/$base\_3b.tif";
