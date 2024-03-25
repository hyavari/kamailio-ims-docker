FROM debian:stable as build

RUN rm -rf /var/lib/apt/lists/* && apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -qq --assume-yes gnupg vim wget apt-transport-https git bison flex make default-libmysqlclient-dev \
    autoconf pkg-config libssl-dev libcurl4-openssl-dev libxml2-dev libpcre3-dev libpcre2-dev libmnl-dev libsctp-dev libxml2-dev
#RUN wget -O- http://deb.kamailio.org/kamailiodebkey.gpg | apt-key add - 

RUN git clone --depth 1 --no-single-branch https://github.com/kamailio/kamailio kamailio && cd kamailio && git checkout -b 5.8 origin/5.8
WORKDIR /kamailio

RUN make PREFIX="/usr/local/kamailio" include_modules="cdp cdp_avp db_mysql dialplan ims_auth ims_charging ims_dialog ims_diameter_server ims_icscf ims_ipsec_pcscf ims_isc ims_ocs ims_qos ims_registrar_pcscf ims_registrar_scscf ims_usrloc_pcscf ims_usrloc_scscf outbound presence presence_conference presence_dialoginfo presence_mwi presence_profile presence_reginfo presence_xml pua pua_bla pua_dialoginfo pua_reginfo pua_rpc pua_usrloc pua_xmpp sctp tls utils xcap_client xcap_server xmlops xmlrpc" cfg
RUN make Q=0 all
RUN make install


FROM debian:stable-slim
COPY --from=build /usr/local/kamailio /usr/local/kamailio
RUN apt-get update && apt-get install -y wget nano libmnl0 libsctp1 libxml2 libcurl4 libpcre3 libssl3 default-mysql-client && rm -rf /var/lib/apt/lists/*

COPY ./configs/kamailio.cfg /usr/local/kamailio/etc/kamailio/kamailio.cfg
COPY ./configs/pcscf.cfg /usr/local/kamailio/etc/kamailio/pcscf.cfg 

CMD ["/usr/local/kamailio/sbin/kamailio", "-DD", "-E", "-e"]