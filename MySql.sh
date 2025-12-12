#!/bin/bash

source ./Common.sh
app_name=mysql
APP_NAME=MYSQL
ROOTACCESS_CHECK
NEWLINE


dnf install $app_name-server -y &>>$LOG_FILE
VALIDATE $? "INSTALLING $APP_NAME SERVER"
NEWLINE
systemctl enable $app_named &>>$LOG_FILE
NEWLINE
systemctl start $app_named  &>>$LOG_FILE
VALIDATE $? "ENABLING & STARTING OF $APP_NAME"
NEWLINE
echo -e "$Y Please SETUP $APP_NAME PASSWORD $N"
read -s $APP_NAME_ROOT_PASSWORD
$app_name_secure_installation --set-root-pass $$APP_NAME_ROOT_PASSWORD
VALIDATE $? "ROOT PASSWORD FOR $APP_NAME"
NEWLINE

PRINT_TIME





















































































































