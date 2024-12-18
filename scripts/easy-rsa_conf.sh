#!/bin/sh

#
# Configure certs for OpenVPN
#

echo "######## INSTALLING AND CONFIGURING CERTS ########"

if [ -d $EASYRSA_PKI ]
then
    echo "ERROR: Certificates already exists!!!"
    exit 1
fi

# https://community.openvpn.net/openvpn/wiki/EasyRSA3-OpenVPN-Howto#PKIprocedure:ProducingyourcompletePKIontheCAmachine
# /usr/share/easy-rsa/
# https://github.com/OpenVPN/easy-rsa/blob/master/doc/EasyRSA-Advanced.md

# EASYRSA_PKI (CLI: --pki-dir) - directory to hold all PKI-specific files, defaults to $PWD/pki.
cd /usr/share/easy-rsa/

# Initialize PKI 
# The command `./easyrsa init-pki` is used to initialize the Public Key Infrastructure (PKI) 
# when using the EasyRSA tool to configure and manage your own Certificate Authority (CA).

./easyrsa init-pki 

# Generate vars
# Script to generate the vars file with certificate details

if [ -z "$EASYRSA_REQ_OU" ]
then
    export EASYRSA_REQ_OU=$OPENVPN_CN
fi 

cat /templates/easy-rsa_vars.tpl | envsubst > $EASYRSA_PKI/vars

# Create CA 
# The command `./easyrsa --batch --req-cn="host.host.host" build-ca nopass` is used to create 
# a Certificate Authority (CA).

./easyrsa --batch --req-cn=$OPENVPN_CN build-ca nopass

# Build Server Certificate
# The command builds a complete server certificate. 
# This includes generating a private key, a Certificate Signing Request (CSR), 
# and having the CA sign the CSR to produce a complete certificate.

./easyrsa --batch build-server-full $OPENVPN_CN nopass
 
# Build Client Certificate
# Build a complete certificate for a client. 
# This includes generating a private key for the client, 
# creating a Certificate Signing Request (CSR), and signing the CSR 
# by the Certificate Authority to produce a complete certificate.

# ./easyrsa --batch build-client-full test_user nopass

#### Generate a strong Diffie-Hellman key to use during key exchange.
# The `easyrsa gen-dh` command is used to generate Diffie-Hellman (DH) key exchange parameters 
# using the EasyRSA tool. Diffie-Hellman is a cryptographic protocol used for secure key exchange 
# in a public network, essential for the security of VPN connections like OpenVPN.

./easyrsa gen-dh

# Generate the tls-crypt pre-shared key.
# The ta.key is a TLS (Transport Layer Security) authentication key file 
# used in OpenVPN to enhance the security of the VPN connection. 
# This file is used to sign all data packets sent between the client and the server, 
# ensuring the authenticity and integrity of the communication.

openvpn --genkey secret $EASYRSA_PKI/ta.key

# Generate the CRL for client/server certificate revocation.
# A CRL is a list containing information about certificates that have been revoked 
# before their normal expiration date.

./easyrsa gen-crl

echo "#### OK INSTALL AND CONFIGURE CERTS ####"
echo ""
