# Kubernetes Node Bundle

一个用于收集 Kubernetes 节点信息的可扩展工具集。通过插件化设计，支持灵活的数据收集和报告生成。

## 功能特点

- 插件化架构，易于扩展
- 支持本地和远程命令执行
- 分类管理的数据收集器
- 支持自定义脚本

## 项目结构

```
.
├── ansible.cfg           # Ansible 配置文件
├── plugins/            # 插件目录
│   └── collectors/    # 数据收集插件
│       ├── system.yml
│       ├── network.yml
│       └── kubernetes.yml
├── lib/               # 核心库
│   └── plugin_loader.py
├── scripts/          # 自定义脚本
├── playbooks/        # Ansible playbooks
└── output/           # 输出目录
```

## 前置条件

- Python 3.6+
- Ansible 2.9+
- 对目标节点的 SSH 访问权限
- 本地 kubectl 配置（用于收集 Kubernetes 信息）

## 安装

1. 克隆仓库：
   ```bash
   git clone <repository-url>
   cd kube-node-bundle
   ```

2. 安装依赖：
   ```bash
   pip install -r requirements.txt
   ```

## 配置

### 添加新的收集器
1. 在 `plugins/collectors/` 创建新的 YAML 文件
2. 定义收集器配置：
   ```yaml
   name: Your Collector
   description: Your description
   enabled: true
   
   commands:
     - name: command_name
       cmd: your_command
       category: your_category
   
   scripts:
     - name: script_name
       path: your_category/script.sh
       description: Script description
   ```

### 运行

1. 构建镜像：
```bash
docker build -t kube-node-bundle .
```

2. 进入容器
```bash
docker run -it --rm \
      -v $(pwd):/app \
      -v ${HOME}/.kube:/root/.kube:ro \
      -v ${HOME}/.ssh:/root/.ssh:ro \
      kube-node-bundle
```
 3. 运行脚本
 ```bash
ansible-playbook playbooks/collect_node_info.yml
 ```

### 注意事项

1. 确保以下文件/目录存在且有正确权限：
   - `~/.kube/config`：kubectl 配置文件
   - `~/.ssh/`：SSH 密钥和配置

2. 如果使用密码认证，需要在运行容器时添加环境变量：
   ```bash
   docker run -it --rm \
       -v $(pwd):/app \
       -v ${HOME}/.kube:/root/.kube:ro \
       -v ${HOME}/.ssh:/root/.ssh:ro \
       -e ANSIBLE_HOST_KEY_CHECKING=False \
       -e ANSIBLE_SSH_PASS=your_password \
       kube-node-bundle
   ```

## 贡献指南

1. Fork 项目
2. 创建特性分支
3. 提交更改
4. 推送到分支
5. 创建 Pull Request

## 许可证

[License Name] - 查看 LICENSE 文件了解详情