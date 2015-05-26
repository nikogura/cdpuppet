# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

require 'vagrant-hosts'
require 'vagrant-auto_network'

app="puppetjenkins"
confType="json"
boxMemory=2048

boxes = [
    {
        :name => 'puppet',
        :memory => boxMemory,
        :provisioner => 'linux_masterless.sh',
        :provisionArgs => "-m #{app} -t #{confType} -e dev" ,
        :box => 'puppetlabs/centos-6.6-64-puppet',
        :guestport => 8080,
        :hostport  => 8080,
    },


]

workingDir  = File.expand_path(File.dirname(__FILE__))

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  boxes.each do |box|
    config.vm.define box[:name] do |node|
      node.vm.hostname = box[:name]
      node.vm.box = box[:box]

      if (box[:box_url])
        node.vm.box_url = box[:box_url]
      end

      node.vm.network :private_network, :auto_network => true
      node.vm.provision :hosts
      #node.proxy.http = "http://10.0.2.2:3128"

      if (box[:guestport])
        node.vm.network "forwarded_port", guest: box[:guestport], host: box[:hostport]
      end

      #node.vm.synced_folder "modules", "/etc/puppet/modules"

      node.vm.provider "virtualbox" do |vb|
        #   # Use VBoxManage to customize the VM. For example to change memory:
        vb.customize ["modifyvm", :id, "--memory", box[:memory]]
        vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
      end

      # Copy keys to VM
      node.vm.provision :file, source: "~/.ssh", destination: "/tmp/.ssh"

      # move keys into place
      node.vm.provision :shell, :path => "#{workingDir}/provision/copy_host_keys_root.sh"

      node.vm.provision :shell do |shell|
        shell.path = "#{workingDir}/provision/#{box[:provisioner]}"
        shell.args = "-n #{box[:name]} #{box[:provisionArgs]}"
      end


    end
  end

end