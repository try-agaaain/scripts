#!/bin/bash

# 获取当前工作目录
dir=$(dirname "$(realpath "$0")")

# 服务和脚本文件名
service_name="host-only.service"
script_name="host-only/host-only.sh"

# 安装必要的工具，用于在脚本中触发DHCP
sudo apt install isc-dhcp-client isc-dhcp-client-ddns

# 定义服务文件的路径
service_file="/etc/systemd/system/$service_name"

# 动态生成 systemd 服务文件内容
cat << EOF | sudo tee $service_file > /dev/null
[Unit]
Description=set host-only ip for this computer.
After=network.target multi-user.target

[Service]
ExecStart=$dir/$script_name
WorkingDirectory=$dir
Type=simple

[Install]
WantedBy=multi-user.target
EOF


# 启用和启动服务
sudo systemctl enable $service_name
sudo systemctl start $service_name

# 给脚本文件添加执行权限
sudo chmod +x "$dir/$script_name"

# 如果需要使用户可以在不提供密码的情况下执行指定脚本，可以取消注释下一行
# echo "$(whoami) ALL=(ALL) NOPASSWD: $dir/$script_name" | sudo tee -a /etc/sudoers

# 执行脚本
sudo bash "$dir/$script_name"

# sudo systemctl status host-only.service 
# sudo systemctl disable host-only.service 