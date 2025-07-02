### ✅ Глава 1: **Пользователи (Users)** в MySQL

MySQL имеет собственную систему пользователей, **отдельную от пользователей вашей ОС**. Каждый пользователь может иметь свои пароли и права (например, доступ только к определённой базе).

Пример:

```sql
-- Создание нового пользователя
CREATE USER 'azamat'@'localhost' IDENTIFIED BY 'пароль';

-- Дать ему доступ ко всем базам:
GRANT ALL PRIVILEGES ON *.* TO 'azamat'@'localhost' WITH GRANT OPTION;

-- Или только к одной базе:
GRANT SELECT, INSERT, UPDATE ON testdb.* TO 'azamat'@'localhost';

-- Посмотреть всех пользователей:
SELECT User, Host FROM mysql.user;
```

#### Зачем

1. Безопасность: Обычно мы подключаемся по руту (Например: `docker exec -it my-mysql mysql -u root -p 12345`) но в боевых проэктах это не хорошо

комментрий: на самомо деле мы не замечаем но `-u root -p 12345` озночает что мы `user: root` и `password: 12345`

2. Разделение ролей