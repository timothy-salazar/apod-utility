#!/bin/sh

# Timothy Salazar
# 4/11/22
#
# This queries Nasa's Astronomy Pic of the Day and
# gets the URL for the day's image.
# It then downloads the image and converts it into a
# .bmp file named "USBlackWallpaper.bmp", replacing the
# boring company-mandated black wallpaper with
# something interesting.
# Assumes that the variable "NASA_API" has been set, and is
# a valid API key

# Replace this with your API key or you might be rate limited
NASA_API="DEMO_KEY"

BRIGHTNESS_THRESHOLD=".3"
LOOP_VAR=0
SCRIPT_DIR=$(dirname $0)

# Gets flags and sets the appropriate variables:
RAND_IMG=0
while getopts 'hr' OPTION; do
    case "$OPTION" in
        h)
            echo "-r: download a random picture from the last 1000 days" >&2
			exit 1
			;;
		r)
			RAND_IMG=1
			;;
	esac
done
# Takes a date with format YYYY-MM-DD, creates a URL, and downloads the metadata
# for that day's NASA Astronomy Pic of the Day.
# It then extracts the media type, and if it's an image it will download it.
download_APOD () {
	APOD_URL="https://api.nasa.gov/planetary/apod?api_key=$NASA_API&date=$1"
	JSON_DATA=$(curl "$APOD_URL")
	MEDIA_TYPE=$(echo $JSON_DATA | jq -r '.media_type')
	IMAGE_URL=$(echo $JSON_DATA | jq -r '.hdurl')
	FILE_NAME=${IMAGE_URL##*/}
	FILE_PATH="/mnt/c/tools/$FILE_NAME"
	if [ $MEDIA_TYPE = "image" ]; then
		curl -s $IMAGE_URL > $FILE_PATH
		return 0
	else
		return 1
	fi
}

# If the image is too bright we get a random date.
# Because this gets run every loop for which the stopping condition hasn't
# been met, we'll also pause for a moment (out of courtesy to the API)
get_random_date () {
	RAND_NUM=$(awk 'BEGIN {srand(); printf "%d\n", rand()*327}')
	APOD_DATE=$(date --date="$RAND_NUM days ago" "+%Y-%m-%d")
	sleep .1
}


# The default behavior is to start by pulling the NASA APOD for the
# current date.
# If the -r flag is given (for example, if the user doesn't like the
# day's picture), then we begin with a random date instead.
if [ $RAND_IMG -eq 0 ]; then
	APOD_DATE=$(date "+%Y-%m-%d")
else
	get_random_date
fi

while [ $LOOP_VAR -le 5 ]
do
	download_APOD $APOD_DATE
	# check whether we downloaded an image
	if [ $? -gt 0 ]; then
		get_random_date
		LOOP_VAR=$((LOOP_VAR+1))
		continue
	fi
	# get the brightness of the image
	IMAGE_BRIGHTNESS=$(identify -channel all -format "%[fx:mean<$BRIGHTNESS_THRESHOLD]" $FILE_PATH)
	# If the image is too bright I don't want to use it, so we choose a random date
	# from the last 1000 days to download an image from and start again
	if [ $IMAGE_BRIGHTNESS -eq 0 ]; then
		get_random_date
		LOOP_VAR=$((LOOP_VAR+1))
		# removes temporary files so we don't eat up a lot of disk space over time
		rm $FILE_PATH
	# If the image is sufficiently dark so as to not offend my nerd-eyes, it is
	# converted to a .bmp file with the name our corporated desktop background
	# policy expects to see
	else
        SCALE_FACTOR=$( $SCRIPT_DIR/get_min_scaling.sh "$FILE_PATH" )
		convert "$FILE_PATH" -type truecolor  -resize $SCALE_FACTOR"%" "/mnt/c/tools/USBlackWallpaper.bmp"
		#rm $FILE_PATH
		break
	fi
done

# Use a powershell script to refresh the desktop background
powershell.exe $SCRIPT_DIR/refreshDesktop.ps1
