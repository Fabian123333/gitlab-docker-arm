FROM ubuntu

RUN apt-get update
RUN apt-get install -y            \
				curl              \	
				openssh-server    \
				ca-certificates   \
				postgresql-client \
				netcat            \
				less              \
			2>&1 > /dev/null

# DISABLE TO USE EXTERNAL MTA
RUN apt-get install -y postfix 2>&1 > /dev/null

# Install node
RUN curl --location https://deb.nodesource.com/setup_12.x | bash -
RUN apt install -y nodejs 2>&1 > /dev/null

RUN curl --silent --show-error https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update 2>&1 > /dev/null
RUN apt-get install yarn 2>&1 > /dev/null

RUN curl https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.deb.sh | bash 2>&1 > /dev/null

RUN apt install -y gitlab-ce

VOLUME ["/etc/gitlab", "/var/opt/gitlab", "/var/log/gitlab"]

ADD ./entrypoint.sh /entrypoint.sh
                                  
ENTRYPOINT /entrypoint.sh
