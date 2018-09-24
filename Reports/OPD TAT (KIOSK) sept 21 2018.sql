select *, right('0'+cast(tempb.timediff_hour as varchar),2) + ':' + right('0'+cast(tempb.timediff_min as varchar),2)  as timediff
from
(
select temp.queue_number,
	   temp.created_datetime,
	   temp.lu_updated_datetime,
	   temp.status_id,
	   temp.status_name,
	   temp.[Turn Around Time],
	   temp.[Call Time],
	   temp.countq,
	   temp.rownum,
	   datediff(ss,temp.lu_updated_datetime, test.lu_updated_datetime) /60 * -1  as timediff_min,
	   datediff(minute,temp.lu_updated_datetime, test.lu_updated_datetime) /60 * -1  as timediff_hour,
	   right('0'+cast(temp.tat_hr as varchar),2) + ':' + right('0'+cast(temp.tat_min as varchar),2)  as TAT
from
(
select b.queue_number,
       a.created_datetime,
	   c.lu_updated_datetime,
	   c.status_id,
	   c.status_name,
	   ROW_NUMBER() over(order by b.queue_number) as [rownum],
	   (select count(qss.status_id) from ITWORKSDEV01.QueueingDB.dbo.queue_summary qss where c.queue_id = qss.queue_id) as countq,

	   (select top 1 cast(datediff(minute,qs.created_date_time,(select top 1 aa.lu_updated_datetime from ITWORKSDEV01.QueueingDB.dbo.queue_summary aa where aa.queue_number = c.queue_number
																									and aa.status_id = 4)) /60 as numeric(4,0)
																									) from ITWORKSDEV01.QueueingDB.dbo.queue_summary qs where qs.queue_number = c.queue_number
																									) as tat_hr ,
	   (select top 1 datediff(ss,qs.created_date_time,(select top 1 aaa.lu_updated_datetime from ITWORKSDEV01.QueueingDB.dbo.queue_summary aaa where aaa.queue_number = c.queue_number
																									and aaa.status_id = 4)
																									) from ITWORKSDEV01.QueueingDB.dbo.queue_summary qs where qs.queue_number = c.queue_number
																									) /60  as tat_min,

	   right('0'+cast(a.call_queue_tat_hrs as varchar),2) + ':' +
	   right('0'+cast(a.call_queue_tat_minutes as varchar),2) as [Call Time],
	   right('0'+cast(a.process_queue_tat_hrs as varchar),2) + ':' +
	   right('0'+cast(a.process_queue_tat_minutes as varchar),2) as [Turn Around Time]
	   from ITWORKSDEV01.QueueingDB.dbo.queue_turn_around_time a left join ITWORKSDEV01.QueueingDB.dbo.queue_numbers b on a.queue_id = b.queue_id
																 left join ITWORKSDEV01.QueueingDB.dbo.queue_summary c on a.queue_id = c.queue_id
	   where 
	   --year(a.created_datetime) = @year
	   --and month(a.created_datetime) = @month
	   year(a.created_datetime) = 2018
	   and month(a.created_datetime) = 9
	   --and b.queue_number = '92118-7'
) as temp
left join (select distinct  b1.queue_number,
	   c1.lu_updated_datetime,
	   ROW_NUMBER() over(order by b1.queue_number) as [rownum]

from ITWORKSDEV01.QueueingDB.dbo.queue_turn_around_time a1 inner join ITWORKSDEV01.QueueingDB.dbo.queue_numbers b1 on a1.queue_id = b1.queue_id
														  inner join ITWORKSDEV01.QueueingDB.dbo.queue_summary c1 on a1.queue_id = c1.queue_id
	   where 
	   year(a1.created_datetime) = 2018
	   and month(a1.created_datetime) = 9
	   --year(a1.created_datetime) = @year
	   --and month(a1.created_datetime) = @month
	   ) as test on  temp.rownum  = test.rownum +1
	   )as tempb