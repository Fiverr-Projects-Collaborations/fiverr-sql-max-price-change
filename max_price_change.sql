create table t1 (
date_d varchar(50),
commodity varchar(50),
price numeric
)
/

create table t2(
commodity varchar(50),
period numeric
);

insert into t1 values('2005-01-01', 'Petrol', 100);
insert into t1 values('2005-01-01', 'Kerosine', 200);
insert into t1 values('2005-01-02', 'Petrol', 150);
insert into t1 values('2005-01-02', 'Kerosine', 250);
insert into t1 values('2005-01-03', 'Kerosine', 300);
insert into t1 values('2005-01-04', 'Kerosine', 400);
insert into t2 values('Petrol',1);
insert into t2 values('Kerosine',2);

with y as (
    SELECT
        ROW_NUMBER() OVER(Partition by commodity ORDER BY commodity, date_d desc) as rn,
        t.commodity AS commodity,
        t.date_d,
        t.price
    FROM t1 t
),
z as (
    select
        y.* ,
        y1.price as price1,
        y1.date_d as date1
    from y
    join t2
        on y.commodity = t2.commodity
    join y y1
        on y1.commodity = y.commodity
        and y.rn = y1.rn - t2.period
),
a as (
    select
        y.commodity,
        y.date_d,
        y.price,
        (y.price-z.price1)*100/z.price1 as perc_change
    from y
    left outer join z
        on y.rn = z.rn
        and y.commodity = z.commodity
),
b as (
    select
        max(perc_change) as pchange,
        commodity
    from a
    group by commodity
)
select
    a.*
from a
join b
    on a.commodity = b.commodity
    and a.perc_change = b.pchange
;
