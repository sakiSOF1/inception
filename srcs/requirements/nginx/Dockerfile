FROM debian:bookworm

RUN apt-get update && \
    apt-get install -y nginx openssl && \
    mkdir -p /etc/nginx/ssl && \
    rm -rf /var/lib/apt/lists/*

COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY tools/init.sh /usr/local/bin/init.sh

RUN chmod +x /usr/local/bin/init.sh

CMD ["/usr/local/bin/init.sh"]