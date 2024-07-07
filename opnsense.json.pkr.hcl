
packer {
  required_plugins {
    qemu = {
      source  = "github.com/hashicorp/qemu"
      version = "~> 1"
    }
    vagrant = {
      source  = "github.com/hashicorp/vagrant"
      version = "~> 1"
    }
  }
}

variable "config_file" {
  type    = string
  default = "config.xml"
}

variable "disk_size" {
  type    = string
  default = "8192"
}

variable "headless" {
  type    = string
  default = "false"
}

variable "iso_sha256_checksum" {
  type    = string
  default = "95962ad9c64ec9bd19d3b91caac0ab1e458d93f2003185a5ae56903a00a6669b"
}


source "qemu" "opnsense" {
  vm_name     = "opnsense"
  qemu_binary = "qemu-system-x86_64"
  boot_wait        = "3s"
  disk_size        = "${var.disk_size}"
  cpus             = 4
  memory = 2048
  // net_bridge = "virbr0"
  headless         = "${var.headless}"
  http_directory   = "http"
  iso_checksum     = "${var.iso_sha256_checksum}"
  iso_url          = "/mnt/data/OPNsense-23.1-OpenSSL-dvd-amd64.iso"
  // vnc_bind_address = "0.0.0.0"
  vnc_port_min     = "5924"
  vnc_port_max     = "5924"
  shutdown_command = "shutdown -p now"
  ssh_password     = "opnsense"
  ssh_username     = "root"
  ssh_wait_timeout = "10000s"
  boot_command = [
    "<wait60>",
    "installer<enter>",
    "opnsense<enter><wait5>",
    "<enter><wait2>", "<enter><wait2>", "<enter><wait2>", "<left><wait2>", "<enter>",
    "<wait60>",
    "<down>", "<enter>",
    "<wait60>",
    "root<enter>", "opnsense<enter>", "<wait>8<enter>",
    "<wait>dhclient vtnet0<enter><wait10>",
    "curl http://{{ .HTTPIP }}:{{ .HTTPPort }}/config-vagrant.xml | sed '/^$/d' > /conf/config.xml<wait><enter>",
    // "echo 'PasswordAuthentication yes' >> /usr/local/etc/ssh/sshd_config<enter>",
    // "mkdir -p /root/.ssh<enter><wait>",
    // "curl http://{{ .HTTPIP }}:{{ .HTTPPort }}/id_rsa.pub > /root/.ssh/authorized_keys<wait><enter>",
    "service openssh enable<enter>",
    "service openssh restart<enter>",
  ]
  // guest_additions_mode = "disable"
  // guest_os_type        = "FreeBSD_64"
  // keep_registered      = false
  // output_directory     = "output"
  // post_shutdown_delay  = "30s"
  // skip_export          = false
  // vboxmanage           = [["modifyvm", "{{ .Name }}", "--memory", "1024"], ["modifyvm", "{{ .Name }}", "--cpus", "1"], ["modifyvm", "{{ .Name }}", "--boot1", "disk"], ["modifyvm", "{{ .Name }}", "--boot2", "dvd"], ["modifyvm", "{{ .Name }}", "--audio", "none"], ["modifyvm", "{{ .Name }}", "--usb", "off"]]
  // vboxmanage_post      = [["modifyvm", "{{ .Name }}", "--nic1", "intnet"], ["modifyvm", "{{ .Name }}", "--nic2", "nat"], ["modifyvm", "{{ .Name }}", "--cableconnected2", "on"], ["modifyvm", "{{ .Name }}", "--natpf2", "managinggui,tcp,127.0.0.1,10443,,443"], ["modifyvm", "{{ .Name }}", "--natpf2", "ssh,tcp,127.0.0.1,10022,,22"]]
}

build {
  sources = ["source.qemu.opnsense"]
  provisioner "shell" {
    execute_command = "chmod +x {{ .Path }}; /bin/sh -c '{{ .Vars }} {{ .Path }}'"
    // execute_command = "chmod +x {{ .Path }}; env {{ .Vars }} {{ .Path }}"
    scripts         = [
      "scripts/vagrant.sh",
      "scripts/base.sh"
    ]
    
    timeout = "120m"
    pause_before = "10s"
    start_retry_timeout = "15m"
    expect_disconnect = "true"
  }
  post-processors {
   post-processor "vagrant" {
      compression_level   = 9
      keep_input_artifact = false
      output              = "output/opnsense.box"
      provider_override   = "libvirt"
      vagrantfile_template = "tpl/opnsense.rb"
    }
  }
}
