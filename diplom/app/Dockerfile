FROM nginx:1.27-alpine

# Версия подставляется на этапе сборки из тега git
ARG VERSION=dev

COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY html/ /usr/share/nginx/html/

RUN sed -i "s/__VERSION__/${VERSION}/g" /usr/share/nginx/html/index.html

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=3s \
  CMD wget -q -O- http://localhost/healthz || exit 1
