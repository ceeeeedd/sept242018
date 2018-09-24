--Active Medical Staff and Dependents - 2016 to July 2017 (MAF Request for Utilization Report of Doctors Benefits)
--51718
--5035 --unk, voi, 2016
SELECT -- ar.ar_invoice_id
			--,ar.policy_id


			p.short_code
			,p.policy_number
			,p.policy_type_rcd
			,ptr.name_l as policy_type
			,p.name_l as policy
			,p.ipd_cover_flag
			,p.opd_cover_flag

			,cast(ar.transaction_date_time as date) as [Transaction Date]
			,format(ar.transaction_date_time,'hh:mm tt') as [Transaction Time]
			,cast(ar.created_on_date_time as date) as [Date Created]
			,format(ar.created_on_date_time,'hh:mm tt') as [Time Created]
			,ar.visit_type_rcd as Visit_Code
			,vtr.name_l as Visit_Type
			,cast(ar.gross_amount as decimal(10,2)) as Gross_Amount
			,cast(ar.net_amount as decimal(10,2)) as Net_Amount
			,cast(ar.tax_amount as decimal(10,2)) as Tax_Amount
			,cast(ar.discount_amount as decimal(10,2)) as Discount_Amount
			,cast(ar.rounding_amount as decimal(10,2)) as Rounding_Amount
			,cast(ar.owing_amount as decimal(10,2)) as Owing_Amount
			,ar.transaction_nr as Transaction_NR
			,ar.transaction_text as Transaction_Text
			,ar.transaction_status_rcd as Transaction_Code
			,tsr.name_l as Transaction_Status
			,ar.swe_payment_status_rcd
			,spsr.name_l as payment_status
			,ar.system_transaction_type_rcd as Transaction_Type
			,sttr.name_l as system_transaction_type
			,ar.ar_invoice_type_rnr as Invoice_Type

			--,ard.discount_posting_rule_id
			--,ard.discount_gl_acct_code_id
			--,ard.discount_costcentre_id
			--,ard.item_id
			--,ard.quantity
			--,ard.uom_rcd
			,cast(ard.gross_amount as decimal(10,2)) as ard_Gross_Amount
			,cast(ard.discount_amount as decimal(10,2)) as ard_Discount_Amount
			,cast(ard.tax_amount as decimal(10,2)) as ard_Tax_Amount
			,ard.discount_percentage
			--,ard.free_line_l
			,ard.visit_type_rcd

			,vtr.er_registration_flag
			,vtr.mandatory_caregiver_roles_flag
			,vtr.auto_close_visits_flag

			,glc.gl_acct_code_code as GL_Account_Code
			,glc.name_l as gl_account_name


FROM ar_invoice ar
			LEFT OUTER JOIN ar_invoice_detail ard ON ard.ar_invoice_id = ar.ar_invoice_id
			LEFT OUTER JOIN policy p ON ar.policy_id = p.policy_id
			LEFT OUTER JOIN visit_type_ref vtr ON ar.visit_type_rcd = vtr.visit_type_rcd
			LEFT OUTER JOIN swe_payment_status_ref spsr ON ar.swe_payment_status_rcd = spsr.swe_payment_status_rcd
			LEFT OUTER JOIN gl_acct_code glc ON ard.discount_gl_acct_code_id = glc.gl_acct_code_id
			LEFT OUTER JOIN policy_type_ref ptr ON p.policy_type_rcd = ptr.policy_type_rcd
			LEFT OUTER JOIN transaction_status_ref tsr ON ar.transaction_status_rcd = tsr.transaction_status_rcd
			LEFT OUTER JOIN system_transaction_type_ref sttr ON ar.system_transaction_type_rcd = sttr.system_transaction_type_rcd

where ard.discount_gl_acct_code_id IN ('A9D35914-B575-11DF-80DB-0022195FC77A', 'B016EDF6-832B-11E3-A934-0022195FC77E') --active medical staff
			and ar.policy_id IN ('3FA759B8-B55C-11DF-B9CA-0022642F6485', '1F0BC40C-DEEA-11E2-9A70-78E3B58FE3DB') --active medical staff
			AND ar.transaction_status_rcd not in ('unk', 'voi')
			--AND ar.transaction_date_time between @From and @To
			AND ar.transaction_date_time between '07/01/2018 00:00:00:000' AND '07/30/2018 23:59:59:998'
			--AND month(ar.transaction_date_time) >= 1 AND month(ar.transaction_date_time) <=7
			AND ar.system_transaction_type_rcd <> 'cdmr'
			--AND p.billing_flag <> 1

			select top 10 * from ar_invoice_detail
			select top 10 * from ar_invoice