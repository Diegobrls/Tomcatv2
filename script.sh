#!/bin/bash

# Crear un usuario para Tomcat
useradd -m -d /opt/tomcat -U -s /bin/false tomcat_user

# Actualizar el sistema operativo
apt-get update

# Instalar la versión 17 de OpenJDK
apt-get install openjdk-17-jdk -y

# Comprobar la versión de Java
java -version

# Navegar a /tmp
cd /tmp

# Descargar el archivo de instalación de Apache Tomcat
wget https://dlcdn.apache.org/tomcat/tomcat-10/v10.1.18/bin/apache-tomcat-10.1.18.tar.gz

# Descomprimir el archivo descargado y moverlo a la ubicación de Tomcat
tar xzvf apache-tomcat-10*tar.gz -C /opt/tomcat --strip-components=1

# Cambiar el propietario y los permisos de los archivos de Tomcat
chown -R tomcat_user:tomcat_user /opt/tomcat/
chmod -R u+x /opt/tomcat/bin

# Configurar los usuarios para acceder a la interfaz de administración de Tomcat
cat << 'EOF' | tee /opt/tomcat/conf/tomcat-users.xml > /dev/null
<?xml version='1.0' encoding='utf-8'?>
<tomcat-users>
  <role rolename="manager-gui" />
  <user username="manager" password="manager_password" roles="manager-gui" />

  <role rolename="admin-gui" />
  <user username="admin" password="admin_password" roles="manager-gui,admin-gui" />
</tomcat-users>
EOF

# Configurar el archivo de contexto para el Manager de Tomcat
cat << 'EOF' | tee /opt/tomcat/webapps/manager/META-INF/context.xml > /dev/null
<?xml version="1.0" encoding="UTF-8"?>
<Context antiResourceLocking="false" privileged="true" >
  <CookieProcessor className="org.apache.tomcat.util.http.Rfc6265CookieProcessor"
                   sameSiteCookies="strict" />
</Context>
EOF

# Configurar el archivo de contexto para el Host Manager de Tomcat
cat << 'EOF' | tee /opt/tomcat/webapps/host-manager/META-INF/context.xml > /dev/null
<?xml version="1.0" encoding="UTF-8"?>
<Context antiResourceLocking="false" privileged="true" >
  <CookieProcessor className="org.apache.tomcat.util.http.Rfc6265CookieProcessor"
                   sameSiteCookies="strict" />
</Context>
EOF

# Crear un servicio systemd para Tomcat
JAVA_HOME_PATH=$(update-java-alternatives -l | awk '{print $3}')
CATALINA_HOME="/opt/tomcat"

cat <<EOF | tee /etc/systemd/system/tomcat.service > /dev/null
[Unit]
Description=Servidor Apache Tomcat
After=network.target

[Service]
Type=forking

User=tomcat_user
Group=tomcat_user

Environment="JAVA_HOME=$JAVA_HOME_PATH"
Environment="JAVA_OPTS=-Djava.security.egd=file:///dev/urandom"
Environment="CATALINA_BASE=$CATALINA_HOME"
Environment="CATALINA_HOME=$CATALINA_HOME"
Environment="CATALINA_PID=$CATALINA_HOME/temp/tomcat.pid"
Environment="CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC"

ExecStart=$CATALINA_HOME/bin/startup.sh
ExecStop=$CATALINA_HOME/bin/shutdown.sh

RestartSec=10
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Recargar el daemon
systemctl daemon-reload
# Iniciar el servicio Tomcat
systemctl start tomcat
# Comprobar el estado
systemctl status tomcat
# Habilitar el inicio automático
systemctl enable tomcat

echo "Accede a la interfaz de Tomcat con esta URL: http://54.90.218.138:8080"
