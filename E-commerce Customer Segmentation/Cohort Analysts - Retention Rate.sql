-- In this project, I will use RFM segmentation method from https://www.putler.com/rfm-analysis/
-- which score R, F, M from 1-5


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
       and x.InvoiceDate >= y.InvoiceDate
       and -x.Quantity   <= y.Quantity
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

----2. Calculte Recency, Frequency, Monetary:
, R_F_ as (
  select
    *
    , percent_rank() over(order by Frequency) as freq_percent_rank
  from
    (select
      CustomerID
      , date_diff((select (max(InvoiceDate) + interval 1 day) from cleaned_data),
                max(InvoiceDate), DAY) as Recency
      , count(distinct InvoiceNo) as Frequency

    from cleaned_data
    where Quantity > 0
    group by 1)
)

, M_ as (
  select
    CustomerID,
    round(sum(Quantity*UnitPrice), 2) as Monetary
  from cleaned_data
  group by 1
)

, RFM_ntile as (
  select
    R_F_.CustomerID
    , Recency
    , Frequency
    , Monetary
    , ntile(5) over(order by Recency desc) as r_score
    -- freq = 1 is 34.4% of the dataset, so using ntile can lead to wrong segmentation
    , case
        when freq_percent_rank between 0.9 and 1 then 5
        when freq_percent_rank between 0.8 and 0.9 then 4
        when freq_percent_rank between 0.7 and 0.8 then 3
        when freq_percent_rank between 0.6 and 0.7 then 2
        when freq_percent_rank between 0 and 0.6 then 1
      end as f_score

    , ntile(5) over(order by Monetary) as m_score
  from R_F_ join M_ using(CustomerID)
)

, RFM_segment as (
    select
      *
      , concat(r_score, f_score, m_score) as RFM_score
      , case
          when (r_score between 4 and 5) and ((f_score+m_score)/2 between 4 and 5) then 'Champions'
          when (r_score between 2 and 5) and ((f_score+m_score)/2 between 3 and 5) then 'Loyal Customers'
          when (r_score between 3 and 5) and ((f_score+m_score)/2 between 1 and 3) then 'Potential Loyalist'
          when (r_score between 4 and 5) and ((f_score+m_score)/2 between 0 and 1) then 'Recent Customers'
          when (r_score between 3 and 4) and ((f_score+m_score)/2 between 0 and 1) then 'Promising'
          when (r_score between 2 and 3) and ((f_score+m_score)/2 between 2 and 3) then 'Customers Needing Attention'
          when (r_score between 2 and 3) and ((f_score+m_score)/2 between 0 and 2) then 'About To Sleep'
          when (r_score between 0 and 2) and ((f_score+m_score)/2 between 2 and 5) then 'At Risk'
          when (r_score between 0 and 1) and ((f_score+m_score)/2 between 4 and 5) then 'Can’t Lose Them'
          when (r_score between 1 and 2) and ((f_score+m_score)/2 between 1 and 2) then 'Hibernating'
          when (r_score between 0 and 2) and ((f_score+m_score)/2 between 0 and 2) then 'Lost'
          else 'No group'
        end as segment

      , case
          when (r_score between 4 and 5) and ((f_score+m_score)/2 between 4 and 5) then 11
          when (r_score between 2 and 5) and ((f_score+m_score)/2 between 3 and 5) then 10
          when (r_score between 3 and 5) and ((f_score+m_score)/2 between 1 and 3) then 9
          when (r_score between 4 and 5) and ((f_score+m_score)/2 between 0 and 1) then 8
          when (r_score between 3 and 4) and ((f_score+m_score)/2 between 0 and 1) then 7
          when (r_score between 2 and 3) and ((f_score+m_score)/2 between 2 and 3) then 6
          when (r_score between 2 and 3) and ((f_score+m_score)/2 between 0 and 2) then 5
          when (r_score between 0 and 2) and ((f_score+m_score)/2 between 2 and 5) then 4
          when (r_score between 0 and 1) and ((f_score+m_score)/2 between 4 and 5) then 3
          when (r_score between 1 and 2) and ((f_score+m_score)/2 between 1 and 2) then 2
          when (r_score between 0 and 2) and ((f_score+m_score)/2 between 0 and 2) then 1
          else 0
        end as important
    from RFM_ntile
)

---- 3. RFM Profile
-- select segment, count(segment) from RFM_segment group by segment;

-- select * from RFM_segment

select
  segment
  , min(Recency) as min_Recency
  , avg(Recency) as avg_Recency
  , max(Recency) as max_Recency

  , min(Frequency) as min_Frequency
  , avg(Frequency) as avg_Frequency
  , max(Frequency) as max_Frequency

  , min(Monetary) as min_Monetary
  , avg(Monetary) as avg_Monetary
  , max(Monetary) as max_Monetary
from RFM_segment
group by segment
order by max(important) desc;





