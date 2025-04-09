FROM nginx:alpine

COPY conf.d/default.conf /etc/nginx/conf.d/default.conf

RUN mkdir -p /usr/share/nginx/html
COPY www/index.html /usr/share/nginx/html/index.html

# Crear directorios SSL si no existen
RUN mkdir -p /etc/nginx/ssl

# Exponer puertos
EXPOSE 80 443

CMD ["nginx", "-g", "daemon off;"]
