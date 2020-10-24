FROM arm32v7/debian

RUN apt-get update
RUN apt-get install -y curl openssh-server ca-certificates

# DISABLE TO USE EXTERNAL MTA
RUN apt-get install -y postfix

RUN curl https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.deb.sh | bash

ADD entrypoint.sh /entrypoint.sh

ENTRYPOINT /entrypoint.sh