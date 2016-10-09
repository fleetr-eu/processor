FROM alpine:3.4

RUN apk add --no-cache nodejs

ADD . /app/

WORKDIR /app

RUN npm install

CMD node_modules/coffee-script/bin/coffee index.coffee
