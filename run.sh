#!/bin/bash
#################################################################
# Dockerfile main script
#################################################################
# Input arguments
#$1: orthoPath - Input path for the original Tile to process (orthophotos)
#$2: texturePath - Folder where the texture files are stored
#$3: resultPath - Path where the results are saved
#$4: InputFile - Input file to be processed
#################################################################
: ${1?"Usage: $0 orthoPath texturePath resultPath inputFile.tif"}
#################################################################
echo $1
echo $2
echo $3
echo $4
basename=$(echo $4 | sed 's/.tif//' | sed 's/-/_/')

# Redirect GUI to Virtual Frame Buffer
Xvfb :1 -screen 0 1024x768x16 &> xvfb.log  &
export DISPLAY=:1.0
#Stuff to get GRASS running
#generate GISRCRC
mkdir -p $HOME/grassdata
MYGISDBASE=$HOME/grassdata
#create temporary location from the EPSG code of the tile
grass73 --text -c $1/$4 $HOME/grassdata/tmplocation  --exec $HOME/dev/script.sh $1 $2 $3 $4
# Clean up the mess
rm -rf $HOME/grassdata/tmplocation
python /home/canhemon/dev/texture_predict.py --orthoPath=$1 --texturePath=$2 --resultPath=$3 --InputFile=$4
