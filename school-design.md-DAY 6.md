# School database design

## Tables

**students** stores one row per person who studies at the school. Columns: `id` (primary key), `name` (required) and `email` (required and `UNIQUE`, so two students can't share an address).

**courses** stores one row per course offered. Columns: `id` (primary key), `title` (required) and `credits` (required, default 10).

**enrolments** records the fact that a particular student is taking a particular course, and holds the grade for that pairing. Columns: `student_id` and `course_id` (both foreign keys, both required) and `grade` (optional, because it is empty until the work is marked). Its primary key is the *pair* `(student_id, course_id)`, which is the rule that stops a student enrolling on the same course twice.

## Relationships

- **One student to many enrolments** (one-to-many): a student can have many enrolment rows, but each enrolment row belongs to exactly one student.
- **One course to many enrolments** (one-to-many): the same, from the course side.
- **Students to courses** (many-to-many): a student takes many courses, and a course has many students.

A many-to-many relationship can't be stored directly in two tables. Putting a list of course ids in `students` (or student ids in `courses`) would break first normal form, make it impossible for the database to enforce foreign keys, and make queries like "who is on this course?" slow and awkward. The **join table** `enrolments` solves this by turning the one many-to-many relationship into two one-to-many relationships. It is also the natural place for the grade, because a grade belongs to neither the student nor the course alone, only to the combination of the two.

## Index

I would add an index on `enrolments(course_id)`:

```sql
CREATE INDEX idx_enrolments_course_id ON enrolments(course_id);
```

The composite primary key `(student_id, course_id)` already gives fast lookups by student, but queries that start from a course ("all students on this course", "number of students per course") filter and join on `course_id` alone, and the primary key index can't be used efficiently for that. The index lets the database jump straight to a course's enrolments instead of scanning the whole table. The trade-off is slightly slower inserts and a little extra storage, which is acceptable because enrolments are read far more often than they are written.

## SQL or NoSQL?

I would choose SQL (a relational database) for this system. The data is clearly structured and highly relational: students, courses and enrolments have fixed shapes and link to each other in a many-to-many pattern. A relational database enforces that structure for us, with foreign keys preventing enrolments for students or courses that don't exist, `UNIQUE` constraints preventing duplicate emails and duplicate enrolments, and transactions keeping changes consistent. Joins and `GROUP BY` also make the questions the school will actually ask, such as class lists, enrolment counts and students with no courses, simple to write. A NoSQL document store could work for very large, loosely structured or rapidly changing data, but here it would mean duplicating course or student data across documents and re-implementing integrity rules in application code. At the scale of a school, SQL's strengths clearly outweigh any scaling advantage NoSQL might offer.
