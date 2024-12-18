client
nobind
dev tun
allow-compression yes
remote-cert-tls server
remote $OPENVPN_REMOTE $OPENVPN_REMOTE_PORT udp

<key>
$CN_KEY
</key>
<cert>
$CN_CRT
</cert>
<ca>
$CA
</ca>
key-direction 1
<tls-auth>
$TA
</tls-auth>

