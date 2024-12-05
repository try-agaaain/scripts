这个项目编写了几个方便易用的脚本，以便更快的在虚拟机上完成一些设置，主要有：

1、安装常用的工具，比如virtualbox-guest-utils；

2、为Host-Only设置静态IP地址；

3、将主机公钥添加到虚拟机ssh配置中。


## 各脚本的信息

### [build.sh](./build.sh)
将所有文件复制一份到 `/usr/local/scripts-for-virtualbox`，随后依次执行各个子脚本。

### [init/init.sh](./inti/init.sh)

用于安装必要的工具：

`virtualbox-guest-utils`：该工具使虚拟机能进行文件共享，并在指定“自动挂载”使自动挂载；

`isc-dhcp-client`：提供dhclient工具进行DHCP刷新，用于处理DHCP没有自动分配IP地址的问题；

`inetutils-traceroute`：提供traceroute，用于查看网络请求路径；

`net-tools`：提供route命令，用于查看路由表；



### [ssh/ssh.sh](./ssh/ssh.sh)
需手动配置 [ssh/.config](ssh/.config)，提供用户名和主机公钥。

该脚本为指定用户配置主机公钥，以便该用户能在主机侧免密登录到虚拟机。


### [static-ip](./static-ip/)

#### [static-ip/install.sh](static-ip/install.sh)
用于注册开机自动执行的服务，这个服务用于执行指定的 [static-ip/host-only/host-only.sh](static-ip/host-only/host-only.sh) 脚本，该脚本会根据 [static-ip/host-only/.config](static-ip/host-only/.config) 生成 `/etc/netplan/60-host-only.yaml` 文件用于设置静态IP地址，虚拟机在每次启动时都会加载该文件，使静态IP生效。

> 这个过程实际上只需要生成一次 `/etc/netplan/60-host-only.yaml` 文件就够了，其实没有必要写成开机服务的方式。通过 `sudo systemctl disable host-only.service` 停用该服务也没关系。

> 这样写最开始是想在开机时，先从桥接网络中动态获取分配给虚拟机的IP地址，然后将IP地址最后几位设置为固定值，比如240，而前面的网络号则随主机连接的WiFi动态变化。这样虚拟机的IP地址就不会完全随机了，稍微方便一些。不过后面有更好的Host-Only方式，桥接网络就没有必要设置这样的半静态IP了。


### 资源下载

Ubuntu Server24.04：[中科大镜像源](https://mirrors.ustc.edu.cn/ubuntu-releases/)

VirtualBox 7.0.22版本下载：[Download_Old_Builds_7_0](https://www.virtualbox.org/wiki/Download_Old_Builds_7_0)