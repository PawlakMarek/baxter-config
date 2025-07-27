{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_101118637";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              type = "EF00";
              size = "512M";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };
            luks = {
              type = "8300";
              size = "100%";
              label = "CRYPTROOT";
              content = {
                type = "luks";
                name = "cryptroot";
                settings = {
                  crypttabExtraOpts = [ "luks" ];
                };
                extraFormatArgs = [
                  "--type luks2"
                  "--cipher aes-xts-plain64"
                  "--hash sha512"
                  "--pbkdf argon2id"
                ];
                content = {
                  type = "lvm_pv";
                  vg = "vg0";
                };
              };
            };
          };
        };
      };
    };
    lvm_vg = {
      vg0 = {
        type = "lvm_vg";
        lvs = {
          swap = {
            size = "2G";
            content = {
              type = "swap";
            };
          };
          emergency = {
            size = "2G";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/emergency";
            };
          };
          root = {
            size = "100%FREE";
            content = {
              type = "filesystem";
              format = "xfs";
              mountpoint = "/";
              mountOptions = [
                "noatime"
                "nodiratime"
                "largeio"
                "inode64"
                "allocsize=16m"
                "logbsize=256k"
              ];
            };
          };
        };
      };
    };
  };
}