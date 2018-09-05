for file in input/lsat_2010/hh*.tif;
	do echo $file;
	basename=${file##*/};
	base=${basename%%_2010*};
	echo $base;

	perl scripts_congo/recode_gaf.pl $base;
done
