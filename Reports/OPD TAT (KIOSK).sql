select temp.queue_number,
	   temp.created_datetime,
	   temp.lu_updated_datetime,
	   temp.status_id,
	   temp.status_name,
		  right('0'+cast(temp.served_hr as varchar),2) + ':' + right('0'+cast(temp.served_min as varchar),2)  as served_time,
		  right('0'+cast(temp.served_hr_recalled as varchar),2) + ':' + right('0'+cast(temp.served_min_recalled as varchar),2) as served_recalled_time,
		  right('0'+cast(temp.missedcall_hr as varchar),2) + ':' + right('0'+cast(temp.missedcall_min as varchar),2) as missedcall_time,
		  right('0'+cast(temp.missedcall_hr1 as varchar),2) + ':' + right('0'+cast(temp.missedcall_min1 as varchar),2) as missedcall_time1,
		  right('0'+cast(temp.recalled_hr as varchar),2) + ':' + right('0'+cast(temp.recalled_min as varchar),2) as recalled_time,
		  right('0'+cast(temp.processed_hr as varchar),2) + ':' + right('0'+cast(temp.processed_min as varchar),2) as processed_time,
		  temp.[Turn Around Time],
		  temp.[Call Time],
		  temp.countq,
		  temp.tat_hr,
		  temp.tat_min,
		  right('0'+cast(temp.tat_hr as varchar),2) + ':' + right('0'+cast(temp.tat_min as varchar),2)  as TAT
