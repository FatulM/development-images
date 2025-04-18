# syntax=docker/dockerfile:1
FROM ubuntu:24.04
ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'
RUN set -eux; \
    apt update; \
    apt install --no-install-recommends -y locales; \
    echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen; \
    locale-gen en_US.UTF-8; \
    rm -rf /var/lib/apt/lists/*
RUN set -eux; \
    apt update; \
    apt install --no-install-recommends -y \
      gnupg ca-certificates binutils tzdata \
      jq yq xq wget curl git htop tree nano vim dnsutils psmisc bridge-utils bzip2 xz-utils \
      xvfb xauth \
      build-essential linux-headers-$(uname -r) \
      python3.12 python3.12-full python3.12-venv \
      openjdk-21-jdk-headless openjdk-21-jre-headless openjdk-21-source openjdk-21-doc \
      maven \
      ; \
    rm -rf /var/lib/apt/lists/*
RUN set -eux; \
    wget -O fastfetch.deb https://github.com/fastfetch-cli/fastfetch/releases/download/2.41.0/fastfetch-linux-$(uname -m).deb; \
    dpkg -i fastfetch.deb; \
    rm fastfetch.deb; \
    rm -rf /var/lib/apt/lists/*
RUN java -Xshare:dump
RUN sudo ln -s /usr/lib/jvm/java-21-openjdk-$(dpkg --print-architecture) /usr/lib/jvm/java-21
ENV JAVA_HOME=/usr/lib/jvm/java-21
RUN java --version
RUN javac --version
RUN python --version
