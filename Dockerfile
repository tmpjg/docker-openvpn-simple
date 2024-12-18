FROM debian:12-slim

RUN apt-get update && apt-get install -y \
    gettext-base \
    openvpn \
    openvpn-auth-ldap \
    easy-rsa \
    iptables \
    && rm -rf /var/lib/apt/lists/*

# openvpn-conf 
VOLUME ["/etc/openvpn"]

ENV OPENVPN_PATH=/etc/openvpn
ENV OPENVPN_TEMPLATES=$OPENVPN_PATH/templates
ENV OPENVPN_CLIENTS_DIR=$OPENVPN_PATH/clients-configs
ENV OPENVPN_SERVER_CONF=$OPENVPN_PATH/server.conf
ENV OPENVPN_CLIENT_CONF_DIR=$OPENVPN_PATH/ccd
ENV OPENVPN_CN="default"
ENV OPENVPN_REMOTE="127.0.0.1"
ENV OPENVPN_REMOTE_PORT="1194"

EXPOSE 1194/udp

# openvpn logrotate
COPY configs/logrotate-openvpn /etc/logrotate.d/openvpn

# easy-rsa pki
ENV EASYRSA_PKI=$OPENVPN_PATH/pki
ENV EASYRSA_CRL_DAYS=3650
ENV EASYRSA_CERT_EXPIRE=3650
ENV EASYRSA_CA_EXPIRE=3650
ENV EASYRSA_REQ_COUNTRY=AR
ENV EASYRSA_REQ_PROVINCE="Buenos Aires"
ENV EASYRSA_REQ_CITY=Moron
ENV EASYRSA_REQ_ORG=Moron
ENV EASYRSA_REQ_EMAIL=admin@example.com

# scripts 
COPY scripts /scripts
RUN chmod +x /scripts/*

# templates 
COPY templates /templates

# bin 
COPY bin /openvpn-bin
ENV PATH="${PATH}:/openvpn-bin/"
RUN chmod +x /openvpn-bin/*

WORKDIR /etc/openvpn 

CMD [ "openvpn_run" ]
