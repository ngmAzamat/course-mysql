### ✅ Глава III: **Процедуры (Procedure)** в MySQL

на самом те деле это те же самые функции но:

1. у нее нету return
2. не изпользует SELECT а изпользует CALL

однако

1. может изпользовать парметры
2. не требуетс указания DETERMINISTIC или NOT DETERMINISTIC

то есть:

```sql
DELIMITER //

CREATE PROCEDURE -- имя_процедуры(параметры)
BEGIN
  -- SQL-код
END;
//

DELIMITER ;

CALL -- имя_процедуры(параметры)
```

по сути дела изпользовать процедуры надо когда нам хочится писать sql код без потребности в возврощении данных:

#### Вариант I: где не нужно Return - ибо там уже в самой функции быстро выполняется INSERT INTO:

```sql
DELIMITER //

CREATE PROCEDURE add_user(IN uname VARCHAR(100), IN uemail VARCHAR(100))
BEGIN
  INSERT INTO users (name, email)
  VALUES (uname, uemail);
END;
//

DELIMITER ;

-- Вызов
CALL add_user('Ali', 'ali@example.com');
```

#### Вариант II: где НУЖЕН Select и Return:

```sql
DELIMITER //

CREATE FUNCTION get_name(uid INT)
RETURNS VARCHAR(100)
DETERMINISTIC
BEGIN
  DECLARE uname VARCHAR(100);
  SELECT name INTO uname FROM users WHERE id = uid;
  RETURN uname;
END;
//

DELIMITER ;
```