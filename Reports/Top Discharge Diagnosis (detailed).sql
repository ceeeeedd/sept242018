select distinct f.hn,
       d.display_name_e,
       cast(a.discharge_date_time as date) as [Discharge Date],
	   format(a.discharge_date_time,'hh:mm tt') as [Discharge Time],
       e.code,
       e.description,
          (select count(p.patient_id) 
        from patient_discharge_nl_view as pdv inner join patient_visit_diagnosis_view as pv on pv.patient_visit_id = pdv.patient_visit_id
                                                                             inner join patient as p on p.patient_id = pv.patient_id
                                              inner join person_formatted_name_iview as pfn on pfn.person_id = p.patient_id
                                              inner join coding_system_element_description as cse on cse.code = pv.code
                     where month(pdv.discharge_date_time) between @From and  @To and
                                  year(pdv.discharge_date_time) = @year and
                                  pv.diagnosis_type_rcd = 'dis' and
                                  pv.coding_type_rcd = 'pri' and
								  pv.code not in ('z38.0') and
                                  pv.code = b.code) as mycount
from patient_discharge_nl_view as a inner join patient_visit_diagnosis_view as b on a.patient_visit_id = b.patient_visit_id
                                                              inner join patient as c on c.patient_id = b.patient_id
                                    inner join person_formatted_name_iview as d on d.person_id = c.patient_id
                                    inner join coding_system_element_description as e on e.code = b.code
									inner join HISReport.dbo.rpt_invoice_pf as f on f.patient_id = b.patient_id
where month(a.discharge_date_time) between @From and  @To and
         year(a.discharge_date_time) = @year and
      b.diagnosis_type_rcd = 'dis' and
      b.coding_type_rcd = 'pri' and
	  b.code not in ('z38.0')
order by mycount desc