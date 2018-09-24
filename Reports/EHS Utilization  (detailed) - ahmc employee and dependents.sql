--for validation

--80411
--80414
--96167

--14810 Jan 2017
--7444 removed cmar
--50370 (total count of last sent file)
--50686 
--50763 (if charge detail amount is used)
--45002 without negative amount
--44342 w/o package
--44955	(last extracted data - Jan to Sept 2017)
--15202 (Oct - Dec 2017)
--54355 (2016)
--60157 (2017)
--EHS Utilization  (detailed) - ahmc employee and dependents
SELECT --temp.patient_visit_id
			--,temp.patient_id
			--,MONTH(temp.transaction_date_time) as Month
			temp.display_name_l as [Patient Name]
			,temp.[Transaction Date]
			,temp.[Transaction Time]
			,temp.[Date Created]
			,temp.[Time Created]
			,temp.visible_patient_id as [HN]
			,temp.[Date of Birth]
			,temp.age as [Age]
			,temp.marital_status as [Marital Status]
			,temp.visit_type_group_rcd as [Visit Type Group]
			,temp.visit_type as [Visit Type]

			,temp.item_code as [Item Code]
			,temp.item as [Item]
			,temp.item_type as [Item Type]
			,temp.quantity as [Qty]
			,temp.parent_item_group_code as [Parent Item Group Code]
			,temp.parent_item_group_name_l as [Parent Item Group Name]
			,temp.[Item Price]
			,temp.item_group as [Item Group]
			,temp.[Gross Amount]
			,temp.[Discount Amount]
			,temp.[Net Amount]
			--,temp.owing_amount as [Owing Amount]

			,temp.transaction_status as [Transaction Status]
			,temp.payment_status as [Payment Status]
			,temp.transaction_text as [Invoice No.]
			,temp.receipt_number as [Receipt No.]
			,temp.claim_code as [Claim Code]
			,temp.short_code as [Short Code]
			,temp.policy as [Policy]
			,temp.policy_code as [Policy Code]
			,temp.payer as [Payer]
			,temp.[Invoice Amount]

			,temp.visit_code as [Visit Code]

			,temp.gl_transaction_no	--added
