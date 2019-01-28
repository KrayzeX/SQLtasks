---- db: -h localhost -p 5432 -U postgres  fhirbase

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
      SELECT count (resource#>>'{subject, id}') as num, (resource#>>'{subject, id}') user_id
             FROM encounter
             group by resource#>>'{subject, id}'
              order by count(resource#>>'{subject, id}') DESC
             limit 10
             )as enc
on p.id = enc.user_id;
----

-- The most often diseases
select c.resource#>>'{code, text}' as ill_name, count (distinct(c.resource#>>'{subject, id}')) as num
from condition c
group by ill_name 
order by num desc
limit 10;

----
--select resource#>> '{name, 0, given, 0}' firstname, resource#>>'{name,0, family}' secondname
--from patient
--where resource#>> '{address, 0, city}'='Tewksbury';
--

