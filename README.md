# ntfs-autofix

> Permanently fix NTFS mount errors on Linux caused by Windows Fast Startup / hibernation.

## The Problem

When Windows shuts down with Fast Startup enabled, it leaves NTFS drives in a
"hibernated" state. Linux then refuses to mount them, throwing errors like:

- `Mount option 'remove_hiberfile' is not allowed`
- `The disk contains an unclean file system`
- `Falling back to read-only mount`

## What This Script Does

| Step | Action |
|------|--------|
| 1 | Installs `ntfs-3g` if missing |
| 2 | Configures udisks2 to allow NTFS hibernation bypass |
| 3 | Creates a udev rule to auto-run `ntfsfix` on every drive plug-in |
| 4 | Reloads udev and restarts udisks2 |
| 5 | Immediately fixes all currently connected NTFS drives |

After running, any NTFS drive you plug in will mount automatically — no manual
intervention needed.

## Usage

```bash
curl -fsSL YOUR_RAW_URL_HERE | bash
```

Or manually:

```bash
wget YOUR_RAW_URL_HERE -O ntfs-autofix.sh
chmod +x ntfs-autofix.sh
./ntfs-autofix.sh
```

## Requirements

- Ubuntu, Debian, Linux Mint, Pop!_OS, or any Debian-based distro
- `sudo` access

## Permanent Windows-Side Fix (Recommended)

This script fixes the Linux side. For a complete fix, also disable
Windows Fast Startup:

1. Boot into Windows
2. Open Command Prompt as Administrator
3. Run:
