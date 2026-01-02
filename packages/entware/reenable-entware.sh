#!/bin/sh
set -e

ENTWARE_DATA="/home/root/.entware"

reenable_entware() {
    if [ ! -d "$ENTWARE_DATA" ]; then
        echo "Error: $ENTWARE_DATA not found. Entware is not installed."
        exit 1
    fi

    if mountpoint -q /opt 2>/dev/null && systemctl is-enabled opt.mount >/dev/null 2>&1; then
        echo "Entware is already enabled."
        exit 0
    fi

    [ ! -d /opt ] && mkdir -p /opt

    if ! mountpoint -q /opt 2>/dev/null; then
        mount --bind "$ENTWARE_DATA" /opt
    fi

    cat > /etc/systemd/system/opt.mount << 'EOF'
[Unit]
Description=Bind mount over /opt to give Entware more space
DefaultDependencies=no
Conflicts=umount.target
After=home.mount
Requires=home.mount
BindsTo=home.mount

[Mount]
What=/home/root/.entware
Where=/opt
Type=none
Options=bind

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    systemctl enable opt.mount

    echo "Entware re-enabled successfully."
}

reenable_entware "$@"
