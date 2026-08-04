FROM debian:bullseye

RUN apt-get update && \
    apt-get install -y \
        php-fpm \
        php-mysql \
        curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY tools/init.sh /usr/local/bin/init.sh

RUN chmod +x /usr/local/bin/init.sh

CMD ["/usr/local/bin/init.sh"]