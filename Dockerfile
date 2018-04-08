FROM python:alpine

ENV \
    UID=1000 \
    GID=1000


ADD https://github.com/spl0k/supysonic/archive/master.zip /supysonic.zip
ADD init.sh /init.sh

RUN apk --no-cache add gcc musl-dev zlib-dev jpeg-dev libjpeg-turbo sqlite uwsgi uwsgi-python; \
    unzip supysonic.zip; \
    pip install ./supysonic-master; \
    cp /supysonic-master/schema/sqlite.sql /usr/local/lib/python3.6/site-packages/supysonic/; \
    adduser -D -u $UID -g $GID -h /var/lib/supysonic supysonic;

CMD /init.sh
