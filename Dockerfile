FROM	debian:buster-slim

MAINTAINER Antoine Aflalo <antoine+docker@aaflalo.me>

ARG DEBIAN_FRONTEND=noninteractive

ENV TZ=GMT
ARG VCS_REF
ARG BUILD_DATE

LABEL org.label-schema.vcs-ref=$VCS_REF \
          org.label-schema.vcs-url="https://github.com/Belphemur/docker-mailcatcher" \
          org.label-schema.build-date=${BUILD_DATE}

ENV APACHE_SERVER_NAME=rainloop.loc \
    APACHE_SERVER_ADMIN=webmaster@rainloop.loc \
    PHP_MAX_POST_SIZE=24M \
    PHP_MAX_UPLOAD_SIZE=20M \
    PHP_MAX_UPLOADS=20 \
    PHP_MAX_EXECUTION_ZIME=30 \
    RAINLOOP_ADMIN_LOGIN=admin \
    RAINLOOP_ADMIN_PASSWORD=12345

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

ARG GPG_FINGERPRINT="3B79 7ECE 694F 3B7B 70F3  11A4 ED7C 49D9 87DA 4591"

ARG TINI_VERSION="v0.18.0"
ARG GPG_TINY_KEY="595E85A6B1B4779EA4DAAEC70B588DFF0527A9B7"

# Courrier fixes
# See  https://bugs.launchpad.net/ubuntu/+source/courier/+bug/1781243

RUN mkdir -p /usr/share/man/man5/ && \
mkdir -p /usr/share/man/man8 && \
mkdir -p /usr/share/man/man1 && \
mkdir -p /usr/share/man/man7 && \
touch /usr/share/man/man5/maildir.courier.5.gz && \
touch /usr/share/man/man8/deliverquota.courier.8.gz && \
touch /usr/share/man/man1/maildirmake.courier.1.gz  && \
touch /usr/share/man/man7/maildirquota.courier.7.gz && \
touch /usr/share/man/man1/makedat.courier.1.gz

# install required packages
RUN	apt-get update -qq && \
	echo 'courier-base courier-base/webadmin-configmode boolean false' | debconf-set-selections && \
	apt-get -y install gnupg curl exim4 courier-imap supervisor vim wget unzip apache2 libapache2-mod-php php-curl php-xml php-sqlite3 curl && \
	apt-get clean autoclean && \
	apt-get autoremove --yes && \
	rm -rf /var/lib/{apt,dpkg,cache,log}/

RUN mkdir -p /var/lock/apache2 /var/run/apache2 /var/log/supervisor \
&& ln -sf /dev/stdout /var/log/apache2/access.log \
&& ln -sf /dev/stdout /var/log/apache2/other_vhosts_access.log \
&& ln -sf /dev/stderr /var/log/apache2/error.log

# Disable IPv6
# See https://github.com/inversepath/usbarmory-debian-base_image/issues/9
RUN mkdir ~/.gnupg && echo "disable-ipv6" >> ~/.gnupg/dirmngr.conf

# init
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini.asc /tini.asc
RUN gpg --batch --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys ${GPG_TINY_KEY} \
 && gpg --batch --verify /tini.asc /tini \
 && chmod +x /tini

RUN cd /tmp \
 && wget -q http://www.rainloop.net/repository/webmail/rainloop-community-latest.zip \
 && wget -q http://www.rainloop.net/repository/webmail/rainloop-community-latest.zip.asc \
 && wget -q https://repository.rainloop.net/RainLoop.asc \
 && echo "Verifying authenticity of rainloop-community-latest.zip using GPG..." \
 && gpg --import RainLoop.asc \
 && FINGERPRINT="$(LANG=C gpg --verify rainloop-community-latest.zip.asc rainloop-community-latest.zip 2>&1 \
  | sed -n "s#Primary key fingerprint: \(.*\)#\1#p")" \
 && if [ -z "${FINGERPRINT}" ]; then echo "Warning! Invalid GPG signature!" && exit 1; fi \
 && if [ "${FINGERPRINT}" != "${GPG_FINGERPRINT}" ]; then echo "Warning! Wrong GPG fingerprint!" && exit 1; fi \
 && echo "All seems good, now unzipping rainloop-community-latest.zip..." \
 &&  mkdir -p /var/www/html/rainloop &&  mkdir -p /var/www/html/data \
 && unzip -q /tmp/rainloop-community-latest.zip -d  /var/www/html \
 && find  /var/www/html/rainloop -type d -exec chmod 755 {} \; \
 && find  /var/www/html/rainloop -type f -exec chmod 644 {} \; \
 && chown -R www-data.www-data /var/www/html/data && chown -R root.root /var/www/html/rainloop \
 && rm -rf /tmp/* /root/.gnupg  \
 && mv /var/www/html/rainloop/v/*/index.php.root /var/www/html/index.php \
 && rm /var/www/html/index.html


ADD    etc/ /etc/

ADD	docker-entrypoint.sh /usr/local/sbin/docker-entrypoint.sh
ADD	apache-conf.sh       /usr/local/sbin/apache-conf.sh

ENTRYPOINT ["/usr/local/sbin/docker-entrypoint.sh"]

ADD	rainloop/localhost.ini /var/www/html/data/_data_/_default_/domains/localhost.ini
ADD	rainloop/application.ini /var/www/html/data/_data_/_default_/configs/application.ini

VOLUME  ["/var/www/html/data"]

HEALTHCHECK --interval=5m --timeout=3s CMD curl -I -s -f http://localhost:80/ || exit 1

# 25/smtp 143/imap 80/apache
EXPOSE	25 143 80

CMD	["/usr/bin/supervisord"]

