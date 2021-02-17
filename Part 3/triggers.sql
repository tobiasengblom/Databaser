CREATE VIEW CourseQueuePositions AS (
	SELECT course, student, position AS place
	FROM WaitingList
);
SELECT course, student, place FROM CourseQueuePositions;