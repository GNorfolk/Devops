# -*- mode: ruby -*-
# vi: set ft=ruby :

required_plugins = %w( vagrant-hostsupdater )
required_plugins.each do |plugin|
    exec "vagrant plugin install #{plugin};vagrant #{ARGV.join(" ")}" unless Vagrant.has_plugin? plugin || ARGV[0] == 'plugin'
end

Vagrant.configure("2") do |config|

  config.vm.box = "ubuntu/xenial64"

  # sync the environment folder to the guest 
  config.vm.synced_folder "environment", "/home/ubuntu/environment"

  config.vm.define "web" do |web|
    
    config.vm.network "private_network", ip: "192.168.10.100"
    config.hostsupdater.aliases = ["development.local"]

    # sync the app folder to the guest
    config.vm.synced_folder "app", "/home/ubuntu/app"

    # run the app provisioning script
    config.vm.provision "shell", path: "environment/app/provision.sh"

  end

  config.vm.define "db" do |db|
    
    config.vm.network "private_network", ip: "192.168.10.101"
    config.hostsupdater.aliases = ["database.local"]

    # run the app provisioning script
    config.vm.provision "shell", path: "environment/db/provision.sh"

  end

end
