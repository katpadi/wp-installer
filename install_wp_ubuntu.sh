#!/bin/bash
echo "------------------------------------------"
echo " This script will do the following: "
echo "------------------------------------------"
echo ""
echo "1. Download and install Wordpress."
echo "2. Create database for you. (Will ask for mysql root pw)"
echo "3. Set up the config file of Wordpress."
echo "4. Move your site to the web server."
echo ""
echo "TLDR IT WILL SET UP WORDPRESS INSTANCE LOCALLY FOR YOU."
echo "------------------------------------------"
read -p "Do you want to proceed??? [y/n]" -n 1 -r
echo    # (optional) move to a new line
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    exit 1
fi

thepathofinstallation="$PWD"

echo "Will download and set up latest WP in your local machine..."
wget http://wordpress.org/latest.tar.gz
tar -xzvf latest.tar.gz

#MySQL stuff
echo -n "Enter project name: "
read proj
printf "Ok.\n\n"

echo -n "Pls enter your MySQL root pw and I will install for you: "
read -s rootpw

dbname=$proj"_db"
dbpw=$proj"_password"
dbuser=$proj"_user"

echo ""
read -p "Press [Enter] key to create MySQL database now..."
echo ""

db="create database $dbname;GRANT ALL PRIVILEGES ON $dbname.* TO $dbuser@localhost IDENTIFIED BY '$dbpw';FLUSH PRIVILEGES;"
mysql -u root -p$rootpw -e "$db"

if [ $? != "0" ]; then
 echo "[Error]: Database creation failed"
 exit 1
else
  echo "------------------------------------------"
  echo " Database has been created !!! "
  echo "------------------------------------------"
  echo " We will use this in your WP config file: "
  echo ""
  echo " DB Name: $dbname"
  echo " DB User: $dbuser"
  echo " DB Pass: $dbpw"
  echo ""
  echo "------------------------------------------"
fi

echo ""
read -p "Press [Enter] to proceed..."
echo ""

#Rename project
mv wordpress $proj

if [ $? != "0" ]; then
 echo "[Error]: No wordpress"
 exit 1
fi

cd $proj

#Config file stuff
printf "Will configure config stuff for you...\n\n"
cp "wp-config-sample.php" "wp-config.php"

sed -i -e "s/database_name_here/$dbname/g" wp-config.php
sed -i -e "s/username_here/$dbuser/g" wp-config.php
sed -i -e "s/password_here/$dbpw/g" wp-config.php

if [ $? != "0" ]; then
 echo "[Error]: sed issue"
 exit 1
fi

echo ""
read -p "Press [Enter] to move your project to the webserver...."
echo ""

#Copy files
sudo rsync -avP "$thepathofinstallation/$proj" /var/www/

#Permission stuff
cd /var/www/
sudo chown www-data:www-data * -R

echo "------------------------------------------"
echo " Yay! "
echo ""
echo " Go to localhost/$proj in your browser to setup your site! "
echo "------------------------------------------"
#sudo usermod -a -G www-data username
