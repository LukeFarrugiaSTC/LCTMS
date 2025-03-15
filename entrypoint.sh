#!/bin/sh
cat <<EOF > /config/outgoing_smtp.json
{
  "default" :{
    "host": "${OUTGOING_SMTP_HOST}",
    "port": "${OUTGOING_SMTP_PORT}",
    "username": "${OUTGOING_SMTP_USERNAME}",
    "password": "${OUTGOING_SMTP_PASSWORD}",
    "auth": "${OUTGOING_SMTP_AUTH}",
    "autotls": "${OUTGOING_SMTP_AUTOTLS}"
  }
}
EOF

# Execute MailHog with the given command-line arguments
exec MailHog "$@"