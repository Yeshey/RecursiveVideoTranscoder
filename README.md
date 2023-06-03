# RecursiveVideoTranscoder
Command line interface for recursively transcoding videos and replacing them in place using ffmpeg to make them smaller, recoding thhem with the H265 codec.

The script finds all the following video extensions: .kvm .avi .mp4 .flv .ogg .mov .asf .mkv, and transcodes them to .mp4 in an efficient way with ffmpeg

# Dependencies
Works in unix systems. Requiers curl and ffmpeg installed:

**ubuntu**: `sudo apt-get update && sudo apt-get install ffmpeg && sudo apt-get install curl`

**arch**: `sudo pacman -Sy ffmpeg && sudo pacman -Sy curl`

# Usage
no installation required, in terminal `cd` to the desiered directory and run 

```bash <(curl -s https://raw.githubusercontent.com/Yeshey/RecursiveVideoTranscoder/main/RecursiveVideoTranscoder.sh)``` <br><br> CTRL + C to stop the script. Will stop the recoding of the current video and replace it with the old again.

# Know Issues:
- Doesn't have option to diminuish bit-rate or resolution.
- Some players might have trouble with the way it's encoded.
- It's a very time and CPU consuming process - This is down to ffmpeg.

# Updates log:
*newest*
- Added option to alter resolution too now, and it won''t allow videos to increase resolution or fps
- Videos don't loose audio and subtitle tracks and chapters anymore.
- Handled "not enough space left on device" exception when running `mv` to /tmp to delete old file instead
- [Solution found](https://stackoverflow.com/questions/16854041/bash-read-is-being-skipped-when-run-from-curl-pipe) to run script with curl whilst being able to read user input with `read`
- Fixed CTRL + C halting justs ffmpeg and not whole script, and handling exit appropriately

*oldest*
