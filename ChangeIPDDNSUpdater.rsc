# ChangeIP.net DDNS Updater

# ==============================================================================
# EDIT YOUR DETAILS / CONFIGURATION HERE
# ==============================================================================
:local ddnsuser "changeipnetuser"
:local ddnspass "changeipnetpass"
:local ddnshost "changeipnethost.changeipdomain.net"
:local ddnsiface "ether1-gateway"
# ==============================================================================
# END OF USER DEFINED CONFIGURATION
# ==============================================================================

:local ddnsip [ /ip address get [ /ip address find interface=$ddnsiface ] address ]
:set ddnsip [ :pick "$ddnsip" 0 ( [ :len $ddnsip ] - 3 ) ]
:local ddnslastip [ :resolve $ddnshost ]

:if ([:len [/interface find name=$ddnsiface]] = 0 ) do={

    :log error ( "DDNS: No interface named " . $ddnsiface . ", please check configuration." )

} else={

    :if ([:typeof $ddnslastip] = "nil") do={

        :set ddnslastip "0.0.0.0"

    }

    :if ([:typeof $ddnsip] = "nothing") do={

        :log info ( "DDNS: No IP address present on " . $ddnsiface . ", please check." )

    } else={

        :if ($ddnsip != $ddnslastip) do={

            :log info ( "DDNS: Sending UPDATE (LAST=" . $ddnslastip . " CURR=" . $ddnsip . ")." )
            :put [ /tool dns-update name=$ddnshost address=[ :pick $ddnsip 0 [ :find $ddnsip "/" ] ] key-name=$ddnsuser key=$ddnspass ]
            /system script run ipsec_policy_update

        } else={

            :log info ( "DDNS: No changes necessary (LAST=" . $ddnslastip . " CURR=" . $ddnsip . ")." )

        }

    }
}

# ==============================================================================
# END OF SCRIPT
# ==============================================================================

