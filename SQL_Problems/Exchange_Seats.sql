-- Problem statement.

-- Mary is a teacher in a middle school and she has a table seat storing students' names and their corresponding seat ids.

-- The column id is continuous increment.


-- Mary wants to change seats for the adjacent students.


-- Can you write a SQL query to output the result for Mary?


-- +---------+---------+
-- |    id   | student |
-- +---------+---------+
-- |    1    | Abbot   |
-- |    2    | Doris   |
-- |    3    | Emerson |
-- |    4    | Green   |
-- |    5    | Jeames  |
-- +---------+---------+
-- For the sample input, the output is:


-- +---------+---------+
-- |    id   | student |
-- +---------+---------+
-- |    1    | Doris   |
-- |    2    | Abbot   |
-- |    3    | Green   |
-- |    4    | Emerson |
-- |    5    | Jeames  |
-- +---------+---------+
-- Note:
-- If the number of students is odd, there is no need to change the last one's seat.

# SQL Solution:

select a.* from
(select s1.id - 1 as id, s1.student
from seat s1
where s1.id MOD 2 = 0
UNION
select s2.id + 1 as id, s2.student
from seat s2
where s2.id MOD 2 = 1 and s2.id != (select max(id) from seat)
UNION
select s3.id, s3.student
from seat s3
where s3.id MOD 2 = 1 and s3.id = (select max(id) from seat)
) a
Order by a.id asc;
