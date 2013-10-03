#!/bin/bash

TEMPFILE=`mktemp`

ss -ant > $TEMPFILE

grep SYN-RECV $TEMPFILE | awk '{ print $5 }' | cut -f1 -d: | perl /opt/asn/asn_ip_analysis.pl

rm -f $TEMPFILE
