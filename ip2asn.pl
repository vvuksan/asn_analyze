#!/usr/bin/perl -W
$|=1;
#################################################################
# Author: vvuksan
#################################################################
use Data::Dumper;
use Socket;
use lib "./";
require 'config.pm'; 
require 'tools.pm';

# Stick ASN mapping into a hash
open(ASN_LIST, "< $CFG{'asn_mapping_file'}");

my %asn;

while(<ASN_LIST>)
{
  chop;
  my ($as, $country, $description) = split /,/;
  
  $asn{"$as"} = "$country = $description";
  
}

close(ASN_LIST);


my %longip2asn;

open(IP2LONG, "< $CFG{'long_ip_to_asn_file'}");

while(<IP2LONG>)
{
  chop;
  my ($longip, $as) = split /,/;
  
  $longip2asn{$longip} = $as;
  
}

close(IP2LONG);

my $ip = $ARGV[0];

# We really only care for /24
my ( $part1, $part2, $part3, undef ) = split /\./, $ip;	  
my $slash24 = "${part1}.${part2}.${part3}.0";

my $ip_value = ip2long($slash24);

for ($i=8; $i<32; $i++) {
$ip2 = ($ip_value >> $i) << $i;
    if ( $longip2asn{$ip2} ) {
        $key = "AS" . $longip2asn{$ip2};
        #$ip2asn{$slash24} = $asn;
        last;
    }
}

$asn{$key} = find_asn_org_name($key ,$CFG{'asn_mapping_file'});
  
printf "IP=%s  %25s   %s\n", $ip, "http://bgp.he.net/$key", $asn{$key};
  

exit 0;
