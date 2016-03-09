# docker-mailcatcher

This docker container can be use to send emails via SMTP and route all incoming SMTP traffic to a single mailbox which can be accessed via IMAP.

You can also access the mailbox via the webmail service which is exposed on port 80.

## Example Run

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
URL : http://DOCKER_IP/?admin

Login: admin

pass: 12345
