asn_analyze
===========

This set of tools intends to aid in identifying patterns of access by converting
IP addresses into AS Numbers (http://en.wikipedia.org/wiki/AS_number). These are 
often way more informative than looking at individual IP prefixes. Especially
since some large providers can have thousands of different IP prefixes. Included are 
two scripts

1. asn_ip_analysis.pl

This script expects just a list of IPs separated by a new line. It will give you
a break down of IPs. For example you can use it to troubleshoot network issues ie.
you notice large number of connections sitting in SYN-RECV state. You could run 
something like this

$ ss -ant | grep SYN-RECV | awk '{ print $5 }' | cut -f1 -d:  | perl asn_ip_analysis.pl 
Top  ASes

 \#          ASN
    1170 http://bgp.he.net/AS7657	 NZ = VODAFONE-NZ-NGN-AS Vodafone NZ Ltd.
       2 http://bgp.he.net/AS4771	 NZ = NZTELECOM Telecom New Zealand Ltd.\

Makes it pretty clear that something is happening with SYN-ACKs going to Vodafone.

You could also analyze your web logs to see where most of your customers are coming from
e.g.

# cut -f1 -d" " access.log | perl /opt/asn/asn_ip_analysis.pl 
............................
You supplied 28646 IPs. Showing top 40 ASNs

 \# IPs            ASN
      331569    http://bgp.he.net/AS7922   US = COMCAST-7922 - Comcast Cable Communications
      290686     http://bgp.he.net/AS786   GB = JANET The JNT Association
      215274   http://bgp.he.net/AS15169   US = GOOGLE - Google Inc.
      134660    http://bgp.he.net/AS2856   GB = BT-UK-AS BTnet UK Regional network
      132031    http://bgp.he.net/AS7018   US = ATT-INTERNET4 - AT&T Services
       98942    http://bgp.he.net/AS1213   IE = HEANET HEAnet Limited
       98017     http://bgp.he.net/AS701   US = UUNET - MCI Communications Services
       87109    http://bgp.he.net/AS5089   GB = NTL Virgin Media Limited
       75678    http://bgp.he.net/AS3352   ES = TELEFONICA-DATA-ESPANA TELEFONICA DE ESPANA
.......


2. varnish_asn_breakdown.pl

This script is used to sample traffic going through varnish. This is intended for situations
where your machines are multi-homed and you want to make sure links are used properly
overused. It is similar to asn_ip_analysis however it does couple additional things

a) Uses payload information - bytes sent and sorts ASNs to which you send most traffic to
b) Shows a sample IP so you could look up routing policy if you desire
c) Shows which hop/router traffic is gonna go out of
d) It requires no arguments. It uses varnishncsa to get data



