export http_proxy=http://corpproxy:8080  && export no_proxy=kmaster,kslave2,kslave,localhost,127.0.0.1,192.168.33.10,192.168.33.12,192.168.33.11,10.0.2.0/16,172.17.0.0/16,10.96.0.0/16,10.244.0.0/16

echo 'net.bridge.bridge-nf-call-iptables = 1' >> /etc/sysctl.conf
systemctl reload network

systemctl restart network.service

echo 'Expect 1 in the next line for bridge-nf-call-iptables:'

cat /proc/sys/net/bridge/bridge-nf-call-iptables 

echo 'INSTALL KUBERNETES'
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=http://yum.kubernetes.io/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg
       https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF
setenforce 0
yum install -y docker kubelet kubeadm kubectl kubernetes-cni wget ntp
systemctl start ntpd
systemctl enable ntpd

yum install -y epel-release 
yum install -y jq
yum install bind-utils -y
yum install -y tcpdump

mkdir -p /etc/systemd/system/kubelet.service.d/
cat <<EOF  > /etc/systemd/system/kubelet.service.d/90-local-extras.conf
[Service]
Environment="KUBELET_EXTRA_ARGS=--fail-swap-on=false"
EOF

mkdir -p /etc/systemd/system/docker.service.d/
cat <<EOF > /etc/systemd/system/docker.service.d/http-proxy.conf
[Service]
Environment="HTTP_PROXY=http://corpproxy:8080"
Environment="NO_PROXY=localhost,127.0.0.0/8,192.168.33.10,192.168.33.11,192.168.33.12"
EOF

systemctl daemon-reload

systemctl enable docker && systemctl start docker && systemctl status docker
systemctl enable kubelet && systemctl start kubelet && systemctl status kubelet

swapoff -a