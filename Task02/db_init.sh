#!/bin/bash
python3 make_db_init.py
sqlite3 movies_rating.db < db_init.sql
echo "Database movies_rating.db has been created successfully."
