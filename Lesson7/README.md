# Cyb07-onl

## 7. Типы атак, часть 1 - OWASP top 10

### Дата и время занятия
Четверг, 2 Октябрь, 19:00-22:00

### Описание занятия
- Broken Access Control
- Cryptographic Failures
- Injection
- Insecure Design & Security Misconfiguration
- Vulnerable and Outdated Components
- Identification and Authentication Failures
- Software and Data Integrity Failures
- Server-Side Request Forgery (SSRF)
- SQl injection в Kali linux

### Учетная запись PortSwigger
https://portswigger.net
parfimovich@tut.by
AlexeyParfimovich
o949E2$8AsT2(LaJMnn79bf5t6WRc8NQ

### Домашнее задание
1. Пройти как можно больше заданий на ресурсе SQLBOLT

2. Выполнить 2 лабораторные работы из практики Brocken Access ControlBroken Access Control - Практика
• https://portswigger.net/web-security/access-control/lab-user-role-controlled-by-request-parameter

This lab has an admin panel at /admin, which identifies administrators using a forgeable cookie.
Solve the lab by accessing the admin panel and using it to delete the user carlos.
You can log in to your own account using the following credentials: wiener:peter

После успешной авторизации в тестовом приложении предоставленным пользователем (wiener), в куки всех последущих запросов к серверу начинает передваться параметр Admin типа bool. 
Задача решается подменой в передаваемых куки значения false параметра Admin на значение true (для всех запросов при обращении к серверу).


• https://portswigger.net/web-security/access-control/lab-user-id-controlled-by-request-parameter

This lab has a horizontal privilege escalation vulnerability on the user account page.
To solve the lab, obtain the API key for the user carlos and submit it as the solution.
You can log in to your own account using the following credentials: wiener:peter

После успешной аутентификации пользователя, в запросах к серверу передается параметр запроса "id", в котором передается значение логина текщего пользователя (wiener).
Задача решается перехватом запроса к серверу и подменой значение в ппараметре "id" На логин целевого пользователя (carlos).

Sec-Websocket-Key: qf5Dq3Z2GJJyYGnJGwaT/A==

3. Выполнить 1 лабораторную работу из практики Injections
• https://portswigger.net/web-security/sql-injection/lab-retrieve-hidden-data

Для экранирования кавычек в теле SQL запроса используются символы комментария "--"
Например для исходного знаачения фильтра filter?category=Gifts
строка с иньекцией - filter?category=Gifts'+or+1=1-- 


4. Выполнить 1 лабораторную работу из практики Server-Side Request Forgery
• https://portswigger.net/web-security/ssrf/lab-basic-ssrf-against-localhost

Используется запрос POST /product/stock для проверки наличия продукта на складе
В запросе передается параметр stockApi, котрорый содержит URL обращения к одному из складов
например http://stock.weliketoshop.net:8080/product/stock/check?productId=1&storeId=1

Решение задача состоит в эксплуатации этой уязвимости:
- Подменяем в запросе параметр stockApi адресом обращения к локальному ресурсу приложения - консоли админстратора http://localhost/admin
- В консоли администратора получаем ссылку на URL для удаления пользователя http://localhost/admin/delete?username=carlos
- Подставляем полученный URL в запрос /product/stock



5. sudo apt install docker.io – установить docker и развернуть в нём на Kali
JuicyShop
sudo docker pull bkimminich/juice-shop
sudo docker run -d -p 3000:3000 bkimminich/juice-shop
http://localhost:3000


Установка Docker в Kali Linux (актуально на 2025 год для Kali Rolling):

Шаг 1: Обновить систему
  sudo apt update && sudo apt upgrade -y

Шаг 2: Установить необходимые зависимости
  sudo apt install -y ca-certificates curl gnupg lsb-release

Шаг 3: Добавить официальный GPG-ключ Docker
  sudo mkdir -p /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

  Важно: Kali основан на Debian, поэтому необходимо использовать репозиторий Debian, а не Ubuntu. 

Шаг 4: Добавить репозиторий Docker
  echo \  
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian boolworm stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
 
 Примечание:
  команда для получения текщего релиза ОС $(lsb_release -cs) в Kali возвращает kali-rolling, но репозиторий Docker не знает такой ветки. Поэтому в команде используется bookworm (актуальный stable-релиз Debian на 2024–2025): 

Шаг 5: Обновить список пакетов
  sudo apt update

Шаг 6: Установить Docker Engine
  sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

Шаг 7: Запустить и включить службу Docker
  sudo systemctl enable --now docker
Проверить статус:
  sudo systemctl status docker
Проверить установку:
  sudo docker run hello-world

На экране должно отобразиться сообщение:
  Hello from Docker!
  This message shows your installation appears to be working correctly. 

Шаг 9: Запусить Docker без sudo (по умолчанию Docker требует sudo. Необходимо добавить пользователя в группу docker):
  sudo usermod -aG docker $USER
  
  + перезапустить сессию чтобы изменения вступили в силу. 


sudo docker pull bkimminich/juice-shop
sudo docker run -d -p 3000:3000 bkimminich/juice-shop
http://localhost:3000