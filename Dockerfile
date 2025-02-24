FROM alpine:3.21.3 AS app-image
ENV container docker

#hadolint ignore=DL3018
RUN apk add --no-cache nfs-utils bash git openssh-client && \
    mkdir -p /var/lib/nfs/rpc_pipefs /var/lib/nfs/v4recovery && \
    echo "rpc_pipefs    /var/lib/nfs/rpc_pipefs rpc_pipefs      defaults        0       0" >> /etc/fstab && \
    echo "nfsd  /proc/fs/nfsd   nfsd    defaults        0       0" >> /etc/fstab

RUN echo "HashKnownHosts no" >> /etc/ssh/ssh_config && \
    echo "IdentityFile /etc/ssh/id_rsa" >> /etc/ssh/ssh_config && \
    echo "IdentityFile /etc/ssh/id_ed25519" >> /etc/ssh/ssh_config

COPY exports /etc/
COPY nfsd.sh /usr/bin/nfsd.sh
COPY git-pull.sh /usr/bin/git-pull.sh
COPY entrypoint.sh /usr/bin/entrypoint.sh

RUN chmod +x /usr/bin/nfsd.sh /usr/bin/git-pull.sh /usr/bin/entrypoint.sh

ENTRYPOINT ["/usr/bin/entrypoint.sh"]
