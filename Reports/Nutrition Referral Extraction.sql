--nutrition referral
select distinct a.creation_date_time,
	   --format(a.creation_date_time,'hh:mm tt') as [Time],
	   pv.actual_visit_date_time as [Admission Date (Start)],
	   pv.closure_date_time as [Admission Date (End)],
	   DATEDIFF (dd, pv.actual_visit_date_time,pv.closure_date_time) as length_of_stay,
	   a.hn,
	   a.patient_name,
	   a.current_bed,
	   a.ward,
	   a.date_of_birth,
	   a.age,
	   a.sex_rcd,
	   a.patient_height,
	   a.patient_weight,
	   a.bmi,
	   pir.name_l as [Indicator],
	   b.modified_by,
	   b.comment,
	   b.lu_updated,
	   format(b.lu_updated,'hh:mm tt') as [Mtime],
	   case when  b.active_flag =1 then 'Active' else 'Inactive' end as Status,
	   case when a.age <= 19 then 'Pedia' 
			 when a.age >= 61 then 'Geriatric' else 'Adult' end as [Age Group]
	  -- case when a.bmi <= 18.5 then 'Underweight'
			--when a.bmi <= 24.9 then 'Normal'
			--when a.bmi <= 29.9 then 'Overweight'
			--when a.bmi >= 30 then 'Obese' else 'Normal' end as [Classification]

from cnl.nutrition_referral a
inner join cnl.person_indicator b on a.person_id = b.person_id
inner join AmalgaPROD.dbo.patient_visit pv on a.patient_visit_id = pv.patient_visit_id
inner join AmalgaPROD.dbo.person_indicator pin on b.person_id = pin.person_id
inner join AmalgaPROD.dbo.person_indicator_ref pir on pin.person_indicator_rcd = pir.person_indicator_rcd
inner join AmalgaPROD.dbo.user_account c on pin.lu_user_id = c.user_id
where year(b.lu_updated) = 2018 and
	  month(b.lu_updated) = 9 and 
--b.person_indicator_id in (select aa.person_indicator_id  from cnl.person_indicator aa
--								where aa.person_indicator_rcd = 'E854F'
--								and aa.person_id = b.person_id
--								and year(aa.lu_updated) = @year
--								and month(aa.lu_updated) = @month
								--and cast(convert(varchar(10),aa.lu_updated,101) as smalldatetime) >= cast(convert(varchar(10),'07/01/2018',101) as smalldatetime)
								--and cast(convert(varchar(10),aa.lu_updated,101) as smalldatetime) <= cast(convert(varchar(10),'08/31/2018',101) as smalldatetime)
								--)
	 pir.person_indicator_rcd = 'E854F'
	and a.current_bed is not null
								order by b.lu_updated desc