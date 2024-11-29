#!/bin/bash

# Automate SSH Configuration, This script has been develop for working in a factory new:
# Ubuntu 24.04.1 LTS (GNU/Linux 6.8.0-1019-aws x86_64)
# You may take care about aditional configuration on AWS Security Groups (in this scenario)
# This has absolutely no warranty, you must check this before running in your server.
# You should not use this in production servers or data sensitive target (JUST FOR FACTORY NEW...)

# Allow the default SSH port 22 (we'll fix this later)
echo "Allowing default SSH port 22..."
sudo ufw allow ssh

# Allow a custom SSH port (e.g., 4040/tcp)
CUSTOM_PORT=4040
echo "Allowing custom SSH port $CUSTOM_PORT..."
sudo ufw allow ${CUSTOM_PORT}/tcp comment "Custom SSH port"

# Remove unused IPv6 ports (assumes rule 3 twice)
echo "Removing unused IPv6 ports..."
sudo ufw delete 3 <<EOF
y
EOF
sudo ufw delete 3 <<EOF
y
EOF

# Enable UFW
echo "Enabling UFW..."
sudo ufw enable <<EOF
y
EOF

# Create ssh.socket configuration
echo "Creating SSH socket configuration..."
cat <<EOT > ~/ssh.socket
[Unit]
Description=OpenBSD Secure Shell server socket
Before=sockets.target ssh.service
ConditionPathExists=!/etc/ssh/sshd_not_to_be_run

[Socket]
ListenStream=${CUSTOM_PORT}
FreeBind=yes

[Install]
WantedBy=sockets.target
EOT

# Move the ssh.socket file to the correct path
echo "Moving ssh.socket to /etc/systemd/system/..."
sudo mv ~/ssh.socket /etc/systemd/system/ssh.socket

# Reload systemd and restart services
echo "Reloading and restarting systemd services..."
sudo systemctl daemon-reload
sudo systemctl restart ssh.socket
sudo systemctl restart ssh

# Enable SSH service
echo "Enabling SSH service..."
sudo systemctl enable ssh

# Delete default port 22 from UFW rules
echo "Deleting default SSH port 22 rule..."
sudo ufw delete allow ssh <<EOF
y
EOF

echo "SSH configuration automated successfully!"

