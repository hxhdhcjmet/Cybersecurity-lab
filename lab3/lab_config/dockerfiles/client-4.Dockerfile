FROM ubuntu:24.04
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends bash bash-completion ca-certificates coreutils findutils grep sed less nano vim procps util-linux iproute2 iputils-ping dnsutils traceroute curl wget tcpdump net-tools netcat-openbsd hping3 nmap openssh-client inetutils-telnet inetutils-ftp python3 python3-scapy apache2 openssh-server vsftpd busybox-static && rm -rf /var/lib/apt/lists/*
RUN (id -u lab >/dev/null 2>&1 || useradd -m -s /bin/bash lab) && mkdir -p /run/sshd /var/run/vsftpd/empty /etc/ssh/sshd_config.d && printf '%s\n' 'PasswordAuthentication yes' 'PermitRootLogin no' > /etc/ssh/sshd_config.d/topology.conf && printf '%s\n' 'listen=YES' 'listen_ipv6=NO' 'background=YES' 'anonymous_enable=NO' 'local_enable=YES' 'write_enable=YES' 'local_umask=022' 'chroot_local_user=YES' 'allow_writeable_chroot=YES' 'pam_service_name=vsftpd' 'secure_chroot_dir=/var/run/vsftpd/empty' 'pasv_enable=YES' 'pasv_min_port=30000' 'pasv_max_port=30009' 'seccomp_sandbox=NO' > /etc/vsftpd.conf && printf '%s\n' 'ServerName localhost' > /etc/apache2/conf-available/topology-server-name.conf && a2enconf topology-server-name
EXPOSE 21 22 23 80 30000-30009
ENV SHELL=/bin/bash HOME=/root TERM=xterm-256color
WORKDIR /root
RUN printf '%s\n' 'export PS1="\u@\h:\w\$ "' > /root/.bashrc
CMD ["/bin/bash"]
LABEL topology.role=server
