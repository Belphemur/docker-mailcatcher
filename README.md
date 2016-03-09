# docker-mailcatcher

This docker container can be use to send emails via SMTP and route all incoming SMTP traffic to a single mailbox which can be accessed via IMAP.

You can also access the mailbox via the webmail service which is exposed on port 80.

## Example Run

```bash
docker run -d \
-e MAILCATCHER_USERNAME=mailcatcher \
-e MAILCATCHER_PASSWORD=mailcatcher \
hauptmedia/mailcatcher
```

## Connect to Rainloop

Login: MAILCATCHER_USERNAME**@localhost**

pass:  MAILCATCHER_PASSWORD
