#!/bin/bash
# python debug1.py
# ./debug2.sh
pipeline="TrialBalance"
export em=""
export emline=""
export dm=""
export line=""
export tm=""
export result=0

export username=$(</etc/foo/username)
export password=$(</etc/foo/password)
export username2=$(</etc/foo/username2)
export password2=$(</etc/foo/password2)

# export em="none"
# export emline="none"
# export dm="none"
# export line="none"
# export tm="none"
# export result=0 


# printf "TrialBalance path= $PATH." | mail -s "Trial Balance Path" bgroves@buschegroup.com

script="AccountingYearCategoryType"
cd ../AccountingYearCategoryType
source AccountingYearCategoryType.sh 
# echo "AccountingYearCategoryType result=$result"

# reset variables
em=""
emline=""
dm=""
line=""
tm=""

if [[ $result -eq 0 ]]
then # if/then branch
  script="AccountingAccount"
  cd ../AccountingAccount
  source AccountingAccount.sh 
fi

# reset variables
em=""
emline=""
dm=""
line=""
tm=""

if [[ $result -eq 0 ]]
then # if/then branch
  script="AccountingPeriod"
  cd ../AccountingPeriod
  source AccountingPeriod.sh 
fi

# reset variables
em=""
emline=""
dm=""
line=""
tm=""

if [[ $result -eq 0 ]]
then # if/then branch
  script="AccountingBalanceUpdatePeriodRange"
  cd ../AccountingBalanceUpdatePeriodRange
  source AccountingBalanceUpdatePeriodRange.sh 
fi

# reset variables
em=""
emline=""
dm=""
line=""
tm=""

if [[ $result -eq 0 ]]
then # if/then branch
  script="AccountingBalanceAppendPeriodRange"
  cd ../AccountingBalanceAppendPeriodRange
  source AccountingBalanceAppendPeriodRange.sh 
fi

# reset variables
em=""
emline=""
dm=""
line=""
tm=""

if [[ $result -eq 0 ]]
then # if/then branch
  script="AccountPeriodBalanceDeletePeriodRange"
  cd ../AccountPeriodBalanceDeletePeriodRange
  source AccountPeriodBalanceDeletePeriodRange.sh 
fi

# reset variables
em=""
emline=""
dm=""
line=""
tm=""

if [[ $result -eq 0 ]]
then # if/then branch
  script="AccountPeriodBalanceRecreatePeriodRange"
  cd ../AccountPeriodBalanceRecreatePeriodRange
  source AccountPeriodBalanceRecreatePeriodRange.sh 
fi


if [[ $result -ne 0 ]]
then # if/then branch
  printf "Pipeline terminated at $script\n"
  printf "Pipeline terminated on $script script." | mail -s "MCP Pipeline Failure" bgroves@buschegroup.com

fi
