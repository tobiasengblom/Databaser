/*
CREATE OR REPLACE VIEW StudentInfo AS
WITH 
	BasicInfo AS 
	(SELECT * FROM BasicInformation),
	Finished AS
	(SELECT Taken.student, Courses.name AS course, code, credits, grade
	 FROM Courses, Taken
	 WHERE code = Taken.course)
SELECT BasicInfo.idnr AS student,
	   name,
	   login,
	   program,
	   branch,
	   course,
	   code,
	   credits,
	   grade FROM BasicInfo
	   --COALESCE (status, NULL) AS status FROM BasicInfo
LEFT OUTER JOIN Finished ON Finished.student = BasicInfo.idnr
ORDER BY student;
*/

SELECT jsonb_build_object(
'student',idnr,
'name',name, 
'login', login, 
'program', program, 
'branch', branch,
'finished', jsonb_agg (jsonb_build_object ('course', jsonb_build_object ('name', name) AS courseNames FROM Courses) AS finished FROM FinishedCourses) 
) AS jsondata FROM BasicInformation WHERE idnr = '1111111111';