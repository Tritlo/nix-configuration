# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
#
# Update to this config by running `sudo nixos-rebuild switch`

{ config, pkgs, ... }:


let
  unstableTarball = fetchTarball https://github.com/NixOS/nixpkgs-channels/archive/nixos-unstable.tar.gz;
  ghcide          = import (fetchTarball "https://github.com/hercules-ci/ghcide-nix/tarball/master") {};
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      # Cachix for faster builds
      ./cachix.nix
      # Authentication related stuff, not for the public
      ./private.nix
    ];


  nixpkgs.config = {
    allowUnfree = true;
    packageOverrides = pkgs: {
      unstable = import unstableTarball {
        config = config.nixpkgs.config;
      };
    };
  };

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  # boot.loader.grub.efiSupport = true;
  # boot.loader.grub.efiInstallAsRemovable = true;
  # boot.loader.efi.efiSysMountPoint = "/boot/efi";
  # Define on which hard drive you want to install Grub.
  boot.loader.grub.device = "/dev/sda"; # or "nodev" for efi only

  networking.hostName = "jung"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.ens33.useDHCP = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n = {
    consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "us";
    defaultLocale = "en_US.UTF-8";
  };

  # Set your time zone.
  time.timeZone = "Europe/Stockholm";

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    wget vim git dmenu rxvt_unicode
    xmobar stow
    unstable.emacs26

    #terminus_font
    #terminus_font_ttf

     # Web dev
    unstable.yarn
    python3

    unstable.cachix

    # Haskell
    ghc cabal-install binutils

    ghcide.ghcide-ghc865
    ghcide.hie-bios
    hlint

    # General dev
    entr
    coreutils clang ripgrep fd
    jq

    htop

   ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs.gnupg.agent = { enable = true; enableSSHSupport = true; };

  # programs.git = {
  #   enable = true;
  #   userName = "Matthias Pall Gissurarson";
  #   userEmail = "mpg@mpg.is";
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  services.postgresql = {
    enable = true;
    package = pkgs.unstable.postgresql_12;
    ensureUsers = [{ name = "tritlo";
                     ensurePermissions = {
                       "ALL TABLES IN SCHEMA public" = "ALL PRIVILEGES";
                     };
                   }];
    ensureDatabases = [ "tritlo" ];
  };

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 8000 80 22 ];
  networking.firewall.allowedUDPPorts = [ 8000 80 22 ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # sound.enable = true;
  # hardware.pulseaudio.enable = true;

  # Enable the X11 windowing system.
  # services.xserver.layout = "us";
  # services.xserver.xkbOptions = "eurosign:e";

  # Enable touchpad support.
  # services.xserver.libinput.enable = true;

  virtualisation.vmware.guest.enable = true;

  # Enable the KDE Desktop Environment.
  services.xserver = {
    enable = true;
    displayManager.auto.enable = true;
    displayManager.auto.user = "tritlo";
    displayManager.sessionCommands = ''
	xsetroot -solid "#141c21" &disown
    '';
    desktopManager = {
      default = "none";
      xterm.enable = false;
    };
    windowManager.default = "xmonad";
    windowManager.xmonad = {
     enable = true;
     enableContribAndExtras = true;
     extraPackages = haskellPackages: [
      haskellPackages.xmonad-contrib
      haskellPackages.xmonad-extras
      haskellPackages.xmonad
    ];
   };
  };

   fonts = {
    enableDefaultFonts = true;
    fonts = [
      pkgs.terminus_font
      pkgs.terminus_font_ttf
      pkgs.unstable.fira-code
    ];
   };

  
  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "19.09"; # Did you read the comment?

}

