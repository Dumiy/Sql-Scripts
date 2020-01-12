select * from tab;

create table emp_prof as select * from employees;
create table dept_prof as select * from departments;

--mutating

--1
-- fara coloane calculate
-- fara tabele copie
-- mutating
CREATE OR REPLACE TRIGGER validare_prof
    BEFORE INSERT OR UPDATE OF department_id ON emp_prof
    FOR EACH ROW
DECLARE 
    nr NUMBER(4);
BEGIN
    SELECT COUNT(*) INTO nr
    FROM emp_prof
    WHERE department_id = :NEW.department_id;
    IF nr = 45 THEN 
        RAISE_APPLICATION_ERROR(-20000, 'Intr-un departament nu pot lucra mai mult de 45 de angajati');
    END IF;
END;
/

desc emp_prof

select department_id, count(*)
from   emp_prof
group by department_id;

-- comenzi cu care verificam implementarea
--test 1
insert into emp_prof
values (301, 'a','b','e301',null,sysdate,'j',100,null,100,100);

insert into emp_prof
values (302, 'a','b','e301',null,sysdate,'j',100,null,100,50);

select * from emp_prof where employee_id in (301,302);
rollback;

--test 2
insert into emp_prof
values (301, 'a','b','e301',null,sysdate,'j',100,null,100,100);

insert into emp_prof
select 302, 'a','b','e301',null,sysdate,'j',100,null,100,50
from   dual;

select * from emp_prof where employee_id in (301,302);
rollback;

--test 3
select department_id, count(*)
from   emp_prof
group by department_id;

update emp_prof
set    department_id = 100
where  department_id = 30;

--comenzi care nu tb sa treaca testul
select department_id, count(*)
from   emp_prof
where department_id in (30,40,50,80,100)
group by department_id;

update emp_prof
set    department_id = 80
where  department_id not in (50,80);

insert into emp_prof
select * from employees 
where  department_id=80;

rollback;

DROP TRIGGER validare_prof;

--2
-----------------------------------------------------------------
--rezolvare folosind tabela copie

create table emp_copie_prof as select * from emp_prof;

CREATE OR REPLACE TRIGGER validare_prof
    BEFORE INSERT OR UPDATE OF department_id ON emp_prof
    FOR EACH ROW
DECLARE 
    nr NUMBER(4);
BEGIN
    SELECT COUNT(*) INTO nr
    FROM emp_copie_prof
    WHERE department_id = :NEW.department_id;
    IF nr = 45 THEN 
        RAISE_APPLICATION_ERROR(-20000, 'Intr-un departament nu pot lucra mai mult de 45 de angajati');
    END IF;
END;
/

-- comenzi cu care verificam implementarea
--test 1
insert into emp_prof
values (301, 'a','b','e301',null,sysdate,'j',100,null,100,100);

insert into emp_prof
values (302, 'a','b','e301',null,sysdate,'j',100,null,100,50);

select * from emp_prof where employee_id in (301,302);
rollback;

--test 2
insert into emp_prof
values (301, 'a','b','e301',null,sysdate,'j',100,null,100,100);

insert into emp_prof
select 302, 'a','b','e301',null,sysdate,'j',100,null,100,50
from   dual;

select * from emp_prof where employee_id in (301,302);
rollback;

delete from emp_prof
where employee_id = 301;

commit;

--test 3
select department_id, count(*)
from   emp_prof
group by department_id;

update emp_prof
set    department_id = 100
where  department_id = 30;

update emp_prof
set    department_id = 50
where  department_id = 40;

--comenzi care trec testul desi nu ar fi trebuit
select department_id, count(*)
from   emp_prof
group by department_id;

update emp_prof
set    department_id = 80
where  department_id not in (50,80);

insert into emp_prof
select * from employees 
where  department_id=80;

rollback;

DROP TRIGGER validare_prof;

--3 (rezolvare pt greseli var 2)
--rezolvare pb in acest caz
create or replace package pck_prof
as
  type tab_contor is table of number index by pls_integer;
  contor tab_contor;
end;
/

create or replace trigger t_prof 
  before insert or update of department_id on emp_prof
  for each row
