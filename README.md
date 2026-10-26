# 🪟 Windows Familiarity for GNOME

A Bash script that helps a GNOME desktop feel more familiar to Windows users and installs office, compatibility, and everyday utility applications.

The goal is to reduce the initial friction of switching to Linux. The script attempts to configure a Windows-style taskbar and Start menu, apply a Windows 11 GTK theme, and install useful applications. It also backs up selected GNOME settings and provides a restore command.

> **Current limitations:** Setup is best-effort. Package names, extension availability, and settings can differ between distributions and GNOME versions. Many failures are ignored so setup can continue; the final “Setup complete!” message does not guarantee that every component installed successfully.

## ✨ Features

- **Windows-style taskbar:** Attempts to configure Dash to Panel as a full-width bottom panel.
- **Start menu:** Installs and configures ArcMenu where available.
- **Desktop appearance:** Downloads the Windows11 GTK theme and moves window controls to the right.
- **Office applications:** Installs LibreOffice for documents, spreadsheets, and presentations.
- **Windows compatibility:** Installs Wine, Winetricks, and Bottles.
- **Everyday tools:** Includes VLC, Flameshot, CopyQ, KDE Connect, GIMP, Timeshift, Syncthing, and more.
- **Settings restore:** Reloads selected backed-up GNOME settings and disables the four targeted extensions.
- **Multiple package managers:** Includes installation paths for Debian/Ubuntu (`apt`), Fedora (`dnf`), and Arch-based systems (`pacman`).

## 📋 What Gets Installed

These are the components the script attempts to install or enable. Availability depends on your system.

### Desktop customization

| Component | Purpose |
| --- | --- |
| Dash to Panel | Windows-style taskbar |
| ArcMenu | Start-menu replacement |
| Blur my Shell | Desktop visual effects |
| User Themes | Enables custom GNOME Shell themes |
| Windows11 GTK theme | Windows-inspired application appearance |
| GNOME Tweaks | Additional desktop customization |
| Extension preferences | GNOME extension configuration |
| Flatpak and Flathub | Application installation, including Bottles |

The script selects `Win11` as both the GTK and icon theme. It downloads the GTK theme, but **does not install a separate icon theme**. It enables User Themes but does not explicitly select a GNOME Shell theme. Extension installation and configuration may require manual completion.

### Office and Windows compatibility

| Application | Purpose |
| --- | --- |
| LibreOffice Writer, Calc, and Impress | Documents, spreadsheets, and presentations |
| Wine | Compatibility layer for running supported Windows applications |
| Winetricks | Helper for configuring Wine dependencies |
| Bottles (Flatpak) | Graphical manager for Windows application environments |

OnlyOffice is optional: the script contains a commented-out installation line for `org.onlyoffice.desktopeditors`.

### Familiar utilities

| Linux tool | Familiar use case |
| --- | --- |
| VLC | Media playback |
| Flameshot | Screenshots and annotation |
| CopyQ | Clipboard management |
| KDE Connect | Phone and desktop integration |
| GIMP | Image editing |
| p7zip and File Roller | Archive creation and extraction |
| Timeshift | System snapshots |
| Syncthing | File synchronization between devices |
| Geany | Text and code editing |

Installing an application does not configure it automatically. In particular, Timeshift snapshots and Syncthing synchronization need to be set up separately.

## 🖥️ Requirements

- A running **GNOME desktop session** under your normal user account.
- A distribution using `apt`, `dnf`, or `pacman`.
- A user account with `sudo` privileges for package installation.
- An internet connection for packages, Flatpak applications, and the theme.
- Bash, Git, and GNOME tools including `dconf`, `gsettings`, and `gnome-extensions`.

The script does not perform a full prerequisite or desktop-environment check. Ensure these tools are available before running it, especially `dconf`, which is needed for the initial settings backup.

KDE Plasma, Xfce, and Cinnamon are outside the intended scope: the desktop configuration specifically targets GNOME Shell. Compatibility with a particular distribution or GNOME release is not guaranteed.

## 🚀 Installation and Usage

### 1. Get the script

Download or clone this repository, then open a terminal in the directory containing `windows-familiarity.sh`.

### 2. Review and run it

Read the script before executing it. Then run:

```bash
chmod +x windows-familiarity.sh
./windows-familiarity.sh
```

Run it as your normal desktop user. The script invokes `sudo` when installing system packages; running the entire script with `sudo` would target the wrong user's settings and home directory.

Setup proceeds through the following steps:

1. Back up selected GNOME settings to `~/.config/windows-familiarity-backup/`.
2. Attempt to install GNOME configuration tools and Flatpak, and add Flathub.
3. Attempt to install the GNOME extensions.
4. Download and install the Windows11 GTK theme.
5. Apply appearance settings and enable the extensions.
6. Configure Dash to Panel and ArcMenu.
7. Install LibreOffice, Wine, Winetricks, Bottles, and the utility applications.

