# KDE reference files

Unlinked references (no links.map entry): `kwinrc` (KWin tiling/scale) and `plasma-org.kde.plasma.desktop-appletsrc` (panel/applets).
KDE rewrites these files at runtime, so symlinking them is fragile. Copy or diff by hand when setting up a machine.