declare
  nr_ang number(4);
begin
  if pck_prof.contor.exists(:new.department_id) then 
    null;
  else   pck_prof.contor(:new.department_id) := 0;
  end if;

  select count(*) into nr_ang
  from   emp_copie_prof 
  where  department_id = :new.department_id;
  
  if nr_ang + pck_prof.contor(:new.department_id) >= 45 then 
     raise_application_error(-20000,'intr-un dept nu pot lucra mai mult de 45 ang');
  end if;   
  
  pck_prof.contor(:new.department_id) := pck_prof.contor(:new.department_id)+1;
end;
/

--comenzi care trec testul desi nu ar fi trebuit
select department_id, count(*)
from   emp_prof
group by department_id;

update emp_prof
set    department_id = 80
where  department_id not in (50,80);

insert into emp_prof
select * from employees 
where  department_id=80;

drop trigger t_prof;

--4 (rezolvare rezolvare probleme 2)
--rezolvare sincronizare tabel copie
--pastrati triggerul de la 2
create or replace trigger t_sincron_prof
  after insert or update or delete on emp_prof 
  for each row
begin
  if inserting then
     insert into emp_copie_prof
     values (:new.EMPLOYEE_ID,
            :new.FIRST_NAME,
            :new.LAST_NAME,
            :new.EMAIL,
            :new.PHONE_NUMBER,
            :new.HIRE_DATE,
            :new.JOB_ID,
            :new.SALARY,
            :new.COMMISSION_PCT,
            :new.MANAGER_ID,
            :new.DEPARTMENT_ID);
   elsif updating then
      update emp_copie_prof
      set   
            FIRST_NAME = :new.FIRST_NAME,
            LAST_NAME = :new.LAST_NAME,
            EMAIL = :new.EMAIL,
            PHONE_NUMBER = :new.PHONE_NUMBER,
            HIRE_DATE = :new.HIRE_DATE,
            JOB_ID = :new.JOB_ID,
            SALARY = :new.SALARY,
            COMMISSION_PCT = :new.COMMISSION_PCT,
            MANAGER_ID = :new.MANAGER_ID,
            DEPARTMENT_ID = :new.DEPARTMENT_ID
      where EMPLOYEE_ID = :old.EMPLOYEE_ID;      
   else
      delete from emp_copie_prof
      where EMPLOYEE_ID = :old.EMPLOYEE_ID;
   end if;
end;
/

desc user_tab_columns

select column_name||' = :new.'||column_name||',' 
from user_tab_columns
where table_name=upper('emp_prof');

--test 1
insert into emp_prof
values (301, 'a','b','e301',null,sysdate,'j',100,null,100,100);

insert into emp_prof
values (302, 'a','b','e301',null,sysdate,'j',100,null,100,50);

select * from emp_prof where employee_id in (301,302);
select * from emp_copie_prof where employee_id in (301,302);

rollback;

--test 2
insert into emp_prof
values (301, 'a','b','e301',null,sysdate,'j',100,null,100,100);

insert into emp_prof
select 302, 'a','b','e301',null,sysdate,'j',100,null,100,50
from   dual;

select * from emp_prof where employee_id in (301,302);
select * from emp_copie_prof where employee_id in (301,302);
rollback;

--test
select department_id, count(*)
from   emp_prof
group by department_id;

update emp_prof
set    department_id = 100
where  department_id = 30;

update emp_prof
set    department_id = 50
where  department_id = 40;

select department_id, count(*)
from   emp_prof
group by department_id;

select department_id, count(*)
from   emp_copie_prof
group by department_id;
rollback;

--comenzi care nu trec testul
select department_id, count(*)
from   emp_prof
group by department_id;

update emp_prof
set    department_id = 80
where  department_id not in (50,80);

insert into emp_prof
select * from employees 
where  department_id=80;

drop package pck_prof;
drop trigger validare_prof;
drop trigger t_sincron_prof;

--5
-----------------------------------------------------------------
--rezolvare fara tabela copie
create or replace package pck_prof
as
  type tab_contor is table of number index by pls_integer;
  contor tab_contor;
  contor_sterg tab_contor;
  
  type rec is record (id number(4), nr number(4));
  type tab_ang is table of rec;
  t tab_ang;

