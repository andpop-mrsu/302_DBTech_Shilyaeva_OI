-- 1. Добавление новых пользователей
INSERT INTO users (name, email, gender, register_date, occupation_id)
VALUES 
('Шиляева Ольга', 'olga.shilyaeva@example.com', 'female', date('now'), 
    (SELECT id FROM occupations WHERE name = 'student')),
('Шапошников Алексей', 'aleksey.shaposhnikov@example.com', 'male', date('now'), 
    (SELECT id FROM occupations WHERE name = 'student')),
('Учуваткин Никита', 'nikita.uchuvatkin@example.com', 'male', date('now'), 
    (SELECT id FROM occupations WHERE name = 'student')),
('Гришуков Егор', 'egor.grishukov@example.com', 'male', date('now'), 
    (SELECT id FROM occupations WHERE name = 'student')),
('Данькин Иван', 'ivan.dankin@example.com', 'male', date('now'), 
    (SELECT id FROM occupations WHERE name = 'student'));


INSERT INTO movies (title, year)
VALUES 
('Вам письмо', 1998),
('Криминальное чтиво', 1994),
('Леон', 1994);


INSERT INTO movies_genres (movie_id, genre_id)
VALUES 
-- Вам письмо: Romance, Comedy
((SELECT id FROM movies WHERE title = 'Вам письмо'), 
 (SELECT id FROM genres WHERE name = 'Romance')),
((SELECT id FROM movies WHERE title = 'Вам письмо'), 
 (SELECT id FROM genres WHERE name = 'Comedy')),

-- Криминальное чтиво: Crime, Thriller
((SELECT id FROM movies WHERE title = 'Криминальное чтиво'), 
 (SELECT id FROM genres WHERE name = 'Crime')),
((SELECT id FROM movies WHERE title = 'Криминальное чтиво'), 
 (SELECT id FROM genres WHERE name = 'Thriller')),

-- Леон: Action, Thriller, Drama
((SELECT id FROM movies WHERE title = 'Леон'), 
 (SELECT id FROM genres WHERE name = 'Action')),
((SELECT id FROM movies WHERE title = 'Леон'), 
 (SELECT id FROM genres WHERE name = 'Thriller')),
((SELECT id FROM movies WHERE title = 'Леон'), 
 (SELECT id FROM genres WHERE name = 'Drama'));

-- 4. Добавление отзывов
INSERT INTO ratings (user_id, movie_id, rating, timestamp)
VALUES 
((SELECT id FROM users WHERE email = 'olga.shilyaeva@example.com'), 
 (SELECT id FROM movies WHERE title = 'Вам письмо'), 4.5, strftime('%s', 'now')),
((SELECT id FROM users WHERE email = 'olga.shilyaeva@example.com'), 
 (SELECT id FROM movies WHERE title = 'Криминальное чтиво'), 5.0, strftime('%s', 'now')),
((SELECT id FROM users WHERE email = 'olga.shilyaeva@example.com'), 
 (SELECT id FROM movies WHERE title = 'Леон'), 4.0, strftime('%s', 'now'));

-- 5. Добавление тегов
INSERT INTO tags (user_id, movie_id, tag, timestamp)
VALUES 
((SELECT id FROM users WHERE email = 'olga.shilyaeva@example.com'), 
 (SELECT id FROM movies WHERE title = 'Вам письмо'), 'Романтическая комедия про интернет-знакомства', strftime('%s', 'now')),
((SELECT id FROM users WHERE email = 'olga.shilyaeva@example.com'), 
 (SELECT id FROM movies WHERE title = 'Криминальное чтиво'), 'Культовый криминальный фильм Квентина Тарантино', strftime('%s', 'now')),
((SELECT id FROM users WHERE email = 'olga.shilyaeva@example.com'), 
 (SELECT id FROM movies WHERE title = 'Леон'), 'Невероятно захватывающий триллер про киллера и девочку', strftime('%s', 'now'));