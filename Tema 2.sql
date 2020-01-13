SELECT *
FROM USER_OBJECTS
WHERE OBJECT_TYPE IN ('PROCEDURE','FUNCTION');
SELECT TEXT
FROM USER_SOURCE
WHERE NAME =UPPER('f2_prof');


drop table info_dumi;
create table info_tema_dumi(
    utilizator varchar(40),
    moment date,
    comanda varchar(40),
    lini int,
    exceptie varchar(30)
);
insert into info_tema_dumi values (user,sysdate,'asad',5,NULL);


CREATE OR REPLACE FUNCTION f2_dumi
(v_nume employees.last_name%TYPE DEFAULT 'Bell')
RETURN NUMBER IS
salariu employees.salary%type;
BEGIN
SELECT salary INTO salariu
FROM employees
WHERE last_name = v_nume;
insert into info_tema_dumi 
values(USER,sysdate,'select',1,NULL);
RETURN salariu;

EXCEPTION
WHEN NO_DATA_FOUND THEN
--RAISE_APPLICATION_ERROR(-20000,'Nu exista angajati cu numele dat');
insert into info_tema_dumi (id,utilizator,moment,comanda,lini,exceptie)
values (info_tema_dumi.NEXTVAL,USER,sysdate,'select',1,'nu exista');
WHEN TOO_MANY_ROWS THEN
--RAISE_APPLICATION_ERROR(-20001,'Exista mai multi angajati cu numele dat');
insert into info_tema_dumi 
values (USER,sysdate,' select command ',1,'prea multi cu numele');
WHEN OTHERS THEN
--RAISE_APPLICATION_ERROR(-20002,'Alta eroare!');
insert into info_tema_dumi values (USER,sysdate,' select command ',1,'another error');
END f2_dumi;
/

BEGIN
  DBMS_OUTPUT.PUT_LINE('Salariul este '|| f2_prof('Bell'));
END;
/

select *
from info_tema_dumi;
