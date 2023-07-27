-- we explore a sales dataset and generate various analytics and insights from customers' past purchase behavior.
---We go from analyzing sales revenue to creating a customer segmentation analysis using the RFM technique.

---Inspecting Data---
select * from [dbo].[sales_data_sample]

--Checking Unique Values--
select distinct status from [dbo].[sales_data_sample]
select distinct YEAR_ID from [dbo].[sales_data_sample]
select distinct PRODUCTLINE from [dbo].[sales_data_sample]
select distinct COUNTRY from [dbo].[sales_data_sample]
select distinct DEALSIZE from [dbo].[sales_data_sample]
select distinct TERRITORY from [dbo].[sales_data_sample]

select distinct CUSTOMERNAME from [dbo].[sales_data_sample]


select distinct MONTH_ID from [dbo].[sales_data_sample]
where YEAR_ID=2004

--ANALYSIS 
--Grouping sales by PRODUCTLINE
select PRODUCTLINE, sum(sales) Revenue
from [Sales Project].dbo.sales_data_sample
group by PRODUCTLINE
order by 2 desc

--Gouping sales by YEAR-ID
select YEAR_ID, sum(sales) Revenue
from [Sales Project].dbo.sales_data_sample
group by YEAR_ID
order by 2 desc

--Gouping sales by DEAL SIZE
select DEAlSIZE, sum(sales) Revenue
from [Sales Project].dbo.sales_data_sample
group by DEALSIZE
order by 2 desc

--What was the best month for sales in a specific year? How much was earned??
select MONTH_ID, sum(sales) Revenue, COUNT(ORDERNUMBER) Frequency
from [Sales Project].dbo.[sales_data_sample]
where YEAR_ID=2003
group by MONTH_ID
order by 2 desc

select MONTH_ID, sum(sales) Revenue, COUNT(ORDERNUMBER) Frequency
from [Sales Project].dbo.[sales_data_sample]
where YEAR_ID=2004
group by MONTH_ID
order by 2 desc

--November was the best month. What product sold November most
select MONTH_ID,PRODUCTLINE, sum(sales) Revenue, COUNT(ORDERNUMBER) Frequency
from [Sales Project].dbo.[sales_data_sample]
where YEAR_ID=2003 and MONTH_ID=11
group by MONTH_ID,PRODUCTLINE
order by 3 desc

--who is our best customer(this could be done in RFM)
--RFM means Recency-Frequency-Monetary
DROP TABLE IF EXISTS #rfm;
with rfm as(
	select  CUSTOMERNAME,
			sum(sales) MonetaryValue,
			avg(sales) AvgMonetaryValue,
			COUNT(ORDERNUMBER) Frequency,
			max(ORDERDATE) Last_order_date,
			(select max(ORDERDATE) from [dbo].[sales_data_sample]) max_date,
			DATEDIFF(DD,max(ORDERDATE),(select max(ORDERDATE) from [dbo].[sales_data_sample])) Recency

	from [dbo].[sales_data_sample]
	group by CUSTOMERNAME
),
rfm_calc as
(
	select * ,
		NTILE(4) OVER (order by Recency desc) rfm_Recency,
		NTILE(4) OVER (order by Frequency) rfm_Frequency,
		NTILE(4) OVER (order by MonetaryValue) rfm_Monetary

	from rfm 
)
select *,
	(rfm_Recency+rfm_Frequency+rfm_Monetary) rfm_cell,
	cast(rfm_Recency as varchar)+cast(rfm_Frequency as varchar)+cast(rfm_Monetary as varchar) rfm_cell_string
	into #rfm
from rfm_calc

select * ,
      case 
	     when rfm_cell>=9 then 'High Value Customers'
	     when rfm_cell>=5 and rfm_cell<9 then 'Good Customers'
	     when rfm_cell <5 then 'Lost Customers'

	  end rfm_segment
from #rfm 
order by rfm_cell desc

--what products are most often sold together?

select distinct OrderNumber, stuff(

	(select ',' + PRODUCTLINE
	from [dbo].[sales_data_sample] p
	where ORDERNUMBER in 
		(

			select ORDERNUMBER
			from (
				select ORDERNUMBER, count(*) rn
				FROM [Sales Project].[dbo].[sales_data_sample]
				where STATUS = 'Shipped'
				group by ORDERNUMBER
			)m
			where rn = 4
		)
		and p.ORDERNUMBER = s.ORDERNUMBER
		for xml path (''))

		, 1, 1, '') ProductCodes

from [dbo].[sales_data_sample] s
order by 2 desc

---EXTRAs----
--which country has the highest sales
select COUNTRY, sum(sales) Revenue
from [dbo].[sales_data_sample]
group by COUNTRY
order by 2 desc

--What city has the highest number of sales in a specific country

select CITY, sum(sales) Revenue
from [dbo].[sales_data_sample]
where COUNTRY= 'USA'
group by CITY
order by 2 desc

---What is the best product in United States?

select PRODUCTLINE, sum(sales) Revenue
from [dbo].[sales_data_sample]
where COUNTRY= 'Ireland'
group by PRODUCTLINE 
order by 2 desc

