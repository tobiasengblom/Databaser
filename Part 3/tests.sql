\i setup.sql
\i triggers.sql

-- TEST #1: Register to an unlimited course.
-- EXPECTED OUTCOME: Pass
INSERT INTO Registrations VALUES ('6666666666', 'CCC111'); 

-- TEST #2: Register to a limited course.
-- EXPECTED OUTCOME: Pass
INSERT INTO Registrations VALUES ('6666666666', 'CCC666');

-- TEST #3: Waiting for a limited course.
-- EXPECTED OUTCOME: Pass
INSERT INTO Registrations VALUES ('5555555555', 'CCC666');

-- TEST #4: Unregister from an unlimited course. 
-- EXPECTED OUTCOME: Pass
DELETE FROM Registrations WHERE student = '6666666666' AND course = 'CCC111';

-- TEST #5: Unregister from a limited course without a waiting list.
-- EXPECTED OUTCOME: Pass
DELETE FROM Registrations WHERE student = '1111111111' AND course = 'CCC222';

-- TEST #6: Unregister from a limited course with a waiting list, when the student is registered.
-- EXPECTED OUTCOME: Pass
DELETE FROM Registrations WHERE student = '6666666666' AND course = 'CCC666';

-- TEST #7: Unregister from a limited course with a waiting list, when the student is in the middle of the waiting list.
-- EXPECTED OUTCOME: Pass
DELETE FROM Registrations WHERE student = '2222222222' AND course = 'CCC333';

-- TEST #8: Unregister from an overfull course with a waiting list.
-- EXPECTED OUTCOME: Pass
DELETE FROM Registrations WHERE student = '1111111111' AND course = 'CCC777';

-- TEST #9: Register to a course, when the student is already registered.
-- EXPECTED OUTCOME: Fail
-- INSERT INTO Registrations VALUES ('1111111111', 'CCC111');

-- TEST #10: Register to a course which the student has already passed.
-- EXPECTED OUTCOME: Fail
-- INSERT INTO Registrations VALUES ('1111111111', 'CCC111');

-- TEST #11: Register non existent student to a course.
-- EXPECTED OUTCOME: Fail
-- INSERT INTO Registrations VALUES ('8888888888', 'CCC111');

-- TEST #12: Register student to a non existent course.
-- EXPECTED OUTCOME: Fail
-- INSERT INTO Registrations VALUES ('1111111111', 'CCC999');

-- TEST #13: Register null student to a course.
-- EXPECTED OUTCOME: Fail
-- INSERT INTO Registrations VALUES (NULL, 'CCC111');

-- TEST #14: Register student to a null course.
-- EXPECTED OUTCOME: Fail
-- INSERT INTO Registrations VALUES ('1111111111', NULL);

-- TEST #15: Unregister student when student is not registered.
-- EXPECTED OUTCOME: Fail
DELETE FROM Registrations WHERE student = '6666666666' AND course = 'CCC777';