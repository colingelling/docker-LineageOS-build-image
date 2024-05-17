FROM ubuntu:24.04

LABEL author "Colin Gelling https://github.com/colingelling"

SHELL ["/bin/bash", "-c"]

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
  unzip /tmp/platform-tools-latest-linux.zip -d ${HOME}

# Set the PATH environment variable
ENV PATH="${HOME}/platform-tools:$PATH"

# Install Supervisor in order to let the image be able to run as a container when requested to do so
RUN apt-get install supervisor -y

# Copy a custom Supervisor configuration from host into the image
COPY image-data/etc/supervisor/conf.d/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Call and execute the supervisor after build is complete
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]