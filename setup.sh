export http_proxy=http://corpproxy:8080  && export no_proxy=kmaster,kslave2,kslave,localhost,127.0.0.1,192.168.33.10,192.168.33.12,192.168.33.11,10.0.2.0/16,172.17.0.0/16,10.96.0.0/16,10.244.0.0/16

kubeadm init --apiserver-advertise-address=192.168.33.10 --token=7baee4.d576223cb4884c9b --pod-network-cidr="10.244.0.0/16"

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

## --iface added
kubectl apply -f /vagrant/kube-flannel.yml

# jq \
#    '.spec.containers[0].command |= .+ ["--advertise-address=192.168.33.10"]' \
#    /etc/kubernetes/manifests/kube-apiserver.json > /tmp/kube-apiserver.json
# mv /tmp/kube-apiserver.json /etc/kubernetes/manifests/kube-apiserver.json


# kubectl -n kube-system get ds -l 'component=kube-proxy' -o json \
#   | jq '.items[0].spec.template.spec.containers[0].command |= .+ ["--proxy-mode=userspace","--cluster-cidr=10.244.0.0/16"]' \
#   |   kubectl apply -f - && kubectl -n kube-system delete pods -l 'component=kube-proxy'


cp /etc/kubernetes/admin.conf /vagrant
