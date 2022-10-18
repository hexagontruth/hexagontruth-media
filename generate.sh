#!/bin/bash

dir="$(dirname "$0")"
src=$(pwd)
dest="${dir}/videos"

if [ -n "$2" ]; then
  src=$1
  dest=$2
elif [ -n "$1" ]; then
  dest=$1
fi

echo "Converting files from $src into $dest"

command_path=commands
crf_path="${dir}/crf"

echo $crf_path
if [ -f "$crf_path" ]; then
  . $crf_path
fi

cat /dev/null > $command_path
ls "$src" | while read line; do
  if [[ $line == thumb* ]] || [[ $line != *.mp4 && $line != *.gif ]]; then
    continue
  fi
  mkdir -p "$dest"

  scale=1080 # No gifs are 1larger than this
  q=27
  if [[ $line == *.mp4 ]]; then
    scale=1440 # Most videos
  fi

  varline="$(echo "$line" | sed 's/\(\-\|\.mp4\|\.gif\)//g')"

  if [ -n "${!varline}" ]; then
    q=${!varline}
  fi

  in="${src}/${line}"
  out="$(echo "${dest}/${line}" | sed s/gif/mp4/g)"
  echo $in '->' $out
  echo ffmpeg -y -i "$in" -pix_fmt yuvj420p -vf scale=${scale}:-1,fps=30 -frames:v 900 -c:v libx264 -crf $q -preset veryslow -an "$out" >> $command_path
done
