---1

create or replace trigger on_delete
 before delete on dept_ana
begin
    if USER <> 'Scott'
    then
    raise_application_error(-20015,'Only scot is permited');
    end if;
end;
/

delete
from dept_ana
where department_id = 10;

drop trigger on_delete;


 --- 2
 create or replace trigger raise_commision
 before update of salary on employee
 for each row
 begin
    if(:NEW.salary < :OLD.salary)then
    raise_application_error(-20009,'salariu nu poate fii mai mic');
    end if;
 end;
/
drop trigger on_delete;

create table info_dept_dumi as (select * from info_dept_jit);


alter table info_dept_dumi
drop column numar;


alter table info_dept_dumi
add numar int;

create or replace procedure dumi_table_update
is
begin
for i in ( select (count(*)) as total,department_id as dep_id
           from employees
           where department_id is not null
           group by department_id
           )
    loop
    update info_dept_dumi
    set numar = i.total
    where id = i.dep_id;
    end loop;
    end;
    /
    
drop procedure dumi_table_update;


create or replace trigger info_dept_update_dumi
after insert or delete on employees
begin
    dumi_table_update;
    end;
    /
select * from employees where employee_id=300;
    
    insert into employees values(92,'adsasdaadgdgsa','asdsasdsaaasFASFdd','dsasafsdsfsafadasad','gdgASDASD','17-JUN-87','AD_VP',26460,null,null,90);
    
    
    begin
    for i in ( select (count(*)) as total,department_id as dep_id
           from employees
           where department_id is not null
           group by department_id
           )
    loop
    dbms_output.put_line(i.total || '   ' || i.dep_id);
    end loop;
    end;
    /

        