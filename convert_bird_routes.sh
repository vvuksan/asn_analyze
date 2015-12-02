#!/bin/bash

# First do birdc show route all and dump it into file called bird_routes.txt
grep ^[1-9] bird_routes.txt  | awk '{ print $12","$1 }' | sed "s/^\[//g" | sed "s/i\]//g" > routes.txt
perl bulk_ip2long_convert.pl | sort -n | sed "s/ /,/g" > ip_long_list.txt
