\i tables.sql
\i inserts.sql

CREATE VIEW BasicInformation AS
  (SELECT DISTINCT idnr, Students.name, login, Students.program, branch
		  FROM Students
		  LEFT OUTER JOIN StudentBranches ON Students.idnr = StudentBranches.student
		  ORDER BY idnr
);
-- SELECT idnr, name, login, program, branch FROM BasicInformation;

CREATE VIEW FinishedCourses AS 
  (SELECT student, course, grade, credits
		  FROM Taken
		  JOIN Courses ON course = Courses.code
		  ORDER BY student
);
-- SELECT student, course, grade, credits FROM FinishedCourses;

CREATE VIEW PassedCourses AS 
  (SELECT student, course, credits
		  FROM Taken
		  JOIN Courses ON course = Courses.code
		  WHERE grade != 'U'
		  ORDER BY student
);
-- SELECT student, course, credits FROM PassedCourses;

CREATE VIEW Registrations (student, course, status) AS 
  (SELECT WaitingList.student, WaitingList.course, 'waiting'
	      FROM WaitingList
		  UNION
		  SELECT Registered.student, Registered.course, 'registered'
		  FROM Registered
		  ORDER BY course
);
-- SELECT student, course, status FROM Registrations;

CREATE VIEW UnreadMandatory (student, course) AS 
  (SELECT student, course
		  FROM StudentBranches, Mandatorybranch
		  WHERE StudentBranches.program = Mandatorybranch.program AND StudentBranches.branch = Mandatorybranch.branch
		  UNION
          SELECT idnr, course
          FROM Students, Mandatoryprogram
		  WHERE Students.program = Mandatoryprogram.program
		  EXCEPT
		  SELECT student, course
		  FROM Taken
		  WHERE grade != 'U'
);
-- SELECT student, course FROM UnreadMandatory;

CREATE VIEW PassedMathCourses AS
  (SELECT student, sum(credits) AS credits
		  FROM PassedCourses, Classified
		  WHERE classification = 'math' AND PassedCourses.course = Classified.course
		  GROUP BY student
);
-- SELECT student, credits FROM PassedMathCourses;

CREATE VIEW PassedResearchCourses AS
  (SELECT student, sum(credits) AS credits
	      FROM PassedCourses, Classified
		  WHERE classification = 'research' AND PassedCourses.course = Classified.course
		  GROUP BY student
);
-- SELECT student, credits FROM PassedResearchCourses;

CREATE VIEW PassedSeminarCourses AS
  (SELECT student, count(student) AS nrCourses
	      FROM PassedCourses, Classified
		  WHERE classification = 'seminar' AND PassedCourses.course = Classified.course
		  GROUP BY student
);
-- SELECT student, nrCourses FROM PassedSeminarCourses;

CREATE VIEW PassedRecommendedCourses AS
  (SELECT StudentBranches.student, sum(credits) AS credits
		  FROM PassedCourses, RecommendedBranch, StudentBranches
		  WHERE PassedCourses.course = RecommendedBranch.course 
		  AND StudentBranches.branch = RecommendedBranch.branch 
		  AND StudentBranches.student = PassedCourses.student
		  AND StudentBranches.program = RecommendedBranch.program
		  GROUP BY StudentBranches.student
);
-- SELECT student, credits FROM PassedRecommendedCourses;

CREATE VIEW Qualified AS
WITH
	StudentID AS
        (SELECT DISTINCT idnr AS student FROM Students),
	PassedMandatory AS
		(SELECT DISTINCT student, FALSE AS passedMandatory
		 FROM UnreadMandatory),
	HasBranch AS
		(SELECT DISTINCT student, TRUE AS hasBranch
		 FROM StudentBranches),
	HasRecommendedCredits AS
		(SELECT DISTINCT student, TRUE AS hasRecommendedCredits
		 FROM PassedRecommendedCourses
		 WHERE credits >= 10),
	HasMathCredits AS
		(SELECT DISTINCT student, TRUE AS hasMathCredits
		 FROM PassedMathCourses
		 WHERE PassedMathCourses.credits >= 20),
	HasResearchCredits AS
		(SELECT DISTINCT student, TRUE AS hasResearchCredits
		 FROM PassedResearchCourses
		 WHERE PassedResearchCourses.credits >= 10),
	HasSeminarCourse AS
		(SELECT DISTINCT student, TRUE AS hasSeminarCourse
		 FROM PassedSeminarCourses)
