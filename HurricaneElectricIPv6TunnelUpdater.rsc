# Update Hurricane Electric IPv6 Tunnel Client IPv4 address

# ==============================================================================
# EDIT YOUR DETAILS / CONFIGURATION HERE
# ==============================================================================
:local HETunnelIface "sit1"
:local HEWanIface "ether1-gateway"
:local HETunnelId "tunnel-id"
:local HEUserId "user-id"
:local HEPassMD5 "md5-password"
# ==============================================================================
# END OF USER DEFINED CONFIGURATION
# ==============================================================================

# Internal processing below...
:local HEUpdateHost "ipv4.tunnelbroker.net"
:local HEUpdatePath "/ipv4_end.php"
:local HEOutputFile ("HE-" . $HETunnelId . ".txt")
:local HELogHeader "[HE IPv6 Tunnel] "
:local HEIpv4Addr "0.0.0.0"

# Get WAN interface IP address
:set HEIpv4Addr [/ip address get [/ip address find interface=$HEWanIface] address]
:set HEIpv4Addr [:pick [:tostr $HEIpv4Addr] 0 [:find [:tostr $HEIpv4Addr] "/"]]

:if ([:len $HEIpv4Addr] = 0) do={
    :log error ($HELogHeader . "Could not get IP for interface " . $HEWanIface)
    :error ($HELogHeader . "Could not get IP for interface " . $HEWanIface)
}

# Update the HETunnelIface with WAN IP
/interface 6to4 {
    :if ([get ($HETunnelIface) local-address] != $HEIpv4Addr) do={
        :log info ($HELogHeader . "Updating " . $HETunnelIface . " local-address with new IP " . $HEIpv4Addr . "...")
        set ($HETunnelIface) local-address=$HEIpv4Addr
    } else={
        :log info ($HELogHeader . "Tunnel address already set to " . $HEIpv4Addr)
        :error ($HELogHeader . "Tunnel address already set to " . $HEIpv4Addr)
   }
}

:log info ($HELogHeader . "Updating IPv6 Tunnel " . $HETunnelId . " Client IPv4 address to new IP " . $HEIpv4Addr . "...")
/tool fetch mode=http \
                  host=($HEUpdateHost) \
                  url=("http://" . $HEUpdateHost . $HEUpdatePath . \
                          "?ipv4b=" . $HEIpv4Addr . \
                          "&pass=" . $HEPassMD5 . \
                          "&user_id=" . $HEUserId . \
                          "&tunnel_id=" . $HETunnelId) \
                  dst-path=($HEOutputFile)

:log info ($HELogHeader . [/file get ($HEOutputFile) contents])
/file remove ($HEOutputFile)

# ==============================================================================
# END OF SCRIPT
# ==============================================================================

