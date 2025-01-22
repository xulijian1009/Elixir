#!/bin/bash

# color
CYAN='\033[0;36m'
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RESET='\033[0m'

# 检查是否以root用户运行脚本
if [ "$(id -u)" != "0" ]; then
    echo "脚本需 root 用户权限运行。"
    echo "使用 'sudo -i' 命令切换到 root 用户然后再次运行此脚本。"
    exit 1
fi

# 脚本保存路径
SCRIPT_PATH="$HOME/elixir.sh"

# 检查并安装Docker
function check_and_install_docker() {
    if ! command -v docker &> /dev/null; then
        echo "未检测到 Docker，正在安装..."
        sudo apt-get update
        sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
        sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
        sudo apt-get update
        sudo apt-get install -y docker-ce
        echo "Docker 已安装。"
    else
        echo "Docker 已安装，请下方提示输入内容。"
    fi
}

# 主网节点安装
function install_node() {
    check_and_install_docker

    # 提示用户输入环境变量的值
    read -p "输入验证者节点的显示名称: " validator_name
    read -p "输入验证者节点的奖励收取地址: " public_address
    read -p "输入签名者私钥，无需 0x: " private_key

    # 将环境变量保存到 validator.env 文件
    cat <<EOF > validator.env
ENV=prod

STRATEGY_EXECUTOR_IP_ADDRESS=${ip_address}
STRATEGY_EXECUTOR_DISPLAY_NAME=${validator_name}
STRATEGY_EXECUTOR_BENEFICIARY=${public_address}
SIGNER_PRIVATE_KEY=${private_key}
EOF

    echo "环境变量已设置并保存到 validator.env 文件。"

    # 拉取 Docker 镜像
    docker pull elixirprotocol/validator

    # 提示用户选择平台
    read -p "是否在 Apple/ARM 架构上运行？(y/n): " is_arm

    if [[ "$is_arm" == "y" ]]; then
        # 在 Apple/ARM 架构上运行
        docker run -it -d \
          --env-file validator.env \
          --name elixir \
          --platform linux/amd64 \
          --restart unless-stopped \
          elixirprotocol/validator
    else
        # 默认运行
        docker run -it -d \
          --env-file validator.env \
          --name elixir \
          --restart unless-stopped \
          elixirprotocol/validator
    fi

        # 操作完成后返回主菜单
        echo "主网节点安装完成。即将返回主菜单..."
        sleep 2
        display_main_menu
}

# 查看 Docker 日志功能
function check_docker_logs() {
    echo "查看 Elixir Docker 容器的日志..."
    docker logs -f --tail=50 elixir
}

# 删除 Docker 容器功能
function delete_docker_container() {
    echo "正在删除 Elixir Docker 容器，预计时间 30s..."
    docker stop elixir
    docker rm elixir
    echo "Elixir Docker 容器已删除。"
}

# 测试节点安装
function install_testnet_node() {
    check_and_install_docker

    # 提示用户输入环境变量的值
    read -p "输入验证者测试节点的显示名称: " validator_name
    read -p "输入验证者测试节点的奖励收取地址: " public_address
    read -p "输入私钥，无需0x: " private_key

    # 将环境变量保存到 test_validator.env 文件
    cat <<EOF > test_validator.env
ENV=testnet

STRATEGY_EXECUTOR_DISPLAY_NAME=${validator_name}
STRATEGY_EXECUTOR_BENEFICIARY=${public_address}
SIGNER_PRIVATE_KEY=${private_key}
EOF

    echo "环境变量已设置并保存到 test_validator.env 文件。"

    # 拉取 Docker 镜像
    docker pull elixirprotocol/validator:testnet

    # 提示用户选择平台
    read -p "是否在 Apple/ARM 架构上运行？(y/n): " is_arm

    if [[ "$is_arm" == "y" ]]; then
        # 在 Apple/ARM 架构上运行
        docker run -it -d \
          --env-file test_validator.env \
          --name elixir-test \
          --platform linux/amd64 \
          --restart unless-stopped \
          elixirprotocol/validator:testnet
    else
        # 默认运行
        docker run -it -d \
          --env-file test_validator.env \
          --name elixir-test \
          --restart unless-stopped \
          elixirprotocol/validator:testnet
    fi

        # 操作完成后返回主菜单
        echo "测试节点安装完成。即将返回主菜单..."
        sleep 2
        display_main_menu

}

# 查看 Docker 日志功能
function check_docker_test_logs() {
    echo "查看 Elixir Docker 容器的日志..."
    docker logs -f --tail=50 elixir-test
}

# 删除 Docker 容器功能
function delete_docker_test_container() {
    echo "正在删除 Elixir Docker 容器，预计时间 30s..."
    docker stop elixir-test
    docker rm elixir-test
    echo "Elixir Docker 容器已删除。"
}

# 主菜单
function display_main_menu() {
    clear
    echo -e ""
    echo -e '\033[0;32m'
    echo -e ' █████╗ ██╗      ██████╗██╗  ██╗███████╗███╗   ███╗██╗   ██╗███████╗██╗███╗   ██╗ █████╗ ███╗   ██╗ ██████╗███████╗'
    echo -e '██╔══██╗██║     ██╔════╝██║  ██║██╔════╝████╗ ████║╚██╗ ██╔╝██╔════╝██║████╗  ██║██╔══██╗████╗  ██║██╔════╝██╔════╝'
    echo -e '███████║██║     ██║     ███████║█████╗  ██╔████╔██║ ╚████╔╝ █████╗  ██║██╔██╗ ██║███████║██╔██╗ ██║██║     █████╗  '
    echo -e '██╔══██║██║     ██║     ██╔══██║██╔══╝  ██║╚██╔╝██║  ╚██╔╝  ██╔══╝  ██║██║╚██╗██║██╔══██║██║╚██╗██║██║     ██╔══╝  '
    echo -e '██║  ██║███████╗╚██████╗██║  ██║███████╗██║ ╚═╝ ██║   ██║   ██║     ██║██║ ╚████║██║  ██║██║ ╚████║╚██████╗███████╗'
    echo -e '╚═╝  ╚═╝╚══════╝ ╚═════╝╚═╝  ╚═╝╚══════╝╚═╝     ╚═╝   ╚═╝   ╚═╝     ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝╚═╝  ╚═══╝ ╚═════╝╚══════╝'
    echo -e '\033[0m'
    echo -e ""
    echo ""
    echo -e "${BLUE}===================== Elixir 节点安装=========================${RESET}"
    echo ""
    echo "请选择要执行的操作："
    echo "1. 安装 Elixir 主网节点"
    echo "2. 查看主网日志"
    echo "3. 删除主网容器"
    echo "4. 安装 Elixir 测试节点"
    echo "5. 查看测试节点日志"
    echo "6. 删除测试节点容器"
    echo "0. 退出"
    read -p "请输入选项（0-4）: " OPTION

    case $OPTION in
    1) install_node ;;
    2) check_docker_logs ;;
    3) delete_docker_container ;;
    4) install_testnet_node ;;
    5) check_docker_test_logs ;;
    6) delete_docker_test_container ;;
    0) exit 0 ;;
    *) echo "无效的选项，请输入 0-6 之间的数字。" ;;
    esac
}

# 显示主菜单
while true; do
    display_main_menu
done
