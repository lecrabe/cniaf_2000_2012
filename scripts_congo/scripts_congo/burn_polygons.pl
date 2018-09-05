############### Author : 		Rémi d'Annunzio {mailto:remi.dannunzio@fao.org}
############### Last update :	27/04/2015

# ouvrir l arbre de decision et reclasser les polygones avec le resultat

###########  Define your path & set parameters
$base = `basename @ARGV[0]`;
chomp($base); 
print "$base\n";

$rootdir = `pwd`;
chomp($rootdir);
$histdir = "$rootdir/output/histograms";
$out_dir = "$rootdir/output/sortie_arbre";
$seg_dir = "$rootdir/output/segments";
$statdir = "$rootdir/output/stats";
print "$out_dir\n";
#die;
system "Rscript --verbose $rootdir/scripts_congo/arbre_decision_20150617.R $histdir/$base\_facet.txt $histdir/$base\_gaf.txt $histdir/$base\_gfc_tc.txt $histdir/$base\_gfc_ly.txt $out_dir/$base\_out.txt $statdir/$base\_stats_out.txt $statdir/$base\_stats_gaf.txt $statdir/$base\_stats_fct.txt $statdir/$base\_stats_gfc.txt $statdir/$base\_arbre.txt $statdir/$base\_strates.txt";

system "oft-reclass -oi $out_dir/$base\_tmp.tif $seg_dir/$base\_clump.tif <<eof \n $out_dir/$base\_out.txt \n 1 \n 1 \n 3 \n 0 \n eof";

system "gdal_translate -co \"COMPRESS=LZW\" $out_dir/$base\_tmp.tif $out_dir/$base\_out.tif";
system "rm $out_dir/$base\_tmp*.tif";


