FROM	debian:jessie
ENV	DEBIAN_FRONTEND noninteractive

ENV	ROUNDCUBE_VERSION 1.1.4
ENV	ROUNDCUBE_INSTALLDIR /var/www/html

# install required packages
RUN	apt-get update -qq && \
	echo 'courier-base courier-base/webadmin-configmode boolean false' | debconf-set-selections && \
	apt-get -y install curl exim4 courier-imap supervisor apache2 php5 php5-sqlite php5-mysqlnd && \
	apt-get clean autoclean && \
	apt-get autoremove --yes && \
	rm -rf /var/lib/{apt,dpkg,cache,log}/

RUN	rm -rf /var/www/html/* && \
	mkdir /var/lib/roundcube && \
	curl -SL https://downloads.sourceforge.net/project/roundcubemail/roundcubemail/${ROUNDCUBE_VERSION}/roundcubemail-${ROUNDCUBE_VERSION}-complete.tar.gz | tar -xz --strip=1 -C ${ROUNDCUBE_INSTALLDIR} && \
	cp ${ROUNDCUBE_INSTALLDIR}/config/config.inc.php.sample ${ROUNDCUBE_INSTALLDIR}/config/config.inc.php && \
	sed -i -e "s|\$config\['db_dsnw'\].*|\$config['db_dsnw'] = 'sqlite:////var/lib/roundcube/sqlite.db?mode=0646';|" ${ROUNDCUBE_INSTALLDIR}/config/config.inc.php

ADD	docker-entrypoint.sh /usr/local/sbin/docker-entrypoint.sh

ENTRYPOINT ["/usr/local/sbin/docker-entrypoint.sh"]

ADD	etc/supervisor/conf.d/ /etc/supervisor/conf.d/

VOLUME ["/var/lib/roundcube"]

# 25/smtp 80/web 143/imap 
EXPOSE	25 80 143

CMD	["/usr/bin/supervisord"]

