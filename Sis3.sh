#!/bin/bash



echo "Установка пакетов и их обновление"

sudo apt update
sudo apt install ufw net-tools iputils-ping python3-venv postgresql-client nginx python3 python3-pip -y

echo "Установка пакетов завершена"

echo "НАстройка файрвола"

sudo ufw default deny incoming 
sudo ufw default allow outgoing 

sudo ufw allow ssh 
sudo ufw allow http 
sudo ufw allow https 

sudo ufw enable

echo "Файрвол настроен, разрешены порты ссх(22) хттп(80) хттпс(443)"

echo "Смок тест начало"

echo "Сетевой доступ"

ping -c 3 google.com
if [ $? -eq 0 ]; then
    echo "  [ОК] Сетевой доступ и утилита ping работают"
else
    echo "  [ОШИБКА] Нет сетевого доступа или ping не работают"
fi

echo "///////////////////////////////////////"

echo "Проверка статуса ufw"
if sudo ufw status | grep -q "active"; then
    echo "  [ОК] Фаервол ufw активен"
else
    echo "  [ОШИБКА] Фаервол ufw не активен"
fi

echo "///////////////////////////////////////"

echo "Проверка пайтон и пип"

python3 -V

if [ $? -eq 0 ]; then
    echo "  [ОК] Python установлен и доступeн"
    pip3 -V
    if [ $? -eq 0 ]; then
        echo "  [ОК] Pip установлен и доступeн"
    else
        echo "  [ОШИБКА] Pip не найден."
    fi
else
    echo "  [ОШИБКА] Python не найден."
fi

echo "Конец мучений с ви едитором и конец смок теста"









