FROM kong:latest
MAINTAINER Antonio L. González Gómez <antonio.gonzalez@idemia.com>

COPY plugins /usr/local/kong_plugins/plugins/
COPY kong.conf /etc/kong/kong.conf

