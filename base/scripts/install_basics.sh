#!/bin/bash -eux

# https://github.com/elastic/elasticsearch/blob/master/distribution/docker/src/docker/Dockerfile#L32

# set variables
PACKAGE_NAME="elasticsearch"

# create system users and folders
groupadd --gid 1000 $PACKAGE_NAME
useradd -M --uid 1000 \
    --gid 1000 \
    --home-dir /usr/share/$PACKAGE_NAME \
    --shell /bin/bash $PACKAGE_NAME
cd /usr/share/$PACKAGE_NAME
mkdir -pv config data logs
chmod 0755 config data logs
chgrp 0 /usr/share/$PACKAGE_NAME

# set folder permissions
chown -R root:$PACKAGE_NAME /var/log/$PACKAGE_NAME
chmod -R 0770 /var/log/$PACKAGE_NAME
chown -R root:$PACKAGE_NAME /var/lib/$PACKAGE_NAME
chmod -R 0770 /var/lib/$PACKAGE_NAME
chown -R $PACKAGE_NAME:root /usr/share/$PACKAGE_NAME
chmod -R 0775 /usr/share/$PACKAGE_NAME

# install the systemctl stub
cd /tmp
curl -sLO https://raw.githubusercontent.com/gdraheim/docker-systemctl-replacement/master/files/docker/systemctl.py \
  && yes | cp -f systemctl.py /usr/bin/systemctl \
  && chmod a+x /usr/bin/systemctl
