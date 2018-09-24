--Employee with Multiple HN

select temp.primary_related_patient_confirmation_status_rcd,
	   temp.Employee,
	   temp.employee_nr as [Employee NR],
	   --temp.patient_id,
	   --temp.employee_id,
	   --temp.primary_related_patient_id,
	   temp.HN,
	   temp.display_name_l as [Name],
	   --temp.[Employee Name],
	   temp.Birthdate,
	   temp.namecount  
from
(
select case when c.employee_nr = c.employee_nr then 'Yes' else 'No' end as [Employee],
	   d.primary_related_patient_confirmation_status_rcd,
	   a.visible_patient_id as [HN],
	   c.employee_nr,
	   a.patient_id,
	   e.primary_related_patient_id,
	  -- isnull(e.primary_related_patient_id, c.employee_id) as primary_related_patient_id,
	   c.employee_id,
	   b.display_name_l,
	   --e.display_name_l as [Employee Name],
	   b.date_of_birth as [Birthdate],
	   (select count(aa.patient_id) from patient_hospital_usage_nl_view aa inner join person_formatted_name_iview_nl_view bb on aa.patient_id = bb.person_id
									  left join employee cc on bb.person_id = cc.employee_id
									  where b.display_name_l = bb.display_name_l
									  ) as namecount

from patient_hospital_usage_nl_view a inner join person_formatted_name_iview_nl_view b on a.patient_id = b.person_id
									  inner join patient d on a.patient_id = d.patient_id
									  left join employee c on b.person_id = c.employee_id
									  left join patient_info_view e on d.patient_id = e.person_id
									  --left join person_formatted_name_iview e on c.employee_id = e.person_id
		where --b.display_name_l = 'Calora, Rowela Genesis' and
		--order by b.display_name_l
		 c.termination_date is null and
		d.primary_related_patient_confirmation_status_rcd is not null
) as temp
where temp.namecount >= 2
--temp.employee_id in (select employee_id from employee where termination_date is null)
--and temp.primary_related_patient_id is not null
--temp.employee_nr is not null
and temp.Employee = 'Yes'
--and temp.display_name_l = 'Calora, Rowela Genesis'
order by temp.display_name_l
