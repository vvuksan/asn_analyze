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

my %per_ip_totals;
my %totals;

#####################################################################################
# We'll loop through a list of IPs and get their sum
#####################################################################################    
while ( <STDIN> ) {

  chop;
  $per_ip_totals{$_}++;

}


my %ip2asn;
my $ip_counter = 0;

############################################################################
# Determine AS Numbers for each IP
############################################################################
foreach my $ip ( keys %per_ip_totals ) {

    $ip_counter++;
    
    if ( $ip_counter % 1000 == 0 ) {
      print ".";
    }
    # We really only care for /24
    my ( $part1, $part2, $part3, undef ) = split /\./, $ip;	  
    my $slash24 = "${part1}.${part2}.${part3}.0";
    
    my $result = 'UNKNOWN';
    # Check do we already have mapping for the ASN
    if ( $ip2asn{$slash24} ) {
      
      $asn = $ip2asn{$slash24};

    } else {
      # Calculate
      my $ip_value = ip2long($slash24);
   
      for ($i=8; $i<32; $i++) {
	$ip2 = ($ip_value >> $i) << $i;
	if ( $longip2asn{$ip2} ) {
	  $asn = $longip2asn{$ip2};
	  $ip2asn{$slash24} = $asn;
	  last;
	} else {
	  $ip2asn{$slash24} = "none";
	}
      }
    
    }
    
    $totals{"AS$asn"} += $per_ip_totals{$ip};
    
}

my $show_top_entries = 40;
my $counter = 0;

print "\nYou supplied " . keys(%per_ip_totals) . " IPs. Showing top " . $show_top_entries . " ASNs\n";

print "\n # IPs            ASN\n";

foreach $key (sort { $totals{$b} <=> $totals{$a} } keys %totals) {

  if ( !  $asn{$key} ) {
     $asn{$key} = find_asn_org_name($key ,$CFG{'asn_mapping_file'});
  } 
  
  printf "%12d   %25s   %s\n", $totals{$key}, "http://bgp.he.net/$key", $asn{$key};
  
  if ( $counter > $show_top_entries ) {
    last;
  } else {
    $counter++;
  }

  
}

exit 0;
