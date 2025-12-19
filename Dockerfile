FROM alpine:3.22

RUN echo "http://dl-cdn.alpinelinux.org/alpine/v3.22/main" >> /etc/apk/repositories

# update index, upgrade existing packages, and install new packages in one layer
RUN apk upgrade --available --no-cache && apk add --no-cache \
    bash \
    php83 \
    php83-bcmath \
    php83-zip \
    php83-pdo \
    php83-pdo_mysql \
    php83-pdo_pgsql \
    php83-pdo_sqlite \
    php83-iconv \
    php83-mbstring \
    php83-phar \
    php83-zlib \
    php83-dom \
    php83-tokenizer \
    php83-xml \
    php83-xmlwriter \
    curl \
    jq \
    netcat-openbsd

RUN ln -sf /usr/bin/php83 /usr/bin/php

COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

COPY . /usr/src/lumen
WORKDIR /usr/src/lumen

RUN composer install

COPY entrypoint.sh /provision/entrypoint.sh

ENTRYPOINT ["/provision/entrypoint.sh"]
CMD ["php", "artisan", "migrate", "--force"]
