--EXERCITII JOS
--4
CREATE OR REPLACE TRIGGER t_prof
    BEFORE INSERT OR UPDATE OF department_id ON emp_prof
    FOR EACH ROW
DECLARE
    v_nr NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_nr
    FROM emp_prof
    WHERE department_id = :NEW.department_id;
    IF v_nr = 45 THEN 
        RAISE_APPLICATION_ERROR(-20001, 'Intr-un departament nu pot fi mai mult de 45 de angajati');
    END IF;
END;
/

DROP TRIGGER t_prof;

SELECT department_id, COUNT(*)
FROM emp_prof
GROUP BY department_id;

DESC emp_prof;

SELECT *
FROM emp_prof;

INSERT INTO emp_prof
VALUES (1, 'f', 'l', 'email@e.com', NULL, SYSDATE, 'AD_ASST', 20000, NULL, 100, 50);

UPDATE emp_prof
SET department_id = 50;

INSERT INTO emp_prof
SELECT 1, 'f', 'l', 'email@e.com', NULL, SYSDATE, 'AD_ASST', 20000, NULL, 100, 50
FROM DUAL;