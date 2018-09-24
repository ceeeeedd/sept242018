select top 50 temp.code,
			  temp.description,

		   (select count(p.patient_id) 
			from patient_discharge_nl_view as pdv inner join patient_visit_diagnosis_view as pv on pv.patient_visit_id = pdv.patient_visit_id
			 									  inner join patient as p on p.patient_id = pv.patient_id
												  inner join person_formatted_name_iview as pfn on pfn.person_id = p.patient_id
												  inner join coding_system_element_description as cse on cse.code = pv.code
			where month(pdv.discharge_date_time) = between @From and @To and
					year(pdv.discharge_date_time) = (@year -1) and
					pv.diagnosis_type_rcd = 'dis' and
					pv.coding_type_rcd = 'pri' and
					pv.code not in ('z38.0') and
					pv.code = temp.code) as [Previous Year],

            temp.[Selected Year]
from
(
	select code,
		   [description],
		   main_pv.coding_system_rcd,

		   (select count(p.patient_id) 
			from patient_discharge_nl_view as pdv inner join patient_visit_diagnosis_view as pv on pv.patient_visit_id = pdv.patient_visit_id
			 									  inner join patient as p on p.patient_id = pv.patient_id
												  inner join person_formatted_name_iview as pfn on pfn.person_id = p.patient_id
												  inner join coding_system_element_description as cse on cse.code = pv.code
			where month(pdv.discharge_date_time) = between @From and @To and
					year(pdv.discharge_date_time) = @year and
					pv.diagnosis_type_rcd = 'dis' and
					pv.coding_type_rcd = 'pri' and
					pv.code not in ('z38.0') and
					pv.code = main_pv.code) as [Selected Year]
					
	from coding_system_element_description as main_pv
	where coding_system_rcd = 'ICD10'
	
) as temp
order by temp.[Selected Year] DESC