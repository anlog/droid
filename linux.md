## autossh service by systemctl

> /etc/systemd/system/autossh.service
```
[Unit]
Description=Autossh Tunnel Service
After=network.target

[Service]
User=user
Environment="AUTOSSH_GATETIME=0"
ExecStart=/usr/bin/autossh -M0 -o "ServerAliveInterval 30" -o "ServerAliveCountMax 3" -NR server_port:localhost:local_port user@host -p port -i key
KillMode=process
Restart=always

[Install]
WantedBy=multi-user.target
```

```
systemctl daemon-reload # reload systemd
systemctl is-enabled autossh && echo "autossh is already enabled." || systemctl enable autossh
systemctl start autossh
```
## [removing-colors-from-output](https://stackoverflow.com/questions/17998978/removing-colors-from-output)

#### For Mac OSX or BSD use
`sed $'s,\x1b\\[[0-9;]*[a-zA-Z],,g'`


## git log history

```
# 查看 presentation/src/main/java/com/chehejia/car/btphone/PhoneActivity.java 290-300行的所有代码提交修改历史记录
git log --oneline -L290,300:presentation/src/main/java/com/chehejia/car/btphone/PhoneActivity.java
# 查看提交中包含文件presentation/src/main/java/com/chehejia/car/btphone/PhoneActivity.java内容改动中 含有onCallLogsLoading的
git log   -G "onCallLogsLoading" presentation/src/main/java/com/chehejia/car/btphone/PhoneActivity.java
# 查看提交中包含文件内容改动中 含有onCallLogsLoading的
git log   -G "onCallLogsLoading"
```

## git show ignores

```
git status --ignored
git clean -ndX
find . -path ./.git -prune -o -print | git check-ignore --no-index --stdin --verbose
```

## socat nat

`socat tcp-listen:234,bind=0.0.0.0,reuseaddr,fork tcp:172.17.0.8:8000`
`socat -d -d  tcp-listen:5555,bind=127.0.0.1,reuseaddr,fork exec:'ssh linux "socat STDIO tcp:127.0.0.1:5555"'`

## zsh_local

```
cd linux && ln -s $PWD/.* ~ && echo "[ -f ~/.zsh_local ] && source ~/.zsh_local" >> ~/.zshrc
```

## wireguard

### server

```
# 首先进入配置文件目录，如果该目录不存在请先手动创建：mkdir /etc/wireguard
cd /etc/wireguard
 
# 然后开始生成 密匙对(公匙+私匙)。
wg genkey | tee sprivatekey | wg pubkey > spublickey
wg genkey | tee cprivatekey | wg pubkey > cpublickey
```

```
echo "[Interface]
# 服务器的私匙，对应客户端配置中的公匙（自动读取上面刚刚生成的密匙内容）
PrivateKey = $(cat sprivatekey)
# 本机的内网IP地址，一般默认即可，除非和你服务器或客户端设备本地网段冲突
Address = 10.0.0.1/24 
# 运行 WireGuard 时要执行的 iptables 防火墙规则，用于打开NAT转发之类的。
# 如果你的服务器主网卡名称不是 eth0 ，那么请修改下面防火墙规则中最后的 eth0 为你的主网卡名称。
PostUp   = iptables -A FORWARD -i wg0 -j ACCEPT; iptables -A FORWARD -o wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
# 停止 WireGuard 时要执行的 iptables 防火墙规则，用于关闭NAT转发之类的。
# 如果你的服务器主网卡名称不是 eth0 ，那么请修改下面防火墙规则中最后的 eth0 为你的主网卡名称。
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT; iptables -D FORWARD -o wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE
# 服务端监听端口，可以自行修改
ListenPort = 443
# 服务端请求域名解析 DNS
DNS = 8.8.8.8
# 保持默认
MTU = 1420
# [Peer] 代表客户端配置，每增加一段 [Peer] 就是增加一个客户端账号，具体我稍后会写多用户教程。
[Peer]
# 该客户端账号的公匙，对应客户端配置中的私匙（自动读取上面刚刚生成的密匙内容）
PublicKey = $(cat cpublickey)
# 该客户端账号的内网IP地址
AllowedIPs = 10.0.0.2/32"|sed '/^#/d;/^\s*$/d' > wg0.conf

```

```
echo "[Interface]
# 客户端的私匙，对应服务器配置中的客户端公匙（自动读取上面刚刚生成的密匙内容）
PrivateKey = $(cat cprivatekey)
# 客户端的内网IP地址
Address = 10.0.0.2/24
# 解析域名用的DNS
DNS = 8.8.8.8
# 保持默认
MTU = 1420
[Peer]
# 服务器的公匙，对应服务器的私匙（自动读取上面刚刚生成的密匙内容）
PublicKey = $(cat spublickey)
# 服务器地址和端口，下面的 X.X.X.X 记得更换为你的服务器公网IP，端口请填写服务端配置时的监听端口
Endpoint = X.X.X.X:443
# 因为是客户端，所以这个设置为全部IP段即可
AllowedIPs = 0.0.0.0/0, ::0/0
# 保持连接，如果客户端或服务端是 NAT 网络(比如国内大多数家庭宽带没有公网IP，都是NAT)，那么就需要添加这个参数定时链接服务端(单位：秒)，如果你的服务器和你本地都不是 NAT 网络，那么建议不使用该参数（设置为0，或客户端配置文件中删除这行）
PersistentKeepalive = 25"|sed '/^#/d;/^\s*$/d' > client.conf
```

`wg-quick down wg0`

```
# 设置开机启动
systemctl enable wg-quick@wg0
# 取消开机启动
systemctl disable wg-quick@wg0
```

### client

`brew install wireguard-tools`

```
sudo mkdir /usr/local/etc/wireguard
scp root@x.x.x.x:~/etc/wireguard/client.conf /usr/local/etc/wireguard
wg-quick up client
```

done

