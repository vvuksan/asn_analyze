#!/usr/bin/perl -W
$|=1;
#################################################################
# Author: vvuksan
# Script to query varnish
#################################################################
use Getopt::Long;
use lib "./";
require 'config.pm'; 
require 'tools.pm';

print "Starting up. Please wait ....\n\n";

# Stick ASN descriptive mapping into a hash
open(ASN_LIST, "< $CFG{'asn_mapping_file'}");

my %asn;

while(<ASN_LIST>)
{
  chop;
  my ($as, $country, $description) = split /,/;
  
  $asn{"$as"} = "$country = $description";
  
}

close(ASN_LIST);
  
my %totals;

my %per_ip_totals;
my %sample_ip;
my %ip2long;
my %ip2asn;

my $total_payload_size = 0;

open(IP2LONG, "< $CFG{'long_ip_to_asn_file'}");

while(<IP2LONG>)
{
  chop;
  my ($longip, $as) = split /,/;
  
  $longip2asn{$longip} = $as;
  
}

close(IP2LONG);

#####################################################################################
# Attach to varnishncsa get 10 seconds worth of data
#####################################################################################    
while ( 1 ) {

  open VARNISHLOG, "-|", "varnishncsa | grep -v ^127.0"
    or die "can't run varnishlog: $!";   
  print "Reading from varnishlog\n";
  my $t = time;

  my $start_time = time;
  
  my $end_time = time + 10;

  while ( <VARNISHLOG> ) {

    my ( $client_ip, undef, undef, undef, undef, undef, undef, undef, $resp_code, $payload_size ) = split / /;
    
    if ( $resp_code eq "200" && $payload_size =~ /^[+-]?\d+$/ && $payload_size > 0 ) {
    
      $total_payload_size += $payload_size;
      
      $per_ip_totals{$client_ip} += $payload_size;
    
    } # end of if ( $resp_code
    
    if ( $end_time == time && $t != time) {
      $t = time;
      close(VARNISHLOG);
      last;
    }
    
  } # end of VARNISHLOG loop
  

  print "Done reading. Processing " . keys(%per_ip_totals) . " IPs.\n";
    
  # Time difference between starting to poll and now
  my $time_diff = time - $start_time;
  
  print "Time diff is $time_diff seconds\n";
  my $show_top_number = 30;
  $counter = 1;

  $ip_counter = 0;
  
  ####################################################################
  # Now go through each IP collected and determine AS #
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
    
    $as_num = "AS$asn";
    $sample_ip{$as_num} = $ip;
    $totals{$as_num} += $per_ip_totals{$ip};

  }

  print "\nTop $show_top_number ASes\n\n  % bw       Sample IP     GW IP     ASN\n";
  
  foreach $key (sort { $totals{$b} <=> $totals{$a} } keys %totals) {
    my $pct = ( $totals{$key} / $total_payload_size ) * 100;

    if (! $asn{$key} ) {
      $asn{$key} = find_asn_org_name($key ,$CFG{'asn_mapping_file'});
    } 
    
    # Determine which upstream IP is being used for this IP range/ASN
    $gw = `ip r get $sample_ip{$key} | grep via | cut -f3 -d" "`;
    chop($gw);
    
    # If possible translate the IP to a descriptive name e.g. cogent, am13cog
    $gw = $peer_list{$gw}	  if exists $peer_list{$gw};
    
    # Output
    printf "%8.2f %15s %10s %7s  %s\n", $pct, $sample_ip{$key}, $gw, $key, $asn{$key};
    
    if ( $counter > $show_top_number ) {
      last;
    } else {
      $counter++;
    }
    
  }

  print "Doing another round please wait\n\n\n\n";
    
} # end of while(1);
        
exit 0;
