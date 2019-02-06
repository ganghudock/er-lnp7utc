FROM debian:jessie
# Add starter 
ADD start.sh /root/start.sh

RUN apt-get update && \
    apt-get install wget curl lsb-release -y && \
    echo "deb http://nginx.org/packages/mainline/debian/ $(lsb_release -cs) nginx" >> /etc/apt/sources.list && \
    curl -L http://nginx.org/keys/nginx_signing.key | apt-key add - && \
    apt-get update && \
    apt-get install nginx -y && \
    usermod -a -G www-data nginx && \
    echo "PROJECT_RUN_MODE=production" >> /etc/environment && \
    mkdir -p /etc/nginx/sites-enabled /etc/nginx/sites-available && \
    apt-get -y install apt-transport-https lsb-release ca-certificates && \
    wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg && \
    echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list && \
    apt-get update && apt-get install php7.0-fpm php7.0-common php7.0-apcu php7.0-pgsql php7.0-curl php7.0-gd php7.0-imagick php7.0-json php7.0-mbstring php7.0-mysql php7.0-readline php7.0-soap php7.0-xml php7.0-zip php7.0-redis php7.0-intl -y && \
    sed -i 's|^short_open_tag.*|short_open_tag = On|' /etc/php/7.0/fpm/php.ini && \
    sed -i 's|^max_execution_time.*|max_execution_time = 300|' /etc/php/7.0/fpm/php.ini && \
    sed -i 's|^max_input_time.*|max_input_time = 600|' /etc/php/7.0/fpm/php.ini && \
    sed -i 's|^error_reporting.*|error_reporting = E_ALL \& ~E_DEPRECATED \& ~E_NOTICE \& ~E_STRICT|' /etc/php/7.0/fpm/php.ini && \
    sed -i 's|^short_open_tag.*|short_open_tag = On|' /etc/php/7.0/cli/php.ini && \
    sed -i 's|^error_reporting.*|error_reporting = E_ALL \& ~E_DEPRECATED \& ~E_NOTICE \& ~E_STRICT|' /etc/php/7.0/cli/php.ini && \
    sed -i 's|^;listen.mode.*|listen.mode = 0660|' /etc/php/7.0/fpm/pool.d/www.conf && \
    sed -i 's|^;pm.max_requests.*|pm.max_requests = 500|' /etc/php/7.0/fpm/pool.d/www.conf && \
    echo "apc.shm_size=64M" >> /etc/php/7.0/mods-available/apcu.ini && \
    ln -snf /usr/share/zoneinfo/UTC /etc/localtime && echo "UTC" > /etc/timezone && \
    mv /etc/nginx /etc/nginx-orig

ADD nginx.conf /etc/nginx-orig/nginx.conf
ADD nginx.service /lib/systemd/system/nginx.service

RUN chmod +x /root/start.sh
CMD ["/bin/bash", "/root/start.sh"]

VOLUME ["/var/www", "/etc/nginx"]