### 3. Log out and back in

Start a fresh GNOME session, then check the extensions and appearance settings. Review any warnings printed during installation.

> **Before running setup again:** Every normal run overwrites the files in `~/.config/windows-familiarity-backup/`. Copy that folder somewhere else first if you want to preserve your original desktop settings.

## 🔄 Restoring Desktop Settings

Run:

```bash
./windows-familiarity.sh --restore
```

Then log out and back in.

The restore command reloads the saved settings for:

- GNOME desktop interface appearance.
- Window-manager preferences.
- Dash to Panel.
- ArcMenu.
- User Themes.

It also disables Dash to Panel, ArcMenu, Blur my Shell, and User Themes, including any of those extensions that were enabled before setup.

### Restore limitations

This is a partial settings restore, not a full system rollback:

- Installed applications, extensions, downloaded themes, and the Flathub remote remain installed.
- The previous enabled/disabled state of each extension is not backed up.
- Loading saved `dconf` values does not necessarily clear values that setup added where no saved value existed.
- Backup and restore errors can be suppressed, so check the result rather than relying only on the completion message.

Remove unwanted applications separately using your distribution's package manager or Flatpak. For a complete rollback strategy, create an independent system backup or snapshot before setup.

## 🧭 After Installation

- Open **Bottles** to create an environment for a Windows application.
- Open **GNOME Tweaks** to adjust fonts and appearance.
- Open **Extensions** and the individual extension preferences to configure the taskbar and Start menu.
- Configure **Timeshift** if you want system snapshots.
- Configure **Syncthing** if you want synchronization between devices.
- If desired, enable the optional OnlyOffice installation line in the script or install it separately through Flatpak.

## 🛠️ Troubleshooting

### Extensions are missing or disabled

Log out and back in, then check the Extensions application. The script first tries distribution packages for Dash to Panel and ArcMenu. Its fallback passes extension identifiers to `gnome-extensions install`; this is not a reliable way to download extensions from the GNOME extension catalog.

If installation fails, install extensions compatible with your GNOME version through your distribution or [GNOME Extensions](https://extensions.gnome.org/), then enable and configure them manually.

### The taskbar or Start menu does not look right

The script uses fixed extension settings and an ArcMenu layout value of `11`. Available keys and accepted values depend on the installed extension version. Open each extension's preferences and select your preferred panel position, size, and menu layout manually.

### The theme or icons are not applying

Check which theme directories were created under `~/.themes/`, then select an installed theme in GNOME Tweaks. The script requests the GTK theme name `Win11`, which must match an installed theme.

Icons require a separately installed icon theme; the script only sets the name `Win11`. For a custom Shell theme, enable User Themes and select an installed Shell theme manually. Application support for desktop themes can vary.

### Wine or another package did not install

Package names and repository availability differ between distributions. Review the installation output and use your distribution's package manager to install the missing package. Bottles is installed separately through Flatpak and may still be available if the native Wine package failed to install.

### A Windows application will not run

Wine is a compatibility layer, not a complete Windows installation. Application support varies. Consult the [WineHQ AppDB](https://appdb.winehq.org/) and [Bottles documentation](https://docs.usebottles.com/) for application-specific information.

### Restore did not bring back the original appearance

Check that `~/.config/windows-familiarity-backup/` contains the expected backup files. If you ran setup more than once, the original backup may have been overwritten. Restore also disables the four targeted extensions, so you may need to re-enable extensions you used previously.

## ⚠️ Scope and Expectations

- Setup installs system packages through `sudo` and executes the downloaded GTK theme's installer.
- Office document formatting and features can differ between LibreOffice and Microsoft Office; check important files in the applications used by their recipients.
- Wine and Bottles cannot guarantee compatibility with every Windows application.
- The result is a Windows-inspired GNOME desktop. Some GNOME interface elements and application styling will remain.
- This script provides no full system backup and does not guarantee a complete reversal of every change.

## 🗂️ Repository Layout

```text
windows-familiarity/
├── windows-familiarity.sh   # Setup and settings-restore script
└── README.md               # Project documentation
```

## 🤝 Contributing

Contributions that improve distribution support, extension compatibility, defaults, or recovery are welcome.

When proposing changes:

- Aim for repeatable setup without losing the original backup.
- Preserve and improve the backup/restore workflow.
- Handle missing packages and incompatible extension settings clearly.
- Update this README when installed components or behavior change.
- Describe which distribution and GNOME version you tested.

## 📜 License

No `LICENSE` file is currently included. Add one to specify the project's license before distributing it under particular terms.

## 🙏 Acknowledgements

Thanks to the maintainers of Dash to Panel, ArcMenu, Blur my Shell, User Themes, the [Windows11 GTK theme](https://github.com/yeyushengfan258/Windows11-gtk-theme), Bottles, and the wider GNOME and Linux application communities.
