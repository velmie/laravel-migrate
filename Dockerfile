
FROM alpine:3.21

RUN echo "http://dl-cdn.alpinelinux.org/alpine/v3.21/main" >> /etc/apk/repositories

RUN apk add --update-cache \
    bash \
    php82 \
    php82-bcmath \
    php82-zip \
    php82-pdo \
    php82-pdo_mysql \
    php82-pdo_pgsql \
    php82-pdo_sqlite \
    php82-iconv \
    php82-mbstring \
    php82-phar \
    php82-zlib \
    php82-dom \
    php82-tokenizer \
    php82-xml \
    php82-xmlwriter \
    curl \
    jq \
    netcat-openbsd

RUN ln -sf /usr/bin/php82 /usr/bin/php

COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

COPY . /usr/src/lumen
WORKDIR /usr/src/lumen

RUN composer install 

COPY entrypoint.sh /provision/entrypoint.sh

ENTRYPOINT ["/provision/entrypoint.sh"]
CMD ["php", "artisan", "migrate", "--force"]
