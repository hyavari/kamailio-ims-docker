#!/bin/bash

cp -r /usr/local/kamailio/etc/kamailio/pcscf/* /usr/local/kamailio/etc/kamailio/ && \
rm -rf /usr/local/kamailio/etc/kamailio/pcscf && \
rm -f /kamailio_pcscf.pid && \

sed -i 's|PCSCF_IP|'$PCSCF_IP'|g' /usr/local/kamailio/etc/kamailio/pcscf.cfg
sed -i 's|IMS_DOMAIN|'$IMS_DOMAIN'|g'/usr/local/kamailio/etc/kamailio/pcscf.cfg

/usr/local/kamailio/sbin/kamailio -f /usr/local/kamailio/etc/kamailio/kamailio.cfg -P /kamailio_pcscf.pid -DD -E -e