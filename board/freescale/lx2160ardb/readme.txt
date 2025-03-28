**************
NXP LX2160ARDB
**************

This file documents the Buildroot support for the LX2160A Reference Design Board.

For more details about the board and the QorIQ Layerscape SoC, see the
following pages (notably the "LX2160A Reference Design Board Getting Started
Guide", for which this guide serves as an addition, not a replacement):
  - https://www.nxp.com/design/design-center/software/qoriq-developer-resources/layerscape-lx2160a-reference-design-board:LX2160A-RDB
  - https://www.nxp.com/LX2160A

Layerscape platforms are officially supported by NXP under the Layerscape
Debian Linux SDK (LDLSDK). This uses components from Linux Factory (project
common with i.MX), currently tag lf-6.6.36-2.1.0, two releases behind the
latest lf-6.12.3-1.0.0.  In Buildroot, the latest Linux Factory release tag
is used, which may be considered pre-release software, as it may contain
features which are not yet documented, and it generally undergoes less testing.

For the software Layerscape Debian Linux SDK User Guide, see:
  - https://docs.nxp.com/bundle/UG10143/page/topics/about_this_document.html
  - https://www.nxp.com/docs/en/user-guide/UG10143.pdf

The components from NXP are:
  - rcw, lf-6.12.3-1.0.0
  - atf (fork), lf-6.12.3-1.0.0
  - uboot (fork), lf-6.12.3-1.0.0
  - cadence-dp-firmware (blob), lf-6.12.3-1.0.0
  - linux (fork), lf-6.12.3-1.0.0

Build
=====

First, configure Buildroot for the LX2160ARDB board:

  make lx2160rdb_defconfig

Build all components:

  make

You will find in output/images/ the following files:
  - bl2_sd.pbl - RCW + ATF BL2 stage
  - dpc-usxgmii.dtb - the default DPC file
  - dpc-warn.dtb
  - dpl-2dpni.dtb
  - dpl-eth.19.dtb - the default DPL file
  - fip_ddr.bin - DDR PHY firmware
  - fip.bin - U-Boot packaged as ATF payload
  - fsl-lx2160a-rdb.dtb
  - Image
  - in112525-phy-ucode.txt - Firmware file for 25GbE SFP+ retimer
  - mc.itb - MC firmware
  - PBL.bin
  - rootfs.ext2
  - rootfs.ext4
  - sdcard.img
  - u-boot.bin
  - uboot-env.bin

Create a bootable SD card
=========================

To determine the device associated to the SD card have a look in the
/proc/partitions file:

  cat /proc/partitions

Buildroot prepares a bootable "sdcard.img" image in the output/images/
directory, ready to be dumped on a SD card. Launch the following
command as root:

  dd if=output/images/sdcard.img of=/dev/sdX

The SD card image can also be programmed from a live system running U-Boot:

  => setenv autoload off && tftp $load_addr sdcard.img && mmc dev 0 && mmc write $load_addr 0 0x80000

*** WARNING! This will destroy all the card content. Use with care! ***

For details about the medium image layout, see the definition in
board/freescale/lx2160ardb/genimage.cfg.

Boot the LX2160ARDB board
=========================

To boot your newly created system:
- insert the SD card in the SD slot of the board;
- Configure the switches SW1[1:4] = 0b1000 (select SD Card boot option),
  or alternatively, run "qixis_reset sd" from a U-Boot booted from a different
  boot source (NOR, eMMC etc).
- put a DB9F cable into the UART1 Port and connect using a terminal
  emulator at 115200 bps, 8n1;
- power on the board.

The DPL and DPC files provided by NXP are not maximal configurations.
They only contain a static description for:
- the 40GbE QSFP+ MAC2 (which implicitly has MAC_LINK_TYPE_FIXED, because its
  entry is missing from the DPC, and this means that the link state is provided
  by the MC firmware)
- the 1GbE RGMII MAC17 (specified as MAC_LINK_TYPE_PHY in the DPC, which means
  that the link state is provided by phylink).

The extra interfaces routed to front panel ports are endpmac3, endpmac4,
endpmac5, endpmac6 and endpmac18. Among the more usual networking choices, one
could create individual DPNIs for each MAC:

$ ls-addni dpmac.3 && ls-addni dpmac.4 && ls-addni dpmac.5 && ls-addni dpmac.6 && ls-addni dpmac.18

or a DPSW object to accelerate L2 forwarding between them:

$ ls-addsw --num-ifs=4 --max-fdbs=4 --flooding-cfg=DPSW_FLOODING_PER_FDB \
       --broadcast-cfg=DPSW_BROADCAST_PER_FDB dpmac.3 dpmac.4 dpmac.5 dpmac.6
$ ip link add br0 type bridge vlan_filtering 1 && ip link set br0 up
$ for eth in endpmac3 endpmac4 endpmac5 endpmac6; do \
       ip link set $eth master br0 && ip link set $eth up; done

Once the runtime configuration is satisfactory, it can be converted back into a
permanent DPL file which can be plugged back into the build system:

$ restool dprc generate-dpl > dpl-new.dts

Using the device tree compiler (dtc), the new DPL can be transformed into a
.dtb file and deployed as a custom networking configuration upon the next boot.
