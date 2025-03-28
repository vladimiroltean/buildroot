#!/bin/sh

BOARD_DIR="$(dirname "$0")"
PARTUUID="$("$HOST_DIR/bin/uuidgen")"

install -d "$TARGET_DIR/boot/extlinux/"
# Default DPL and DPC selections for mcinitcmd
ln -sf dpc-usxgmii.dtb "$TARGET_DIR/boot/dpc.dtb"
ln -sf dpl-eth.19.dtb "$TARGET_DIR/boot/dpl.dtb"
sed "s/%PARTUUID%/$PARTUUID/g" "$BOARD_DIR/extlinux.conf" > "$TARGET_DIR/boot/extlinux/extlinux.conf"
sed "s/%PARTUUID%/$PARTUUID/g" "$BOARD_DIR/genimage.cfg" > "$BINARIES_DIR/genimage.cfg"
