--lab 3 PLSQL

--1
DECLARE
  v_nr    number(4);
  v_nume  departments.department_name%TYPE;
  CURSOR c IS
    SELECT department_name nume, COUNT(employee_id) nr  
    FROM   departments d, employees e
    WHERE  d.department_id=e.department_id(+) 
    GROUP BY department_name; 
BEGIN
  OPEN c;
  LOOP
      FETCH c INTO v_nume,v_nr;
      EXIT WHEN c%NOTFOUND;
      IF v_nr=0 THEN
         DBMS_OUTPUT.PUT_LINE('In departamentul '|| v_nume||
                           ' nu lucreaza angajati');
      ELSIF v_nr=1 THEN
           DBMS_OUTPUT.PUT_LINE('In departamentul '|| v_nume||
                           ' lucreaza un angajat');
      ELSE
         DBMS_OUTPUT.PUT_LINE('In departamentul '|| v_nume||
                           ' lucreaza '|| v_nr||' angajati');
     END IF;
 END LOOP;
 CLOSE c;
END;
/

--3
DECLARE
  CURSOR c IS
    SELECT department_name nume, COUNT(employee_id) nr 
    FROM   departments d, employees e
    WHERE  d.department_id=e.department_id(+)
    GROUP BY department_name; 
BEGIN
  FOR i in c LOOP
      IF i.nr=0 THEN
         DBMS_OUTPUT.PUT_LINE('In departamentul '|| i.nume||
                           ' nu lucreaza angajati');
      ELSIF i.nr=1 THEN
           DBMS_OUTPUT.PUT_LINE('In departamentul '|| i.nume ||
                           ' lucreaza un angajat');
      ELSE
         DBMS_OUTPUT.PUT_LINE('In departamentul '|| i.nume||
                           ' lucreaza '|| i.nr||' angajati');
     END IF;
 END LOOP;
END;
/

--4
BEGIN
  FOR i in (SELECT department_name nume, COUNT(employee_id) nr 
            FROM   departments d, employees e
            WHERE  d.department_id=e.department_id(+)
            GROUP BY department_name) LOOP
      IF i.nr=0 THEN
         DBMS_OUTPUT.PUT_LINE('In departamentul '|| i.nume||
                           ' nu lucreaza angajati');
      ELSIF i.nr=1 THEN
           DBMS_OUTPUT.PUT_LINE('In departamentul '|| i.nume ||
                           ' lucreaza un angajat');
      ELSE
         DBMS_OUTPUT.PUT_LINE('In departamentul '|| i.nume||
                           ' lucreaza '|| i.nr||' angajati');
     END IF;
 END LOOP;
END;
/

--5
DECLARE
  v_cod    employees.employee_id%TYPE;
  v_nume   employees.last_name%TYPE;
  v_nr     NUMBER(4);
  CURSOR c IS
    SELECT   sef.employee_id cod, MAX(sef.last_name) nume, 
             count(*) nr
    FROM     employees sef, employees ang
    WHERE    ang.manager_id = sef.employee_id
    GROUP BY sef.employee_id
    ORDER BY nr DESC;
BEGIN
  OPEN c;
    LOOP
      FETCH c INTO v_cod,v_nume,v_nr;
      EXIT WHEN c%ROWCOUNT>3 OR c%NOTFOUND;
      DBMS_OUTPUT.PUT_LINE('Managerul '|| v_cod || 
                           ' avand numele ' || v_nume || 
                           ' conduce ' || v_nr||' angajati');
    END LOOP;
  CLOSE c;
END;
/

--6
DECLARE
  CURSOR c IS
    SELECT   sef.employee_id cod, MAX(sef.last_name) nume, 
             count(*) nr
    FROM     employees sef, employees ang
    WHERE    ang.manager_id = sef.employee_id
    GROUP BY sef.employee_id
    ORDER BY nr DESC;
BEGIN
  FOR i IN c LOOP
      EXIT WHEN c%ROWCOUNT>3 OR c%NOTFOUND;
      DBMS_OUTPUT.PUT_LINE('Managerul '|| i.cod || 
                           ' avand numele ' || i.nume || 
                           ' conduce '|| i.nr||' angajati');
  END LOOP;
