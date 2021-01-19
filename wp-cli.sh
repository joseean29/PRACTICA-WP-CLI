#!/bin/bash

#DECLARACIÓN DE LAS VARIABLES
IP=http://54.84.247.11
HTTPASSWD_DIR=/home/ubuntu
DB_ROOT_PASSWD=root
DB_NAME=wp_db
DB_USER=wp_user
DB_PASSWORD=wp_pass


# ---------------------------
# INSTALACIÓN DE LA PILA LAMP|
# ---------------------------
#Activamos la depuración del script
set -x

#Actualizamos la lista de paquetes y los actualizamos
apt update -y
apt upgrade -y

#INSTALACIÓN APACHE 
apt install apache2 -y


#INSTALACIÓN MYSQL 
apt install mysql-server -y


#INSTALACIÓN PHP
#Instalamos módulos PHP 
apt install php libapache2-mod-php php-mysql -y

#Reiniciamos el servicio Apache2
systemctl restart apache2



#CREACIÓN DE LA BASE DE DATOS DE WORDPRESS
#Aquí vamos a introducir gran parte de las variables que creamos anteriormente al principio del script

#Nos aseguramos de que la base de datos que vamos a crear no existe, y si existe, la borramos
mysql -u root <<< "DROP DATABASE IF EXISTS $DB_NAME;"

#Creamos la base de datos
mysql -u root <<< "CREATE DATABASE $DB_NAME;"

#Nos aseguramos de que no existe el usuario que vamos a crear, y si existe, lo borramos
mysql -u root <<< "DROP USER IF EXISTS $DB_USER@localhost;"

#Creamos el usuario para Wordpress
mysql -u root <<< "CREATE USER $DB_USER@localhost IDENTIFIED BY '$DB_PASSWORD';"

#Concedemos privilegios a nuestro usuario
mysql -u root <<< "GRANT ALL PRIVILEGES ON $DB_NAME.* TO $DB_USER@localhost;"

#Aplicamos cambios con un FLUSH
mysql -u root <<< "FLUSH PRIVILEGES;"



#---------------------
#INSTALACIÓN WORDPRESS|
#---------------------
#Nos movemos al directorio de Apache
cd /var/www/html

#Descargamos y guardamos el contenido de wp-cli.phar
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar

#Le asignamos permisos de ejecución
chmod +x wp-cli.phar

#Movemos el archivo y cambiamos el nombre 
mv wp-cli.phar /usr/local/bin/wp

#Eliminamos index.html
rm -rf index.html

# Descargamos el código fuente de Wordpress en español y le damos permisos
wp core download --locale=es_ES --allow-root

#Le damos permisos a la carpeta de Wordpress
chown -R www-data:www-data /var/www/html

#Creamos el archivo de configuración de Wordpress
wp config create --dbname=$DB_NAME --dbuser=$DB_USER --dbpass=$DB_PASSWORD --allow-root

#Instalamos Wordpress
wp core install --url=$IP --title="IAW - Jose Antonio Abad Jurado" --admin_user=admin --admin_password=admin --admin_email=test@test.com --allow-root
