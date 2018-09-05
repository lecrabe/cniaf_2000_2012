for file in input/lsat_2010/hh*.tif;
	do echo $file;
	basename=${file##*/};
	base=${basename%%_2010*};
	echo $base;

	oft-stat -i output/gfc/$base\_gfc_cover.tif -o output/histograms/$base\_gfc_tc.txt -um output/segments/$base\_clump.tif;
	oft-his -i output/gfc/$base\_gfc_lossyear.tif -o output/histograms/$base\_gfc_ly.txt -um output/segments/$base\_clump.tif -maxval 13;
	oft-his -i output/facet/$base\_facet.tif -o output/histograms/$base\_facet.txt -um output/segments/$base\_clump.tif -maxval 12;
	oft-his -i output/gaf_recode/$base\_gaf_change0010.tif -o output/histograms/$base\_gaf.txt -um output/segments/$base\_clump.tif -maxval 9;
done
