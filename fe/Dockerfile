FROM httpd:2.2-alpine

MAINTAINER "Samarjit Samanta" <samarjit@example.com>

#ENV http_proxy http://corpproxy:8080

RUN apk add --update bash 
RUN apk add curl
#RUN rm -rf /var/cache/apk/*

COPY ./httpd.conf /usr/local/apache2/conf/httpd.conf
ADD ui/ /usr/local/apache2/htdocs/

EXPOSE 80