ARG DISTRO_IMAGE
FROM debian:${DISTRO_IMAGE} AS kamailio-base

ARG DISTRO_IMAGE
ARG KAMAILIO_VERSION
ARG STARTER_KAM_USER
ARG STARTER_KAM_GROUP

WORKDIR /root

## install some dependencies
RUN apt update && \
    apt install -y wget \
    gnupg2 \
    sngrep \
    iproute2 \
    procps \
    rsyslog \
    vim \
    sudo

## install package
RUN wget -qO- https://deb.kamailio.org/kamailiodebkey.gpg | gpg --dearmor 2>/dev/null | tee /usr/share/keyrings/kamailio.gpg >/dev/null && \
    echo "deb [signed-by=/usr/share/keyrings/kamailio.gpg] http://deb.kamailio.org/kamailio${KAMAILIO_VERSION} ${DISTRO_IMAGE} main" > /etc/apt/sources.list.d/kamailio.list && \
    apt update

## create user and group, if not root
RUN USER=$(echo "$STARTER_KAM_USER" | tr '[:upper:]' '[:lower:]') && \
    GROUP=$(echo "$STARTER_KAM_GROUP" | tr '[:upper:]' '[:lower:]') && \
    if [ "$GROUP" != "root" ] && ! getent group "$GROUP" > /dev/null; then groupadd "$GROUP"; fi && \
    if [ "$GROUP" != "root" ] && ! id "$USER" > /dev/null 2>&1; then useradd -m -g "$GROUP" "$USER"; fi
