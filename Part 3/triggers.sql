CREATE OR REPLACE VIEW CourseQueuePositions AS (
	SELECT course, student, position AS place
	FROM WaitingList
);
-- SELECT course, student, place FROM CourseQueuePositions;

CREATE OR REPLACE FUNCTION registerCourse () RETURNS TRIGGER AS $$
DECLARE newStatus TEXT;
DECLARE	maxCapacity INT;
BEGIN
	newStatus := (SELECT status FROM Registrations
			   WHERE NEW.student = student AND NEW.course = course);
	maxCapacity := (SELECT capacity FROM LimitedCourses
			   WHERE NEW.course = course);
	IF (newStatus = 'registered' OR newStatus = 'waiting')
	THEN RAISE EXCEPTION 'ALREADY IN REGISTRATIONS VIEW';
	ELSE IF (NEW.course = LimitedCourses.course AND COUNT(Registered.student) < maxCapacity)
	THEN INSERT INTO
	ELSE
		INSERT INTO Registrations 
		VALUES (NEW.student, NEW.course, NEW.status);
	END IF;
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER courseRegistration
INSTEAD OF INSERT ON Registrations
FOR EACH ROW
EXECUTE FUNCTION registerCourse ();