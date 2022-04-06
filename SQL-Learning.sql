CREATE TABLE hallgatok(
neptunID char(6) not null,
vnev varchar2(50) not null,
szuldatum date not null,
CONSTRAINT h_pk PRIMARY KEY (neptunID),
CONSTRAINT h_oe CHECK(neptunID LIKE 'OE%')
);

CONSTRAINT k_CK CHECK(kredit>=0),
CONSTRAINT k_fk FOREIGN KEY (elofeltetelID)
REFERENCES kurzusok (kurzusID)

ALTER TABLE leckekonyv ADD erdemjegy NUMBER(1);

ALTER TABLE leckekonyv
ADD CONSTRAINT l_ck2 CHECK (erdemjegy BETWEEN 1 and 5);

INSERT INTO hallgatok
VALUES ('OEK255','Bekre','Pál',TO_DATE('1995-08-20','YYYY-MM-DD'));

ELECT k.nev Kurzusnév, k2.nev Előfeltételnév
FROM kurzusok k INNER JOIN kurzusok k2 ON k2.kurzusID = k.elofeltetelID
ORDER BY Kurzusnév;

SELECT vnev||''||knev Név, nev, NVL(erdemjegy, 0) Erdemjegy
FROM LECKEKONYV 
INNER JOIN kurzusok USING(kurzusID)
RIGHT JOIN hallgatok USING(neptunID);

SELECT vnev||''||knev Név, nev
FROM HALLGATOK h 
FULL OUTER JOIN LECKEKONYV l ON h.NEPTUNID = l.NEPTUNID
FULL OUTER JOIN kurzusok k ON k.kurzusID = l.KURZUSID
WHERE l.NEPTUNId IS NULL AND l.KURZUSID IS NULL ;

SELECT UPPER(SUBSTR(vnev,1,2)||SUBSTR(knev,-2,2))||SUBSTR(TO_CHAR(szuldatum,'YYYY'),3,2)
FROM hallgatok;

UPDATE kurzusok SET kredit = kredit+1
WHERE ELOFELTETELID is not null;

DELETE FROM leckekonyv WHERE kurzusID in(2,4);
DELETE FROM leckekonyv WHERE kurzusid = 2 OR kurzusid = 4;

SELECT nev Kurzus, PRIOR nev ELőfeltétel, LEVEL 
from kurzusok
START WITH kurzusid = 4
CONNECT BY PRIOR kurzusid = ELOFELTETELID
ORDER BY level;



CREATE TABLE Education(
Employee_id number,
Education_level varchar2(50),
Skill_area varchar2(50),
Languages varchar2(50),
Education_finished date,
CONSTRAINT e_ck CHECK(Education_level NOT LIKE 'BA'),
CONSTRAINT e_pk PRIMARY KEY(Employee_id),
CONSTRAINT e_fk FOREIGN KEY(Employee_id)
REFERENCES Employees(Employee_id)
);

INSERT INTO Education
VALUES (100,'MSc','Finance','English',to_date('2003-01-31','YYYY-MM-DD'));

INSERT INTO Education
VALUES (108,'BSc','Management','German',TO_DATE('2003-06-14','YYYY-MM-DD'));

INSERT INTO Education
VALUES (132,'MA','History','English, Latin',TO_DATE('2006-02-14','YYYY-MM-DD'));

INSERT INTO Education
VALUES (105,'Highschool','IT administrator','English, German',TO_DATE('2006-01-30','YYYY-MM-DD'));

SELECT Skill_area, salary FROM education INNER JOIN EMPLOYEES USING(employee_id)
WHERE EDUCATION_LEVEL IN('MSc','BSc','MA')
ORDER BY salary;

SELECT First_name||' '||Last_name Dolgozó, round((hire_date-education.EDUCATION_FINISHED)/-30) hónapok
FROM Employees INNER JOIN education USING(employee_id)
WHERE hire_date < education.EDUCATION_FINISHED;

CREATE VIEW becslés AS
SELECT First_name||' '||Last_name Alkalmazott, Employee_id, salary, commission_pct,
CASE 
  WHEN salary+(salary*(NVL(commission_pct,0))) < 3000 THEN 'Highschool'
  WHEN salary+(salary*(NVL(commission_pct,0))) BETWEEN 3001 AND 6000 THEN 'MA'
  WHEN salary+(salary*(NVL(commission_pct,0))) BETWEEN 6001 AND 9000 THEN 'BSc'
  ELSE 'MSc'
END "becsöltérték"
FROM EMPLOYEES;

SELECT Last_name dolgozó, PRIOR last_name Felettes, CONNECT_BY_ROOT last_name CEO,
CASE level-1 
  when 0 then 'Tulajdonos'
  when 1 then 'Helyettes'
  else 'Dolgozó'
END "beosztások"
FROM EMPLOYEES
CONNECT BY PRIOR employee_ID = manager_ID
ORDER BY level;

UPDATE EMPLOYEES SET salary = salary+salary*(NVL(commission_pct,0));

DROP VIEW becslés;
DROP TABLE education;



