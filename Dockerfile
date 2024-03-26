FROM debian:stable as build

# Install necessary dependencies
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    gcc ca-certificates gnupg vim wget apt-transport-https git bison flex make default-libmysqlclient-dev \
    autoconf pkg-config libssl-dev libcurl4-openssl-dev libxml2-dev libpcre3-dev \
    libpcre2-dev libmnl-dev libsctp-dev libxml2-dev libjson-c-dev && \
    rm -rf /var/lib/apt/lists/*

# TODO: Change to the latest stable version
RUN git clone https://github.com/kamailio/kamailio && \
    cd kamailio && \
    make PREFIX="/usr/local/kamailio" cfg

WORKDIR /kamailio
COPY modules/modules.lst ./src
# Build Kamailio
RUN make -j$(nproc) Q=0 all | tee make_all.txt && \
    make install | tee make_install.txt && \
    ldconfig

# final image
FROM debian:bookworm-slim
COPY --from=build /usr/local/kamailio /usr/local/kamailio
# Install necessary runtime dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    wget nano libmnl0 libsctp1 libxml2 libcurl4 libpcre3 libssl3 default-mysql-client && \
    rm -rf /var/lib/apt/lists/*

# Copy Kamailio configuration files and initialize script
COPY configs/ /usr/local/kamailio/etc/kamailio/
RUN mkdir -p /var/run/kamailio
COPY init.sh /init.sh
RUN chmod +x /init.sh

# Set default command
CMD ["/init.sh"]