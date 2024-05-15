-- This query returns count of customers
select count(customer_id) as customers_count
from salesdb.public.customers c;

select 
CONCAT(e.first_name,' ', e.last_name) as seller, -- объединение имени и фамилии в одной ячейке
count(s.sales_id) as operations, --  количество проведенных сделок
FLOOR (sum(p.price * s.quantity))  as income  -- суммарная выручка
from salesdb.public.sales s
left join salesdb.public.employees e  on s.sales_person_id  = e.employee_id  -- присоединение таблицы продавцов
left join salesdb.public.products p on p.product_id = s.product_id -- присоединение теблицы товаров
group by 1 -- группировка по seller
order by 3 desc --сортировка в обратном порядке
limit 10; --вывод первых 10

select 
CONCAT(e.first_name,' ', e.last_name) as seller, -- объединение имени и фамилии в одной ячейке
floor(avg(p.price * s.quantity)) as average_income -- округление в меньшую сторону средней выручки каждого продавца
from salesdb.public.sales s
left join salesdb.public.employees e  on s.sales_person_id  = e.employee_id  -- присоединение таблицы продавцов
left join salesdb.public.products p on p.product_id = s.product_id -- присоединение теблицы товаров
group by 1
having floor(avg(p.price * s.quantity)) <( select floor(avg(p.price * s.quantity)) as average
      from salesdb.public.sales s
      left join salesdb.public.products p on p.product_id = s.product_id) -- сравнение среднего значения выручки за сделку каждого продавца со средней выручкой за сделку по всем продавцам.
      order by 2;

with dat as (SELECT
               CONCAT(e.first_name,' ', e.last_name) AS seller, -- объединение имени и фамилии в одной ячейке
               TO_CHAR(s.sale_date, 'day') AS day_of_week,  -- преобразование число или дату в строку
               FLOOR(SUM(p.price * s.quantity)) AS income, -- округление в меньшую сторону средней выручки каждого продавца
               EXTRACT(ISODOW FROM s.sale_date) as dow -- извлечение дня недели из даты
             FROM salesdb.public.sales s
             INNER JOIN salesdb.public.products p ON p.product_id = s.product_id 
             INNER JOIN salesdb.public.employees e  ON s.sales_person_id  = e.employee_id
             GROUP by 1,2,4
             )
select 
seller,
day_of_week,
income
FROM dat
ORDER by dow,seller;
