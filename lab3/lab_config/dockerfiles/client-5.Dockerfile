FROM kasmweb/ubuntu-focal-desktop:1.16.0
USER root
RUN apt-get update \
    && apt-get install -y --no-install-recommends sudo ca-certificates procps iproute2 iputils-ping dnsutils traceroute curl wget tcpdump net-tools netcat-openbsd hping3 nmap openssh-client inetutils-telnet inetutils-ftp less nano vim \
    && printf '%s\n' 'kasm-user ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/kasm-user \
    && chmod 0440 /etc/sudoers.d/kasm-user \
    && rm -rf /var/lib/apt/lists/*
USER 1000
LABEL topology.role=client
