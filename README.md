# postgis-parallel

## Notes

This is a **temporary** docker image which support PostgreSQL 12 and PostGIS 3 whilst they are under development

## Tagged versions

The following convention is used for tagging the images we build:

tbrocherieux/postgis-parallel:[postgres-version]-[postgis-version]

So for example:

``tbrocherieux/postgis-parallel:12.0beta1:3.0alpha1`` Provides PostgreSQL 12.0 beta 1, PostGIS 3.0 alpha 1

## Getting the image

```
docker pull tbrocherieux/postgis-parallel
```

## Environment variables

You can also use the following environment variables to pass a 
user name, password and/or default database name(or multiple databases coma separated).

* -e POSTGRES_USER=<PGUSER> 
* -e POSTGRES_PASS=<PGPASSWORD>
* -e POSTGRES_DBNAME=<PGDBNAME>
* -e POSTGRES_MULTIPLE_EXTENSIONS=postgis,hstore,postgis_topology # You can pass as many extensions as you need.

These will be used to create a new superuser with
your preferred credentials. If these are not specified then the postgresql
user is set to 'docker' with password 'docker'.

You can open up the PG port by using the following environment variable. By default
the container will allow connections only from the docker private subnet.

* -e ALLOW_IP_RANGE=<0.0.0.0/0> By default 
t

Postgres conf is setup to listen to all connections and if a user needs to restrict which IP address
PostgreSQL listens to you can define it with the following environment variable. The default is set to listen to all connections.
* -e IP_LIST=<*>

## Convenience docker-compose.yml

The docker compose recipe will expose PostgreSQL on port 5434 (to prevent potential conflicts with any local database instance you may have).

Example usage:

```shell
docker-compose up -d
```

**Note:** The docker-compose recipe above will not persist your data on your local
disk, only in a docker volume.

## Connect via psql

Connect with psql (make sure you first install postgresql client tools on your
host / client):

```shell
psql -h localhost -U docker -p 5434 -l
```

**Note:** Default postgresql user is 'docker' with password 'docker'.

## Credits

This docker image is largely inspired by [kartoza/docker-postgis](https://github.com/kartoza/docker-postgis)

## FAQ

**Question:** Why this docker image ?

**Answer:** With PostgreSQL 12 and PostGIS 3, running parallel operations has never been so easy 
[Check this article](http://blog.cleverelephant.ca/2019/05/parallel-postgis-4.html)
