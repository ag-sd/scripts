#BING DeskTop
$BING = "BingDesktop";

#sleep 3 minutes to ensure system has started and all is good
write-host "Will begin dinging in ... "
for($i=3; $i -gt 0; $i--) {
	write-host $i;
	sleep 60;
}

$bing_process = Get-Process $BING -ErrorAction SilentlyContinue

if($bing_process) {
	write-host "Bing Found " + $bing_process
	
	# try gracefully first
	$bing_process.CloseMainWindow()
	# kill after five seconds
	Sleep 5
	if (!$bing_process.HasExited) {
		write-host "Force quit " + $bing_process
		$bing_process | Stop-Process -Force
	}
	
	write-host "Bing was dinged "
} else{
	write-host "Bing was not found "
}

sleep 3