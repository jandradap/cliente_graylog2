FROM debian:latest
MAINTAINER Jorge Andrada <jandradap@gmail.com>

#instalo paquetes
RUN apt-get update && apt-get install -fy \
	nano \
	curl \
	ssh \
	openssh-server \
	lynx \
	rsyslog \
	apache2 \
	samba \
	supervisor

#instalacion de MySQL con password root
RUN echo mysql-server mysql-server/root_password select root | debconf-set-selections
RUN echo mysql-server mysql-server/root_password_again select root | debconf-set-selections
RUN apt-get install -fy mysql-server

#borro descargas
RUN rm -rf /var/lib/apt/lists/*
RUN rm -rf /var/cache/apt/archives/*

#Configurar Apache2
RUN mkdir -p /var/lock/apache2 /var/run/apache2 /var/run/sshd /var/log/supervisor
RUN rm -rf /var/www/html/index.html
COPY index.html /var/www/html/index.html
RUN chown www-data:www-data /var/www/html/index.html

#Configurar SSH
RUN echo 'root:root' | chpasswd
RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config

#Configuracion RSYSLOG
RUN echo "*.* @172.17.0.5:2514" >> /etc/rsyslog.conf

#Copio la configuracion del supervisord
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
RUN chown root:root /etc/supervisor/conf.d/supervisord.conf

#expongo los puertos
EXPOSE 22 80

#Ejecuto el supervisor
CMD ["/usr/bin/supervisord"]


########### INFORMACION ###########
#mysql root:root
#docker build -t monino/pruebas:cliente_graylog_debian --no-cache .
#docker run --name=Cliente_Graylog -p 22 -p 80 -d monino/pruebas:cliente_graylog_debian
#docker exec -i  Cliente_Graylog /bin/bash
#docker login
#docker push monino/pruebas:cliente_graylog_debian

