{ config, pkgs, lib, ... }:

{
  system.stateVersion = "25.05";

  imports = [
    ./hardware-configuration.nix
  ];

  boot = {
    loader = {
      grub = {
        enable = true;
        device = "/dev/sda";
        configurationLimit = 10;
        extraConfig = ''
          serial --speed=19200 --unit=0 --word=8 --parity=no --stop=1
          terminal_input serial
          terminal_output serial
        '';
      };
      timeout = 10;
    };
    kernelParams = [
      "console=ttyS0,19200n8"
      "console=tty0"
      "earlyprintk=serial,ttyS0,19200"
      "boot.shell_on_fail"
    ];
    initrd.availableKernelModules = [ "virtio_pci" "virtio_scsi" "ahci" "sd_mod" "dm_crypt" ];
    initrd.kernelModules = [ "dm-snapshot" "dm-crypt" ];
  };

  networking = {
    hostName = "baxter";
    domain = "pixelkeepers.net";
    
    useNetworkd = true;
    useDHCP = false;
    
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 ];
    };
  };

  systemd.network = {
    enable = true;
    networks."10-dhcp" = {
      matchConfig.Name = "en*";
      networkConfig = {
        DHCP = "ipv4";
        IPv6AcceptRA = true;
        IPv6PrivacyExtensions = "kernel";
      };
    };
  };

  services.resolved = {
    enable = true;
    dnssec = "true";
    domains = [ "~." ];
    fallbackDns = [ "1.1.1.1#cloudflare-dns.com" "8.8.8.8#dns.google" ];
    extraConfig = ''
      DNS=1.1.1.1#cloudflare-dns.com 8.8.8.8#dns.google
      DNSOverTLS=yes
    '';
  };

  time.timeZone = "Europe/Warsaw";

  i18n.defaultLocale = "en_US.UTF-8";

  users.users.h4wkeye = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    hashedPasswordFile = config.sops.secrets."h4wkeye-password-hash".path;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMGeqoInM+/Ia0qeAiFOLywjCo6bH5nJGYYMIPShxKT9"
    ];
  };

  users.users.root = {
    hashedPasswordFile = config.sops.secrets."root-password-hash".path;
  };

  services.openssh = {
    enable = true;
    ports = [ 22 ];
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
      PubkeyAuthentication = true;
    };
  };

  environment.systemPackages = with pkgs; [
    vim
    git
    curl
    wget
    htop
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  sops = {
    defaultSopsFile = ./secrets.yaml;
    defaultSopsFormat = "yaml";
    age = {
      keyFile = "/var/lib/sops-nix/key.txt";
      generateKey = true;
    };
    secrets = {
      "h4wkeye-password-hash" = {
        neededForUsers = true;
      };
      "root-password-hash" = {
        neededForUsers = true;
      };
      "luks-password" = {};
      "initrd-ssh-authorized-key" = {};
      "storage-box-user" = {};
      "storage-box-password" = {};
      "storage-box-host" = {};
    };
  };
}