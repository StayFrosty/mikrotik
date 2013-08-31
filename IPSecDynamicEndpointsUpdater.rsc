# IPSec Peer/Policy Updater for Dynamic WAN addresses

# ==============================================================================
# CONFIGURATION START
# ==============================================================================
:local localfqdn "local.fqdn-or-ip.domain.tld"
:local remotefqdn "remote.fqdn-or-ip.domain.tld"
:local peertag "peer-comment"
:local policytag "policy-comment"
# ==============================================================================
# CONFIGURATION END
# ==============================================================================

/ip dns cache flush

:local localsite "0.0.0.0"
:local remotesite "0.0.0.0"

:if ( [ :tostr [ :toip $localfqdn ] ] != $localfqdn ) do={
    :set localsite [ :resolve $localfqdn ]
} else={
    :set localsite $localfqdn
}

:if ( [ :tostr [ :toip $remotefqdn ] ] != $remotefqdn ) do={
    :set remotesite [ :resolve $remotefqdn ]
} else={
    :set remotesite $remotefqdn
}

:log info ( "IPSec: setting local to ". $localsite ." and remote to ". $remotesite ."." )

/ip ipsec policy set [ /ip ipsec policy find comment="$policytag" ] sa-src-address=$localsite sa-dst-address=$remotesite
/ip ipsec peer set [ /ip ipsec peer find comment="$peertag" ] address="$remotesite/32"

# ==============================================================================
# END OF SCRIPT
# ==============================================================================