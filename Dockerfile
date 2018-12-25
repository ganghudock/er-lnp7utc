FROM debian:jessie
# Add starter 
ADD start.sh /root/start.sh

RUN apt-get update && \
    apt-get install wget curl lsb-release -y && \
    echo "deb http://nginx.org/packages/mainline/debian/ $(lsb_release -cs) nginx" >> /etc/apt/sources.list && \
    curl -L http://nginx.org/keys/nginx_signing.key | apt-key add - && \
    apt-get update && \
    apt-get install nginx -y && \
    systemctl enable nginx && \
    echo "PROJECT_RUN_MODE=production" >> /etc/environment && \
    mkdir -p /etc/nginx/sites-enabled /etc/nginx/sites-available && \
    apt-get -y install apt-transport-https lsb-release ca-certificates && \
    wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg && \
    echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list && \
    apt-get update && apt-get install php7.2-fpm php7.2-common php7.2-apcu php7.2-pgsql php7.2-curl php7.2-gd php7.2-imagick php7.2-json php7.2-mbstring php7.2-mysql php7.2-readline php7.2-soap php7.2-xml php7.2-zip php7.2-redis php7.2-intl -y && \
    sed -i 's|^short_open_tag.*|short_open_tag = On|' /etc/php/7.2/fpm/php.ini && \
    sed -i 's|^max_execution_time.*|max_execution_time = 300|' /etc/php/7.2/fpm/php.ini && \
    sed -i 's|^max_input_time.*|max_input_time = 600|' /etc/php/7.2/fpm/php.ini && \
    sed -i 's|^error_reporting.*|error_reporting = E_ALL \& ~E_DEPRECATED \& ~E_NOTICE \& ~E_STRICT|' /etc/php/7.2/fpm/php.ini && \
    sed -i 's|^short_open_tag.*|short_open_tag = On|' /etc/php/7.2/cli/php.ini && \
    sed -i 's|^error_reporting.*|error_reporting = E_ALL \& ~E_DEPRECATED \& ~E_NOTICE \& ~E_STRICT|' /etc/php/7.2/cli/php.ini && \
    echo "apc.shm_size=64M" >> /etc/php/7.2/mods-available/apcu.ini && \
    ln -snf /usr/share/zoneinfo/UTC /etc/localtime && echo "UTC" > /etc/timezone && \
    mv /etc/nginx /etc/nginx-orig

ADD nginx.conf /etc/nginx-orig/nginx.conf
ADD nginx.service /lib/systemd/system/nginx.service

RUN chmod +x /root/start.sh
CMD ["/bin/bash", "/root/start.sh"]

VOLUME ["/var/www", "/etc/nginx"]
