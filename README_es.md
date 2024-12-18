## Docker-OpenVPN-simple

Un contenedor simple con OpenVpn y Debian, listo para crear certificados y conectar tus clientes, con la posibilidad de modificar fácilmente cualquier configuración. 

* [Docker Hub](https://hub.docker.com/r/tmpjg/docker-openvpn-simple)
* [Docs in english](./README.md)

## Requisitos

* Docker funcionando y corriendo: Ver [Docker website](http://www.docker.io/gettingstarted/#h_installation)

* Configuracion de Red: 
    - Para habilitar el reenvío de IP en Linux y permitir que el tráfico de la VPN se enrute correctamente:
        1. **Verificar el estado del reenvío de IP:**
        ```bash
            sysctl net.ipv4.ip_forward
        ```

        2. **Habilitar temporalmente el reenvío de IP:**
        ```bash
            echo 1 > /proc/sys/net/ip_forward
        ```

        3. **Habilitar permanentemente:**
        Edita `/etc/sysctl.conf` y agrega o asegúrate de que la línea siguiente esté descomentada:
        ```bash
            net.ipv4.ip_forward = 1
        ```
        4. Luego aplica los cambios:
        ```bash
            sysctl -p
        ```
        Este ajuste es necesario para que el tráfico de la VPN pueda ser reenviado hacia otras redes o a Internet.
* Configuración de Iptables para OpenVPN
    - **Permitir tráfico de la VPN hacia la red externa:**
        Ejecuta las siguientes reglas para permitir el tráfico entre la red VPN (`tun0`) y la red externa (`eth0`):
        ```bash
            iptables -A FORWARD -i tun0 -o eth0 -j ACCEPT
            iptables -A FORWARD -i eth0 -o tun0 -m state --state RELATED,ESTABLISHED -j ACCEPT
        ```
    - **Configurar NAT (enmascaramiento) para la VPN:**
        Usa la siguiente regla para enmascarar el tráfico de la VPN (`variable OPENVPN_SERVER_IP`) para que salga con la IP del servidor:
       ```bash
            iptables -t nat -A POSTROUTING -s <rango_ip_server_vpn/24> -o eth0 -j MASQUERADE
        ```
    - **Persistencia en las reglas**
        Al reiniciar el servidor estas reglas se perderan, suguiero seguir [alguna guia para hacer las reglas persistentes de iptables a nivel host](https://www.cyberciti.biz/faq/how-to-save-iptables-firewall-rules-permanently-on-linux/)

    ***Nota Importante**: Esta configuración de iptables es para que el trafico salga con la ip del host a la red. Para cosas mas complejas hay mejores tutoriales en internet ;)*

### Proxmox (LXC)

Para correr este contenedor en un CT de Proxmox (LXC) es necesario seguir primero esta [guía para que el contenedor pueda acceder al `/dev/net/tun`](https://pve.proxmox.com/wiki/OpenVPN_in_LXC) y utilizar el [docker-compose-proxmox.yml](./docker-compose-proxmox.yml). 


## Primer inicio

Pasos para iniciar el contenedor con `docker compose` por primera ves:

1. Crear archivo [docker-compose.yml](./docker-compose.yml) en por ejemplo `/opt/openvpn`
2. Ejecutar el comando `docker compose run --rm openvpn-simple openvpn_init`
3. Iniciar el contenedor: `docker compose up -d`

## Crear Certificados para clientes

Ejecutar: `docker compose run --rm -e CLIENTNAME="<NOMBRE_CLIENTE>" openvpn-simple openvpn_client_add nopass` 

Para utilizar contraseña en el certificado del cliente, debemos quitar la opcion `nopass`: 
`docker compose run --rm -e CLIENTNAME="<NOMBRE_CLIENTE>" openvpn-simple openvpn_client_add`


## Variables (solamente las útiles el resto pueden verse en el [Dockerfile](./Dockerfile))

|Variable|Ejemplo|Descripción|
|--------|-------|-----------|
|OPENVPN_CN|"${var.environment}-${var.name}"|Common Name de certificados VPN|
|OPENVPN_REMOTE|3.4.5.6/vpn.example.com|Dirección remota para que los clientes se conecten a la VPN|
|OPENVPN_REMOTE_PORT|1194|Puerto remoto para que los clientes se conecten a la VPN|
|OPENVPN_SERVER_IP|"192.168.255.0 255.255.255.0"|rango ip de la VPN|
|EASYRSA_CRL_DAYS|3650|Expiración de certificado|
|EASYRSA_CERT_EXPIRE|3650|Expiración de certificado|
|EASYRSA_CA_EXPIRE|3650|Expiración de certificado|
|EASYRSA_REQ_COUNTRY|AR|Información de certificado|
|EASYRSA_REQ_PROVINCE|"Buenos Aires"|"Información de certificado"|
|EASYRSA_REQ_CITY|Moron|Información de certificado|
|EASYRSA_REQ_ORG|Example|Información de certificado|
|EASYRSA_REQ_EMAIL|"admin@example.com"|Información de certificado|
