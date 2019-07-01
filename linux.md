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

