select * from census.dbo.Data1;

select * from census.dbo.Data2;

--number of rows in our dataset

select count(*) from census..Data1;
select count(*) from census..Data2;

--select dataset for jharkhand and bihar

select * from census..data1 where State in ('Jharkhand','Bihar');

--total population

select sum(Population) from census..Data2;

--avg growth

select avg(Growth)*100 as avg_growth from census..Data1;

--avg growth per state

select State,avg(Growth) as avg_growth from census..data1 group by state;

--avg sex ratio per state in descending order

select State,round(avg(Sex_Ratio),0) as avg_sex_ratio from census..data1 group by state order by avg_sex_ratio desc;

--average literacy ratio

select State,round(avg(literacy),0) as avg_literacy_rate from census..data1
group by state 
having round(avg(literacy),0)>90
order by avg_literacy_rate desc;

--top three states showing highest growth ratio

select State,avg(Growth)*100 as avg_growth from census..data1 group by state order by avg_growth desc limit 3;

--top and bottom 3 states in literacy
drop table if exists topstates
create table topstates(
state nvarchar(255),
avg_literacy float
);

insert into topstates
select State,round(avg(literacy),0) as avg_literacy_ratio from census..data1 group by state order by avg_literacy_ratio desc;

select * from
(select top 3 * from topstates order by avg_literacy desc) a
union
select * from
(select top 3 * from topstates order by avg_literacy asc) b;

--states starting with letter A

select distinct state from census..data1 where lower(state) like 'a%' or lower(state) like 'm%';

--joining both tables

select d.state,sum(d.males) males,sum(d.females) females from 
(select c.district,c.state,round(c.population/(c.sex_ratio+1),0) males,round(c.population*c.sex_ratio/(1+c.sex_ratio),0) females from
(select a.district,a.sex_ratio/1000 as sex_ratio,a.state,b.population from census..data1 a inner join census..data2 b on a.district=b.district) c) d
group by d.state;

-----total literacy rates

select d.state,sum(d.literate) literate,sum(d.illiterate) illiterate from 
(select c.district,c.state,round(c.population*c.literacy,0) literate,round(c.population*(1-c.literacy),0) illiterate from
(select a.district,a.literacy/100 as literacy,a.state,b.population from census..data1 a inner join census..data2 b on a.district=b.district) c) d
group by d.state;

--- previous population

select d.state,sum(d.population) population,sum(d.previous_population) previous_population from
(select c.district,c.state,c.population,round(c.population/(1+c.growth),0) previous_population from
(select a.district,a.growth as growth,a.state,b.population from census..data1 a inner join census..data2 b on a.district=b.district) c) d
group by d.state;


select d.state,sum(d.population) population,sum(d.previous_population) previous_population from
(select c.district,c.state,c.population/area population_density,round(c.population/(1+c.growth),0)/area previous_population_density from
(select a.district,a.growth as growth,a.state,b.population,b.Area_km2 area from census..data1 a inner join census..data2 b on a.district=b.district) c) d
group by d.state;


---top 3 districts from each state in literacy
select a.* from
(select district,state,literacy,rank() over(partition by state order by literacy desc) rnk from census..data1) a
where a.rnk in (1,2,3) order by a.state;