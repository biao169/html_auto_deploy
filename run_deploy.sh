#!/bin/bash
# 个人网站部署一键安装脚本 ubuntu/linux版本
# Author: biao

RED="\033[31m"      # Error message
GREEN="\033[32m"    # Success message
YELLOW="\033[33m"   # Warning message
BLUE="\033[36m"     # Info message
PLAIN='\033[0m'

client = 1
checkSystem() {
    result=$(id | awk '{print $1}')
    if [ $result != "uid=0(root)" ]; then
        echo "请以root身份执行该脚本"
        exit 1
    fi

    res=`lsb_release -d | grep -i ubuntu`
    if [ "$?" != "0" ]; then
        res=`which apt`
        if [ "$?" != "0" ]; then
            echo "系统不是Ubuntu"
            exit 1
        fi
        res=`which systemctl`
         if [ "$?" != "0" ]; then
            echo "系统版本过低，请重装系统到高版本后再使用本脚本！"
            exit 1
         fi
    else
        result=`lsb_release -d | grep -oE "[0-9.]+"`
        main=${result%%.*}
        if [ $main -lt 16 ]; then
            echo "不受支持的Ubuntu版本"
            exit 1
        fi
     fi
}

slogon() {
    clear
    echo "#############################################################"
    echo -e "#              ${RED}Ubuntu LTS v2ray带伪装一键安装脚本${PLAIN}               #"
    echo -e "# ${GREEN}作者${PLAIN}: Kingbiu                                      #"
    echo "#############################################################"
    echo ""
}

colorecho() {
    echo -e "${1}${@:2}${PLAIN}"
}


update_apt(){
    # 先使用更新，避免后面终端需要管理密码
    sudo apt update
    # 使用 expect 命令自动输入密码并等待安装完成
    expect -c '
    spawn sudo apt-get install -y apache2
    expect "Password:"
    send "your-password\r"
    expect eof
    '
}

install_Apache(){
    # 检测 Apache 服务器是否已安装
    if [ $(which apache2) ]; then
        colorecho $GREEN "Apache  had been installed."
    else
        colorecho $BLUE "Apache is not installed. Installing Apache..."
        # 2. 安装 Apache 服务器
        
        sudo apt install apache2
        # 检查安装结果
        if [ $? -eq 0 ]; then
            colorecho $GREEN "Apache2 installation successful."
        else
            colorecho $RED "Failed to install Apache2. Exiting..."
            exit 1
        fi
    fi
    client = 1
}


install_Nginx(){
    # 检测 Nginx 服务器是否已安装
    if [ $(which nginx) ]; then
        colorecho $GREEN "Nginx had been installed."
    else
        colorecho $BLUE "Nginx is not installed. Installing Nginx ..."
        sudo apt install nginx
        
        # 检查安装结果
        if [ $? -eq 0 ]; then
            colorecho $GREEN "Nginx installation successful."
        else
            colorecho $RED "Failed to install Nginx. Exiting..."
            exit 1
        fi
    fi
    client = 2
}

install_Git(){
    # 检查是否已安装 Git
    if ! command -v git &> /dev/null; then
        colorecho $BLUE  "Git is not installed. Installing Git..."
        
        # 安装 Git
        # sudo apt-get update
        sudo apt-get install -y git
        
        # 检查安装结果
        if [ $? -eq 0 ]; then
            colorecho $GREEN "Git installation successful."
        else
            colorecho $RED "Failed to install Git. Exiting..."
            exit 1
        fi
    else

    fi
}

download_html_files(){
    # 创建存放网页文件的目录
    mkdir website

    # 克隆 GitHub 仓库到指定目录
    git clone https://github.com/your-username/your-repository.git website

    # 检查克隆是否成功
    if [ $? -eq 0 ]; then
        colorecho $GREEN "html files download successful."
    else
        colorecho $RED "网页文件下载失败，请检查仓库 URL 是否正确。"
    fi
}

move_html_files(){
    # 1. 复制 HTML 文件和相关资源到部署目录
    cp -r /path/to/your/html/files/* /var/www/html/

    if [client == 1]; then
        # 3. 启动 Apache 服务器
        sudo systemctl stop apache2
        sudo systemctl start apache2
    else
        sudo systemctl start nginx
        sudo systemctl stop nginx
    fi
    # 检查是否成功
    if [ $? -eq 0 ]; then
        colorecho $GREEN "网页部署完成！."
    else
        colorecho $RED "网页部署失败！"
    fi

}



# 继续执行部署步骤...





# 3. 启动 Apache 服务器
sudo systemctl start apache2