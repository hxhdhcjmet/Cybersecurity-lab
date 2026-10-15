FROM ubuntu:24.04
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends bash bash-completion ca-certificates coreutils findutils grep sed less nano vim procps util-linux iproute2 iputils-ping dnsutils traceroute curl wget tcpdump net-tools netcat-openbsd hping3 nmap openssh-client inetutils-telnet inetutils-ftp python3 python3-scapy && rm -rf /var/lib/apt/lists/*
ENV SHELL=/bin/bash HOME=/root TERM=xterm-256color
WORKDIR /root
RUN printf '%s\n' 'export PS1="\u@\h:\w\$ "' > /root/.bashrc
CMD ["/bin/bash"]
LABEL topology.role=client
