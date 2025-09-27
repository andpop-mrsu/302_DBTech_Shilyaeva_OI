#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Скрипт для создания базы данных movies_rating.db из SQL-скрипта
Использует встроенный модуль sqlite3 Python
"""

import sqlite3
import os
import sys

def create_database_from_sql(sql_file, db_file):
    """Создает базу данных из SQL-скрипта"""
    try:
        # Удаляем существующую базу данных если есть
        if os.path.exists(db_file):
            os.remove(db_file)
            print(f"Removed existing database: {db_file}")
        
        # Создаем подключение к базе данных
        conn = sqlite3.connect(db_file)
        cursor = conn.cursor()
        
        # Читаем и выполняем SQL-скрипт
        with open(sql_file, 'r', encoding='utf-8') as f:
            sql_script = f.read()
        
        # Выполняем SQL-скрипт
        cursor.executescript(sql_script)
        
        # Сохраняем изменения
        conn.commit()
        
        # Проверяем количество записей в таблицах
        tables = ['users', 'movies', 'ratings', 'tags']
        print("\nDatabase created successfully!")
        print("Records in tables:")
        
        for table in tables:
            cursor.execute(f"SELECT COUNT(*) FROM {table}")
            count = cursor.fetchone()[0]
            print(f"  {table}: {count} records")
        
        conn.close()
        return True
        
    except Exception as e:
        print(f"Error creating database: {e}")
        return False

def main():
    """Основная функция"""
    sql_file = "db_init.sql"
    db_file = "movies_rating.db"
    
    print("Creating database from SQL script...")
    print(f"SQL file: {sql_file}")
    print(f"Database file: {db_file}")
    
    # Проверяем наличие SQL-файла
    if not os.path.exists(sql_file):
        print(f"Error: SQL file '{sql_file}' not found!")
        print("Please run make_db_init.py or make_db_init.ps1 first.")
        sys.exit(1)
    
    # Создаем базу данных
    if create_database_from_sql(sql_file, db_file):
        print(f"\nDatabase '{db_file}' created successfully!")
        print(f"File size: {os.path.getsize(db_file)} bytes")
    else:
        print("Failed to create database!")
        sys.exit(1)

if __name__ == "__main__":
    main()
