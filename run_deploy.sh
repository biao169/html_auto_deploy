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
Project_Name="html_auto_deploy"
EXIST_Servie="null"
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
    echo -e "#                ${RED}Ubuntu HTML 一键安装部署脚本${PLAIN}                #"
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
    echo "--------" 
    if [ "$EXIST_Servie" == "null" ]; then
        echo "   1: restart service: [unknow]"
    else
        echo -e "   1: restart service: ${GREEN}${EXIST_Servie}${PLAIN}"
    fi
    echo "--------" 
    echo -e "   2: Modifying the configuration file: ${YELLOW}nginx.conf${PLAIN} [修改配置]"
    echo -e "   3: Restore configuration of: ${YELLOW}nginx.conf${PLAIN} [恢复配置]"
    echo "   4: show a correct configuration of nginx.conf [显示可用配置]"
    echo "--------  [ One-click install ]  ----------"
    if [ "$EXIST_Servie" == "apache2" ]; then
       echo  -e "   5: apache2   ${GREEN}(Is installed)${PLAIN}  [ One-click install ]"
    else
        echo "   5: apache2"
    fi
    if [ "$EXIST_Servie" == "nginx" ]; then
        echo  -e "   6: nginx   ${GREEN}(Is installed)${PLAIN}"
    else
        echo "   6: nginx"
    fi
    echo "--------" 
    echo "   7: uninstall all. [delete: html+python+tempFile]"
    
    echo ""

    read -p "Enter your selection: " Client
    # if [[ "$Client" == "1" || "$Client" == "2" || "$Client" == "3" || "$Client" == "3" ]]; then
    colorecho $YELLOW "Your choice is: $Client"
    # else
    #     colorecho $RED "input ERROR!"
    #     read -p "Enter your selection again:" Client
    #     colorecho $YELLOW "Your choice is: $Client"
    #     if [[ "$Client" == "1" || "$Client" == "2" || "$Client" == "3" ]]; then
    #        colorecho $YELLOW "Your choice is: $Client"
    #     else
    #        colorecho $RED "input ERROR!"
    #     fi
    # fi
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
    echo "download at path=${PWD}"
    # 克隆 GitHub 仓库到指定目录
    Project_Name="html_auto_deploy"
    sudo rm -rf "${Project_Name}"
    git clone https://github.com/biao169/html_auto_deploy.git

    # 检查克隆是否成功
    if [ $? -eq 0 ]; then
        colorecho $GREEN "html files download successful. in: ${PWD}"
    else
        colorecho $RED "网页文件下载失败，请检查仓库 URL 是否正确。"
        exit 1
    fi
}

