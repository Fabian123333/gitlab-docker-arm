#!/bin/bash

# wait for redis server
if [ ! -z "REDIS_SERVER" ]; then
	# configure redis server
	sed "s/.*gitlab_rails\['redis_host'\].*/gitlab_rails['redis_host'] = 'redis'/g" /etc/gitlab/gitlab.rb | grep redis_host
	
	echo "wait for redis server..."
	while ! nc -z redis 6379; do
		echo "wait for redis server..."
		sleep 5
	done
fi

# configure hostname
grep -Eq "^external_url .*$HOSTNAME" /etc/gitlab/gitlab.rb ||
	sed -i "s/.*external_url.*/external_url  \"${HOSTNAME}\"/g" /etc/gitlab/gitlab.rb &&
	gitlab-ctl reconfigure


while true; do
	echo start
	sleep 1000;
done;