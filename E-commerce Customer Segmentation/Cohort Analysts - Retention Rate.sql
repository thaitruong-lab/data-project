
----1. Clean data:
-- exclude null customerID and remove dupplicated. After perfome this action, null values of other field will be excluded too.
with not_null_cusID as (
  select
    distinct InvoiceNo, StockCode, Quantity, InvoiceDate, UnitPrice, CustomerID
    ,row_number() over() as row_num --add row_num to indicate index
  from `angular-argon-305607.test.e_commerce`
  where CustomerID is not null
)

-- Remove order entries that was canceled
-- in this dataset, cancellation transations has the invoiceNo start with a 'C' and a negative stock quantity
-- we will match the cancellation with its beforehand transaction using CustomerID, StockCode, Quantity, Unit Price

--Find cancellation transactions
, canceled_trans as (
  select *
  from not_null_cusID
  where left(InvoiceNo, 1) = 'C'
)

--Find initial records that correspond with cancellation transactions;
--These cancellation transactions with negative quantity, we keep it.
--When calculate total, use sum fuction and canceled amount will be subtracted
, counter_of_cancel as (
  select
    x.row_num
  from canceled_trans x join not_null_cusID y
       on  x.CustomerID   = y.CustomerID
       and x.StockCode    = y.StockCode
       and x.UnitPrice    = y.UnitPrice
       and x.InvoiceDate  > y.InvoiceDate
       and y.Quantity     > 0
  group by x.row_num
)

--cancellation transations that not relevent to current data need to be excluded
, exclude_trans as (
  select row_num from canceled_trans c1
  where not exists (select row_num from counter_of_cancel c2
                    where c1.row_num = c2.row_num)
)
, cleaned_data as (
  select * from not_null_cusID n
  where not exists (select row_num from exclude_trans e
                    where n.row_num = e.row_num)
)
-- 2. Calcualte Retention

, user_first_month as (
  select
    CustomerID
    , concat(extract(MONTH from min(InvoiceDate)),'-',extract(YEAR from min(InvoiceDate))) as first_month
    , row_number() over(order by min(InvoiceDate)) as row_num
  from cleaned_data
  group by CustomerID
)

, month_year_order as(
  select
    first_month
    , first_month as retention_month
    , min(row_num) as row_num
  from user_first_month
  group by 1, 2
)
, user_retention_month as (
  select
    CustomerID
    , concat(extract(MONTH from InvoiceDate),'-',extract(YEAR from InvoiceDate)) as retention_month
  from cleaned_data
  group by 1, 2
)

, retention_by_month as (
  select
    f.first_month
    , r.retention_month
    , count(f.CustomerID) as retained_users
  from user_first_month f right join user_retention_month r using(CustomerID)
  group by 1, 2
)

, new_user_by_month as (
  select
    first_month
    , count(CustomerID) as new_users
  from user_first_month
  group by 1
)

-- retention_rate
select
  r.first_month
  , concat(
    'M'
    ,date_diff(
      date(parse_date('%m-%Y', r.retention_month)),
      date(parse_date('%m-%Y', r.first_month)), MONTH)
    ) as retention_month_no
  , u.new_users
  , r.retained_users
  , round(r.retained_users/u.new_users, 2) as retention_rate
from
  retention_by_month r join new_user_by_month u
  using(first_month)

  join month_year_order o1 on r.first_month = o1.first_month
  join month_year_order o2 on r.retention_month = o2.retention_month
where r.retention_month <> '12-2011'
order by o1.row_num, o2.row_num

-- We can see at the result, retention_month 12-2011 of every first_month has a very low retention_rate
-- It is because our data end at 9-12-2011, so we do not have data of full month
-- In further analysis, we should exclude 12-2011 from retention rate
