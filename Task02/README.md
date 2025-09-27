# ETL процесс для создания базы данных movies_rating.db

Данный проект реализует процесс ETL (Extract, Transform, Load) для переноса данных о фильмах, пользователях, рейтингах и тегах в базу данных SQLite.

## Структура проекта

- `make_db_init.py` - Python утилита для генерации SQL-скрипта
- `make_db_init.ps1` - PowerShell утилита для генерации SQL-скрипта (альтернатива для Windows)
- `db_init.bat` - Windows batch-скрипт для запуска ETL процесса
- `db_init.sh` - Linux/macOS shell-скрипт для запуска ETL процесса
- `db_init.sql` - SQL-скрипт для создания таблиц и загрузки данных (генерируется автоматически)
- `movies_rating.db` - База данных SQLite (создается автоматически)

## Исходные данные

- `movies.csv` - данные о фильмах (9742 записи)
- `ratings.csv` - данные о рейтингах (18773 записи)
- `tags.csv` - данные о тегах (3683 записи)
- `users.txt` - данные о пользователях (942 записи)
- `genres.txt` - список жанров
- `occupation.txt` - список профессий

## Структура базы данных

### Таблица users
- `id` (INTEGER PRIMARY KEY) - идентификатор пользователя
- `name` (TEXT) - имя пользователя
- `email` (TEXT) - email адрес
- `gender` (TEXT) - пол
- `register_date` (TEXT) - дата регистрации
- `occupation` (TEXT) - профессия

### Таблица movies
- `id` (INTEGER PRIMARY KEY) - идентификатор фильма
- `title` (TEXT) - название фильма
- `year` (INTEGER) - год выпуска
- `genres` (TEXT) - жанры (разделенные символом |)

### Таблица ratings
- `id` (INTEGER PRIMARY KEY AUTOINCREMENT) - идентификатор рейтинга
- `user_id` (INTEGER) - идентификатор пользователя (FK)
- `movie_id` (INTEGER) - идентификатор фильма (FK)
- `rating` (REAL) - оценка (0.5-5.0)
- `timestamp` (INTEGER) - временная метка

### Таблица tags
- `id` (INTEGER PRIMARY KEY AUTOINCREMENT) - идентификатор тега
- `user_id` (INTEGER) - идентификатор пользователя (FK)
- `movie_id` (INTEGER) - идентификатор фильма (FK)
- `tag` (TEXT) - текст тега
- `timestamp` (INTEGER) - временная метка

## Требования к окружению

Для корректной работы скрипта `db_init.bat` необходимо установить:

### Windows
- **Python 3.x** - для выполнения утилиты генерации SQL-скрипта
  - Скачать с официального сайта: https://www.python.org/downloads/
  - Убедиться, что Python добавлен в PATH
- **SQLite3** - для создания и управления базой данных
  - Обычно входит в состав Python
  - Или скачать отдельно: https://www.sqlite.org/download.html

### Linux/macOS
- **Python 3.x** - установить через пакетный менеджер:
  - Ubuntu/Debian: `sudo apt install python3`
  - CentOS/RHEL: `sudo yum install python3`
  - macOS: `brew install python3`
- **SQLite3** - обычно предустановлен:
  - Ubuntu/Debian: `sudo apt install sqlite3`
  - CentOS/RHEL: `sudo yum install sqlite3`

## Использование

1. Убедитесь, что все исходные файлы данных находятся в текущей директории
2. Запустите скрипт инициализации:

   **На Windows:**
   ```cmd
   db_init.bat
   ```
   
   **На Linux/macOS:**
   ```bash
   chmod +x db_init.sh
   ./db_init.sh
   ```

3. После успешного выполнения будет создана база данных `movies_rating.db` с заполненными таблицами

**Альтернативный способ (только генерация SQL-скрипта):**
- На Windows: `powershell -ExecutionPolicy Bypass -File make_db_init.ps1`
- На Linux/macOS: `python3 make_db_init.py`

## Особенности реализации

- Утилита автоматически удаляет существующие таблицы перед созданием новых
- Год фильма извлекается из названия (формат: "Title (YYYY)")
- Все строковые значения экранируются для безопасности SQL-запросов
- Поддерживается кроссплатформенность (Windows, Linux, macOS)
- Генерируется подробный SQL-скрипт с комментариями

## Проверка результата

После выполнения скрипта можно проверить созданную базу данных:

```bash
sqlite3 movies_rating.db
.tables
.schema
SELECT COUNT(*) FROM users;
SELECT COUNT(*) FROM movies;
SELECT COUNT(*) FROM ratings;
SELECT COUNT(*) FROM tags;
.quit
```
