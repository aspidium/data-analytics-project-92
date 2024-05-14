INSERT INTO "select 
CONCAT(e.first_name,' ', e.last_name) as seller,
floor(avg(p.price * s.quantity)) as average_income 
from salesdb.public.sales s
left join salesdb.public.employees e  on s.sales_person_id  = e.employee_id  
left join salesdb.public.products p on p.product_id = s.product_id 
group by 1
having floor(avg(p.price * s.quantity)) <( select floor(avg(p.price * s.quantity)) as average
      from salesdb.public.sales s
      left join salesdb.public.products p on p.product_id = s.product_id)
      order by 2" (seller,average_income) VALUES
	 ('Stearns MacFeather',46407),
	 ('Ann Dull',55090),
	 ('Morningstar Greene',88124),
	 ('Marjorie Green',109395),
	 ('Johnson White',126133),
	 ('Anne Ringer',136767),
	 ('Cheryl Carson',139818),
	 ('Reginald Blotchet-Halls',151773),
	 ('Charlene Locksley',152007),
	 ('Michael O''Leary',161108);
INSERT INTO "select 
CONCAT(e.first_name,' ', e.last_name) as seller,
floor(avg(p.price * s.quantity)) as average_income 
from salesdb.public.sales s
left join salesdb.public.employees e  on s.sales_person_id  = e.employee_id  
left join salesdb.public.products p on p.product_id = s.product_id 
group by 1
having floor(avg(p.price * s.quantity)) <( select floor(avg(p.price * s.quantity)) as average
      from salesdb.public.sales s
      left join salesdb.public.products p on p.product_id = s.product_id)
      order by 2" (seller,average_income) VALUES
	 ('Burt Gringlesby',167993),
	 ('Abraham Bennet',170983),
	 ('Sylvia Panteley',179517),
	 ('Meander Smith',188075),
	 ('Sheryl Hunter',225515);
