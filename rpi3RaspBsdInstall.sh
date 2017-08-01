#!/usr/bin/env sh
echo "Installing bash"
pkg install -y bash
echo "Installing nmap"
pkg install -y nmap

echo "Installing logrotate"
pkg install -y logrotate
mkdir -p /usr/local/etc/logrotate.d
touch /usr/local/etc/logrotate.d/AutoNmap
cat > /usr/local/etc/logrotate.d/AutoNmap <<EOL
/var/log/AutoNmap.log {
daily
rotate 10
copytruncate
compress
extension gz
missingok
notifempty
}
EOL

echo "Applying crontab configuration"
touch crontab.config
echo "*/10 * * * * /usr/home/raspberry/AutoNmap.sh" >> crontab.config
echo "0    1 * * * /usr/local/sbin/logrotate /usr/local/etc/logrotate.conf > /dev/null 2>&1" >> crontab.config
crontab -rf 2>/dev/null
crontab crontab.config
rm crontab.config

echo "#!/usr/bin/env bash" > AutoNmap.sh

echo "NMAP=\$(which nmap)" >> AutoNmap.sh
echo "NETMASK=\$(which netmask)" >> AutoNmap.sh
echo "LOGFILE=/var/log/AutoNmap.log" >> AutoNmap.sh
echo "SUBNET=\$(ifconfig | grep -w inet | grep -v 127.0.0.1 | awk '{print \$2}')" >> AutoNmap.sh
echo "MASK=\$(ifconfig | grep -w inet |grep -v 127.0.0.1| awk '{print \$4}')" >> AutoNmap.sh

echo "\$NMAP \$SUBNET/24 -sn >> \$LOGFILE" >> AutoNmap.sh

echo "Setup NTP"
pkg install -y ntp
ntpdate -v -b nz.pool.ntp.org
printf "%s\n%s\n" 'ntpdate_enable="YES"' 'ntpdate_hosts="nz.pool.ntp.org"' >> /etc/rc.conf

echo "Setting up Timezone"
cp /usr/share/zoneinfo/Pacific/Auckland /etc/localtime

echo "Done"

