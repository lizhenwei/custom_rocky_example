#!/bin/bash
set -e

ISO_NAME="Rocky-9.6-x86_64-dvd.iso"
ISO_LABEL="Rocky-9-6-x86_64"
CUSTOM_DIR="$PWD/iso_base"
OUTPUT_ISO="rocky-9.6-custom.iso"

# Step 1: 准备基础 ISO
if [ ! -f "$ISO_NAME" ]; then
    echo "请先下载 Rocky Linux 9.6 官方 ISO 放在当前目录，并命名为 $ISO_NAME"
    exit 1
fi

# Step 2: 解包原始 ISO
mkdir -p /mnt/rocky
sudo mount -o loop "$ISO_NAME" /mnt/rocky

rm -rf "$CUSTOM_DIR"
mkdir -p "$CUSTOM_DIR"
cp -rT /mnt/rocky "$CUSTOM_DIR"
sudo umount /mnt/rocky

# Step 3: 拷贝 kickstart 和 docker rpm 目录
cp ks.cfg "$CUSTOM_DIR/ks.cfg"
if [ -d docker_rpms ]; then
    cp -r docker_rpms "$CUSTOM_DIR/docker_rpms"
else
    echo "警告：docker_rpms 目录不存在，离线 docker 需要先准备 rpm 并运行 createrepo_c docker_rpms"
fi

# Step 4: 添加自动安装菜单项
ISOLINUX_CFG="$CUSTOM_DIR/isolinux/isolinux.cfg"
if ! grep -q "label autoinstall" "$ISOLINUX_CFG"; then
cat >> "$ISOLINUX_CFG" <<EOF

label autoinstall
  menu label ^Auto Install Rocky with Docker (Offline + SSH + sfere)
  kernel vmlinuz
  append initrd=initrd.img inst.stage2=hd:LABEL=$ISO_LABEL inst.ks=cdrom:/ks.cfg
EOF
fi

# Step 5: 构建 ISO
xorriso -as mkisofs \
  -iso-level 3 \
  -R -J -joliet-long \
  -V "$ISO_LABEL" \
  -volset "Rocky Linux 9.6 Custom" \
  -o "$OUTPUT_ISO" \
  -b isolinux/isolinux.bin \
  -c isolinux/boot.cat \
  -no-emul-boot \
  -boot-load-size 4 \
  -boot-info-table \
  -eltorito-alt-boot \
  -e images/efiboot.img \
  -no-emul-boot \
  -isohybrid-gpt-basdat \
  "$CUSTOM_DIR"

echo "✅ ISO 构建完成: $OUTPUT_ISO"
