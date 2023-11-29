#!/bin/bash

################################################################################
# Common variables                                                             #
################################################################################

VERSION="0.1"
IMAGEMAGICK="magick"
DEFAULT_MIN_ZOOM=1
DEFAULT_MAX_ZOOM=2
INITIAL_CROP=50
MAPDIR="map"

################################################################################
# help                                                                         #
################################################################################

help()
{
   # Display Help
   echo "== Map for Leaflet : tool to convert an image to map tiles"
   echo "== Version : $VERSION"
   echo "syntax: map_for_leaflet [-h] [-v] [-s <start zoom>] [-e <end zoom>] -i <input image> -o <output directory>"
   echo "options:"
   echo "-h     print this help"
   echo "-v     print software version and exit"
   echo "-s     indicate the start zoom (default 1)"
   echo "-e     indicate the end zoom (default 3)"
   echo
}

################################################################################
# Controls before launching                                                    #
################################################################################

current_crop=${INITIAL_CROP}
min_zoom=${DEFAULT_MIN_ZOOM}
max_zoom=${DEFAULT_MAX_ZOOM}

# Get the options
while getopts "hvi:o:s:e:" option; do
   case $option in
      h) # display help
         help
         exit;;
      v) # display version
         echo "map_for_leaflet v$VERSION"
         exit;;
      s) # min zoom
   	     min_zoom="$OPTARG";;
   	  e) # max zomm
   	     max_zoom="$OPTARG";;
      i) # input file
	     input_file="$OPTARG";;
	  o) # output directory
	     output_dir="$OPTARG";;
     \?) # incorrect option
         echo "error: invalid option"
         exit;;
   esac
done

# check required arguments
if ! command -v $IMAGEMAGICK &> /dev/null
then
    echo "Error : $IMAGEMAGICK could not be found."
	echo "Please install it to use this tool."
    exit 1
fi

# check if input and output provided
if test -z $input_file || test -z $output_dir 
then
    echo "Error : input file and output directory are required."
	exit 1
fi

# check if input file exists
if ! test -f "$input_file"
then
    echo "$input_file does not exist."
	exit 1
fi

# check if output dir exists
if ! test -d "$output_dir"
then
    echo "output_dir does not exist."
	exit 1
fi

################################################################################
# Main program                                                                 #
################################################################################

tiles_grid=2

mkdir "${output_dir}/$MAPDIR"
for zoom in $(seq ${min_zoom} ${max_zoom});
do 
  echo "Processing zoom $zoom (crop ${current_crop}%) (tiles_grid ${tiles_grid}x${tiles_grid})"; 
  echo "=============================================="; 

  mkdir "${output_dir}/$MAPDIR/$zoom"
  convert -crop ${current_crop}%x${current_crop}% ${input_file} "${output_dir}/$MAPDIR/$zoom/img-%03d.jpg"
  x=0
  y=0
  for file in `ls "${output_dir}/$MAPDIR/$zoom"`
  do
    mv "${output_dir}/$MAPDIR/$zoom/$file" "${output_dir}/$MAPDIR/$zoom/$x-$y.jpg"
    echo file $file processed to $x-$y.jpg
    x=$((x+1))
	
	max_grid=`expr ${tiles_grid} '-' 1`
	echo "max_grid=$max_grid"
    if [ $x -gt ${max_grid} ]
    then
      x=0
      y=$((y+1))
    fi
  done
  
  tiles_grid=`expr $tiles_grid '*' 2`
  current_crop=`bc -l <<< "$current_crop / 2"`
done

echo "Tiles are now completed !"; 


