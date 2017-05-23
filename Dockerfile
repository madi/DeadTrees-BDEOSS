#
# Dockerfile
#

# Pull base image.
FROM debian:stretch
MAINTAINER Margherita Di Leo <dileomargherita@gmail.com>
ENV DEBIAN_FRONTEND=noninteractive
ENV TERM xterm
ENV DISPLAY :1.0
ENV LC_ALL C.UTF-8

USER root
RUN echo "deb http://httpredir.debian.org/debian stretch main" > /etc/apt/sources.list

RUN sed -i 's/$/ contrib non-free/g' /etc/apt/sources.list

# Install.
RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get dist-upgrade -y
RUN apt-get install -y apt
RUN apt-get install -y \
	bc flex byacc m4 automake cmake ccache \
	gawk grep sed libreadline-dev checkinstall \
	bash subversion icewm imagej dillo links \
	byobu curl git htop mc unzip vim wget \
	git libxml2-dev python build-essential make \
	man gcc python-dev locales python-pip xauth xvfb \
	python-dateutil libgsl0-dev \
	python-opengl python-wxversion python-wxtools python-wxgtk3.0 \
	python-dateutil libgsl0-dev \
	wx3.0-headers wx-common libwxgtk3.0-dev libwxbase3.0-dev \
	zlib1g-dev libtiff-dev libgeotiff-dev libpnglite-dev \
	libcairo2-dev libsqlite3-dev libpq-dev \
	libfreetype6-dev gettext ghostscript \
	libboost-thread-dev libboost-program-options-dev \
	libjpeg-dev libav-tools libavutil-dev ffmpeg2theora \
	libffmpegthumbnailer-dev libavcodec-dev libxmu-dev \
	libavformat-dev libswscale-dev libglu1-mesa-dev libxmu-dev \
	python-gdal liblapack-dev python-numpy \
	libfftw3-double3 libfftw3-dev libcairo2 libsqlite3-dev \
	libnetcdf-dev libtinfo-dev \
	sudo

RUN apt-get install -y default-libmysqlclient-dev

RUN apt-get install -y \
	r-base r-cran-raster r-cran-rjava r-cran-foreach \
	r-cran-doparallel r-cran-ggplot2 r-cran-taxize \
	r-cran-fields r-cran-knitr r-cran-xtable \
	libcurl4-gnutls-dev libgdal-dev default-jre

RUN apt-get install -y grass-dev

