#!/bin/bash  

cities=$@
zoneinfo=/usr/share/zoneinfo/right
format='%I:%M %p'

# Print current date
echo -e "\${font Open Sans:bold:size=10}${color2}$(date +"%a %d %b %Y\${alignr}wk.%U d.%j")"
# Then print all timezones
for city in ${cities[@]}; do
    find $zoneinfo -type f,l | grep -i "$city" | while read z; do
		city_name=${z##*/}
		city_name_clean=${city_name/_/ }
        echo -e "\${font Open Sans:bold:size=8.5}$city_name_clean\${alignc}\${font Open Sans:size=8.5}$(TZ=$z date +"$format")"
    done
done | sort
echo -e "\${voffset -100}\${font Roboto:bold:size=30}\${alignr}$(date +"%I:%M")"
echo -e "\${voffset -20} \${font Roboto:size=30}\${alignr}$(date +"%p")"
