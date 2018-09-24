--ECU PACKAGES	
			
SELECT temp.charged_date_time as [Charged Date and Time]
			,temp.[Time Charged]
			,temp.actual_visit_date_time as [Actual Visit Date and Time]
			,temp.[Actual Visit Time]
			,temp.charge_type_rcd as [Charge Type]
			,temp.parent_item_group_code  as [Main Item Group Code]
			,temp.item_package_group as [Package Name]
			,temp.item_code as [Item Code]
			,temp.item_desc as [Item Name]
			,temp.item_type as [Item Type]
			,temp.quantity as [Qty]
			,temp.amount as [Amount]
			,temp.payment_status as [Payment Status]
			,temp.service_provider as [Service Provider]
			,temp.visible_patient_id as [HN]
			,temp.display_name_l as [Patient Name]
			,temp.age as [Age]
			,temp.date_of_birth as [Date of Birth]
			,temp.visit_type as [Visit Type]
			,isnull(temp.caregiver,'--') as [Clinician]
			,temp.charged_by_employee as [Charged By Employee]
			,temp.visit_code as [Visit Code]
			
	
FROM		
(
			SELECT DISTINCT
				b.actual_visit_date_time,
				format(b.actual_visit_date_time,'hh:mm tt') as [Actual Visit Time],
				a.charged_date_time,
				format(a.charged_date_time,'hh:mm tt') as [Time Charged],
				b.charge_type_rcd,
				c.item_code,
				c.name_l AS item_desc,
				a.quantity
				,(SELECT name_l from costcentre where costcentre_id = a.service_provider_costcentre_id) as service_provider
				,phu.visible_patient_id
				,pfn.display_name_l
				,DATEDIFF(dd,pfn.date_of_birth,GETDATE()) / 365 as age
				,pfn.date_of_birth
				,b.visit_type_rcd
				,vtr.name_l as visit_type
				,a.caregiver_employee_id
				,(SELECT display_name_l from person_formatted_name_iview where person_id = a.caregiver_employee_id)as caregiver
				,a.charged_by_employee_id
				,(SELECT display_name_l from person_formatted_name_iview where person_id = a.charged_by_employee_id)as charged_by_employee
				,itr.name_l as item_type
				,a.amount
				,spsr.name_l as payment_status
				,b.visit_code
				,a.patient_visit_package_id
				,(SELECT name_l from item where item_id = 
									(SELECT top 1 item_id from package_item where item_id =
										(SELECT top 1 package_item_id from patient_visit_package where patient_visit_package_id = a.patient_visit_package_id))) item_package_group
				,d.parent_item_group_code
				


			FROM	charge_detail a
							LEFT OUTER JOIN patient_visit b ON a.patient_visit_id = b.patient_visit_id
							LEFT OUTER JOIN item c ON a.item_id = c.item_id
							LEFT OUTER JOIN olap_dim_item_view d on c.item_id = d.item_id
							LEFT OUTER JOIN patient_hospital_usage phu ON b.patient_id = phu.patient_id
							LEFT OUTER JOIN person_formatted_name_iview pfn ON b.patient_id = pfn.person_id

							INNER JOIN visit_type_ref vtr ON b.visit_type_rcd = vtr.visit_type_rcd
							INNER JOIN item_type_ref itr ON c.item_type_rcd = itr.item_type_rcd
							INNER JOIN swe_payment_status_ref spsr ON a.payment_status_rcd = spsr.swe_payment_status_rcd

			WHERE 
			(MONTH(a.charged_date_time) = 7
				AND YEAR(a.charged_date_time) = 2018)
			 --(MONTH(a.charged_date_time) = @month
				--AND YEAR(a.charged_date_time) = @year)

			GROUP BY
					b.patient_visit_id,
					a.charge_detail_id,
					b.actual_visit_date_time,
					a.charged_date_time
					,b.charge_type_rcd
					,c.item_group_id
					,c.item_code
					,c.name_l 
					,a.service_provider_costcentre_id
					,a.quantity
					,phu.visible_patient_id
					,pfn.display_name_l
					,pfn.date_of_birth
					,b.visit_type_rcd
					,vtr.name_l
					,a.caregiver_employee_id
					,a.charged_by_employee_id
					,itr.name_l
					,a.amount
					,spsr.name_l
					,b.visit_code
					,a.patient_visit_package_id
					,a.parent_charge_detail_id
					,d.item_group_code
					,d.parent_item_group_name_l
					,d.parent_item_group_code
					,c.item_id
					,a.item_id
)as temp
--where temp.visible_patient_id = '00148345'
where temp.item_package_group is not null
and datename(weekday,temp.charged_date_time) <> 'sunday'
			order by temp.charged_date_time,
					 temp.item_package_group asc