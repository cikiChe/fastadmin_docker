> fastadmin Docker Image
# fastadmin Docker 镜像


# Quick start

## 方式1 docker

```bash
docker build -t fastadmin .
docker run -d -p 80:80 fastadmin
```

## 方式2 docker-compose 

```bash
docker-compose up -d
```
以上两种方式任选其一


# 特色
## 说明
1. 自动下载最新的 fastadmin 压缩包到项目目录，里面只有一个nginx和php 。需要使用反代到这个容器
2. 代码里面不含 mysql ，如果需要，请自行安装。
3. 因为 fastadmin 官网不提供 docker 镜像了（至少我没有找到）
4. 代码目录为 容器内 */var/www/html/fastadmin
5. nginx 配置为 /etc/nginx/nginx.conf (容器内) 。
6. nginx 域名配置目录为 /etc/nginx/conf.d (容器内)


## End
如果对您有用，请帮忙点个 star
