#!/bin/bash

# Get route list but running sudo birdc show route > routes_bird.txt
egrep ^[0-9] routes_bird.txt | sed "s/via.*\[AS/AS/g" | grep -v via | sed "s/i\]//g" | awk '{ print $2","$1 }' |  pv > routes.txt

perl bulk_ip2long_convert.pl | sort -n | sed "s/ /,/g" > ip_long_list.txt