-- Tables

CREATE TABLE Programs (
	name TEXT PRIMARY KEY,
	abbreviation TEXT NOT NULL
);

CREATE TABLE Students (
	idnr CHAR(10) PRIMARY KEY,
	name TEXT NOT NULL,
	login TEXT NOT NULL UNIQUE,
	program TEXT NOT NULL REFERENCES Programs(name),
	UNIQUE (idnr, program)
);

CREATE TABLE Branches (
	name TEXT,
	program TEXT REFERENCES Programs(name),
	PRIMARY KEY (name, program)
);

CREATE TABLE Departments (
	name TEXT PRIMARY KEY,
	abbreviation TEXT NOT NULL UNIQUE
);

CREATE TABLE Courses (
	code CHAR(6) PRIMARY KEY,
	name TEXT NOT NULL,
	credits FLOAT NOT NULL CHECK (credits >= 0),
	department TEXT NOT NULL REFERENCES Departments(name)
);

CREATE TABLE Classifications (
	name TEXT PRIMARY KEY
);

CREATE TABLE DepartmentPrograms (
	program TEXT PRIMARY KEY REFERENCES Programs(name),
	department TEXT NOT NULL REFERENCES Departments(name)
);

CREATE TABLE StudentBranches (
	student CHAR(10) PRIMARY KEY,
	branch TEXT NOT NULL, 
	program TEXT NOT NULL,
	UNIQUE (student, branch, program),
	FOREIGN KEY (student, program) REFERENCES Students(idnr, program),
	FOREIGN KEY (branch, program) REFERENCES Branches(name, program)
);

CREATE TABLE Classified (
	course CHAR(6) REFERENCES Courses(code),
	classification TEXT REFERENCES Classifications(name),
	PRIMARY KEY (course, classification)
);

CREATE TABLE LimitedCourses (
	course CHAR(6) PRIMARY KEY REFERENCES Courses(code),
	capacity INT NOT NULL CHECK (capacity > 0),
	UNIQUE (course, capacity)
);

CREATE TABLE Taken (
	student CHAR(10) REFERENCES Students(idnr),
	course CHAR(6) REFERENCES Courses(code),
	grade CHAR(1) DEFAULT 'U' NOT NULL CHECK (grade IN ('U', '3', '4', '5')),
	PRIMARY KEY (student, course),
	UNIQUE (student, course, grade)
);

CREATE TABLE Registered (
	student CHAR(10) REFERENCES Students(idnr),
	course CHAR(6) REFERENCES Courses(code),
	PRIMARY KEY (student, course)
);

CREATE TABLE WaitingList (
	student CHAR(10) REFERENCES Students(idnr),
	course CHAR(6) REFERENCES LimitedCourses(course),
	position SERIAL,
	PRIMARY KEY (student, course),
	UNIQUE (course, position)
);

CREATE TABLE RecommendedBranch (
	course CHAR(6) REFERENCES Courses(code),
	branch TEXT, 
	program TEXT,
	FOREIGN KEY (branch, program) REFERENCES Branches,
	PRIMARY KEY (branch, program),
	UNIQUE (course, branch, program)
);

CREATE TABLE MandatoryBranch (
	course CHAR(6) REFERENCES Courses(code),
	branch TEXT,
	program TEXT,
	FOREIGN KEY (branch, program) REFERENCES Branches,
	PRIMARY KEY (branch, program),
	UNIQUE (course, branch, program)
);

CREATE TABLE MandatoryProgram (
	course CHAR(6) REFERENCES Courses(code),
	program TEXT PRIMARY KEY REFERENCES Programs(name),
	UNIQUE (course, program)
);

CREATE TABLE Prerequisite (
	course CHAR(6) REFERENCES Courses(code),
	prerequisite CHAR(6) REFERENCES Courses(code),
	PRIMARY KEY (course, prerequisite)
);

-- Inserts

INSERT INTO Programs VALUES ('Prog1', 'P1');
INSERT INTO Programs VALUES ('Prog2', 'P2');

