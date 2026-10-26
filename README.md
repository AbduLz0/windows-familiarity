# Windows Familiarity for GNOME

A Windows-inspired GNOME desktop, with familiar apps to make switching to Linux easier.

This Bash script sets up a taskbar, Start menu, and GTK theme, then installs office software, Windows compatibility tools, and everyday utilities. Selected desktop settings are backed up for restoration.

## What's included

| Category | Components |
| --- | --- |
| Desktop | Dash to Panel, ArcMenu, Blur my Shell, User Themes |
| Appearance | Windows11 GTK theme, right-side window controls, GNOME Tweaks |
| Office | LibreOffice; optional OnlyOffice via a commented-out script line |
| Windows apps | Wine, Winetricks, Bottles |
| Everyday tools | VLC, Flameshot, CopyQ, KDE Connect, GIMP, Geany |
| Files and backups | p7zip, File Roller, Syncthing, Timeshift |
| App installation | Flatpak and Flathub |

Installation is best-effort across **Debian/Ubuntu, Fedora, and Arch-based systems**. Package availability and extension compatibility vary.

## Quick start

You need a **GNOME session**, internet access, `sudo` privileges, and these tools available: `bash`, `git`, `dconf`, `gsettings`, and `gnome-extensions`.

Download or clone this repository, review the script, then run from its folder:

```bash
chmod +x windows-familiarity.sh
./windows-familiarity.sh
```

Run as your normal desktop user; the script requests `sudo` for system packages. **Log out and back in** when setup finishes.

> **Keep your original backup:** Settings are saved to `~/.config/windows-familiarity-backup/`. Every setup run overwrites this folder, so copy it elsewhere before running again.

## Restore desktop settings

```bash
./windows-familiarity.sh --restore
```

Log out and back in afterward. Restore reloads selected GNOME and extension settings and disables all four targeted extensions, including ones previously enabled.

Applications, themes, extensions, and Flathub remain installed. Some newly added settings may remain too; this is a partial settings restore, not a full system rollback.

## Finishing touches

- **Desktop:** Use GNOME Tweaks and extension preferences to adjust the theme, taskbar, and menu.
- **Windows software:** Open Bottles to configure an environment for each application. Compatibility varies.
- **Backups and sync:** Configure Timeshift snapshots and Syncthing separately after installation.

## Troubleshooting

| Issue | What to check |
| --- | --- |
| Missing extensions | Log in again, then check Extensions. Automatic installation may fail; install compatible versions manually from your distribution or [GNOME Extensions](https://extensions.gnome.org/). |
| Taskbar or menu looks wrong | Configure the extension preferences manually; supported settings vary by version. |
| Theme or icons missing | Select an installed theme in GNOME Tweaks. The script requests `Win11` icons but does not install an icon pack or select a Shell theme. |
| An application did not install | Review the terminal output and check your distribution's package names and repositories. |
| A Windows app will not run | Check [WineHQ AppDB](https://appdb.winehq.org/) or [Bottles documentation](https://docs.usebottles.com/). |

Some setup and restore errors are suppressed. Check the actual results even if the script reports completion.

## Contributing

Improvements to distribution support, extension compatibility, and backup handling are welcome. Include the distribution and GNOME version you tested, and update this README when behavior changes.

## Credits

Built on the work of the GNOME community, Dash to Panel, ArcMenu, Blur my Shell, User Themes, [Windows11 GTK theme](https://github.com/yeyushengfan258/Windows11-gtk-theme), Bottles, and the included application projects.
