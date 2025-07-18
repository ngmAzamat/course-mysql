### ✅ Глава 1: **Пользователи (Users)** в MySQL

MySQL имеет собственную систему пользователей, **отдельную от пользователей вашей ОС**. 
Каждый пользователь может иметь свои пароли и права (например, доступ только к определённой базе).

#### Зачем

1. Безопасность: Обычно мы подключаемся по руту (Например: `docker exec -it my-mysql mysql -u root -p 12345`) но в боевых проэктах это не хорошо

комментрий: на самомо деле мы не замечаем но `-u root -p 12345` озночает что мы `user: root` и `password: 12345`

2. Разделение ролей
- один пользователь для создания `CREATE`, `INSERT INTO`
- второй пользователь для аналитики `SELECT`, `INDEX`
- третий пользователь для удаления `DELETE`, `DROP`
- четвертый пользователь для изменения `ALTER`, `UPDATE`

3. 📦 Управления подключениями
- Можно отследить, кто к базе подключается.
- Можно запретить доступ по IP ('user'@'localhost', 'user'@'192.168.%').
- Можно установить лимиты: сколько соединений, сколько операций в секунду и т.д.

4. 🧩 Безопасный доступ с серверов и приложений, В настоящем проекте:
- Веб-приложение использует пользователя app_user с минимальными правами.
- Администратор может подключаться под admin_user и управлять БД.

#### как мы делаем

1. мы заходим как root `docker exec -it my-mysql mysql -u root -p 12345`
2. делаем пользователя 
3. выходим 
4. заходим как пользователь


```sql
-- Создание нового пользователя
CREATE USER 'azamat'@'localhost' IDENTIFIED BY 'пароль';

-- Дать ему доступ ко всем базам:
GRANT ALL PRIVILEGES ON *.* TO 'azamat'@'localhost' WITH GRANT OPTION;

-- Или только к одной базе:
GRANT SELECT, INSERT, UPDATE ON testdb.* TO 'azamat'@'localhost';
```
```sql
-- Посмотреть всех пользователей:
SELECT user, host FROM mysql.user;

-- Создать пользователя:
CREATE USER 'user'@'localhost' IDENTIFIED BY 'пароль';

-- Удалить пользователя:
DROP USER 'user'@'localhost';

-- Дать права:
GRANT SELECT, INSERT ON testdb.* TO 'user'@'localhost';

-- Убрать права:
REVOKE INSERT ON testdb.* FROM 'user'@'localhost';

-- Посмотреть права:
SHOW GRANTS FOR 'user'@'localhost';
```

