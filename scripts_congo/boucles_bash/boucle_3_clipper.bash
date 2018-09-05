for file in input/lsat_2010/hh*.tif;
	do echo $file;
	basename=${file##*/};
	base=${basename%%_2010*};
	echo $base;

	oft-clip.pl output/segments/$base\_clump.tif input/gfc_cover2000_cgo.tif output/gfc/$base\_gfc_cover.tif;  
	oft-clip.pl output/segments/$base\_clump.tif input/facet_cgo.tif output/facet/$base\_facet.tif;
 	oft-clip.pl output/segments/$base\_clump.tif input/gfc_lossyear_cgo.tif output/gfc/$base\_gfc_lossyear.tif;  
	oft-clip.pl output/segments/$base\_clump.tif input/gaf_change_0010.tif output/gaf/$base\_gaf_change_0010.tif; 
	
done
