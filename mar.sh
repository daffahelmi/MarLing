#!/bin/bash
sfile="https://github.com/daffahelmi/MarLing/blob/main"

#domain
read -rp "Masukkan Domain: " domain
echo "$domain" > /root/domain
domain=$(cat /root/domain)

#email
read -rp "Masukkan Email anda: " email

#Preparation
clear
cd;
apt-get update;

#Remove unused Module
apt-get -y --purge remove samba*;
apt-get -y --purge remove apache2*;
apt-get -y --purge remove sendmail*;
apt-get -y --purge remove bind9*;

#install bbr
echo 'fs.file-max = 500000
net.core.rmem_max = 67108864
net.core.wmem_max = 67108864
net.core.netdev_max_backlog = 250000
net.core.somaxconn = 4096
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_fin_timeout = 30
net.ipv4.tcp_keepalive_time = 1200
net.ipv4.ip_local_port_range = 10000 65000
net.ipv4.tcp_max_syn_backlog = 8192
net.ipv4.tcp_max_tw_buckets = 5000
net.ipv4.tcp_fastopen = 3
net.ipv4.tcp_mem = 25600 51200 102400
net.ipv4.tcp_rmem = 4096 87380 67108864
net.ipv4.tcp_wmem = 4096 65536 67108864
net.core.rmem_max=4000000
net.ipv4.tcp_mtu_probing = 1
net.ipv4.ip_forward=1
net.core.default_qdisc=fq
net.ipv4.tcp_congestion_control=bbr
net.ipv6.conf.all.disable_ipv6=1
net.ipv6.conf.default.disable_ipv6=1
net.ipv6.conf.lo.disable_ipv6=1' >> /etc/sysctl.conf
sysctl -p;

#install toolkit
apt-get install libio-socket-inet6-perl libsocket6-perl libcrypt-ssleay-perl libnet-libidn-perl perl libio-socket-ssl-perl libwww-perl libpcre3 libpcre3-dev zlib1g-dev dbus iftop zip unzip wget net-tools curl nano sed screen gnupg gnupg1 bc apt-transport-https build-essential dirmngr dnsutils sudo at htop iptables bsdmainutils cron lsof lnav -y

#Install Marzban
sudo bash -c "$(curl -sL https://github.com/daffahelmi/Marzban-scripts/raw/master/marzban.sh)" @ install

#Install Subs
wget -N -P /var/lib/marzban/templates/subscription/  https://raw.githubusercontent.com/daffahelmi/MarLing/main/index.html

#install env
wget -O /opt/marzban/.env "https://raw.githubusercontent.com/daffahelmi/MarLing/main/env"

#profile
echo -e 'profile' >> /root/.profile
wget -O /usr/bin/profile "https://raw.githubusercontent.com/daffahelmi/MarLing/main/profile";
chmod +x /usr/bin/profile
apt install neofetch -y
wget -O /usr/bin/cekservice "https://raw.githubusercontent.com/daffahelmi/MarLing/main/cekservice.sh"
chmod +x /usr/bin/cekservice

#install compose
wget -O /opt/marzban/docker-compose.yml "https://raw.githubusercontent.com/daffahelmi/MarLing/main/docker-compose.yml"

#Install VNSTAT
apt -y install vnstat

#Install Speedtest
curl -s https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.deb.sh | sudo bash
sudo apt-get install speedtest -y

#install nginx
apt install nginx -y
rm /etc/nginx/conf.d/default.conf
wget -O /etc/nginx/nginx.conf "https://raw.githubusercontent.com/daffahelmi/MarLing/main/nginx.conf"
wget -O /etc/nginx/conf.d/vps.conf "https://raw.githubusercontent.com/daffahelmi/MarLing/main/vps.conf"
wget -O /etc/nginx/conf.d/xray.conf "https://raw.githubusercontent.com/daffahelmi/Marling/main/xray.conf"
systemctl enable nginx
mkdir -p /var/www/html
echo "<pre>Setup by LingVPN edit by DaffaVPN</pre>" > /var/www/html/index.html
systemctl start nginx

#install socat
apt install iptables -y
apt install curl socat xz-utils wget apt-transport-https gnupg gnupg2 gnupg1 dnsutils lsb-release -y 
apt install socat cron bash-completion -y

#install cert
systemctl stop nginx
curl https://get.acme.sh | sh -s email=$email
/root/.acme.sh/acme.sh --server letsencrypt --register-account -m $email --issue -d $domain --standalone -k ec-256
~/.acme.sh/acme.sh --installcert -d $domain --fullchainpath /var/lib/marzban/xray.crt --keypath /var/lib/marzban/xray.key --ecc
systemctl start nginx
wget -O /var/lib/marzban/xray_config.json "https://raw.githubusercontent.com/daffahelmi/MarLing/main/xray_config.json"

#install firewall
apt install ufw -y
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow http
sudo ufw allow https
sudo ufw allow 7879/tcp
sudo ufw allow 8081/tcp
sudo ufw allow 1080/tcp
sudo ufw allow 1080/udp
yes | sudo ufw enable

#install database
wget -O /var/lib/marzban/db.sqlite3 "https://github.com/daffahelmi/MarLing/raw/main/db.sqlite3"

#swap ram 1gb
wget https://raw.githubusercontent.com/Cretezy/Swap/master/swap.sh -O swap
sh swap 1G
rm swap

#install WARP Proxy
wget -O /root/warp "https://raw.githubusercontent.com/hamid-gh98/x-ui-scripts/main/install_warp_proxy.sh"
sudo chmod +x /root/warp
sudo bash /root/warp -y

#finishing
apt autoremove -y
apt clean
systemctl restart nginx
cd /opt/marzban
docker compose down && docker compose up -d
cd
rm /root/mar.sh
