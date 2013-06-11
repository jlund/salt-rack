#!/bin/sh
HOSTNAME=hostname_here
SALT_MASTER=internal_ip_here

echo $HOSTNAME > /etc/hostname
hostname --file /etc/hostname

sed --in-place -e "s/127.0.0.1 localhost/127.0.0.1 $HOSTNAME localhost/" /etc/hosts
sed --in-place -e "s/::1 ip6-localhost ip6-loopback/::1 $HOSTNAME ip6-localhost ip6-loopback/" /etc/hosts
sed --in-place "2i $SALT_MASTER salt" /etc/hosts

add-apt-repository -y ppa:saltstack/salt

apt-get update
apt-get --yes dist-upgrade

apt-get --yes install salt-minion
reboot
