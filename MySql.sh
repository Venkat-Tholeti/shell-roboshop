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

dnf install mysql-server -y &>>$LOG_FILE
VALIDATE $? "INSTALLING MYSQL SERVER"
NEWLINE
systemctl enable mysqld &>>$LOG_FILE
NEWLINE
systemctl start mysqld  &>>$LOG_FILE
VALIDATE $? "ENABLING & STARTING OF MYSQL"
NEWLINE
echo -e "$Y Please SETUP MYSQL PASSWORD $N"
read -s MYSQL_ROOT_PASSWORD
mysql_secure_installation --set-root-pass $MYSQL_ROOT_PASSWORD
VALIDATE $? "ROOT PASSWORD FOR MYSQL"
NEWLINE

END_TIME=$(date +%s)
TOTAL_TIME=$(($END_TIME - $START_TIME))

echo -e "$Y Total time taken to execute the script is $TOTAL_TIME seconds $N"





















































































