end;
/

create or replace trigger t_comanda_prof 
  before insert or update of department_id on emp_prof
begin
  pck_prof.contor := pck_prof.contor_sterg;
  select department_id, count(*) 
  bulk collect into pck_prof.t
  from   emp_prof
  group by department_id;
end;
/


create or replace trigger t_linie_prof 
  before insert or update of department_id on emp_prof
  for each row
begin
  if pck_prof.contor.exists(:new.department_id)
  then null;
  else   pck_prof.contor(:new.department_id) := 0;
  end if;

  for i in 1..pck_prof.t.last loop 
      if pck_prof.t(i).id = :new.department_id and pck_prof.t(i).nr + pck_prof.contor(:new.department_id) >= 45 then 
         raise_application_error(-20000,'intr-un dept nu pot lucra mai mult de 45 ang');
      end if;   
  end loop;
  pck_prof.contor(:new.department_id) := pck_prof.contor(:new.department_id)+1;
end;
/

--test 1
insert into emp_prof
values (301, 'a','b','e301',null,sysdate,'j',100,null,100,100);

insert into emp_prof
values (302, 'a','b','e301',null,sysdate,'j',100,null,100,50);

select * from emp_prof where employee_id in (301,302);
rollback;

--test 2
insert into emp_prof
values (301, 'a','b','e301',null,sysdate,'j',100,null,100,100);

insert into emp_prof
select 302, 'a','b','e301',null,sysdate,'j',100,null,100,50
from   dual;

select * from emp_prof where employee_id in (301,302);
rollback;

--test 3
select department_id, count(*)
from   emp_prof
group by department_id;

update emp_prof
set    department_id = 100
where  department_id = 30;

update emp_prof
set    department_id = 50
where  department_id = 40;

select department_id, count(*)
from   emp_prof
group by department_id;

rollback;

--comenzi care nu trec testul
select department_id, count(*)
from   emp_prof
group by department_id;

update emp_prof
set    department_id = 80
where  department_id not in (50,80);

insert into emp_prof
select * from employees 
where  department_id=80;

drop package pck_prof;
drop trigger t_comanda_prof;
drop trigger t_linie_prof;

--6
-- rezolvare cu coloana calculata
alter table dept_prof
add nr_ang number(4) default 0;

update dept_prof d
set nr_ang = (select count(*) from emp_prof where department_id = d.department_id);

SELECT *
FROM dept_prof;

create or replace procedure p_prof (v_id dept_prof.department_id%type, v_nr number)
as
begin
   update dept_prof
   set    nr_ang = nr_ang + v_nr
   where  department_id = v_id;
end;
/

CREATE OR REPLACE TRIGGER validare_prof
    BEFORE INSERT OR UPDATE OF department_id ON emp_prof
    FOR EACH ROW
DECLARE 
    v_nr NUMBER;
BEGIN
    SELECT nr_ang 
    INTO v_nr
    FROM dept_prof
    WHERE department_id = :NEW.department_id;
    IF v_nr = 45 THEN 
        raise_application_error(-20000,'intr-un dept nu pot lucra mai mult de 45 ang');
    END IF;
END;
/

create or replace trigger t_prof 
    after update or insert or delete of department_id on emp_prof
    for each row
begin
  if inserting then
    p_prof(:new.department_id, 1);
  elsif deleting then
    p_prof(:old.department_id, -1);
  else
    p_prof(:new.department_id, 1);
    p_prof(:old.department_id, -1);
  end if;  
end;
/

--test
insert into emp_prof
values (301, 'a','b','e301',null,sysdate,'j',100,null,100,100);

select * from dept_prof where department_id in (100,80,50);

update emp_prof
set    department_id = 80
where  employee_id = 301;

delete from emp_prof where employee_id = 301;

rollback;

--create or replace trigger tv_prof 
--before insert or update of department_id on emp_prof
--for each row
--declare
--  nr number(4);
--begin
--  select nr_ang into nr
--  from   dept_prof 
--  where  department_id = :new.department_id;
--  
--  if nr = 45 then 
--     raise_application_error(-20000,'intr-un dept nu pot lucra mai mult de 45 ang');
--  end if;   
--end;
--/


