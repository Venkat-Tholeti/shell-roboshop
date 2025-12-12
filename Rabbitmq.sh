#!/bin/bash

source ./Common.sh
app_name=rabbitmq   
APP_NAME=RABBITMQ
ROOTACCESS_CHECK
NEWLINE


cp $app_name.repo /etc/yum.repos.d/$app_name.repo &>>$LOG_FILE
VALIDATE $? "COPYING THE REPO"
NEWLINE

dnf install $app_name-server -y &>>$LOG_FILE
VALIDATE $? "INSTALLTION OF $APP_NAME"
NEWLINE

systemctl enable $app_name-server &>>$LOG_FILE
systemctl start $app_name-server &>>$LOG_FILE
VALIDATE $? "ENABLING AND STARTING OF $APP_NAME"
NEWLINE

echo -e "$Y PLEASE SETUP PASSWORD $N"
read -s PASSWORD

rabbitmqctl add_user roboshop $PASSWORD &>>$LOG_FILE
if [ $? -eq 0 ]
then
   echo -e "$G USERNAME AND PASSWORD CREATED $N"
   VALIDATE $? "USERNAME & PASSWORD CREATION"
else
    echo -e "$Y SKIPPING $N"
fi

rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>>$LOG_FILE
VALIDATE $? "PERMISSIONS SET"

PRINT_TIME
