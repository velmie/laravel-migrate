FROM php:8.0.9-cli

RUN apt-get update && \
    apt-get install -y \
    netcat \
    libzip-dev \
    libsqlite3-dev \
    libpq-dev \
    zlib1g-dev

RUN docker-php-ext-install \
    bcmath \
    zip \
    pdo \
    pdo_mysql \
    pdo_pgsql \
    pdo_sqlite

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
