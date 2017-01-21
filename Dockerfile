FROM debian:latest
ARG BUILD_DATE
ARG VCS_REF
ARG VERSION
LABEL org.label-schema.build-date=$BUILD_DATE \
			org.label-schema.name="cliente_graylog2" \
			org.label-schema.description="Cliente testing graylog2" \
			org.label-schema.url="http://andradaprieto.es" \
			org.label-schema.vcs-ref=$VCS_REF \
			org.label-schema.vcs-url="https://github.com/jandradap/cliente_graylog2" \
			org.label-schema.vendor="Jorge Andrada Prieto" \
			org.label-schema.version=$VERSION \
			org.label-schema.schema-version="1.0" \
			maintainer="Jorge Andrada Prieto <jandradap@gmail.com>" \
			org.label-schema.docker.cmd="docker run --name=Cliente_Graylog -p 22 -p 80 -d jorgeandrada/cliente_graylog2"

#instalacion de MySQL con password root
RUN echo mysql-server mysql-server/root_password select root | debconf-set-selections && \
	echo mysql-server mysql-server/root_password_again select root | debconf-set-selections && \
	apt-get update && apt-get install -fy \
		nano \
		curl \
		ssh \
		openssh-server \
		lynx \
		rsyslog \
		apache2 \
		samba \
		supervisor \
		mysql-server && \
 	rm -rf /var/lib/apt/lists/* && \
	rm -rf /var/cache/apt/archives/*

#Configurar Apache2
RUN mkdir -p /var/lock/apache2 /var/run/apache2 /var/run/sshd /var/log/supervisor && \
	rm -rf /var/www/html/index.html
COPY index.html /var/www/html/index.html
RUN chown www-data:www-data /var/www/html/index.html

#Configurar SSH
RUN echo 'root:root' | chpasswd && \
	sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config

#Configuracion RSYSLOG
RUN echo "\$template GRAYLOGRFC5424,\"%protocol-version% %timestamp:::date-rfc3339% %HOSTNAME% %app-name% %procid% %msg%\n\"" >> /etc/rsyslog.conf && \
echo "*.* @172.17.0.5:2514;GRAYLOGRFC5424" >> /etc/rsyslog.conf

#Copio la configuracion del supervisord
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
RUN chown root:root /etc/supervisor/conf.d/supervisord.conf

#expongo los puertos
EXPOSE 22 80

#Ejecuto el supervisor
CMD ["/usr/bin/supervisord"]


########### INFORMACION ###########
#mysql root:root
#docker build -t jorgeandrada/cliente_graylog2 --no-cache .
#docker run --name=Cliente_Graylog -p 22 -p 80 -d jorgeandrada/cliente_graylog2
#docker exec -i  Cliente_Graylog /bin/bash
#docker login
#docker push jorgeandrada/cliente_graylog2
