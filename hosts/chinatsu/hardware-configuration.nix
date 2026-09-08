# Hardware configuration placeholder
{ lib, ... }:
{
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  boot.initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "usbhid" "sd_mod" ];
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
