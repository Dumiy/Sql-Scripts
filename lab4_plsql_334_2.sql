--lab 4 PLSQL
SELECT *
FROM USER_OBJECTS
WHERE OBJECT_TYPE IN ('PROCEDURE','FUNCTION');
SELECT TEXT
FROM USER_SOURCE
WHERE NAME =UPPER('f2_prof');
--1
DECLARE
  v_nume employees.last_name%TYPE := Initcap('&p_nume');   

  FUNCTION f1 RETURN NUMBER IS
    salariu employees.salary%type; 
  BEGIN
    SELECT salary INTO salariu 
    FROM   employees
    WHERE  last_name = v_nume;
    RETURN salariu;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
       DBMS_OUTPUT.PUT_LINE('Nu exista angajati cu numele dat');
    WHEN TOO_MANY_ROWS THEN
       DBMS_OUTPUT.PUT_LINE('Exista mai multi angajati cu numele dat');
    WHEN OTHERS THEN
       DBMS_OUTPUT.PUT_LINE('Alta eroare!');
  END f1;
BEGIN
  DBMS_OUTPUT.PUT_LINE('Salariul este '|| f1);

--EXCEPTION
--  WHEN OTHERS THEN
--    DBMS_OUTPUT.PUT_LINE('Eroarea are codul = '||SQLCODE
--            || ' si mesajul = ' || SQLERRM);
END;
/
--Bell, King, Kimball

--2
CREATE OR REPLACE FUNCTION f2_prof 
  (v_nume employees.last_name%TYPE DEFAULT 'Bell')    
RETURN NUMBER IS
    salariu employees.salary%type; 
  BEGIN
    SELECT salary INTO salariu 
    FROM   employees
    WHERE  last_name = v_nume;
    RETURN salariu;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
       RAISE_APPLICATION_ERROR(-20000, 'Nu exista angajati cu numele dat');
    WHEN TOO_MANY_ROWS THEN
       RAISE_APPLICATION_ERROR(-20001, 'Exista mai multi angajati cu numele dat');
    WHEN OTHERS THEN
       RAISE_APPLICATION_ERROR(-20002,'Alta eroare!');
END f2_prof;
/

-- metode de apelare
-- bloc plsql
BEGIN
  DBMS_OUTPUT.PUT_LINE('Salariul este '|| f2_prof);
END;
/

BEGIN
  DBMS_OUTPUT.PUT_LINE('Salariul este '|| f2_prof('King'));
END;
/

-- SQL
  SELECT f2_prof FROM DUAL;
  SELECT f2_prof('King') FROM DUAL;

-- SQL*PLUS CU VARIABILA HOST
  VARIABLE nr NUMBER
  EXECUTE :nr := f2_prof('King');
  PRINT nr
  
-- 3 
-- varianta 1
DECLARE
  v_nume employees.last_name%TYPE := Initcap('&p_nume');   
  
  PROCEDURE p3 
  IS 
      salariu employees.salary%TYPE;
  BEGIN
    SELECT salary INTO salariu 
    FROM   employees
    WHERE  last_name = v_nume;
    DBMS_OUTPUT.PUT_LINE('Salariul este '|| salariu);
  
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
       DBMS_OUTPUT.PUT_LINE('Nu exista angajati cu numele dat');
    WHEN TOO_MANY_ROWS THEN
       DBMS_OUTPUT.PUT_LINE('Exista mai multi angajati cu numele dat');
    WHEN OTHERS THEN
       DBMS_OUTPUT.PUT_LINE('Alta eroare!');
  END p3;

BEGIN
  p3;
END;
/

-- varianta 2
DECLARE
  v_nume employees.last_name%TYPE := Initcap('&p_nume');  
  v_salariu employees.salary%type;

  PROCEDURE p3(salariu OUT employees.salary%type) IS 
  BEGIN
    SELECT salary INTO salariu 
    FROM   employees
    WHERE  last_name = v_nume;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
       RAISE_APPLICATION_ERROR(-20000,'Nu exista angajati cu numele dat');
    WHEN TOO_MANY_ROWS THEN
       RAISE_APPLICATION_ERROR(-20001,'Exista mai multi angajati cu numele dat');
    WHEN OTHERS THEN
       RAISE_APPLICATION_ERROR(-20002,'Alta eroare!');
  END p3;

BEGIN
  p3(v_salariu);
  DBMS_OUTPUT.PUT_LINE('Salariul este '|| v_salariu);
END;
/
 
--4
-- varianta 1
CREATE OR REPLACE PROCEDURE p4_prof
      (v_nume employees.last_name%TYPE)
  IS 
      salariu employees.salary%TYPE;
  BEGIN
    SELECT salary INTO salariu 
    FROM   employees
    WHERE  last_name = v_nume;
    DBMS_OUTPUT.PUT_LINE('Salariul este '|| salariu);
  
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
       RAISE_APPLICATION_ERROR(-20000, 'Nu exista angajati cu numele dat');
    WHEN TOO_MANY_ROWS THEN
       RAISE_APPLICATION_ERROR(-20001, 'Exista mai multi angajati cu numele dat');
    WHEN OTHERS THEN
       RAISE_APPLICATION_ERROR(-20002,'Alta eroare!');
  END p4_prof;
