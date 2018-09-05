############### Author : 		Rémi d'Annunzio {mailto:remi.dannunzio@fao.org}
############### Last update :	27/04/2015
#### Script pour recoder les valeurs du produit GAF

#### code  10 -> new_code 1 -> FORET
#### code  20 -> new_code 2 -> NON FORET
#### code  21 -> new_code 3 -> F-terres cultivees
#### code  22 -> new_code 4 -> F-zone humide
#### code  23 -> new_code 5 -> F-savanne
#### code  24 -> new_code 6 -> F-infrastructure
#### code  25 -> new_code 7 -> F-autre
#### code 120 -> new_code 8 -> GAIN
#### code 254 -> new_code 9 -> No DATA

$base = `basename @ARGV[0]`;
chomp($base); 
print "$base\n";

$indir= "/media/xubuntu/data_ofgt/output/gaf";
$outdir= "/media/xubuntu/data_ofgt/output/gaf_recode";

system "oft-calc -ot Byte $indir/$base\_gaf_change_0010.tif $outdir/$base\_gaf_change_0010.tif  <<aof \n 1 \n #1 10 = #1 20 = #1 21 =  #1 22 = #1 23 =  #1 24 =  #1 25 = #1 120 =  #1 254 = 0 9 ? 8 ? 7 ? 6 ? 5 ? 4 ? 3 ? 2 ? 1 ? \n aof";
