#!/bin/bash

# NTFS Hibernation Fix Script
# Fixes "remove_hiberfile is not allowed" and dirty bit errors on Linux

set -e

echo "=== NTFS Permanent Fix Script ==="
echo ""

# 1. Install ntfs-3g if not present
echo "[1/5] Checking ntfs-3g..."
if ! command -v ntfsfix &> /dev/null; then
    sudo apt-get update && sudo apt-get install -y ntfs-3g
    echo "ntfs-3g installed."
else
    echo "ntfs-3g already installed."
fi

# 2. Fix udisks2 mount options
echo ""
echo "[2/5] Configuring udisks2 mount options..."
sudo mkdir -p /etc/udisks2

sudo tee /etc/udisks2/mount_options.conf > /dev/null << 'EOF'
[defaults]
ntfs_defaults=uid=$UID,gid=$GID,windows_names
ntfs_allow=uid,gid,windows_names,nosuid,nodev,noexec,remove_hiberfile
EOF

echo "udisks2 config written."

# 3. Create udev rule to auto-fix dirty bit on plug-in
echo ""
echo "[3/5] Creating udev rule for auto ntfsfix..."
sudo tee /etc/udev/rules.d/99-ntfs-autofix.rules > /dev/null << 'EOF'
ACTION=="add", SUBSYSTEM=="block", ENV{ID_FS_TYPE}=="ntfs", RUN+="/usr/bin/ntfsfix -d %E{DEVNAME}"
ACTION=="add", SUBSYSTEM=="block", ENV{ID_FS_TYPE}=="ntfs3", RUN+="/usr/bin/ntfsfix -d %E{DEVNAME}"
EOF

echo "udev rule created."

# 4. Reload udev + restart udisks2
echo ""
echo "[4/5] Reloading udev rules and restarting udisks2..."
sudo udevadm control --reload-rules
sudo udevadm trigger
sudo systemctl restart udisks2
echo "Done."

# 5. Fix currently connected NTFS drives right now
echo ""
echo "[5/5] Fixing any currently connected NTFS drives..."
for dev in /dev/sd* /dev/nvme* /dev/mmcblk*; do
    [ -b "$dev" ] || continue
    fstype=$(blkid -o value -s TYPE "$dev" 2>/dev/null || true)
    if [[ "$fstype" == "ntfs" ]]; then
        echo "  Running ntfsfix on $dev ..."
        sudo ntfsfix -d "$dev" && echo "  Fixed: $dev" || echo "  Skipped: $dev"
    fi
done

echo ""
echo "=== All done! ==="
echo "Unplug and replug your NTFS drive — it should now mount cleanly."
echo ""
echo "NOTE: For a truly permanent fix, disable Windows Fast Startup:"
echo "  1. Boot into Windows"
echo "  2. Open Admin CMD and run: powercfg /h off"
echo "  3. Shut down Windows normally (not restart)"
