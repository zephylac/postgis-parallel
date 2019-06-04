#!/usr/bin/env bash

source /env-data.sh

SETUP_LOCKFILE="${ROOT_CONF}/.ssl.conf.lock"
if [ -f "${SETUP_LOCKFILE}" ]; then
	return 0
fi

# This script will setup default SSL config

# /etc/ssl/private can't be accessed from within container for some reason
# (@andrewgodwin says it's something AUFS related)  - taken from https://github.com/orchardup/docker-postgresql/blob/master/Dockerfile
mkdir /etc/ssl/private-copy;
mv /etc/ssl/private/* /etc/ssl/private-copy/
rm -r /etc/ssl/private
mv /etc/ssl/private-copy /etc/ssl/private
chmod -R 0700 /etc/ssl/private
chown -R postgres /etc/ssl/private

# Needed under debian, wasnt needed under ubuntu
mkdir -p ${PGSTAT_TMP}
chmod 0777 ${PGSTAT_TMP}

# moved from setup.sh
echo "ssl = true" >> $CONF
#echo "ssl_ciphers = 'DEFAULT:!LOW:!EXP:!MD5:@STRENGTH' " >> $CONF
#echo "ssl_renegotiation_limit = 512MB "  >> $CONF
echo "ssl_cert_file = '/etc/ssl/certs/ssl-cert-snakeoil.pem'" >> $CONF
echo "ssl_key_file = '/etc/ssl/private/ssl-cert-snakeoil.key'" >> $CONF
echo "data_directory = '/usr/local/pgsql/data'" >> $CONF
echo "hba_file = '/usr/local/pgsql/data/pg_hba.conf'" >> $CONF
echo "ident_file = '/usr/local/pgsql/data/pg_ident.conf'" >> $CONF
echo "external_pid_file = '/var/run/postgresql/12-main.pid'" >> $CONF

#echo "ssl_ca_file = ''                       # (change requires restart)" >> $CONF
#echo "ssl_crl_file = ''" >> $CONF

# Put lock file to make sure conf was not reinitialized
touch ${SETUP_LOCKFILE}
