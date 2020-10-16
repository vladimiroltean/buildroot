CZ.NIC Turris MOX

Intro
=====

These instructions apply to the CZ.NIC Turris MOX modular router.

How to build it
===============

Configure Buildroot
-------------------

  $ make cznic_turris_mox_defconfig

Build the rootfs
----------------

Note: you will need to have access to the network, since Buildroot will
download the packages' sources.

You may now build your rootfs with:

  $ make

(This may take a while, consider getting yourself a coffee ;-) )

Result of the build
-------------------

After building, you should obtain this tree:

    output/images/
    +-- armada-3720-turris-mox.dtb
    +-- boot.scr
    +-- Image
    +-- rootfs.ext2
    +-- rootfs.ext4 -> rootfs.ext2
    +-- rootfs.tar
    +-- sdcard.img

How to write the SD card
========================

Once the build process is finished you will have an image called "sdcard.img"
in the output/images/ directory.

Copy the bootable "sdcard.img" onto an SD card with "dd":

  $ sudo dd if=output/images/sdcard.img of=/dev/sdX

Insert the SDcard into your MOX, and power it up. Your new system should come
up now and start one console, on the UART pins from the GPIO header:
https://docs.turris.cz/hw/serial/#turris-mox
