#!/bin/bash

# 获取当前脚本所在目录
dir=$(dirname "$(realpath "$0")")

# 定义目标位置
target_dir="/usr/local/scripts-for-virtualbox"

# 检查目标目录是否已存在
if [ ! -d "$target_dir" ]; then
    echo "Moving $dir to $target_dir..."
    sudo mkdir -p "$target_dir"
    sudo cp -r "$dir/"* "$target_dir/"
else
    echo "$target_dir already exists. Updating scripts..."
    sudo cp -r "$dir/"* "$target_dir/"
fi

# 切换到目标目录
dir="$target_dir"

# 定义要执行的子脚本路径
scripts=(
    "static-ip/install.sh"
    "init/init.sh"
    "ssh/ssh.sh"
)

# 使用 for 循环遍历并执行子脚本
for script in "${scripts[@]}"; do
    sudo bash "$target_dir/$script"
done
