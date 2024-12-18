#!/bin/bash

dir=$(dirname "$(realpath "$0")") # static-ip/host-only
p_dir=$(dirname "$dir")      # static-ip/
pp_dir=$(dirname "$p_dir")
# 配置文件路径
CONFIG_FILE_PATH="$pp_dir/.config"

# 检查配置文件是否存在
if [ ! -f "$CONFIG_FILE_PATH" ]; then
    echo "配置文件不存在，请确保 $CONFIG_FILE_PATH 文件无误"
    exit 1
fi

# 让DHCP动态分配地址，原本不必要，但这次部署时有些网卡没有自动部署上IP地址。
sudo dhclient -r  # 删除原有IP地址
sudo dhclient     # 通过DHCP重新分配

# 读取配置文件
source "$CONFIG_FILE_PATH"

# 网卡名称
network_interface=${NETWORK_INTERFACE}
# 静态IP地址
new_ip=${STATIC_IP}

# DNS服务器地址（如果未配置则使用默认值）
dns_servers=${DNS_SERVERS:-"8.8.8.8 8.8.4.4 223.5.5.5 223.6.6.6"}

# Netplan配置文件路径（如果未配置则使用默认路径）
config_file=${CONFIG_FILE:-/etc/netplan/60-host-only.yaml}

# 检查文件是否存在，如果存在则备份
if [ -f "$config_file" ]; then
    echo "$config_file 文件已存在，正在创建备份..."
    sudo cp "$config_file" "${config_file}.orig"
    echo "备份已创建：${config_file}.orig"
fi

# 写入Netplan配置文件
echo "正在写入$config_file文件..."
sudo bash -c "cat > $config_file <<EOF
network:
  version: 2
  ethernets:
    $network_interface:
      dhcp4: no
      addresses:
        - $new_ip
EOF"

# 限制权限并应用配置
sudo chmod 600 "$config_file"
sudo netplan apply

echo "网络设置已完成！"
echo "当前ip地址为：$new_ip"
