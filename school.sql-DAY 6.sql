-- Day 6: school database (students, courses, enrolments)
-- Runs in SQLite (e.g. sqliteonline.com). Safe to re-run: it drops old tables first.

PRAGMA foreign_keys = ON;

DROP TABLE IF EXISTS enrolments;
DROP TABLE IF EXISTS courses;
DROP TABLE IF EXISTS students;

-- ---------------------------------------------------------------
-- 1. Tables
-- ---------------------------------------------------------------

CREATE TABLE students (
  id    INTEGER PRIMARY KEY AUTOINCREMENT,
  name  TEXT NOT NULL,
  email TEXT NOT NULL UNIQUE
);

CREATE TABLE courses (
  id      INTEGER PRIMARY KEY AUTOINCREMENT,
  title   TEXT NOT NULL,
  credits INTEGER NOT NULL DEFAULT 10
);

-- Join table: one row = one student enrolled on one course.
-- The composite PRIMARY KEY stops the same student enrolling on the
-- same course twice. grade is nullable because it is unknown until marked.
CREATE TABLE enrolments (
  student_id INTEGER NOT NULL,
  course_id  INTEGER NOT NULL,
  grade      TEXT,
  PRIMARY KEY (student_id, course_id),
  FOREIGN KEY (student_id) REFERENCES students(id),
  FOREIGN KEY (course_id)  REFERENCES courses(id)
);

-- ---------------------------------------------------------------
-- 2. Sample data
-- ---------------------------------------------------------------

INSERT INTO students (name, email) VALUES
  ('Amina Wanjiru', 'amina@example.com'),
  ('Brian Otieno',  'brian@example.com'),
  ('Chloe Mwangi',  'chloe@example.com'),
  ('David Kamau',   'david@example.com');   -- deliberately not enrolled anywhere

INSERT INTO courses (title, credits) VALUES
  ('Databases',      15),
  ('Web Foundations', 10),
  ('Algorithms',     15);

INSERT INTO enrolments (student_id, course_id, grade) VALUES
  (1, 1, 'B'),
  (1, 2, 'A'),
  (2, 1, NULL),
  (2, 3, 'C'),
  (3, 1, 'A'),
  (3, 2, NULL);

-- ---------------------------------------------------------------
-- 3. Queries
-- ---------------------------------------------------------------

-- Q1: All courses for one student (by name)
SELECT c.title, c.credits, e.grade
FROM students s
JOIN enrolments e ON e.student_id = s.id
JOIN courses c    ON c.id = e.course_id
WHERE s.name = 'Amina Wanjiru';

-- Q2: All students on one course
SELECT s.name, s.email, e.grade
FROM courses c
JOIN enrolments e ON e.course_id = c.id
JOIN students s   ON s.id = e.student_id
WHERE c.title = 'Databases';

-- Q3: Number of students per course
-- LEFT JOIN so a course with zero students still appears with 0.
SELECT c.title, COUNT(e.student_id) AS student_count
FROM courses c
LEFT JOIN enrolments e ON e.course_id = c.id
GROUP BY c.id, c.title;

-- Q4: Students who have no enrolments
SELECT s.name, s.email
FROM students s
LEFT JOIN enrolments e ON e.student_id = s.id
WHERE e.student_id IS NULL;

-- Q5: Update one enrolment's grade (Brian's grade on Databases)
UPDATE enrolments
SET grade = 'B'
WHERE student_id = (SELECT id FROM students WHERE email = 'brian@example.com')
  AND course_id  = (SELECT id FROM courses  WHERE title = 'Databases');

-- Check the update worked
SELECT s.name, c.title, e.grade
FROM enrolments e
JOIN students s ON s.id = e.student_id
JOIN courses c  ON c.id = e.course_id
WHERE s.email = 'brian@example.com' AND c.title = 'Databases';
