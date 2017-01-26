FROM	runningman84/rainloop

# install required packages
RUN	apt-get update -qq && \
	echo 'courier-base courier-base/webadmin-configmode boolean false' | debconf-set-selections && \
	apt-get -y install curl exim4 courier-imap supervisor && \
	apt-get clean autoclean && \
	apt-get autoremove --yes && \
	rm -rf /var/lib/{apt,dpkg,cache,log}/

RUN mkdir -p /var/lock/apache2 /var/run/apache2 /var/log/supervisor


ADD    etc/supervisor/conf.d/ /etc/supervisor/conf.d/

ADD	docker-entrypoint.sh /usr/local/sbin/docker-entrypoint.sh
ADD	apache-conf.sh       /usr/local/sbin/apache-conf.sh

ENTRYPOINT ["/usr/local/sbin/docker-entrypoint.sh"]

ADD	rainloop/localhost.ini /var/www/html/data/_data_/_default_/domains/localhost.ini
ADD	rainloop/application.ini /var/www/html/data/_data_/_default_/configs/application.ini

# 25/smtp 143/imap 
EXPOSE	25 143

CMD	["/usr/bin/supervisord"]

