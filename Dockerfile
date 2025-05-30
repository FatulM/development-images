# syntax=docker/dockerfile:1
# Use latest Ubuntu LTS as base image.
FROM ubuntu:24.04
# Upgrade dependencies:
RUN set -eux; \
    apt update; \
    DEBIAN_FRONTEND=noninteractive apt upgrade -y; \
    apt clean; \
    rm -rf /var/lib/apt/lists/*
# Setup language and Locale.
ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'
RUN set -eux; \
    apt update; \
    DEBIAN_FRONTEND=noninteractive apt install --no-install-recommends -y locales; \
    echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen; \
    locale-gen en_US.UTF-8; \
    apt clean; \
    rm -rf /var/lib/apt/lists/*
# Install needed dependencies. such as Java, Python and Maven.
RUN set -eux; \
    LINUX_HEADERS_APT="linux-headers-$(uname -r)"; \
    apt update; \
    DEBIAN_FRONTEND=noninteractive apt install --no-install-recommends -y \
      gnupg ca-certificates binutils tzdata fontconfig p11-kit \
      jq yq xq wget curl git htop tree nano vim dnsutils psmisc bridge-utils bzip2 xz-utils unzip \
      xvfb xauth \
      build-essential $LINUX_HEADERS_APT \
      dpkg-dev gcc gnupg libbluetooth-dev libbz2-dev libc6-dev libdb-dev libffi-dev libgdbm-dev liblzma-dev libncursesw5-dev libreadline-dev libsqlite3-dev libssl-dev make tk-dev uuid-dev wget xz-utils zlib1g-dev \
      python3.12 python3.12-full python3.12-venv \
      openjdk-21-jdk-headless openjdk-21-jre-headless openjdk-21-source openjdk-21-doc \
      maven \
      ; \
    apt clean; \
    rm -rf /var/lib/apt/lists/*
# Install fastfetch from GitHub release page.
# linux/arm64: https://github.com/fastfetch-cli/fastfetch/releases/download/2.41.0/fastfetch-linux-aarch64.deb
# linux/amd64: https://github.com/fastfetch-cli/fastfetch/releases/download/2.41.0/fastfetch-linux-amd64.deb
RUN set -eux; \
    ARCH=$(uname -m); \
    # We should fix arch for x86_64 to amd64.
    ARCH_FIXED=$(echo $ARCH | sed "s/x86_64/amd64/g"); \
    FASTFETCH_URL="https://github.com/fastfetch-cli/fastfetch/releases/download/2.41.0/fastfetch-linux-${ARCH_FIXED}.deb"; \
    wget -O fastfetch.deb $FASTFETCH_URL; \
    dpkg -i fastfetch.deb; \
    rm fastfetch.deb; \
    apt clean; \
    rm -rf /var/lib/apt/lists/*
# Some code found in eclipse temurin docker file.
RUN set -eux; \
    JDK_INSTALL_DIR="/usr/lib/jvm/java-21-openjdk-$(dpkg --print-architecture)"; \
    find "$JDK_INSTALL_DIR/lib" -name '*.so' -exec dirname '{}' ';' | sort -u > /etc/ld.so.conf.d/docker-openjdk.conf; \
    ldconfig
# Precache Java CDS files.
RUN java -Xshare:dump
# Setup Java home environment variable.
# I am making a workaround, since the directory is architecture dependent.
# TODO: how to make dynamic env variables ?
RUN set -eux; \
    JDK_INSTALL_DIR="/usr/lib/jvm/java-21-openjdk-$(dpkg --print-architecture)"; \
    mkdir -p /opt/java/; \
    ln -s $JDK_INSTALL_DIR /opt/java/openjdk
ENV JAVA_HOME='/opt/java/openjdk'
# Update path environment variable for Java.
ENV PATH=$JAVA_HOME/bin:$PATH
# Setup some more environment variable.
ENV JAVA_VERSION='21'
ENV PYTHON_VERSION='3.12'
# Check installed app versions.
RUN set -eux; \
    java --version; \
    javac --version; \
    mvn --version;
RUN set -eux; \
    export PYTHONDONTWRITEBYTECODE=1; \
    export PYTHONUNBUFFERED=1; \
    python3 --version; \
    python3 -m venv --help | head -n 3
# Check venv creation.
COPY example.py /tmp/example_python/example.py
RUN set -eux; \
    mkdir -p /tmp/; \
    mkdir -p /tmp/example_python/; \
    export PYTHONDONTWRITEBYTECODE=1; \
    export PYTHONUNBUFFERED=1; \
    python3 -m venv /tmp/example_venv/; \
    /tmp/example_venv/bin/python --version; \
    /tmp/example_venv/bin/pip --version; \
    /tmp/example_venv/bin/python /tmp/example_python/example.py; \
    rm -rf /tmp/example_python/; \
    rm -rf /tmp/example_venv/
# Check java compiler.
COPY Example.java /tmp/example_java/Example.java
RUN set -eux; \
    mkdir -p /tmp/; \
    mkdir -p /tmp/example_java/; \
    cd /tmp/example_java/; \
    javac Example.java; \
    java Example; \
    cd /; \
    rm -rf /tmp/example_java/
# List apt installed packages.
RUN apt list --installed
# Run fastfetch.
RUN fastfetch
# Install ssh tools.
RUN set -eux; \
    apt update; \
    DEBIAN_FRONTEND=noninteractive apt install --no-install-recommends -y \
    openssh-client openssh-server; \
    apt clean; \
    rm -rf /var/lib/apt/lists/*
# Setup home and working directories.
ENV HOME='/root'
WORKDIR $HOME
# Expose some ports such as ssh (22).
EXPOSE 22
# Use bash as default cmd.
CMD ["bash"]
# Set some oci labels.
LABEL org.opencontainers.image.description="Docker image for use in developing Java and Python applications."
