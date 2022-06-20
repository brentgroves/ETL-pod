# build image
docker build --tag brentgroves/etl-pod:1 .
docker build --tag brentgroves/etl-pod:3 --build-arg CACHEBUST=$(date +%s) .


https://10.1.0.23

https://10.1.0.9
administrator@vsphere.local
Bu$ch3@dm!n



# start a container in the background
docker run --name etl-pod -d brentgroves/etl-pod:3
docker container ls -a

# Next, execute a command on the container.
docker exec -it etl-pod pwd
docker exec -it etl-pod pgrep cron

# Next, execute an interactive bash shell on the container.
docker exec -it etl-pod bash

# is python installed
ls /miniconda/bin
python

# check path
echo $PATH
/miniconda/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/mssql-tools/bin:/opt/mssql-tools18/bin

# Verify access to secret
cat /etc/foo/username
cat /etc/foo/username2
cat /etc/foo/password
cat /etc/foo/password2

kubectl get secret db-user-pass -o jsonpath='{.data.username}' | base64 --decode
kubectl get secret db-user-pass -o jsonpath='{.data.password}' | base64 --decode
kubectl get secret db-user-pass -o jsonpath='{.data.username2}' | base64 --decode
kubectl get secret db-user-pass -o jsonpath='{.data.password2}' | base64 --decode
 
# Can we run each ETL script.
This wont work any more because the secret is passed in from TrialBalance.sh
cd /etl/AccountingYearCategoryType
./truncate-logs.sh
truncate table Validation.Detailed_Production_History dph 
./AccountingYearCategoryType.sh
select * from Validation.Detailed_Production_History dph 

# Verify script history for each script
select * 
--into Archive.Script_History_06_06
from ETL.Script_History sh 
where Script_Key in (1,3,5) 
and Start_Time > '2022-06-08' 
order by Script_History_Key desc
-- delete from ETL.Script_History
where Script_Key = 1
and Start_Time > '2022-06-06' 


cd /etl/PipeLine
./TrialBalance.sh

# verify cron is running
pgrep cron



# activate the log-email job.
crontab -l
crontab /etc/cron.d/trial-balance-crontab
crontab -l
when you run crontab /etc/cron.d/trial-balance-crontab
a file get's created here /var/spool/cron/crontabs/root
cat /var/spool/cron/crontabs/root

# verify log file is getting written to
tail /var/log/cron.log

# verify you have recieved email

# deactivate the job
this will delete /var/spool/cron/crontabs/root
crontab -r

# verify no cron jobs are active
crontab -l
cd /validation
# send email from python script
python send_email.py
# wait to see if email is sent

# Test web service etl script 
python ws_to_cm_test.py
python ws_to_dw_test.py
# verify records were inserted into CM and DW
# select * from Validation.Detailed_Production_History dph 
# select * from Detailed_Production_History dph 

# exit container

# clean up
docker container rm --force 13fce4d91185

# push image
docker push brentgroves/etl-pod:1 


Test on K8s
# create pod
kubectl apply -f etl-pod.yaml

# verify pod was created 
kubectl get pods -o wide

# shell to pod
kubectl exec --stdin --tty etl-pod -- /bin/bash

# GO TO THE BEGINNING AND DO SAME TESTS YOU 
# DID FOR DOCKER

# is cron running? YES
pgrep cron

# delete pod
kubectl delete pod etl-pod

# view the cron log
tail /var/log/cron.log
# empy the cron log
cat /dev/null > /var/log/cron.log

# can we see the mobex mail server? 
dig mobexglobal-com.mail.protection.outlook.com
# can we send an email?
echo "Testing msmtp from ${HOSTNAME} with mail command" | mail -s "test mail from cron-test pod" bgroves@buschegroup.com

# activate the email job.
crontab /etc/cron.d/email-cron
crontab -l
# wait to see if email is sent

# activate the log-email job.
crontab /etc/cron.d/log-email-cron
crontab -l
# empy the cron log
cat /dev/null > /var/log/cron.log
# view the cron log
tail /var/log/cron.log

# a# wait to see if /var/log/cron.log is being populate and email is sent

# deactivate them email job
crontab -r
crontab -l

# send email from python script
python send_email.py
# wait to see if email is sent

# Test web service etl script 
python ws_to_cm_test.py
python ws_to_dw_test.py
# verify records were inserted into CM and DW
# select * from Validation.Detailed_Production_History dph 
# select * from Detailed_Production_History dph 

https://gist.github.com/movd/7a9e3db63d076f85d16c7dcde62fe401
mobexglobal-com.mail.protection.outlook.com
https://marlam.de/msmtp/
http://manpages.ubuntu.com/manpages/bionic/en/man1/msmtp.1.html

Check that default account is pointing to mobexglobal smtp server. 
vim /etc/msmtprc

Make sure alias root has been added and the mail transfer agent points to msmtp
vim /etc/mail.rc
set mta=/usr/bin/msmtp
alias root root<bgroves@buschegroup.com>



Set these aliases.
# Send root to Jane
root: bgroves@buschegroup.com
   
# Send everything else to admin
default: bgroves@buschegroup.com
vim /etc/aliases

can we see the mobex mail server?
dig mobexglobal-com.mail.protection.outlook.com
can we send an email?
echo "Testing msmtp from ${HOSTNAME} with mail command" | mail -s "test mail 2 from py-etl-training pod" bgroves@buschegroup.com


send email from python script
python send_email.py

Test web service etl script 
python ws_to_cm_test.py
python ws_to_dw_test.py