/

-- metode apelare
-- 1. Bloc PLSQL
BEGIN
  p4_prof('Bell');
END;
/

-- 2. SQL*PLUS
EXECUTE p4_prof('Bell');
EXECUTE p4_prof('King');
EXECUTE p4_prof('Kimball');

-- varianta 2
CREATE OR REPLACE PROCEDURE 
       p4_prof(v_nume IN employees.last_name%TYPE,
               salariu OUT employees.salary%type) IS 
  BEGIN
    SELECT salary INTO salariu 
    FROM   employees
    WHERE  last_name = v_nume;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
       RAISE_APPLICATION_ERROR(-20000, 'Nu exista angajati cu numele dat');
    WHEN TOO_MANY_ROWS THEN
       RAISE_APPLICATION_ERROR(-20001, 'Exista mai multi angajati cu numele dat');
    WHEN OTHERS THEN
       RAISE_APPLICATION_ERROR(-20002,'Alta eroare!');
  END p4_prof;
/

-- metode apelare
-- Bloc PLSQL
DECLARE
   v_salariu employees.salary%type;
BEGIN
  p4_prof('Bell',v_salariu);
  DBMS_OUTPUT.PUT_LINE('Salariul este '|| v_salariu);
END;
/

-- SQL*PLUS
VARIABLE v_sal NUMBER
EXECUTE p4_prof ('Bell',:v_sal)
PRINT v_sal

--5
VARIABLE ang_man NUMBER
BEGIN
 :ang_man:=200;
END;
/

CREATE OR REPLACE PROCEDURE p5_prof  (nr IN OUT NUMBER) IS 
BEGIN
 SELECT manager_id INTO nr
 FROM employees
 WHERE employee_id=nr;
END p5_prof;
/

EXECUTE p5_prof (:ang_man)
PRINT ang_man

--6
DECLARE
nume employees.last_name%TYPE;
PROCEDURE p6 (rezultat OUT employees.last_name%TYPE,
              comision IN  employees.commission_pct%TYPE:=NULL,
              cod      IN  employees.employee_id%TYPE:=NULL) 
 IS
 BEGIN
 IF (comision IS NOT NULL) THEN
    SELECT last_name 
    INTO rezultat
    FROM employees
    WHERE commission_pct= comision;
    DBMS_OUTPUT.PUT_LINE('numele salariatului care are comisionul ' 
                        ||comision||' este '||rezultat);
 ELSE 
    SELECT last_name 
    INTO rezultat
    FROM employees
    WHERE employee_id =cod;
    DBMS_OUTPUT.PUT_LINE('numele salariatului avand codul ' ||cod||' este '||rezultat);
 END IF;
END p6;

BEGIN
  p6(nume,0.4);
  p6(cod=>200,rezultat=>nume);
END;
/

--7
DECLARE
  medie1 NUMBER(10,2);
  medie2 NUMBER(10,2);
  FUNCTION medie (v_dept employees.department_id%TYPE) 
    RETURN NUMBER IS
    rezultat NUMBER(10,2);
  BEGIN
    SELECT AVG(salary) 
    INTO   rezultat 
    FROM   employees
    WHERE  department_id = v_dept;
    RETURN rezultat;
  END;
  
  FUNCTION medie (v_dept employees.department_id%TYPE,
                  v_job employees.job_id %TYPE) 
    RETURN NUMBER IS
    rezultat NUMBER(10,2);
  BEGIN
    SELECT AVG(salary) 
    INTO   rezultat 
    FROM   employees
    WHERE  department_id = v_dept AND job_id = v_job;
    RETURN rezultat;
  END;

BEGIN
  medie1:=medie(80);
  DBMS_OUTPUT.PUT_LINE('Media salariilor din departamentul 80' 
      || ' este ' || medie1);
  medie2 := medie(80,'SA_MAN');
  DBMS_OUTPUT.PUT_LINE('Media salariilor managerilor din'
      || ' departamentul 80 este ' || medie2);
END;
/

--8
CREATE OR REPLACE FUNCTION factorial_prof(n NUMBER) 
 RETURN INTEGER 
 IS
 BEGIN
  IF (n=0) THEN RETURN 1;
  ELSE RETURN n*factorial_prof(n-1);
  END IF;
END factorial_prof;
/

VARIABLE x NUMBER
EXECUTE :x := factorial_prof(5);
PRINT x

SELECT factorial_prof(5) FROM DUAL;

--9
CREATE OR REPLACE FUNCTION medie_prof 
RETURN NUMBER 
IS 
rezultat NUMBER;
BEGIN
  SELECT AVG(salary) INTO   rezultat
  FROM   employees;
  RETURN rezultat;
