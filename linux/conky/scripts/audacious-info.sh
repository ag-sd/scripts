#!/bin/bash

#
# Returns Audacious information.
#

 title=$(audtool --current-song)
 second=$(date +%S)
 if [ ${#title} -ge 60 ] 
 then 
	trim="${title:$second}"
 else
	trim="$title"
 fi

 if [ -z "$trim" ]
 then
    trim="..."
 fi
 echo ""
 echo "\${font Open Sans:Bold:size=10}\${color0}Audacious:\${audacious_status} (Track:\${audacious_playlist_position}/\${audacious_playlist_length})\${color1}\${hr 2}\$color\$font"
 echo "\${font Open Sans:size=8}\${color6}$trim"
 echo "\${audacious_bar 4}"
 echo "\${voffset -3}\${audacious_position}\$alignr\${audacious_length}"
 echo ""
