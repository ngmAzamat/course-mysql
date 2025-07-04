# course-mysql

## 🚀 **Как начать работать с MySQL (быстро и кроссплатформенно)**

### ✅ **Шаг 1: Установи Docker**

- Docker работает на **Windows, MacOS, Linux**
- Это самый простой и универсальный способ развернуть сервер MySQL без лишней возни

📥 [Скачать Docker Desktop](https://www.docker.com/products/docker-desktop/)

---

### ✅ **Шаг 2: Скачай образ MySQL**

```bash
docker pull mysql
```

или конкретную версию (рекомендуется):

```bash
docker pull mysql:8.0.42
```

---

### ✅ **Шаг 3: Запусти контейнер MySQL**

#### 📌 Вариант 1: без пароля (для теста)

```bash
docker run --rm -d -e MYSQL_ALLOW_EMPTY_PASSWORD=yes -p 3306:3306 mysql
```

#### 📌 Вариант 2: с паролем (лучше для учебной среды)

```bash
docker run --rm -d -e MYSQL_ROOT_PASSWORD=12345 -p 40001:3306 mysql
```

но то было в первый тестовый раз а потом надо:

```bash
sudo docker run -d --name my-mysql -e MYSQL_ROOT_PASSWORD=12345 -p 40001:3306 -v mysql-data:/var/lib/mysql mysql
```

- `--rm` — удалить контейнер после остановки
- `-d` — фоновой запуск
- `-e` — задаём переменные окружения
- `-p` — проброс порта

---

### ✅ **Шаг 4: Подключись через GUI (например, Sqlectron)**

📥 [Sqlectron GUI](https://sqlectron.github.io/) и там скачавоем и так как линукс убунту файл sqlectron_1.38.0_amd64.deb

`azamat@ubuntu:~/Downloads$ sudo dpkg -i sqlectron_1.38.0_amd64.deb`
`azamat@ubuntu:~/Downloads$ sqlectron`

далее на кнопку add
🔧 Настройки подключения:

| Поле                      | Значение    |
| ------------------------- | ----------- |
| Name                      | local-mysql |
| Database Type             | MySQL       |
| Server Address            | 127.0.0.1   |
| Port                      | 40001       |
| User                      | root        |
| Password                  | 12345       |
| Initial Database/Keyspace | ничего      |

а потом на кнопки test, save, а потом на connect

а потом в undefined #1:

```sql
-- так мы создаем базу
CREATE DATABASE testdb;
-- применяем базу
USE testdb;

-- создаем таблицу
CREATE TABLE users (
  -- это для того что бы не повторялось что то, тут id с типом int и с номером и уникальном идентификатором строки
  id INT AUTO_INCREMENT PRIMARY KEY,
  -- имя с типом varchar и до 100 символов(обычных varchar 65 535 а char 255)
  name VARCHAR(100),
  -- email с типом varcharи до 100 символов(обычных varchar 65 535 а char 255)
  email VARCHAR(100)
);

-- созданием пользователя в таблице users с параметрами указаннами
INSERT INTO users (name, email)
-- он будет Azamat
VALUES ('Azamat', 'azamat@example.com');
-- хочю увидеть всех пользователей
SELECT * FROM users;

/* почему именно varchar?
он потенициально больше(65 535) но экономит место, например между char(100) и varchar(100) лучше varchar,
если дело не про жёстко фиксированное поле (например MD5-хеш длиной ровно 32 символа) */
```

а потом CTRL + ENTER

---