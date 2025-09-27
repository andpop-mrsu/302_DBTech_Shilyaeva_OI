@echo off
echo Generating SQL script...
powershell -ExecutionPolicy Bypass -File make_db_init.ps1

echo Creating database using Python...
python create_db.py
if %errorlevel% equ 0 (
    echo.
    echo SUCCESS: Database movies_rating.db has been created!
) else (
    echo.
    echo ERROR: Failed to create database
    echo Trying alternative method with sqlite3 command...
    sqlite3 movies_rating.db < db_init.sql
    if %errorlevel% equ 0 (
        echo SUCCESS: Database created using sqlite3 command
    ) else (
        echo ERROR: Both methods failed. Please check your Python installation.
    )
)
pause