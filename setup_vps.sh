#!/bin/sh
# Update server 
apt update;
apt dist-upgrade -y;
# Install packages
apt install -y git curl wget htop build-essential;
# install nodejs
curl -sL https://deb.nodesource.com/setup_19.x | bash -;
apt install -y nodejs;
# install nginx
apt install -y nginx;
# install pm2
npm install pm2 -g;
# configure nginx
rm /etc/nginx/sites-enabled/*;
cp /root/weboverflows.fr /etc/nginx/sites-available/weboverflows.fr;
rm /root/weboverflows.fr;
ln -s /etc/nginx/sites-available/weboverflows.fr /etc/nginx/sites-enabled/weboverflows.fr;
nginx -t;
systemctl restart nginx;
# add user
adduser weboverflows;
# conf web server
cd /home/weboverflows/;
git clone https://github.com/WebOverflows/web.git;
cd web;
npm i;
# configure pm2
pm2 startup systemd;
cd /home/weboverflows/web/;
pm2 start index.js --name "weboverflows";
pm2 save;
# install fail2ban
apt install -y fail2ban;
# configure fail2ban
cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local;
sed -i 's/bantime  = 10m/bantime  = 1h/g' /etc/fail2ban/jail.local;
sed -i 's/findtime  = 10m/findtime  = 1h/g' /etc/fail2ban/jail.local;
sed -i 's/maxretry = 5/maxretry = 3/g' /etc/fail2ban/jail.local;
systemctl restart fail2ban;
# certbot
apt install -y certbot python3-certbot-nginx;
certbot --nginx -d weboverflows.fr;
# configure ufw
ufw default deny incoming;
ufw default allow outgoing;
ufw allow ssh;
ufw allow http;
ufw allow https;
ufw enable;
#remove setup script
rm /root/setup_vps.sh;
# reboot
reboot;