END;
/

--7
DECLARE
  top number(1):= 0; 
BEGIN
  FOR i IN (SELECT   sef.employee_id cod, MAX(sef.last_name) nume, 
                     count(*) nr
            FROM     employees sef, employees ang
            WHERE    ang.manager_id = sef.employee_id
            GROUP BY sef.employee_id
            ORDER BY nr DESC) 
  LOOP
      DBMS_OUTPUT.PUT_LINE('Managerul '|| i.cod || 
                           ' avand numele ' || i.nume || 
                           ' conduce '|| i.nr||' angajati');
      Top := top+1;
      EXIT WHEN top=3;
  END LOOP;
END;
/

--8
DECLARE
  v_x     number(4) := &p_x;
  v_nr    number(4);
  v_nume  departments.department_name%TYPE;

  CURSOR c (paramentru NUMBER) IS
    SELECT department_name nume, COUNT(employee_id) nr  
    FROM   departments d, employees e
    WHERE  d.department_id=e.department_id
    GROUP BY department_name
    HAVING COUNT(employee_id)> paramentru; 
BEGIN
  OPEN c(v_x);
  LOOP
      FETCH c INTO v_nume,v_nr;
      EXIT WHEN c%NOTFOUND;
      DBMS_OUTPUT.PUT_LINE('In departamentul '|| v_nume||
                           ' lucreaza '|| v_nr||' angajati');
 END LOOP;
 CLOSE c;
END;
/

DECLARE
 v_x     number(4) := &p_x;
 CURSOR c (paramentru NUMBER) IS
    SELECT department_name nume, COUNT(employee_id) nr 
    FROM   departments d, employees e
    WHERE  d.department_id=e.department_id
    GROUP BY department_name
    HAVING COUNT(employee_id)> paramentru; 
BEGIN
  FOR i in c(v_x) LOOP
     DBMS_OUTPUT.PUT_LINE('In departamentul '|| i.nume||
                           ' lucreaza '|| i.nr||' angajati');
  END LOOP;
END;
/

DECLARE
 v_x     number(4) := &p_x;
 BEGIN
  FOR i in (SELECT department_name nume, COUNT(employee_id) nr 
            FROM   departments d, employees e
            WHERE  d.department_id=e.department_id
            GROUP BY department_name 
            HAVING COUNT(employee_id)> v_x) 
  LOOP
     DBMS_OUTPUT.PUT_LINE('In departamentul '|| i.nume||
                           ' lucreaza '|| i.nr||' angajati');
END LOOP;
END;
/

--9
create table emp_prof as select * from employees;

SELECT last_name, hire_date, salary
FROM   emp_prof
WHERE  TO_CHAR(hire_date, 'yyyy') = 2000;

DECLARE
  CURSOR c IS
    SELECT *
    FROM   emp_prof
    WHERE  TO_CHAR(hire_date, 'YYYY') = 2000
    FOR UPDATE OF salary NOWAIT;
BEGIN
  FOR i IN c  LOOP
    UPDATE  emp_prof
    SET     salary= salary+1000
    WHERE CURRENT OF c;
  END LOOP;
END;
/

SELECT last_name, hire_date, salary
FROM   emp_prof
WHERE  TO_CHAR(hire_date, 'yyyy') = 2000;

ROLLBACK;

--10
--varianta 1 - cursor parametrizat
BEGIN
  FOR v_dept IN (SELECT department_id, department_name
                 FROM   departments
                 WHERE  department_id IN (10,20,30,40))
  LOOP
    DBMS_OUTPUT.PUT_LINE('-------------------------------------');
    DBMS_OUTPUT.PUT_LINE ('DEPARTAMENT '||v_dept.department_name);
    DBMS_OUTPUT.PUT_LINE('-------------------------------------');
    FOR v_emp IN (SELECT last_name
                  FROM   employees
                  WHERE  department_id = v_dept.department_id)
    LOOP
       DBMS_OUTPUT.PUT_LINE (v_emp.last_name);
    END LOOP;
  END LOOP;
