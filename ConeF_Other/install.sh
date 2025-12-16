#!/bin/bash

# 检测操作系统
detect_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$ID
        OS_LIKE=$ID_LIKE
    elif [ -f /etc/debian_version ]; then
        OS="debian"
    elif [ -f /etc/redhat-release ]; then
        OS="rhel"
    else
        OS=$(uname -s)
    fi
    echo "检测到操作系统: $OS"
}

# 检查是否为root用户
check_root() {
    if [ "$EUID" -ne 0 ]; then
        echo "错误: 请使用root权限运行此脚本"
        exit 1
    fi
}

# 检查是否支持apt包管理器
check_apt_support() {
    if ! command -v apt &> /dev/null; then
        echo "错误: 此脚本仅支持使用apt包管理器的系统 (Debian/Ubuntu等)"
        exit 1
    fi
}

# 配置UFW防火墙
configure_ufw() {
    echo "正在更新软件包列表并安装ufw..."
    apt update && apt install -y ufw

    echo "配置防火墙规则..."
    ufw allow 22/tcp comment 'SSH'
    ufw allow 1213/tcp comment 'app 1213 tcp'
    ufw allow 1415/udp comment 'app 1415 udp'
    ufw allow 1514/udp comment 'app 1514 udp'

    echo "设置默认策略..."
    ufw default deny incoming
    ufw default allow outgoing

    echo "启用UFW防火墙..."
    ufw --force enable

    echo "设置UFW开机自启..."
    systemctl enable ufw

    echo "防火墙状态:"
    ufw status verbose
}

# 主函数
main() {
    check_root
    detect_os
    check_apt_support
    configure_ufw
    echo "防火墙配置完成!"
}

main
