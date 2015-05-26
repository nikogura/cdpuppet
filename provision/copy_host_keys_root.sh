#!/bin/bash

cp -r /tmp/.ssh /root
chown -R root:root /root/.ssh
chmod 0700 /root/.ssh
chmod 0600 /root/.ssh/*

chown -R vagrant:vagrant /tmp/.ssh
chmod 0700 /tmp/.ssh
chmod 0600 /tmp/.ssh/*
mv /tmp/.ssh/* /home/vagrant/.ssh
rm -rf /tmp/.ssh