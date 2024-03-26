#!/bin/bash

cd /usr/local/kamailio/
./sbin/kamailio -f ./etc/kamailio/pcscf/kamailio.cfg -P /kamailio_pcscf.pid -DD -E -e