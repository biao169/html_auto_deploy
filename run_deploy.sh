#!/bin/bash
# 个人网站部署一键安装脚本 ubuntu/linux版本
# Author: biao

RED="\033[31m"      # Error message
GREEN="\033[32m"    # Success message
YELLOW="\033[33m"   # Warning message
BLUE="\033[36m"     # Info message
PLAIN='\033[0m'

Download_Path="/usr/"
Deploy_Path="/var/www/html/"
EXIST_Servie = "null"
Client="1"
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
    echo -e "#               ${RED}Ubuntu HTML 带伪装一键安装脚本${PLAIN}              #"
    echo -e "#                       ${GREEN}作者:${PLAIN} Kingbiu                       #"
    echo "-------------------------------------------------------------"
    echo -e "   ${YELLOW}This script requires the installation of:${PLAIN}"
    echo -e "    ${YELLOW}a) apache2 || nginx;  b) git;  c) expect (Maybe not)${PLAIN}"
    echo ""
    echo "#############################################################"
    echo ""
}

colorecho() {
    echo -e "${1}${@:2}${PLAIN}"
}


start_choice(){
    slogon
    if [ -x "$(command -v apache2)" ]; then
        EXIST_Servie="apache2"
    else
        echo "     No apache2."
    fi

    if [ -x "$(command -v nginx)" ]; then
        EXIST_Servie="nginx"
    else 
        echo "     No nginx."
    fi

    echo "Please select function:"
    if [ "$EXIST_Servie" == "apache2" ]; then
       echo  -e "   1: apache2   ${GREEN}(Is installed)${PLAIN}"
    else
        echo "   1: apache2"
    fi
    if [ "$EXIST_Servie" == "nginx" ]; then
        echo  -e "   2: nginx   ${GREEN}(Is installed)${PLAIN}"
    else
        echo "   2: nginx"
    fi
     echo "   3: restart service: ${EXIST_Servie}"

    read -p "Enter your selection [ 1 | 2 | 3 ]:" Client
    if [[ "$Client" == "1" || "$Client" == "2" || "$Client" == "3" ]]; then
        colorecho $YELLOW "Your choice is: $Client"
    else
        colorecho $RED "input ERROR!"
        read -p "Enter your selection again [ 1 | 2 | 3 ]:" Client
        colorecho $YELLOW "Your choice is: $Client"
        if [[ "$Client" == "1" || "$Client" == "2" || "$Client" == "3" ]]; then
           colorecho $YELLOW "Your choice is: $Client"
        else
           colorecho $RED "input ERROR!"
        fi
    fi
}


update_apt(){
    colorecho $BLUE "Updating system by [sudo apt update] ...  这里报错没关系的"
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
    if [ -x "$(command -v apache2)" ]; then
        colorecho $GREEN "Apache  had been installed."
    else
        colorecho $BLUE "Apache is not installed. Installing Apache..."
        # 2. 安装 Apache 服务器
        
        sudo apt install -y apache2
        # 检查安装结果
        if [ $? -eq 0 ]; then
            colorecho $GREEN "Apache2 installation successful."
        else
            colorecho $RED "Failed to install Apache2. Exiting..."
            exit 1
        fi
    fi
}
restart_Apache(){
    # 3. 启动 Apache 服务器
    sudo systemctl stop apache2
    # 检查安装结果
    if [ $? -eq 0 ]; then
        colorecho $GREEN "Apache2 stop successful."
    else
        colorecho $RED "Failed to stop Apache2."
        exit 1
    fi
    sudo systemctl start apache2
    if [ $? -eq 0 ]; then
        colorecho $GREEN "Apache2 start successful."
    else
        colorecho $RED "Failed to start Apache2."
        exit 1
    fi
}

install_Nginx(){
    # 检测 Nginx 服务器是否已安装
    if [ -x "$(command -v nginx)" ]; then
        colorecho $GREEN "Nginx had been installed."
    else
        colorecho $BLUE "Nginx is not installed. Installing Nginx ..."
        sudo apt install -y nginx
        
        # 检查安装结果
        if [ $? -eq 0 ]; then
            colorecho $GREEN "Nginx installation successful."
        else
            colorecho $RED "Failed to install Nginx. Exiting..."
            exit 1
        fi
    fi
}
restart_Nginx(){
    # 3. 启动 Nginx 服务器
    sudo systemctl stop nginx
    # 检查安装结果
    if [ $? -eq 0 ]; then
        colorecho $GREEN "Nginx stop successful."
    else
        colorecho $RED "Failed to stop Nginx."
        exit 1
    fi
    sudo systemctl start nginx
    if [ $? -eq 0 ]; then
        colorecho $GREEN "Nginx start successful."
    else
        colorecho $RED "Failed to start Nginx."
        exit 1
    fi
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
        colorecho $GREEN  "Git had been installed."
    fi
}

download_html_files(){
    echo "download at：${pwd}"
    # 克隆 GitHub 仓库到指定目录
    git clone https://github.com/biao169/html_auto_deploy.git

    # 检查克隆是否成功
    if [ $? -eq 0 ]; then
        colorecho $GREEN "html files download successful. in: ${pwd}"
    else
        colorecho $RED "网页文件下载失败，请检查仓库 URL 是否正确。"
        exit 1
    fi
}

move_html_files(){
     # 创建存放网页文件的目录
    # sudo mkdir "$Download_Path"

    echo "move：[$pwd/html_auto_deploy] to [$Download_Path]"
    # 1. 复制 HTML 文件和相关资源到部署目录
    sudo mv "html_auto_deploy/" "$Download_Path"

    echo "copy: [$Download_Path/html_auto_deploy/html_project/] to [$Deploy_Path]"
    sudo cp -r "$Download_Path/html_auto_deploy/html_project/." $Deploy_Path

    if [ "$Client" == "1" ]; then
        # 3. 启动 Apache 服务器
        restart_Apache
    elif [ "$Client" == "2" ]; then
        restart_Nginx
    fi
    # 检查是否成功
    if [ $? -eq 0 ]; then
        colorecho $GREEN "网页部署完成！."
    else
        colorecho $RED "网页部署失败！"
        exit 1
    fi
    echo "------------------------------------------------------"
    colorecho $YELLOW "HTML Project has been put into ${Deploy_Path}"
    colorecho $YELLOW "Git Project has been put into ${Download_Path}"
    echo "------------------------------------------------------"


}




# 执行部署步骤...
slogon
start_choice
# update_apt
if [ "$Client" == "1" ]; then
    # 3. 启动 Apache 服务器
    install_Apache
elif [ "$Client" == "2" ]; then
    install_Nginx
elif [ "$Client" == "3" ]; then
    if [ "$EXIST_Servie" == "apache2" ]; then
         # 3. 启动 Apache 服务器
        restart_Apache
    elif [ "$EXIST_Servie" == "nginx" ]; then
        restart_Nginx
    fi
else
    colorecho $RED "没有在个选项，${Client}"
    exit 1
fi
install_Git
download_html_files
move_html_files


# 3. 启动 Apache 服务器
# sudo systemctl start apache2
