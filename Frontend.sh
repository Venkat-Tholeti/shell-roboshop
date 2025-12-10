#!/bin/bash

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
LOGS_FOLDER="/var/log/shellscript.logs"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"
SCRIPT_DIRECTORY=$PWD

mkdir -p $LOGS_FOLDER
echo -e "$G script started executing at $(date)" &>>$LOG_FILE
echo -e "$Y Logs stored at  $LOG_FILE"

USERID=$(id -u)

if [ $USERID -ne 0 ]
then 
   echo -e "$R ERROR: USER NEED TO SWITCH TO ROOT ACCESS $N" | tee -a $LOG_FILE
   exit 1 
else
   echo -e "$G USER HAS ROOT PRIVILEGES $N" | tee -a $LOG_FILE
fi

#FUNCTION NAME WE GAVE AS VALIDATE & NEWLINE (name our choice)
# we can provide arguments to function as we do it for script
#VALIDATE $? MYSQL  --> here 1st argument is exit status $1 = $?, 2nd argument is what we tried to install $2 =MYSL, PYTHON3 , NGINX

NEWLINE(){
      echo ""
}

VALIDATE(){
    if [ $1 -eq 0 ]
    then
        echo -e "$G $2 IS SUCCESS $N" | tee -a $LOG_FILE
    else 
        echo -e "$R $2 IS FAILURE $N" | tee -a $LOG_FILE
        exit 1
    fi
}

dnf module disable nginx -y &>>$LOG_FILE
VALIDATE $? "DISABLE OLD MODULE OF NGINX" 
NEWLINE
dnf module enable nginx:1.24 -y &>>$LOG_FILE
VALIDATE $? "ENABLE MODULE:1.24 OF NGINX"
NEWLINE
dnf install nginx -y &>>$LOG_FILE
VALIDATE $? "INSTALLATION OF NGINX"
NEWLINE

systemctl enable nginx &>>$LOG_FILE
VALIDATE $? "ENABLING NGINX"
NEWLINE
systemctl start nginx &>>$LOG_FILE
VALIDATE $? "STARTING NGINX"
NEWLINE

rm -rf /usr/share/nginx/html/* &>>$LOG_FILE
VALIDATE $? "REMOVING DEFAULT CONTENT"
NEWLINE

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip &>>$LOG_FILE
VALIDATE $? "DOWNLOADING FRONTEND CONTENT"
NEWLINE

cd /usr/share/nginx/html &>>$LOG_FILE
unzip /tmp/frontend.zip &>>$LOG_FILE
VALIDATE $? "UNZIPPING THE CONTENTS"
NEWLINE

rm -rf /etc/nginx/nginx.conf &>>$LOG_FILE
VALIDATE $? "REMOVE DEFAULT NGINX CONF FILE"
NEWLINE

cp $SCRIPT_DIRECTORY/nginx.conf /etc/nginx/nginx.conf &>>$LOG_FILE
VALIDATE $? "COPYING NGINX CONF FILE"
NEWLINE

systemctl restart nginx &>>$LOG_FILE
VALIDATE $? "RESTART NGINX"








