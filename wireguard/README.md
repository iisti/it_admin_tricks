# How to install and configure Wireguard VPN

## Linux Rocky 9 Server Install and configuration

* Source <https://docs.vultr.com/how-to-install-wireguard-vpn-on-rocky-linux-9>

~~~sh
##############
# Variables
##############

server_ip_public="x.y.z.w"
server_ip_private="10.0.75.1/24"
server_network_client="10.0.75.0/24"
server_port_vpn="443"
# 124.124.124.124/32 = some service or server
# 123.123.123.123/32 = some other service or server
client_allowed_ips="10.0.75.0/24,124.124.124.124/32,123.123.123.123/32"
# These are Hetzner DNS servers
dns_servers="193.47.99.5,88.198.229.192,213.133.100.98"

#################
# Installation
#################

sudo dnf install epel-release -y
sudo dnf install wireguard-tools -y
sudo dnf install firewalld -y
sudo wg --version

########################
# Server configuration
########################

wg genkey | sudo tee /etc/wireguard/server_private.key | wg pubkey | sudo tee /etc/wireguard/server_public.key
sudo chmod 600 /etc/wireguard/server_private.key /etc/wireguard/server_public.key

server_priv_key=$(sudo cat /etc/wireguard/server_private.key)
server_pub_key=$(sudo cat /etc/wireguard/server_public.key)

sudo tee -a /etc/wireguard/wg0.conf > /dev/null <<EOL
[Interface]
Address = ${server_ip_private}
SaveConfig = true
PrivateKey = ${server_priv_key}
ListenPort = ${server_port_vpn}
EOL

# Start, enable, and check status of WireGuard VPN service
sudo systemctl start wg-quick@wg0.service
sudo systemctl enable wg-quick@wg0.service
sudo systemctl status wg-quick@wg0.service

# Allow IP forward
echo 'net.ipv4.ip_forward = 1' | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

# Firewalld configuration
sudo systemctl status firewalld
sudo systemctl start firewalld
sudo firewall-cmd --permanent --add-port=22/tcp
sudo firewall-cmd --permanent --add-port=443/udp
sudo firewall-cmd --reload
sudo firewall-cmd --list-ports
sudo firewall-cmd --permanent --add-rich-rule="rule family='ipv4' source address=$server_network_client masquerade"
#sudo firewall-cmd --permanent --add-rich-rule='rule family="ipv4" source address=10.0.75.0/24 masquerade'
sudo firewall-cmd --reload

# Check running configuration
sudo wg showconf wg0

################
# Client
################
client_id="01"
client_ip="10.0.75.3/32"

# Generate client keys
wg genkey | sudo tee /etc/wireguard/client_private_"$client_id".key | wg pubkey | sudo tee /etc/wireguard/client_public_"$client_id".key

# Save keys to variables
client_priv_key=$(sudo cat /etc/wireguard/client_private_"$client_id".key)
client_pub_key=$(sudo cat /etc/wireguard/client_public_"$client_id".key)

# Create client conf file
# Remember to save server public key to variable if the installation has been done
# awhile ago.
server_pub_key=$(sudo cat /etc/wireguard/server_public.key)
sudo tee -a /etc/wireguard/client_"$client_id".conf > /dev/null <<EOL
[Interface]
PrivateKey = ${client_priv_key}
Address = ${client_ip}
DNS = ${dns_servers}

[Peer]
PublicKey = ${server_pub_key}
AllowedIPs = ${allowed_ips}
Endpoint = ${server_ip_public}:${server_port_vpn}
PersistentKeepalive = 15
EOL

# Enable client on wg0.conf
# This requires restart afterwards. Command to add without restart is below.
sudo tee -a /etc/wireguard/wg0.conf > /dev/null <<EOL
[Peer]
#${client_id}
PublicKey = ${client_pub_key}
AllowedIPs = ${allowed_ips}
EOL

# Add client without restart
# https://serverfault.com/questions/1101002/wireguard-client-addition-without-restart
# 10.0.75.0/24 = VPN network
# Peer Key = Client public key
sudo wg set wg0 peer "$client_pub_key" allowed-ips "$client_ip"
# Not sure if this is required
#ip -4 route add "10.0.75.0/24" dev wg0

# Remove client with:
# sudo wg set wg0 peer "$client_pub_key" remove

# Check server configuration that client is added properly
sudo wg showconf wg0

# Client conf for client application
cat /etc/wireguard/client_"$client_id".conf
~~~
