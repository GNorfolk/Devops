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

  config.vm.define "app" do |app|
    
    app.vm.network "private_network", ip: "192.168.10.100"
    app.hostsupdater.aliases = ["development.local"]

    # sync the app folder to the guest
    app.vm.synced_folder "app", "/home/ubuntu/app"

    # run the app provisioning script
    app.vm.provision "shell", inline: "echo 'export DB_HOST=mongodb://192.168.10.101/blog' >> /home/ubuntu/.bashrc"
    app.vm.provision "shell", path: "environment/app/provision.sh"

  end

  config.vm.define "db" do |db|
    
    db.vm.network "private_network", ip: "192.168.10.101"
    db.hostsupdater.aliases = ["database.local"]

    # run the app provisioning script
    db.vm.provision "shell", path: "environment/db/provision.sh"

  end

end
