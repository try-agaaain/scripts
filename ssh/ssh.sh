#!/bin/bash

dir=$(dirname "$(realpath "$0")") # ssh/
p_dir=$(dirname "$dir")

# 配置文件路径
CONFIG_FILE_PATH="$p_dir/.config"

# 检查配置文件是否存在
if [ ! -f "$CONFIG_FILE_PATH" ]; then
    echo "配置文件不存在，请确保 $CONFIG_FILE_PATH 文件无误"
    exit 1
fi

# 读取配置文件
source "$CONFIG_FILE_PATH"

# 检查必要的配置项是否存在
if [[ -z "$USERNAME" || -z "$SSH_CONFIG" || -z "$USER_PUBLIC_KEY" ]]; then
    echo "Error: Missing required configuration in $CONFIG_FILE."
    exit 1
fi

# 获取用户的 home 目录
HOME_DIR=$(eval echo "~$USERNAME")
USER_AUTH_KEYS="$HOME_DIR/.ssh/authorized_keys"

# 设置 root 用户密码
if [[ -n "$ROOT_PASSWORD" ]]; then
    echo "Setting root password..."
    echo "root:$ROOT_PASSWORD" | chpasswd
    # 修改 SSH 配置文件允许 root 登录
    echo "Modifying SSH configuration to allow root login..."
    if [[ -f "$SSH_CONFIG" ]]; then
        sed -i 's/^#PermitRootLogin .*/PermitRootLogin yes/' "$SSH_CONFIG"
        if ! grep -q "^PermitRootLogin yes" "$SSH_CONFIG"; then
            echo "PermitRootLogin yes" >> "$SSH_CONFIG"
        fi
    else
        echo "Error: SSH configuration file not found at $SSH_CONFIG"
        exit 1
    fi
else
    echo "Warning: ROOT_PASSWORD not set. Skipping root password configuration."
fi

# 为指定用户添加公钥
echo "Adding public key for user $USERNAME..."
if [[ -n "$USER_PUBLIC_KEY" ]]; then
    mkdir -p "$HOME_DIR/.ssh"
    chmod 700 "$HOME_DIR/.ssh"

    # 添加公钥到 authorized_keys
    echo "$USER_PUBLIC_KEY" > "$USER_AUTH_KEYS"
    chmod 600 "$USER_AUTH_KEYS"
    chown -R "$USERNAME:$USERNAME" "$HOME_DIR/.ssh"

    echo "Public key added successfully for user $USERNAME."
else
    echo "Error: USER_PUBLIC_KEY is empty. Cannot add public key."
    exit 1
fi

# 重启 SSH 服务
echo "Restarting SSH service..."
systemctl restart ssh
if [[ $? -ne 0 ]]; then
    echo "Failed to restart SSH service."
    exit 1
fi

echo "SSH service restarted successfully!"
echo "Setup completed."
