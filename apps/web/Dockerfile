# Dockerfile — receta de la imagen de la app web.
FROM node:24-alpine

WORKDIR /app
COPY server.js .

# La versión llega desde el pipeline (docker build --build-arg VERSION=...).
ARG VERSION=local
ENV VERSION=$VERSION

# No correr como root: el usuario "node" ya existe en la imagen base.
USER node
EXPOSE 8080
CMD ["node", "server.js"]
