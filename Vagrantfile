# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "precise64new"
  config.vm.box_url = "http://files.vagrantup.com/precise64.box"

  config.vm.network :forwarded_port, guest: 80, host: 8080
  
  config.omnibus.chef_version = :latest
  config.berkshelf.enabled = true
  config.vm.provision :chef_solo do |chef|
    chef.add_recipe "postgresql::server"
    chef.add_recipe "redash::redis"
    chef.add_recipe "redash::database"
    chef.add_recipe "redash::deploy"
    chef.add_recipe "redash::services"
    chef.add_recipe "redash::nginx"
    chef.json = { 
      postgresql: {
        password: {
          postgres: "postgres"
        }
      }
    }
  end
end
