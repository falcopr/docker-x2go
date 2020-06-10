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
    firefox chromium mate mate-extra sudo \
    htop git nano code dotnet-sdk nodejs gimp p7zip inkscape midori --noconfirm

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
