--TOP 50 DISCHARGE DIAGNOSIS REPORT Summary SSRS
Declare @year1 int

set @year1 = 2018



select distinct code,
	   description,
	   Diagnosis,
	   mycount,
	   total_amount as total_amount_selectedyear,
	   fee_amount as fee_amount_selectedyear,
	   mycount1,
	   total_amount1 as total_amount_previousyear,
	   fee_amount1 as fee_amount_previousyear
from(
select distinct f.hn,
       d.display_name_e,
       cast(a.discharge_date_time as date) as [Discharge Date],
	   format(a.discharge_date_time,'hh:mm tt') as [Discharge Time],
       e.code,
       e.description,
	  case when e.code like '%c%' and e.coding_system_rcd = 'icd10' then 'Malignant Neoplasm'
			when e.code in ('A90','A91') then 'Dengue Fever'
			when e.code in ('J18.9','J18.0') then 'Pneumonia'
			when e.code in ('O80', 'O80.0', 'O80.1', 'O80.8', 'O80.9', 'O81', 'O81.0', 'O81.1', 'O81.2', 'O81.3', 'O81.4', 'O81.5', 'O82',
'O82.0', 'O82.1', 'O82.2', 'O82.8', 'O82.9', 'O83', 'O83.0', 'O83.1', 'O83.2', 'O83.3', 'O83.4', 'O83.8', 'O83.9',
'O84', 'O84.0', 'O84.1', 'O84.2', 'O84.8', 'O84.9') then 'Pregnancy/Delivery'
				else e.description end as [Diagnosis],
	   --a.patient_visit_id,
	   --h.name_l as itemname,
	   --g.amount,
          (select count(distinct pv.patient_visit_id) 
        from patient_discharge_nl_view as pdv inner join patient_visit_diagnosis_view as pv on pv.patient_visit_id = pdv.patient_visit_id
                                              inner join patient as p on p.patient_id = pv.patient_id
                                              inner join person_formatted_name_iview as pfn on pfn.person_id = p.patient_id
                                              inner join coding_system_element_description as cse on cse.code = pv.code
                     where --month(pdv.discharge_date_time) between @From and  @To and
                                  --year(pdv.discharge_date_time) = @year and
								  month(pdv.discharge_date_time) = 8 and
                                  year(pdv.discharge_date_time) = 2018 and
                                  pv.diagnosis_type_rcd = 'dis' and
                                  pv.coding_type_rcd = 'pri' and
								  pv.code not in ('z38.0') and
                                  pv.code = b.code) as mycount,


			(select count(distinct pv.patient_visit_id) 
        from patient_discharge_nl_view as pdv inner join patient_visit_diagnosis_view as pv on pv.patient_visit_id = pdv.patient_visit_id
                                              inner join patient as p on p.patient_id = pv.patient_id
                                              inner join person_formatted_name_iview as pfn on pfn.person_id = p.patient_id
                                              inner join coding_system_element_description as cse on cse.code = pv.code
                     where --month(pdv.discharge_date_time) between @From and  @To and
                                  --year(pdv.discharge_date_time) = @year and
								  month(pdv.discharge_date_time) = 8 and
                                  year(pdv.discharge_date_time) = 2017 and
                                  pv.diagnosis_type_rcd = 'dis' and
                                  pv.coding_type_rcd = 'pri' and
								  pv.code not in ('z38.0') and
                                  pv.code = b.code) as mycount1,


			(select sum(cd.amount) 
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
								  month(pdv.discharge_date_time) = 8 and
                                  year(pdv.discharge_date_time) = 2018 and
                                  pv.diagnosis_type_rcd = 'dis' and
                                  pv.coding_type_rcd = 'pri' and
								  pv.code not in ('z38.0') and
                                  pv.code = b.code and
								  cd.deleted_date_time is null

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
								  month(pdv.discharge_date_time) = 8 and
                                  year(pdv.discharge_date_time) = 2018 and
                                  pv.diagnosis_type_rcd = 'dis' and
                                  pv.coding_type_rcd = 'pri' and
								  pv.code not in ('z38.0') and
                                  pv.code = b.code and
								  i.sub_item_type_rcd = 'drfee' and
								  cd.deleted_date_time is null
								  --rip.swe_payment_status_rcd <> 'unp'
								  ) as fee_amount,

			(select sum(cd.amount)
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
								  month(pdv.discharge_date_time) = 8 and
                                  year(pdv.discharge_date_time) = 2017 and
                                  pv.diagnosis_type_rcd = 'dis' and
                                  pv.coding_type_rcd = 'pri' and
								  pv.code not in ('z38.0') and
                                  pv.code = b.code and
								  cd.deleted_date_time is null
								  ) as total_amount1,
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
								  month(pdv.discharge_date_time) = 8 and
                                  year(pdv.discharge_date_time) = 2017 and
                                  pv.diagnosis_type_rcd = 'dis' and
                                  pv.coding_type_rcd = 'pri' and
								  pv.code not in ('z38.0') and
                                  pv.code = b.code and
								  i.sub_item_type_rcd = 'drfee' and
								  cd.deleted_date_time is null
								  --rip.swe_payment_status_rcd <> 'unp'
								  ) as fee_amount1
from patient_discharge_nl_view as a inner join patient_visit_diagnosis_view as b on a.patient_visit_id = b.patient_visit_id
                                    inner join patient as c on c.patient_id = b.patient_id
                                    inner join person_formatted_name_iview as d on d.person_id = c.patient_id
                                    inner join coding_system_element_description as e on e.code = b.code
									inner join HISReport.dbo.rpt_invoice_pf as f on f.patient_id = b.patient_id
									--inner join charge_detail as g on b.patient_visit_id = g.patient_visit_id
									--inner join item as h on g.item_id = h.item_id
									--inner join charge_detail as g on a.patient_visit_id = g.patient_visit_id

where --month(a.discharge_date_time) between @From and @To and
      --year(a.discharge_date_time) >= (@year -1) and
	  --year(a.discharge_date_time) <= @year and
		month(a.discharge_date_time) = 8 and
         year(a.discharge_date_time) >= @year1 -1 and 
		 year(a.discharge_date_time) <= @year1 and
      b.diagnosis_type_rcd = 'dis' and
      b.coding_type_rcd = 'pri' and
	  b.code not in ('z38.0')
	  --g.deleted_date_time is null 
	  --h.sub_item_type_rcd <> 'drfee'
--order by mycount desc
) as temp
where temp.Diagnosis = 'malignant neoplasm'
--where mycount <> '0'
--code = 'j18.9'


order by mycount desc