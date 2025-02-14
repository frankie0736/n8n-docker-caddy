# n8n-docker-caddy


## 操作步骤
```bash

# 拉取n8n的镜像
git clone https://github.com/n8n-io/n8n-docker-caddy.git

# 进入n8n文件夹 【录屏的时候刚开始漏了这一步】
cd n8n-docker-caddy
# 执行完这条命令之后，直接跳到6:03秒看即可。

# 创建存储卷
sudo docker volume create caddy_data
sudo docker volume create n8n_data
sudo docker volume create postgres_data

# 开放Ubuntu的防火墙端口
sudo ufw allow 80
sudo ufw allow 443

# 修改环境变量
vi .env

# 修改caddy的配置文件
vi caddy_config/Caddyfile

# 启动docker: 运行n8n和caddy
sudo docker compose up -d

# 升级 1 - 拉取新的n8n版本
sudo docker compose pull
# 升级 2 - 停掉n8n服务
sudo docker compose down
# 升级 3 - 重新开启n8n服务
sudo docker compose up -d

#  确保 Docker 服务在启动时自动运行
#通常，Docker 服务在安装时会自动配置为在系统启动时运行。你可以通过以下命令检查并启用它：
sudo systemctl enable docker

#设置服务器每天凌晨4点自动重启
#你可以使用 cron 来安排服务器的自动重启。编辑 cron 任务
sudo crontab -e
0 4 * * * /sbin/shutdown -r now

```
## 源repo地址
[https://github.com/n8n-io/n8n-docker-caddy](https://github.com/n8n-io/n8n-docker-caddy)
