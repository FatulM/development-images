# syntax=docker/dockerfile:1
FROM ubuntu:24.04
SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]
RUN apt update; \
    DEBIAN_FRONTEND=noninteractive apt upgrade -y; \
    apt clean; \
    rm -rf /var/lib/apt/lists/*
ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'
RUN apt update; \
    DEBIAN_FRONTEND=noninteractive apt install --no-install-recommends -y locales; \
    echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen; \
    locale-gen en_US.UTF-8; \
    apt clean; \
    rm -rf /var/lib/apt/lists/*
RUN LINUX_HEADERS_APT="linux-headers-$(uname -r)"; \
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
RUN ARCH=$(uname -m); \
    ARCH_FIXED=$(echo $ARCH | sed "s/x86_64/amd64/g"); \
    FASTFETCH_URL="https://github.com/fastfetch-cli/fastfetch/releases/download/2.41.0/fastfetch-linux-${ARCH_FIXED}.deb"; \
    wget -O fastfetch.deb $FASTFETCH_URL; \
    dpkg -i fastfetch.deb; \
    rm fastfetch.deb; \
    apt clean; \
    rm -rf /var/lib/apt/lists/*
RUN JDK_INSTALL_DIR="/usr/lib/jvm/java-21-openjdk-$(dpkg --print-architecture)"; \
    find "$JDK_INSTALL_DIR/lib" -name '*.so' -exec dirname '{}' ';' | sort -u > /etc/ld.so.conf.d/docker-openjdk.conf; \
    ldconfig
RUN java -Xshare:dump
RUN JDK_INSTALL_DIR="/usr/lib/jvm/java-21-openjdk-$(dpkg --print-architecture)"; \
    mkdir -p /opt/java/; \
    ln -s $JDK_INSTALL_DIR /opt/java/openjdk
ENV JAVA_HOME='/opt/java/openjdk'
ENV PATH=$JAVA_HOME/bin:$PATH
ENV JAVA_VERSION='21'
ENV PYTHON_VERSION='3.12'
RUN java --version; \
    javac --version; \
    mvn --version;
RUN export PYTHONDONTWRITEBYTECODE=1; \
    export PYTHONUNBUFFERED=1; \
    python3 --version; \
    python3 -m venv --help | head -n 3
COPY example.py /tmp/example_python/example.py
RUN mkdir -p /tmp/; \
    mkdir -p /tmp/example_python/; \
    export PYTHONDONTWRITEBYTECODE=1; \
    export PYTHONUNBUFFERED=1; \
    python3 -m venv /tmp/example_venv/; \
    /tmp/example_venv/bin/python --version; \
    /tmp/example_venv/bin/pip --version; \
    /tmp/example_venv/bin/python /tmp/example_python/example.py; \
    rm -rf /tmp/example_python/; \
    rm -rf /tmp/example_venv/
COPY Example.java /tmp/example_java/Example.java
RUN mkdir -p /tmp/; \
    mkdir -p /tmp/example_java/; \
    cd /tmp/example_java/; \
    javac Example.java; \
    java Example; \
    cd /; \
    rm -rf /tmp/example_java/
RUN apt list --installed
RUN fastfetch
RUN apt update; \
    DEBIAN_FRONTEND=noninteractive apt install --no-install-recommends -y \
    openssh-client openssh-server; \
    apt clean; \
    rm -rf /var/lib/apt/lists/*
ENV HOME='/root'
WORKDIR $HOME
EXPOSE 22, 80, 443
CMD ["bash"]