SELECT StudentID.student, 
COALESCE(passedMandatory, TRUE) AS passedMandatory, 
COALESCE(hasBranch, FALSE) AS hasBranch, 
COALESCE(hasRecommendedCredits, FALSE) AS hasRecommendedCredits,
COALESCE(hasMathCredits, FALSE) AS hasMathCredits,
COALESCE(hasResearchCredits, FALSE) AS hasResearchCredits,
COALESCE(hasSeminarCourse, FALSE) AS hasSeminarCourse FROM StudentID
LEFT OUTER JOIN PassedMandatory ON PassedMandatory.student = StudentID.student
LEFT OUTER JOIN HasBranch ON HasBranch.student = StudentID.student
LEFT OUTER JOIN HasRecommendedCredits ON HasRecommendedCredits.student = StudentID.student
LEFT OUTER JOIN HasMathCredits ON HasMathCredits.student = StudentID.student
LEFT OUTER JOIN HasResearchCredits ON HasResearchCredits.student = StudentID.student
LEFT OUTER JOIN HasSeminarCourse ON HasSeminarCourse.student = StudentID.student;
-- SELECT student, passedMandatory, hasBranch, hasRecommendedCredits, hasMathCredits, hasResearchCredits, hasSeminarCourse FROM Qualified;
	
CREATE VIEW IsQualified AS (
    SELECT student, TRUE AS isQualified FROM Qualified
    WHERE Qualified.passedMandatory = TRUE AND
          Qualified.hasBranch = TRUE AND
          Qualified.hasRecommendedCredits = TRUE AND 
          Qualified.hasMathCredits = TRUE AND
          Qualified.hasResearchCredits = TRUE AND
          Qualified.hasSeminarCourse = TRUE
);
-- SELECT student, isQualified FROM isQualified;

CREATE VIEW PathToGraduation AS 
WITH
    StudentID AS
		(SELECT DISTINCT idnr AS student FROM Students),
    TotalCredits AS	  
		(SELECT student, sum(credits) AS totalCredits FROM PassedCourses
		 GROUP BY student),
	MandatoryLeft AS
		(SELECT student, count(student) AS mandatoryleft FROM UnreadMandatory
		 GROUP BY student),
	MathCredits AS
		(SELECT student, credits AS mathCredits FROM PassedMathCourses
		 GROUP BY student, mathCredits),
	ResearchCredits AS
		(SELECT student, credits AS researchCredits FROM PassedResearchCourses
		 GROUP BY student, researchCredits),
	SeminarCourses AS
		(SELECT student, nrCourses AS seminarCourses FROM PassedSeminarCourses
		 GROUP BY student, seminarCourses),
	isQualified AS
		(SELECT student, TRUE AS isQualified FROM IsQualified
		 GROUP BY student, isQualified)
SELECT StudentID.student, 
COALESCE(totalCredits, 0) AS totalCredits, 
COALESCE(mandatoryleft, 0) AS mandatoryleft, 
COALESCE(mathCredits, 0) AS mathCredits, 
COALESCE(researchCredits, 0) AS researchCredits,
COALESCE(seminarCourses, 0) AS seminarCourses,
COALESCE(isQualified, FALSE) AS qualified FROM StudentID
LEFT OUTER JOIN TotalCredits ON TotalCredits.student = StudentID.student
LEFT OUTER JOIN MandatoryLeft ON MandatoryLeft.student = StudentID.student
LEFT OUTER JOIN MathCredits ON MathCredits.student = StudentID.student
LEFT OUTER JOIN ResearchCredits ON ResearchCredits.student = StudentID.student
LEFT OUTER JOIN SeminarCourses ON SeminarCourses.student = StudentID.student
LEFT OUTER JOIN IsQualified ON IsQualified.student = StudentID.student;
-- SELECT student, totalCredits, mandatoryleft, mathCredits, researchCredits, seminarCourses, qualified FROM PathToGraduation ORDER BY student;
	
		  
		  	