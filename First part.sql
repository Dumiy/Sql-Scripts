declare
 dep_name departments.department_name%TYPE;
 employ int ;
BEGIN
 select department_name,count(department_name)
 into dep_name,employ
 from employees e, departments d 
 where e.department_id = d.department_id
 group by department_name
 having count(*) = (select max (count (*))
                    from employees
                    group by department_id);
 dbms_output.put_line('Department ' || dep_name || employ);
end;




select d.department_name,count(d.department_name) as total
from departments d ,employees e
where d.department_id = e.department_id
group by department_name
order by total desc;




declare 
    v_cod employees.employee_id%Type := &p;
    v_salariu number(8);
    v_bonus number (6);
    begin
    select salary
    into v_salariu
    from employees
    where employee_id = v_cod;
    if v_salariu >= 20001
        then v_bonus:=2000;
    elsif v_salariu between 10001 and 20000
        then v_bonus := 1000;
    else v_bonus := 500;
    end if;
    dbms_output.put_line('Bonusul este ' || v_bonus);
    exception
    when NO_DATA_FOUND then
        raise NO_DATA_FOUND;
end;

with temporaryTable as
(
select count(d.department_name) as total
from departments d ,employees e
where d.department_id = e.department_id
group by department_name
)
select temporaryTable.total 
from temporaryTable
order by temporaryTable.total  desc;


    
    