# -*- mode: ruby -*-
# vi: set ft=ruby :
Vagrant.require_version ">= 1.4.3"
VAGRANTFILE_API_VERSION = "2"

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.
  
  #Multi-Machine config
  config.vm.box = "bento/centos-7.2" #"opscode-centos-7.0" #
  #config.vm.box_url = "http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_centos-7.0_chef-provisionerless.box"
  config.vm.boot_timeout = 1000
  config.vbguest.auto_update = false

  config.vm.define "kmaster" do |kmaster|
	  
	  kmaster.vm.provider "virtualbox" do |vb|
      vb.name = "kmaster"
      vb.customize ["modifyvm", :id, "--memory", "4096"]
      vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
      vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
      vb.customize ['modifyvm', :id, '--cableconnected1', 'on']

    end   
    kmaster.vm.network "private_network", ip:  "192.168.33.10"
    kmaster.vm.network "forwarded_port", guest: 80, host: 8888, auto_config: true
    kmaster.vm.network "forwarded_port", guest: 8001, host: 8001, auto_config: true
    kmaster.vm.network "forwarded_port", guest: 8080, host: 8080, auto_config: true
    kmaster.vm.hostname = "kmaster"
    
    kmaster.vm.provision :shell, :inline => "sed 's/127.0.0.1.*kmaster/192.168.33.10 kmaster/' -i /etc/hosts"
    kmaster.vm.provision :shell, :inline => "setenforce 0"
    kmaster.vm.provision :shell, :inline => "sed -i 's/^SELINUX=.*/SELINUX=disabled/g' /etc/sysconfig/selinux"

    kmaster.vm.provision :shell, path: "install.sh"
    kmaster.vm.provision :shell, path: "setup.sh"

  end
  
  config.vm.define "kslave" do |kslave|
	  kslave.vm.provider "virtualbox" do |vb|
      vb.name = "kslave"
      vb.customize ["modifyvm", :id, "--memory", "2048"]
      vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
      vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
      vb.customize ['modifyvm', :id, '--cableconnected1', 'on']
    end   

    kslave.vm.network "public_network", ip: "192.168.33.11"
    kslave.vm.network "forwarded_port", guest: 80, host: 8889, auto_config: false
    kslave.vm.network "forwarded_port", guest: 8080, host: 8081, auto_config: false
    kslave.vm.hostname = "kslave"

    kslave.vm.provision :shell, :inline => "sed 's/127.0.0.1.*kslave/192.168.33.11 kslave/' -i /etc/hosts"
    kslave.vm.provision :shell, :inline => "setenforce 0"
    kslave.vm.provision :shell, :inline => "sed -i 's/^SELINUX=.*/SELINUX=disabled/g' /etc/sysconfig/selinux"
    kslave.vm.provision :shell, path: "install.sh"
  end
 
  # config.vm.define "javaingest" do |javaingest|
	 #  javaingest.vm.provider "virtualbox" do |vb|
  #     vb.name = "javaingest"
  #     vb.customize ["modifyvm", :id, "--memory", "1024"]
  #     vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
  #     vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
  #   end   

  #   javaingest.vm.network "public_network", ip:"192.168.33.12"
  #   javaingest.vm.hostname = "javaingestion"
  # end
  # config.vm.provision "docker"
  # config.vm.provision "ansible" do |ansible|
  #   ansible.playbook = "playbook.yml"
  # end
 end
