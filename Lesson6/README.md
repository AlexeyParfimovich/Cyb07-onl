# Cyb07-onl

## 6. Криптография.

### Дата и время занятия
Четверг, 25 Сентябрь, 19:00-22:00

### Описание занятия
- Откуда пошло шифрование
- Как строится ассиметричное шифрование, метод Диффи-Хельмана
- SHA, DES, SSL, TLS. Чем хэширование отличается от шифрования
- HTTP и HTTPS
- Организации, выпускающие сертификаты
- Практика шифрования диска ПК

### Домашнее задание

#### 1. Создать пару ключей SSH на Kali Linux, 
экспортировать открытый ключ на сервер Ubuntu Server. Настроить конфиг SSH для аутентификации по ключам. Выполнить подключение SSH по ключу, сохранить скрин экрана, после чего удалить соданные SSH ключи на ВМ Kali и Ubuntu.

##### Шаг 1: Создание SSH-пары ключей на Kali Linux
Открыть терминал на Kali Linux и выполнить:
  ssh-keygen -t ed25519 -C "parfimovich@tut.by"
Примечание: 
  -t ed25519 — современный и безопасный алгоритм шифрования, если система не поддерживает ed25519, использовать -t rsa -b 4096.
В процессе генерации:
  Нажать Enter, чтобы принять путь по умолчанию (~/.ssh/id_ed25519).
  При необходимости задать парольную фразу (passphrase) для дополнительной защиты (рекомендуется).
В результате будут созданы два файла:
  Приватный ключ: ~/.ssh/id_ed25519
  Публичный ключ: ~/.ssh/id_ed25519.pub

##### Шаг 2: Копирование публичного ключа на сервер Ubuntu
Основной способ — использовать ssh-copy-id:
  ssh-copy-id -i ~/.ssh/id_ed25519.pub user@192.168.2.100
Где: 
  username — имя пользователя на Ubuntu-сервере (например user)
  ip_адрес_сервера — IP-адрес или доменное имя сервера

Если ssh-copy-id недоступен в системе, можно вручную скопировать ключ:
  cat ~/.ssh/id_ed25519.pub | ssh username@ip_адрес_сервера "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys"
Установить права доступа на сервере (если существующие не корректны):
  ssh username@ip_адрес_сервера "chmod 700 ~/.ssh && chmod 600 ~/.ssh/authorized_keys"

##### Шаг 3: Настройка SSH-сервера на Ubuntu
Подключиться к серверу Ubuntu:
  ssh user@192.168.2.100

Открыть конфигурационный файл SSH-демона:
  sudo nano /etc/ssh/sshd_config
Убедиться, что следующие параметры заданы:
  PubkeyAuthentication yes
  AuthorizedKeysFile .ssh/authorized_keys
  PasswordAuthentication no        # отключить вход по паролю (только после проверки ключа!)

Важно: Не отключать PasswordAuthentication, пока не убедитесь, что вход по ключу работает! 

Перезапусть SSH-сервис:
  sudo systemctl restart sshd

##### Шаг 4: Проверка подключения
С ВМ Kali выполнить подключение к ВМ Ubuntu:
  ssh username@ip_адрес_сервера
Если была задана passphrase при создании ключа — необходимо ввести её.
Если всё было настроено верно — выполнится вход без пароля (или только с passphrase от ключа).

##### Дополнительно: Настройка ~/.ssh/config (для удобства использования)
Чтобы не вводить каждый раз IP и имя пользователя, создать файл конфигурации:
  nano ~/.ssh/config
Добавить:
  Host myserver
    HostName ip_адрес_сервера
    User username
    IdentityFile ~/.ssh/id_ed25519

Теперь можно выполнять подключения:
  ssh myserver

##### Безопасность:
  - Никогда не передавайте приватный ключ (id_ed25519) третьим лицам.
  - Храните его в надёжном месте с правами 600:
      chmod 600 ~/.ssh/id_ed25519
  - Регулярно обновляйте ключи и отслеживайте доступ.


#### 2. Установить 2FA с TOTP токеном на Ubuntu Server.
Выполнить конфигурацию и выдачу токена пользователю. Подключиться с ВМ Kali на ВМ Ubuntu с использованием TOTP, сделать скрин экрана.

##### Часть 1: Установка и настройка 2FA на Ubuntu-сервере

1. Обновить систему
  sudo apt update && sudo apt upgrade -y

2. Установить libpam-google-authenticator
  sudo apt install libpam-google-authenticator -y

