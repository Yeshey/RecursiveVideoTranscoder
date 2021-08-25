# RecursiveVideoTranscoder
Command line interface for recursively transcoding videos and replacing them in place using ffmpeg to make them smaller 

The script finds all the following video extensions: .kvm .avi .mp4 .flv .ogg .mov .asf, and transcodes them to .mp4 in an efficient way with ffmpeg

# Installation
Works in unix systems. Requiers curl and ffmpeg installed:

**ubuntu**: `sudo apt-get update && sudo apt-get install ffmpeg && sudo apt-get install curl`

**arch**: `Pacman -Sy ffmpeg && Pacman -Sy curl`

# Usage
in terminal `cd` to the desiered directory and run 

```curl -s https://raw.githubusercontent.com/Yeshey/RecursiveVideoTranscoder/main/RecursiveVideoTranscoder.sh | bash```

# Know Issues:
CTRL+C SHOULDN'T BE USED!, as it deletes the original file and leaves the unfinished product of ffmpeg, then keeps going for other files, there is no way to cancel the process currently & deleted files are not recoverable as they are not sent to the recycle bin

there is only one transcoding command that keeps the video as is, just codificated in a more efficient way. No prompts are made as to how the user wants the process to happen.

It's a very time and CPU consuming process - This is down to ffmpeg.
