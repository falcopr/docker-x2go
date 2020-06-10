FROM ubuntu:focal
MAINTAINER FALCO PRESCHER

RUN (apt update && \
     apt install -y software-properties-common && \
     add-apt-repository universe && \
     add-apt-repository multiverse && \
     add-apt-repository restricted && \
     add-apt-repository -y ppa:x2go/stable && \
     apt update && \
     # Removing snapd since its not working properly inside a container
    #  apt purge snapd && \
     DEBIAN_FRONTEND=noninteractive apt install -y \
         x2goserver x2goserver-xsession \
         mate-desktop-environment-extras \
         sudo rxvt-unicode-256color \
         firefox terminator git htop curl nano)

RUN (mkdir -p /var/run/sshd && \
     sed -ri 's/UseDNS yes/#UseDNS yes/g' /etc/ssh/sshd_config && \
     echo "UseDNS no" >> /etc/ssh/sshd_config)
#     sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config && \
#     sed -ri 's/#UsePAM no/UsePAM no/g' /etc/ssh/sshd_config)

# Create a user
RUN (useradd -m docker && \
     mkdir -p /home/docker/.ssh && \
     chmod 700 /home/docker/.ssh && \
     chown docker:docker /home/docker/.ssh && \
     mkdir -p /etc/sudoers.d)

ADD ./999-sudoers-docker /etc/sudoers.d/999-sudoers-docker
RUN chmod 440 /etc/sudoers.d/999-sudoers-docker

# Startup script
ADD ./start-sshd.sh /root/start-sshd.sh
RUN chmod 744 /root/start-sshd.sh

RUN ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime

EXPOSE 22
ENTRYPOINT ["/root/start-sshd.sh"]
