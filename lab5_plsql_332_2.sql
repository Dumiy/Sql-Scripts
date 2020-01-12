--1
CREATE OR REPLACE TRIGGER trig1_prof
      BEFORE INSERT OR UPDATE OR DELETE ON emp_prof
BEGIN
 IF (TO_CHAR(SYSDATE,'D') = 1) 
     OR (TO_CHAR(SYSDATE,'HH24') NOT BETWEEN 8 AND 20)
 THEN
    RAISE_APPLICATION_ERROR(-20001,'tabelul nu poate fi actualizat');
 END IF;
END;
/

DELETE FROM emp_prof
WHERE employee_id = 100;

DROP TRIGGER trig1_prof;

--2
--Varianta 1
CREATE OR REPLACE TRIGGER trig21_prof
  BEFORE UPDATE OF salary ON emp_prof
  FOR EACH ROW
BEGIN
  IF (:NEW.salary < :OLD.salary) THEN 
     RAISE_APPLICATION_ERROR(-20002,'salariul nu poate fi micsorat');
  END IF;
END;
/

UPDATE emp_prof
SET    salary = salary-100;

DROP TRIGGER trig21_prof;

--Varianta 2
CREATE OR REPLACE TRIGGER trig22_prof
  BEFORE UPDATE OF salary ON emp_prof
  FOR EACH ROW
  WHEN (NEW.salary < OLD.salary)
BEGIN
  RAISE_APPLICATION_ERROR(-20002,'salariul nu poate fi micsorat');
END;
/

UPDATE emp_prof
SET    salary = salary-100;

DROP TRIGGER trig22_prof;

--3
CREATE TABLE job_grades_prof
AS SELECT * FROM job_grades;

CREATE OR REPLACE TRIGGER trig3_prof
  BEFORE UPDATE OF lowest_sal, highest_sal ON job_grades_prof
  FOR EACH ROW
DECLARE
  v_min_sal  emp_prof.salary%TYPE;
  v_max_sal  emp_prof.salary%TYPE;
  exceptie EXCEPTION;
BEGIN
  SELECT MIN(salary), MAX(salary)
  INTO   v_min_sal,v_max_sal
  FROM   emp_prof;
  IF (:OLD.grade_level=1) AND  (v_min_sal< :NEW.lowest_sal) 
     THEN RAISE exceptie;
  END IF;
  IF (:OLD.grade_level=7) AND  (v_max_sal> :NEW.highest_sal) 
     THEN RAISE exceptie;
  END IF;
EXCEPTION
  WHEN exceptie THEN
    RAISE_APPLICATION_ERROR (-20003, 'Exista salarii care se gasesc in afara intervalului'); 
END;
/

UPDATE job_grades_prof 
SET    lowest_sal =2000
WHERE  grade_level=1;

UPDATE job_grades_prof
SET    highest_sal =20000
WHERE  grade_level=7;
ROLLBACK;
DROP TRIGGER trig3_prof;

--4
--a
CREATE TABLE info_dept_prof (
    id NUMBER(4) PRIMARY KEY,
    nume_dept VARCHAR2(30),
    plati NUMBER(20)
);
DESC departments;

--b
BEGIN
    FOR i IN (SELECT d.department_id id, MAX(department_name) name, 
                     SUM(salary*(1+NVL(commission_pct,0))) sal
              FROM employees e, departments d
              WHERE e.department_id (+) = d.department_id
              GROUP BY d.department_id) LOOP
        INSERT INTO info_dept_prof
        VALUES (i.id, i.name, i.sal);
    END LOOP;
END;
/
select *
from info_dept_prof;

--c
CREATE OR REPLACE PROCEDURE modific_plati_prof
          (v_codd  info_dept_prof.id%TYPE,
           v_plati info_dept_prof.plati%TYPE) AS
BEGIN
  UPDATE  info_dept_prof
  SET     plati = NVL (plati, 0) + v_plati
  WHERE   id = v_codd;
END;
/

CREATE OR REPLACE TRIGGER trig4_prof
  AFTER DELETE OR INSERT OR UPDATE OF salary ON emp_prof
  FOR EACH ROW
