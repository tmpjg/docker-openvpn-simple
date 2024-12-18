#!/bin/sh

#
# gen config openvpn
#

echo "######## CONF OPENVPN ########"

if [ -f $OPENVPN_SERVER_CONF ]
then
    echo "ERROR: Openvpn config exists!!!"
    exit 1
fi

if [ -z $OPENVPN_SERVER_IP ]
then
    export OPENVPN_SERVER_IP="192.168.255.0 255.255.255.0"
fi

# Folder for clients conf certs
echo "creating folder ccd"
mkdir -p $OPENVPN_CLIENT_CONF_DIR

# Folder for user certs
echo "creating folder clients dir"
mkdir -p $OPENVPN_CLIENTS_DIR

# Generate openvpn-server.conf 
echo "creating server conf" 
cat /templates/openvpn-server.conf.tpl | envsubst > $OPENVPN_SERVER_CONF

# Create openvpn templates 
mkdir -p $OPENVPN_TEMPLATES
echo "cp templates"
cp /templates/openvpn-client.ovpn.tpl $OPENVPN_TEMPLATES/openvpn-client.ovpn.tpl

echo "######## OK CONF OPENVPN ########"
