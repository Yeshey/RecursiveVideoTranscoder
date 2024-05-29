#!/bin/bash

    exit_handler() {
        local old="${1}"
        local file="${2}"
        echo "ffmpeg interrupted, recovering old file..."
        rm "${file%.*}_f.mp4"
        mv "${old}" "${file}"
        exit  # gets caught by trap and goes to terminator
    }
    terminater(){
        echo
        echo " Exiting normally"
        exit  # Exits normally
    }
trap "terminater" SIGINT SIGTERM

echo "This script will recursively search for any videos from the current folder and transcode them in place to make'em smaller"
echo "Videos that end with _f won't be transcoded"
echo
while true; do
    read -p "do you wish to append _f to transcoded videos? y/n: " yn
    case $yn in
        [Yy]* ) name_f="_f"; break;;
        [Nn]* ) name_f=""; break;;
        * ) echo "Please answer yes or no.";;
    esac
done
echo
changefps=false
while true; do
    read -p "Do you wish to change frame rate y/n: " yn
    case $yn in
        [Yy]* ) echo "All files will be recoded with the following fps unless they already have a lower fps than the given (give a number): "; 
                read fps;
                newfps=$fps
                changefps=true
                break;;
        [Nn]* ) changefps=""; break;;
        * ) echo "Please answer yes or no.";;
    esac
done
echo
while true; do
    read -p "Do you wish to change the resolution y/n: " yn
    case $yn in
        [Yy]* ) echo "Videos will never be upscaled, only downscalled. Give the width of the new videos, aspect ratio will be preserved."; 
                echo "For example, if width given is 1600, then a video 1920x1080 will turn into a 1600x900, but a ";
                echo "Width (has to be divisible by 2, as well as the height): "; 
                read newWidth;
                # Check if width is divisible by two
                if (($newWidth % 2 != 0)); then
                    # Increment width by one
                    newWidth=$(($newWidth + 1))
                    echo "Width = $newWidth to be divisible by two"
                fi
                scale="-vf \"scale='if(gt(iw,${newWidth}),${newWidth},iw)':-1\" ";
                break;;
        [Nn]* ) scale=""; break;;
        * ) echo "Please answer yes or no.";;
    esac
done
echo
echo "ffmpeg command to be ran:"
echo "ffmpeg -i \"\$file\" -map 0 -c:s copy -vcodec libx265 -crf 28 ${scale}${changefps:+-filter:v fps=${fps} }-max_muxing_queue_size 1024 \"\$file${name_f}.mp4\""
echo
while true; do
    read -p "Proceed? y/n: " yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done

find . \( -iname '*.kvm' -o -iname '*.avi' -o -iname '*.mp4' -o -iname '*.wmv' -o -iname '*.flv' -o -iname '*.webm' -o -iname '*.ogg' -o -iname '*.mov' -o -iname '*.asf' -o -iname '*.mkv' \) -print |
    while IFS= read file    # IFS= prevents "read" stripping whitespace
        do
            if [[ "$file" != *"_f."* ]]
            then
                filename=$(basename -- "$file")
                old="${file%.*}_old_f.${file##*.}"
                mv "$file" "$old"  # renaming
                vf=""

                # Run ffprobe and capture the output
                probe_output=$(ffprobe -v error -select_streams v:0 -show_entries stream=width,height,r_frame_rate -of csv=s=x:p=0 "$old")
                # Extract the width, height, and frame rate values from the output
                IFS="x" read -r width height frame_rate <<< "$probe_output"
                # Print the values (optional)
                echo "Width: $width"
                echo "Height: $height"
                # Extract the frame rate numerator from the frame_rate value
                frame_rate_num=$(echo "$frame_rate" | cut -d'/' -f1)
                # Convert the frame rate numerator to an integer
                frame_rate_num=$(printf "%.0f" "$frame_rate_num")
                # Print the updated frame rate value
                echo "Frame Rate: $frame_rate_num"

                # Initialize linearfilters as an empty string
                linearfilters=""

                # Check if the scale is empty
                if [[ -n "$scale" ]]; then
                    # Scale not empty
                    vf="-vf"
                    scale="scale='if(gt(iw,$newWidth),$newWidth,iw)':-4" # -4 bc https://ffmpeg.org/pipermail/ffmpeg-user/2015-July/027727.html

                    # Calculate the new height based on the new width and the aspect ratio of the old video to see if it is divisible by 2
                    newHeight=$(($newWidth * $height / $width))
                    # Loop until the new height is divisible by 2
                    while (($newHeight % 2 != 0)); do
                        # Increment newWidth by 2
                        newWidth=$(($newWidth + 2))
                        # Recalculate the new height
                        newHeight=$(($newWidth * $height / $width))

                        scale="scale='if(gt(iw,$newWidth),$newWidth,iw)':-4"
                        # Print the new width and height values
                        echo "New Width: $newWidth"
                        echo "New Height: $newHeight"
                    done

                    if [ -z "$linearfilters" ]; then
                        # linear filters empty
                        linearfilters="${scale}"
                    else
                        # linear filters not empty
                        linearfilter="${linearfilter},${scale}"
                    fi
                fi

                # Check if the changefps is true
                if [[ "$changefps" = true ]]; then
                    # changefps not empty
                    # Only change fps if they'll be lesser than the original, never increase fps
                    if (($frame_rate_num > $fps)); then
                        # Frame rate needs to be changed
                        fpsoption="fps=${newfps}";

                        vf="-vf";
                        if [ -z "$linearfilters" ]; then
                            # linear filters empty
                            linearfilters="$fpsoption";
                        else
                            # linear filters not empty
                            linearfilters+=",$fpsoption";
                        fi
                    # else frame rate doesn't need to be changed
                    fi
                fi

                # < /dev/null to prevent from reading standard input (Strange errors when using ffmpeg in a loop)
                # -max_muxing_queue_size 1024 needed for certain situations (FFMPEG: Too many packets buffered)
                # -map 0 -c:s copy to copy metadata, keeping audio tracks, subtitles and chapters
                < /dev/null ffmpeg -i "$old" -map 0 -c:s copy -vcodec libx265 -crf 28 ${vf} ${linearfilters} -max_muxing_queue_size 1024 "${file%.*}${name_f}.mp4" || exit_handler "$old" "$file"

                echo "file $file transcoded, moving old to /tmp..."
                mv "${old}" "/tmp/${filename}" || 
                ( echo "mv failed, deleting instead" && rm "${old}" ) || exit
            fi
        done