Примечание: этот пакет не отправляет данные в Google — он просто реализует стандарт TOTP (RFC 6238) и совместим с любыми TOTP-приложениями (Google Authenticator, Authy, Microsoft Authenticator, FreeOTP и др.). 

3. Запустить генератор TOTP для пользователя
Выполните от имени пользователя, для которого настраивается 2FA (не от root!):
  google-authenticator
  
  Далее будут заданы вопросы. Рекомендуемые ответы:
  - Do you want authentication tokens to be time-based (y/n)? → y
    → Появится QR-код, секретный ключ и список одноразовых аварийных кодов (emergency scratch codes).
  - Do you want me to update your "~/.google_authenticator" file? → y
  - Do you want to disallow multiple uses of the same authentication token? → y
  - By default, tokens are good for 30 seconds... Do you want to increase the window? → n
  - If the computer time is ever more than 1 minute off... Do you want to do so? → y

  Обязательно сохраните: 
    QR-код (сфотографируйте или скопируйте)
    Секретный ключ (на случай, если не сможете отсканировать QR)
    5 аварийных кодов (храните в надёжном месте — они одноразовые и нужны при потере телефона)
  
  Файл ~/.google_authenticator будет создан автоматически с правильными правами.

4. Настройка PAM для использования 2FA
Открыть файл PAM для SSH:
  sudo nano /etc/pam.d/sshd

Добавить в начало файла (или сразу после @include common-auth):
  auth required pam_google_authenticator.so
!Не удалять существующие строки — только добавить эту. 

5. Настройка SSH-демона
Открыть файл конфигурации SSH:
  sudo nano /etc/ssh/sshd_config

Убедиться, что включены следующие параметры:
  ChallengeResponseAuthentication (или KbdInteractiveAuthentication) yes
  AuthenticationMethods keyboard-interactive:pam,publickey
  UsePAM yes

Пояснения: 
  AuthenticationMethods требует и ключ, и 2FA, если вы используете ключи.
  Если вы хотите только пароль + 2FA, используйте:
    AuthenticationMethods keyboard-interactive:pam
    PasswordAuthentication yes

Рекомендуется оставить аутентификацию по ключу + 2FA для максимальной безопасности. 

6. Перезапусть SSH
  sudo systemctl restart ssh


##### Часть 2: Настройка TOTP-приложения на клиенте
Установите TOTP-приложение на смартфон:
  - Google Authenticator (Android/iOS) или Microsoft Authenticator
  - Открыть приложение → «Добавить аккаунт» → «Сканировать QR-код».
  - Отсканировать QR-код, показанный на сервере при запуске google-authenticator,
    или вручную ввести секретный ключ и указать тип «Time-based». 

Теперь приложение будет генерировать 6-значные коды каждые 30 секунд.

##### Часть 3: Подключение с удалённой машины
Вариант A (Если используется только пароль + 2FA):
  ssh username@ip_адрес_сервера
Система запросит:
  - Пароль пользователя
  - TOTP-код из приложения

Вариант B (Если используется SSH-ключ + 2FA):
  ssh username@ip_адрес_сервера
Если ключ настроен — система не запросит пароль, но запросит TOTP-код:
  Verification code: ввести 6-значный код из приложения.

Важно убедиться, что время на сервере и на телефоне синхронизировано (используйте NTP). 

Советы и устранение неполадок:
  1. Проверить время на сервере:
    sudo timedatectl set-ntp on
  2. Если не работает — проверьте логи: 
    sudo tail -f /var/log/auth.log
  3. Временное отключение 2FA (если что-то пошло не так):
    - Подключься через консоль (не по SSH!)
    - Закомментировать строку в /etc/pam.d/sshd
      или временно измените AuthenticationMethods на publickey или password
  4. Резервные коды
    - Использовать один из 5 аварийных кодов вместо TOTP, если потеряли доступ к приложению.

Теперь Ubuntu-сервер защищён двухфакторной аутентификацией:
  - Пользователь должен предоставить SSH-ключ (или пароль) + TOTP-код.
  - Подключение с удалённой машины требует живого кода из приложения.
  - Безопасность значительно повышена даже при утечке пароля или ключа.

Важно: всегда тестируйте подключение до закрытия текущей сессии, чтобы не остаться без доступа! 


#### 3. На сервере Ubuntu развернуть и настроить ftp сервер(vsftpd).
Подключиться к FTP серверу с ВМ Kali и отправить туда любой файл, сохранить скрин об успешной отправке файла.

##### Шаг 1: Обновление системы
  sudo apt update && sudo apt upgrade -y

