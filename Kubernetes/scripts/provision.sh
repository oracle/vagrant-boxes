#!/bin/bash
#
# LICENSE UPL 1.0
#
# Copyright (c) 1982-2018 Oracle and/or its affiliates. All rights reserved.
#
# Since: March, 2018
# Author: philippe.vanhaesendonck@oracle.com
# Description: Installs Docker Engine, Kubernetes packages and satisfy
#              pre-requisites
#
# DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS HEADER.
#

# YUM repo selection.
YumRepos="--disablerepo=ol7_preview"
Insecure=""

# Parse arguments
while [ $# -gt 0 ]
do
  case "$1" in
    "--preview")
      YumRepos="--enablerepo=ol7_preview"
      shift
      ;;
    "--insecure")
      if [ $# -lt 2 ]
      then
        echo "Missing parameter"
	exit 1
      fi
      Insecure="$2"
      shift; shift
      ;;
    *)
      echo "Invalid parameter"
      exit 1
      ;;
  esac
done

echo "Installing and configuring Docker Engine"

# Install Docker
yum ${YumRepos} install -y docker-engine btrfs-progs

# Create and mount a BTRFS partition for docker.
docker-storage-config -f -s btrfs -d /dev/sdb

# Kubernetes: Docker should not touch iptables -- See Orabug 26641724/26641807
# Alternatively you could use firewalld as described in the Kubernetes User's Guide
# On the ol74 box, firewalld is installed but disabled by default.
sed -i "s/^OPTIONS='\(.*\)'/OPTIONS='\1 --iptables=false'/" /etc/sysconfig/docker

# Configure insecure (non-ssl) registry if needed
if [ -n "${Insecure}" ]
then
  sed -i "s/\"$/\",\n    \"insecure-registries\": [\"${Insecure}\"]/" /etc/docker/daemon.json
fi

# Add vagrant user to docker group
usermod -a -G docker vagrant

# Enable and start Docker
systemctl enable docker
systemctl start docker

echo "Installing and configuring Kubernetes packages"

# Install Kubernetes packages from the "preview" channel fulfil pre-requisites
yum ${YumRepos} install -y  kubeadm
# Set SeLinux to Permissive
/usr/sbin/setenforce 0
sed -i 's/^SELINUX=.*/SELINUX=permissive/g' /etc/selinux/config
# Bridge filtering
modprobe br_netfilter
echo "br_netfilter" > /etc/modules-load.d/br_netfilter.conf
sysctl -p /etc/sysctl.d/k8s.conf
# Ensure kubelet uses the right IP address
IP=$(ip addr | awk -F'[ /]+' '/192.168.99.255/ {print $3}')
KubeletNode="/etc/systemd/system/kubelet.service.d/90-node-ip.conf"
cat <<-EOF >${KubeletNode}
	[Service]
	Environment="KUBELET_NODE_IP_ARGS=--node-ip=${IP}"
	ExecStart=
	ExecStart=/usr/bin/kubelet \$KUBELET_KUBECONFIG_ARGS \$KUBELET_SYSTEM_PODS_ARGS \$KUBELET_NETWORK_ARGS \$KUBELET_DNS_ARGS \$KUBELET_AUTHZ_ARGS \$KUBELET_CGROUP_ARGS \$KUBELET_CADVISOR_ARGS \$KUBELET_CERTIFICATE_ARGS \$KUBELET_EXTRA_ARGS \$KUBELET_NODE_IP_ARGS \$KUBELET_FLAGS
EOF
chmod 755 ${KubeletNode}
systemctl daemon-reload

echo "Your Kubernetes VM is ready to use!"
