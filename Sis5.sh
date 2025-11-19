#!/bin/bash

systemd_service_name="budget-tracker.service"
REPO_URL="https://github.com/mozgbolitochen/budget_tracker_devops.git"
REPO_DIR="budget_tracker_devops"
PLAYBOOK="setup.yml"


if ! command -v ansible &> /dev/null; then
    echo "Ansible не найден. Установка..."
    sudo apt update
    sudo apt install ansible -y
fi

echo ":D Запуск Ansible Playbook :D"
ansible-playbook -i inventory.ini "$PLAYBOOK"

if [ $? -ne 0 ]; then
    echo "[ОШИБКА D:] Ansible Playbook завершился с ошибкой."
    exit 1
fi

echo "Смок тест начало"
f=0

echo "Сетевой доступ"

ping -c 3 google.com > /dev/null 2>&1

ping -c 3 google.com
if [ $? -eq 0 ]; then
    echo "  [ОК :D] Сетевой доступ и утилита ping работают"
else
    echo "  [ОШИБКА D:] Нет сетевого доступа или ping не работают"
    f=1
fi

echo "///////////////////////////////////////"

echo "Проверка статуса ufw"

if sudo ufw status | grep -q "active"; then
    echo "[ОК :D] Фаервол ufw активен."
else
    echo "[ОШИБКА D:] Фаервол ufw не активен."
    f=1
fi

echo "///////////////////////////////////////"

echo "Проверка пайтон и пип"

python3 -V

if [ $? -eq 0 ]; then
    echo "  [ОК :D] Python установлен и доступeн"
    pip3 -V
    if [ $? -eq 0 ]; then
        echo "  [ОК :D] Pip установлен и доступeн"
    else
        echo "  [ОШИБКА D:] Pip не найден."
	f=1
    fi
else
    echo "  [ОШИБКА D:] Python не найден."
    f=1
fi

echo "///////////////////////////////////////"

echo "Проверка Докер"

if sudo systemctl is-active "$systemd_service_name" &> /dev/null; then
    echo "[ОК] Сервис $systemd_service_name активен."
else
    echo "[ОШИБКА] Сервис $systemd_service_name не активен."
    f=1
fi


echo ":D Результаты  D:"
if [ $f -ne 0 ]; then
    echo "[D:] Один или несколько тестов не пройдены."
    exit 1
else
    echo "[:D] Все тесты пройдены! Система настроена."
fi
