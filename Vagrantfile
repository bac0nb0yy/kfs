Vagrant.configure("2") do |config|
  config.vm.box = "debian/bookworm64"
  config.vm.synced_folder ".", "/vagrant"
  config.vm.provision "shell", inline: <<-SHELL
	export DEBIAN_FRONTEND=noninteractive
    apt-get update
    apt-get install -y --no-install-recommends grub-pc-bin grub-common xorriso
  SHELL
end
