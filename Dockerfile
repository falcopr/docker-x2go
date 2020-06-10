FROM archlinux:20200605
MAINTAINER FALCO PRESCHER

ENV BUILD_VERSION='20200610_1450'

ENV PATH='/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin' \
    LANG='en_US.UTF-8' \
    LANGUAGE='en_US:en' \
    LC_TIME='en_US.UTF-8' \
    LC_PAPER='en_US.UTF-8' \
    LC_MEASUREMENT='en_US.UTF-8' \
    TZ='UTC'

RUN pacman -Sy && \
    pacman -S openssh x2goserver nxagent terminator \
    htop git firefox mate sudo nano --noconfirm

RUN mkdir -p /var/run/sshd && \
    sed -i 's/^#X11Forwarding.*/X11Forwarding yes/' /etc/ssh/sshd_config && \
    sed -i 's/^#X11DisplayOffset 10/X11DisplayOffset 10/' /etc/ssh/sshd_config && \
    sed -i 's/^#X11UseLocalhost yes/X11UseLocalhost yes/' /etc/ssh/sshd_config && \
    sed -i 's/^#AllowTcpForwarding yes/AllowTcpForwarding yes/' /etc/ssh/sshd_config && \
	sed -i 's/^# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers

RUN useradd -m -G wheel docker && \
    mkdir -p /home/docker/.ssh && \
    chmod 700 /home/docker/.ssh && \
    chown docker:docker /home/docker/.ssh && \
    mkdir -p /etc/sudoers.d && \
    x2godbadmin --createdb

RUN systemctl enable sshd.service && \
    systemctl enable x2goserver.service

ADD ./999-sudoers-docker /etc/sudoers.d/999-sudoers-docker
RUN chmod 440 /etc/sudoers.d/999-sudoers-docker

ADD ./generate-key.sh /root/generate-key.sh
RUN chmod 744 /root/generate-key.sh
RUN /root/generate-key.sh

RUN ln --symbolic "/usr/share/zoneinfo/Europe/Berlin" /etc/localtime

EXPOSE 22

VOLUME ["/sys/fs/cgroup", "/tmp", "/run", "/run/lock"]
CMD ["/lib/systemd/systemd"]
# ENTRYPOINT ["/root/start-sshd.sh"]

# RUN (apt update && \
#      apt install -y software-properties-common && \
#      add-apt-repository universe && \
#      add-apt-repository multiverse && \
#      add-apt-repository restricted && \
#      add-apt-repository -y ppa:x2go/stable && \
#      apt update && \
#      # Removing snapd since its not working properly inside a container
#     #  apt purge snapd && \
#      DEBIAN_FRONTEND=noninteractive apt install -y \
#          x2goserver x2goserver-xsession \
#          mate-desktop-environment-extras \
#          sudo rxvt-unicode-256color \
#          firefox terminator git htop curl nano)

# RUN (mkdir -p /var/run/sshd && \
#      sed -ri 's/UseDNS yes/#UseDNS yes/g' /etc/ssh/sshd_config && \
#      echo "UseDNS no" >> /etc/ssh/sshd_config)
# #     sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config && \
# #     sed -ri 's/#UsePAM no/UsePAM no/g' /etc/ssh/sshd_config)

# # Create a user
# RUN (useradd -m docker && \
#      mkdir -p /home/docker/.ssh && \
#      chmod 700 /home/docker/.ssh && \
#      chown docker:docker /home/docker/.ssh && \
#      mkdir -p /etc/sudoers.d)

# ADD ./999-sudoers-docker /etc/sudoers.d/999-sudoers-docker
# RUN chmod 440 /etc/sudoers.d/999-sudoers-docker

# # Startup script
# ADD ./start-sshd.sh /root/start-sshd.sh
# RUN chmod 744 /root/start-sshd.sh

# RUN ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime

# EXPOSE 22
# ENTRYPOINT ["/root/start-sshd.sh"]
