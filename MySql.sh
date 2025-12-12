#!/bin/bash

source ./Common.sh
app_name=mysql
APP_NAME=MYSQL
ROOTACCESS_CHECK
NEWLINE


dnf install $app_name-server -y &>>$LOG_FILE
VALIDATE $? "INSTALLING $APP_NAME SERVER"
NEWLINE
systemctl enable mysqld &>>$LOG_FILE
NEWLINE
systemctl start mysqld  &>>$LOG_FILE
VALIDATE $? "ENABLING & STARTING OF $APP_NAME"
NEWLINE
echo -e "$Y Please SETUP $APP_NAME PASSWORD $N"
read -s MYSQL_ROOT_PASSWORD
mysql_secure_installation --set-root-pass $MYSQL_ROOT_PASSWORD
VALIDATE $? "ROOT PASSWORD FOR $APP_NAME"
NEWLINE

PRINT_TIME





















































































































