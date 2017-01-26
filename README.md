# Rainloop Webmail with Catch All

[![](https://images.microbadger.com/badges/image/belphemur/mailcatcher-exim-courrier)](https://microbadger.com/images/belphemur/mailcatcher-exim-courrier "Get your own image badge on microbadger.com")
[![](https://images.microbadger.com/badges/version/belphemur/mailcatcher-exim-courrier)](https://microbadger.com/images/belphemur/mailcatcher-exim-courrier "Get your own version badge on microbadger.com")
[![](https://img.shields.io/docker/stars/belphemur/mailcatcher-exim-courrier.svg)](https://hub.docker.com/r/belphemur/mailcatcher-exim-courrier "Click to view the image on Docker Hub")
[![](https://img.shields.io/docker/pulls/belphemur/mailcatcher-exim-courrier.svg)](https://hub.docker.com/r/belphemur/mailcatcher-exim-courrier "Click to view the image on Docker Hub")

## Introduction

This docker image installs Rainloop Webmail on Ubuntu Xenial.

A documentation can be found here:
[http://www.rainloop.net/](http://www.rainloop.net/)

This docker container can be use to send emails via SMTP and route all incoming SMTP traffic to a single mailbox which can be accessed via IMAP.

You can also access the mailbox via the webmail service which is exposed on port 80.

### Variables

Key | Description | Default
------------ | ------------- | -------------
APACHE_SERVER_NAME | Apache ServerName | rainloop.loc
APACHE_SERVER_ADMIN | Apache ServerAdmin | webmaster@rainloop.loc
PHP_MAX_POST_SIZE | PHP post_max_size (should outmatch PHP_MAX_UPLOAD_SIZE) | 20M
PHP_MAX_UPLOAD_SIZE | PHP upload_max_filesize | 8M
PHP_MAX_UPLOADS | PHP max_file_uploads | 20
PHP_MAX_EXECUTION_ZIME | PHP max_execution_time | 30
RAINLOOP_ADMIN_LOGIN | Rainloop admin user | admin
RAINLOOP_ADMIN_PASSWORD | Rainloop admin password | 12345
MAILCATCHER_USERNAME| Username of your catchall user | mailcatcher
MAILCATCHER_PASSWORD| Password of your catchall user | mailcatcher



### Example Run

```bash
docker run -d \
-e MAILCATCHER_USERNAME=mailcatcher \
-e MAILCATCHER_PASSWORD=mailcatcher \
belphemur/mailcatcher-exim-courrier
```

### Email folder
The email are stored in /home/MAILCATCHER_USERNAME/MailDir

## Connect to Rainloop

Login: MAILCATCHER_USERNAME**@localhost** OR just MAILCATCHER_USERNAME

pass:  MAILCATCHER_PASSWORD

### Configuration

The domain **localhost** is already configured in rainloop and set as default domain.

### Admin
To access admin panel, use URL of the following kind: http://product_installation_URL/?admin
