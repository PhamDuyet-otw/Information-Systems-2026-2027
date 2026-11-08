-- LAB 4D --
-- Question 1 : List names of all the languages in the database (sorted aphabetically )
select l.name
from language as l
order by name asc;
-- Question 2: List full names of actors with “GER” in their last name,ordered by their first name)
select concat(first_name,' ', last_name) as full_name
from actor
where last_name LIKE '%GER%'
order by first_name asc;
-- question 3: find all the addresses where postal code starts with "57", and return addresses sorted
select address
from address 
where postal_code like '57%'
order by address asc;
-- question 4: how many films involve a "DWARF" in their titles?
select count(*) as flim_count
from film
where title LIKE '%DWARF%';
-- question 5: find full names of actors who played in a film involving "WAR" in its title and longer than 2.5 hours,
-- along with the title, run length and release year of the movie, sorted by the actors' last names
select concat(a.first_name, ' ', a.last_name) as full_name,
       f.title, f.length, f.release_year
from actor as a
join film_actor as fa on a.actor_id = fa.actor_id
join film as f on fa.film_id = f.film_id
where f.title like '%WAR%'
  and f.length > 150
order by a.last_name asc;
-- question 6: find all film categories with between 55 and 65 films,
-- return their names and film counts, sorted by the number of films descending
select c.name as category_name, count(fc.film_id) as film_count
from category as c
join film_category as fc on c.category_id = fc.category_id
group by c.category_id, c.name
having count(fc.film_id) between 55 and 65
order by film_count desc;
-- question 7: in how many film categories is the average difference 
-- between replacement cost and rental rate larger than 17?
select count(*) as category_count
from (
    select fc.category_id
    from film_category as fc
    join film as f on fc.film_id = f.film_id
    group by fc.category_id
    having avg(f.replacement_cost - f.rental_rate) > 17
) as matching_categories;
-- question 8: find district names whose minimum postal code is the maximum of all district minimums,
-- ignoring empty postal codes and district names
select a.district
from address as a
where a.district is not null
  and a.postal_code is not null
group by a.district
having min(a.postal_code) = (
    select max(d.min_postal_code)
    from (
        select min(postal_code) as min_postal_code
        from address
        where district is not null
          and trim(district) <> ''
          and postal_code is not null
          and trim(postal_code) <> ''
        group by district
    ) as d
)
order by a.district asc;
-- question 9: find first and last names of all actors and customers with the same first name
-- as actor id 101, excluding actor id 101
select a.first_name, a.last_name
from actor as a
where a.first_name = (
    select first_name
    from actor
    where actor_id = 101)
and a.actor_id <> 101
union all
select c.first_name, c.last_name
from customer as c
where c.first_name = (
    select first_name
    from actor
    where actor_id = 101)
order by first_name, last_name;