--test 1
insert into emp_prof
values (301, 'a','b','e301',null,sysdate,'j',100,null,100,100);

insert into emp_prof
values (302, 'a','b','e301',null,sysdate,'j',100,null,100,50);

select * from emp_prof where employee_id in (301,302);
select * from dept_prof where department_id in (100,80,50);
rollback;

--test 2
insert into emp_prof
values (301, 'a','b','e301',null,sysdate,'j',100,null,100,100);

insert into emp_prof
select 302, 'a','b','e301',null,sysdate,'j',100,null,100,50
from   dual;

select * from emp_prof where employee_id in (301,302);
select * from dept_prof where department_id in (100,80,50);
rollback;

--test 3
select * from dept_prof where department_id in (100,80,50,30,40);

update emp_prof
set    department_id = 100
where  department_id = 30;

update emp_prof
set    department_id = 50
where  department_id = 40;

rollback;

--comenzi care nu trec testul
select * from dept_prof where department_id in (100,80,50,30,40);

update emp_prof
set    department_id = 80
where  department_id not in (50,80);

insert into emp_prof
select * from employees 
where  department_id=80;

drop trigger t_prof;
drop trigger tv_prof;
drop trigger validare_prof;

--7
--cu vizualizare
create or replace view v_prof 
as
select * from emp_prof;

create or replace trigger t_prof
  instead of insert or update or delete on v_prof
  for each row
declare
  nr_ang number(4);
begin
  select count(*) into nr_ang
  from   emp_prof 
  where  department_id = :new.department_id;
  
  if deleting then
      delete from emp_prof
      where EMPLOYEE_ID = :old.EMPLOYEE_ID;
  elsif nr_ang = 45 then 
     raise_application_error(-20000,'intr-un dept nu pot lucra mai mult de 45 ang');
  end if;  
  
  if inserting then
     insert into emp_prof
     values (:new.EMPLOYEE_ID,
            :new.FIRST_NAME,
            :new.LAST_NAME,
            :new.EMAIL,
            :new.PHONE_NUMBER,
            :new.HIRE_DATE,
            :new.JOB_ID,
            :new.SALARY,
            :new.COMMISSION_PCT,
            :new.MANAGER_ID,
            :new.DEPARTMENT_ID);
   elsif updating then
      update emp_prof
      set   
            FIRST_NAME = :new.FIRST_NAME,
            LAST_NAME = :new.LAST_NAME,
            EMAIL = :new.EMAIL,
            PHONE_NUMBER = :new.PHONE_NUMBER,
            HIRE_DATE = :new.HIRE_DATE,
            JOB_ID = :new.JOB_ID,
            SALARY = :new.SALARY,
            COMMISSION_PCT = :new.COMMISSION_PCT,
            MANAGER_ID = :new.MANAGER_ID,
            DEPARTMENT_ID = :new.DEPARTMENT_ID
      where EMPLOYEE_ID = :old.EMPLOYEE_ID;      
   end if;
 end;
/

--test 1
insert into v_prof
values (301, 'a','b','e301',null,sysdate,'j',100,null,100,100);

insert into v_prof
values (302, 'a','b','e301',null,sysdate,'j',100,null,100,50);

select * from emp_prof where employee_id in (301,302);
rollback;

--test 2
insert into v_prof
values (301, 'a','b','e301',null,sysdate,'j',100,null,100,100);

insert into v_prof
select 302, 'a','b','e301',null,sysdate,'j',100,null,100,50
from   dual;

select * from emp_prof where employee_id in (301,302);
rollback;

--test 3
select department_id, count(*)
from   emp_prof
group by department_id;

update v_prof
set    department_id = 100
where  department_id = 30;

update v_prof
set    department_id = 50
where  department_id = 40;

--comenzi care nu trec testul
select department_id, count(*)
from   emp_prof
group by department_id;

update v_prof
set    department_id = 80
where  department_id not in (50,80);

insert into v_prof
select * from employees 
where  department_id=80;

rollback;

drop trigger t_prof;