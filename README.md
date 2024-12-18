Here's the translation of the text you provided:

---

## Docker-OpenVPN-Simple

A simple container with OpenVPN and Debian, ready to create certificates and connect your clients, with easy configuration modifications available.

* [Docker Hub](https://hub.docker.com/r/tmpjg/docker-openvpn-simple)
* [Documentación en español](./README_es.md)

## Requirements

* Docker running: Check on the [Docker website](http://www.docker.io/gettingstarted/#h_installation)

* Network Configuration:
  - To enable IP forwarding on Linux and allow VPN traffic to be routed correctly:
    1. **Check the IP forwarding status:**
      ```bash
          sysctl net.ipv4.ip_forward
      ```

    2. **Temporarily enable IP forwarding:**
      ```bash
          echo 1 > /proc/sys/net/ip_forward
      ```

    3. **Make it permanent:**
      Edit `/etc/sysctl.conf` and make sure the following line is uncommented:
      ```bash
          net.ipv4.ip_forward = 1
      ```
    4. Then apply the changes:
      ```bash
          sysctl -p
      ```
    This adjustment is necessary for the VPN traffic to be routed towards other networks or the Internet.

* OpenVPN `iptables` Configuration
  - **Allow VPN traffic to external network:**
    Run the following rules to allow traffic between the VPN network (`tun0`) and the external network (`eth0`):
    ```bash
        iptables -A FORWARD -i tun0 -o eth0 -j ACCEPT
        iptables -A FORWARD -i eth0 -o tun0 -m state --state RELATED,ESTABLISHED -j ACCEPT
    ```
  - **Configure NAT (masquerading) for VPN traffic:**
    Use the following rule to masquerade the VPN traffic (variable OPENVPN_SERVER_IP) to use the server's IP:
    ```bash
        iptables -t nat -A POSTROUTING -s <ip_range_server_openvpn/24> -o eth0 -j MASQUERADE
    ```

    ***Important Note**:This `iptables` configuration allows traffic to exit with the host's IP. For more complex setups, there are better tutorials available online ;)** 

### Proxmox (LXC)

To run this container in a Proxmox CT, you need to follow this [guide to allow the container to access `/dev/net/tun`](https://pve.proxmox.com/wiki/OpenVPN_in_LXC) and use the [docker-compose-proxmox.yml](./docker-compose-proxmox.yml).

## Initial Setup

Steps to start the container with `docker compose` for the first time:

1. Create the [docker-compose.yml](./docker-compose.yml) file in, for example, `/opt/openvpn`.
2. Run `docker compose run --rm openvpn-simple openvpn_init`.
3. Start the container: `docker compose up -d`.

## Creating Client Certificates

Run: `docker compose run --rm -e CLIENTNAME="<CLIENT_NAME>" openvpn-simple openvpn_client_add nopass`

To use a password in the client certificate, remove the `nopass` option:
`docker compose run --rm -e CLIENTNAME="<CLIENT_NAME>" openvpn-simple openvpn_client_add`

## Variables (only the useful ones, the rest can be viewed in the [Dockerfile](./Dockerfile))

|Variable|Example|Description|
|--------|-------|-----------|
|OPENVPN_CN|"${var.environment}-${var.name}"|VPN Certificate Common Name|
|OPENVPN_REMOTE|3.4.5.6/vpn.example.com|Remote address for client connections to the VPN|
|OPENVPN_REMOTE_PORT|1194|Remote port for client connections to the VPN|
|OPENVPN_SERVER_IP|"192.168.255.0 255.255.255.0"|VPN IP range|
|EASYRSA_CRL_DAYS|3650|Certificate expiration|
|EASYRSA_CERT_EXPIRE|3650|Certificate expiration|
|EASYRSA_CA_EXPIRE|3650|Certificate authority expiration|
|EASYRSA_REQ_COUNTRY|AR|Certificate information|
|EASYRSA_REQ_PROVINCE|"Buenos Aires"|"Certificate information"|
|EASYRSA_REQ_CITY|Moron|Certificate information|
|EASYRSA_REQ_ORG|Example|Certificate information|
|EASYRSA_REQ_EMAIL|"admin@example.com"|Certificate information|

---

*(Translated with ChatGPT)*
