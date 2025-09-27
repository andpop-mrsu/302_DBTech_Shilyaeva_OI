#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
ETL утилита для создания SQL-скрипта инициализации базы данных movies_rating.db
Генерирует SQL-скрипт db_init.sql для создания таблиц и загрузки данных
"""

import csv
import os
import sys
from datetime import datetime


def escape_sql_string(value):
    """Экранирует строку для безопасной вставки в SQL"""
    if value is None:
        return 'NULL'
    return "'" + str(value).replace("'", "''") + "'"


def extract_year_from_title(title):
    """Извлекает год из названия фильма (формат: Title (YYYY))"""
    import re
    match = re.search(r'\((\d{4})\)', title)
    return match.group(1) if match else None


def create_drop_tables_sql():
    """Создает SQL для удаления существующих таблиц"""
    return """
-- Удаление существующих таблиц
DROP TABLE IF EXISTS tags;
DROP TABLE IF EXISTS ratings;
DROP TABLE IF EXISTS movies;
DROP TABLE IF EXISTS users;
"""


def create_create_tables_sql():
    """Создает SQL для создания таблиц"""
    return """
-- Создание таблиц
CREATE TABLE users (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT NOT NULL,
    gender TEXT NOT NULL,
    register_date TEXT NOT NULL,
    occupation TEXT NOT NULL
);

CREATE TABLE movies (
    id INTEGER PRIMARY KEY,
    title TEXT NOT NULL,
    year INTEGER,
    genres TEXT
);

CREATE TABLE ratings (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    movie_id INTEGER NOT NULL,
    rating REAL NOT NULL,
    timestamp INTEGER NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (movie_id) REFERENCES movies(id)
);

CREATE TABLE tags (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    movie_id INTEGER NOT NULL,
    tag TEXT NOT NULL,
    timestamp INTEGER NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (movie_id) REFERENCES movies(id)
);
"""


def process_users_data():
    """Обрабатывает данные пользователей из users.txt"""
    print("Обработка данных пользователей...")
    users_sql = []
    
    with open('users.txt', 'r', encoding='utf-8') as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
                
            parts = line.split('|')
            if len(parts) >= 6:
                user_id = parts[0]
                name = parts[1]
                email = parts[2]
                gender = parts[3]
                register_date = parts[4]
                occupation = parts[5]
                
                sql = f"INSERT INTO users (id, name, email, gender, register_date, occupation) VALUES ({user_id}, {escape_sql_string(name)}, {escape_sql_string(email)}, {escape_sql_string(gender)}, {escape_sql_string(register_date)}, {escape_sql_string(occupation)});"
                users_sql.append(sql)
    
    return users_sql


def process_movies_data():
    """Обрабатывает данные фильмов из movies.csv"""
    print("Обработка данных фильмов...")
    movies_sql = []
    
    with open('movies.csv', 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        for row in reader:
            movie_id = row['movieId']
            title = row['title']
            genres = row['genres']
            
            # Извлекаем год из названия
            year = extract_year_from_title(title)
            
            sql = f"INSERT INTO movies (id, title, year, genres) VALUES ({movie_id}, {escape_sql_string(title)}, {year if year else 'NULL'}, {escape_sql_string(genres)});"
            movies_sql.append(sql)
    
    return movies_sql


def process_ratings_data():
    """Обрабатывает данные рейтингов из ratings.csv"""
    print("Обработка данных рейтингов...")
    ratings_sql = []
    
    with open('ratings.csv', 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        for row in reader:
            user_id = row['userId']
            movie_id = row['movieId']
            rating = row['rating']
            timestamp = row['timestamp']
            
            sql = f"INSERT INTO ratings (user_id, movie_id, rating, timestamp) VALUES ({user_id}, {movie_id}, {rating}, {timestamp});"
            ratings_sql.append(sql)
    
    return ratings_sql


def process_tags_data():
    """Обрабатывает данные тегов из tags.csv"""
    print("Обработка данных тегов...")
    tags_sql = []
    
    with open('tags.csv', 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        for row in reader:
            user_id = row['userId']
            movie_id = row['movieId']
            tag = row['tag']
            timestamp = row['timestamp']
            
            sql = f"INSERT INTO tags (user_id, movie_id, tag, timestamp) VALUES ({user_id}, {movie_id}, {escape_sql_string(tag)}, {timestamp});"
            tags_sql.append(sql)
    
    return tags_sql


def generate_sql_script():
    """Генерирует полный SQL-скрипт"""
    print("Генерация SQL-скрипта db_init.sql...")
    
    sql_parts = []
    
    # Добавляем комментарий с временной меткой
    sql_parts.append(f"-- SQL-скрипт для инициализации базы данных movies_rating.db")
    sql_parts.append(f"-- Сгенерирован: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    sql_parts.append("")
    
    # Удаление таблиц
    sql_parts.append(create_drop_tables_sql())
    
    # Создание таблиц
    sql_parts.append(create_create_tables_sql())
    
    # Обработка данных
    sql_parts.append("-- Загрузка данных")
    sql_parts.append("")
    
    # Пользователи
    users_sql = process_users_data()
    sql_parts.extend(users_sql)
    sql_parts.append("")
    
    # Фильмы
    movies_sql = process_movies_data()
    sql_parts.extend(movies_sql)
    sql_parts.append("")
    
    # Рейтинги
    ratings_sql = process_ratings_data()
    sql_parts.extend(ratings_sql)
    sql_parts.append("")
    
    # Теги
    tags_sql = process_tags_data()
    sql_parts.extend(tags_sql)
    sql_parts.append("")
    
    # Финальный комментарий
    sql_parts.append("-- Инициализация базы данных завершена")
    
    return '\n'.join(sql_parts)


def main():
    """Основная функция"""
    print("ETL утилита для создания базы данных movies_rating.db")
    print("=" * 50)
    
    # Проверяем наличие исходных файлов
    required_files = ['users.txt', 'movies.csv', 'ratings.csv', 'tags.csv']
    missing_files = [f for f in required_files if not os.path.exists(f)]
    
    if missing_files:
        print(f"Ошибка: Отсутствуют файлы: {', '.join(missing_files)}")
        sys.exit(1)
    
    try:
        # Генерируем SQL-скрипт
        sql_script = generate_sql_script()
        
        # Записываем в файл
        with open('db_init.sql', 'w', encoding='utf-8') as f:
            f.write(sql_script)
        
        print(f"SQL-скрипт успешно создан: db_init.sql")
        print(f"Размер файла: {os.path.getsize('db_init.sql')} байт")
        
    except Exception as e:
        print(f"Ошибка при генерации SQL-скрипта: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
