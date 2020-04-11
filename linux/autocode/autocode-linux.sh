#!/bin/bash
#./autocode-linux.sh <path to files> <hours to run for>
if [ -z "$1" ]
  then
    echo "Please provide a working directory"
    exit 1
fi
WORK_DIR=$1
cd "$WORK_DIR" || exit

if [ -z "$2" ]
  then
    echo "Please provide the minimum number of hours you wish encoding to occur"
    exit 1
fi
MAX_HOURS=$2

if ! [ -x "$(command -v HandBrakeCLI)" ]; then
  echo 'Error: HandBrakeCLI is not installed.' >&2
  exit 1
fi

SETTINGS="$WORK_DIR/settings"
if test -f "$SETTINGS"; then
    echo "Will read settings from $SETTINGS"
else
    echo "$SETTINGS does not exist. Creating an empty settings file now"
    touch "$SETTINGS"
fi

PreProcess() {
  echo "[$(date)] : Moving files less than 300MB to encoded"
  find "$WORK_DIR/work" -maxdepth 1 -type f -size -300M -exec mv "{}" "$WORK_DIR/work/encoded/" \;
}

CURRENT_FILE=""
Get-Next-File () {
  IFS=$'\n'
  for f in $(ls -p --sort=size "$WORK_DIR/work" | grep -v /);
  do
    if grep -Fq "$f" "$WORK_DIR/encode-history.log"
    then
        echo "[$(date)] : $f has been processed. Skipping"
        CURRENT_FILE=""
    else
        echo "[$(date)] : $f has not been processed. This file will be chosen for encoding."
        CURRENT_FILE=$f
        break
    fi
  done
  unset IFS
}

Encode-File() {
  file=$1
  hrs=$2
  # Create output file
  output_file="$WORK_DIR/work/encoded/$file"
  echo "[$(date)] : Encoding $file to $output_file"
  #Encode
  cmd="HandBrakeCLI -i \"$WORK_DIR/work/$file\" -t 1 --angle 1 -c 1 -o \"$output_file\"  -f mp4  --detelecine -w 640 --crop 0:0:0:0 --loose-anamorphic  --modulus 2 -e x264 -q 22 -r 30 --pfr -a none  --audio-fallback ac3 --markers="/tmp/chapter.csv" --encoder-preset=veryslow  --encoder-tune="film"  --encoder-level="3.1"  --encoder-profile=high  --verbose=1"
  echo "Command to execute is $cmd"
  # Niceness to be turned on dynamically from settings
  # shellcheck disable=SC1090
  source "$SETTINGS"
  if [ "$NICE" == true ]; then
    echo "[$(date)] : I will be nice. Encoding will be done with lesser system resources"
    eval "nice $cmd"
  else
    echo "[$(date)] : I will be greedy. Encoding will be done with maximum system resources"
    eval "$cmd"
  fi
  error_code=$?
  if [ $error_code -eq 0 ]
  then
  	# Add the file to the execution log history
  	echo "$(date)|$hrs|$file" >> "$WORK_DIR/encode-history.log"
    echo "[$(date)] : File encoded successfully!"
    mv "$WORK_DIR/work/$file" "$WORK_DIR/work/complete/$file"
    echo "[$(date)] : File moved to $WORK_DIR/work/complete/"
  else
    dt=$(date)
    echo "[$dt] : Unable to encode file!! An error-code has been logged" >&2
    echo "$dt|$error_code|$file" >> "$WORK_DIR/encode-errors.log"
  fi
}

Determine-Shutdown() {
  SHUTDOWN_TIMEOUT=30
  # Use Zenity if available
  if ! [ -x "$(command -v zenity)" ]; then
    eval "$(dirname "$0")/shutdown_test.py $SHUTDOWN_TIMEOUT"
    error_code=$?
    if [ $error_code -eq 0 ]
    then
      echo "[$(date)] : Proceeding with System Shutdown"
      shutdown -h now
    else
      echo "[$(date)] : Shutdown has been canceled. Autocode will exit."
    fi
  else
    if zenity --question --timeout $SHUTDOWN_TIMEOUT --default-cancel \
      --width=550 --text="Autocode has completed execution. Do you want to shutdown the computer now?\n\nIf no option is selected Autocode will automatically shutdown the system in $SHUTDOWN_TIMEOUT seconds"; then
      echo "[$(date)] : Proceeding with System Shutdown"
      shutdown -h now
    else
      echo "[$(date)] : Shutdown has been canceled. Autocode will exit."
      zenity --info --text="Shutdown canceled\!"
    fi
  fi
}

echo "Working in $WORK_DIR"
echo "$(date)|Autocode Is Starting" >> "$WORK_DIR/encode-activity.log"
#Start a timer
start=$SECONDS
echo "[$(date)] : Will run for the next $MAX_HOURS hours"
# Do any necessary pre-processing
PreProcess
hours=0
while [ $hours -lt "$MAX_HOURS" ]
do
  echo "[$(date)] : $hours elapsed so far. Encoding some more..."
  Get-Next-File
  file=$CURRENT_FILE
  if [ -z "$file" ]
    then
      echo "[$(date)] : Nothing more to process!!"
      hours=$MAX_HOURS
    else
      Encode-File "$file" "$hours"
      hours=$(((SECONDS-start)/3600))
      echo "[$(date)] : Autocode has been running for $hours hours"
  fi
done
echo "$(date)|Autocode Is Exiting" >> "$WORK_DIR/encode-activity.log"
Determine-Shutdown

