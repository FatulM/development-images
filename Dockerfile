# syntax=docker/dockerfile:1
FROM ubuntu:24.04

ENV LANG='en_US.UTF-8'
ENV LANGUAGE='en_US:en'
ENV LC_ALL='en_US.UTF-8'
ENV JAVA_VERSION='21'
ENV PYTHON_VERSION='3.12'
ENV HOME='/root'
ENV JAVA_HOME='/opt/java/openjdk'
ENV PATH=$JAVA_HOME/bin:$PATH

RUN set -eux; \
    DEBIAN_FRONTEND=noninteractive; \
    apt update; \
    apt upgrade -y; \
    apt install --no-install-recommends -y \
          locales \
          gnupg ca-certificates binutils tzdata fontconfig p11-kit \
          jq yq xq wget curl git htop tree nano vim dnsutils psmisc bridge-utils bzip2 xz-utils unzip \
          xvfb xauth \
          build-essential \
          dpkg-dev gcc gnupg libbluetooth-dev libbz2-dev libc6-dev libdb-dev libffi-dev libgdbm-dev liblzma-dev libncursesw5-dev libreadline-dev libsqlite3-dev libssl-dev make tk-dev uuid-dev wget xz-utils zlib1g-dev \
          python3.12 python3.12-full python3.12-venv \
          openjdk-21-jdk-headless openjdk-21-jre-headless openjdk-21-source openjdk-21-doc \
          maven \
          openssh-client openssh-server \
          ; \
    apt clean; \
    rm -rf /var/lib/apt/lists/*; \
    echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen; \
    locale-gen en_US.UTF-8; \
    apt list --installed;

RUN set -eux; \
    PYTHONUNBUFFERED=1; \
    ARCH=$(dpkg --print-architecture); \
    JDK_INSTALL_DIR="/usr/lib/jvm/java-21-openjdk-${ARCH}"; \
    find "$JDK_INSTALL_DIR/lib" -name '*.so' -exec dirname '{}' ';' | sort -u > /etc/ld.so.conf.d/docker-openjdk.conf; \
    ldconfig; \
    java -Xshare:dump; \
    mkdir -p /opt/java/; \
    ln -s $JDK_INSTALL_DIR /opt/java/openjdk; \
    java --version; \
    javac --version; \
    mvn --version; \
    python3 --version; \
    python3 -m venv --help | head -n 3;

RUN set -eux; \
    ARCH=$(uname -m); \
    ARCH1=$(echo $ARCH | sed "s/x86_64/amd64/g"); \
    FASTFETCH_URL="https://github.com/fastfetch-cli/fastfetch/releases/download/2.44.0/fastfetch-linux-${ARCH1}.deb"; \
    wget -O fastfetch.deb $FASTFETCH_URL; \
    dpkg -i fastfetch.deb; \
    rm fastfetch.deb; \
    apt clean; \
    rm -rf /var/lib/apt/lists/*; \
    fastfetch;

WORKDIR $HOME

EXPOSE 22 80 443

CMD ["bash"]
