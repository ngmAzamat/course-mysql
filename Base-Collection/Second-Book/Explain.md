### ✅ Глава VII: **Команда EXPLAIN** в MySQL

## 🧠 Что такое `EXPLAIN`?

Команда `EXPLAIN` в MySQL показывает **как именно** выполняется SQL-запрос. Это нужно, чтобы **понять эффективность** индексов.
`EXPLAIN` — команда, которая **анализирует план выполнения запроса**:
какие таблицы используются, как происходит поиск, есть ли индекс, сколько строк просматривается и т.д.

---

## 🔍 Сравнение до и после индекса:

Предположим, у тебя есть таблица `users` с 10 000 строк, и ты часто делаешь:

```sql
SELECT * FROM users WHERE email = 'azamat@example.com';
```

### 🔴 Без индекса:

```sql
EXPLAIN SELECT * FROM users WHERE email = 'azamat@example.com';
```

Пример вывода:

| id | select\_type | table | type    | rows  | Extra       |
| -- | ------------ | ----- | ------- | ----- | ----------- |
| 1  | SIMPLE       | users | **ALL** | 10000 | Using where |

* **type = ALL** → это значит **полный перебор строк** (медленно!)
* **rows = 10000** → столько строк MySQL просмотрит

---

### ✅ После создания индекса:

```sql
CREATE INDEX idx_email ON users(email);
```

Теперь снова:

```sql
EXPLAIN SELECT * FROM users WHERE email = 'azamat@example.com';
```

Пример вывода:

| id | select\_type | table | type    | key        | rows | Extra       |
| -- | ------------ | ----- | ------- | ---------- | ---- | ----------- |
| 1  | SIMPLE       | users | **ref** | idx\_email | 1    | Using where |

* **type = ref** → означает, что используется индекс
* **key = idx\_email** → вот он, твой индекс!
* **rows = 1** → просматривается только одна строка

---

## 💡 Вывод:

| До индекса                        | После индекса                        |
| --------------------------------- | ------------------------------------ |
| Перебор всех строк (`type = ALL`) | Использование индекса (`type = ref`) |
| Медленно                          | Быстро                               |

---

Хочешь, я покажу пример с `EXPLAIN` в реальной таблице, шаг за шагом?


Отлично! Это всё ключевые команды SQL, которые **используются в `SELECT`-запросах** для фильтрации, сортировки и ограничения данных. Вот кратко и наглядно про каждую:

---