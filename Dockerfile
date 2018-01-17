# inspired by https://github.com/geertw/docker-php-ci/blob/master/php-7.0-no-xdebug/Dockerfile

FROM php:7.0

RUN apt-get update \
    && apt-get install -y git zip libgd-dev libmagickwand-dev zlib1g-dev \
    && apt-get clean \
    && pecl install imagick \
    && docker-php-ext-enable imagick \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ --with-png-dir=/usr/include/ \
    && docker-php-ext-install gd \
    && docker-php-ext-install opcache \
    && docker-php-ext-install zip

### PDO_sqlsrv START
# from https://github.com/Microsoft/msphpsql/wiki/Install-and-configuration#docker-files
# Add Microsoft repo for Microsoft ODBC Driver 13 for Linux
RUN apt-get install -y apt-transport-https \
    && curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
    && curl https://packages.microsoft.com/config/debian/8/prod.list > /etc/apt/sources.list.d/mssql-release.list \
    && apt-get update

# Install Dependencies
RUN ACCEPT_EULA=Y apt-get install -y \
    unixodbc \
    unixodbc-dev \
    libgss3 \
    odbcinst \
    msodbcsql \
    locales \
    && echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && locale-gen

# Install pdo_sqlsrv from PECL.
RUN pecl install pdo_sqlsrv \
	&& docker-php-ext-enable pdo_sqlsrv
### PDO_sqlsrv END

RUN echo "memory_limit = -1;" > $PHP_INI_DIR/conf.d/memory_limit.ini

ENV COMPOSER_ALLOW_SUPERUSER=1

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
