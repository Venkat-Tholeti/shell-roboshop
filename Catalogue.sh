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

dnf module disable nodejs -y &>>$LOG_FILE
VALIDATE $? "DISABLE OLD MODULE OF NODEJS" 
NEWLINE
dnf module enable nodejs:20 -y &>>$LOG_FILE
VALIDATE $? "ENABLE MODULE20 OF NODEJS"
NEWLINE
dnf install nodejs -y &>>$LOG_FILE
VALIDATE $? "INSTALLATION OF NODEJS"
NEWLINE

id roboshop
if [ $? -ne 0 ]
then 
   useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
   VALIDATE $? "CREATING APPLICATION USER"
else
   echo -e "$Y USER ALREADY EXIST, SKIPPING $N"
fi

NEWLINE
mkdir -p /app &>>$LOG_FILE
VALIDATE $? "APP DIRECTORY CREATION"
NEWLINE

rm -rf /app/* # removing any contents in the app directory if we rerun the script

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip  &>>$LOG_FILE
VALIDATE $? "DOWNLOADING THE CATALOGUE APPLICATION CODE"
NEWLINE

cd /app &>>$LOG_FILE
unzip /tmp/catalogue.zip &>>$LOG_FILE
sleep 5
echo -e "$Y UNZIPPING THE ZIP FILE $N"
NEWLINE

npm install &>>$LOG_FILE
VALIDATE $? "UNZIP & DEPENDECNCIES  INSTALLATION"
NEWLINE

cp $SCRIPT_DIRECTORY/catalogue.service /etc/systemd/system/catalogue.service &>>$LOG_FILE
VALIDATE $? "COPYING CATALOGUE SERVICE"
NEWLINE

systemctl daemon-reload &>>$LOG_FILE
systemctl enable catalogue &>>$LOG_FILE
systemctl start catalogue &>>$LOG_FILE
VALIDATE $? "RELOAD,ENABLING & STARTING OF CATALOGUE SERVICE" 
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