INSERT INTO Branches VALUES ('B1', 'Prog1');
INSERT INTO Branches VALUES ('B2', 'Prog1');
INSERT INTO Branches VALUES ('B1', 'Prog2');

INSERT INTO Students VALUES ('1111111111', 'N1', 'ls1', 'Prog1');
INSERT INTO Students VALUES ('2222222222', 'N2', 'ls2', 'Prog1');
INSERT INTO Students VALUES ('3333333333', 'N3', 'ls3', 'Prog2');
INSERT INTO Students VALUES ('4444444444', 'N4', 'ls4', 'Prog1');
INSERT INTO Students VALUES ('5555555555', 'Nx', 'ls5', 'Prog2');
INSERT INTO Students VALUES ('6666666666', 'Nx', 'ls6', 'Prog2');

INSERT INTO Departments VALUES ('Dep1', 'D1');

INSERT INTO Courses VALUES ('CCC111', 'C1', 22.5, 'Dep1');
INSERT INTO Courses VALUES ('CCC222', 'C2', 20,   'Dep1');
INSERT INTO Courses VALUES ('CCC333', 'C3', 30,   'Dep1');
INSERT INTO Courses VALUES ('CCC444', 'C4', 40,   'Dep1');
INSERT INTO Courses VALUES ('CCC555', 'C5', 50,   'Dep1');
INSERT INTO Courses VALUES ('CCC666', 'C6', 35,   'Dep1');
INSERT INTO Courses VALUES ('CCC777', 'C7', 25,   'Dep1');

INSERT INTO LimitedCourses VALUES ('CCC222', 2);
INSERT INTO LimitedCourses VALUES ('CCC333', 2);
INSERT INTO LimitedCourses VALUES ('CCC666', 1);
INSERT INTO LimitedCourses VALUES ('CCC777', 2);

INSERT INTO Classifications VALUES ('math');
INSERT INTO Classifications VALUES ('research');
INSERT INTO Classifications VALUES ('seminar');

INSERT INTO Classified VALUES ('CCC333', 'math');
INSERT INTO Classified VALUES ('CCC444', 'research');
INSERT INTO Classified VALUES ('CCC444','seminar');

INSERT INTO StudentBranches VALUES ('2222222222', 'B1', 'Prog1');
INSERT INTO StudentBranches VALUES ('3333333333', 'B1', 'Prog2');
INSERT INTO StudentBranches VALUES ('4444444444', 'B1', 'Prog1');

INSERT INTO MandatoryProgram VALUES ('CCC111', 'Prog1');

INSERT INTO MandatoryBranch VALUES ('CCC333', 'B1', 'Prog1');
INSERT INTO MandatoryBranch VALUES ('CCC555', 'B1', 'Prog2');

INSERT INTO RecommendedBranch VALUES ('CCC222', 'B1', 'Prog1');
INSERT INTO RecommendedBranch VALUES ('CCC333', 'B2', 'Prog1');

INSERT INTO Registered VALUES ('1111111111', 'CCC111');
INSERT INTO Registered VALUES ('1111111111', 'CCC222');
INSERT INTO Registered VALUES ('2222222222', 'CCC222');
INSERT INTO Registered VALUES ('5555555555', 'CCC333');
INSERT INTO Registered VALUES ('1111111111', 'CCC333');
INSERT INTO Registered VALUES ('1111111111', 'CCC777');
INSERT INTO Registered VALUES ('2222222222', 'CCC777');
INSERT INTO Registered VALUES ('3333333333', 'CCC777');

INSERT INTO WaitingList VALUES ('3333333333', 'CCC333');
INSERT INTO WaitingList VALUES ('2222222222', 'CCC333');
INSERT INTO WaitingList VALUES ('6666666666', 'CCC333');
INSERT INTO WaitingList VALUES ('4444444444', 'CCC777');

INSERT INTO Taken VALUES('2222222222', 'CCC111', 'U');
INSERT INTO Taken VALUES('2222222222', 'CCC222', 'U');
INSERT INTO Taken VALUES('2222222222', 'CCC444', 'U');

