FROM debian:stable as build

RUN rm -rf /var/lib/apt/lists/* && apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -qq --assume-yes gnupg vim wget apt-transport-https git bison flex make default-libmysqlclient-dev \
    autoconf pkg-config libssl-dev libcurl4-openssl-dev libxml2-dev libpcre3-dev libpcre2-dev libmnl-dev libsctp-dev libxml2-dev libjson-c-dev

# TODO: Change to the latest stable version
RUN git clone https://github.com/kamailio/kamailio && cd kamailio && git checkout 4fb8accc6747ad56fec3dc84d70cb2b8bbd7316e

WORKDIR /kamailio
RUN make PREFIX="/usr/local/kamailio" cfg
COPY modules/modules.lst ./src
RUN make -j`nproc` Q=0 all | tee make_all.txt && \
    make install | tee make_install.txt && \
    ldconfig

# final image
FROM debian:stable-slim
COPY --from=build /usr/local/kamailio /usr/local/kamailio
RUN apt-get update && apt-get install -y wget nano libmnl0 libsctp1 libxml2 libcurl4 libpcre3 libssl3 default-mysql-client && rm -rf /var/lib/apt/lists/*

COPY configs/ /usr/local/kamailio/etc/kamailio/
RUN mkdir -p /var/run/kamailio
COPY init.sh /init.sh
RUN chmod +x /init.sh

CMD ["/init.sh"]