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

dnf install maven -y &>>$LOG_FILE
VALIDATE $? "INSTALLATION OF MAVEN"
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

curl -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip  &>>$LOG_FILE
VALIDATE $? "DOWNLOADING THE SHIPPING APPLICATION CODE"
NEWLINE

cd /app &>>$LOG_FILE
unzip /tmp/shipping.zip &>>$LOG_FILE
sleep 5
echo -e "$Y UNZIPPING THE ZIP FILE $N"
VALIDATE $? "UNZIPPING THE FILE"
NEWLINE
mvn clean package &>>$LOG_FILE
VALIDATE $? "CLEAN PACKAGE"
NEWLINE
mv target/shipping-1.0.jar shipping.jar &>>$LOG_FILE
VALIDATE $? "JAR FILE RENAME"
NEWLINE

cp $SCRIPT_DIRECTORY/shipping.service /etc/systemd/system/shipping.service
VALIDATE $? "COPYING OF SHIPPING SERVICE"
NEWLINE

systemctl daemon-reload &>>$LOG_FILE
sleep 5
systemctl enable shipping &>>$LOG_FILE
systemctl start shipping &>>$LOG_FILE
VALIDATE $? "RELOAD,ENABLING & STARTING OF SHIPPING SERVICE" 
NEWLINE

dnf install mysql -y &>>$LOG_FILE
VALIDATE $? "INSTALLING MYSQL"
NEWLINE
echo -e "$Y Please SETUP MYSQL PASSWORD $N"
read -s MYSQL_ROOT_PASSWORD
NEWLINE

mysql -h mysql.devopsaws.store -u root -p$MYSQL_ROOT_PASSWORD -e 'use cities'
if [ $? -ne 0 ]
then
mysql -h mysql.devopsaws.store -uroot -p$MYSQL_ROOT_PASSWORD < /app/db/schema.sql
NEWLINE
mysql -h mysql.devopsaws.store -uroot -p$MYSQL_ROOT_PASSWORD < /app/db/app-user.sql
NEWLINE
mysql -h mysql.devopsaws.store -uroot -p$MYSQL_ROOT_PASSWORD < /app/db/master-data.sql
NEWLINE
else
echo -e "$Y DATA IS ALREADY LOADED, SO SKIPPING $N"
fi

NEWLINE
systemctl restart shipping &>>$LOG_FILE
VALIDATE $? "RESTART SHIPPING"
NEWLINE

END_TIME=$(date +%s)
TOTAL_TIME=$(($END_TIME - $START_TIME))

echo -e "$Y Total time taken to execute the script is $TOTAL_TIME seconds $N"
