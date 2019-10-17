#!/bin/bash
source apache-conf.sh

MAILCATCHER_HOSTNAME=$(hostname)
MAILCATCHER_USERNAME=${MAILCATCHER_USERNAME:-mailcatcher}
MAILCATCHER_PASSWORD=${MAILCATCHER_PASSWORD:-mailcatcher}

IP=$(hostname --ip-address | cut -d" " -f1)

echo "Running mailcatcher on ip $IP ($MAILCATCHER_HOSTNAME)"
echo
echo Username: $MAILCATCHER_USERNAME
echo Password: $MAILCATCHER_PASSWORD

echo

rundir_courier="/var/run/courier"
rundir="/var/run/courier/authdaemon"


CRYPTED_PASSWORD=$(perl -e 'print crypt($ARGV[0], "password")' $MAILCATCHER_PASSWORD)
mkdir /home/$MAILCATCHER_USERNAME
useradd --shell /bin/sh -d /home/$MAILCATCHER_USERNAME --password $CRYPTED_PASSWORD $MAILCATCHER_USERNAME
chown -R $MAILCATCHER_USERNAME:$MAILCATCHER_USERNAME /home/$MAILCATCHER_USERNAME

# configure exim4
echo $MAILCATCHER_HOSTNAME >/etc/mailname

cat >/etc/exim4/update-exim4.conf.conf<<EOF
dc_eximconfig_configtype='local'
dc_other_hostnames=''
dc_local_interfaces='0.0.0.0'
dc_readhost=''
dc_relay_domains=''
dc_minimaldns='false'
dc_relay_nets='127.0.0.1;10.0.0.0/8;172.16.0.0/12;192.168.0.0/16'
dc_smarthost=''
CFILEMODE='644'
dc_use_split_config='true'
dc_hide_mailname=''
dc_mailname_in_oh='true'
dc_localdelivery='maildir_home'
EOF

sed -i -e"s/  data = :fail: Mailing to remote domains not supported/  data = ${MAILCATCHER_USERNAME}@${MAILCATCHER_HOSTNAME}/" /etc/exim4/conf.d/router/200_exim4-config_primary

update-exim4.conf


if [ ! -d "$rundir_courier" ]; then
	mkdir -m 0775 $rundir_courier
	chown daemon:daemon $rundir_courier
fi

if [ ! -d "$rundir" ]; then
	mkdir -m 0750 $rundir 
	chown daemon:daemon $rundir
fi

if [ ! -d /home/$MAILCATCHER_USERNAME/Maildir ]; then
	# send an email to force the creation of a Maildir directory
	echo "Hello World" | mail $MAILCATCHER_USERNAME@$(hostname)
fi


exec dumb-init "$@"