BEGIN
  IF DELETING THEN 
     -- se sterge un angajat
     modific_plati_prof (:OLD.department_id, -1*:OLD.salary);
  ELSIF UPDATING THEN 
    --se modifica salariul unui angajat
    modific_plati_prof(:OLD.department_id,:NEW.salary-:OLD.salary);  
  ELSE 
    -- se introduce un nou angajat
    modific_plati_prof(:NEW.department_id, :NEW.salary);
  END IF;
END;
/

SELECT * FROM  info_dept_prof WHERE id=90;

INSERT INTO emp_prof (employee_id, last_name, email, hire_date, 
                     job_id, salary, department_id) 
VALUES (300, 'N1', 'n1@g.com',sysdate, 'SA_REP', 2000, 90);

SELECT * FROM  info_dept_prof WHERE id=90;

UPDATE emp_prof
SET    salary = salary + 1000
WHERE  employee_id=300;

SELECT * FROM  info_dept_prof WHERE id=90;

DELETE FROM emp_prof
WHERE  employee_id=300;   

SELECT * FROM  info_dept_prof WHERE id=90;

DROP TRIGGER trig4_prof;

--5
--a
CREATE TABLE info_emp_prof (
    id NUMBER(6) PRIMARY KEY,
    nume VARCHAR2(20),
    prenume VARCHAR2(25),
    salariu NUMBER(8,2),
    id_dept NUMBER(4) REFERENCES info_dept_prof(id)
);

DESC employees;

--b
BEGIN
    FOR i IN (SELECT employee_id, first_name, last_name, 
                     salary*(1+NVL(commission_pct,0)) sal, id
              FROM employees, info_dept_prof
              WHERE department_id = id) LOOP
        INSERT INTO info_emp_prof
        VALUES (i.employee_id, i.first_name, i.last_name, i.sal, i.id);
    END LOOP;
END;
/

SELECT *
FROM info_emp_prof;

--c
CREATE OR REPLACE VIEW v_info_prof AS
  SELECT e.id, e.nume, e.prenume, e.salariu, e.id_dept, 
         d.nume_dept, d.plati 
  FROM   info_emp_prof e, info_dept_prof d
  WHERE  e.id_dept = d.id;

--d
SELECT *
FROM   user_updatable_columns
WHERE  table_name = UPPER('v_info_prof');

--e
CREATE OR REPLACE TRIGGER trig5_prof
    INSTEAD OF INSERT OR DELETE OR UPDATE ON v_info_prof
    FOR EACH ROW
BEGIN
IF INSERTING THEN 
    -- inserarea in vizualizare determina inserarea 
    -- in info_emp_prof si reactualizarea in info_dept_prof
    -- se presupune ca departamentul exista
   INSERT INTO info_emp_prof 
   VALUES (:NEW.id, :NEW.nume, :NEW.prenume, :NEW.salariu,
           :NEW.id_dept);
     
   UPDATE info_dept_prof
   SET    plati = plati + :NEW.salariu
   WHERE  id = :NEW.id_dept;

ELSIF DELETING THEN
   -- stergerea unui salariat din vizualizare determina
   -- stergerea din info_emp_prof si reactualizarea in
   -- info_dept_prof
   DELETE FROM info_emp_prof
   WHERE  id = :OLD.id;
     
   UPDATE info_dept_prof
   SET    plati = plati - :OLD.salariu
   WHERE  id = :OLD.id_dept;

ELSIF UPDATING ('salariu') THEN
   /* modificarea unui salariu din vizualizare determina 
      modificarea salariului in info_emp_prof si reactualizarea
      in info_dept_prof    */
    	
   UPDATE  info_emp_prof
   SET     salariu = :NEW.salariu
   WHERE   id = :OLD.id;
    	
   UPDATE info_dept_prof
   SET    plati = plati - :OLD.salariu + :NEW.salariu
   WHERE  id = :OLD.id_dept;

ELSIF UPDATING ('id_dept') THEN
    /* modificarea unui cod de departament din vizualizare
       determina modificarea codului in info_emp_prof 
       si reactualizarea in info_dept_prof  */  
    UPDATE info_emp_prof
    SET    id_dept = :NEW.id_dept
    WHERE  id = :OLD.id;
    
    UPDATE info_dept_prof
    SET    plati = plati - :OLD.salariu
    WHERE  id = :OLD.id_dept;
    	
    UPDATE info_dept_prof
    SET    plati = plati + :NEW.salariu
    WHERE  id = :NEW.id_dept;
  END IF;
