declare
    type angajat is record(
    cod emp_dumi.employee_id%Type,
    salariu emp_dumi.salary%Type,
    job emp_dumi.job_id%Type
    );
    v_ang angajat;
    begin
    select employee_id,salary,job_id
    into v_ang
    from emp_dumi
    where employee_id = 105;
    dbms_output.put_line(count(v_ang));
    end;
    /
    
    

declare
type indexed_emp_dumi is table of emp_dumi%ROWTYPE
index by binary_integer;
lista indexed_emp_dumi;

cursor cursor_emp_dumi is
    select *
    from emp_dumi;
begin
 if cursor_emp_dumi %ISOPEN then
 close cursor_emp_dumi;
 end if;

for i in cursor_emp_dumi loop
    lista(i.employee_id):=i;
    dbms_output.put(lista(i.employee_id).salary || '  ');
end loop;
dbms_output.new_line;
exception
when CURSOR_ALREADY_OPEN then
   close cursor_emp_dumi;
   raise;
end;
/

declare
type imbricat is table of number;
t imbricat :=imbricat();
begin 
    for i in 1..10 loop
        t.extend();
        t(i):=i;
    end loop;
    for i in t.first..t.last loop
        dbms_output.put(t(i) || ' ');
        end loop;
    dbms_output.new_line;
    for i in t.first..t.last loop
        if t(i) mod 2 = 1 then 
        dbms_output.put(t(i));
        else dbms_output.put('  impar ');
        end if;
        end loop;
    dbms_output.new_line;
    end;
    
    /
    
    
create table test_dumi as select employee_id,first_name,last_name,salary from employees;


/

create or replace type cost_dumi is table of number;
/

alter table test_dumi
add (costuri cost_dumi)
nested table costuri store as tabel_cost_dumi;
/

insert into test_dumi
values(900,'dumi','dumi',1500,cost_dumi(200));

begin
    for i in (
                select *
                from test_dumi
                where costuri is null
             )
        loop
        update test_dumi
        set costuri = cost_dumi(round((i.salary/12)))
        where employee_id = i.employee_id;
        end loop;
end;
/



drop table test_dumi;
drop type cost_dumi;
