FROM ubuntu

RUN apt-get update
RUN apt-get install -y curl openssh-server ca-certificates 2>&1 > /dev/null

# DISABLE TO USE EXTERNAL MTA
RUN apt-get install -y postfix 2>&1 > /dev/null

RUN curl https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.deb.sh | bash

ADD ./entrypoint.sh /entrypoint.sh
                                  
ENTRYPOINT /entrypoint.sh
