--populate table Student with the values
INSERT INTO Student(ID, FirstName, LastName, DateOfBirth, EnrolledDate, Gender, NationalIdNumber, StudentCardNumber)
VALUES (1, 'Bob', 'Bobski', '2000-10-10', '2020-10-01', 'Male', '1234567890123', '12345');

--populate table Teacher
INSERT INTO Teacher(ID, FirstName, LastName, DateOfBirth, AcademicRank, HireDate)
VALUES (1, 'Trajko', 'Trajkovski', '1900-10-10', 'Academic', '1920-01-10');

--populate table GradeDetails
INSERT INTO GradeDetails(ID, GradeID, AchievementTypeID, AchievementPoints, AchievementMaxPoints, AchievementDate)
VALUES (1, 1, 1, 10, 10, '2025-01-10');

--populate table Course
INSERT INTO Course(ID, Name, Credit, AcademicYear, Semester, AchievementDate)
VALUES (1, 'Course 1', 10, '2024-2025', 'First', '2025-01-10');

--populate table Grade
INSERT INTO Grade(ID, StudentID, CourseID, TeacherID, Grade, Comment, CreatedDate)
VALUES (1, 1, 1, 1, 10, 'Comment', '2025-02-05');

--populate table AchievementType
INSERT INTO AchievementType(ID, Name, Description, ParticipationRate)
VALUES (1, 'Bob Bobski reward', 'Some big fat juicy reward', '99.99');

--multiple values insert into Student table
INSERT INTO Student(ID, FirstName, LastName, DateOfBirth, EnrolledDate, Gender, NationalIdNumber, StudentCardNumber)
VALUES (1, 'Bob', 'Bobski', '2000-10-10', '2020-10-01', 'Male', '1234567890123', '12345'),
(2, 'Gjorge', 'Davidov', '2000-10-10', '2020-10-01', 'Male', '1234567890123', '12345'),
(3, 'Hristina', 'Bozhinova', '2000-10-10', '2020-10-01', 'Female', '1234567890123', '12345');