##### Шаг 2: Установка vsftpd
  sudo apt install vsftpd -y

##### Шаг 3: Резервное копирование конфигурации
  sudo cp /etc/vsftpd.conf /etc/vsftpd.conf.bak

##### Шаг 4: Базовая настройка vsftpd
Открыть основной конфигурационный файл:
  sudo nano /etc/vsftpd.conf
  Рекомендуемые параметры (для локальных пользователей с шифрованием):
  local_enable=YES  # Разрешить локальных пользователей
  write_enable=YES  # Разрешить запись (загрузку файлов)
  chroot_local_user=YES # Ограничить пользователей в их домашних каталогах (chroot)
  allow_writeable_chroot=YES  # Запретить выход из домашнего каталога
  pasv_enable=YES # Включить пассивный режим (если нужен доступ извне)
  pasv_min_port=40000
  pasv_max_port=50000
  anonymous_enable=NO # Отключить анонимный доступ
  xferlog_enable=YES  # Включить логирование
  xferlog_file=/var/log/vsftpd.log
  utf8_filesystem=YES # Использовать UTF-8
  require_ssl_reuse=NO  # Безопасность
  ssl_enable=YES
  allow_anon_ssl=NO
  force_local_data_ssl=YES
  force_local_logins_ssl=YES
  rsa_cert_file=/etc/ssl/certs/ssl-cert-snakeoil.pem
  rsa_private_key_file=/etc/ssl/private/ssl-cert-snakeoil.key
  
Примечание: Если вы не используете SSL, можно отключить ssl_enable=YES и связанные с ним параметры, но это не рекомендуется из соображений безопасности. 

##### Шаг 5: Настройка SSL (опционально)
Если используется самоподписанный сертификат (как в примере выше) то он уже установлен с пакетом ssl-cert. 
Если нужно использовать свой сертификат — указать пути к нему в rsa_cert_file и rsa_private_key_file.

##### Шаг 6: Создание FTP-пользователя (опционально)
Если нельзя использовать существующих пользователей системы:
  sudo adduser ftpuser
  
  - Задайте пароль и пропустите остальные поля (нажимайте Enter).
  - Убедитесь, что у пользователя есть домашний каталог и права на запись.

##### Шаг 7: Настройка прав доступа
Если используется chroot_local_user=YES - необходимо убедиться, что домашний каталог не имеет прав на запись для владельца (это требование безопасности vsftpd). Но это конфликтует с параметром allow_writeable_chroot=YES.
Если был включен параметр allow_writeable_chroot=YES, то можно оставить права как есть:
  sudo chmod 755 /home/ftpuser

или создать подкаталог для загрузки:
  sudo mkdir /home/ftpuser/upload
  sudo chown ftpuser:ftpuser /home/ftpuser/upload

##### Шаг 8: Перезапуск службы
  sudo systemctl restart vsftpd
  sudo systemctl enable vsftpd  # автозапуск при загрузке

  Проверить статус службы:
  sudo systemctl status vsftpd

##### Шаг 9: Настройка брандмауэра (UFW)
Если включён UFW:
  sudo ufw allow 20:21/tcp
  sudo ufw allow 40000:50000/tcp  # для пассивного режима

##### Шаг 10: Тестирование подключения
С локальной машины:
  ftp localhost

или с удалённой машины (замените your_server_ip):
  ftp your_server_ip

Если при подключении вы получили ошибку:
  500 OOPS: vsftpd: refusing to run with writable root inside chroot()
  ftp: Login failed
- Это стандартная ошибка vsftpd, возникающая, когда включена опция chroot_local_user=YES (ограничение пользователя в домашнем каталоге), но домашний каталог пользователя имеет права на запись для владельца — это считается уязвимостью безопасности.

Причина:
В файле /etc/vsftpd.conf установлен признак:
  chroot_local_user=YES
и при этом домашний каталог пользователя (например, /home/user) имеет права 755 или 775, что разрешает запись владельцу — а vsftpd по умолчанию запрещает это для безопасности.

Решение: Включить признак allow_writeable_chroot=YES


Полезные файлы и команды
  Конфигурация: /etc/vsftpd.conf
  Логи: /var/log/vsftpd.log (если включено)
  Служба: sudo systemctl {start|stop|restart|status} vsftpd


8. В PfSense настроить блокирующее правило(Floating) по src.ip=kali, dst.ip=ubuntu, dst.port=20,21, protocol=tcp. Настроить логирование этого правила и прислать скрин блокировки(в логах).