from
(
select b.queue_number,
       a.created_datetime,
	   c.lu_updated_datetime,
	   c.status_id,
	   c.status_name,
	   (select count(qss.status_id) from ITWORKSDEV01.QueueingDB.dbo.queue_summary qss where c.queue_id = qss.queue_id) as countq,
	   (select top 1 cast(datediff(minute,qs.lu_updated_datetime,(select top 1 aa.lu_updated_datetime from ITWORKSDEV01.QueueingDB.dbo.queue_summary aa where aa.queue_number = c.queue_number
																									and aa.status_id = 2)) /60 as numeric(4,0)
																									) from ITWORKSDEV01.QueueingDB.dbo.queue_summary qs where qs.queue_number = c.queue_number
																									and qs.status_id = 1) as served_hr ,
	   (select top 1 datediff(ss,qs.lu_updated_datetime,(select top 1 aaa.lu_updated_datetime from ITWORKSDEV01.QueueingDB.dbo.queue_summary aaa where aaa.queue_number = c.queue_number
																									and aaa.status_id = 2)
																									) from ITWORKSDEV01.QueueingDB.dbo.queue_summary qs where qs.queue_number = c.queue_number
																									and qs.status_id = 1)/60 as served_min,
	   
	   (select top 1 cast(datediff(minute,qs.lu_updated_datetime,(select top 1 aa.lu_updated_datetime from ITWORKSDEV01.QueueingDB.dbo.queue_summary aa where aa.queue_number = c.queue_number
																									and aa.status_id = 4)) /60 as numeric(4,0)
																									) from ITWORKSDEV01.QueueingDB.dbo.queue_summary qs where qs.queue_number = c.queue_number
																									and qs.status_id = 2) as served_hr_recalled ,
	   (select top 1 datediff(ss,qs.lu_updated_datetime,(select top 1 aaa.lu_updated_datetime from ITWORKSDEV01.QueueingDB.dbo.queue_summary aaa where aaa.queue_number = c.queue_number
																									and aaa.status_id = 4)
																									) from ITWORKSDEV01.QueueingDB.dbo.queue_summary qs where qs.queue_number = c.queue_number
																									and qs.status_id = 2)/60 as served_min_recalled,

	   (select top 1 cast(datediff(minute,qs.lu_updated_datetime,(select top 1 aa.lu_updated_datetime from ITWORKSDEV01.QueueingDB.dbo.queue_summary aa where aa.queue_number = c.queue_number
																									and aa.status_id = 3)) /60 as numeric(4,0)
																									) from ITWORKSDEV01.QueueingDB.dbo.queue_summary qs where qs.queue_number = c.queue_number
																									and qs.status_id = 1) as missedcall_hr ,
	   (select top 1 datediff(ss,qs.lu_updated_datetime,(select top 1 aaa.lu_updated_datetime from ITWORKSDEV01.QueueingDB.dbo.queue_summary aaa where aaa.queue_number = c.queue_number
																									and aaa.status_id = 3)
																									) from ITWORKSDEV01.QueueingDB.dbo.queue_summary qs where qs.queue_number = c.queue_number
																									and qs.status_id = 1)/60 as missedcall_min,

	   (select top 1 cast(datediff(minute,qs.lu_updated_datetime,(select top 1 aa.lu_updated_datetime from ITWORKSDEV01.QueueingDB.dbo.queue_summary aa where aa.queue_number = c.queue_number
																									and aa.status_id = 5)) /60 as numeric(4,0)
																									) from ITWORKSDEV01.QueueingDB.dbo.queue_summary qs where qs.queue_number = c.queue_number
																									and qs.status_id = 3) as missedcall_hr1,
	   (select top 1 datediff(ss,qs.lu_updated_datetime,(select top 1 aaa.lu_updated_datetime from ITWORKSDEV01.QueueingDB.dbo.queue_summary aaa where aaa.queue_number = c.queue_number
																									and aaa.status_id = 5)
																									) from ITWORKSDEV01.QueueingDB.dbo.queue_summary qs where qs.queue_number = c.queue_number
																									and qs.status_id = 3)/60 as missedcall_min1,

	   (select top 1 cast(datediff(minute,qs.lu_updated_datetime,(select top 1 aa.lu_updated_datetime from ITWORKSDEV01.QueueingDB.dbo.queue_summary aa where aa.queue_number = c.queue_number
																									and aa.status_id = 5)) /60 as numeric(4,0)
																									) from ITWORKSDEV01.QueueingDB.dbo.queue_summary qs where qs.queue_number = c.queue_number
																									and qs.status_id = 3) as recalled_hr ,
	   (select top 1 datediff(ss,qs.lu_updated_datetime,(select top 1 aaa.lu_updated_datetime from ITWORKSDEV01.QueueingDB.dbo.queue_summary aaa where aaa.queue_number = c.queue_number
																									and aaa.status_id = 5)
																									) from ITWORKSDEV01.QueueingDB.dbo.queue_summary qs where qs.queue_number = c.queue_number
																									and qs.status_id = 3)/60 as recalled_min,

	   (select top 1 cast(datediff(minute,qs.lu_updated_datetime,(select top 1 aa.lu_updated_datetime from ITWORKSDEV01.QueueingDB.dbo.queue_summary aa where aa.queue_number = c.queue_number
																									and aa.status_id = 4)) /60 as numeric(4,0)
																									) from ITWORKSDEV01.QueueingDB.dbo.queue_summary qs where qs.queue_number = c.queue_number
																									and qs.status_id = 2) as processed_hr ,
	   (select top 1 datediff(ss,qs.lu_updated_datetime,(select top 1 aaa.lu_updated_datetime from ITWORKSDEV01.QueueingDB.dbo.queue_summary aaa where aaa.queue_number = c.queue_number
																									and aaa.status_id = 4)
																									) from ITWORKSDEV01.QueueingDB.dbo.queue_summary qs where qs.queue_number = c.queue_number
																									and qs.status_id = 2) /60  as processed_min,
	   
	   a.call_queue_tat_hrs + a.process_queue_tat_hrs as [tat_hr],
	   a.call_queue_tat_minutes + a.process_queue_tat_minutes as [tat_min],
	   
	   
	   right('0'+cast(a.call_queue_tat_hrs as varchar),2) + ':' +
	   right('0'+cast(a.call_queue_tat_minutes as varchar),2) as [Call Time],
	   right('0'+cast(a.process_queue_tat_hrs as varchar),2) + ':' +
	   right('0'+cast(a.process_queue_tat_minutes as varchar),2) as [Turn Around Time]
	   from ITWORKSDEV01.QueueingDB.dbo.queue_turn_around_time a left join ITWORKSDEV01.QueueingDB.dbo.queue_numbers b on a.queue_id = b.queue_id
																 left join ITWORKSDEV01.QueueingDB.dbo.queue_summary c on a.queue_id = c.queue_id
	   where 
	   year(a.created_datetime) = 2018
	   and month(a.created_datetime) = 9
	   --and b.queue_number in ('91818-242')
) as temp
order by temp.created_datetime