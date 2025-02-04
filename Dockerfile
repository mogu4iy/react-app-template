FROM node:15.12-alpine AS builder

WORKDIR /opt/web
COPY package.json package-lock.json ./
RUN apk add --no-cache --virtual .gyp python make g++
RUN npm install
RUN apk del .gyp
ENV PATH="./node_modules/.bin:$PATH"
COPY . ./
RUN npm run build

FROM nginx:1.17-alpine

RUN apk --no-cache add curl
RUN curl -L https://github.com/a8m/envsubst/releases/download/v1.1.0/envsubst-`uname -s`-`uname -m` -o envsubst && \
    chmod +x envsubst && \
    mv envsubst /usr/local/bin
COPY ./nginx.conf /etc/nginx/nginx.template
COPY --from=builder /opt/web/build /usr/share/nginx/html
CMD ["/bin/sh", "-c", "envsubst < /etc/nginx/nginx.template > /etc/nginx/conf.d/default.conf && nginx -g 'daemon off;'"]
