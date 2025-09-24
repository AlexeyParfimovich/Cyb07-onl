#!/bin/bash

LASTNAME=${1:-"DefaultName"}

# 1. Создать папку с заданной фамилией
mkdir -p "$LASTNAME"

# 2. В папке создать текстовый файл infobez.txt и записать в него строку через перенаправление вывода
echo "27.11.23 10.1.1.2 ip addr" > "$LASTNAME/infobez.txt"

# 4. Извлечь подстроку "10.1.1.2" с помощью cut и сохранить в ip.txt
# Пояснения: 
# -d' ' — разделитель: пробел
# -f2 — взять второе поле (т.е. "10.1.1.2")
cut -d' ' -f2 "$LASTNAME/infobez.txt" > "$LASTNAME/ip.txt"

echo "Создана папка: $LASTNAME"
echo "IP сохранён в: $LASTNAME/ip.txt"