# COVID-19 Data Mining Demo

## Prepare

- Download [Coronavirus dataset](https://www.kaggle.com/kimjihoo/coronavirusdataset)
- Install Microsoft SQL Server Management Studio, or JetBrains Data Grip and connect to DB server
- Upload dataset to DB server
   - programmatically: python, java, c#, etc.
   - or manually.


## View data import results
```
SELECT TOP (1000) * FROM [dbo].[time]
SELECT TOP (1000) * FROM [dbo].[route]
SELECT TOP (1000) * FROM [dbo].[patient]
```

## Discovery your data

```
select distinct state
from patient

select min(confirmed_date) as min_date, max(confirmed_date) as max_date
from patient

select (2020 - min(birth_year)) as max_age, (2020 - max(birth_year)) as max_date
from patient
where deceased_date is not null
```

## 5. Calculate statistics

```
select confirmed_date, count(*) n
from patient
group by confirmed_date
order by confirmed_date desc

select infection_reason, count(*) n
from patient
where confirmed_date > '2020-02-18'
group by infection_reason
order by n desc

select infected_by, count(*) N
from patient
group by infected_by
having count(*) > 1
order by n desc
```

## Enrich data

```
with infected_stats as (
	select infected_by, count(*) n
	from patient
	group by infected_by
	having count(*) > 1
)
select p.id, p.infected_by, n, r.*
from patient as p
	inner join infected_stats as inf on p.infected_by = inf.infected_by
	left join route as r on p.id = r.id
order by n desc, p.infected_by
```

## Create data mart

```
create view dbo.patient_stats_vw
as
select sex, (2020 - birth_year) as age, infection_reason, country, region, state, count(*) n_people
from patient
where sex is not null and birth_year is not null
group by sex, birth_year, infection_reason, country, region, state
```

