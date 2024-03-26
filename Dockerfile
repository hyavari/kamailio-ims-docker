FROM debian:stable as build

RUN rm -rf /var/lib/apt/lists/* && apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -qq --assume-yes gnupg vim wget apt-transport-https git bison flex make default-libmysqlclient-dev \
    autoconf pkg-config libssl-dev libcurl4-openssl-dev libxml2-dev libpcre3-dev libpcre2-dev libmnl-dev libsctp-dev libxml2-dev

RUN git clone --depth 1 --no-single-branch https://github.com/kamailio/kamailio kamailio && cd kamailio && git checkout -b 5.8 origin/5.8
WORKDIR /kamailio
COPY configs/modules.lst /kamailio/

RUN make PREFIX="/usr/local/kamailio" cfg
RUN make Q=0 all
RUN make install

RUN make -j`nproc` Q=0 all | tee make_all.txt && \
    make install | tee make_install.txt && \
    ldconfig

FROM debian:stable-slim
COPY --from=build /usr/local/kamailio /usr/local/kamailio
RUN apt-get update && apt-get install -y wget nano libmnl0 libsctp1 libxml2 libcurl4 libpcre3 libssl3 default-mysql-client && rm -rf /var/lib/apt/lists/*

COPY configs/pcscf /usr/local/kamailio/etc/kamailio/
RUN mkdir -p /var/run/kamailio

CMD ["/usr/local/kamailio/sbin/kamailio", "-DD", "-E", "-e"]