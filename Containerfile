# Allow build scripts to be referenced without being copied into the final image
FROM scratch AS ctx
COPY build_files /

# Base Image
FROM ghcr.io/ublue-os/base-main:42

## Other possible base images include:
# FROM ghcr.io/ublue-os/bazzite:latest
# FROM ghcr.io/ublue-os/bluefin-nvidia:stable
# 
# ... and so on, here are more base images
# Universal Blue Images: https://github.com/orgs/ublue-os/packages
# Fedora base image: quay.io/fedora/fedora-bootc:41
# CentOS base images: quay.io/centos-bootc/centos-bootc:stream10

### MODIFICATIONS
## make modifications desired in your image and install packages by modifying the build.sh script
## the following RUN directive does all the things required to run "build.sh" as recommended.

# Setup Copr
RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    for copr in \
        ublue-os/staging \
        ublue-os/packages; \
    do \
    dnf5 -y install dnf5-plugins && \
    dnf5 -y copr enable $copr; \
    done && unset -v copr && \
    dnf5 -y install --nogpgcheck --repofrompath 'terra,https://repos.fyralabs.com/terra$releasever' terra-release{,-extras} && \
    dnf5 -y config-manager addrepo --overwrite --from-repofile=https://pkgs.tailscale.com/stable/fedora/tailscale.repo && \
    dnf5 -y install \
        https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
        https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm && \
    dnf5 -y config-manager setopt "*terra*".priority=3 "*terra*".exclude="nerd-fonts topgrade" && \
    dnf5 -y config-manager setopt "terra-mesa".enabled=true && \
    dnf5 -y config-manager setopt "terra-nvidia".enabled=false && \
    dnf5 -y config-manager setopt "*rpmfusion*".priority=5 "*rpmfusion*".exclude="mesa-*" && \
    dnf5 -y config-manager setopt "*fedora*".exclude="mesa-* kernel-core-* kernel-modules-* kernel-uki-virt-*" && \
    dnf5 -y config-manager setopt "*staging*".exclude="scx-scheds kf6-* mesa* mutter* rpm-ostree* systemd* gnome-shell gnome-settings-daemon gnome-control-center gnome-software libadwaita tuned*"

# Install Cinnamon Desktop Enviroment 
RUN --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=tmpfs,dst=/tmp \
    for spice in \
        uupd \
        git \
        flatpak \
        NetworkManager-adsl \
        NetworkManager-bluetooth \
        NetworkManager-openconnect-gnome \
        NetworkManager-openvpn-gnome \
        NetworkManager-ppp \
        NetworkManager-pptp-gnome \
        NetworkManager-vpnc-gnome \
        NetworkManager-wifi \
        NetworkManager-wwan \
        blueman \
        cinnamon \
        cinnamon-control-center \
        cinnamon-screensaver \
        firewall-config \
        glx-utils \
        gnome-disk-utility \
        gnome-screenshot \
        gnome-system-monitor \
        gnome-terminal \
        gstreamer1-plugins-ugly-free \
        gvfs-archive \
        gvfs-gphoto2 \
        gvfs-mtp \
        gvfs-smb \
        imsettings-gsettings \
        initial-setup-gui \
        mesa-dri-drivers \
        mesa-vulkan-drivers \
        muffin \
        nemo-fileroller \
        nemo-image-converter \
        nemo-preview \
        nm-connection-editor \
        pipewire-alsa \
        pipewire-pulseaudio \
        powerline \
        qgnomeplatform-qt5 \
        redshift-gtk \
        lightdm \
        lightdm-gtk \
        system-config-printer \
        totem-video-thumbnailer \
        wireplumber \
        xdg-user-dirs-gtk \
        xorg-x11-drv-amdgpu \
        xorg-x11-drv-ati \
        xorg-x11-drv-evdev \
        xorg-x11-drv-fbdev \
        xorg-x11-drv-libinput \
        xorg-x11-drv-nouveau \
        xorg-x11-drv-qxl \
        xorg-x11-drv-wacom \
        xorg-x11-server-Xorg \
        xorg-x11-xauth \
        xorg-x11-xinit \
        xorg-x11-drv-intel \
        xorg-x11-drv-openchrome \
        xorg-x11-drv-vesa \
        xorg-x11-drv-vmware; \
    do \
    dnf5 install -y $spice; \
    done && unset -v spice

# Configure
RUN --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=tmpfs,dst=/tmp \
    systemctl enable lightdm && \
    echo 'u lightdm - "Light Display Manager" /var/lib/lightdm' > /usr/lib/sysusers.d/lightdm.conf && \
    echo 'u nm-openconnect - "NetworkManager OpenConnect Plugin" /var/lib/nm-openconnect /usr/sbin/nologin' > /usr/lib/sysusers.d/nm-openconnect.conf && \
    echo 'u nm-openvpn - "NetworkManager OpenVPN Plugin" /var/lib/nm-openvpn /usr/sbin/nologin' > /usr/lib/sysusers.d/nm-openvpn.conf && \
    echo 'u wsdd - "Web Services Dynamic Discovery Daemon" /var/lib/wsdd /usr/sbin/nologin' > /usr/lib/sysusers.d/wsdd.conf && \
    systemctl set-default graphical.target 

# Install Software manager held toghether by duct tape
RUN --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=tmpfs,dst=/tmp \
    cd /tmp/ \
    git clone https://github.com/horizonlinux/FatInstall.git \
    cd FatInstall \
    cp usr / -r \
    cd /tmp \
    rm -r FatInstall \
    cd / \
    flatpak remote-delete fedora --force \
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo \

# Cleanup
RUN --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=tmpfs,dst=/tmp \
    dnf5 clean all && \
    rm -rf /tmp/* || true && \
    find /var/* -maxdepth 0 -type d \! -name cache -exec rm -fr {} \; && \
    find /var/cache/* -maxdepth 0 -type d \! -name libdnf5 \! -name rpm-ostree -exec rm -fr {} \; && \
    mkdir -p /var/tmp && \
    chmod -R 1777 /var/tmp && \
    ostree container commit

### LINTING
## Verify final image and contents are correct.
RUN bootc container lint
