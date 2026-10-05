#!/bin/bash
set -e

# ============================================
# JAMESXHER VPS - RAILWAY SSH SERVER
# ============================================

SSH_USER="ipx"
SSH_PASSWORD="loveyoubabu3000"


# ============================================
# CREATE SSH USER
# ============================================

echo "Creating SSH user..."

if ! id "$SSH_USER" >/dev/null 2>&1; then
    useradd -m -s /bin/bash "$SSH_USER"
fi

echo "$SSH_USER:$SSH_PASSWORD" | chpasswd

usermod -aG sudo "$SSH_USER"

echo "$SSH_USER ALL=(ALL) NOPASSWD:ALL" \
    > "/etc/sudoers.d/$SSH_USER"

chmod 440 "/etc/sudoers.d/$SSH_USER"


# ============================================
# CUSTOM JAMESXHER TERMINAL
# ============================================

touch "/home/$SSH_USER/.bashrc"

# Prevent duplicate prompt lines after restart
sed -i '/# JAMESXHER_PROMPT/d' "/home/$SSH_USER/.bashrc" || true
sed -i '/Jamesxher@Jamesxher-VPS/d' "/home/$SSH_USER/.bashrc" || true

cat >> "/home/$SSH_USER/.bashrc" <<'EOF'

# JAMESXHER_PROMPT
export PS1='Jamesxher@Jamesxher-VPS:\w\$ '
EOF

# Make sure SSH login loads .bashrc
touch "/home/$SSH_USER/.bash_profile"

if ! grep -q "source ~/.bashrc" "/home/$SSH_USER/.bash_profile"; then
    cat >> "/home/$SSH_USER/.bash_profile" <<'EOF'

if [ -f ~/.bashrc ]; then
    source ~/.bashrc
fi
EOF
fi

chown "$SSH_USER:$SSH_USER" "/home/$SSH_USER/.bashrc"
chown "$SSH_USER:$SSH_USER" "/home/$SSH_USER/.bash_profile"


# ============================================
# CONFIGURE SSH
# ============================================

mkdir -p /run/sshd
mkdir -p /etc/ssh/sshd_config.d

cat > /etc/ssh/sshd_config.d/railway.conf <<EOF
Port 22
ListenAddress 0.0.0.0
PasswordAuthentication yes
KbdInteractiveAuthentication no
PermitRootLogin no
UsePAM no
X11Forwarding no
PrintMotd no
ClientAliveInterval 60
ClientAliveCountMax 3
EOF


# ============================================
# GENERATE SSH HOST KEYS
# ============================================

ssh-keygen -A


# ============================================
# TEST SSH CONFIGURATION
# ============================================

/usr/sbin/sshd -t


# ============================================
# STARTUP MESSAGE
# ============================================

echo ""
echo "============================================"
echo "              JAMESXHER VPS"
echo "============================================"
echo " SSH SERVER READY!"
echo " User: $SSH_USER"
echo " Internal port: 22"
echo " Terminal: Jamesxher@Jamesxher-VPS"
echo "============================================"
echo ""


# ============================================
# START SSH SERVER
# ============================================

exec /usr/sbin/sshd -D -e
