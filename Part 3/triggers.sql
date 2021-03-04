CREATE OR REPLACE VIEW CourseQueuePositions AS (
	SELECT student, course, ROW_NUMBER() OVER (PARTITION BY course ORDER BY position) AS place
	FROM WaitingList
	GROUP BY course, student
);

CREATE OR REPLACE FUNCTION registerCourse () RETURNS TRIGGER AS $$
DECLARE nrStudents INT;
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
	INSERT INTO WaitingList VALUES (NEW.student, NEW.course);
	ELSE INSERT INTO Registered VALUES (NEW.student, NEW.course);
	END IF;	
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION unregisterCourse () RETURNS TRIGGER AS $$
DECLARE registeringStudent CHAR(10);
DECLARE registeringCourse CHAR(6);
DECLARE nrStudents INT;
DECLARE	maxCapacity INT;
BEGIN
	IF EXISTS (SELECT student FROM WaitingList 
			   WHERE student = OLD.student AND course = OLD.course)
	THEN 
	DELETE FROM WaitingList WHERE student = OLD.student AND course = OLD.course;
	ELSIF EXISTS (SELECT student FROM Registered
				  WHERE student = OLD.student AND course = OLD.course)
	THEN 
	DELETE FROM Registered WHERE student = OLD.student AND course = OLD.course;
	maxCapacity := (SELECT capacity FROM LimitedCourses
				   WHERE OLD.course = course);
	nrStudents := (SELECT COUNT (student) FROM Registered
				  WHERE OLD.course = Registered.course);
		IF OLD.course IN (SELECT LimitedCourses.course FROM LimitedCourses) AND
		maxCapacity > nrStudents
		THEN
			IF EXISTS (SELECT student FROM CourseQueuePositions
					   WHERE course = OLD.course)
			THEN
			registeringStudent := (SELECT student FROM CourseQueuePositions
								   WHERE course = OLD.course AND place = 1);
			registeringCourse := (SELECT course FROM CourseQueuePositions
								  WHERE course = OLD.course AND place = 1);
			DELETE FROM WaitingList WHERE student = registeringStudent AND course = registeringCourse;
			INSERT INTO Registered VALUES (registeringStudent, registeringCourse);
			END IF;
		END IF;
	END IF;
	RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER courseRegistration
INSTEAD OF INSERT OR UPDATE ON Registrations
FOR EACH ROW
EXECUTE FUNCTION registerCourse ();

CREATE TRIGGER courseUnregistration
INSTEAD OF DELETE ON Registrations
FOR EACH ROW
EXECUTE FUNCTION unregisterCourse ();