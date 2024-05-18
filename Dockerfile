FROM ubuntu:24.04

LABEL author "Colin Gelling https://github.com/colingelling"

# Make sure that the system is updated before continuing
RUN apt-get update && apt-get upgrade -y

# Download and install additional packages
RUN set -x; \
    apt-get install -y \
    unzip \
    htop \
    wget \
    vim

# Download and prepare platform-tools
RUN set -x; \
    wget https://dl.google.com/android/repository/platform-tools-latest-linux.zip -P /tmp; \
    unzip /tmp/platform-tools-latest-linux.zip -d ${HOME}; \
    rm -f /tmp/platform-tools-latest-linux.zip

# Set the PATH environment variable
ENV PATH="${HOME}/platform-tools:$PATH"

# Install build packages
RUN set -x; \
    apt-get install -y \
    lib32readline-dev \
    build-essential \
    squashfs-tools \
    libxml2-utils \
    libsdl1.2-dev \
    g++-multilib \
    gcc-multilib \
    imagemagick \
    lib32z1-dev \
    liblz4-tool \
    libelf-dev \
    zlib1g-dev \
    libssl-dev \
    schedtool \
    pngcrush \
    xsltproc \
    libxml2 \
    git-lfs \
    ccache \
    gnupg \
    bison \
    rsync \
    gperf \
    curl \
    lzop \
    flex \
    git \
    zip \
    bc

# Install libncurses5
RUN set -x; \
    wget http://archive.ubuntu.com/ubuntu/pool/universe/n/ncurses/libtinfo5_6.4-2_amd64.deb -P /tmp; \
    dpkg -i /tmp/libtinfo5_6.4-2_amd64.deb && rm -f /tmp/libtinfo5_6.4-2_amd64.deb; \
    wget http://archive.ubuntu.com/ubuntu/pool/universe/n/ncurses/libncurses5_6.4-2_amd64.deb -P /tmp; \
    dpkg -i /tmp/libncurses5_6.4-2_amd64.deb && rm -f /tmp/libncurses5_6.4-2_amd64.deb

# Download Java (OpenJDK 11 - Lineage OS 18.1+)
RUN set -x; \
    wget https://download.java.net/java/GA/jdk11/9/GPL/openjdk-11.0.2_linux-x64_bin.tar.gz -P /tmp; \
    tar -xf /tmp/openjdk-11.0.2_linux-x64_bin.tar.gz -C /tmp; \
    rm -f /tmp/openjdk-11.0.2_linux-x64_bin.tar.gz

ENV JAVA_HOME=/usr/lib/jvm/jdk-11.0.2
ENV PATH="$JAVA_HOME/bin:$PATH"

# Install Java
RUN set -x; \
    mkdir -p /usr/lib/jvm/jdk-11.0.2; \
    mv /tmp/jdk-11.0.2/* /usr/lib/jvm/jdk-11.0.2; \
    sed -i 's/TLSv1,TLSv1.1,//g' /usr/lib/jvm/jdk-11.0.2/conf/security/java.security

# Avoid error 'add-apt-repository: command not found'
RUN apt-get install software-properties-common -y

# Install Python
RUN set -x; \
    add-apt-repository ppa:deadsnakes/ppa; \
    apt-get update && apt-get install python3.13 -y

# Install Supervisor in order to let the image be able to run as a container when requested to do so
RUN apt-get install supervisor -y

# Copy a custom Supervisor configuration from host into the image
COPY image-data/etc/supervisor/conf.d/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Call and execute the supervisor after build is complete
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]