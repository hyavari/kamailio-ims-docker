#!/bin/bash

cp -r /kamailio/etc/kamailio/pcscf/* /kamailio/etc/kamailio/ && \
rm -rf /kamailio/etc/kamailio/pcscf && \
rm -f /kamailio_pcscf.pid && \

sed -i 's|PCSCF_IP|'$PCSCF_IP'|g' /kamailio/etc/kamailio/pcscf.cfg
sed -i 's|IMS_DOMAIN|'$IMS_DOMAIN'|g' /kamailio/etc/kamailio/pcscf.cfg

/kamailio/sbin/kamailio -f /kamailio/etc/kamailio/kamailio.cfg -P /kamailio_pcscf.pid -DD -E -e