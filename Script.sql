DECLARE
x NUMBER(1) := 5;
y x%TYPE := NULL;
BEGIN
IF x <> y THEN
DBMS_OUTPUT.PUT_LINE ('valoare <> null este = true');
ELSE
DBMS_OUTPUT.PUT_LINE ('valoare <> null este != true');
END IF;
x := NULL;
IF x = y THEN
DBMS_OUTPUT.PUT_LINE ('null = null este = true');
ELSE
DBMS_OUTPUT.PUT_LINE ('null = null este != true');
END IF;
END;
/


set serveroutput on;

select *
from member;







create table emp_dumi as (select * from employees);

DECLARE
TYPE tablou_indexat IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
t tablou_indexat;
BEGIN
-- punctul a
FOR i IN 1..10 LOOP
t(i):=i;
END LOOP;
DBMS_OUTPUT.PUT('Tabloul are ' || t.COUNT ||' elemente: ');
FOR i IN t.FIRST..t.LAST LOOP
DBMS_OUTPUT.PUT(t(i) || ' ');
END LOOP;
DBMS_OUTPUT.NEW_LINE;
-- punctul b
FOR i IN 1..10 LOOP
IF i mod 2 = 1 THEN t(i):=null;
END IF;
END LOOP;
DBMS_OUTPUT.PUT('Tabloul are ' || t.COUNT ||' elemente: ');

FOR i IN t.FIRST..t.LAST LOOP
DBMS_OUTPUT.PUT(nvl(t(i), 0) || ' ');
END LOOP;
DBMS_OUTPUT.NEW_LINE;
-- punctul c
t.DELETE(t.first);
t.DELETE(5,7);
t.DELETE(t.last);
DBMS_OUTPUT.PUT_LINE('Primul element are indicele ' || t.first ||
' si valoarea ' || nvl(t(t.first),0));
DBMS_OUTPUT.PUT_LINE('Ultimul element are indicele ' || t.last ||
' si valoarea ' || nvl(t(t.last),0));
DBMS_OUTPUT.PUT('Tabloul are ' || t.COUNT ||' elemente: ');
FOR i IN t.FIRST..t.LAST LOOP
IF t.EXISTS(i) THEN
DBMS_OUTPUT.PUT(nvl(t(i), 0)|| ' ');
END IF;
END LOOP;
DBMS_OUTPUT.NEW_LINE;
-- punctul d
t.delete;
DBMS_OUTPUT.PUT_LINE('Tabloul are ' || t.COUNT ||' elemente.');
END;


DECLARE
TYPE tablou_indexat IS TABLE OF emp_dumi%ROWTYPE
INDEX BY BINARY_INTEGER;
t tablou_indexat;
BEGIN
-- stergere din tabel si salvare in tablou
DELETE FROM emp_dumi
WHERE ROWNUM<= 2
RETURNING employee_id, first_name, last_name, email, phone_number,
hire_date, job_id, salary, commission_pct, manager_id,
department_id
BULK COLLECT INTO t;
--afisare elemente tablou
DBMS_OUTPUT.PUT_LINE (t(1).employee_id ||' ' || t(1).last_name);
DBMS_OUTPUT.PUT_LINE (t(2).employee_id ||' ' || t(2).last_name);
--inserare cele 2 linii in tabel
INSERT INTO emp_dumi VALUES t(1);
INSERT INTO emp_dumi VALUES t(2);
END;
/
