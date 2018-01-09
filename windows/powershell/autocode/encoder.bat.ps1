#HANDBRAKE Location
$HANDBRAKE = "C:\Program Files\Handbrake\HandBrakeCLI.exe";

#MAX Hours to run
$MAX_HOURS = 14

#Set working directory
cd work;


function Decide-Shutdown {
	#http://msdn.microsoft.com/en-us/library/x83z1d9f(v=vs.84).aspx

	$a = new-object -comobject wscript.shell 
	$intAnswer = $a.popup("Do you want to abort Windows shutdown?", 15,"Confirm Abort", 1) #first number is timeout, second is display.
	$intAnswer
	if (-Not ($intAnswer -eq 1)) { 
		write-host "Windows will shutdown in 1 minute"
		shutdown /s /t 60
	} else {
		write-host "Shutdown Aborted..."
	}
}

function Encode($file) {
	#// Add the file to the execution log
	$new_entry = "$(get-date -format g)|$hours|$file"
	Add-Content "H:\staging\autocode\encode-history.log" $new_entry

	#// Create output file
	$output_file = ".\encoded\"+ $file;

	#// Proclaim intent
	write-host "Encoding " + $file + " to " + $output_file;

	#Handbrake Command Line
	$hb_cli = $HANDBRAKE + " -i $file -t 1 --angle 1 -c 1 -o $output_file  -f mp4  --detelecine -w 640 --crop 0:0:0:0 --loose-anamorphic  --modulus 2 -e x264 -q 22 -r 30 --pfr -a none  --audio-fallback ac3 --markers=""C:\Users\sheld\AppData\Local\Temp\199 032516 333 459-1-1-chapters.csv"" --encoder-preset=veryslow  --encoder-tune=""film""  --encoder-level=""3.1""  --encoder-profile=high  --verbose=1"

	#// Execute action
	&$HANDBRAKE -i $file -t 1 --angle 1 -c 1 -o $output_file  -f mp4  --detelecine -w 640 --crop 0:0:0:0 --loose-anamorphic  --modulus 2 -e x264 -q 22 -r 30 --pfr -a none  --audio-fallback ac3 --markers="C:\Users\sheld\AppData\Local\Temp\199 032516 333 459-1-1-chapters.csv" --encoder-preset=veryslow  --encoder-tune="film"  --encoder-level="3.1"  --encoder-profile=high  --verbose=1

	#// Delete the file
	#rm $file
	sleep 5
}

function Get-Next-File {
	#// Get execution history
	$work_log = Get-Content "H:\staging\autocode\encode-history.log"
	
	#// initialize the blank file
	$file_to_process = ""
	
	#// Select the largest file that has not been processed
	gci | where { ! $_.PSIsContainer } | Sort-Object Length -descending | 
	Foreach-Object {
		$file = $_.Name
		
		if ($file_to_process -eq "") {
			Write-Host "Evaluating" + $file
			#$file_processed = $work_log | %{$_ -match $file}
			$Sel = select-string -pattern $file -SimpleMatch -Quiet -path "H:\staging\autocode\encode-history.log" 
			
			If($Sel -eq $true) {
				Write-Host $file + " has been processed. Skipping this file."
			} else {
				Write-Host $file + " has not been processed. This file will be chosen for encoding."
				$file_to_process = $file
			}
		}
	}
	return $file_to_process
}


#start timer
$elapsed = [System.Diagnostics.Stopwatch]::StartNew()
$start = $(get-date)
write-host "Started at $start. Will run for the next $MAX_HOURS hours"

$hours = 0
#Encode for the next 10 hours!
while ($hours -lt $MAX_HOURS) {
	write-host "$hours elapsed so far. Encoding some more..."
	$file = Get-Next-File
	if (-Not ($file -eq "")) {
		Encode $file
		$hours = $($elapsed.get_ElapsedMilliseconds()) / 3600000
	} else {
		Write-Host "Nothing to process!"
		#// Simulate the exit condition
		$hours = $MAX_HOURS
	}
}

write-host "Ended at $(get-date)"
write-host "Total Elapsed Time: $($elapsed.Elapsed.ToString())"

Decide-Shutdown