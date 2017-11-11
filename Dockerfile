FROM node:8

WORKDIR /microserv

ADD src ./src
ADD package.json ./package.json
ADD yarn.lock .

RUN npm i -g coffeescript yarn; \
    yarn install; \
    yarn build
