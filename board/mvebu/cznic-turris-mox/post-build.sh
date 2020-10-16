#!/bin/sh
cp $BINARIES_DIR/boot.scr $TARGET_DIR/boot/boot.scr
ln -sf boot/boot.scr $TARGET_DIR/boot.scr
