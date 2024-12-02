#!/bin/bash

# 获取当前主机的IP地址和子网掩码
current_ip=$(hostname -I | awk '{print $1}')
subnet_mask=$(ip addr show | grep -w "$current_ip" | grep -oP '(?<=/)\d+')

if [ -z "$subnet_mask" ]; then
    echo "未能获取到正确的子网掩码，请检查网络配置。"
    exit 1
fi

echo "当前主机的IP地址是: $current_ip/$subnet_mask"

# 获取当前网关地址
gateway=$(ip route | grep default | awk '{print $3}' | head -n 1)
echo "当前网关地址是: $gateway"

# 提示用户是否按程序默认修改IP和网关地址
echo "是否按程序的方式修改IP地址和网关地址？"
echo "输入'yes'表示按程序默认修改，输入'no'表示自定义IP地址。"
read user_input

if [[ "$user_input" == "no" ]]; then
    # 让用户输入自定义的IP地址
    echo "请输入新的IP地址:"
    read current_ip

fi

# 检查文件是否存在，如果存在则备份
if [ -f /etc/netplan/01-bridge-net.yaml ]; then
    echo "/etc/netplan/01-bridge-net.yaml 文件已存在，正在创建备份..."
    sudo cp /etc/netplan/01-bridge-net.yaml /etc/netplan/01-bridge-net.yaml.orig
    echo "备份已创建为 /etc/netplan/01-bridge-net.yaml.orig"
fi

# 如果有多个yaml文件，则按字母序依次加载，后加载的文件将覆盖之前加载的文件中的相同配置项！！！

# 写入/etc/netplan/01-bridge-net.yaml文件
echo "正在写入/etc/netplan/01-bridge-net.yaml文件..."

sudo bash -c "cat > /etc/netplan/01-bridge-net.yaml <<EOF
network:
  version: 2
  ethernets:
    eth0:
      dhcp4: no
      addresses:
        - $current_ip/$subnet_mask
      routes:
        - to: 0.0.0.0/0
          via: $gateway
          metric: 100
      nameservers:
        addresses:
          - 8.8.8.8
          - 8.8.4.4
          - 223.5.5.5
          - 223.6.6.6
EOF"

sudo netplan apply

echo "文件创建完成！"
