DECLARE
v_nr number(4);
v_nume departments.department_name%TYPE;
CURSOR c IS
SELECT department_name nume, COUNT(employee_id) nr
FROM departments d, employees e
WHERE d.department_id=e.department_id
GROUP BY department_name;
BEGIN
OPEN c;
LOOP
FETCH c INTO v_nume,v_nr;
    EXIT WHEN c%NOTFOUND;
    CASE 
        when v_nr=0 THEN DBMS_OUTPUT.PUT_LINE('In departamentul '|| v_nume||' nu lucreaza angajati');
        when v_nr=1 THEN DBMS_OUTPUT.PUT_LINE('In departamentul '|| v_nume||' lucreaza un angajat');
        else DBMS_OUTPUT.PUT_LINE('In departamentul '|| v_nume||' lucreaza '|| v_nr||' angajati');
    end case;
END LOOP;
CLOSE c;
END;