# Étape 1 : Builder l'application Flutter Web
FROM debian:bookworm AS build-env

RUN apt-get update && apt-get install -y curl git unzip xz-utils zip libglu1-mesa
RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter

ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

RUN flutter config --enable-web
RUN flutter doctor

COPY . /app
WORKDIR /app
RUN flutter pub get
RUN flutter build web --release

# Étape 2 : Servir avec Nginx
FROM nginx:alpine
COPY --from=build-env /app/build/web /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]