#!/bin/bash

for x in /opt/gitlab/sv /run $(ls -d /tmp/gitaly-ruby* 2>/dev/null) ; do
    find $x \
        \( \
          -type f \
          -o -type s \
        \) \(\
          -name pid \
          -o -name "*.pid" \
          -o -name "socket.?" \
        \) \
        -delete ;
done

 /opt/gitlab/embedded/bin/runsvdir-start &

# wait for redis server
if [ ! -z "$REDIS_SERVER" ]; then
	# configure redis server
	sed -i "s/.*redis\['enable'\] =.*/redis['enable'] = false/g" /etc/gitlab/gitlab.rb
	sed -i "s/.*gitlab_rails\['redis_host'\].*/gitlab_rails['redis_host'] = 'redis'/g" /etc/gitlab/gitlab.rb
	
	echo "wait for redis server..."
	while ! nc -z redis 6379; do
		echo "wait for redis server..."
		sleep 5
	done
fi

if [ ! -z "$POSTGRES_SERVER" ]; then
	# configure postgres server
	sed -i "s/.*postgresql\['enable'\] =.*/postgresql['enable'] = false/g" /etc/gitlab/gitlab.rb
	sed -i "s/.*gitlab_rails\['db_adapter'\].*/gitlab_rails['db_adapter'] = 'postgresql'/g" /etc/gitlab/gitlab.rb	
	sed -i "s/.*gitlab_rails\['db_host'\].*/gitlab_rails['db_host'] = 'postgres'/g" /etc/gitlab/gitlab.rb	
	sed -i "s/.*gitlab_rails\['db_password'\].*/gitlab_rails['db_password'] = 'Start2020'/g" /etc/gitlab/gitlab.rb

	echo "wait for postgres server..."
	while ! nc -z postgres 5432; do	
		echo "wait for postgres server..."
		sleep 5
	done;
fi;

# configure hostname
grep -Eq "^external_url .*$HOSTNAME" /etc/gitlab/gitlab.rb ||
	( sed -i "s~.*external_url.*~external_url  \"${HOSTNAME}\"~g" /etc/gitlab/gitlab.rb &&
	  gitlab-ctl reconfigure )

while true; do
	echo start
	sleep 1000;
done;