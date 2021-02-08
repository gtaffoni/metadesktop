FROM ubuntu:18.04
LABEL Maintainer Giuliano Taffoni <giuliano.taffoni@inaf.it>
USER root
ENV CONTAINER_NAME='SkadcBase'
# Set non-interactive
ENV DEBIAN_FRONTEND noninteractive

# Always update when extending base images
RUN apt update
RUN apt -y upgrade

# install some requirements
RUN apt -y install lubuntu-core libjpeg-dev wget sudo git curl nano vim emacs
RUN apt-get install -y  supervisor 
RUN apt-get clean
# remove aoutmatic updates amnd warnings
#
RUN  sed -i 's\1\0\g' /etc/apt/apt.conf.d/20auto-upgrades
RUN  ln -s /usr/share/lxde/wallpapers/lxde_blue.jpg /etc/alternatives/desktop-background
#
#------------------------
# SKA user
#------------------------

# Add group. We chose GID 65527 to try avoiding conflicts.
RUN groupadd -g 65527 metagroup 

# Add user. We chose UID 65527 to try avoiding conflicts.
RUN useradd metauser -d /home/metauser -u 65527 -g 65527 -m -s /bin/bash

# Add metuaser user to sudoers
RUN adduser metauser sudo

# No pass sudo (for everyone, actually)
COPY files/sudoers /etc/sudoers


# Prepare for logs
RUN mkdir /home/metauser/.logs && chown metauser:metagroup /home/metauser/.logs

# Add fluxbox customisations
# COPY files/dot_fluxbox /home/lofar/.fluxbox
# RUN chown -R lofar:lofar /home/lofar/.fluxbox
#COPY files/background.jpg /usr/share/images/fluxbox/background.jpg

RUN mkdir /home/metauser/.vnc
COPY files/config  /home/metauser/.vnc
COPY files/xstartup /home/metauser/.vnc
RUN chmod 755 /home/metauser/.vnc/xstartup
RUN chown -R metauser:metagroup /home/metauser/.vnc

# Rename user home folder as a "vanilla" home folder
RUN mv /home/metauser /metauser_home_vanilla

# Give write access to anyone to the home folder so the entrypoint will be able
# to copy over the /home/matauser_vanilla into /home/metauser (for Singularity)
RUN chmod 777 /home

# Copy and install kasmvnc
COPY files/kasmvnc-Linux-x86_64-0.9.tar.gz /tmp
RUN sudo tar xz --strip 1 -C / -f /tmp/kasmvnc-Linux-x86_64-0.9.tar.gz && rm /tmp/kasmvnc-Linux-x86_64-0.9.tar.gz
RUN mkdir /usr/local/share/kasmvnc/certs
RUN chown metauser:metagroup /usr/local/share/kasmvnc/certs
COPY files/index.html /usr/local/share/kasmvnc/www/


# Global Supervisord conf
COPY files/supervisord.conf /etc/supervisor/
COPY files/supervisord_kasm.conf /etc/supervisor/conf.d/
COPY files/run_kasm.sh /etc/supervisor/conf.d/
RUN chmod 755 /etc/supervisor/conf.d/run_kasm.sh


#----------------------
# Entrypoint
#----------------------

# Copy entrypoint
COPY entrypoint.sh /

# Give right permissions
RUN chmod 755 /entrypoint.sh

# Set entrypoint
ENTRYPOINT ["/entrypoint.sh"]

# Set user lofar
USER metauser

# Set container name
ENV CONTAINER_NAME='virtualVNC.0.0.3'
RUN sudo apt install -y strace
