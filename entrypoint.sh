#!/bin/bash

export PGPASSWORD=Start2020

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
	echo "create postgres config"
	
	sed -i "s/.*postgresql\['enable'\] =.*/postgresql['enable'] = false/g" /etc/gitlab/gitlab.rb
	sed -i "s/.*gitlab_rails\['db_adapter'\].*/gitlab_rails['db_adapter'] = 'postgresql'/g" /etc/gitlab/gitlab.rb	
	sed -i "s/.*gitlab_rails\['db_host'\].*/gitlab_rails['db_host'] = 'postgres'/g" /etc/gitlab/gitlab.rb	
	sed -i "s/.*gitlab_rails\['db_username'\].*/gitlab_rails['db_username'] = 'postgres'/g" /etc/gitlab/gitlab.rb
	sed -i "s/.*gitlab_rails\['db_password'\].*/gitlab_rails['db_password'] = 'Start2020'/g" /etc/gitlab/gitlab.rb

	psql -h postgres -U postgres -c "CREATE USER gitlab CREATEDB;"
	psql -h postgres -U postgres -c "CREATE EXTENSION IF NOT EXISTS pg_trgm;"
	psql -h postgres -U postgres -c "CREATE EXTENSION IF NOT EXISTS btree_gist;"
	psql -h postgres -U postgres -c "CREATE DATABASE gitlabhq_production OWNER gitlab;"
	psql -h postgres -U postgres -c "ALTER USER gitlab WITH PASSWORD 'Start2020';"

	echo "wait for postgres server..."
	while ! nc -z postgres 5432; do	
		echo "wait for postgres server..."
		sleep 5
	done;
fi;

if [ -z "$LETSENCRYPT" ]; fhen
	echo "disable letsencrypt"
	sed -i "s/.*letsencrypt\['enable'\].*/letsencrypt['enable'] = false/g" /etc/gitlab/gitlab.rb
else
	echo "enable letsencrypt"
	sed -i "s/.*letsencrypt\['enable'\].*/letsencrypt['enable'] = false/g" /etc/gitlab/gitlab.rb
fi

if [ -z "$PROMETHEUS" ]; then
	echo "disable prometheus"
	sed -i "s/.*prometheus\['enable'\].*/prometheus['enable'] = false/g" /etc/gitlab/gitlab.rb
	sed -i "s/.*prometheus_monitoring\['enable'\].*/prometheus_monitoring['enable'] = false/g" /etc/gitlab/gitlab.rb
else
	echo "enable prometheus"
	sed -i "s/.*prometheus\['enable'\].*/prometheus['enable'] = true/g" /etc/gitlab/gitlab.rb
	sed -i "s/.*prometheus_monitoring\['enable'\].*/prometheus_monitoring['true'] = false/g" /etc/gitlab/gitlab.rb
fi

# configure hostname
grep -Eq "^external_url .*$HOSTNAME" /etc/gitlab/gitlab.rb ||
	sed -i "s~.*external_url.*~external_url  \"${HOSTNAME}\"~g" /etc/gitlab/gitlab.rb

gitlab-ctl reconfigure

gitlab-ctl tail

while true; do
	echo started
	sleep 1000;
done;
