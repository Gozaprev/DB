--create Student table
--different ways to declare gender:

--gender INTEGER CHECK (gender IN (0, 1, 2))  -- 0 for Male, 1 for Female, 2 for Other
/*CREATE DOMAIN gender_domain AS CHAR(1)
CHECK (VALUE IN ('M', 'F'));
*/
--is_male BOOLEAN
--NationalIdNumber check if it is 13 digits
CREATE TYPE gender AS ENUM ('Male', 'Female', 'Other');
CREATE TABLE Student(
	ID INTEGER NOT NULL,
	FirstName VARCHAR(20) NOT NULL,
	LastName VARCHAR(20) NOT NULL,
	DateOfBirth DATE NOT NULL,
	EnrolledDate DATE NOT NULL,
	Gender gender NOT NULL,
	NationalIdNumber CHAR(13) NOT NULL CHECK (NationalIdNumber ~ '^\d{13}$'),
	StudentCardNumber BIGINT NOT NULL
);
--create Teacher table
CREATE TABLE Teacher(
	ID INTEGER NOT NULL,
	FirstName VARCHAR(20) NOT NULL,
	LastName VARCHAR(20) NOT NULL,
	DateOfBirth DATE NOT NULL,
	AcademicRank VARCHAR(20) NOT NULL,
	HireDate DATE NOT NULL
);

--create GradeDetails table
CREATE TABLE GradeDetails(
	ID INTEGER NOT NULL,
	GradeID INTEGER NOT NULL,
	AchievementTypeID INTEGER NOT NULL,
	AchievementPoints FLOAT NOT NULL,
	AchievementMaxPoints FLOAT NOT NULL,
	AchievementDate DATE NOT NULL
);

--create Course table

CREATE TYPE AcademicYear AS ENUM ('2023-2024', '2024-2025', '2025-2026');
CREATE TYPE Semester AS ENUM ('First', 'Second');
CREATE TABLE Course(
	ID INTEGER NOT NULL,
	Name VARCHAR(20) NOT NULL,
	Credit INTEGER NOT NULL,
	AcademicYear AcademicYear NOT NULL,
	Semester Semester NOT NULL,
	AchievementDate DATE NOT NULL
);

--create Grade table
CREATE TABLE Grade(
	ID INTEGER NOT NULL,
	StudentID INTEGER NOT NULL,
	CourseID INTEGER NOT NULL,
	TeacherID INTEGER NOT NULL,
	Grade FLOAT NOT NULL,
	Comment VARCHAR NOT NULL,
    CreatedDate DATE NOT NULL
);

--create AchievementType table
CREATE TABLE AchievementType(
	ID INTEGER NOT NULL,
	Name VARCHAR(50) NOT NULL,
	Description VARCHAR NOT NULL,
	ParticipationRate NUMERIC(5, 2) CHECK (ParticipationRate >= 0 AND ParticipationRate <= 100)
);
