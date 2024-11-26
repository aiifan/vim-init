#!/usr/bin/env bash
# 给所有用户添加 Vim 配置，仅在欧拉系统测试

# 获取当前时间
cut_time=$(date +"%Y%m%d%H%M%S")

# 获取当前路径
cut_path=$(dirname "$(realpath "$0")")
init_vim_file=$cut_path/init.vim

# 判断目录是否存在，不存在则创建
exist_path(){
    if [[ ! -d $1 ]]; then
        mkdir -p $1
    fi
}

# 判断文件是否存在，存在则备份
exist_file() {
    if [[ -f $1 ]]; then
        mv $1 $1.$cut_time.bak
    fi
}

mod_permission(){
    if [[ -f $1 ]]; then
        chown $2:$3 $1
        chmod 644 $1
    elif [[ -d $1 ]]; then
        chown $2:$3 $1
        chmod 755 $1
    else
        echo "$1 既不是文件也不是文件夹，请确认输入信息"
    fi
}

# 查找所有存在家目录并且能够登录的用户和用户组
users=$(awk -F: '($7 ~ /(bash|sh|zsh|ksh)$/) {print $1":"$4":"$6}' /etc/passwd)
user_array=($users)

# 遍历用户数组
for element in "${user_array[@]}"; do 
    user=$(echo $element | cut -d: -f1)
    group_id=$(echo $element | cut -d: -f2)
    home_dir=$(echo $element | cut -d: -f3)
    group_name=$(getent group $group_id | cut -d: -f1)
    
    vimrc_path=$home_dir/.vim/
    vimrc_file=$vimrc_path/vimrc
    exist_path $vimrc_path
    exist_file $vimrc_file
    echo -e "source $init_vim_file" > $vimrc_file
    mod_permission $vimrc_path $user $group_name
    mod_permission $vimrc_file $user $group_name
done

# 处理 root 用户
exist_path /root/.vim
exist_file /root/.vim/vimrc
echo -e "source $init_vim_file" > /root/.vim/vimrc
mod_permission /root/.vim root root
mod_permission /root/.vim/vimrc root root
