FROM debian:stable

RUN  export DEBIAN_FRONTEND=noninteractive
ENV  DEBIAN_FRONTEND noninteractive
RUN  dpkg-divert --local --rename --add /sbin/initctl

RUN apt-get -y update; apt-get -y install gnupg2 wget ca-certificates ssl-cert rpl pwgen build-essential libreadline-dev zlib1g-dev libxml2-dev libgeos-dev binutils libproj-dev gdal-bin libgdal-dev libssl-dev libcunit1-dev

RUN sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ stretch-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -

RUN wget --quiet -O postgresql-12beta1.tar.gz https://ftp.postgresql.org/pub/source/v12beta1/postgresql-12beta1.tar.gz \
 && tar -xzf postgresql-12beta1.tar.gz \
 && rm postgresql-12beta1.tar.gz

RUN wget --quiet -O postgis-3.0.0alpha1.tar.gz https://download.osgeo.org/postgis/source/postgis-3.0.0alpha1.tar.gz \
 && tar -xzf postgis-3.0.0alpha1.tar.gz \
 && rm postgis-3.0.0alpha1.tar.gz

RUN wget --quiet -O geos-3.7.2.tar.bz2 http://download.osgeo.org/geos/geos-3.7.2.tar.bz2 \
 && tar -jxf geos-3.7.2.tar.bz2 \
 && rm geos-3.7.2.tar.bz2

RUN cd geos-3.7.2 \
 && ./configure \
 && make \
 && make install

RUN cd postgresql-12beta1 \
 && ./configure --with-openssl \
 && make \
 && su \
 && make install

RUN cd postgresql-12beta1/contrib \
 && su \
 && make install

RUN cd postgis-3.0.0alpha1 \
 && ./configure --with-pgconfig=/usr/local/pgsql/bin/pg_config --with-geosconfig=/usr/local/bin/geos-config \
 && make \
 && make install

EXPOSE 5432

ENV PGDATA /usr/local/pgsql/data
RUN useradd -ms /bin/bash postgres

# Run any additional tasks here that are too tedious to put in
# this dockerfile directly.
ADD env-data.sh /env-data.sh
ADD setup.sh /setup.sh
RUN chmod +x /setup.sh
RUN /setup.sh

# We will run any commands in this when the container starts
ADD docker-entrypoint.sh /docker-entrypoint.sh
#ADD setup-conf.sh /
ADD setup-database.sh /
ADD setup-pg_hba.sh /
ADD setup-replication.sh /
ADD setup-user.sh /
ADD setup-ssl.sh /
RUN chmod +x /docker-entrypoint.sh

ENTRYPOINT /docker-entrypoint.sh