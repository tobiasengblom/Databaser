-- psql -v ON_ERROR_STOP=1 -U postgres portal

\c portal
\set QUIT true
SET client_min_messages TO WARNING;
DROP SCHEMA public CASCADE;
CREATE SCHEMA public;
GRANT ALL ON SCHEMA public TO postgres;
\set QUIET false

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
