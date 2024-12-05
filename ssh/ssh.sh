#!/bin/bash

# 检查是否传递了参数
if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <username>"
    exit 1
fi

# 获取传递的用户名
USERNAME=$1

dir=$(dirname "$(realpath "$0")")

HOME_DIR=$(eval echo "~$USERNAME")
# 修改 SSH 配置文件
SSH_CONFIG="/etc/ssh/sshd_config"
SSH_KEY_FILE="$dir/ssh_key.pub"
USER_AUTH_KEYS="$HOME_DIR/.ssh/authorized_keys"

# 检查配置文件是否存在
if [[ ! -f "$SSH_CONFIG" ]]; then
    echo "Error: SSH configuration file not found at $SSH_CONFIG"
    exit 1
fi

############################ 允许root用户通过ssh登录 ############################
echo "Modifying SSH configuration to allow root login..."
sed -i 's/^#PermitRootLogin .*/PermitRootLogin yes/' "$SSH_CONFIG"
if ! grep -q "^PermitRootLogin yes" "$SSH_CONFIG"; then
    echo "PermitRootLogin yes" >> "$SSH_CONFIG"
fi

# 设置 root 用户密码
echo "Setting password for root user..."
passwd root

echo "Setup completed. Root user can now log in via SSH."
################################################################################

############################## 为指定用户添加公钥 ###############################
if [[ -f "$SSH_KEY_FILE" ]]; then
    echo "Adding public key from $SSH_KEY_FILE to $USER_AUTH_KEYS..."

    # 确保 $HOME/.ssh 目录存在
    mkdir -p $HOME/.ssh
    chmod 700 $HOME/.ssh

    # 添加公钥到 authorized_keys
    cat "$SSH_KEY_FILE" >> "$USER_AUTH_KEYS"
    chmod 600 "$USER_AUTH_KEYS"

    echo "Public key added successfully."
else
    echo "Error: Public key file $SSH_KEY_FILE not found in the current directory."
fi
################################################################################

echo "SSH configuration updated. Restarting SSH service..."
systemctl restart ssh
if [[ $? -ne 0 ]]; then
    echo "Failed to restart SSH service."
    exit 1
fi

echo "SSH service restarted successfully!"

