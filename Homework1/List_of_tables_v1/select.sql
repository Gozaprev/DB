--reading * all columns from a table
SELECT * FROM Student;
SELECT * FROM Teacher;
SELECT * FROM GradeDetails;
SELECT * FROM Course;
SELECT * FROM Grade;
SELECT * FROM AchievementType;


--reading specific colimn from a table
SELECT FirstName FROM Student LIMIT 1;

--reading by specific value
SELECT * FROM Teacher 
WHERE id = 1;

/*retrieves all the values of the Semester enum type. 
The function enum_range() returns an array of all enumerators defined in the Semester enum, 
and UNNEST() expands this array into individual rows
*/
SELECT UNNEST(enum_range(NULL::Semester)) AS semesters;