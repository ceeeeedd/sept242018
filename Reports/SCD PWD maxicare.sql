--SCD/PWD maxicare
SELECT --cd.service_provider_costcentre_id as [Service Provider CostCentre ID]
			--,cd.gl_acct_code_id  as [GL Account Code ID]
		  --  ,cd.item_id  as [Item ID]  
			i.item_code as [Item Code]
			,i.name_l as [Item_Name]
			,i.item_type_rcd as [Item_Type]
			,pfn.display_name_l as [Patient Name]
			,phu.visible_patient_id as [Patient ID]
			,DATEDIFF(dd, pfn.date_of_birth, GETDATE()) / 365 as [Age]
			,YEAR(cd.charged_date_time) as [Year]
			,MONTH(cd.charged_date_time) as [Month]
			,format(cd.charged_date_time,'hh:mm tt') as [Time]
			--,p.policy_id as [Policy ID]
			,arh.transaction_date_time as [Transaction Date and Time]
			,arh.transaction_text as [Transaction ID]
			--,cd.charge_detail_id as [Charge Detail ID]
			--,arh.ar_invoice_id as [Invoice ID]
			,p.name_l as [Policy Name]     
			,ard.gross_amount as [Gross Amount]
			,ard.discount_amount as [Discount Amount]
			,(ard.gross_amount - ard.discount_amount) as [Net Amount]
			--,SUM(cd.quantity) AS volume        
			--,SUM(ROUND(cd.amount,2)) AS revenue        
			
	FROM dbo.charge_detail_nl_view AS cd 
															INNER JOIN dbo.patient_visit_nl_view AS pv ON cd.patient_visit_id = pv.patient_visit_id
															LEFT OUTER JOIN dbo.patient_visit_policy as pvp ON pv.patient_visit_id = pvp.patient_visit_id
															LEFT OUTER join dbo.ar_invoice_detail ard on cd.charge_detail_id = ard.charge_detail_id
															LEFT outer JOIN dbo.ar_invoice arh on ard.ar_invoice_id = arh.ar_invoice_id
															inner JOIN dbo.policy p on pvp.policy_id = p.policy_id
															inner join dbo.item i on ard.item_id = i.item_id
															INNER JOIN dbo.person_formatted_name_iview as pfn ON pv.patient_id = pfn.person_id
															LEFT OUTER JOIN dbo.patient_hospital_usage as phu ON pv.patient_id = phu.patient_id
															
	WHERE cd.charged_date_time between @From and @To
	--YEAR(cd.charged_date_time) = 2015
		--and MONTH(cd.charged_date_time) = 12
		--AND cd.deleted_date_time IS NULL
		and p.policy_id = '0D2C251E-6ED7-11E3-84F9-78E3B58FDD66'
		--AND (SELECT policy_id from ar_invoice where ar_invoice_id = arh.ar_invoice_id) =  '0D2C251E-6ED7-11E3-84F9-78E3B58FDD66'
		--AND (SELECT policy_id from patient_visit_policy where policy_id = arh.policy_id) IN ('AE27B927-5FF7-11DA-BB34-000E0C7F3ED2','B01C02EE-04CC-11DF-B726-00237DBC514A')
		--AND pvp.policy_id IN ('AE27B927-5FF7-11DA-BB34-000E0C7F3ED2','B01C02EE-04CC-11DF-B726-00237DBC514A')
		--AND arh.transaction_status_rcd <> 'VOI'	
		--AND arh.swe_payment_status_rcd IN ('UNP','COM')
	GROUP BY     
			cd.service_provider_costcentre_id
			,cd.gl_acct_code_id
			,p.policy_id
			,p.name_l
			,cd.item_id 
			,i.item_code
			,i.item_type_rcd
			,i.name_l
			,charged_date_time
			,cd.charge_detail_id
			,arh.ar_invoice_id
			,arh.transaction_date_time
			,arh.transaction_text
			,pfn.display_name_l
			,phu.visible_patient_id
			,DATEDIFF(dd, pfn.date_of_birth, GETDATE()) / 365
			,ard.gross_amount
			,ard.discount_amount
			,(ard.gross_amount - ard.discount_amount)

ORDER BY cd.charge_detail_id ASC