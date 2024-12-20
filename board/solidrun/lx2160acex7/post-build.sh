#!/bin/sh

BOARD_DIR="$(dirname "$0")"
PARTUUID="$("$HOST_DIR/bin/uuidgen")"

install -d "$TARGET_DIR/boot/extlinux/"
# Default DPL and DPC selections for mcinitcmd
ln -sf clearfog-cx-s1_8-s2_0-dpc.dtb "$TARGET_DIR/boot/dpc.dtb"
ln -sf clearfog-cx-s1_8-s2_0-dpl.dtb "$TARGET_DIR/boot/dpl.dtb"
sed "s/%PARTUUID%/$PARTUUID/g" "$BOARD_DIR/extlinux.conf" > "$TARGET_DIR/boot/extlinux/extlinux.conf"
sed "s/%PARTUUID%/$PARTUUID/g" "$BOARD_DIR/genimage.cfg" > "$BINARIES_DIR/genimage.cfg"
install -d -m 0700 "$TARGET_DIR/root/.ssh/"
install -m 0600 ~/.ssh/id_rsa.pub "$TARGET_DIR/root/.ssh/authorized_keys"
