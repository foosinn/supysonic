#!/bin/sh

# create config
cat > /var/lib/supysonic/.supysonic <<EOF
[base]
database_uri = sqlite:////var/lib/supysonic/supysonic.db
EOF

# create database if required
if ! test -f /var/lib/supysonic/supysonic.db; then
    echo Creating intial database
    sqlite3 /var/lib/supysonic/supysonic.db < /usr/local/lib/python3.6/site-packages/supysonic/sqlite.sql

    if test -f /run/secrets/supysonic; then
        password=$(cat /run/secrets/supysonic)
    else
        password=$(tr -dc '[:alnum:]' < /dev/urandom | head -c 16)
        echo Generated password: $password
    fi

    echo Adding user
    supysonic-cli user add admin -a -p $password

    echo Adding and scanning Library in /media
    supysonic-cli folder add Library /media
    supysonic-cli folder scan supysonic:latestLibrary
fi

uwsgi --http-socket :8080 \
      --wsgi-file /supysonic-master/cgi-bin/supysonic.wsgi \
      --master \
      --processes 4 --threads 2 \
      --uid $UID --pid $PID
