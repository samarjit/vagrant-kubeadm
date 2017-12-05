## Vagrant environment to simulate kubeadm with flannel add-on

This will create 2 bento/centos-7.2 VMs kmaster and kslave.


### Update

* Now it works with kubeadm 1.8.x
* Some previous hacks of /etc/kubernetes/manifests/kube-apiserver.json
* Adding ["--proxy-mode=userspace","--cluster-cidr=10.244.0.0/16"] to kube-proxy is not required.
* Previously one hack was missing for flannel --iface. It has been added now.
* Added option to set corporate proxy. Just replace all occurrences of 'corpproxy:8080' with your corporate proxy settings.

### Prerequisites

Vagrant version: Tested with 2.0.1 which is latest as of now
Virtual Box Version: Tested with 5.2.0 which is latest as of now

My version of vagrant and virtual box combination has some issue with networking. So right after boot up I need to fire `$systemctl restart network.service` on both kmaster and kslave.

Check ifconfig if 192.168.33.11 does not appear (virtual box issue).
Steps:

1. Login to kslave. Check ifconfig if 192.168.33.11 does not appear (virtual box issue). Then fire `$systemctl restart network.service`.
    * kubeadm join --token=7baee4.d576223cb4884c9b 192.168.33.10.
2. Login to kmaster. Check ifconfig if 192.168.33.10 does not appear (virtual box issue). Then fire `$systemctl restart network.service`.
    * kubectl taint nodes --all dedicated-
    * kubectl --kubeconfig /vagrant/admin.conf apply -f /vagrant/kube-flannel.yml
    * kubectl create -f /vagrant/service.yml -f /vagrant/deployment.yml    
    * kubectl get pods --all-namespaces

Expected to resolve to pod IPs. But this does not work. 
`dig +short  @10.96.0.10 _http._tcp.hello-service.default.svc.cluster.local SRV`     

````
kubectl -n kube-system describe pod -l name=kube-dns
kubectl logs kube-dns-2924299975-rs0fg  -c kube-dns --namespace=kube-system
$systemctl cat docker.service
````

This will dynamically fetch the IP and execute pod. (Does not work with flannel)

````
curl -sSL http://$(dig +short @10.96.0.10 $(dig +short  @10.96.0.10 \
        _http._tcp.hello-service.default.svc.cluster.local SRV | cut '-d ' -f4)):\
        $(dig +short @10.96.0.10 _http._tcp.hello-service.default.svc.cluster.local SRV | cut '-d ' -f3)
````



```
[root@kmaster net.d]# kubectl get svc kube-dns --namespace=kube-system
NAME       CLUSTER-IP   EXTERNAL-IP   PORT(S)         AGE
kube-dns   10.96.0.10   <none>        53/UDP,53/TCP   5h
```


```
[root@kmaster ~]# kubectl describe svc
Name:                   hello-service
Namespace:              default
Labels:                 <none>
Selector:               app=hello
Type:                   ClusterIP
IP:                     10.105.36.17
Port:                   http    80/TCP
Endpoints:              10.244.0.2:8080,10.244.1.3:8080,10.244.1.4:8080
Session Affinity:       None
No events.


Name:                   kubernetes
Namespace:              default
Labels:                 component=apiserver
                        provider=kubernetes
Selector:               <none>
Type:                   ClusterIP
IP:                     10.96.0.1
Port:                   https   443/TCP
Endpoints:              192.168.33.10:6443
Session Affinity:       ClientIP
No events.
[root@kmaster ~]#
```

This always point to master. Since the other two ips 10.244.1.4, 10.244.1.3 are not resolvable.

```
[root@kmaster ~]# curl http://10.105.36.17
Hello, "/"
HOST: hello-deployment-1725651635-smtx8
ADDRESSES:
    127.0.0.1/8
    10.244.0.2/24
    ::1/128
    fe80::855:c3ff:fe3c:180c/64
[root@kmaster ~]#
```

```
[root@kmaster ~]# kubectl get pods --all-namespaces -o wide
NAMESPACE     NAME                                READY     STATUS    RESTARTS   AGE       IP              NODE
default       busybox                             1/1       Running   1          1h        10.244.1.5      kslave
default       hello-deployment-1725651635-1nnnx   1/1       Running   0          2h        10.244.1.4      kslave
default       hello-deployment-1725651635-dh3r6   1/1       Running   0          2h        10.244.1.3      kslave
default       hello-deployment-1725651635-smtx8   1/1       Running   0          2h        10.244.0.2      kmaster
default       kube-flannel-ds-bklmr               2/2       Running   0          2h        192.168.33.10   kmaster
default       kube-flannel-ds-m0lbd               2/2       Running   2          2h        192.168.33.11   kslave
kube-system   dummy-2088944543-zrk8b              1/1       Running   0          2h        192.168.33.10   kmaster
kube-system   etcd-kmaster                        1/1       Running   0          2h        192.168.33.10   kmaster
kube-system   kube-apiserver-kmaster              1/1       Running   1          2h        192.168.33.10   kmaster
kube-system   kube-controller-manager-kmaster     1/1       Running   0          2h        192.168.33.10   kmaster
kube-system   kube-discovery-1769846148-f31cm     1/1       Running   0          2h        192.168.33.10   kmaster
kube-system   kube-dns-2924299975-tnsj3           4/4       Running   0          2h        10.244.1.2      kslave
kube-system   kube-proxy-hxrn3                    1/1       Running   0          2h        192.168.33.10   kmaster
kube-system   kube-proxy-kvn81                    1/1       Running   0          2h        192.168.33.11   kslave
kube-system   kube-scheduler-kmaster              1/1       Running   0          2h        192.168.33.10   kmaster
[root@kmaster ~]#
```



### Create your own docker image and run in k8s cluster
```
[root@kmaster ~]# cd /vagrant/fe
[root@kmaster fe]# docker build -t fe:1.0 .
[root@kmaster fe]# docker run -d -p 80:80 fe:1.0
[root@kmaster fe]# docker ps
```

Check that container is up and listening on port 80. `netstat -nlp|grep 80`.

```
[root@kmaster fe]# docker stop <container id that you got in the previous docker ps step>
```

```
[root@kmaster fe]# kubectl apply -f front.yml
[root@kmaster fe]# kubectl get pod -owide
[root@kmaster fe]# kubectl get svc
[root@kmaster fe]# curl 192.168.33.10/ui/src/            --- Should return the index.html
```

