# Originally from: https://android-review.googlesource.com/c/platform/build/+/1161367

FROM ubuntu:22.04
ARG userid=1000
ARG groupid=1000
ARG username=mojo
ARG mojo_auth
ARG https_proxy

# Using separate RUNs here allows Docker to cache each update
RUN DEBIAN_FRONTEND="noninteractive" apt-get update

# Make sure the base image is up to date
RUN DEBIAN_FRONTEND="noninteractive" apt-get upgrade -y

# Install apt-utils to make apt run more smoothly
RUN DEBIAN_FRONTEND="noninteractive" apt-get install -y apt-utils curl sudo

# Install deb required by mojo
RUN DEBIAN_FRONTEND="noninteractive" apt-get install -y libncurses-dev apt-transport-https ca-certificates gnupg libxml2-dev python3 python3-pip python3-dev

# Disable some gpg options which can cause problems in IPv4 only environments
RUN mkdir ~/.gnupg && chmod 600 ~/.gnupg && echo "disable-ipv6" >> ~/.gnupg/dirmngr.conf

# Create the home directory for the build user
RUN groupadd -g $groupid $username \
 && useradd -m -s /bin/bash -u $userid -g $groupid $username \
 && mkdir -p /home/$username && chown $userid:$groupid /home/$username
RUN echo "$username ALL=(ALL:ALL) NOPASSWD: ALL" > /etc/sudoers.d/$username

# Install the modular package
RUN curl https://get.modular.com | \
  ALL_PROXY=$https_proxy https_proxy=$https_proxy HOME=/home/$username DEBIAN_FRONTEND="noninteractive" MODULAR_AUTH=$mojo_auth sudo -u $username -E sh

# Install the mojo package
RUN ALL_PROXY=$https_proxy https_proxy=$https_proxy HOME=/home/$username sudo -u $username -E modular install mojo

RUN echo 'export MODULAR_HOME="$HOME/.modular"' >> /home/$username/.bashrc
RUN echo 'export PATH="$HOME/.modular/pkg/packages.modular.com_mojo/bin:$PATH"' >> /home/$username/.bashrc

WORKDIR /home/$username
USER $username
