### SSH连接配置

SSH有两种连接方式：

一种是通过密码连接，这种方式比较简单，直接 `ssh username@xx.xx.xx.xx` 然后输入密码即可；

> 踩坑：需要注意的是root用户默认并不支持该登录方式，需要在/etc/ssh/sshd_config中将`PermitRootLogin` 设置为yes。同时虚拟机刚创建时，root用户是没有密码的，需要为root设置好密码后才能通过这种方式登录。

第二种是将主机的公钥加入虚拟机用户的`home/userxx/.ssh/authorized_keys`文件中，通过这个方式主机侧通过SSH登录对应用户时无需提供密码，更加方便快捷。

> 注意，这种方式只在 `ssh userxx@xx.xx.xx.xx` 时无需提供密码，但对于另一个用户比如useryy，依然是需要提供密码的，可以将主机公钥添加到`home/useryy/.ssh/authorized_keys`

**.ssh目录的权限必须是700**，**.ssh/authorized_keys文件权限必须是600**

如果无法成功注意检查 `RSAAuthentication yes` 和 `PubkeyAuthentication yes`

同时也通过 `sudo systemctl status ssh` 检查一下ssh服务是否开启，没有开启的话通过 `sudo systemctl start ssh` 打开。







































