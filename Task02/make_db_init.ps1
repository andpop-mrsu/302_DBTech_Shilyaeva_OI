# PowerShell ETL utility for creating SQL initialization script for movies_rating.db database

param(
    [string]$OutputFile = "db_init.sql"
)

function Escape-SqlString {
    param([string]$Value)
    if ([string]::IsNullOrEmpty($Value)) {
        return 'NULL'
    }
    return "'" + $Value.Replace("'", "''") + "'"
}

function Extract-YearFromTitle {
    param([string]$Title)
    $match = $Title -match '\((\d{4})\)'
    if ($match) {
        return $matches[1]
    }
    return $null
}

function Create-DropTablesSql {
    return @"
-- Drop existing tables
DROP TABLE IF EXISTS tags;
DROP TABLE IF EXISTS ratings;
DROP TABLE IF EXISTS movies;
DROP TABLE IF EXISTS users;
"@
}

function Create-CreateTablesSql {
    return @"
-- Create tables
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
"@
}

function Process-UsersData {
    Write-Host "Processing users data..."
    $usersSql = @()
    
    $content = Get-Content 'users.txt' -Encoding UTF8
    foreach ($line in $content) {
        if ([string]::IsNullOrWhiteSpace($line)) {
            continue
        }
        
        $parts = $line -split '\|'
        if ($parts.Length -ge 6) {
            $userId = $parts[0]
            $name = $parts[1]
            $email = $parts[2]
            $gender = $parts[3]
            $registerDate = $parts[4]
            $occupation = $parts[5]
            
            $nameEscaped = Escape-SqlString $name
            $emailEscaped = Escape-SqlString $email
            $genderEscaped = Escape-SqlString $gender
            $registerDateEscaped = Escape-SqlString $registerDate
            $occupationEscaped = Escape-SqlString $occupation
            
            $sql = "INSERT INTO users (id, name, email, gender, register_date, occupation) VALUES ($userId, $nameEscaped, $emailEscaped, $genderEscaped, $registerDateEscaped, $occupationEscaped);"
            $usersSql += $sql
        }
    }
    
    return $usersSql
}

function Process-MoviesData {
    Write-Host "Processing movies data..."
    $moviesSql = @()
    
    $content = Get-Content 'movies.csv' -Encoding UTF8
    $header = $true
    foreach ($line in $content) {
        if ($header) {
            $header = $false
            continue
        }
        
        $parts = $line -split ','
        if ($parts.Length -ge 3) {
            $movieId = $parts[0]
            $title = $parts[1]
            $genres = $parts[2]
            
            # Extract year from title
            $year = Extract-YearFromTitle $title
            
            $yearValue = if ($year) { $year } else { 'NULL' }
            $titleEscaped = Escape-SqlString $title
            $genresEscaped = Escape-SqlString $genres
            
            $sql = "INSERT INTO movies (id, title, year, genres) VALUES ($movieId, $titleEscaped, $yearValue, $genresEscaped);"
            $moviesSql += $sql
        }
    }
    
    return $moviesSql
}

function Process-RatingsData {
    Write-Host "Processing ratings data..."
    $ratingsSql = @()
    
    $content = Get-Content 'ratings.csv' -Encoding UTF8
    $header = $true
    foreach ($line in $content) {
        if ($header) {
            $header = $false
            continue
        }
        
        $parts = $line -split ','
        if ($parts.Length -ge 4) {
            $userId = $parts[0]
            $movieId = $parts[1]
            $rating = $parts[2]
            $timestamp = $parts[3]
            
            $sql = "INSERT INTO ratings (user_id, movie_id, rating, timestamp) VALUES ($userId, $movieId, $rating, $timestamp);"
            $ratingsSql += $sql
        }
    }
    
    return $ratingsSql
}

function Process-TagsData {
    Write-Host "Processing tags data..."
    $tagsSql = @()
    
    $content = Get-Content 'tags.csv' -Encoding UTF8
    $header = $true
    foreach ($line in $content) {
        if ($header) {
            $header = $false
            continue
        }
        
        $parts = $line -split ','
        if ($parts.Length -ge 4) {
            $userId = $parts[0]
            $movieId = $parts[1]
            $tag = $parts[2]
            $timestamp = $parts[3]
            
            $tagEscaped = Escape-SqlString $tag
            $sql = "INSERT INTO tags (user_id, movie_id, tag, timestamp) VALUES ($userId, $movieId, $tagEscaped, $timestamp);"
            $tagsSql += $sql
        }
    }
    
    return $tagsSql
}

function Generate-SqlScript {
    Write-Host "Generating SQL script $OutputFile..."
    
    $sqlParts = @()
    
    # Add timestamp comment
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $sqlParts += "-- SQL script for movies_rating.db database initialization"
    $sqlParts += "-- Generated: $timestamp"
    $sqlParts += ""
    
    # Drop tables
    $sqlParts += Create-DropTablesSql
    $sqlParts += ""
    
    # Create tables
    $sqlParts += Create-CreateTablesSql
    $sqlParts += ""
    
    # Process data
    $sqlParts += "-- Load data"
    $sqlParts += ""
    
    # Users
    $usersSql = Process-UsersData
    $sqlParts += $usersSql
    $sqlParts += ""
    
    # Movies
    $moviesSql = Process-MoviesData
    $sqlParts += $moviesSql
    $sqlParts += ""
    
    # Ratings
    $ratingsSql = Process-RatingsData
    $sqlParts += $ratingsSql
    $sqlParts += ""
    
    # Tags
    $tagsSql = Process-TagsData
    $sqlParts += $tagsSql
    $sqlParts += ""
    
    # Final comment
    $sqlParts += "-- Database initialization completed"
    
    return $sqlParts -join "`n"
}

# Main logic
Write-Host "ETL utility for creating movies_rating.db database"
Write-Host "=" * 50

# Check for required files
$requiredFiles = @('users.txt', 'movies.csv', 'ratings.csv', 'tags.csv')
$missingFiles = @()

foreach ($file in $requiredFiles) {
    if (-not (Test-Path $file)) {
        $missingFiles += $file
    }
}

if ($missingFiles.Count -gt 0) {
    Write-Error "Error: Missing files: $($missingFiles -join ', ')"
    exit 1
}

try {
    # Generate SQL script
    $sqlScript = Generate-SqlScript
    
    # Write to file
    $sqlScript | Out-File -FilePath $OutputFile -Encoding UTF8
    
    $fileSize = (Get-Item $OutputFile).Length
    Write-Host "SQL script successfully created: $OutputFile"
    Write-Host "File size: $fileSize bytes"
    
} catch {
    Write-Error "Error generating SQL script: $($_.Exception.Message)"
    exit 1
}
