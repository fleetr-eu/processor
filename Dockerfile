FROM alpine:3.4

RUN apk add --no-cache nodejs && \
    npm i -g yarn

ADD . /app/

WORKDIR /app

RUN yarn install --production

CMD node_modules/coffee-script/bin/coffee index.coffee
