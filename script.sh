#!/bin/bash

texturePath=$2
echo "texturePath" $2
echo "orthoPath" $1
echo "InputFile" $4


infileG=$(echo $4 | sed 's/.tif//' | sed 's/-/_/')

echo $infileG

r.external input=$1/$4 output=$infileG
g.region rast=$infileG\.4 -a
r.texture -a input=$infileG\.4 output=text_b4_$infileG size=7 distance=5
r.texture -a input=$infileG\.1 output=text_b1_$infileG size=7 distance=5

i.group group=text input=`g.list type=raster pattern=*text* mapset=. sep=,`
i.pca input=text output=pca_text_$infileG

r.out.gdal input=pca_text_$infileG\.1 output=$texturePath/pca_text_$infileG\_1.tif \
  -f format=GTiff
r.out.gdal input=pca_text_$infileG\.2 output=$texturePath/pca_text_$infileG\_2.tif \
  -f format=GTiff
