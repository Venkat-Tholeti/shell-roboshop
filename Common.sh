#!/bin/bash

START_TIME=$(date +%s)
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

ROOTACCESS_CHECK(){
if [ $USERID -ne 0 ]
then 
   echo -e "$R ERROR: USER NEED TO SWITCH TO ROOT ACCESS $N" | tee -a $LOG_FILE
   exit 1 
else
   echo -e "$G USER HAS ROOT PRIVILEGES $N" | tee -a $LOG_FILE
fi
}

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

NODEJS_SETUP(){
dnf module disable nodejs -y &>>$LOG_FILE
VALIDATE $? "DISABLE OLD MODULE OF NODEJS" 
NEWLINE
dnf module enable nodejs:20 -y &>>$LOG_FILE
VALIDATE $? "ENABLE MODULE20 OF NODEJS"
NEWLINE
dnf install nodejs -y &>>$LOG_FILE
VALIDATE $? "INSTALLATION OF NODEJS"
NEWLINE
npm install &>>$LOG_FILE
VALIDATE $? "DEPENDENCIES  INSTALLATION"
NEWLINE
}

APPUSERCODE_SETUP(){
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

curl -o /tmp/$app_name.zip https://roboshop-artifacts.s3.amazonaws.com/$app_name-v3.zip  &>>$LOG_FILE
VALIDATE $? "DOWNLOADING THE $APP_NAME APPLICATION CODE"
NEWLINE

cd /app &>>$LOG_FILE
unzip /tmp/$app_name.zip &>>$LOG_FILE
sleep 5
echo -e "$Y UNZIPPING THE ZIP FILE IS $N"
}

MAVEN_SETUP(){
dnf install maven -y &>>$LOG_FILE
VALIDATE $? "INSTALLATION OF MAVEN AND JAVA"
NEWLINE
mvn clean package &>>$LOG_FILE
VALIDATE $? "CLEAN PACKAGE"
NEWLINE
mv target/$app_name-1.0.jar $app_name.jar &>>$LOG_FILE
VALIDATE $? "JAR FILE RENAME"
NEWLINE
}


SYSTEMD_SETUP(){
cp $SCRIPT_DIRECTORY/$app_name.service /etc/systemd/system/$app_name.service &>>$LOG_FILE
VALIDATE $? "COPYING $APP_NAME SERVICE"
NEWLINE

systemctl daemon-reload &>>$LOG_FILE
sleep 5
systemctl enable $app_name &>>$LOG_FILE
systemctl start $app_name &>>$LOG_FILE
VALIDATE $? "RELOAD,ENABLING & STARTING OF $APP_NAME SERVICE" 
NEWLINE    
}


PRINT_TIME(){
END_TIME=$(date +%s)
TOTAL_TIME=$(($END_TIME - $START_TIME))
NEWLINE
echo -e "$Y Total time taken to execute the script is $TOTAL_TIME seconds $N"
}