--update 
UPDATE Student
SET FirstName = 'John', LastName = 'Johnsky'
WHERE id = 1;

--update multiple records with matching where clause
UPDATE Teacher
SET AcademicRank = 'Professor'
WHERE HireDate = '2000-10-10';