move_html_files(){
     # 创建存放网页文件的目录
    # sudo mkdir "$Download_Path"

    echo "move：[$PWD/${Project_Name}] to [$Download_Path]"
    # 1. 复制 HTML 文件和相关资源到部署目录
    sudo rm -rf "$Download_Path/${Project_Name}"
    sudo mv "${Project_Name}/" "$Download_Path"

    echo "copy: [$Download_Path/${Project_Name}/html_project/] to [$Deploy_Path]"
    sudo cp -r "$Download_Path/${Project_Name}/html_project/." $Deploy_Path

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

show_successful_config_nginx(){
    Conf="user www-data;
        worker_processes auto;
        error_log /var/log/nginx/error.log;
        pid /run/nginx.pid;

        # Load dynamic modules. See /usr/share/doc/nginx/README.dynamic.
        include /usr/share/nginx/modules/*.conf;

        events {
            worker_connections 1024;
        }

        http {
            log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                            '$status $body_bytes_sent "$http_referer" '
                            '"$http_user_agent" "$http_x_forwarded_for"';

            access_log  /var/log/nginx/access.log  main;
            server_tokens off;

            sendfile            on;
            tcp_nopush          on;
            tcp_nodelay         on;
            keepalive_timeout   65;
            types_hash_max_size 2048;
            gzip                on;

            include             /etc/nginx/mime.types;
            default_type        application/octet-stream;

            # Load modular configuration files from the /etc/nginx/conf.d directory.
            # See http://nginx.org/en/docs/ngx_core_module.html#include
            # for more information.
            include /etc/nginx/conf.d/*.conf;
            server {
                listen 80 default_server;
                listen [::]:80 default_server;
                root /var/www/html;

                index index.html index.htm index.nginx-debian.html;

                server_name _;

                location / {
                        # First attempt to serve request as file, then
                        # as directory, then fall back to displaying a 404.
                        try_files $uri $uri/ =404;
                }
            }

        }
        "
    echo "${Conf}"
}

# 修改ngix的配置文件 一般路径在 /etc/nginx/nginx.conf
# 配置文件路径
Config_File="/etc/nginx/nginx.conf" 
set_conf_file_nginx(){

    Domain_url = "kingbiu.com"
    Choise_change="1"
    if [ -f "$Config_File" ]; then
        
        if grep -q "server_name" ${Config_File}; then
            read -p "已配置有服务器，是否修改[Yes:1 | No:0]" Choise_change
        fi
        if [ "$Choise_change" == "1" ]; then
            read -p "Enter your Domain URL: " Domain_url
            colorecho $YELLOW "你输入的网址/链接是：${Domain_url}"
        else
            colorecho $YELLOW "正在使用的域名/网址是：${Domain_url}"
        fi
    fi
    # root ${Download_Path}/${Project_Name}/html_project/;${new_row}\
      # 插入位置标记
    Insert_Marker="http {"
    new_row=$"\n\t"
    New_Conf="         # 新添加的内容从这开始 ${new_row}\
    server {${new_row}\
        listen 80;${new_row}\
        listen [::]:80;${new_row}\
${new_row}\
        server_name ${Domain_url};${new_row}\
${new_row}\
        root ${Deploy_Path};${new_row}\
        index index.html;${new_row}\
${new_row}\
        location / {${new_row}\
                try_files \$uri \$uri/ =404;${new_row}\
        }${new_row}\
    }${new_row}    # 新添加的内容到此结束 ${new_row}\
    "

    # 检查配置文件是否存在
    if [ -f "$Config_File" ]; then
        if grep -q "server_name" ${Config_File}; then
            echo "配置已添加过，不能重复添加。"
            if [ "$Choise_change" == "1" ]; then
                colorecho $RED "nginx已被配置过，请使用命令[vim ${Confile_File}]手动修改文件！"
            fi
        else
            # echo "目标字符不存在"

            sudo chmod 777 ${Config_File}
            # 检查安装结果
            if [ $? -eq 0 ]; then
                # colorecho $RED "可手动修改权限后重试，可使用命令: \"sudo chmod 777 ${Config_File}\"."
                echo "配置文件：[ ${Config_File} ] 修改权限：可写入"
            else
                colorecho $RED "可手动修改权限后重试，可使用命令: \"sudo chmod 777 ${Config_File}\"."
                exit 1
            fi

            # 在配置文件末尾追加新配置
            # echo "$New_Conf" | sudo tee -a "$Config_File" >/dev/null
            # echo "已成功添加新配置到 $Config_File"
            # 在配置文件中查找插入位置标记，并在其后插入新配置
            sudo sed -i.backup "/${Insert_Marker}/a${New_Conf}" ${Config_File}
            if [ $? -eq 0 ]; then
                echo "已成功插入新配置到 ${Config_File}"
            else
                echo "插入失败: $Config_File"
                exit 1
            fi
            echo "原配置备份在: ${Config_File}.backup"
        fi 
    else
        echo "配置文件 ${Config_File} 不存在"
    fi
}

reset_conf_file_nginx(){
    sudo rm -f ${Config_File}
    if [ $? -eq 0 ]; then
        echo "删除配置 ${Config_File}"
    else
        echo "删除失败: $Config_File，请手动删除，可执行指令：[ sudo rm -f ${Config_File} ] "
        exit 1
    fi
    sudo mv "${Config_File}.backup" ${Config_File}
    if [ $? -eq 0 ]; then
        echo "恢复配置: ${Config_File}.backup --> ${Config_File}"
    else
        echo "恢复失败: $Config_File，请恢复，可执行指令：[ sudo mv ${Config_File}.backup ${Config_File} ] "
        exit 1
    fi
}


uninstall(){
    colorecho $YELLOW"removeing: $Deploy_Path"
    sudo rm -rf "$Deploy_Path"

    colorecho $YELLOW"removeing: $Download_Path/${Project_Name}"
    sudo rm -rf "$Download_Path/${Project_Name}"
    
    reset_conf_file_nginx
    restart_Nginx
}

# 执行部署步骤...
slogon
start_choice
# update_apt

if [ "$Client" == "1" ]; then
    if [ "$EXIST_Servie" == "apache2" ]; then
         # 3. 启动 Apache 服务器
        restart_Apache
    elif [ "$EXIST_Servie" == "nginx" ]; then
        restart_Nginx
    fi
elif [ "$Client" == "2" ]; then
    if [ "$EXIST_Servie" == "apache2" ]; then
        echo " ${EXIST_Servie}.conf: finish by yourself! "
    elif [ "$EXIST_Servie" == "nginx" ]; then
        set_conf_file_nginx
    fi 
elif [ "$Client" == "3" ]; then
    if [ "$EXIST_Servie" == "apache2" ]; then
        echo " ${EXIST_Servie}.conf: finish by yourself! "
    elif [ "$EXIST_Servie" == "nginx" ]; then
        reset_conf_file_nginx
    fi     
elif [ "$Client" == "4" ]; then
    show_successful_config_nginx

elif [ "$Client" == "5" ]; then
    # 3. 启动 Apache 服务器
    install_Apache
    install_Git
    download_html_files
    move_html_files
    restart_Apache
elif [ "$Client" == "6" ]; then
    install_Nginx
    install_Git
    download_html_files
    move_html_files
    set_conf_file_nginx
    restart_Nginx
else
    colorecho $RED "没有在个选项，${Client}"
    exit 1
fi



# 3. 启动 Apache 服务器
# sudo systemctl start apache2
