# First, We need an Operating System for our docker. We choose alpine.
FROM alpine:3.16.2

# Next, Update Alpine OS
RUN apk update && apk upgrade

# Next, we need to install utilities inside alpine, we can achieve this by type RUN then, the alpine command.
# Install apline utilities and php depedencies
RUN apk add --no-cache \
    bash \
    php8 \ 
    php8-fpm \ 
    php8-opcache \
    php8-gd \
    php8-zlib \
    php8-curl \
    php8-bcmath \
    php8-ctype \
    php8-iconv \
    php8-intl \
    php8-json \
    php8-mbstring \
    php8-mysqlnd \
    php8-openssl \
    php8-pdo \
    php8-pdo_mysql \
    php8-pdo_pgsql \
    php8-pdo_sqlite \
    php8-phar \
    php8-posix \
    php8-session \
    php8-soap \
    php8-xml \
    php8-zip \
    libmcrypt-dev \
    libltdl 

# Next, Install nginx on alpine official guide in nginx official site. I just copied and paste what's on the site guide for installing nginx on alpine.
# https://docs.nginx.com/nginx/admin-guide/installing-nginx/installing-nginx-open-source/
RUN apk add openssl curl ca-certificates

# To set up the apk repository for stable nginx packages, run the command:
RUN printf "%s%s%s\n" \
"http://nginx.org/packages/alpine/v" \
`egrep -o '^[0-9]+\.[0-9]+' /etc/alpine-release` \
"/main" \
| tee -a /etc/apk/repositories

# Import an official nginx signing key so apk could verify the packages authenticity. Fetch the key:
RUN curl -o /tmp/nginx_signing.rsa.pub https://nginx.org/keys/nginx_signing.rsa.pub

# Verify that the downloaded file contains the proper key:
RUN openssl rsa -pubin -in /tmp/nginx_signing.rsa.pub -text -noout

# Move the key to apk trusted keys storage
RUN mv /tmp/nginx_signing.rsa.pub /etc/apk/keys/

# Now, install nginx
RUN apk add nginx

# Install PHP Composer, If you use composer, you can uncomment this one.
# RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# copy project file to nginx inside docker.
COPY ./src /usr/share/nginx/html/project

# Copy default config and paste it into nginx config path inside docker.
COPY ./nginx-configs/default.conf /etc/nginx/conf.d/default.conf

# Expose port to be visible outside the container.
EXPOSE 80
EXPOSE 443

STOPSIGNAL SIGTERM

# Execute startup command.
# Start php-fpm8 and nginx through bash terminal.
CMD ["/bin/bash", "-c", "php-fpm8 && chmod 755 /usr/share/nginx/html/* && nginx -g 'daemon off;'"]