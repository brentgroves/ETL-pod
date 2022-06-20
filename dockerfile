#
#   ref https://github.com/tebeka/pythonwise/blob/master/docker-miniconda/Dockerfile
#
#   miniconda vers: http://repo.continuum.io/miniconda
#   sample variations:
#     Miniconda3-latest-Linux-armv7l.sh
#     Miniconda3-latest-Linux-x86_64.sh
#     Miniconda3-py38_4.10.3-Linux-x86_64.sh
#     Miniconda3-py37_4.10.3-Linux-x86_64.sh
#
#   py vers: https://anaconda.org/anaconda/python/files
#   tf vers: https://anaconda.org/anaconda/tensorflow/files
#   tf-mkl vers: https://anaconda.org/anaconda/tensorflow-mkl/files
# https://hub.docker.com/_/ubuntu?tab=tags&page=1&name=20.04

# ARG UBUNTU_VER=18.04
ARG UBUNTU_VER=20.04
ARG CONDA_VER=latest
ARG OS_TYPE=x86_64
ARG PY_VER=3.10
ARG TF_VER=2.5.0
ARG ZEEP_VER=4.1.0
ARG PYODBC_VER=4.0.32 
ARG PANDAS_VER=1.4.2
ARG SQLALCHEMY_VER=1.4.32
FROM ubuntu:${UBUNTU_VER}
# FROM ubuntu:20.04


# https://futurestud.io/tutorials/ubuntu-debian-fix-sudo-command-not-found
# Open question.  Do I need to run as non-root user
# https://code.visualstudio.com/remote/advancedcontainers/add-nonroot-user#:~:text=Many%20Docker%20images%20use%20root,that%20you%20should%20know%20about.
# RUN apt-get install sudo -y 

# had problems installing all of this on one layer.

