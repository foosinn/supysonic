#!/bin/sh

# create config
cat > /etc/supysonic <<EOF
[base]
database_uri = sqlite:////var/lib/supysonic/supysonic.db
EOF

# create database if required
if ! test -f /var/lib/supysonic/supysonic.db; then
    echo Creating intial database
    sqlite3 /var/lib/supysonic/supysonic.db < /supysonic-master/schema/sqlite.sql

    if test -f /run/secrets/supysonic; then
        password=$(cat /run/secrets/supysonic)
    else
        until [ ${len=0} -gt 12 ]; do len=$(( $RANDOM % 24 )); done
        password=$(tr -dc '[:alnum:]' < /dev/urandom | head -c $len)
        echo Generated password: $password
    fi

    echo Adding user
    supysonic-cli user add admin -a -p $password

    echo Adding and scanning Library in /media
    supysonic-cli folder add Library /media
    supysonic-cli folder scan supysonic:latestLibrary

    echo Changing owner of config dir
    chown -R supysonic:supysonic ~supysonic
fi

# update database
# see: https://github.com/spl0k/supysonic/blob/master/README.md#upgrading
pip install /supysonic-master

# run uwsgi
exec uwsgi --http-socket :8080 \
           --wsgi-file /supysonic-master/cgi-bin/supysonic.wsgi \
           --master \
           --processes 4 --threads 2 \
           --uid $UID --gid $GID
