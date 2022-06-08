#!/bin/bash
#
# Timothy Salazar
# 5-17-22
#
# This is a script with a very narrow scope, and it makes a lot
# of assumptions. It assumes:
#    - it's being run within a WSL2 instance
#    - getMaxScreenDims.ps1 is in the same directory
#        - yeah, powershell. Kinda gross, but we're in WSL2 land
# It gets the max width and height out of every monitor in pixels,
# as well as the width and height of an image in pixels (passed in
# as an argument to this script).
# This script was written to help scale pictures downloaded from
# NASA's Astronomy Pic of the Day, which are ocassionally very
# large. This may come down to individual taste, but the author
# prefers that images be cut off on some monitors (it doesn't matter
# much in the case of a starfield). Therefor, this script returns the
# MINUMUM PERCENT by which the image should be scaled down such that
# either its width or height match the max width or height among the
# attached monitors.
#
# TLDR; this returns the percent we should scale the given image
# to make it roughly fit the monitors (erring on the side of too
# big).

cd $(dirname $0)
MAX_SCREEN_DIMS=( $(powershell.exe ./getMaxScreenDims.ps1) )
IMG_DIMS=( $(identify -format "%w %h" $1 ) )

IMG_W=${IMG_DIMS[0]}
IMG_H=${IMG_DIMS[1]}

SCR_W=${MAX_SCREEN_DIMS[0]}
SCR_H=${MAX_SCREEN_DIMS[1]}

if [ $IMG_W -gt $SCR_W ] && [ $IMG_H -gt $SCR_H ]; then
	W_PRC=$((SCR_W*100 / IMG_W))
	H_PRC=$((SCR_H*100 / IMG_H))
	MIN_PRC=$((W_PRC > H_PRC ? W_PRC : H_PRC))
	echo $MIN_PRC
else
    echo 100
fi
