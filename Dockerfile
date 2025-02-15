FROM quay.io/openshift/origin-must-gather:4.9.0 as builder

FROM quay.io/centos/centos:8

ENV INSTALLATION_NAMESPACE kubevirt-hyperconverged

# For gathering data from nodes
RUN dnf update -y && \
    dnf install iproute tcpdump pciutils util-linux nftables rsync jq -y && \
    dnf clean all && \
    curl -L $(curl -s https://api.github.com/repos/mikefarah/yq/releases/latest | jq -r '.assets[] | select(.name == "yq_linux_amd64") | .browser_download_url') -o /usr/bin/yq && \
    chmod +x /usr/bin/yq

COPY --from=builder /usr/bin/oc /usr/bin/oc

# Copy all collection scripts to /usr/bin
COPY collection-scripts/* /usr/bin/

# Copy node-gather resources to /etc
COPY node-gather /etc/

ENTRYPOINT /usr/bin/gather
