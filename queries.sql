--Проект Продажи
--4.Работа с базой данных
--запрос, который считает общее количество покупателей из таблицы customers
select count(customer_id) as customers_count
from salesdb.public.customers c;

--5.Анализ отдела продаж
--Первый отчет о десятке лучших продавцов. 
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

--Второй отчет содержит информацию о продавцах, чья средняя выручка за сделку меньше средней выручки за сделку по всем продавцам. 
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

--Третий отчет содержит информацию о выручке по дням недели.
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

--6.Анализ покупателей
--Первый отчет - количество покупателей в разных возрастных группах: 16-25, 26-40 и 40+.
select 
( CASE -- использование оператора CASE для обработки и выполнения условий
            WHEN c.age between 16 and 25 THEN '16-25'
            WHEN c.age between 26 and 40 THEN '26-40'
            ELSE '40+' 
        END
    ) AS age_category,
    COUNT(c.customer_id) AS age_count --количество покупателей 
FROM salesdb.public.customers c
group by 1
order by 1;

--Второй отчет -- данные по количеству уникальных покупателей и выручке, которую они принесли
select distinct 
to_char(s.sale_date, 'YYYY-MM') as selling_month, -- получение даты в указанном формате
count(s.customer_id) as total_customers, --количество покупателей
floor (sum(p.price * s.quantity)) as income -- принесенная выручка
from salesdb.public.sales s 
left join salesdb.public.products p on p.product_id = s.product_id 
group by 1
order by 1;

--Третий отчет о покупателях, первая покупка которых была в ходе проведения акций (акционные товары отпускали со стоимостью равной 0). 
SELECT
CONCAT(c.first_name,' ', c.last_name) AS customer, -- объединение имени и фамилии в одной ячейке
MIN(s.sale_date) as sale_date,  -- поиск первой даты
CONCAT(e.first_name,' ', e.last_name) AS seller -- объединение имени и фамилии в одной ячейке
FROM salesdb.public.sales s 
INNER JOIN salesdb.public.products  p  ON p.product_id  = s.product_id 
INNER JOIN salesdb.public.customers c  ON c.customer_id = s.customer_id 
INNER JOIN salesdb.public.employees e  ON e.employee_id = s.sales_person_id  
WHERE p.price  = 0 --товары со стоимостью равной 0
GROUP BY 1,3,s.customer_id
ORDER BY s.customer_id;
