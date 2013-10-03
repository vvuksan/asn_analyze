#!/usr/bin/perl

#################################################################
# Converts a file called routes.txt to 
#################################################################

use lib "./";
require 'config.pm'; 
require 'tools.pm';

open(ASN_LIST, "< ./routes.txt");

my %asn;

while(<ASN_LIST>)
{
  chop;
  my ($as, $ip_prefix) = split /,/;
  
  $as =~ m/\[AS(\d+)(.*)/;
  $substr = $1;
  print "$substr," . ip2long($ip_prefix) ."\n";  
  
}

close(ASN_LIST);
  
