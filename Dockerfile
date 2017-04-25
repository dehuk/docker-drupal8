FROM php:7.0-apache

RUN a2enmod rewrite

RUN apt-get update && apt-get install -y libpng12-dev libjpeg-dev libpq-dev libfreetype6-dev mysql-client \
	&& rm -rf /var/lib/apt/lists/* \
	&& docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr --with-freetype-dir=/usr \
	&& docker-php-ext-install gd mbstring opcache pdo pdo_mysql pdo_pgsql zip exif

RUN pecl install redis-3.1.0 \
    && pecl install xdebug-2.5.0 \
    && docker-php-ext-enable redis xdebug

RUN php -r "readfile('https://s3.amazonaws.com/files.drush.org/drush.phar');" > drush \
    && chmod +x drush \
    && mv drush /usr/local/bin

RUN curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer \
    && chmod +x /usr/local/bin/composer

RUN { \
        echo 'post_max_size=250M'; \
        echo 'upload_max_filesize=250M'; \
        echo 'memory_limit=512M'; \
        echo 'session.cache_limiter = nocache'; \
        echo 'session.auto_start = 0'; \
        echo 'expose_php = off'; \
        echo 'allow_url_fopen = on'; \
        echo 'magic_quotes_gpc = off'; \
        echo 'register_globals = off'; \
        echo ''; \
    } > /usr/local/etc/php/conf.d/drupal-php.ini

RUN apt-get update && apt-get install -y openssh-client