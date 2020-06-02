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

## zsh_local

```
cd linux && ln -s $PWD/.* ~ && echo "[ -f ~/.zsh_local ] && source ~/.zsh_local" >> ~/.zshrc
```
