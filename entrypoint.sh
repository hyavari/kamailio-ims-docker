#!/bin/bash

# Path to Kamailio
RUN_PATH=/usr/local/kamailio/sbin
CFG_PATH=/usr/local/kamailio/etc/kamailio
PID_PATH=/var/run


# functions
prepare_pcscf() {
    echo "Preparing PCSCF configuration..."
    sed -i 's|PCSCF_IP|'$PCSCF_IP'|g' $CFG_PATH/pcscf/pcscf.cfg
    sed -i 's|IMS_DOMAIN|'$IMS_DOMAIN'|g' $CFG_PATH/pcscf/pcscf.cfg
}

prepare_icscf() {
    echo "Preparing ICSCF configuration..."
    sed -i 's|ICSCF_IP|'$ICSCF_IP'|g' $CFG_PATH/icscf/icscf.cfg
    sed -i 's|IMS_DOMAIN|'$IMS_DOMAIN'|g' $CFG_PATH/icscf/icscf.cfg
}

prepare_scscf() {
    echo "Preparing SCSCF configuration..."
}

# Start Kamailio with the appropriate configuration file
if [[ -z "$COMPONENT_NAME" ]]; then
    echo "Error: COMPONENT_NAME environment variable not set"; exit 1;
elif [[ "$COMPONENT_NAME" =~ ^i-?cscf-?[[:digit:]]*$ ]]; then
    echo "Deploying component: '$COMPONENT_NAME'"
    mkdir -p $PID_PATH/kamailio_icscf && \
    rm -f $PID_PATH/kamailio_icscf/kamailio_icscf.pid && \
    prepare_icscf && \
    $RUN_PATH/kamailio -f $CFG_PATH/icscf/kamailio.cfg -P $PID_PATH/kamailio_icscf/kamailio_icscf.pid -DD -E -e
elif [[ "$COMPONENT_NAME" =~ ^s-?cscf-?[[:digit:]]*$ ]]; then
    echo "Deploying component: '$COMPONENT_NAME'"
    mkdir -p $PID_PATH/kamailio_scscf && \
    rm -f $PID_PATH/kamailio_scscf/kamailio_scscf.pid && \
    prepare_scscf && \
    $RUN_PATH/kamailio -f $CFG_PATH/scscf/kamailio.cfg -P $PID_PATH/kamailio_scscf/kamailio_scscf.pid -DD -E -e
elif [[ "$COMPONENT_NAME" =~ ^p-?cscf-?[[:digit:]]*$ ]]; then
    echo "Deploying component: '$COMPONENT_NAME'"
    mkdir -p $PID_PATH/kamailio_pcscf && \
    rm -f $PID_PATH/kamailio_pcscf/kamailio_pcscf.pid && \
    prepare_pcscf && \
    $RUN_PATH/kamailio -f $CFG_PATH/pcscf/kamailio.cfg -P $PID_PATH/kamailio_pcscf/kamailio_pcscf.pid -DD -E -e
else
    echo "Error: Invalid component name: '$COMPONENT_NAME'"
fi