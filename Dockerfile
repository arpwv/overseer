FROM node:8-alpine

RUN apk add --no-cache make bash git
RUN npm install -g yarn

# use bash as the default shell, the busybox shell does not work with ypib
RUN cp /bin/bash /bin/sh

WORKDIR /app
COPY package.json yarn.lock ./

RUN yarn install --non-interactive --frozen-lockfile

COPY . .

RUN make ci-test
RUN make lib

# prune modules
RUN yarn install --non-interactive --frozen-lockfile --production

EXPOSE 8080

ENV PORT 8080
ENV NODE_ENV production

CMD [ "node", "lib/server.js" ]
