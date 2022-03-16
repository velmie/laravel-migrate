FROM alpine:3.11

ADD https://php.hernandev.com/key/php-alpine.rsa.pub /etc/apk/keys/php-alpine.rsa.pub

RUN apk --update-cache add ca-certificates && \
    echo "https://php.hernandev.com/v3.11/php-8.0" >> /etc/apk/repositories

RUN apk add --update-cache \
    bash \
    curl \
    php8 \
    php8-bcmath \
    php8-zip \
    php8-pdo \
    php8-pdo_mysql \
    php8-pdo_pgsql \
    php8-pdo_sqlite \
    php8-iconv \
    php8-mbstring \
    php8-phar \
    php8-zlib \
    php8-dom

RUN ln -sf /usr/bin/php8 /usr/bin/php

# Install composer
ENV COMPOSER_HOME /composer
ENV PATH ./vendor/bin:/composer/vendor/bin:$PATH
ENV COMPOSER_ALLOW_SUPERUSER 1
RUN curl -s https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin/ --filename=composer

COPY . /usr/src/lumen
WORKDIR /usr/src/lumen

RUN composer install

COPY entrypoint.sh /provision/entrypoint.sh

ENTRYPOINT ["/provision/entrypoint.sh"]
CMD ["php", "artisan", "migrate", "--force"]
