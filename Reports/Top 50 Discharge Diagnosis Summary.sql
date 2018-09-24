select top 50 temp.code,
			  temp.description,
			  case when temp.code in ('C00', 'C01', 'C02', 'C03', 'C04', 'C05', 'C06', 'C07', 'C08', 'C09', 'C10', 'C11', 'C12', 'C13', 'C14', 'C15',
				'C16', 'C17', 'C18', 'C19', 'C20', 'C21', 'C22', 'C23', 'C24', 'C25', 'C26', 'C30', 'C31', 'C32', 'C33', 'C34', 
				'C37', 'C38', 'C39', 'C40', 'C41', 'C44', 'C44.9', 'C47', 'C48', 'C49', 'C50', 'C51', 'C52', 'C53', 'C54', 'C55', 
				'C56', 'C57', 'C58', 'C60', 'C61', 'C62', 'C63', 'C64', 'C65', 'C66', 'C67', 'C68', 'C69', 'C70', 'C71', 'C72', 
				'C73', 'C74', 'C75', 'C76') then 'Malignant Neoplasm' else temp.description end as [Diagnosis],

		   (select count(p.patient_id) 
			from patient_discharge_nl_view as pdv inner join patient_visit_diagnosis_view as pv on pv.patient_visit_id = pdv.patient_visit_id
			 									  inner join patient as p on p.patient_id = pv.patient_id
												  inner join person_formatted_name_iview as pfn on pfn.person_id = p.patient_id
												  inner join coding_system_element_description as cse on cse.code = pv.code
			where --month(pdv.discharge_date_time) = 7 and
					--year(pdv.discharge_date_time) = (2018 -1) and
					month(pdv.discharge_date_time) between @From and @To and
					year(pdv.discharge_date_time) = (@year -1) and
					pv.diagnosis_type_rcd = 'dis' and
					pv.coding_type_rcd = 'pri' and
					pv.code not in ('z38.0') and
					pv.code = temp.code) as [2017],

			(select sum(cd.amount) -- - (ard.gross_amount)
        from patient_discharge_nl_view as pdv inner join patient_visit_diagnosis_view as pv on pv.patient_visit_id = pdv.patient_visit_id
                                              inner join patient as p on p.patient_id = pv.patient_id
                                              inner join person_formatted_name_iview as pfn on pfn.person_id = p.patient_id
                                              inner join coding_system_element_description as cse on cse.code = pv.code
											  inner join charge_detail as cd on pv.patient_visit_id = cd.patient_visit_id
											  --inner join ar_invoice_detail as ard on cd.charge_detail_id = ard.charge_detail_id
											  --inner join item as i on ard.item_id = i.item_id
											  --inner join sub_item_type_ref as sit on i.sub_item_type_rcd = sit.sub_item_type_rcd
                     where month(pdv.discharge_date_time) between @From and  @To and
                                  year(pdv.discharge_date_time) = (@year -1) and
								  --month(pdv.discharge_date_time) = 7 and
                                  --year(pdv.discharge_date_time) = (2018 -1) and
                                  pv.diagnosis_type_rcd = 'dis' and
                                  pv.coding_type_rcd = 'pri' and
								  pv.code not in ('z38.0') and
                                  pv.code = temp.code and
								  cd.patient_visit_id = pv.patient_visit_id and
								  cd.deleted_date_time is null
								  --sit.sub_item_type_rcd = 'drfee'
								  --rip.swe_payment_status_rcd <> 'unp'
								  --group by ard.gross_amount
								  ) as total_amount_previousyear,
			(select  sum(cd.amount)
        from patient_discharge_nl_view as pdv inner join patient_visit_diagnosis_view as pv on pv.patient_visit_id = pdv.patient_visit_id
                                              inner join patient as p on p.patient_id = pv.patient_id
                                              inner join person_formatted_name_iview as pfn on pfn.person_id = p.patient_id
                                              inner join coding_system_element_description as cse on cse.code = pv.code
											  inner join charge_detail as cd on pv.patient_visit_id = cd.patient_visit_id
											  --inner join ar_invoice_detail as ard on cd.charge_detail_id = ard.charge_detail_id
											  inner join item as i on cd.item_id = i.item_id
											  --inner join sub_item_type_ref as sit on i.sub_item_type_rcd = sit.sub_item_type_rcd
                     where month(pdv.discharge_date_time) between @From and  @To and
                                  year(pdv.discharge_date_time) = (@year -1) and
								  --month(pdv.discharge_date_time) = 7 and
                                  --year(pdv.discharge_date_time) = (2018 -1) and
                                  pv.diagnosis_type_rcd = 'dis' and
                                  pv.coding_type_rcd = 'pri' and
								  pv.code not in ('z38.0') and
                                  pv.code = temp.code and
								  cd.patient_visit_id = pv.patient_visit_id and
								  i.sub_item_type_rcd = 'drfee' and
								  cd.deleted_date_time is null
								  --rip.swe_payment_status_rcd <> 'unp'
								  ) as fee_amount_previousyear,
            temp.[2018],
			temp.total_amount_selectedyear,
			  temp.fee_amount_selectedyear
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
			where --month(pdv.discharge_date_time) = 7 and
			--		year(pdv.discharge_date_time) = (2018) and
					month(pdv.discharge_date_time) between @From and @To and
					year(pdv.discharge_date_time) = @year and
					pv.diagnosis_type_rcd = 'dis' and
					pv.coding_type_rcd = 'pri' and
					pv.code not in ('z38.0') and
					pv.code = main_pv.code) as [2018],


			(select sum(cd.amount) -- - (ard.gross_amount)
        from patient_discharge_nl_view as pdv inner join patient_visit_diagnosis_view as pv on pv.patient_visit_id = pdv.patient_visit_id
                                              inner join patient as p on p.patient_id = pv.patient_id
                                              inner join person_formatted_name_iview as pfn on pfn.person_id = p.patient_id
                                              inner join coding_system_element_description as cse on cse.code = pv.code
											  inner join charge_detail as cd on pv.patient_visit_id = cd.patient_visit_id
											  --inner join ar_invoice_detail as ard on cd.charge_detail_id = ard.charge_detail_id
											  --inner join item as i on ard.item_id = i.item_id
											  --inner join sub_item_type_ref as sit on i.sub_item_type_rcd = sit.sub_item_type_rcd
                     where month(pdv.discharge_date_time) between @From and  @To and
                                  year(pdv.discharge_date_time) = @year and
								  --month(pdv.discharge_date_time) = 7 and
          --                        year(pdv.discharge_date_time) = (2018) and
                                  pv.diagnosis_type_rcd = 'dis' and
                                  pv.coding_type_rcd = 'pri' and
								  pv.code not in ('z38.0') and
                                  pv.code = main_pv.code and
								  cd.patient_visit_id = pv.patient_visit_id and
								  cd.deleted_date_time is null
								  --sit.sub_item_type_rcd = 'drfee'
								  --rip.swe_payment_status_rcd <> 'unp'
								  --group by ard.gross_amount
								  ) as total_amount_selectedyear,
			(select  sum(cd.amount)
        from patient_discharge_nl_view as pdv inner join patient_visit_diagnosis_view as pv on pv.patient_visit_id = pdv.patient_visit_id
                                              inner join patient as p on p.patient_id = pv.patient_id
                                              inner join person_formatted_name_iview as pfn on pfn.person_id = p.patient_id
                                              inner join coding_system_element_description as cse on cse.code = pv.code
											  inner join charge_detail as cd on pv.patient_visit_id = cd.patient_visit_id
											  --inner join ar_invoice_detail as ard on cd.charge_detail_id = ard.charge_detail_id
											  inner join item as i on cd.item_id = i.item_id
											  --inner join sub_item_type_ref as sit on i.sub_item_type_rcd = sit.sub_item_type_rcd
                     where month(pdv.discharge_date_time) between @From and  @To and
                                  year(pdv.discharge_date_time) = @year and
								  --month(pdv.discharge_date_time) = 7 and
                                  --year(pdv.discharge_date_time) = (2018) and
                                  pv.diagnosis_type_rcd = 'dis' and
                                  pv.coding_type_rcd = 'pri' and
								  pv.code not in ('z38.0') and
                                  pv.code = main_pv.code and
								  cd.patient_visit_id = pv.patient_visit_id and
								  i.sub_item_type_rcd = 'drfee' and
								  cd.deleted_date_time is null
								  --rip.swe_payment_status_rcd <> 'unp'
								  ) as fee_amount_selectedyear
		


	from coding_system_element_description as main_pv
	where coding_system_rcd = 'ICD10'
	
) as temp
order by temp.[2018] DESC