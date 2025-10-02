#!/bin/bash
# Скрипт должен запускаться от имени пользователя с правами sudo!

# 1. Создание групп 
echo "1. Создание групп..."
sudo groupadd sys_admin_group
sudo groupadd dev_ops_group
sudo groupadd auditor_group
sudo groupadd app_user_group
sudo groupadd pg_user_group

# 2. Создание пользователей
echo "2. Создание пользователей..."
# sys_admin, auditor humans
sudo adduser sys_admin --ingroup sys_admin_group
sudo adduser auditor --ingroup auditor_group

# dev_ops
sudo useradd -r -s /bin/bash -g dev_ops_group dev_ops
# app_user, postgres (служебные, 
sudo useradd -r -s /bin/false -g app_user_group app_user
sudo useradd -r -s /bin/false -g pg_user_group postgres

# Создание домашнего каталога для dev_ops
echo "Создание домашнего каталога для dev_ops (для SSH)"
sudo mkdir /home/dev_ops
sudo chown -R dev_ops:dev_ops_group /home/dev_ops
sudo chmod 700 /home/dev_ops

# 3. Установка Docker 
echo "3. Установка Docker Engine..."
# Установка lsb-release и прочих пакетов
sudo apt update
sudo apt install ca-certificates curl gnupg lsb-release -y

# Настройка репозитория (автоматически определяет кодовое имя Ubuntu)
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
UBUNTU_CODENAME=$(grep ^[[:space:]]*deb /etc/apt/sources.list.d/* | grep -i ubuntu | head -n 1 | awk '{print $3}')
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $UBUNTU_CODENAME stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Финальная установка Docker Engine
sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

# 4. Настройка прав 

# 4.1. Настройка Sudoers 
echo "4.1. Настройка Sudoers (добавление правил для групп)"
# добавляем нужные строки в конец файла /etc/sudoers
echo "%sys_admin_group ALL=(ALL) NOPASSWD: ALL" | sudo tee -a /etc/sudoers
echo "%auditor_group ALL=(ALL) NOPASSWD: /usr/bin/systemctl status *, /usr/bin/journalctl *" | sudo tee -a /etc/sudoers

# 4.2. Настройка прав для dev_ops (добавление в группу docker)
echo "4.2. Настройка прав для dev_ops"
sudo usermod -aG docker dev_ops

# 4.3. Настройка каталога проекта (dev_ops)
sudo mkdir -p /opt/budget_tracker
sudo chown dev_ops:dev_ops_group /opt/budget_tracker
sudo chmod 770 /opt/budget_tracker

# 4.4. Настройка каталога логов (auditor)
sudo mkdir -p /var/log/budget_tracker
sudo chown root:auditor_group /var/log/budget_tracker
sudo chmod 770 /var/log/budget_tracker

echo "Настройка пользователей и прав завершена. Не забудьте вручную настроить SSH-ключи!"
