CREATE OR REPLACE VIEW CourseQueuePositions AS (
	SELECT course, student, position AS place
	FROM WaitingList
);
-- SELECT course, student, place FROM CourseQueuePositions;

CREATE OR REPLACE FUNCTION registerCourse () RETURNS TRIGGER AS $$
DECLARE newStatus TEXT;
DECLARE	maxCapacity INT;
DECLARE nrOfPrerequisites INT;
DECLARE nrOfPassedPrerequisites INT;
BEGIN
	IF NOT EXISTS (SELECT idnr FROM Students WHERE idnr = NEW.student)
	THEN RAISE EXCEPTION 'Student in input does not exist';
	
	ELSIF NOT EXISTS (SELECT code FROM Courses WHERE code = NEW.course)
	THEN RAISE EXCEPTION 'Course in input does not exist';
	END IF;
	
	IF EXISTS (SELECT course FROM PassedCourses WHERE PassedCourses.course = NEW.course AND PassedCourses.student = NEW.student)
	THEN RAISE EXCEPTION 'Student already passed the course';
	
	ELSIF NEW.student IN (SELECT Registrations.student FROM Registrations
					   WHERE Registrations.course = NEW.course)
	THEN RAISE EXCEPTION 'Student already registered';
	
	ELSIF EXISTS (SELECT prerequisite FROM Prerequisite WHERE Prerequisite.course = NEW.course)
	THEN 
	nrOfPrerequisites := (SELECT COUNT (prerequisite) FROM Prerequisite WHERE Prerequisite.course = NEW.course);
	nrOfPassedPrerequisites := (SELECT COUNT (student) FROM Prerequisite JOIN PassedCourses ON prerequisite = PassedCourses.course
								WHERE student = NEW.student AND course = NEW.course);
		IF (nrOfPrerequisites > nrOfPassedPrerequisites)
		THEN RAISE EXCEPTION 'Student have not passed all prerequisite courses';
		END IF;
	END IF;
	newStatus := (SELECT status FROM Registrations
			   WHERE NEW.student = student AND NEW.course = course);
	maxCapacity := (SELECT capacity FROM LimitedCourses
			   WHERE NEW.course = course);
	/*
	ELSE IF (SELECT prerequisite FROM Prerequisite WHERE NEW.course = Prerequisite.course) NOTNULL
	THEN
		FOREACH 
	
	ELSE
		INSERT INTO Registrations 
		VALUES (NEW.student, NEW.course, NEW.status);
		*/
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER courseRegistration
INSTEAD OF INSERT ON Registrations
FOR EACH ROW
EXECUTE FUNCTION registerCourse ();