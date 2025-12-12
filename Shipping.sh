#!/bin/bash

source ./Common.sh
app_name=shipping
APP_NAME=SHIPPING
ROOTACCESS_CHECK
NEWLINE





APPUSERCODE_SETUP

MAVEN_SETUP
SYSTEMD_SETUP


dnf install mysql -y &>>$LOG_FILE
VALIDATE $? "INSTALLING MYSQL"
NEWLINE
echo -e "$Y Please SETUP MYSQL PASSWORD $N"
read -s MYSQL_ROOT_PASSWORD
NEWLINE

mysql -h mysql.devopsaws.store -u root -p$MYSQL_ROOT_PASSWORD -e 'use cities'
if [ $? -ne 0 ]
then
mysql -h mysql.devopsaws.store -uroot -p$MYSQL_ROOT_PASSWORD < /app/db/schema.sql
NEWLINE
mysql -h mysql.devopsaws.store -uroot -p$MYSQL_ROOT_PASSWORD < /app/db/app-user.sql
NEWLINE
mysql -h mysql.devopsaws.store -uroot -p$MYSQL_ROOT_PASSWORD < /app/db/master-data.sql
NEWLINE
else
echo -e "$Y DATA IS ALREADY LOADED, SO SKIPPING $N"
fi

NEWLINE
systemctl restart $app_name &>>$LOG_FILE
VALIDATE $? "RESTART $APP_NAME"
NEWLINE

PRINT_TIME
