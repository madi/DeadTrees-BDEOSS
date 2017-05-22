#!/bin/bash

outputPath=$2

infileG=$(echo $3 | sed 's/.tif//' | sed 's/-/_/')
r.external input=$1/$3 output=$infileG
g.region rast=$infileG\.4 -a
r.texture -a input=$infileG\.4 output=text_b4_$infileG size=7 distance=5
r.texture -a input=$infileG\.1 output=text_b1_$infileG size=7 distance=5

i.group group=text input=`g.list type=raster pattern=*text* mapset=. sep=,`
i.pca input=text output=pca_text_$infileG

r.out.gdal input=pca_text_$infileG\.1 output=$outputPath/pca_text_$infileG\_1.tif \
  -f format=GTiff
r.out.gdal input=pca_text_$infileG\.2 output=$outputPath/pca_text_$infileG\_2.tif \
  -f
