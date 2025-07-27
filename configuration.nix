{ config, pkgs, lib, ... }:

{
  system.stateVersion = "25.05";

  imports = [
    ./hardware-configuration.nix
  ];

  boot = {
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 10;
        consoleMode = "0";
      };
      efi = {
        canTouchEfiVariables = true;
      };
      timeout = 10;
    };
    kernelParams = [
      "console=ttyS0,19200n8"
    ];
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
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMGeqoInM+/Ia0qeAiFOLywjCo6bH5nJGYYMIPShxKT9"
    ];
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
}