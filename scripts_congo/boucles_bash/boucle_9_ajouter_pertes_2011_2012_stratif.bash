mkdir output/sortie_arbre_route_pertes_11_12_stratif
for file in input/lsat_2010/hh*.tif;
	do echo $file;
	basename=${file##*/};
	base=${basename%%_2010*};
	echo $base;

	perl scripts_congo/ajouter_pertes_gfc_2011_2012.pl $base;
done
echo "la boucle est finie"
echo "maintenant on reaggrege"
gdal_merge.py -o output/arbre_route_pertes1112_stratifiees.tif -v -co "COMPRESS=LZW" output/sortie_arbre_route_pertes_11_12_stratif/*ly1112.tif