END;
/
--Varianta 2 – expresii cursor
DECLARE
  TYPE refcursor IS REF CURSOR;
  CURSOR c_dept IS
    SELECT department_name, 
           CURSOR (SELECT last_name 
                   FROM   employees e
                   WHERE  e.department_id = d.department_id)
    FROM   departments d
    WHERE  department_id IN (10,20,30,40);
  v_nume_dept   departments.department_name%TYPE;
  v_cursor      refcursor;
  v_nume_emp    employees.last_name%TYPE;
BEGIN
  OPEN c_dept;
  LOOP
    FETCH c_dept INTO v_nume_dept, v_cursor;
    EXIT WHEN c_dept%NOTFOUND;
    DBMS_OUTPUT.PUT_LINE('-------------------------------------');
    DBMS_OUTPUT.PUT_LINE ('DEPARTAMENT '||v_nume_dept);
    DBMS_OUTPUT.PUT_LINE('-------------------------------------');
    LOOP
      FETCH v_cursor INTO v_nume_emp;
      EXIT WHEN v_cursor%NOTFOUND;
      DBMS_OUTPUT.PUT_LINE (v_nume_emp);
    END LOOP;
  END LOOP;
  CLOSE c_dept;
END;
/

--11
-- atentie la rezultat
DECLARE
  TYPE      emp_tip IS REF CURSOR RETURN employees%ROWTYPE;
  -- sau 
  -- TYPE   emp_tip IS REF CURSOR;
  
  v_emp     emp_tip;
  v_optiune NUMBER := &p_optiune;
  v_ang    employees%ROWTYPE;
BEGIN
   IF v_optiune = 1 THEN
     OPEN v_emp FOR SELECT * 
                    FROM employees;
   ELSIF v_optiune = 2 THEN
     OPEN v_emp FOR  SELECT * 
                     FROM employees 
                     WHERE salary BETWEEN 10000 AND 20000;
   ELSIF v_optiune = 3 THEN
     OPEN v_emp FOR SELECT * 
                    FROM employees 
                    WHERE EXTRACT(YEAR FROM hire_date) = 2000;
   ELSE
      DBMS_OUTPUT.PUT_LINE('Optiune incorecta');  
   END IF;
   IF v_optiune IN (1,2,3) THEN
       LOOP
          FETCH v_emp into v_ang;
          EXIT WHEN v_emp%NOTFOUND;
          DBMS_OUTPUT.PUT_LINE(v_ang.last_name);
       END LOOP;
       
       DBMS_OUTPUT.PUT_LINE('Au fost procesate '||v_emp%ROWCOUNT 
                            || ' linii');
       CLOSE v_emp;
   END IF;
END;
/

--12
DECLARE
  TYPE emprec IS RECORD (cod employees.employee_id%TYPE, 
                         sal employees.salary%TYPE,
                         comm employees.commission_pct%TYPE);
  TYPE  empref IS REF CURSOR; 
  v_emp empref;
  v_nr  INTEGER := &n;
  v_emprec emprec;
BEGIN
  OPEN v_emp FOR 
    'SELECT employee_id, salary, commission_pct ' ||
    'FROM employees WHERE salary > :bind_var'
     USING v_nr;
 -- introduceti liniile corespunzatoare rezolvarii problemei
 FETCH v_emp INTO v_emprec;
 WHILE v_emp%FOUND LOOP
    IF v_emprec.comm IS NOT NULL THEN
        DBMS_OUTPUT.PUT_LINE(v_emprec.cod || ' ' || v_emprec.sal || ' ' ||
                    v_emprec.comm);
    ELSE 
        DBMS_OUTPUT.PUT_LINE(v_emprec.cod || ' ' || v_emprec.sal);
    END IF;
    FETCH v_emp INTO v_emprec; 
 END LOOP;
 CLOSE v_emp;
END;
/