END;
/
SELECT last_name,salary
FROM   employees
WHERE  salary >= medie_prof;

--EXERCITII
--1
DROP TABLE info_prof;
CREATE TABLE info_prof (
    id NUMBER(4) PRIMARY KEY,
    utilizator VARCHAR2(30),
    data TIMESTAMP,
    comanda VARCHAR2(20),
    nr_linii NUMBER,
    eroare VARCHAR2(50)
);

DROP SEQUENCE s_info_prof;
CREATE SEQUENCE s_info_prof
START WITH 1
INCREMENT BY 1;

--2
CREATE OR REPLACE FUNCTION f2_prof 
  (v_nume employees.last_name%TYPE DEFAULT 'Bell')    
RETURN NUMBER IS
    salariu employees.salary%type; 
    v_mesaj VARCHAR2(70);
  BEGIN
    SELECT salary INTO salariu 
    FROM   employees
    WHERE  last_name = v_nume;
    INSERT INTO info_prof
    VALUES (s_info_prof.NEXTVAL, USER, SYSTIMESTAMP, 'select', 1, NULL);
    RETURN salariu;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
        INSERT INTO info_prof
        VALUES (s_info_prof.NEXTVAL, USER, SYSTIMESTAMP, 'select', 0, 'Nu exista angajati cu numele dat');
        RETURN -1;
--       RAISE_APPLICATION_ERROR(-20000, 'Nu exista angajati cu numele dat');
    WHEN TOO_MANY_ROWS THEN
        INSERT INTO info_prof
        VALUES (s_info_prof.NEXTVAL, USER, SYSTIMESTAMP, 'select', 2, 'Exista mai multi angajati cu numele dat');
        RETURN -2;
--       RAISE_APPLICATION_ERROR(-20001, 'Exista mai multi angajati cu numele dat');
    WHEN OTHERS THEN
        v_mesaj := SQLCODE || ' ' || SQLERRM;
        INSERT INTO info_prof
        VALUES (s_info_prof.NEXTVAL, USER, SYSTIMESTAMP, 'select', NULL, v_mesaj);
        RETURN -3;
--       RAISE_APPLICATION_ERROR(-20002,'Alta eroare!');
END f2_prof;
/

-- metode de apelare
--SQL -> nu merge
SELECT f2_prof
FROM DUAL;

-- bloc plsql
BEGIN
  DBMS_OUTPUT.PUT_LINE('Salariul este '|| f2_prof);
END;
/

SELECT *
FROM info_prof;

--4
CREATE OR REPLACE PROCEDURE pt4_prof (p_manager_id emp_prof.manager_id%TYPE DEFAULT 100) 
IS
    v_manager_id emp_prof.manager_id%TYPE ;
    v_nr NUMBER;
BEGIN
    SELECT DISTINCT manager_id INTO v_manager_id
    FROM employees
    WHERE manager_id = p_manager_id;
    UPDATE emp_prof
    SET salary = salary * 1.1
    WHERE employee_id IN (SELECT employee_id
                          FROM emp_prof
                          WHERE employee_id <> v_manager_id
                          START WITH employee_id = v_manager_id
                          CONNECT BY PRIOR employee_id = manager_id);
    v_nr := SQL%ROWCOUNT;
    INSERT INTO info_prof
    VALUES (s_info_prof.NEXTVAL, USER, SYSTIMESTAMP, 'update', v_nr, NULL);
EXCEPTION
    WHEN NO_DATA_FOUND THEN 
        INSERT INTO info_prof
        VALUES (s_info_prof.NEXTVAL, USER, SYSTIMESTAMP, 'select', 0, 'NU EXISTA MANAGERI CU CODUL DAT');
END;
/

-- bloc plsql
BEGIN
  pt4_prof;
END;
/

SELECT *
FROM info_prof;

--5
--for pentru department_id si department_name, iar in for-ul acesta avem un alt for in care 
--se selecteaza ziua din saptamana in care a fost angajata persoana curenta si numele
--angajatului
--va luati un vector in care numarati pentru fiecare zi din saptamana cati angajati 
--au fost angajati
--cazuri speciale: nu exista angajati
SELECT MAX(COUNT(employee_id))
FROM emp_prof
GROUP BY TO_CHAR(hire_date, 'D');

BEGIN
  FOR i IN (SELECT department_id, department_name
            FROM departments) LOOP
    DBMS_OUTPUT.PUT_LINE('--------------' || i.department_name || '--------------');
    FOR j IN (SELECT TO_CHAR(hire_date, 'D') zi
              FROM emp_prof
              WHERE department_id = i.department_id
              GROUP BY TO_CHAR(hire_date, 'D')
              HAVING COUNT(employee_id) = (SELECT MAX(COUNT(employee_id))
                                           FROM emp_prof
                                           WHERE department_id = i.department_id
                                           GROUP BY TO_CHAR(hire_date, 'D'))) LOOP
      DBMS_OUTPUT.PUT_LINE(j.zi);
    END LOOP;
  END LOOP;
END;
/