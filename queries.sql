--Проект Продажи
--4.Работа с базой данных
--запрос, который считает общее количество покупателей из таблицы customers
select count(customer_id) as customers_count
from salesdb.public.customers;

--5.Анализ отдела продаж
--Первый отчет о десятке лучших продавцов. 
select
    -- объединение имени и фамилии в одной ячейке
    concat(e.first_name, ' ', e.last_name) as seller,
    count(s.sales_id) as operations, --  количество проведенных сделок
    floor(sum(p.price * s.quantity)) as income  -- суммарная выручка
from salesdb.public.sales as s
-- присоединение таблицы продавцов
left join salesdb.public.employees as e on s.sales_person_id = e.employee_id
-- присоединение теблицы товаров
left join salesdb.public.products as p on s.product_id = p.product_id
group by 1 -- группировка по seller
order by 3 desc --сортировка в обратном порядке
limit 10; --вывод первых 10

--Второй отчет содержит информацию о продавцах, чья средняя выручка за сделку меньше средней выручки за сделку по всем продавцам. 
select
    -- объединение имени и фамилии в одной ячейке
    concat(e.first_name, ' ', e.last_name) as seller,
    -- округление в меньшую сторону средней выручки каждого продавца
    floor(avg(p.price * s.quantity)) as average_income
from salesdb.public.sales as s
-- присоединение таблицы продавцов
left join salesdb.public.employees as e on s.sales_person_id = e.employee_id
-- присоединение теблицы товаров
left join salesdb.public.products as p on s.product_id = p.product_id
group by 1
having
    floor(avg(p.price * s.quantity))
    < (
        select floor(avg(p.price * s.quantity)) as average
        from salesdb.public.sales as s
        left join salesdb.public.products as p on s.product_id = p.product_id
    ) -- сравнение среднего значения выручки за сделку каждого продавца со средней выручкой за сделку по всем продавцам.
order by 2;

--Третий отчет содержит информацию о выручке по дням недели.
with dat as (
    select
        -- объединение имени и фамилии в одной ячейке
        concat(e.first_name, ' ', e.last_name) as seller,
        -- преобразование число или дату в строку
        to_char(s.sale_date, 'day') as day_of_week,
        -- округление в меньшую сторону средней выручки каждого продавца
        floor(sum(p.price * s.quantity)) as income,
        extract(isodow from s.sale_date) as dow -- извлечение дня недели из даты
    from salesdb.public.sales as s
    inner join salesdb.public.products as p on s.product_id = p.product_id
    inner join
        salesdb.public.employees as e
        on s.sales_person_id = e.employee_id
    group by 1, 2, 4
)

select
    seller,
    day_of_week,
    income
from dat
order by dow, seller;

--6.Анализ покупателей
--Первый отчет - количество покупателей в разных возрастных группах: 16-25, 26-40 и 40+.
select
    (
        case -- использование оператора CASE для обработки и выполнения условий
            when c.age between 16 and 25 then '16-25'
            when c.age between 26 and 40 then '26-40'
            else '40+'
        end
    ) as age_category,
    count(c.customer_id) as age_count --количество покупателей 
from salesdb.public.customers as c
group by 1
order by 1;

--Второй отчет -- данные по количеству уникальных покупателей и выручке, которую они принесли
with tab as (
    select
        -- получение даты в указанном формате
        to_char(s.sale_date, 'YYYY-MM') as selling_month,
        sum(p.price * s.quantity) as total, -- принесенная выручка
        customer_id as cc
    from salesdb.public.sales as s
    inner join salesdb.public.products as p on s.product_id = p.product_id
    group by 1, 3
)

select distinct
    tab.selling_month,
    count(tab.cc) as total_customers,
    floor(sum(tab.total)) as income
from tab
group by 1
order by 1;

--Третий отчет о покупателях, первая покупка которых была в ходе проведения акций (акционные товары отпускали со стоимостью равной 0). 
with tab as (
    select
        s.sale_date,
        p.price,
        concat(c.first_name, ' ', c.last_name) as customer,
        concat(e.first_name, ' ', e.last_name) as seller,
        row_number()
            over (
                partition by concat(c.first_name, c.last_name)
                order by sale_date
            )
        as rn
    from salesdb.public.sales as s
    inner join salesdb.public.products as p on s.product_id = p.product_id
    inner join salesdb.public.customers as c on s.customer_id = c.customer_id
    inner join
        salesdb.public.employees as e
        on s.sales_person_id = e.employee_id
    order by s.customer_id
)

select
    tab.customer,
    tab.sale_date,
    tab.seller
from tab
where tab.price = 0 and tab.rn = 1;
