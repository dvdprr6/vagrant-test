# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.box = "puphpet/centos65-x64"

  config.vm.network "forwarded_port", guest: 80, host: 8080
  
  config.ssh.forward_agent = true

  config.vm.synced_folder "./", "/vagrant"

  config.vm.provision "puppet" do |puppet|
    puppet.manifests_path = "puppet/manifests"
    puppet.manifest_file = "setup.pp"
  end

end
