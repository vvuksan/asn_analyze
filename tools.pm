#!/usr/bin/perl

use Socket;
use Data::Dumper;
$|=1;

########################################################################
#converts an IP address x.x.x.x into a long IP number
########################################################################
sub ip2long {
	
	my $ip_address = shift;
	
	my (@octets,$octet,$ip_number,$number_convert);
	
	chomp ($ip_address);
	@octets = split(/\./, $ip_address);
	$ip_number = 0;
	foreach $octet (@octets) {
		$ip_number <<= 8;
		$ip_number |= $octet;
	}
	return $ip_number;
}


sub long2ip {
    return inet_ntoa(pack("N*", shift));
}

########################################################################
# Returns AS org name and country. Requires 
# $asn  = AS number as AS12345
# $asn_mapping_file = local CSV mapping file
########################################################################
sub find_asn_org_name {

    my $asn = shift;
    my $asn_mapping_file = shift; 

    $as_output = `dig +short $asn.asn.cymru.com TXT`;

    my $return_string ;
    chop($as_output);

    if ( $as_output =~ m/\"(\d+)(.*)(\w{2}) \| (\w+) \|(.*)\| (.*)\"/ ) {
      #open (MYFILE, ">>$asn_mapping_file");
      #print MYFILE "AS$1,$3,$6\n";
      $return_string = "$3 = $6";
      #close (MYFILE);
    } else {
      $return_string = "UNKNOWN";
    }
    
    return $return_string;

}

1;
