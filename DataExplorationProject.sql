/*
World's Best-Selling Phone's Sales Data Exploration

Skills used: 
*/
--view of our dataset
select *
from best_selling_phones bsp;
/*
When viewing the uploaded dataset,
we may notice that some data are not in their proper places,
and some data are missing.
*/
--Let's fix it
--populating data from rank into manufacturer column
update best_selling_phones 
set manufacturer = split_part(rank, ',', 2)
where LENGTH(rank) > 4;

--in order that we have too long columns we need to change data type to pupulate to model column
alter table best_selling_phones 
alter column model
set data type varchar(128);
--populating data from rank into model column
update best_selling_phones 
set model = split_part(rank, ',', 3) || split_part(rank, ',', 4)
where LENGTH(rank) > 4;
--Oh, we see that some records not fully populated, so we need to write special code to this example
update best_selling_phones 
set model = split_part(rank, ',', 3) || split_part(rank, ',', 4) || split_part(rank, ',', 5)
where rank like '21%';
--we need to delete unnecessary "
update best_selling_phones 
set model = TRIM('"' from model)
where LENGTH(rank) > 4;
--here we are also have too long columns we need to change data type to pupulate to form_factor column
alter table best_selling_phones 
alter column form_factor
set data type varchar(64);
--populating data from rank into form_factor column
update best_selling_phones 
set form_factor = split_part(rank, ',', 5)
where LENGTH(rank) > 4;
--we have the same issue with iPhone 12 12 mini 12 Pro & 12 Pro Max and this issue will go on until the end of these process so i won't repeat it
update best_selling_phones 
set form_factor = split_part(rank, ',', 6)
where rank like '21%';
--populating data from rank into smartphone column
update best_selling_phones 
set smartphone = cast(split_part(rank, ',', 6) as BOOLEAN)
where LENGTH(rank) > 4 and rank not like '21%';
update best_selling_phones 
set smartphone = cast(split_part(rank, ',', 7) as BOOLEAN)
where rank like '21%';
--populating data from rank into year column
update best_selling_phones 
set year = cast(split_part(rank, ',', 7) as integer)
where LENGTH(rank) > 4 and rank not like '21%';
update best_selling_phones 
set year = cast(split_part(rank, ',', 8) as integer)
where rank like '21%';
--we have to change data typeof a column because we have not only integers
alter table best_selling_phones 
alter column unit_sold_millons
set data type DOUBLE PRECISION;
--populating data from rank into unit_sold_millons column
update best_selling_phones 
set unit_sold_millons = cast(split_part(rank, ',', 8) as DOUBLE PRECISION)
where LENGTH(rank) > 4 and rank not like '21%';
update best_selling_phones 
set unit_sold_millons = cast(split_part(rank, ',', 9) as DOUBLE PRECISION)
where rank like '21%';
--removing unnecessary information from rank column 
update best_selling_phones 
set rank = split_part(rank, ',', 1)
where LENGTH(rank) > 4;
--change datatypes that we will able to use rank column for sorting 
alter table best_selling_phones 
alter column rank type INTEGER
USING rank::integer;
--Take a look at our cleaned dataset
select *
from best_selling_phones bsp
order by rank;
--Which companies make the most amount of best-selling phones?
select manufacturer, SUM(bsp.unit_sold_millons) as sum
from best_selling_phones bsp 
group by manufacturer 
order by sum desc
--Which companies made the best-selling phones based on each form-factor?
select manufacturer, form_factor, SUM(unit_sold_millons),
		RANK() OVER(PARTITION by form_factor order by SUM(unit_sold_millons) DESC)
from best_selling_phones bsp2 
group by manufacturer, form_factor
--Top-1 companies which made the best-selling phones based on each form-factor?
select manufacturer, form_factor, sum
FROM
(select manufacturer, form_factor, SUM(unit_sold_millons) as sum,
		RANK() OVER(PARTITION by form_factor order by SUM(unit_sold_millons) DESC) rnk
from best_selling_phones bsp2 
group by manufacturer, form_factor)
where rnk <=1
--The most popular phone based on the year of release
SELECT year, manufacturer,model, form_factor, unit_sold_millons 
FROM best_selling_phones bsp
WHERE unit_sold_millons  = (
    SELECT MAX(unit_sold_millons )
    FROM best_selling_phones
    WHERE Year = bsp.Year)
order by year;
--The most popular smartphones of all time
select manufacturer, model, bsp.unit_sold_millons 
from best_selling_phones bsp 
where smartphone = TRUE
order by unit_sold_millons desc
--The most popular not smartphones of all time
select manufacturer, model, bsp.unit_sold_millons 
from best_selling_phones bsp 
where smartphone = FALSE
order by unit_sold_millons desc
--The most_popular phones of each company
select manufacturer, model, sum, rnk
FROM
(select manufacturer, model, SUM(unit_sold_millons) as sum,
		RANK() OVER(PARTITION by manufacturer order by SUM(unit_sold_millons) DESC) rnk
from best_selling_phones bsp2 
group by manufacturer, model)
where rnk <=3;
--The most unpopular phones from the top-selling phones of each company
select manufacturer, model, sum, rnk
FROM
(select manufacturer, model, SUM(unit_sold_millons) as sum,
		RANK() OVER(PARTITION by manufacturer order by SUM(unit_sold_millons) ASC) rnk
from best_selling_phones bsp2 
group by manufacturer, model)
where rnk <=3;