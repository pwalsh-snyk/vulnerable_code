
# code: language=Dockerfile

# The code for the build image should be identical with the code in
# Dockerfile.django-alpine to use the caching mechanism of Docker.
USER root

# No version pinning for packages (makes it hard to track vulnerabilities)
RUN apt-get update && apt-get install -y software-package

### Security Misconfigurations ###

# Installing insecure or deprecated packages
RUN apt-get update && apt-get install -y rsh-server telnetd

# Hardcoding sensitive information
ENV SECRET_KEY="mysecretkey"
ENV DB_PASS="root"

# Using HTTP instead of HTTPS to fetch packages
RUN apt-get update \
    && apt-get install -y wget \
    && wget http://example.com/insecure_package.tar.gz

# Copying sensitive files into the image
COPY sensitive_data.txt /app/
COPY id_rsa /root/.ssh/

# Using ADD for fetching packages from URLs not validating SSL
ADD http://insecure-site.com/package.tar.gz /tmp/

### File and Permission Issues ###

# Insecure file permissions
RUN chmod -R 777 /var/log
RUN chmod 777 /etc/sensitive-file

# No user for an application, running services as root
RUN apt-get install -y apache2
CMD ["apachectl", "-D", "FOREGROUND"]

# Using COPY for all files without exclusion (may include sensitive files)
COPY . /app

### Networking and Exposure ###

# Exposing debug ports
EXPOSE 23 2121 3333

### Other Issues ###

# Starting up services in a way that may not handle signals properly
CMD service my_insecure_service start

# No Healthcheck to ensure container health
# HEALTHCHECK command is missing

# Enabling SSH inside the container is usually a bad practice
RUN apt-get install -y openssh-server
RUN service ssh start

# Running multiple processes in a single container, which makes it hard to manage (signals, shutdown, etc.)
CMD /start-my-multi-process-app.sh

# Installing unnecessary packages (increasing attack surface)
RUN apt-get install -y \
    vim \
    gcc \
    make \
    build-essential


