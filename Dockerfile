# Originally from: https://android-review.googlesource.com/c/platform/build/+/1161367

FROM ubuntu:22.04
ARG userid=1000
ARG groupid=1000
ARG username=mojo
ARG mojo_auth
ARG https_proxy

ENV DEBIAN_FRONTEND=noninteractive

# Using separate RUNs here allows Docker to cache each update
# Make sure the base image is up to date
# Install apt-utils to make apt run more smoothly
# Install deb required by mojo
RUN apt-get update -qq && apt-get upgrade -y && \
    apt-get install -y apt-utils curl sudo && \
    apt-get install -y libedit2 libncurses-dev apt-transport-https \
      ca-certificates gnupg libxml2-dev python3 python3-pip python3-dev python3.10-venv && \
    apt-get clean

# Disable some gpg options which can cause problems in IPv4 only environments
RUN mkdir ~/.gnupg && chmod 600 ~/.gnupg && echo "disable-ipv6" >> ~/.gnupg/dirmngr.conf

# Create the home directory for the build user
RUN groupadd -g $groupid $username \
    && useradd -m -s /bin/bash -u $userid -g $groupid $username \
    && mkdir -p /home/$username && chown $userid:$groupid /home/$username
RUN echo "$username ALL=(ALL:ALL) NOPASSWD: ALL" > /etc/sudoers.d/$username

# Install the modular package
RUN echo "export HOME=/home/$username" >> /home/$username/.bashrc
RUN curl https://get.modular.com | \
  sudo -u $username ALL_PROXY=$https_proxy MODULAR_AUTH=$mojo_auth bash -

# Install the mojo package
RUN sudo -u $username bash -c "mkdir -p ~/.modular/pkg/packages.modular.com_mojo && cd ~/.modular/pkg/packages.modular.com_mojo && python3 -m venv venv"
RUN sudo -u $username ALL_PROXY=$https_proxy \
  bash -c "cd ~/.modular/pkg/packages.modular.com_mojo && source venv/bin/activate && modular install mojo"

# Update the mojo package manually
# RUN sudo -u $username ALL_PROXY=$https_proxy \
#   bash -c "cd \$HOME && source venv/bin/activate && modular update mojo"

RUN echo 'export MODULAR_HOME="$HOME/.modular"' >> /home/$username/.bashrc
RUN echo 'export PATH="$HOME/.modular/pkg/packages.modular.com_mojo/bin:$PATH"' >> /home/$username/.bashrc

WORKDIR /home/$username
USER $username
