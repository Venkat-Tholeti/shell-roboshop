#!/bin/bash

source ./Common.sh
app_name=mongodb
APP_NAME=MONGODB
ROOTACCESS_CHECK
NEWLINE

cp mongodb.repo /etc/yum.repos.d/mongo.repo &>>$LOG_FILE
VALIDATE $? "COPYING $APP_NAME REPO"
NEWLINE
dnf install mongodb-org -y &>>$LOG_FILE
VALIDATE $? "INSTALLING $APP_NAME SERVER"
NEWLINE
systemctl enable mongod &>>$LOG_FILE
VALIDATE $? "ENABLING $APP_NAME SERVER"
NEWLINE
systemctl start mongod &>>$LOG_FILE
VALIDATE $? "STARTING $APP_NAME SERVER"
NEWLINE
sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf &>>$LOG_FILE
VALIDATE $? "EDITING MONGOD CONF FILE FOR REMOTE CONNECTIONS"
NEWLINE
systemctl restart mongod &>>$LOG_FILE
VALIDATE $? "$APP_NAME RESTART"

NEWLINE
PRINT_TIME