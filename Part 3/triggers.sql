CREATE OR REPLACE VIEW CourseQueuePositions AS (
	SELECT course, student, position AS place
	FROM WaitingList
);
-- SELECT course, student, place FROM CourseQueuePositions;

CREATE OR REPLACE FUNCTION registerCourse () RETURNS TRIGGER AS $$
DECLARE nrStudents INT;
DECLARE	maxCapacity INT;
DECLARE nrOfPrerequisites INT;
DECLARE nrOfPassedPrerequisites INT;
DECLARE lastWaitingPos INT;
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
								WHERE student = NEW.student AND Prerequisite.course = NEW.course);
		IF (nrOfPrerequisites > nrOfPassedPrerequisites)
		THEN RAISE EXCEPTION 'Student have not passed all prerequisite courses';
		END IF;
	END IF;	
	maxCapacity := (SELECT capacity FROM LimitedCourses
					WHERE NEW.course = course);
	nrStudents := (SELECT COUNT (student) FROM Registered
				   WHERE NEW.course = Registered.course);
	IF (nrStudents >= maxCapacity)
	THEN 
	lastWaitingPos := (SELECT COALESCE (MAX (position), 0) FROM WaitingList WHERE WaitingList.course = NEW.course);
	INSERT INTO WaitingList VALUES (NEW.student, NEW.course, lastWaitingPos + 1);
	ELSE INSERT INTO Registered VALUES (NEW.student, NEW.course);
	END IF;	
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION unregisterCourse () RETURNS TRIGGER AS $$
BEGIN
	IF NOT EXISTS (SELECT idnr FROM Students WHERE idnr = OLD.student)
	THEN RAISE EXCEPTION 'Student in input does not exist';
	ELSIF NOT EXISTS (SELECT code FROM Courses WHERE code = OLD.course)
	THEN RAISE EXCEPTION 'Course in input does not exist';
	END IF;
	
	IF NOT EXISTS (SELECT Registrations.student FROM Registrations
				   WHERE Registrations.course = OLD.course)
	THEN RAISE EXCEPTION 'Student not registered on this course';
	END IF;
	
	IF EXISTS (SELECT student FROM WaitingList 
			   WHERE WaitingList.student = OLD.student AND WaitingList.course = OLD.course)
	THEN 
	DELETE FROM WaitingList WHERE WaitingList.student = OLD.student AND WaitingList.course = OLD.course;
	
	ELSIF EXISTS (SELECT student FROM Registered
				  WHERE Registered.student = OLD.student AND Registered.course = OLD.course)
	THEN 
	DELETE FROM Registered WHERE Registered.student = OLD.student AND Registered.course = OLD.course;
		IF OLD.course IN (SELECT LimitedCourses.course FROM LimitedCourses)
		THEN 
		END IF;
	END IF;
	RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER courseRegistration
INSTEAD OF INSERT ON Registrations
FOR EACH ROW
EXECUTE FUNCTION registerCourse ();

CREATE TRIGGER courseUnregistration
INSTEAD OF DELETE ON Registrations
FOR EACH ROW
EXECUTE FUNCTION unregisterCourse ();