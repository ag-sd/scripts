#!/bin/bash

#
# Returns a list of the harddisks, in a conky-style configuration.
#

avalable_mounts=`lsblk | awk 'NR > 1 { print $7 }' | sort | uniq | tail -n +2`

for mount in $avalable_mounts; do
    echo "\${font Open Sans:bold:size=8.5}${mount/\/mnt\//} \$font\$alignr \${fs_type $mount}"
    echo "\${fs_used $mount} / \${fs_size $mount} \$alignr \${fs_used_perc $mount} %" 
    echo "\${fs_bar $mount}"
done

