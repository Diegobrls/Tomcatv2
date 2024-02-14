#!/bin/bash

id tomcat || useradd -m -d /opt/tomcat -U -s /bin/false tomcat
apt-get update -y
apt-get upgrade -y

# Instalación del JDK
apt install openjdk-17-jdk-headless -y
wget https://dlcdn.apache.org/tomcat/tomcat-10/v10.1.18/bin/apache-tomcat-10.1.18.tar.gz -O /tmp/tomcat.tar.gz
tar xzvf /tmp/tomcat.tar.gz -C /opt/tomcat --strip-components=1
chown -R tomcat:tomcat /opt/tomcat/
chmod -R u+x /opt/tomcat/bin

cp /opt/tomcat/conf/tomcat-users.xml /opt/tomcat/conf/tomcat-users-backup.xml

sed -i '/<\/tomcat-users>/i\
  <role rolename="manager-gui" />\
  <user username="manager" password="usuario" roles="manager-gui" />\
\
  <role rolename="admin-gui" /> \
  <user username="admin" password="usuario" roles="manager-gui,admin-gui" />' /opt/tomcat/conf/tomcat-users.xml

# manager
sed -i '/<Valve/i\<!--' /opt/tomcat/webapps/manager/META-INF/context.xml
sed -i '/allow="127/a-->' /opt/tomcat/webapps/manager/META-INF/context.xml

# host-manager
sed -i '/<Valve/i\<!--' /opt/tomcat/webapps/host-manager/META-INF/context.xml
sed -i '/allow="127/a-->' /opt/tomcat/webapps/host-manager/META-INF/context.xml

# Creamos el archivo tomcat.service con el texto contenido a continuación, hasta EOF
cat <<EOF | tee -a /etc/systemd/system/tomcat.service > /dev/null
[Unit]
Description=Tomcat
After=network.target

[Service]
Type=forking

User=tomcat
Group=tomcat

Environment="JAVA_HOME=/usr/lib/jvm/java-1.17.0-openjdk-amd64"
Environment="JAVA_OPTS=-Djava.security.egd=file:///dev/urandom"
Environment="CATALINA_BASE=/opt/tomcat"
Environment="CATALINA_HOME=/opt/tomcat"
Environment="CATALINA_PID=/opt/tomcat/temp/tomcat.pid"
Environment="CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC"

ExecStart=/opt/tomcat/bin/startup.sh
ExecStop=/opt/tomcat/bin/shutdown.sh

RestartSec=10
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Recargamos la configuración del sistema
systemctl daemon-reload
# Inicia Tomcat
systemctl start tomcat
# Mostrará por línea de comandos si Tomcat se ha iniciado correctamente al ejecutar el script
echo '-----------------------------------------------------------'
systemctl status tomcat | cat
echo '-----------------------------------------------------------'
# Habilitamos el inicio automático del servicio durante el arranque del sistema
systemctl enable tomcat
# Permitimos el tráfico por el puerto 8080, por el que escucha Tomcat
systemctl restart tomcat
# Accede a Tomcat a traves de esta URL
echo "Accede a la interfaz de Tomcat con esta URL: http://54.90.218.138:8080"