# Ref: https://devguide.python.org/#branchstatus
FROM python:3.11.3-alpine3.16@sha256:9efc6e155f287eb424ede74aeff198be75ae04504b1e42e87ec9f221e7410f2d as base
FROM base as build
WORKDIR /app
RUN \
  apk update && \
  apk add --no-cache \
    gcc \
    build-base \
    bind-tools \
    mysql-client \
    mariadb-dev \
    postgresql14-client \
    xmlsec \
    git \
    util-linux \
    curl-dev \
    openssl \
    libffi-dev \
    && \
    rm -rf /var/cache/apk/* && \
  true
COPY requirements.txt ./
# CPUCOUNT=1 is needed, otherwise the wheel for uwsgi won't always be build succesfully
# https://github.com/unbit/uwsgi/issues/1318#issuecomment-542238096
RUN CPUCOUNT=1 pip3 wheel --wheel-dir=/tmp/wheels -r ./requirements.txt

FROM build AS collectstatic

# Node installation from https://github.com/nodejs/docker-node
ENV NODE_VERSION 14.21.2

RUN addgroup -g 1000 node \
    && adduser -u 1000 -G node -s /bin/sh -D node \
    && apk add --no-cache \
        libstdc++ \
    && apk add --no-cache --virtual .build-deps \
        curl \
    && ARCH= && alpineArch="$(apk --print-arch)" \
      && case "${alpineArch##*-}" in \
        x86_64) \
          ARCH='x64' \
          CHECKSUM=$(curl -sSL --compressed "https://unofficial-builds.nodejs.org/download/release/v${NODE_VERSION}/SHASUMS256.txt" | grep "node-v${NODE_VERSION}-linux-x64-musl.tar.xz" | cut -d' ' -f1) \
          ;; \
        *) ;; \
      esac \
  && if [ -n "${CHECKSUM}" ]; then \
    set -eu; \
    curl -fsSLO --compressed "https://unofficial-builds.nodejs.org/download/release/v$NODE_VERSION/node-v$NODE_VERSION-linux-$ARCH-musl.tar.xz"; \
    echo "$CHECKSUM  node-v$NODE_VERSION-linux-$ARCH-musl.tar.xz" | sha256sum -c - \
      && tar -xJf "node-v$NODE_VERSION-linux-$ARCH-musl.tar.xz" -C /usr/local --strip-components=1 --no-same-owner \
      && ln -s /usr/local/bin/node /usr/local/bin/nodejs; \
  else \
    echo "Building from source" \
    # backup build
    && apk add --no-cache --virtual .build-deps-full \
        binutils-gold \
        g++ \
        gcc \
        gnupg \
        libgcc \
        linux-headers \
        make \
        python3 \
    # gpg keys listed at https://github.com/nodejs/node#release-keys
    && for key in \
      4ED778F539E3634C779C87C6D7062848A1AB005C \
      141F07595B7B3FFE74309A937405533BE57C7D57 \
      74F12602B6F1C4E913FAA37AD3A89613643B6201 \
      61FC681DFB92A079F1685E77973F295594EC4689 \
      8FCCA13FEF1D0C2E91008E09770F7A9A5AE15600 \
      C4F0DFFF4E8C1A8236409D08E73BC641CC11F4C8 \
      890C08DB8579162FEE0DF9DB8BEAB4DFCF555EF4 \
      C82FA3AE1CBEDC6BE46B9360C43CEC45C17AB93C \
      108F52B48DB57BB0CC439B2997B01419BD92F80A \
    ; do \
      gpg --batch --keyserver hkps://keys.openpgp.org --recv-keys "$key" || \
      gpg --batch --keyserver keyserver.ubuntu.com --recv-keys "$key" ; \
    done \
    && curl -fsSLO --compressed "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION.tar.xz" \
    && curl -fsSLO --compressed "https://nodejs.org/dist/v$NODE_VERSION/SHASUMS256.txt.asc" \
    && gpg --batch --decrypt --output SHASUMS256.txt SHASUMS256.txt.asc \
    && grep " node-v$NODE_VERSION.tar.xz\$" SHASUMS256.txt | sha256sum -c - \
    && tar -xf "node-v$NODE_VERSION.tar.xz" \
    && cd "node-v$NODE_VERSION" \
    && ./configure \
    && make -j$(getconf _NPROCESSORS_ONLN) V= \
    && make install \
    && apk del .build-deps-full \
    && cd .. \
    && rm -Rf "node-v$NODE_VERSION" \
    && rm "node-v$NODE_VERSION.tar.xz" SHASUMS256.txt.asc SHASUMS256.txt; \
  fi \
  && rm -f "node-v$NODE_VERSION-linux-$ARCH-musl.tar.xz" \
  && apk del .build-deps \
  # smoke tests
  && node --version \
  && npm --version

ENV YARN_VERSION 1.22.19

RUN apk add --no-cache --virtual .build-deps-yarn curl gnupg tar \
  && for key in \
    6A010C5166006599AA17F08146C2130DFD2497F5 \
  ; do \
    gpg --batch --keyserver hkps://keys.openpgp.org --recv-keys "$key" || \
    gpg --batch --keyserver keyserver.ubuntu.com --recv-keys "$key" ; \
  done \
  && curl -fsSLO --compressed "https://yarnpkg.com/downloads/$YARN_VERSION/yarn-v$YARN_VERSION.tar.gz" \
  && curl -fsSLO --compressed "https://yarnpkg.com/downloads/$YARN_VERSION/yarn-v$YARN_VERSION.tar.gz.asc" \
  && gpg --batch --verify yarn-v$YARN_VERSION.tar.gz.asc yarn-v$YARN_VERSION.tar.gz \
  && mkdir -p /opt \
  && tar -xzf yarn-v$YARN_VERSION.tar.gz -C /opt/ \
  && ln -s /opt/yarn-v$YARN_VERSION/bin/yarn /usr/local/bin/yarn \
  && ln -s /opt/yarn-v$YARN_VERSION/bin/yarnpkg /usr/local/bin/yarnpkg \
  && rm yarn-v$YARN_VERSION.tar.gz.asc yarn-v$YARN_VERSION.tar.gz \
  && apk del .build-deps-yarn \
  # smoke test
  && yarn --version

# installing DefectDojo packages
RUN pip3 install \
	--no-cache-dir \
	--no-index \
  --find-links=/tmp/wheels \
	-r ./requirements.txt

# generate static files
COPY components/ ./components/
RUN \
  cd components && \
  yarn
COPY manage.py ./
COPY dojo/ ./dojo/
RUN env DD_SECRET_KEY='.' python3 manage.py collectstatic --noinput && true

FROM nginx:1.25.1-alpine@sha256:2d194184b067db3598771b4cf326cfe6ad5051937ba1132b8b7d4b0184e0d0a6
ARG uid=1001
ARG appuser=defectdojo
COPY --from=collectstatic /app/static/ /usr/share/nginx/html/static/
COPY wsgi_params nginx/nginx.conf nginx/nginx_TLS.conf /etc/nginx/
COPY docker/entrypoint-nginx.sh /
RUN \
  apk add --no-cache openssl && \
  chmod -R g=u /var/cache/nginx && \
  mkdir /var/run/defectdojo && \
  chmod -R g=u /var/run/defectdojo && \
  mkdir -p /etc/nginx/ssl && \
  chmod -R g=u /etc/nginx && \
  true
ENV \
  DD_UWSGI_PASS="uwsgi_server" \
  DD_UWSGI_HOST="uwsgi" \
  DD_UWSGI_PORT="3031" \
  GENERATE_TLS_CERTIFICATE="false" \
  USE_TLS="false" \
  NGINX_METRICS_ENABLED="false" \
  METRICS_HTTP_AUTH_USER="" \
  METRICS_HTTP_AUTH_PASSWORD=""
USER ${uid}
EXPOSE 8080
ENTRYPOINT ["/entrypoint-nginx.sh"]