INSERT INTO Taken VALUES('4444444444', 'CCC111', '5');
INSERT INTO Taken VALUES('4444444444', 'CCC222', '5');
INSERT INTO Taken VALUES('4444444444', 'CCC333', '5');
INSERT INTO Taken VALUES('4444444444', 'CCC444', '5');

INSERT INTO Taken VALUES('5555555555', 'CCC111', '5');
INSERT INTO Taken VALUES('5555555555', 'CCC333', '5');
INSERT INTO Taken VALUES('5555555555', 'CCC444', '5');

INSERT INTO Prerequisite VALUES('CCC555', 'CCC222');
INSERT INTO Prerequisite VALUES('CCC555', 'CCC333');

-- Views

CREATE VIEW BasicInformation AS
  (SELECT DISTINCT idnr, Students.name, login, Students.program, branch
		  FROM Students
		  LEFT OUTER JOIN StudentBranches ON Students.idnr = StudentBranches.student
		  ORDER BY idnr
);

CREATE VIEW FinishedCourses AS 
  (SELECT student, course, grade, credits
		  FROM Taken
		  JOIN Courses ON course = Courses.code
		  ORDER BY student
);

CREATE VIEW PassedCourses AS 
  (SELECT student, course, credits
		  FROM Taken
		  JOIN Courses ON course = Courses.code
		  WHERE grade != 'U'
		  ORDER BY student
);

CREATE VIEW Registrations (student, course, status) AS 
  (SELECT WaitingList.student, WaitingList.course, 'waiting'
	      FROM WaitingList
		  UNION
		  SELECT Registered.student, Registered.course, 'registered'
		  FROM Registered
		  ORDER BY course
);

CREATE VIEW UnreadMandatory (student, course) AS 
  (SELECT student, course
		  FROM StudentBranches, Mandatorybranch
		  WHERE StudentBranches.program = Mandatorybranch.program AND StudentBranches.branch = Mandatorybranch.branch
		  UNION
          SELECT idnr, course
          FROM Students, Mandatoryprogram
		  WHERE Students.program = Mandatoryprogram.program
		  EXCEPT
		  SELECT student, course
		  FROM Taken
		  WHERE grade != 'U'
);

CREATE VIEW PassedMathCourses AS
  (SELECT student, sum(credits) AS credits
		  FROM PassedCourses, Classified
		  WHERE classification = 'math' AND PassedCourses.course = Classified.course
		  GROUP BY student
);

CREATE VIEW PassedResearchCourses AS
  (SELECT student, sum(credits) AS credits
	      FROM PassedCourses, Classified
		  WHERE classification = 'research' AND PassedCourses.course = Classified.course
		  GROUP BY student
);

CREATE VIEW PassedSeminarCourses AS
  (SELECT student, count(student) AS nrCourses
	      FROM PassedCourses, Classified
		  WHERE classification = 'seminar' AND PassedCourses.course = Classified.course
		  GROUP BY student
);

CREATE VIEW PassedRecommendedCourses AS
  (SELECT StudentBranches.student, sum(credits) AS credits
		  FROM PassedCourses, RecommendedBranch, StudentBranches
		  WHERE PassedCourses.course = RecommendedBranch.course 
		  AND StudentBranches.branch = RecommendedBranch.branch 
		  AND StudentBranches.student = PassedCourses.student
		  AND StudentBranches.program = RecommendedBranch.program
		  GROUP BY StudentBranches.student
);

CREATE VIEW Qualified AS
WITH
	StudentID AS
        (SELECT DISTINCT idnr AS student FROM Students),
	PassedMandatory AS
		(SELECT DISTINCT student, FALSE AS passedMandatory
		 FROM UnreadMandatory),
	HasBranch AS
		(SELECT DISTINCT student, TRUE AS hasBranch
		 FROM StudentBranches),
	HasRecommendedCredits AS
		(SELECT DISTINCT student, TRUE AS hasRecommendedCredits
		 FROM PassedRecommendedCourses
		 WHERE credits >= 10),
	HasMathCredits AS
		(SELECT DISTINCT student, TRUE AS hasMathCredits
		 FROM PassedMathCourses
		 WHERE PassedMathCourses.credits >= 20),
	HasResearchCredits AS
		(SELECT DISTINCT student, TRUE AS hasResearchCredits
		 FROM PassedResearchCourses
		 WHERE PassedResearchCourses.credits >= 10),
	HasSeminarCourse AS
		(SELECT DISTINCT student, TRUE AS hasSeminarCourse
		 FROM PassedSeminarCourses)
