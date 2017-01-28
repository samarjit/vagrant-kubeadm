systemctl restart network.service

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

systemctl enable docker && systemctl start docker && systemctl status docker
systemctl enable kubelet && systemctl start kubelet && systemctl status kubelet
