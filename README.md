# docker-mutillidae [![Build Status](https://travis-ci.org/edoz90/docker-mutillidae.svg?branch=master)](https://travis-ci.org/edoz90/docker-mutillidae)
Dockerfile to run [OWASP Mutillidae II](https://github.com/webpwnized/mutillidae) with NGINX

# Steps

`docker build . --force-rm -t cesena:mutillidae`

`docker run -d -p 80:80 --name mutillidae cesena:mutillidae`

Connect to the docker IP and first perform the database population.

## MySQL

During the build of the container MySQL passwords will be randomly generated and printed on console:

```
[!!!] MySQL 'root' password is: FJVHs4vwVCTo94A
[!!!] MySQL 'mutillidae' password is: pzborshCWPpKLy9
```
