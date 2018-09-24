SELECT year(cd.charged_date_time) as year
			,MONTH(cd.charged_date_time) as month
			,cd.charged_date_time
			,format(cd.charged_date_time,'hh:mm tt') as [Time]
			,pv.charge_type_rcd
			,gac.gl_acct_code_code
			,gac.name_l as gl_account_name
			--,cd.gl_acct_code_id
			,cc.costcentre_code
			,cc.name_l as costcentre
			,cd.quantity
			,cd.amount
			,cd.deleted_date_time




FROM charge_detail cd 
			LEFT OUTER JOIN patient_visit pv ON cd.patient_visit_id = pv.patient_visit_id
			LEFT OUTER JOIN gl_acct_code gac ON cd.gl_acct_code_id = gac.gl_acct_code_id
			LEFT OUTER JOIN costcentre cc ON cd.service_requester_costcentre_id = cc.costcentre_id
			LEFT OUTER JOIN patient_hospital_usage phu ON pv.patient_id = phu.patient_id
			LEFT OUTER JOIN person_formatted_name_iview pfn ON pv.patient_id = pfn.person_id
			LEFT OUTER JOIN visit_type_ref vtr ON pv.visit_type_rcd = vtr.visit_type_rcd


where
--cd.charged_date_time between '07/01/2018 00:00:00' and '07/31/2018 23:59:59'
cd.charged_date_time between @From and @To
--and cc.costcentre_code in (@CostCentreCode)
/*AND YEAR(cd.charged_date_time) = 2018
			AND MONTH(cd.charged_date_time) = 1
			--AND gac.gl_acct_code_code IN ('4232200', '4226000', '4244000')	--Heart Station, Cath Lab , Brain Wellness

			--AND gac.gl_acct_code_code = '4232200'		--Brain Wellness
			--AND gac.gl_acct_code_code = '4226000'		--Cath Lab
			--AND gac.gl_acct_code_code = '4244000'		--Heart Station

			AND cc.costcentre_code = '7245'				--Brain Wellness
			AND cc.costcentre_code = '7147'				--Cath Lab
			AND cc.costcentre_code = '7110'				--Heart Station
			AND cc.costcentre_code = '7345'				--Asian Cardiovascular Institute
			AND cc.costcentre_code = '7346'				--Asian Brain Institute

			--and cd.deleted_date_time is NULL
*/
Order by  cd.charged_date_time