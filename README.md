该项目编写了几个方便易用的脚本，以便更好的在VirtualBox上使用Ubuntu虚拟机，主要有：

1、安装常用的工具，比如virtualbox-guest-utils，这是VirtualBox提供文件共享功能所需要的库；

2、为Host-Only网络接口设置静态IP地址；

3、将主机公钥添加到虚拟机ssh配置中；

4、提供快捷的执行方式，直接执行 build.sh 文件即可完成所有脚本的执行。

脚本经过多次测试，能顺利完成部署任务。

### 如何使用

虚拟机安装后，将该脚本通过文件共享方式或在VScode上通过拖拽的方式加入到虚拟机中，随后在 ·config 文件中配置好你需要的信息，执行：

```bash
sudo bash build.sh
```

## 更具体的功能

### [build.sh](./build.sh)

将所有文件复制一份到 `/usr/local/scripts-for-virtualbox`，随后依次执行下面的各个脚本。

### [init/init.sh](./inti/init.sh)

用于安装必要的工具：

`virtualbox-guest-utils`：该工具使虚拟机能通过VirtualBox和主机进行文件共享，并在指定“自动挂载”使自动挂载；

`isc-dhcp-client`：提供dhclient工具进行DHCP刷新，用于处理DHCP没有自动分配IP地址的问题；

`inetutils-traceroute`：提供traceroute，用于查看网络请求路径；

`net-tools`：提供route命令，用于查看路由表；

### [ssh/ssh.sh](./ssh/ssh.sh)

需在 `.config` 文件中手动配置用户名和主机公钥。该脚本可以为指定用户配置主机公钥，以便该用户能在主机侧免密码登录到虚拟机。

### [static-ip/install.sh](static-ip/install.sh)

用于注册开机自动执行服务——`host-only.service`，[static-ip/install.sh](static-ip/install.sh) 会自动生成该文件并添加到 `/etc/systemd/system` 中，随后通过 `sudo systemctl enable host-only.service` 使该服务生效，每次开机时便会自动执行该服务。

这个服务会执行指定的 [static-ip/host-only/host-only.sh](static-ip/host-only/host-only.sh) 脚本，该脚本会根据 [.config](.config) 的配置信息生成 `/etc/netplan/60-host-only.yaml` 文件用于设置静态IP地址，虚拟机在每次启动时都会加载该文件，使静态IP生效。

> 这个过程实际上只需要生成一次 `/etc/netplan/60-host-only.yaml` 文件就够了，其实没有必要写成开机服务的方式。通过 `sudo systemctl disable host-only.service` 停用该服务也没关系。

> 这样写最开始是想在开机时，先从桥接网络中动态获取分配给虚拟机的IP地址，然后将IP地址最后几位设置为固定值，比如240，而前面的网络号则随主机连接的WiFi动态变化。这样虚拟机的IP地址就不会完全随机了，稍微方便一些。不过后面有更好的Host-Only方式，桥接网络就没有必要设置这样的半静态IP了。


### 资源下载

Ubuntu Server24.04：[中科大镜像源](https://mirrors.ustc.edu.cn/ubuntu-releases/)

VirtualBox 7.0.22版本下载：[Download_Old_Builds_7_0](https://www.virtualbox.org/wiki/Download_Old_Builds_7_0)
