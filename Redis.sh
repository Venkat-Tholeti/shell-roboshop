#!/bin/bash

source ./Common.sh
app_name=redis
APP_NAME=REDIS
ROOTACCESS_CHECK
NEWLINE

dnf module disable $app_name -y &>>$LOG_FILE
VALIDATE $? "DISABLING $APP_NAME MODULE"
NEWLINE
dnf module enable $app_name:7 -y &>>$LOG_FILE
VALIDATE $? "ENABLING $APP_NAME 7 MODULE"
NEWLINE
dnf install $app_name -y &>>$LOG_FILE
VALIDATE $? "INSTALLING $APP_NAME"
NEWLINE
sed -i -e 's/127.0.0.1/0.0.0.0/g' -e '/protected-mode/ c protected-mode no' /etc/$app_name/$app_name.conf &>>$LOG_FILE
VALIDATE $? "EDITING $APP_NAME CONF FILE FOR REMOTE CONNECTIONS AND PROTECT MODE CHANGES"
NEWLINE
systemctl enable $app_name &>>$LOG_FILE
systemctl start $app_name  &>>$LOG_FILE
VALIDATE $? "ENABLE & START $APP_NAME"

NEWLINE
PRINT_TIME







