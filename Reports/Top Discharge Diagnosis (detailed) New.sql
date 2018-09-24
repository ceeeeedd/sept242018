--TOP 50 DISCHARGE DIAGNOSIS REPORT W/ TOTAL AMOUNT PER PATIENT w/ total amount/icd diagnosis

select distinct f.hn,
       d.display_name_e,
       cast(a.discharge_date_time as date) as [Discharge Date],
	   format(a.discharge_date_time,'hh:mm tt') as [Discharge Time],
       e.code,
       e.description,
	   --a.patient_visit_id,
	   --h.name_l as itemname,
	   --g.amount,
          (select count(p.patient_id) 
        from patient_discharge_nl_view as pdv inner join patient_visit_diagnosis_view as pv on pv.patient_visit_id = pdv.patient_visit_id
                                              inner join patient as p on p.patient_id = pv.patient_id
                                              inner join person_formatted_name_iview as pfn on pfn.person_id = p.patient_id
                                              inner join coding_system_element_description as cse on cse.code = pv.code
                     where --month(pdv.discharge_date_time) between @From and  @To and
                                  --year(pdv.discharge_date_time) = @year and
								  month(pdv.discharge_date_time) = 7 and
                                  year(pdv.discharge_date_time) = 2018 and
                                  pv.diagnosis_type_rcd = 'dis' and
                                  pv.coding_type_rcd = 'pri' and
								  pv.code not in ('z38.0') and
                                  pv.code = b.code) as mycount,
			(select sum(cd.amount) -- - (ard.gross_amount)
        from patient_discharge_nl_view as pdv inner join patient_visit_diagnosis_view as pv on pv.patient_visit_id = pdv.patient_visit_id
                                              inner join patient as p on p.patient_id = pv.patient_id
                                              inner join person_formatted_name_iview as pfn on pfn.person_id = p.patient_id
                                              inner join coding_system_element_description as cse on cse.code = pv.code
											  inner join charge_detail as cd on pv.patient_visit_id = cd.patient_visit_id
											  --inner join ar_invoice_detail as ard on cd.charge_detail_id = ard.charge_detail_id
											  --inner join item as i on ard.item_id = i.item_id
											  --inner join sub_item_type_ref as sit on i.sub_item_type_rcd = sit.sub_item_type_rcd
                     where --month(pdv.discharge_date_time) between @From and  @To and
                                  --year(pdv.discharge_date_time) = @year and
								  month(pdv.discharge_date_time) = 7 and
                                  year(pdv.discharge_date_time) = 2018 and
                                  pv.diagnosis_type_rcd = 'dis' and
                                  pv.coding_type_rcd = 'pri' and
								  pv.code not in ('z38.0') and
                                  pv.code = b.code and
								  cd.patient_visit_id = b.patient_visit_id and
								  cd.deleted_date_time is null
								  --sit.sub_item_type_rcd = 'drfee'
								  --rip.swe_payment_status_rcd <> 'unp'
								  --group by ard.gross_amount
								  ) as total_amount,
			(select  sum(cd.amount)
        from patient_discharge_nl_view as pdv inner join patient_visit_diagnosis_view as pv on pv.patient_visit_id = pdv.patient_visit_id
                                              inner join patient as p on p.patient_id = pv.patient_id
                                              inner join person_formatted_name_iview as pfn on pfn.person_id = p.patient_id
                                              inner join coding_system_element_description as cse on cse.code = pv.code
											  inner join charge_detail as cd on pv.patient_visit_id = cd.patient_visit_id
											  --inner join ar_invoice_detail as ard on cd.charge_detail_id = ard.charge_detail_id
											  inner join item as i on cd.item_id = i.item_id
											  --inner join sub_item_type_ref as sit on i.sub_item_type_rcd = sit.sub_item_type_rcd
                     where --month(pdv.discharge_date_time) between @From and  @To and
                                  --year(pdv.discharge_date_time) = @year and
								  month(pdv.discharge_date_time) = 7 and
                                  year(pdv.discharge_date_time) = 2018 and
                                  pv.diagnosis_type_rcd = 'dis' and
                                  pv.coding_type_rcd = 'pri' and
								  pv.code not in ('z38.0') and
                                  pv.code = b.code and
								  cd.patient_visit_id = b.patient_visit_id and
								  i.sub_item_type_rcd = 'drfee' and
								  cd.deleted_date_time is null
								  --rip.swe_payment_status_rcd <> 'unp'
								  ) as fee_amount
from patient_discharge_nl_view as a inner join patient_visit_diagnosis_view as b on a.patient_visit_id = b.patient_visit_id
                                    inner join patient as c on c.patient_id = b.patient_id
                                    inner join person_formatted_name_iview as d on d.person_id = c.patient_id
                                    inner join coding_system_element_description as e on e.code = b.code
									inner join HISReport.dbo.rpt_invoice_pf as f on f.patient_id = b.patient_id
									--inner join charge_detail as g on b.patient_visit_id = g.patient_visit_id
									--inner join item as h on g.item_id = h.item_id
									--inner join charge_detail as g on a.patient_visit_id = g.patient_visit_id

where --month(a.discharge_date_time) between @From and  @To and
      --year(a.discharge_date_time) = @year and
		month(a.discharge_date_time) = 7 and
         year(a.discharge_date_time) = 2018 and
      b.diagnosis_type_rcd = 'dis' and
      b.coding_type_rcd = 'pri' and
	  b.code not in ('z38.0')
	  --g.deleted_date_time is null 
	  --h.sub_item_type_rcd <> 'drfee'
order by mycount desc