" First CDS
define view zcds_hremp as select from zhrempmaster 
{
   key emp_id as id,
emp_name  as name,
emp_add as addr,
emp_mobile as mobile
} 

" sencod CDS for join
define view zcds_hrdept_1
  as select from zhrempmaster as emp
    inner join zhrempdet as dept
      on dept.emp_id = emp.emp_id
{
    key emp.emp_id     as id,
        emp.emp_name   as name,
        emp.emp_add    as addr,
        emp.emp_mobile as mobile,
        dept.emp_sal   as salary
}
