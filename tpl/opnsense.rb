Vagrant.configure(2) do |config|
  config.vm.boot_timeout = 1800
  config.ssh.shell = "/bin/sh"
  config.vm.synced_folder ".", "/vagrant", disabled: true
  # config.vm.box_check_update = true
  config.vm.boot_timeout = 1800
  config.vm.provider :libvirt do |v, override|
    v.cpus = 2
    v.memory = 2048
    v.driver = "kvm"
    v.video_vram = 256
    v.disk_bus = "virtio"
  end
end