Vagrant.require_version ">= 1.7.0"

$os_image = (ENV['OS_IMAGE'] || "ubuntu16").to_sym

def set_vbox(vb, config)
  vb.gui = false
  vb.memory = 2048
  vb.cpus = 1

  case $os_image
  when :centos7
    config.vm.box = "bento/centos-7.2"
  when :ubuntu16
    config.vm.box = "bento/ubuntu-16.04"
    #config.vm.box = "frjaraur/xenial64"
    #config.vm.box_version = "1.4"
  end
end

Vagrant.configure("2") do |config|
  config.vm.provider "virtualbox"
  master = 1
  node = 2

  private_count = 10 + master + node
  (1..(master + node)).each do |mid|
    name = (mid <= node) ? "node" : "master"
    id   = (mid <= node) ? mid : (mid - node)
    p = private_count -1 
    config.vm.define "k8s-#{name}#{id}" do |n|
      n.vm.hostname = "k8s-#{name}#{id}"
      ip_addr = "10.10.10.#{private_count}"
      n.vm.network "private_network",
       ip: "#{ip_addr}", :netmask => "255.255.255.0",
       virtualbox__intnet: false,
       hostonlyadapter: ["vboxnet1"]

      #n.vm.network :private_network, ip: "#{ip_addr}",  auto_config: true

      n.vm.provider :virtualbox do |vb, override|
        vb.name = "#{n.vm.hostname}"
        set_vbox(vb, override)
      end
      private_count -= 1
    end
  end

  # Install of dependency packages using script
  config.vm.provision :shell, path: "./setup/setup-vms.sh"
end
