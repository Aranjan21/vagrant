# -*- mode: ruby -*-
# vi: set ft=ruby :
 
Vagrant.configure("2") do |config|
    config.vm.box = "Centos/7"
 
    config.vm.define :jenkins do |jenkins_config|
        jenkins_config.vm.hostname = 'jenkins'
        jenkins_config.vm.network "private_network", ip: "192.168.33.11"
    end
 
    config.vm.provider :virtualbox do |virtualbox_config|
        virtualbox_config.name = "Jenkins - CentOs"
    end
 
    config.vm.provision :shell, path: "bootstrap.sh"
end