CREATE TABLE telefonok(
gyarto varchar2(50),
tipus varchar2(50),
gyartas_kezdete date not null,
eladott_db NUMBER,
ertekeles NUMBER,
CONSTRAINT t_pk PRIMARY KEY (gyarto,tipus),
CONSTRAINT t_eladottdbck CHECK (eladott_db > 99999),
CONSTRAINT t_ertekelesck CHECK (ertekeles BETWEEN 1 AND 5)
);


CREATE TABLE employees2 AS
SELECT * FROM employees;

ALTER TABLE employees2
ADD gyarto varchar2(50);

ALTER TABLE employees2
ADD tipus varchar2(50);

INSERT INTO telefonok
VALUES('Apple','Iphone',TO_DATE('2007-01-09','YYYY-MM-DD'),120000,4);

INSERT INTO telefonok
VALUES('Samsung','Galaxy',TO_DATE('2009-06-29','YYYY-MM-DD'),180000,3);

INSERT INTO telefonok
VALUES ('Xiaomi','Redmi',TO_DATE('2013-07-01','YYYY-MM-DD'),250000,5);

INSERT INTO telefonok
VALUES ('ZTE','Blade',TO_DATE('2010-09-21','YYYY-MM-DD'),200000,4);

INSERT INTO telefonok
VALUES('HTC','One',TO_DATE('2012-04-26','YYYY-MM-DD'),111000,2);

UPDATE employees2
SET gyarto='Apple',tipus='Iphone'
WHERE department_id = 50 AND job_id= 'ST_MAN';

UPDATE employees2
SET gyarto='Samsung',tipus='Galaxy'
WHERE department_id <> 50;

UPDATE employees2
SET gyarto='HTC', tipus='One'
WHERE Last_name LIKE 'A%' 
AND salary+salary*(NVL(commission_pct,0)) BETWEEN 3000 AND 15000
AND hire_date > to_date('2002-01-01','YYYY-MM-DD');

SELECT last_name||' '||first_name as teljesnev, e.gyarto,e.tipus, eladott_db
FROM employees2 e, telefonok t
WHERE e.gyarto = t.gyarto and e.tipus = t.tipus
AND t.ERTEKELES >= 4
ORDER BY last_name;

SELECT last_name, job_title, e.gyarto, e.tipus, ertekeles, department_id
FROM employees2 e INNER JOIN JOBS USING(job_ID)
Inner join telefonok t on e.gyarto = t.gyarto and e.tipus = t.tipus
WHERE department_id IN (50,80,100)
ORDER BY department_id;

DELETE FROM telefonok
WHERE ERTEKELES >= 4;

ALTER TABLE employees2
DROP COLUMN gyarto;

ALTER TABLE employees2
DROP COLUMN tipus;

DROP TABLE telefonok;


SYS_CONNECT_BY_PATH(last_name, '/') "Út"

CREATE TABLE Feedback(
Feedback_id number,
Employee_id number,
Feedback_date date,
Feedback_empid number,
Rating number,
CONSTRAINT f_pk PRIMARY KEY(feedback_id),
CONSTRAINT f_fk FOREIGN KEY (employee_id)
REFERENCES EMPLOYEES(employee_id),
CONSTRAINT f_ck CHECK(rating between 1 and 5)
);

INSERT INTO Feedback
VALUES(10,101,TO_DATE('2005-10-20','YYYY-MM-DD'),108,3);

INSERT INTO Feedback
VALUES(20,109,TO_DATE('2006-03-14','YYYY-MM-DD'),124,5);

INSERT INTO Feedback
VALUES(30,131,TO_DATE('2005-07-27','YYYY-MM-DD'),124,5);

INSERT INTO Feedback
VALUES(40,104,TO_DATE('2006-02-15','YYYY-MM-DD'),104,4);

SELECT department_id, last_name||' '||first_name Teljesnev
FROM EMPLOYEES INNER JOIN FEEDBACK USING(employee_id)
WHERE rating >= 4
ORDER BY last_name;

SELECT last_name||' '||first_name Teljesnev, feedback_date, ROUND((Sysdate-feedback_date)/30,2) as "Months"
FROM EMPLOYEES INNER JOIN FEEDBACK USING(employee_id)
WHERE feedback_date < TO_DATE('2006-01-01','YYYY-MM-DD');

CREATE VIEW review AS
SELECT e.employee_id,e.department_id, f.FEEDBACK_DATE,
CASE
  WHEN rating = 5 THEN 'EXCELLENT'
  WHEN rating = 4 THEN 'GOOD'
  WHEN rating = 3 THEN 'Medium'
  WHEN rating = 2 THEN 'Minimum'
  ELSE 'Bad'
END "rating"
FROM EMPLOYEES e INNER JOIN FEEDBACK f ON e.employee_id = f.employee_id;

SELECT last_name alkalmazott, PRIOR last_name vezető, CONNECT_BY_ROOT last_name cégvezető,level depth,
CASE level-1 
  when 0 then 'Cégvezető'
  when 1 then 'Vezető'
  else 'ALkalmazott'
END "beosztások"
FROM employees
CONNECT BY PRIOR employee_id = manager_id
ORDER BY level;


DELETE FROM feedback
WHERE FEEDBACK_DATE < TO_DATE('2006-01-01','YYYY-MM-DD');

DROP VIEW REVIEW;
DROP TABLE feedback;








