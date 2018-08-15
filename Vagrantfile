# -*- mode: ruby -*-
# vi: set ft=ruby :
#Vagrant::DEFAULT_SERVER_URL.replace('https://vagrantcloud.com')
# Require YAML module
require 'yaml'

config = YAML.load_file(File.join(File.dirname(__FILE__), 'config.yml'))

base_box=config['environment']['base_box']

base_box_version=config['environment']['base_box_version']

domain=config['environment']['domain']

engine_version=config['environment']['engine_version']

boxes = config['boxes']

boxes_hostsfile_entries=""

boxes_hosts=""

 boxes.each do |box|
   boxes_hostsfile_entries=boxes_hostsfile_entries+box['mgmt_ip'] + ' ' +  box['name'] + ' ' + box['name']+'.'+domain+'\n'
   boxes_hosts=boxes_hosts+box['mgmt_ip'] + ' '
  end


update_hosts = <<SCRIPT
    echo "127.0.0.1 localhost" >/etc/hosts
    echo -e "#{boxes_hostsfile_entries}" |tee -a /etc/hosts
SCRIPT

install_common_software  = <<SCRIPT
  systemctl stop apt-daily.timer
  systemctl disable apt-daily.timer
  sed -i '/Update-Package-Lists/ s/1/0/' /etc/apt/apt.conf.d/10periodic
  while true;do fuser -vki /var/lib/apt/lists/lock || break ;done
  apt-get update -qq \
  && apt-get install -qq \
  ntpdate \
  ntp \
  python \
  && timedatectl set-timezone Europe/Madrid
SCRIPT

install_ansible_master = <<SCRIPT
  apt-add-repository -y ppa:ansible/ansible && apt-get update -qq && apt-get install -qq \
  ansible \
  git \
  sshpass \
  python-netaddr \
  libssl-dev
SCRIPT

$install_docker_engine = <<SCRIPT
  #curl -sSk $1 | sh
  DEBIAN_FRONTEND=noninteractive apt-get remove -qq docker docker-engine docker.io
  DEBIAN_FRONTEND=noninteractive apt-get update -qq
  DEBIAN_FRONTEND=noninteractive apt-get install -qq \
  apt-transport-https \
  ca-certificates \
  curl \
  software-properties-common \
  bridge-utils
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | DEBIAN_FRONTEND=noninteractive apt-key add -
  add-apt-repository \
  "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) \
  stable"
  DEBIAN_FRONTEND=noninteractive apt-get -qq update
  DEBIAN_FRONTEND=noninteractive apt-get install -y docker-ce=$1
  usermod -aG docker vagrant >/dev/null
SCRIPT



$install_kubernetes = <<SCRIPT
  curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
  echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list 
  apt-get update -qq
  apt-get install -y --allow-unauthenticated kubelet=$1 kubeadm=$1 kubectl=$1 kubernetes-cni
  sed -i \'9s/^/Environment="KUBELET_EXTRA_ARGS=--fail-swap-on=false"\\n/\' /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
  systemctl daemon-reload
  systemctl enable kubelet
  echo "Kubelet Configured without Swap"
SCRIPT

$create_kubernetes_cluster = <<SCRIPT
  kubeadm init --pod-network-cidr 10.244.0.0/16 --apiserver-advertise-address $1
  sleep 30
	mkdir -p ~vagrant/.kube
	cp -i /etc/kubernetes/admin.conf ~vagrant/.kube/config
	chown vagrant:vagrant ~vagrant/.kube/config
  kubeadm token list |awk '/default-node-token/ { print $1 }'> /tmp_deploying_stage/token
  while true;do curl -ksSL https://$1:6443 && break;done
  kubectl --kubeconfig=/home/vagrant/.kube/config  apply -f https://docs.projectcalico.org/v3.1/getting-started/kubernetes/installation/hosted/kubeadm/1.7/calico.yaml
SCRIPT

$join_kubernetes_cluster = <<SCRIPT
  kubeadm join $1:6443 --token "$(cat /tmp_deploying_stage/token)" --discovery-token-unsafe-skip-ca-verification
SCRIPT


Vagrant.configure(2) do |config|
  VAGRANT_COMMAND = ARGV[0]
#   if VAGRANT_COMMAND == "ssh"
#    config.ssh.username = 'ubuntu'
#    config.ssh.password = 'ubuntu'
#   end
  config.vm.box = base_box
  config.vm.box_version = base_box_version
#  config.vm.synced_folder "tmp_deploying_stage/", "/tmp_deploying_stage",create:true
#  config.vm.synced_folder "src/", "/src",create:true
  boxes.each do |node|
    config.vm.define node['name'] do |config|
      config.vm.hostname = node['name']
      config.vm.provider "virtualbox" do |v|
	      v.linked_clone = true
        config.ssh.shell = "bash -c 'BASH_ENV=/etc/profile exec bash'"       
	      v.customize [ "modifyvm", :id, "--uartmode1", "disconnected" ]
        v.name = node['name']
        v.customize ["modifyvm", :id, "--memory", node['mem']]
        v.customize ["modifyvm", :id, "--cpus", node['cpu']]

        v.customize ["modifyvm", :id, "--nictype1", "Am79C973"]
        v.customize ["modifyvm", :id, "--nictype2", "Am79C973"]
        v.customize ["modifyvm", :id, "--nictype3", "Am79C973"]
        v.customize ["modifyvm", :id, "--nictype4", "Am79C973"]
        v.customize ["modifyvm", :id, "--nicpromisc1", "allow-all"]
        v.customize ["modifyvm", :id, "--nicpromisc2", "allow-all"]
        v.customize ["modifyvm", :id, "--nicpromisc3", "allow-all"]
        v.customize ["modifyvm", :id, "--nicpromisc4", "allow-all"]
        v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
      end

      config.vm.network "private_network",
      ip: node['mgmt_ip'],:netmask => "255.255.255.0",
      virtualbox__intnet: false,
      hostonlyadapter: ["vboxnet1"]

      config.vm.network "public_network",
      bridge: ["enp4s0","wlp3s0","enp3s0f1","wlp2s0","enp3s0"],
      auto_config: true

      config.vm.provision :shell, :inline => install_common_software

      config.vm.provision :shell, :inline => update_hosts

      # Install of dependency packages using script 
      # and Deploy Kubernetes Cluster using Ansible (site.yaml)
      
      if node['role'] == "master"
        config.vm.provision :shell, :inline => install_ansible_master

        #puts "We will use Ansible to install packages and deploy Kubernetes cluster"
        config.vm.provision :shell,
        :path => "./setup/setup-vms.sh",
        :args => [boxes_hosts]       
      end  
      
    end

  end


end
