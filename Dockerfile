from ubuntu:14.04
maintainer Dockerfiles

run apt-get update -y
run apt-get install -y python python-dev python-setuptools supervisor
run apt-get install -y python-mysqldb
run apt-get install -y libpq-dev
run apt-get install -y libtcmalloc-minimal4
run apt-get purge -y libopenblas-dev
run easy_install pip
run pip install Flask

RUN mkdir -p /app
ADD ./module/* app/
ADD ./config/supervisor-app.conf /etc/supervisor/conf.d/supervisor-app.conf

expose 8080
cmd ["supervisord", "-n"]
