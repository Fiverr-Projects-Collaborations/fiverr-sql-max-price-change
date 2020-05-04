create table t1 (
date_d varchar(20),
commodity varchar(50),
price double
);

create table t2(
commodity varchar(50),
period integer
);

insert into t1 values('2005-01-01', 'Petrol', 100);
insert into t1 values('2005-01-01', 'Kerosine', 200);
insert into t1 values('2005-01-02', 'Petrol', 150);
insert into t1 values('2005-01-02', 'Kerosine', 250);
insert into t1 values('2005-01-03', 'Kerosine', 300);
insert into t1 values('2005-01-04', 'Kerosine', 400);
insert into t2 values('Petrol',2);
insert into t2 values('Kerosine',3);

with x as(
select t1.date_d,t1.commodity,t1.price from t1
join t2 on t1.commodity = t2.commodity
join (
SELECT
@row_no := IF(@prev_val = t.commodity, @row_no + 1, 1) as rn,
@prev_val := t.commodity AS commodity,
t.date_d,
t.price
FROM t1 t,
  (SELECT @row_no := 0) x,
  (SELECT @prev_val := '') y
ORDER BY t.commodity ASC,t.date_d DESC ) as t3
on t3.commodity = t1.commodity
and t3.date_d=t1.date_d
and t3.rn <= period
),
min_d as (select t1.* from t1 join (select min(date_d) date_d,commodity from x group by commodity) min_t on t1.commodity = min_t.commodity and t1.date_d = min_t.date_d),
max_d as (select t1.* from t1 join (select max(date_d) date_d,commodity from x group by commodity) max_t on t1.commodity = max_t.commodity and t1.date_d = max_t.date_d)
select t1.date_d,t1.commodity,t1.price,(max_d.price-min_d.price)*100/min_d.price as percentage from min_d
join max_d using(commodity)
right outer join t1
on t1.commodity = max_d.commodity
and t1.date_d = max_d.date_d
order by t1.date_d,t1.commodity
;