SELECT StudentID.student, 
COALESCE(passedMandatory, TRUE) AS passedMandatory, 
COALESCE(hasBranch, FALSE) AS hasBranch, 
COALESCE(hasRecommendedCredits, FALSE) AS hasRecommendedCredits,
COALESCE(hasMathCredits, FALSE) AS hasMathCredits,
COALESCE(hasResearchCredits, FALSE) AS hasResearchCredits,
COALESCE(hasSeminarCourse, FALSE) AS hasSeminarCourse FROM StudentID
LEFT OUTER JOIN PassedMandatory ON PassedMandatory.student = StudentID.student
LEFT OUTER JOIN HasBranch ON HasBranch.student = StudentID.student
LEFT OUTER JOIN HasRecommendedCredits ON HasRecommendedCredits.student = StudentID.student
LEFT OUTER JOIN HasMathCredits ON HasMathCredits.student = StudentID.student
LEFT OUTER JOIN HasResearchCredits ON HasResearchCredits.student = StudentID.student
LEFT OUTER JOIN HasSeminarCourse ON HasSeminarCourse.student = StudentID.student;
	
CREATE VIEW IsQualified AS (
    SELECT student, TRUE AS isQualified FROM Qualified
    WHERE Qualified.passedMandatory = TRUE AND
          Qualified.hasBranch = TRUE AND
          Qualified.hasRecommendedCredits = TRUE AND 
          Qualified.hasMathCredits = TRUE AND
          Qualified.hasResearchCredits = TRUE AND
          Qualified.hasSeminarCourse = TRUE
);

CREATE VIEW PathToGraduation AS 
WITH
    StudentID AS
		(SELECT DISTINCT idnr AS student FROM Students),
    TotalCredits AS	  
		(SELECT student, sum(credits) AS totalCredits FROM PassedCourses
		 GROUP BY student),
	MandatoryLeft AS
		(SELECT student, count(student) AS mandatoryleft FROM UnreadMandatory
		 GROUP BY student),
	MathCredits AS
		(SELECT student, credits AS mathCredits FROM PassedMathCourses
		 GROUP BY student, mathCredits),
	ResearchCredits AS
		(SELECT student, credits AS researchCredits FROM PassedResearchCourses
		 GROUP BY student, researchCredits),
	SeminarCourses AS
		(SELECT student, nrCourses AS seminarCourses FROM PassedSeminarCourses
		 GROUP BY student, seminarCourses),
	isQualified AS
		(SELECT student, TRUE AS isQualified FROM IsQualified
		 GROUP BY student, isQualified)
SELECT StudentID.student, 
COALESCE(totalCredits, 0) AS totalCredits, 
COALESCE(mandatoryleft, 0) AS mandatoryleft, 
COALESCE(mathCredits, 0) AS mathCredits, 
COALESCE(researchCredits, 0) AS researchCredits,
COALESCE(seminarCourses, 0) AS seminarCourses,
COALESCE(isQualified, FALSE) AS qualified FROM StudentID
LEFT OUTER JOIN TotalCredits ON TotalCredits.student = StudentID.student
LEFT OUTER JOIN MandatoryLeft ON MandatoryLeft.student = StudentID.student
LEFT OUTER JOIN MathCredits ON MathCredits.student = StudentID.student
LEFT OUTER JOIN ResearchCredits ON ResearchCredits.student = StudentID.student
LEFT OUTER JOIN SeminarCourses ON SeminarCourses.student = StudentID.student
LEFT OUTER JOIN IsQualified ON IsQualified.student = StudentID.student;