#!/bin/bash

CFLAGS="-g -O1 -Wall -Werror-implicit-function-declaration -fno-common -fexceptions -Wreturn-type"
LDFLAGS="-Wl,--no-undefined -Wl,-z,relro,-s"
./configure \
--with-cxx \
--with-wxwidgets \
--with-freetype=yes \
--with-postgres=no \
--with-sqlite=yes \
--with-freetype-includes=/usr/include/freetype2 \
--with-opengl-libs=/usr/include/GL \
--with-readline \
--with-python=yes \
--with-gdal=/usr/bin/gdal-config \
--with-proj-share=/usr/share/proj \
--with-pthread \
--with-openmp \
--with-liblas-config=/usr/bin/liblas-config \
--with-liblas=no \
--with-liblas-libs=/usr/lib \
--with-blas \
--with-geos=/usr/bin/geos-config \
--with-proj-share=/usr/share/proj \
--with-freetype=yes \
--with-freetype-includes="/usr/include/freetype2/" \
--with-ffmpeg=yes \
--with-ffmpeg-includes="/usr/include/libavcodec /usr/include/libavformat /usr/include/libswscale /usr/include/libavutil" \
2>&1 | tee config_log.txt

if [ $? -eq 1 ] ; then
         echo "an error occured"
         exit 1
fi

#old
#--with-lapack \
### now compile:
echo "Run for compilation: 'make' or 'make -j8'"

ARCH=`grep ARCH config.status | cut -d'%' -f3 |head -1`
echo "After that"
echo " GRASS 7 start script will be in: ./$BINDIR/bin.$ARCH"
echo " GRASS 7 binaries will be in:     ./$PREFIX/dist.$ARCH"
echo "(no need to run 'make install')"
echo "Enjoy."
