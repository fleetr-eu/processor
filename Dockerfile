FROM alpine:3.7

RUN apk add --no-cache nodejs

ADD . /app/

WORKDIR /app

RUN npm i --production

CMD npm start