--EXERCITII
--2 de la exercitii rezolvate
DECLARE
  TYPE   tab_nume IS TABLE OF departments.department_name%TYPE;
  TYPE   tab_nr IS TABLE OF NUMBER(4);
  t_nr   tab_nr;
  t_nume tab_nume;
  v_nr NUMBER := 0;
  CURSOR c IS
    SELECT department_name nume, COUNT(employee_id) nr  
    FROM   departments d, employees e
    WHERE  d.department_id=e.department_id(+)
    GROUP BY department_name; 
BEGIN
  OPEN c;
  DBMS_OUTPUT.PUT_LINE('-------FETCH 1----------');
  FETCH c  BULK COLLECT INTO t_nume, t_nr LIMIT 5;
  FOR i IN t_nume.FIRST..t_nume.LAST LOOP
      v_nr := v_nr + 1;
      DBMS_OUTPUT.PUT_LINE(v_nr);
      IF t_nr(i)=0 THEN
         DBMS_OUTPUT.PUT_LINE('In departamentul '|| t_nume(i)||
                           ' nu lucreaza angajati');
      ELSIF t_nr(i)=1 THEN
           DBMS_OUTPUT.PUT_LINE('In departamentul '||t_nume(i)||
                           ' lucreaza un angajat');
      ELSE
         DBMS_OUTPUT.PUT_LINE('In departamentul '|| t_nume(i)||
                           ' lucreaza '|| t_nr(i)||' angajati');
     END IF;
  END LOOP;
  DBMS_OUTPUT.PUT_LINE('-------FETCH 2----------');
  FETCH c  BULK COLLECT INTO t_nume, t_nr LIMIT 100;
  FOR i IN t_nume.FIRST..t_nume.LAST LOOP
      v_nr := v_nr + 1;
      DBMS_OUTPUT.PUT_LINE(v_nr);
      IF t_nr(i)=0 THEN
         DBMS_OUTPUT.PUT_LINE('In departamentul '|| t_nume(i)||
                           ' nu lucreaza angajati');
      ELSIF t_nr(i)=1 THEN
           DBMS_OUTPUT.PUT_LINE('In departamentul '||t_nume(i)||
                           ' lucreaza un angajat');
      ELSE
         DBMS_OUTPUT.PUT_LINE('In departamentul '|| t_nume(i)||
                           ' lucreaza '|| t_nr(i)||' angajati');
     END IF;
  END LOOP;
  CLOSE c;
END;
/


DESC jobs;
DESC emp_prof;

--5
--expresii cursor
DECLARE
    TYPE refcursor IS REF CURSOR;
    CURSOR c_jobs IS SELECT job_title,
                            CURSOR (SELECT last_name || ' ' || first_name,
                                           salary * (1+NVL(commission_pct,0))
                                    FROM employees e
                                    WHERE e.job_id = j.job_id
                                    ORDER BY 2 DESC)
                     FROM jobs j;
    v_cursor refcursor;
    v_job_title jobs.job_title%TYPE;
    v_nume VARCHAR2(45);
    v_sal NUMBER;
    v_top NUMBER := 1;
    v_curent NUMBER;
BEGIN
    OPEN c_jobs;
    FETCH c_jobs INTO v_job_title, v_cursor;
    WHILE c_jobs%FOUND LOOP
        DBMS_OUTPUT.PUT_LINE('--------------' || v_job_title || '--------------');
        v_curent := -1;
        v_top := 1;
        LOOP
            FETCH v_cursor INTO v_nume, v_sal;
            EXIT WHEN v_cursor%NOTFOUND OR v_top > 4;
            IF v_curent = -1 THEN 
                v_curent := v_sal;
            ELSIF v_curent <> v_sal THEN 
                v_curent := v_sal;
                v_top := v_top + 1;
            END IF;
            DBMS_OUTPUT.PUT_LINE(v_top || '. ' || v_nume || ' are salariul ' || v_sal);
        END LOOP;
        DBMS_OUTPUT.NEW_LINE;
        FETCH c_jobs INTO v_job_title, v_cursor;
    END LOOP;
    CLOSE c_jobs;
END;
/