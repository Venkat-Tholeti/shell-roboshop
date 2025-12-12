#!/bin/bash

source ./Common.sh
app_name=catalogue
APP_NAME=CATALOGUE
ROOTACCESS_CHECK
NEWLINE
APPUSERCODE_SETUP
NEWLINE
NODEJS_SETUP
NEWLINE


cp $SCRIPT_DIRECTORY/mongodb.repo /etc/yum.repos.d/mongo.repo &>>$LOG_FILE
VALIDATE $? "COPYING MONGODB REPO"
NEWLINE

dnf install mongodb-mongosh -y &>>$LOG_FILE
VALIDATE $? "INSTALLING MONGODB CLIENT"
NEWLINE

STATUS=$(mongosh --host mongodb.devopsaws.store --eval 'db.getMongo().getDBNames().indexOf("catalogue")')
if [ $STATUS -lt 0 ]
then
    mongosh --host mongodb.devopsaws.store </app/db/master-data.js &>>$LOG_FILE
    VALIDATE $? "LOADING DATA INTO MONGODB"
else
    echo -e "$Y DATA IS ALREADY LOADED SO SKIPPING $N"
fi

PRINT_TIME







