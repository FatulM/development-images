# syntax=docker/dockerfile:1
# Use latest Ubuntu LTS as base image.
FROM ubuntu:24.04
# Setup language and Locale.
ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'
RUN set -eux; \
    apt update; \
    apt install --no-install-recommends -y locales; \
    echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen; \
    locale-gen en_US.UTF-8; \
    rm -rf /var/lib/apt/lists/*
# Install needed dependencies. such as Java, Python and Maven.
RUN set -eux; \
    apt update; \
    apt install --no-install-recommends -y \
      gnupg ca-certificates binutils tzdata \
      jq yq xq wget curl git htop tree nano vim dnsutils psmisc bridge-utils bzip2 xz-utils unzip \
      xvfb xauth \
      build-essential linux-headers-$(uname -r) \
      python3.12 python3.12-full python3.12-venv \
      openjdk-21-jdk-headless openjdk-21-jre-headless openjdk-21-source openjdk-21-doc \
      maven \
      ; \
    rm -rf /var/lib/apt/lists/*
# Install fastfetch from GitHub release page.
RUN set -eux; \
    wget -O fastfetch.deb https://github.com/fastfetch-cli/fastfetch/releases/download/2.41.0/fastfetch-linux-$(uname -m).deb; \
    dpkg -i fastfetch.deb; \
    rm fastfetch.deb; \
    rm -rf /var/lib/apt/lists/*
# Some code found in eclipse temurin docker file.
RUN set -eux; \
    find "/usr/lib/jvm/java-21-openjdk-$(dpkg --print-architecture)/lib" -name '*.so' -exec dirname '{}' ';' | sort -u > /etc/ld.so.conf.d/docker-openjdk.conf; \
    ldconfig
# Precache Java CDS files.
RUN java -Xshare:dump
# Setup Java home environment variable.
# I am making a workaround, since the directory is architecture dependent.
# TODO: how to make dynamic env variables ?
RUN set -eux; \
    mkdir -p /opt/java/; \
    sudo ln -s /usr/lib/jvm/java-21-openjdk-$(dpkg --print-architecture) /opt/java/openjdk
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
    mvn --version; \
    python --version;
# Setup home and working directories.
ENV HOME=/root/
WORKDIR $HOME
# Expose some ports such as ssh (22).
EXPOSE 22
# Use bash as default cmd.
CMD ["bash"]