END;
/

SELECT *
FROM   user_updatable_columns
WHERE  table_name = UPPER('v_info_prof');

--f
-- adaugarea unui nou angajat
SELECT * FROM  info_dept_prof WHERE id=10;

INSERT INTO v_info_prof 
VALUES (400, 'N1', 'P1', 3000,10, 'Nume dept', 0);

SELECT * FROM  info_emp_prof WHERE id=400;
SELECT * FROM  info_dept_prof WHERE id=10;

-- modificarea salariului unui angajat
UPDATE v_info_prof
SET    salariu=salariu + 1000
WHERE  id=400;

SELECT * FROM  info_emp_prof WHERE id=400;
SELECT * FROM  info_dept_prof WHERE id=10;

-- modificarea departamentului unui angajat
SELECT * FROM  info_dept_prof WHERE id=90;

UPDATE v_info_prof
SET    id_dept=90
WHERE  id=400;

SELECT * FROM  info_emp_prof WHERE id=400;
SELECT * FROM  info_dept_prof WHERE id IN (10,90);

-- eliminarea unui angajat
DELETE FROM v_info_prof WHERE id = 400;
SELECT * FROM  info_emp_prof WHERE id=400;
SELECT * FROM  info_dept_prof WHERE id = 90;

DROP TRIGGER trig5_prof;

--6 
CREATE OR REPLACE TRIGGER trig6_prof
  BEFORE DELETE ON emp_prof
 BEGIN
  IF USER= UPPER('grupa32') THEN
     RAISE_APPLICATION_ERROR(-20900,'Nu ai voie sa stergi!');
  END IF;
 END;
/

DELETE FROM emp_prof;

DROP TRIGGER trig6_prof;

--7
--a
CREATE TABLE audit_prof
   (utilizator     VARCHAR2(30),
    nume_bd        VARCHAR2(50),
    eveniment      VARCHAR2(20),
    nume_obiect    VARCHAR2(30),
    data           DATE);

--b
CREATE OR REPLACE TRIGGER trig7_prof
  AFTER CREATE OR DROP OR ALTER ON SCHEMA
BEGIN
  INSERT INTO audit_prof
  VALUES (SYS.LOGIN_USER, SYS.DATABASE_NAME, SYS.SYSEVENT, 
          SYS.DICTIONARY_OBJ_NAME, SYSDATE);
END;
/

CREATE INDEX ind_prof ON info_emp_prof(nume);
DROP INDEX ind_prof;
SELECT * FROM audit_prof;

DROP TRIGGER trig7_prof;

--8
CREATE OR REPLACE PACKAGE pachet_prof
AS
	smin emp_prof.salary%type;
	smax emp_prof.salary%type;
	smed emp_prof.salary%type;
END pachet_prof;
/

CREATE OR REPLACE TRIGGER trig81_prof
BEFORE UPDATE OF salary ON emp_prof
BEGIN
  SELECT MIN(salary),AVG(salary),MAX(salary)
  INTO pachet_prof.smin, pachet_prof.smed, pachet_prof.smax
  FROM emp_prof;
END;
/

CREATE OR REPLACE TRIGGER trig82_prof
BEFORE UPDATE OF salary ON emp_prof
FOR EACH ROW
BEGIN
IF(:OLD.salary=pachet_prof.smin)AND (:NEW.salary>pachet_prof.smed) 
 THEN
   RAISE_APPLICATION_ERROR(-20001,'Acest salariu depaseste valoarea medie');
ELSIF (:OLD.salary= pachet_prof.smax) 
       AND (:NEW.salary<  pachet_prof.smed) 
 THEN
   RAISE_APPLICATION_ERROR(-20001,'Acest salariu este sub valoarea medie');
END IF;
END;
/

SELECT AVG(salary)
FROM   emp_prof;

UPDATE emp_prof 
SET    salary=10000 
WHERE  salary=(SELECT MIN(salary) FROM emp_prof);

UPDATE emp_prof 
SET    salary=1000 
WHERE  salary=(SELECT MAX(salary) FROM emp_prof);

DROP TRIGGER trig81_prof;
DROP TRIGGER trig82_prof;
