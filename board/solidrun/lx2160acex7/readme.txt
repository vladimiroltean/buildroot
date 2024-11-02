*********************
SolidRun LX2160A-CEx7
*********************

This file documents the Buildroot support for the NXP Layerscape CEx7 LX2160A
board made by SolidRun. The CEx7 (COM Express type 7) is a Computer On Module
which can be plugged into different carrier boards. It is sold either
separately, or with the HoneyComb LX2 or Clearfog CX LX2 carrier boards, both
having Mini ITX form factors.

Both the HoneyComb LX2 and Clearfog CX LX2 carrier boards are targeted towards
networking use cases, with 4 10G-capable SFP+ cages, and the Clearfog
additionally having a 4x25G-capable QSFP28 cage. In addition, the carrier
boards have 4x SATA III interfaces, PCIe Gen 3 x8, 2x USB 3.0, an m.2 slot
compatible with NVMe SSDs, pin headers for traditional PC/NAS cases, and
regular RJ45 1G Ethernet.

The developer resources for the platform can be found at:
  - https://solidrun.atlassian.net/wiki/spaces/developer/pages/197493977/NXP+LX2160A+Based+Products

SolidRun keeps build scripts for the firmware on GitHub, which track NXP Linux
Factory (LF) releases in the form of patches:
  - https://github.com/SolidRun/lx2160a_build

The most recent functional branch is develop-ls-5.15.71-2.2.0. These patches
are also included into Buildroot, except for the Linux kernel, where the most
recent lf-6.12.3-1.0.0 NXP tag is used directly.

The Buildroot support is for the maximal configuration, which is the CEX7
platform on the Clearfog CX LX2 carrier board.

Build
=====

First, configure Buildroot for the LX2160A-CEX7 platform:

  make solidrun_lx2160acex7_defconfig

Build all components:

  make

You will find in output/images/ the following files:
  - bl2_sd.pbl - RCW + ATF BL2 stage
  - dpc.dtb
  - dpl.dtb
  - fip.bin - U-Boot packaged as ATF payload
  - fip_ddr.bin - DDR PHY firmware
  - fsl-lx2160a-clearfog-cx.dtb
  - fsl-lx2160a-honeycomb.dtb
  - Image
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

*** WARNING! This will destroy all the card content. Use with care! ***

For details about the medium image layout, see the definition in
board/solidrun/lx2160acex7/genimage.cfg.

Boot the LX2160A-CEX7 board
===========================

To boot your newly created system:
- configure the DIP switches for SD boot selection as per SolidRun instructions:
  https://solidrun.atlassian.net/wiki/spaces/developer/pages/197494288/HoneyComb+LX2+ClearFog+CX+LX2+Quick+Start+Guide#Boot-Select
- insert the Micro-SD card in the Micro-SD slot of the board
- put a Micro-USB cable into the Micro-USB connector labeled CONSOLE (CON9)
  and connect using a terminal emulator at 115200 bps, 8n1.
- power on the board.

The DPL file only contains a static description for the 1G RGMII RJ45 port
(endpmac17). By default, this will attempt acquire an IP address over DHCP.

The 4 interfaces routed to the SFP+ cages are endpmac7, endpmac8, endpmac9 and
endpmac10. Among the more usual networking choices, one could create individual
DPNIs for each MAC:

$ ls-addni dpmac.7 && ls-addni dpmac.8 && ls-addni dpmac.9 && ls-addni dpmac.10

or a DPSW object to accelerate L2 forwarding between them:

$ ls-addsw --num-ifs=4 --max-fdbs=4 --flooding-cfg=DPSW_FLOODING_PER_FDB \
	--broadcast-cfg=DPSW_BROADCAST_PER_FDB dpmac.7 dpmac.8 dpmac.9 dpmac.10
$ ip link add br0 type bridge vlan_filtering 1 && ip link set br0 up
$ for eth in endpmac7 endpmac8 endpmac9 endpmac10; do \
	ip link set $eth master br0 && ip link set $eth up; done

Once the runtime configuration is satisfactory, it can be converted back into a
permanent DPL file which can be plugged back into the build system:

$ restool dprc generate-dpl > dpl-new.dts

Networking options through the QSFP28 cage have not yet been investigated.
