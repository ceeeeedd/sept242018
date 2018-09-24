--EHS Utilization summary
SELECT distinct --temp.[Date Created],
			   --temp.[Time Created],
			   temp.[Transaction Date],
			   temp.[Transaction Time],
			   --temp.[Main Group Code],
			   --temp.[Group Name],
			   --temp.[Service Provider],
			  --temp.[Item Code],
			   --temp.[Item Name],
			   temp.visible_patient_id as [HN],
			   temp.display_name_l as [Patient Name],
			   --temp.Employee,
			   --temp.Clinician,
			   --temp.quantity,
			   --temp.[Item Price],
			   temp.[Invoice Amount],
			   temp.[Invoice Date],
			   --temp.[Gross Amount],
			   --temp.[Discount Amount],
			   --temp.[Net Amount],
			   temp.transaction_text as [Invoice No.],
			  --temp.receipt_number as [Receipt No.],
			   --temp.[Transaction Date],
			   --temp.[Transaction Time],
			   temp.policy_code as [Policy Code],
			   temp.short_code,
			   temp.visit_type_group_rcd as [Visit Type Group],
			   isnull(temp.Diagnosis,'--') as [Diagnosis]
FROM
(
						SELECT  DISTINCT --pv.patient_visit_id
									--,pv.patient_id
									cast(pv.creation_date_time as date) as [Date Created]
									,format(pv.creation_date_time,'hh:mm tt') as [Time Created]
									--,pv.visit_code
									,phu.visible_patient_id
									,pfn.display_name_l
									--,cast(pfn.date_of_birth as date) as [Date of Birth]
									--,DATEDIFF(dd,pfn.date_of_birth,GETDATE()) / 365 as age
									--,person.marital_status_rcd
									--,ms.name_l as marital_status
									--,vtr.name_l as visit_type
									,vtr.visit_type_group_rcd
									--,ar.ar_invoice_id
									--,ar.gl_transaction_id
									,cast(ar.transaction_date_time as date) as [Transaction Date]
									,format(ar.transaction_date_time,'hh:mm tt') as [Transaction Time]
									--,ar.transaction_status_rcd
									--,ar.swe_payment_status_rcd
									,ar.transaction_text
									--,i.item_id
									--,i.item_code
									--,i.name_l as item_name
									--,i.item_type_rcd
									--,itr.name_l as item_type
									--,cast(ip.price as decimal(10,2)) as [Item Price]
									,cast(crv.invoice_date_time as date) as [Invoice Date]
									--,ig.parent_item_group_id
									--,ig.item_group_code
									--,ig2.name_l as parent
									--,ig.name_l as item_group
									,odiv.parent_item_group_name_l as [Group Name]
									,odiv.parent_item_group_code as [Main Group Code]
									--,odiv.item_code as [Item Code]
									--,odiv.name_l as [Item Name]
									--,isnull(pfn2.display_name_l,'--') as [Employee]
									--,isnull(pfn1.display_name_l,'--') as [Clinician]							

									--,ar.gross_amount
									--,ar.discount_amount
									--,ar.net_amount
									--,ar.owing_amount

									--,cast(ard.gross_amount as decimal(10,2)) as [Gross Amount]
									--,cast(ard.discount_amount as decimal(10,2)) as [Discount Amount]
									--,cast(ard.gross_amount - ard.discount_amount as decimal(10,2))as [Net Amount]

									--,cd.unit_price
									--,cd.amount
									
									--,spsr.name_l as payment_status
									--,tsr.name_l as transaction_status
									--,pc.claim_code
									--,p.name_l as payer
									--,ar.policy_id
									,p.short_code
									--,p.name_l as policy

									,(SELECT name_l from policy where policy_id = p.policy_id
													AND policy_id IN ('CF46271E-1DC5-11DE-ACA1-000E0C7F3FA3',						
																					'4A6E2252-FEEA-11DC-8164-000E0C7F3FA3',						
																					'DECBB52A-FC93-11DC-8164-000E0C7F3FA3'))as policy

									,(SELECT name_l from policy where policy_id = p.policy_id
													AND policy_id IN ('CF46271E-1DC5-11DE-ACA1-000E0C7F3FA3',						
																					'4A6E2252-FEEA-11DC-8164-000E0C7F3FA3',						
																					'DECBB52A-FC93-11DC-8164-000E0C7F3FA3'))as payer

									,(CASE WHEN p.name_l = 'AHMC Employee Health Clinic - Regular Employees' THEN 'Regular'
															WHEN p.name_l = 'AHMC Employee Health Clinic - Dependents' THEN 'Dependents'
															WHEN p.name_l = 'AHMC Employee Health Clinic - Probationary Employees' THEN 'Probationary'
															ELSE ' '
															  END) as policy_code

									,crv.invoice_number
									,cast(crv.invoice_amount as decimal(10,2)) as [Invoice Amount]
									,crv.receipt_number

									--,ard.quantity
									,cd.quantity

									--,gl.transaction_text as gl_transaction_no	--added
									,c.name_l as [Service Provider]
									,(select top 1 a.diagnosis from patient_discharge_diagnosis_coding_view a where a.patient_visit_id = pv.patient_visit_id) as [Diagnosis]
									
						FROM charge_detail cd
										LEFT OUTER JOIN ar_invoice_detail ard ON cd.charge_detail_id = ard.charge_detail_id
										LEFT OUTER JOIN ar_invoice ar ON ard.ar_invoice_id = ar.ar_invoice_id
										LEFT OUTER JOIN item i ON ard.item_id = i.item_id
										LEFT OUTER JOIN item_type_ref itr ON i.item_type_rcd = itr.item_type_rcd
										LEFT OUTER JOIN patient_visit pv ON cd.patient_visit_id = pv.patient_visit_id
										LEFT OUTER JOIN patient_hospital_usage phu ON pv.patient_id = phu.patient_id
										LEFT OUTER JOIN person_formatted_name_iview pfn ON pv.patient_id = pfn.person_id
										LEFT OUTER JOIN person_formatted_name_iview pfn1 on cd.caregiver_employee_id = pfn1.person_id
										LEFT OUTER JOIN person_formatted_name_iview pfn2 on cd.charged_by_employee_id = pfn2.person_id
										LEFT OUTER JOIN policy p ON ar.policy_id = p.policy_id
										LEFT OUTER JOIN policy_claim pc ON ar.ar_invoice_id = pc.ar_invoice_id
										LEFT OUTER JOIN cashier_receipt_view crv ON ard.ar_invoice_id = crv.invoice_id
										LEFT OUTER JOIN visit_type_ref vtr ON pv.visit_type_rcd = vtr.visit_type_rcd										
										LEFT OUTER JOIN swe_payment_status_ref spsr ON ar.swe_payment_status_rcd = spsr.swe_payment_status_rcd
										LEFT OUTER JOIN transaction_status_ref tsr ON ar.transaction_status_rcd = tsr.transaction_status_rcd
										LEFT OUTER JOIN costcentre c on cd.service_provider_costcentre_id = c.costcentre_id 
										--LEFT OUTER JOIN patient_discharge_diagnosis_coding_view pdd on pv.patient_visit_id = pdd.patient_visit_id

										LEFT OUTER JOIN item_price ip ON i.item_id = ip.item_id AND ip.effective_to_date_time IS NULL
										LEFT OUTER JOIN item_group ig ON i.item_group_id = ig.item_group_id
										--LEFT OUTER JOIN item_group ig2 ON ig.parent_item_group_id = ig2.parent_item_group_id AND ig.parent_item_group_id is NULL
										LEFT OUTER JOIN olap_dim_item_view odiv ON cd.item_id = odiv.item_id
										--LEFT OUTER JOIN person person ON pfn.person_id = person.person_id
										--LEFT OUTER JOIN marital_status_ref ms ON person.marital_status_rcd = ms.marital_status_rcd

										LEFT OUTER JOIN gl_transaction gl ON ar.gl_transaction_id = gl.gl_transaction_id		--added

						WHERE --pv.patient_id = '30C41579-5996-11DB-868A-000E0C7F3ED2' AND
										--ar.transaction_date_time between '06/01/2018 00:00:00' and '06/02/2018 23:59:59'
										--year(ar.transaction_date_time) = 2018 and
										--month(ar.transaction_date_time) = 7
										year(ar.transaction_date_time) = @year and
										month(ar.transaction_date_time) = @month
										--AND p.policy_id in (@Policy)									
										AND cd.deleted_date_time IS NULL
										AND ar.transaction_status_rcd <> 'VOI'
										AND ar.system_transaction_type_rcd <> 'CDMR'
										AND p.policy_id IN('CF46271E-1DC5-11DE-ACA1-000E0C7F3FA3',		--AHMC Employee Health Clinic - Dependents
																			'4A6E2252-FEEA-11DC-8164-000E0C7F3FA3',		--AHMC Employee Health Clinic - Probationary Employees
																			'DECBB52A-FC93-11DC-8164-000E0C7F3FA3')		--AHMC Employee Health Clinic - Regular Employees

										--AND ard.gross_amount >= 0
										--AND itr.name_l <> 'Package'
										--AND pv.patient_id = '91425343-9D89-11E2-AF14-78E3B597EBC4'

										--AND ip.effective_from_date_time IS NULL
					--ORDER BY ar.transaction_date_time

								

) as temp
--where temp.visible_patient_id = '00428321'
--group by 
--		   temp.[Transaction Date],
--			   temp.[Transaction Time],
--			   temp.visible_patient_id,
--			   temp.display_name_l,
--			   temp.[Invoice Amount],
--			   temp.[Invoice Date],
--			   temp.transaction_text,
--			   temp.policy_code,
--			   temp.short_code,
--			   temp.visit_type_group_rcd,
--			   temp.Diagnosis
ORDER by temp.[Transaction Date]