RUN apt-get update && apt-get install -yq \
  tzdata \
  ksh \
  apt-utils \
  apt-transport-https \
  ca-certificates \
  neofetch \
  software-properties-common \
  curl \
  wget \
  dnsutils \
  iputils-ping \
  netcat \
  tree \
  curl \
  vim \
  jq \
  msmtp \
  msmtp-mta \
  mailutils \ 
  bsd-mailx \
  cron \
  && ln -fs /usr/share/zoneinfo/America/Indiana/Indianapolis /etc/localtime \
  && dpkg-reconfigure -f noninteractive tzdata  \
  && rm -rf /var/lib/apt/lists/*
  # https://dev.to/0xbf/set-timezone-in-your-docker-image-d22
# ENV TZ="America/Indiana/Indianapolis"

# Configure mail utility
WORKDIR /install/mail
COPY ./install/mail/msmtprc /etc/msmtprc
COPY ./install/mail/mail.rc /etc/mail.rc
COPY ./install/mail/aliases /etc/aliases

# Add microsoft repo 
RUN curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
RUN curl https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/prod.list > /etc/apt/sources.list.d/mssql-release.list
RUN apt-get update

# Install Microsoft odbc utilities for Busche-sql which requires the older driver.
RUN DEBIAN_FRONTEND=noninteractive ACCEPT_EULA=Y apt-get install -y msodbcsql17
RUN DEBIAN_FRONTEND=noninteractive ACCEPT_EULA=Y apt-get install -y mssql-tools
RUN echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc

# Install Microsoft odbc utilities for Azure SQL which requires the older driver.
RUN DEBIAN_FRONTEND=noninteractive ACCEPT_EULA=Y apt-get install -y msodbcsql18
RUN DEBIAN_FRONTEND=noninteractive ACCEPT_EULA=Y apt-get install -y mssql-tools18
RUN echo 'export PATH="$PATH:/opt/mssql-tools18/bin"' >> ~/.bashrc
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y unixodbc-dev


# Use the above args during building https://docs.docker.com/engine/reference/builder/#understand-how-arg-and-from-interact
ARG CONDA_VER
ARG OS_TYPE
# Install miniconda to /miniconda
RUN curl -LO "http://repo.continuum.io/miniconda/Miniconda3-${CONDA_VER}-Linux-${OS_TYPE}.sh"
RUN bash Miniconda3-${CONDA_VER}-Linux-${OS_TYPE}.sh -p /miniconda -b
RUN rm Miniconda3-${CONDA_VER}-Linux-${OS_TYPE}.sh
ENV PATH=/miniconda/bin:${PATH}
RUN conda update -y conda

ARG PY_VER
ARG ZEEP_VER
ARG PYODBC_VER 
ARG PANDAS_VER
ARG SQLALCHEMY_VER


# Install packages from anaconda.
RUN conda install -c anaconda -y python=${PY_VER}
RUN conda install -c anaconda -y \
    pyodbc=${PYODBC_VER} \ 
    pandas=${PANDAS_VER} \
    sqlalchemy=${SQLALCHEMY_VER}

# Install packages from conda-forge
RUN conda install -c conda-forge -y \
    zeep=${ZEEP_VER} 


# Install Plex ODBC driver
WORKDIR /install/odbc
COPY ./install/odbc/PROGRESS_DATADIRECT_OPENACCESS_OAODBC_8.1.0.HOTFIX_LINUX_64.tar .
RUN tar -xf PROGRESS_DATADIRECT_OPENACCESS_OAODBC_8.1.0.HOTFIX_LINUX_64.tar
COPY ./install/odbc/PlexDriverInstall.py ./
RUN python PlexDriverInstall.py 
COPY ./install/odbc/odbc.ini /etc/
COPY ./install/odbc/odbc64.ini /usr/oaodbc81/
ENV LD_LIBRARY_PATH="/usr/oaodbc81/lib64"
ENV OASDK_ODBC_HOME="/usr/oaodbc81/lib64"
ENV ODBCINI="/usr/oaodbc81/odbc64.ini"

# https://www.freecodecamp.org/news/docker-cache-tutorial/
# docker build -t my-custom-nginx --build-arg CACHEBUST=$(date +%s) .
# Custom cache invalidation
ARG CACHEBUST=1

# Setup sample cron job and log
# RUN touch /var/log/cron.log
# COPY ./install/cron/log-email-cron /etc/cron.d/log-email-cron
# RUN chmod 0644 /etc/cron.d/log-email-cron
# RUN crontab /etc/cron.d/log-email-cron
COPY ./install/cron/trial-balance-crontab /etc/cron.d/trial-balance-crontab
# cp /etc/cron.d/trial-balance-crontab /var/spool/cron/crontabs/root
# https://www.howtogeek.com/devops/how-to-use-cron-with-your-docker-containers/
# COPY ./install/cron/trial-balance-crontab /var/spool/cron/crontabs/root
RUN chmod 0644 /etc/cron.d/trial-balance-crontab && crontab /etc/cron.d/trial-balance-crontab
# RUN chmod 0644 /var/spool/cron/crontabs/root
# RUN crontab /etc/cron.d/trial-balance-crontab
# COPY example-crontab /etc/cron.d/example-crontab
# RUN chmod 0644 /etc/cron.d/example-crontab &&
# crontab /etc/cron.d/example-crontab


WORKDIR /validation
COPY ./validation/*.py ./
COPY ./validation/*.wsdl ./


WORKDIR /etl/PipeLine
COPY ./etl/PipeLine .

WORKDIR /etl/wsdl
COPY ./etl/wsdl .


WORKDIR /etl/AccountingYearCategoryType
COPY ./etl/AccountingYearCategoryType .

WORKDIR /etl/AccountingAccount
COPY ./etl/AccountingAccount .

WORKDIR /etl/AccountingPeriod
COPY ./etl/AccountingPeriod .

WORKDIR /etl/AccountingBalanceUpdatePeriodRange
COPY ./etl/AccountingBalanceUpdatePeriodRange .

WORKDIR /etl/AccountingBalanceAppendPeriodRange
COPY ./etl/AccountingBalanceAppendPeriodRange .

WORKDIR /etl/AccountPeriodBalanceDeletePeriodRange
COPY ./etl/AccountPeriodBalanceDeletePeriodRange .

WORKDIR /etl/AccountPeriodBalanceRecreatePeriodRange
COPY ./etl/AccountPeriodBalanceRecreatePeriodRange .

WORKDIR /etl/misc
COPY ./etl/misc .


# https://blog.yaakov.online/kubernetes-getting-pods-to-talk-to-the-internet/#:~:text=If%20you%20install%20this%20with,make%20connections%20to%20the%20Internet.
# some devs like to let it hang https://stackoverflow.com/a/42873832/868736
# ENTRYPOINT ["tail", "-f", "/dev/null"]
# CMD [ "python", "soapTest.py" ]
# The following did not work.  crontab -l showed no crontab
# ENTRYPOINT cron start && tail -f /var/log/cron.log
# crontab /etc/cron.d/trial-balance-crontab
# The following entry point could work I have not tried it
# https://stackoverflow.com/questions/610839/how-can-i-programmatically-create-a-new-cron-job
# ENTRYPOINT cron start && cat /etc/cron.d/trial-balance-crontab |crontab - && tail -f /var/log/cron.log
# https://www.howtogeek.com/devops/how-to-use-cron-with-your-docker-containers/
ENTRYPOINT ["cron", "-f"] 
# https://www.howtogeek.com/devops/how-to-use-cron-with-your-docker-containers/
