\c portal
\set QUIT true
SET client_min_messages TO WARNING;
DROP SCHEMA public CASCADE;
CREATE SCHEMA public;
GRANT ALL ON SCHEMA public TO postgres;
\set QUIET false
\i setup.sql

CREATE OR REPLACE VIEW FinishedCoursesWithNames AS (
	SELECT student, Courses.name, course, grade, FinishedCourses.credits
	FROM Courses, FinishedCourses
	WHERE Courses.code = course
);
SELECT * FROM FinishedCoursesWithNames;

CREATE OR REPLACE VIEW RegistrationsWithNames AS (
	SELECT student, Courses.name, course, status
	FROM Courses, Registrations
	WHERE Courses.code = course
);
SELECT * FROM RegistrationsWithNames;

SELECT jsonb_build_object(
'student', idnr,
'name', BasicInformation.name, 
'login', login, 
'program', program, 
'branch', branch,
'finished', jsonb_agg (jsonb_build_object ('course', FinishedCoursesWithNames.name, 'code', FinishedCoursesWithNames.course, 'credits', FinishedCoursesWithNames.credits, 'grade', FinishedCoursesWithNames.grade)),
'registered', jsonb_agg (jsonb_build_object ('course', RegistrationsWithNames.name, 'code', RegistrationsWithNames.course, 'status', status))
) AS jsondata FROM BasicInformation, FinishedCoursesWithNames, RegistrationsWithNames
WHERE idnr = '2222222222' AND 
FinishedCoursesWithNames.student = idnr AND
RegistrationsWithNames.student = idnr
GROUP BY BasicInformation.idnr, BasicInformation.name, BasicInformation.login, BasicInformation.program, BasicInformation.branch;