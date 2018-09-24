--Nutrtion Referral Dumping AmalgaPROD

SELECT temp.creation_date_time,
	   temp.closure_date_time,
	   temp.patient_name,
	   temp.hn,
	   temp.current_bed,
	   temp.ward,
	   temp.date_of_birth,
	   temp.sex_rcd,
	   temp.age,
	   temp.expected_discharge_date_time,
	   

	temp.patient_height,
	temp.patient_weight,
	temp.patient_visit_id,
	temp.patient_id,
	
	   case when (temp.patient_height > 0 and temp.patient_weight > 0) then cast(ROUND(temp.patient_weight / ((temp.patient_height / 100) * (temp.patient_height / 100)),2) as NUMERIC(12,2)) else 0 END as bmi,
	   'With Visit' as category
from
(
	SELECT DISTINCT pv.patient_id,
		   pv.creation_date_time,
		   patient_name = pfn.display_name_l,
		   phu.visible_patient_id as hn,
		   pv.patient_visit_id,
		   current_bed = (select bed_code 
							  from ph_room_bed_patient_assign_info_view 
							  where patient_visit_id = PV.patient_visit_id),
							  
		   ward = (SELECT temp.ward_name_l
					from
					(
						select distinct rbp.patient_visit_id,
							   biv.ward_name_l
						from ph_room_bed_patient_assign_info_view rbp inner join ward w on rbp.ward_id = w.ward_id
																	  inner join bed_info_view biv on w.ward_id = biv.ward_id
						where patient_visit_id = pv.patient_visit_id
					) as temp),
		   pfn.date_of_birth,
		   pfn.sex_rcd,
		   age = DATEDIFF(dd,pfn.date_of_birth,GETDATE()) / 365,
		   pv.expected_discharge_date_time, 
		  
		  ISNULL((SELECT TOP 1 pcod.numeric_value as patient_height
				  from patient_clinical_observation pco inner join patient_clinical_observation_detail pcod on pco.patient_clinical_observation_id = pcod.patient_clinical_observation_id
				  where patient_id = pv.patient_id
					   and clinical_observation_item_rid = '7FE3127B-9CF1-40A5-8E2C-7F6CF09062FD'
				  order by pcod.lu_updated DESC),0) as patient_height,
		   ISNULL((SELECT TOP 1 pcod.numeric_value as patient_weight
					from patient_clinical_observation pco inner join patient_clinical_observation_detail pcod on pco.patient_clinical_observation_id = pcod.patient_clinical_observation_id
					where patient_id = pv.patient_id
						 and clinical_observation_item_rid = '241526D4-FF6B-4FD0-9BBD-A41C3F312E75'
					order by pcod.lu_updated DESC),0) as patient_weight,
	   pv.closure_date_time
	from patient_visit pv inner join person_formatted_name_iview pfn on pv.patient_id = pfn.person_id
						  inner join patient_hospital_usage phu on pfn.person_id = phu.patient_id
	where --pv.visit_type_rcd = 'V1'
	 pv.creation_date_time <= getdate()
	and pv.closure_date_time is null
) as temp
order by patient_name




/*
--closed visit stage dumping

DECLARE @datenow datetime
DECLARE @dateago datetime
set @datenow = GETDATE()
set @dateago =   DATEADD(day, -30,@datenow)

select patient_visit_id,
	   closure_date_time 
from patient_visit
where closure_date_time between @dateago and @datenow

--person indicator id dumping

DECLARE @datenow datetime
DECLARE @dateago datetime
set @datenow = GETDATE()
set @dateago =   DATEADD(day, -30,@datenow)

select a.*,c.display_name_l 
from person_indicator a
inner join user_account as b on a.lu_user_id = b.user_id
inner join person_formatted_name_iview_nl_view as c on b.person_id = c.person_id
where a.person_indicator_rcd = 'E854F' and
a.lu_updated between @dateago and @datenow
*/
/*
select * from cnl.person_indicator

select * from cnl.nutrition_referral

delete from cnl.nutritional_referral
delete from cnl.person_indicator


select * from cnl.nutrition_referral as a
inner join cnl.closed_visit_stage as b on b.patient_visit_id = a.patient_visit_id

--update closed visit date script

update cnl.nutrition_referral
set closure_date_time = b.closure_date_time
from cnl.nutrition_referral as a
inner join cnl.closed_visit_stage as b on b.patient_visit_id = a.patient_visit_id

--delete closed vist date script
delete from from cnl.closed_visit_stage

*/
