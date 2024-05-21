set serveroutput on
create or replace function sum_of_week(
    start_date in date
) return number as
subtotal number := 0;
BEGIN
select sum(total_cost) into subtotal
from order_table where (date_time - start_date < 8);

return subtotal;

END;
/