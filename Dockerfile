FROM ubuntu

RUN apt-get update
RUN apt-get install -y          \
				curl            \	
				openssh-server  \
				ca-certificates \
				netcat          \
				less            \
			2>&1 > /dev/null

# DISABLE TO USE EXTERNAL MTA
RUN apt-get install -y postfix 2>&1 > /dev/null

RUN curl https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.deb.sh | bash

RUN apt install -y gitlab-ce

ADD ./entrypoint.sh /entrypoint.sh
                                  
ENTRYPOINT /entrypoint.sh
