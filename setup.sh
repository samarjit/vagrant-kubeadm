kubeadm init --api-advertise-addresses=192.168.33.10 --token=7baee4.d576223cb4884c9b --pod-network-cidr="10.244.0.0/16"
jq \
   '.spec.containers[0].command |= .+ ["--advertise-address=192.168.33.10"]' \
   /etc/kubernetes/manifests/kube-apiserver.json > /tmp/kube-apiserver.json
mv /tmp/kube-apiserver.json /etc/kubernetes/manifests/kube-apiserver.json


kubectl -n kube-system get ds -l 'component=kube-proxy' -o json \
  | jq '.items[0].spec.template.spec.containers[0].command |= .+ ["--proxy-mode=userspace","--cluster-cidr=10.244.0.0/16"]' \
  |   kubectl apply -f - && kubectl -n kube-system delete pods -l 'component=kube-proxy'
  cp /etc/kubernetes/admin.conf /vagrant
