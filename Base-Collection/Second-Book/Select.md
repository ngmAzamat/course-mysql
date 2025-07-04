### ✅ Глава VI: **Команды в SELECT запросах** в MySQL


#### ✅ `ORDER BY` — сортировка

```sql
SELECT * FROM users ORDER BY name ASC;  -- по возрастанию (по имени)
SELECT * FROM users ORDER BY id DESC;   -- по убыванию (по id)
```

| Ключевое слово | Описание                      |
| -------------- | ----------------------------- |
| `ASC`          | По возрастанию (по умолчанию) |
| `DESC`         | По убыванию                   |

---

#### ✅ `LIMIT` — ограничить количество результатов

```sql
SELECT * FROM users LIMIT 5;            -- только 5 строк
SELECT * FROM users LIMIT 10 OFFSET 5;  -- пропустить 5, взять 10
```

| Команда    | Описание                          |
| ---------- | --------------------------------- |
| `LIMIT N`  | Возвращает N строк                |
| `OFFSET N` | Пропустить N строк перед выборкой |

---

#### ✅ `LIKE` — поиск по шаблону

```sql
SELECT * FROM users WHERE name LIKE 'A%';    -- имя начинается с A
SELECT * FROM users WHERE email LIKE '%@gmail.com';  -- email заканчивается на @gmail.com
```

| Шаблон | Значение                        |
| ------ | ------------------------------- |
| `%`    | Любое количество любых символов |
| `_`    | Ровно один любой символ         |

---

#### ✅ `IN` — находится в списке значений

```sql
SELECT * FROM users WHERE id IN (1, 2, 3);
SELECT * FROM users WHERE name IN ('Ali', 'Azamat');
```

| `IN`            | То же самое, что много `OR`  |
| --------------- | ---------------------------- |
| `id IN (1,2,3)` | `id = 1 OR id = 2 OR id = 3` |

---

#### ✅ `BETWEEN` — диапазон значений

```sql
SELECT * FROM users WHERE id BETWEEN 5 AND 10;
```

\| `BETWEEN a AND b` | Значение от `a` до `b`, включая границы |

---

#### ✅ `IS NULL` — проверка на NULL

```sql
SELECT * FROM users WHERE email IS NULL;
SELECT * FROM users WHERE email IS NOT NULL;
```

| Условие       | Описание             |
| ------------- | -------------------- |
| `IS NULL`     | Значение отсутствует |
| `IS NOT NULL` | Значение есть        |

---

Хочешь я сделаю наглядный пример с таблицей `users`, где применяются все эти операторы в одном запросе?
