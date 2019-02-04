---- db: -h localhost -p 5433 -U postgres testbase

--insert into phones_number values ('Kreez', 'Saint-Petersburg', '89999101234', '9999');
----
--select * from phones_number
----
--update phones_number
  --  set mobile = '+79111112233', worknumb = '666'
--where username ='Kreez';
----
--select resource#>> '{activestatus}'
--from patient
--limit 5;
----
--update patient
--set resource = resource || '{"activestatus": false}'::jsonb
--where resource#>> '{birthDate}'= '1955-06-27';
----
--select resource#>>'{birthDate}'
--from patient
--where resource#>> '{birthDate}'> '1955-06-27';
----
--select resource#>>'{name,0,given,0}', resource#>>'{name,0,family}'
--from patient
--where (resource#>>'{activestatus}')::boolean = true;
----

--The most ill patients

\timing
select p.resource#>>'{name, 0, given, 0}' as first_name, p.resource#>>'{name,0,family}' as second_name, enc.num, p.resource#>> '{id}' as patient_id
from patient as p
join
(
      SELECT count (resource#>>'{subject, id}') as num, (resource#>>'{subject, id}') as user_id
             FROM encounter
             group by resource#>>'{subject, id}'
             )as enc
on p.id = enc.user_id
order by enc.num desc
limit 10;
----

-- The most often diseases
select c.resource#>>'{code, text}' as ill_name, count (distinct(c.resource#>>'{subject, id}')) as num
from condition c
group by ill_name 
order by num desc
limit 10;

----

--The most number of cases due to illness

select p.resource#>> '{name, 0, given, 0}' as first_name, p.resource#>>'{name, 0, family}' as second_name, enc.ill_name, enc.num
from patient p
join
(
    select c.resource#>>'{code, text}' as ill_name, count (*) as num, c.resource#>>'{subject, id}' as patient_id
    from condition c
    group by ill_name, patient_id
    order by num desc

)as enc
on p.id = enc.patient_id and enc.num >=5
limit 10;
 
----

--The youngest patients

select resource#>>'{name, 0, given, 0}' as patient_name, resource#>>'{name, 0, family}' as patient_family, date_part('year', current_date) - date_part('year',to_date(resource#>>'{birthDate}','YYYY-MM-DD')) as age
from patient
order by age asc
limit 5;
----

-- The number of patients of a certain age

select count (*) as num, date_part('year', current_date) - date_part('year',to_date(resource#>>'{birthDate}','YYYY-MM-DD')) as age
from patient
where  date_part('year', current_date) - date_part('year',to_date(resource#>>'{birthDate}','YYYY-MM-DD')) > 0 and date_part('year', current_date) - date_part('year',to_date(resource#>>'{birthDate}','YYYY-MM-DD')) < 10
group by age;
--date_part('year', current_date) - date_part('year',to_date(resource#>>'{birthDate}','YYYY-MM-DD'));
----
--select resource#>> '{name, 0, given, 0}' firstname, resource#>>'{name,0, family}' secondname
--from patient
--where resource#>> '{address, 0, city}'='Tewksbury';
--
----

--The top three diseases of patients who was born between 1961 and 2000

select c.resource#>>'{code, text}' as disease_name, count(distinct(c.resource#>>'{subject, id}')) as numbers
from condition c
join
(
    select p.id as patient_id
    from patient p
    where to_date(resource#>>'{birthDate}', 'YYYY-MM-DD') > to_date('1961-05-12', 'YYYY-MM-DD') and to_date(resource#>>'{birthDate}','YYYY-MM-DD') < to_date('2000-07-23', 'YYYY-MM-DD')
) as ant 
on  c.resource#>> '{subject, id}' = ant.patient_id
group by disease_name
order by numbers desc
limit 3;
----
-- crud operations in testbase
----
create table mans (resource jsonb);
----
insert into mans(resource) values (jsonb_build_object('gender', 'male', 'birthdate', '1987-06-21', 'address', '[{"city":"SPB"}, {"country": "Russia"}, {"street": "Pobeda street"}]'::jsonb));
----
select jsonb_pretty(resource) from mans;
----
