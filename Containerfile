# Allow build scripts to be referenced without being copied into the final image
FROM scratch AS ctx
COPY build_files /

# Base Image
FROM quay.io/fedora/fedora-bootc:42

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
    dnf5 -y config-manager setopt "*staging*".exclude="scx-scheds kf6-* mesa* mutter* rpm-ostree* systemd* gnome-shell gnome-settings-daemon gnome-control-center gnome-software libadwaita tuned*" && \
    echo "done"

# Install kernel
RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    for toswap in linux-firmware netronome-firmware libertas-firmware atheros-firmware realtek-firmware tiwilink-firmware cirrus-audio-firmware linux-firmware-whence iwlwifi-dvm-firmware iwlwifi-mvm-firmware amd-ucode-firmware qcom-firmware mt7xxx-firmware liquidio-firmware nxpwireless-firmware intel-vsc-firmware nvidia-gpu-firmware intel-audio-firmware amd-gpu-firmware iwlegacy-firmware intel-gpu-firmware mlxsw_spectrum-firmware qed-firmware mrvlprestera-firmware brcmfmac-firmware dvb-firmware; do \
        dnf5 -y swap --repo copr:copr.fedorainfracloud.org:bazzite-org:bazzite $toswap $toswap; \
    done && unset -v toswap && \
    dnf5 -y config-manager setopt "*rpmfusion*".enabled=0 && \
    done && unset -v toswap

# Install Cinnamon Desktop Enviroment 
RUN --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=tmpfs,dst=/tmp \
    for spice in \
        uupd \
        NetworkManager-adsl \
        NetworkManager-bluetooth \
        NetworkManager-iodine-gnome \
        NetworkManager-l2tp-gnome \
        NetworkManager-libreswan-gnome \
        NetworkManager-openconnect-gnome \
        NetworkManager-openvpn-gnome \
        NetworkManager-ppp \
        NetworkManager-pptp-gnome \
        NetworkManager-vpnc-gnome \
        NetworkManager-wifi \
        NetworkManager-wwan \
        abrt-desktop  \
        blueman \
        cinnamon \
        cinnamon-control-center \
        cinnamon-screensaver \
        ffmpegthumbnailer \
        firewall-config \
        gnome-calculator \
        gnome-disk-utility \
        gnome-screenshot \
        gnome-software \
        gnome-system-monitor \
        gnome-terminal \
        gstreamer1-plugins-ugly-free \
        gvfs-archive \
        gvfs-gphoto2 \
        gvfs-mtp \
        gvfs-smb \
        muffin \
        nemo-fileroller \
        nemo-image-converter \
        nemo-preview \
        pipewire-alsa \
        pipewire-pulseaudio \
        powerline \
        qadwaitadecorations-qt5 \
        sane-backends-drivers-scanners \
        setroubleshoot \
        simple-scan \
        slick-greeter \
        slick-greeter-cinnamon \
        system-config-printer \
        tmux \
        tmux-powerline \
        vim-powerline \
        xdg-user-dirs-gtk \
        xed \
        xreader \
        wireplumber \
        lightdm-gtk \
        lightdm-settings \
        lightdm; \
    do \
    dnf5 install $spice; && \
    done && unset -v spice

# Configure
RUN --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=tmpfs,dst=/tmp \
    systemctl enable lightdm

### LINTING
## Verify final image and contents are correct.
RUN bootc container lint
