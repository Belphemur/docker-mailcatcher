FROM	combro2k/nginx-rainloop:latest

# install required packages
RUN	apt-get update -qq && \
	echo 'courier-base courier-base/webadmin-configmode boolean false' | debconf-set-selections && \
	apt-get -y install curl exim4 courier-imap supervisor && \
	apt-get clean autoclean && \
	apt-get autoremove --yes && \
	rm -rf /var/lib/{apt,dpkg,cache,log}/

ADD	docker-entrypoint.sh /usr/local/sbin/docker-entrypoint.sh

ENTRYPOINT ["/usr/local/sbin/docker-entrypoint.sh"]

ADD	etc/supervisor/conf.d/ /etc/supervisor/conf.d/

ADD	rainloop/localhost.ini /data/web/data/_data_/_default_/domains/localhost.ini
ADD	rainloop/application.ini /data/web/data/_data_/_default_/configs/application.ini

# 25/smtp 143/imap 
EXPOSE	25 143

CMD	["/usr/bin/supervisord"]

