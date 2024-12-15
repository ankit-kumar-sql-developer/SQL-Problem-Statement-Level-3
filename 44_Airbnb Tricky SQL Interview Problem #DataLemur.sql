-- Create the rental_amenities table
CREATE TABLE #rental_amenities (
    rental_id INT,
    amenity VARCHAR(50)
);
delete from #rental_amenities
-- Insert the example data
INSERT INTO #rental_amenities (rental_id, amenity) VALUES
(123, 'pool'),
(123, 'kitchen'),
(234, 'hot tub'),
(234, 'fireplace'),
(345, 'kitchen'),
(345, 'pool'),
(456, 'pool'),
(641, 'fireplace'),
(999, 'fireplace'),
(864, 'fireplace')


select *  from #rental_amenities

--

; with cte as (
select rental_id,STRING_AGG(amenity,',') WITHIN GROUP (order by rental_id,amenity) as grp
from #rental_amenities group by rental_id )

select count(a.rental_id)
from cte a
inner join cte b on a.grp=b.grp and a.rental_id < b.rental_id



--

select COUNT(rental_id) as cnt
from (
select rental_id,STRING_AGG(amenity,',' ) WITHIN GROUP (order by rental_id,amenity) as list
from #rental_amenities
group by rental_id ) t
group by list having COUNT(rental_id) > 1 