# Clean up the mess
RUN apt-get autoremove -y
RUN rm -rf /var/lib/apt/lists/*

RUN dpkg-reconfigure locales && \
    locale-gen C.UTF-8 && \
    /usr/sbin/update-locale LANG=C.UTF-8
RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
RUN dpkg-reconfigure locales

# Create USER
RUN useradd --create-home --shell /bin/bash -u 35378 canhemon
#RUN echo 'canhemon:newpassword' | chpasswd
USER canhemon
WORKDIR /home/canhemon

# GRASS and ImageJ/Fiji
# Create dev dir for GRASS
RUN mkdir -p /home/canhemon/dev
WORKDIR /home/canhemon/dev/

# Download GRASS
RUN svn checkout \
    https://svn.osgeo.org/grass/grass/trunk /home/canhemon/dev/grass_trunk

# Download GRASS add-ons
RUN svn checkout \
    https://svn.osgeo.org/grass/grass-addons /home/canhemon/dev/grass_addons

# Add config file for GRASS 7
ADD c7.sh /home/canhemon/dev/grass_trunk/c7.sh

# Compile GRASS SVN
WORKDIR /home/canhemon/dev/grass_trunk

# added this workaround for running config file because was not executable
#USER root
WORKDIR /home/canhemon/dev/grass_trunk
RUN bash ./c7.sh

USER canhemon
WORKDIR /home/canhemon/dev/grass_trunk
RUN make

# Compile Add-ons
WORKDIR /home/canhemon/dev/grass_addons/grass7
RUN make MODULE_TOPDIR=/home/canhemon/dev/grass_trunk/

# Install Full GRASS SVN with ADDONS
WORKDIR /home/canhemon/dev/grass_trunk
USER root
RUN make install && ldconfig
USER canhemon

# Download, unzip and install Fiji
#WORKDIR /home/canhemon/dev/
#RUN wget \
#    -c http://downloads.imagej.net/fiji/latest/fiji-linux64.zip
#    #-e use_proxy=yes -e http_proxy=10.168.209.72:8012 \
#RUN unzip fiji-linux64.zip

# Install the dismo R lib
WORKDIR /home/canhemon/dev
USER root
RUN echo 'install.packages("dismo", repos="http://cran.us.r-project.org", \
    dependencies=TRUE)' > /home/canhemon/dev/packages.R \
    && Rscript /home/canhemon/dev/packages.R

RUN echo 'install.packages("rgdal", repos="http://cran.us.r-project.org", \
    dependencies=TRUE)' > /home/canhemon/dev/packages.R \
    && Rscript /home/canhemon/dev/packages.R

RUN echo 'install.packages("biomod2", repos="http://cran.us.r-project.org", \
    dependencies=TRUE)' > /home/canhemon/dev/packages.R \
    && Rscript /home/canhemon/dev/packages.R

RUN echo 'install.packages("maxent", repos="http://cran.us.r-project.org", \
    dependencies=TRUE)' > /home/canhemon/dev/packages.R \
    && Rscript /home/canhemon/dev/packages.R

RUN echo 'install.packages("Reol", repos="http://cran.us.r-project.org", \
    dependencies=TRUE)' > /home/canhemon/dev/packages.R \
    && Rscript /home/canhemon/dev/packages.R

#USER root
# Add file for the Maxent model to be used by R lib
#ADD maxent.jar /usr/local/lib/R/site-library/dismo/java/maxent.jar

WORKDIR /home/canhemon/dev
USER canhemon

# Set environment variables for GRASS
ENV HOME /home/canhemon
ENV GISBASE /usr/local/grass-7.3.svn
ENV GRASS_VERSION="7.3.svn"
RUN echo "\nexport TERM=xterm" >> /home/canhemon/.bashrc
RUN Xvfb :1 -screen 0 1024x768x16 &> xvfb.log  &

# Define working directory for GRASS
WORKDIR /home/canhemon
RUN mkdir -p /home/canhemon/grassdata
RUN grass73 -text -c EPSG:32629 /home/canhemon/grassdata/temp

# Define default command.
CMD ["bash"]
ENV DEBIAN_FRONTEND=teletype

# Dependencies for DeadTrees model
USER root
RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y python-rtree libspatialindex-dev python-numpy \
    python-scipy python-matplotlib python-sklearn python-scikits-learn \
		python-dev python-setuptools python-pip

# Add file for the main script
ADD run.sh /home/canhemon/run.sh

# Add file for pre-processing in GRASS
ADD script.sh /home/canhemon/dev/script.sh

ADD texture_common.py /home/canhemon/dev/texture_common.py
ADD texture_predict.py /home/canhemon/dev/texture_predict.py
ADD movingwindow.py /home/canhemon/dev/movingwindow.py
ADD mlh.py /home/canhemon/dev/mlh.py
ADD poligonize.py /home/canhemon/dev/poligonize.py
ADD serialize.py /home/canhemon/dev/serialize.py
ADD clipshape.py /home/canhemon/dev/clipshape.py

ADD /pickle/model/modelKNN.pickle /home/canhemon/data_test_docker/pickle/model/modelKNN.pickle

# run test
#TODO: remove this in prod
ADD data_test_docker/pt599000-4415000.tif \
  /home/canhemon/data_test_docker/pt599000-4415000.tif

ADD data_test_docker/pt603000-4402000.tif \
	/home/canhemon/data_test_docker/pt603000-4402000.tif

ADD data_test_docker/dataOut/ \
	/home/canhemon/data_test_docker/dataOut/

ADD data_test_docker/texturePath/ \
	/home/canhemon/data_test_docker/texturePath/

#TODO: remove this in prod
ADD data_test_docker/texturePath/pca_text_pt599000_4415000_1.tif \
	/home/canhemon/data_test_docker/texturePath/pca_text_pt599000_4415000_1.tif
#TODO: remove this in prod
ADD data_test_docker/texturePath/pca_text_pt599000_4415000_2.tif \
	/home/canhemon/data_test_docker/texturePath/pca_text_pt599000_4415000_2.tif

RUN bash ./run.sh /home/canhemon/data_test_docker /home/canhemon/data_test_docker/texturePath  /home/canhemon/data_test_docker/dataOut  pt599000-4415000.tif
