--EXERCITII JOS
--4
CREATE OR REPLACE TRIGGER t_prof 
    BEFORE INSERT OR UPDATE OF department_id ON emp_prof
    FOR EACH ROW
DECLARE
    v_numar NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_numar
    FROM emp_prof
    WHERE department_id = :NEW.department_id;
    
    IF v_numar >= 45 THEN
        DBMS_OUTPUT.PUT_LINE('Intr-un departament nu pot fi mai mult de 45 de angajati');
        RAISE_APPLICATION_ERROR(-20001, 'Intr-un departament nu pot fi mai mult de 45 de angajati');
    ELSE DBMS_OUTPUT.PUT_LINE('Comanda s-a executat cu success');
    END IF;
END;
/

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