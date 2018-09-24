--List of special patients

select d.visible_patient_id as [HN],
	   b.display_name_l as [Patient Name],
	   c.name_l as [Indicator],
	   a.person_indicator_rcd as [Indicator Code],
	   case when b.sex_rcd = 'M' then 'Male' else 'Female' end as [Gender]
from person_indicator_nl_view a
left join person_formatted_name_iview_nl_view b on a.person_id = b.person_id
left join person_indicator_ref_nl_view c on a.person_indicator_rcd = c.person_indicator_rcd
left join patient_hospital_usage_nl_view d on d.patient_id = a.person_id
where a.person_indicator_rcd = 'SPCPX'
and a.active_flag = 1
order by b.display_name_l