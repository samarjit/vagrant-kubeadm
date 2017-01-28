## Vagrant environment to simulate kubeadm with flannel add-on

This will create 2 bento/centos-7.2 VMs kmaster and kslave.


Vagrant version:
Virtual Box Version:

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
[root@kmaster ~]# kubectl get pods -o wide
NAME                                READY     STATUS    RESTARTS   AGE       IP              NODE
busybox                             1/1       Running   0          36m       10.244.1.5      kslave
hello-deployment-1725651635-1nnnx   1/1       Running   0          1h        10.244.1.4      kslave
hello-deployment-1725651635-dh3r6   1/1       Running   0          1h        10.244.1.3      kslave
hello-deployment-1725651635-smtx8   1/1       Running   0          1h        10.244.0.2      kmaster
kube-flannel-ds-bklmr               2/2       Running   0          1h        192.168.33.10   kmaster
kube-flannel-ds-m0lbd               2/2       Running   2          1h        192.168.33.11   kslave
[root@kmaster ~]#
```



