#!/bin/bash

cp -r /usr/local/kamailio/etc/kamailio/pcscf/* /usr/local/kamailio/etc/kamailio/ && \
rm -rf /usr/local/kamailio/etc/kamailio/pcscf && \
rm -f /kamailio_pcscf.pid && \
/usr/local/kamailio/sbin/kamailio -f /usr/local/kamailio/etc/kamailio/kamailio.cfg -P /kamailio_pcscf.pid -DD -E -e