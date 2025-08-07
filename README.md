# 自定义 Rocky Linux ISO 与 Docker 安装指南

### 1. 准备 Docker RPM 包

```bash
# 创建新的 docker_rpms 目录
rm -rf docker_rpms
mkdir -p docker_rpms
cd docker_rpms

# 下载 Docker CE 仓库文件
curl -O https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/centos/docker-ce.repo

# 修改仓库文件，使用阿里云镜像源
sed -i 's|https://download.docker.com|https://mirrors.tuna.tsinghua.edu.cn/docker-ce|g' docker-ce.repo

# 安装 yum-utils 以便使用 yumdownloader
yum install -y yum-utils

# 下载 Docker 及其依赖包（不安装）
yumdownloader --resolve docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# 返回上级目录
cd ..
```

### 2. 生成仓库元数据
```bash
# 安装 createrepo_c 工具
yum install -y createrepo_c

# 生成仓库元数据
createrepo_c docker_rpms
```

### 3. 构建自定义 ISO
```bash
# 运行构建脚本
chmod +x build.sh
./build.sh
```

## 验证 Docker 安装
ISO 构建完成后，安装系统并验证 Docker 是否正确安装：
```bash
# 检查 Docker 版本
docker --version

# 启动 Docker 服务
systemctl start docker

# 设置 Docker 开机自启
systemctl enable docker

# 验证 Docker 是否正常运行
docker run hello-world
```

## 安全建议
1. 安装完成后，建议修改默认密码：
   ```bash
   passwd root
   passwd sfere
   ```

2. 考虑禁用 SSH 密码认证，使用密钥认证：
   ```bash
   sed -i 's/^PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
   systemctl restart sshd
   ```

3. 移除或限制 sudo 免密码权限：
   ```bash
   vi /etc/sudoers.d/sfere
   ```

## 文件引用
- <mcfile name="build.sh" path="/root/rocky-iso-custom/build.sh"></mcfile>
- <mcfile name="ks.cfg" path="/root/rocky-iso-custom/ks.cfg"></mcfile>
- <mcfolder name="docker_rpms" path="/root/rocky-iso-custom/docker_rpms"></mcfolder>

## 参考文章
```bash
https://blog.csdn.net/yudaxiaye/article/details/131818684
https://linuxhint.com/install-centos-kickstart
```
