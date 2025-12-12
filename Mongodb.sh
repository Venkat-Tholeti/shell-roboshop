#!/bin/bash

source ./Common.sh
app_name=mongodb
check_root
NEWLINE

cp mongodb.repo /etc/yum.repos.d/mongo.repo &>>$LOG_FILE
VALIDATE $? "COPYING MONGODB REPO"
NEWLINE
dnf install mongodb-org -y &>>$LOG_FILE
VALIDATE $? "INSTALLING MONGODB SERVER"
NEWLINE
systemctl enable mongod &>>$LOG_FILE
VALIDATE $? "ENABLING MONGODB SERVER"
NEWLINE
systemctl start mongod &>>$LOG_FILE
VALIDATE $? "STARTING MONGODB SERVER"
NEWLINE
sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf &>>$LOG_FILE
VALIDATE $? "EDITING MONGOD CONF FILE FOR REMOTE CONNECTIONS"
NEWLINE
systemctl restart mongod &>>$LOG_FILE
VALIDATE $? "MONGODB RESTART"

NEWLINE
print_time