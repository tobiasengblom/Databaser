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
'finished', (SELECT jsonb_agg (jsonb_build_object (
			'course', FinishedCoursesWithNames.name, 
			'code', FinishedCoursesWithNames.course, 
			'credits', FinishedCoursesWithNames.credits, 
			'grade', FinishedCoursesWithNames.grade)) 
			FROM FinishedCoursesWithNames WHERE student = BasicInformation.idnr),
'registered', (SELECT jsonb_agg (jsonb_build_object (
			'course', RegistrationsWithNames.name, 
			'code', RegistrationsWithNames.course, 
			'status', status)) 
			FROM RegistrationsWithNames WHERE student = BasicInformation.idnr),
'seminarCourses', (SELECT seminarCourses FROM PathToGraduation WHERE student = BasicInformation.idnr),
'mathCredits', (SELECT mathCredits FROM PathToGraduation WHERE student = BasicInformation.idnr),
'researchCredits', (SELECT researchCredits FROM PathToGraduation WHERE student = BasicInformation.idnr),
'totalCredits', (SELECT totalCredits FROM PathToGraduation WHERE student = BasicInformation.idnr),
'canGraduate', (SELECT qualified FROM PathToGraduation WHERE student = BasicInformation.idnr)) 
AS 
jsondata 
FROM 
BasicInformation
WHERE 
idnr = '2222222222'
GROUP BY 
idnr, 
BasicInformation.name, 
login, 
program, 
branch;