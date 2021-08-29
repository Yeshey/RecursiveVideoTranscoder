#!/bin/bash

trap "terminater" SIGINT
    exit_handler() {
        local old="${1}"
        local file="${2}"
        echo "ffmpeg interrupted, recovering old file..."
        rm "${file%.*}_f.mp4"
        mv "${old}" "${file}"
        exit  # gets caught by trap and goes to terminator
    }
    terminater(){
        echo " Exiting normally"
        exit  # Exits normally
    }

echo "This script will recursively search for any videos and transcode them in place to make'em smaller"

while true; do
    read -p "do you wish to append _f to transcoded videos?, videos that end with _f won't be transcoded y/n: " yn
    case $yn in
        [Yy]* ) name_f="_f"; break;;
        [Nn]* ) name_f=""; break;;
        * ) echo "Please answer yes or no.";;
    esac
done

while true; do
    read -p "Do you wish to change frame rate y/n: " yn
    case $yn in
        [Yy]* ) echo "dayum"; 
                echo "well ok";
                break;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no.";;
    esac
done

exit

find . \( -iname '*.kvm' -o -iname '*avi' -o -iname '*mp4' -o -iname '*flv' -o -iname '*ogg' -o -iname '*mov' -o -iname '*asf' -o -iname '*mkv' \) -print |
    while IFS= read file    # IFS= prevents "read" stripping whitespace
        do
            if [[ "$file" != *"_f."* ]]
            then
                filename=$(basename -- "$file")
                old="${file%.*}_old_f.${file##*.}"
                mv "$file" "$old"  #renaming
                # < /dev/null to prevent from reading standard input (Strange errors when using ffmpeg in a loop)
                # -max_muxing_queue_size 1024 needed for certain situations (FFMPEG: Too many packets buffered)
                < /dev/null ffmpeg -i "$old" -vcodec libx265 -crf 28 -max_muxing_queue_size 1024 "${file%.*}${name_f}.mp4" || exit_handler "$old" "$file"

                mv "${old}" "/tmp/${filename}"
                echo "file $file transcoded, old moved to /tmp"
            fi
        done