FROM
(
						SELECT DISTINCT --pv.patient_visit_id
									--,pv.patient_id
									cast(pv.creation_date_time as date) as [Date Created]
									,format(pv.creation_date_time,'hh:mm tt') as [Time Created]
									,pv.visit_code
									,phu.visible_patient_id
									,pfn.display_name_l
									,cast(pfn.date_of_birth as date) as [Date of Birth]
									,DATEDIFF(dd,pfn.date_of_birth,GETDATE()) / 365 as age
									,person.marital_status_rcd
									,ms.name_l as marital_status
									,vtr.name_l as visit_type
									,vtr.visit_type_group_rcd
									,ar.ar_invoice_id
									,ar.gl_transaction_id
									,cast(ar.transaction_date_time as date) as [Transaction Date]
									,format(ar.transaction_date_time,'hh:mm tt') as [Transaction Time]
									,ar.transaction_status_rcd
									,ar.swe_payment_status_rcd
									,ar.transaction_text
									,i.item_id
									,i.item_code
									,i.name_l as item
									,i.item_type_rcd
									,itr.name_l as item_type
									,cast(ip.price as decimal(10,2)) as [Item Price]
									,ig.parent_item_group_id
									--,ig.item_group_code
									--,ig2.name_l as parent
									,ig.name_l as item_group
									,odiv.parent_item_group_name_l
									,odiv.parent_item_group_code

									--,ar.gross_amount
									--,ar.discount_amount
									--,ar.net_amount
									--,ar.owing_amount

									,cast(ard.gross_amount as decimal(10,2)) as [Gross Amount]
									,cast(ard.discount_amount as decimal(10,2)) as [Discount Amount]
									,cast(ard.gross_amount - ard.discount_amount as decimal(10,2))as [Net Amount]

									--,cd.unit_price
									--,cd.amount
									
									,spsr.name_l as payment_status
									,tsr.name_l as transaction_status
									,pc.claim_code
									--,p.name_l as payer
									,ar.policy_id
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

									,gl.transaction_text as gl_transaction_no	--added
									
						FROM charge_detail cd
										LEFT OUTER JOIN ar_invoice_detail ard ON cd.charge_detail_id = ard.charge_detail_id
										LEFT OUTER JOIN ar_invoice ar ON ard.ar_invoice_id = ar.ar_invoice_id
										LEFT OUTER JOIN item i ON ard.item_id = i.item_id
										LEFT OUTER JOIN item_type_ref itr ON i.item_type_rcd = itr.item_type_rcd
										LEFT OUTER JOIN patient_visit pv ON cd.patient_visit_id = pv.patient_visit_id
										LEFT OUTER JOIN patient_hospital_usage phu ON pv.patient_id = phu.patient_id
										LEFT OUTER JOIN person_formatted_name_iview pfn ON pv.patient_id = pfn.person_id
										LEFT OUTER JOIN policy p ON ar.policy_id = p.policy_id
										LEFT OUTER JOIN policy_claim pc ON ar.ar_invoice_id = pc.ar_invoice_id
										LEFT OUTER JOIN cashier_receipt_view crv ON ard.ar_invoice_id = crv.invoice_id
										LEFT OUTER JOIN visit_type_ref vtr ON pv.visit_type_rcd = vtr.visit_type_rcd										
										LEFT OUTER JOIN swe_payment_status_ref spsr ON ar.swe_payment_status_rcd = spsr.swe_payment_status_rcd
										LEFT OUTER JOIN transaction_status_ref tsr ON ar.transaction_status_rcd = tsr.transaction_status_rcd

										LEFT OUTER JOIN item_price ip ON i.item_id = ip.item_id AND ip.effective_to_date_time IS NULL
										LEFT OUTER JOIN item_group ig ON i.item_group_id = ig.item_group_id
										--LEFT OUTER JOIN item_group ig2 ON ig.parent_item_group_id = ig2.parent_item_group_id AND ig.parent_item_group_id is NULL
										LEFT OUTER JOIN olap_dim_item_view odiv ON i.item_id = odiv.item_id
										LEFT OUTER JOIN person person ON pfn.person_id = person.person_id
										LEFT OUTER JOIN marital_status_ref ms ON person.marital_status_rcd = ms.marital_status_rcd

										LEFT OUTER JOIN gl_transaction gl ON ar.gl_transaction_id = gl.gl_transaction_id		--added

						WHERE --pv.patient_id = '30C41579-5996-11DB-868A-000E0C7F3ED2' AND
										ar.transaction_date_time between '07/01/2018 00:00:00' and '07/31/2018 23:59:59'
										--year(ar.transaction_date_time) = @year and
										--month(ar.transaction_date_time) = @month
										--AND p.policy_id in (@Policy)									
										AND cd.deleted_date_time IS NULL
										AND ar.transaction_status_rcd <> 'VOI'
										AND ar.system_transaction_type_rcd <> 'CDMR'
										AND p.policy_id IN('CF46271E-1DC5-11DE-ACA1-000E0C7F3FA3',		--AHMC Employee Health Clinic - Dependents
																			'4A6E2252-FEEA-11DC-8164-000E0C7F3FA3',		--AHMC Employee Health Clinic - Probationary Employees
																			'DECBB52A-FC93-11DC-8164-000E0C7F3FA3')		--AHMC Employee Health Clinic - Regular Employees

										AND ard.gross_amount >= 0
										AND itr.name_l <> 'Package'
										--AND pv.patient_id = '91425343-9D89-11E2-AF14-78E3B597EBC4'

										--AND ip.effective_from_date_time IS NULL
					--ORDER BY ar.transaction_date_time


						--UNION ALL


						--SELECT DISTINCT pv.patient_visit_id
						--			,pv.patient_id
						--			,pv.creation_date_time
						--			,pv.visit_code
						--			,phu.visible_patient_id
						--			,pfn.display_name_l
						--			,pfn.date_of_birth
						--			,DATEDIFF(dd,pfn.date_of_birth,GETDATE()) / 365 as age
						--			,vtr.name_l as visit_type
						--			,vtr.visit_type_group_rcd
						--			,ar.ar_invoice_id
						--			,ar.gl_transaction_id
						--			,ar.transaction_date_time
						--			,ar.transaction_status_rcd
						--			,ar.swe_payment_status_rcd
						--			,ar.transaction_text
						--			----,cd.deleted_date_time
						--			----,pv.cancelled_date_time
						--			,i.item_id
						--			,i.item_code
						--			,i.name_l as item
						--			,i.item_type_rcd
						--			,itr.name_l as item_type
						--			--,ard.quantity
						--			--,i.item_group_id
						--			,ip.price as item_price
						--			--,(SELECT price from item_price where item_id = i.item_id AND effective_to_date_time IS NULL) as item_price
						--			,ig.name_l as item_group
						--			--,ar.gross_amount
						--			--,ar.discount_amount
						--			--,ar.net_amount
						--			--,ar.owing_amount
						--			,ard.gross_amount
						--			,ard.discount_amount
						--			,(ard.gross_amount - ard.discount_amount)as net_amount
						--			--,cd.amount
									
						--			,spsr.name_l as payment_status
						--			,tsr.name_l as transaction_status
						--			,pc.claim_code
						--			--,p.name_l as payer
						--			,ar.policy_id
						--			,p.short_code
						--			--,p.name_l as policy

						--			,(SELECT name_l from policy where policy_id = p.policy_id
						--							AND policy_id IN ('CF46271E-1DC5-11DE-ACA1-000E0C7F3FA3',						
						--															'4A6E2252-FEEA-11DC-8164-000E0C7F3FA3',						
						--															'DECBB52A-FC93-11DC-8164-000E0C7F3FA3'))as policy

						--			,(SELECT name_l from policy where policy_id = p.policy_id
						--							AND policy_id IN ('CF46271E-1DC5-11DE-ACA1-000E0C7F3FA3',						
						--															'4A6E2252-FEEA-11DC-8164-000E0C7F3FA3',						
						--															'DECBB52A-FC93-11DC-8164-000E0C7F3FA3'))as payer

						--			,(CASE WHEN p.name_l = 'AHMC Employee Health Clinic - Regular Employees' THEN 'Regular'
						--									WHEN p.name_l = 'AHMC Employee Health Clinic - Dependents' THEN 'Dependents'
						--									WHEN p.name_l = 'AHMC Employee Health Clinic - Probationary Employees' THEN 'Probationary'
						--									ELSE ' '
						--									  END) as policy_code

						--			,crv.invoice_number
						--			,crv.invoice_amount
						--			,crv.receipt_number


						--FROM charge_detail cd
						--				LEFT OUTER JOIN ar_invoice_detail ard ON cd.charge_detail_id = ard.charge_detail_id
						--				LEFT OUTER JOIN ar_invoice ar ON ard.ar_invoice_id = ar.ar_invoice_id
						--				LEFT OUTER JOIN item i ON ard.item_id = i.item_id
						--				LEFT OUTER JOIN item_type_ref itr ON i.item_type_rcd = itr.item_type_rcd
						--				LEFT OUTER JOIN patient_visit pv ON cd.patient_visit_id = pv.patient_visit_id
						--				LEFT OUTER JOIN patient_hospital_usage phu ON pv.patient_id = phu.patient_id
						--				LEFT OUTER JOIN person_formatted_name_iview pfn ON pv.patient_id = pfn.person_id
						--				LEFT OUTER JOIN policy p ON ar.policy_id = p.policy_id
						--				LEFT OUTER JOIN policy_claim pc ON ar.ar_invoice_id = pc.ar_invoice_id
						--				LEFT OUTER JOIN cashier_receipt_view crv ON ard.ar_invoice_id = crv.invoice_id
						--				LEFT OUTER JOIN visit_type_ref vtr ON pv.visit_type_rcd = vtr.visit_type_rcd										
						--				LEFT OUTER JOIN swe_payment_status_ref spsr ON ar.swe_payment_status_rcd = spsr.swe_payment_status_rcd
						--				LEFT OUTER JOIN transaction_status_ref tsr ON ar.transaction_status_rcd = tsr.transaction_status_rcd

						--				LEFT OUTER JOIN item_price ip ON i.item_id = ip.item_id AND ip.effective_to_date_time IS NULL
						--				LEFT OUTER JOIN item_group ig ON i.item_group_id = ig.item_group_id


						--WHERE --pv.patient_id = '30C41579-5996-11DB-868A-000E0C7F3ED2' AND
						--				ar.transaction_date_time BETWEEN '2017-01-01 00:00:00.000' AND '2017-01-31 23:59:59.998'
						--				AND cd.deleted_date_time IS NULL
						--				AND ar.transaction_status_rcd <> 'VOI'
						--				AND p.policy_id NOT IN ('CF46271E-1DC5-11DE-ACA1-000E0C7F3FA3',						
						--														'4A6E2252-FEEA-11DC-8164-000E0C7F3FA3',						
						--														'DECBB52A-FC93-11DC-8164-000E0C7F3FA3')
					--ORDER BY ar.transaction_date_time

								

) as temp


ORDER by temp.display_name_l,
		 temp.[Transaction Date]