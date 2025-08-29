#!/bin/bash

set -ouex pipefail

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/39/x86_64/repoview/index.html&protocol=https&redirect=1

# this installs a package from fedora repos
dnf5 install -y tmux 

# Use a COPR Example:
#
# dnf5 -y copr enable ublue-os/staging
# dnf5 -y install package
# Disable COPRs so they don't end up enabled on the final image:
# dnf5 -y copr disable ublue-os/staging

#### Example for enabling a System Unit File

systemctl enable podman.socket

echo "NoDisplay=true" >> /usr/share/applications/cinnamon-color-panel.desktop
echo "NoDisplay=true" >> /usr/share/applications/cinnamon-display-panel.desktop
echo "NoDisplay=true" >> /usr/share/applications/cinnamon-network-panel.desktop
echo "NoDisplay=true" >> /usr/share/applications/cinnamon-onscreen-keyboard.desktop
echo "NoDisplay=true" >> /usr/share/applications/cinnamon-settings-actions.desktop
echo "NoDisplay=true" >> /usr/share/applications/cinnamon-settings-applets.desktop
echo "NoDisplay=true" >> /usr/share/applications/cinnamon-settings-backgrounds.desktop
echo "NoDisplay=true" >> /usr/share/applications/cinnamon-settings-calendar.desktop
echo "NoDisplay=true" >> /usr/share/applications/cinnamon-settings-default.desktop
echo "NoDisplay=true" >> /usr/share/applications/cinnamon-settings-desklets.desktop
echo "NoDisplay=true" >> /usr/share/applications/cinnamon-settings-desktop.desktop
echo "NoDisplay=true" >> /usr/share/applications/cinnamon-settings-effects.desktop
echo "NoDisplay=true" >> /usr/share/applications/cinnamon-settings-extensions.desktop
echo "NoDisplay=true" >> /usr/share/applications/cinnamon-settings-fonts.desktop
echo "NoDisplay=true" >> /usr/share/applications/cinnamon-settings-general.desktop
echo "NoDisplay=true" >> /usr/share/applications/cinnamon-settings-gestures.desktop
echo "NoDisplay=true" >> /usr/share/applications/cinnamon-settings-hotcorner.desktop
echo "NoDisplay=true" >> /usr/share/applications/cinnamon-settings-info.desktop
echo "NoDisplay=true" >> /usr/share/applications/cinnamon-settings-keyboard.desktop
echo "NoDisplay=true" >> /usr/share/applications/cinnamon-settings-mouse.desktop
echo "NoDisplay=true" >> /usr/share/applications/cinnamon-settings-nightlight.desktop
echo "NoDisplay=true" >> /usr/share/applications/cinnamon-settings-notifications.desktop
echo "NoDisplay=true" >> /usr/share/applications/cinnamon-settings-panel.desktop
echo "NoDisplay=true" >> /usr/share/applications/cinnamon-settings-power.desktop
echo "NoDisplay=true" >> /usr/share/applications/cinnamon-settings-privacy.desktop
echo "NoDisplay=true" >> /usr/share/applications/cinnamon-settings-screensaver.desktop
echo "NoDisplay=true" >> /usr/share/applications/cinnamon-settings-sound.desktop
echo "NoDisplay=true" >> /usr/share/applications/cinnamon-settings-startup.desktop
echo "NoDisplay=true" >> /usr/share/applications/cinnamon-settings-themes.desktop
echo "NoDisplay=true" >> /usr/share/applications/cinnamon-settings-tiling.desktop
echo "NoDisplay=true" >> /usr/share/applications/cinnamon-settings-universal-access.desktop
echo "NoDisplay=true" >> /usr/share/applications/cinnamon-settings-user.desktop
echo "NoDisplay=true" >> /usr/share/applications/cinnamon-settings-windows.desktop
echo "NoDisplay=true" >> /usr/share/applications/cinnamon-settings-workspaces.desktop
echo "NoDisplay=true" >> /usr/share/applications/cinnamon-wacom-panel.desktop
echo "NoDisplay=true" >> /usr/share/applications/mintlocale.desktop
