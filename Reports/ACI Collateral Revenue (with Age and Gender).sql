--collateral rev
--w/ age and gender
SELECT DISTINCT --cd.charge_detail_id
			cast(inv.transaction_date_time as date) as [Invoice Date]
			,format(inv.transaction_date_time,'hh:mm tt') as [Invoice Time]
			,cast(cd.charged_date_time as date) as [Charged Date]
			,format(cd.charged_date_time,'hh:mm tt') as [Charged Time]
			,inv.invoice_no
			,inv.visit_type
			,inv.visit_type_rcd
			,inv.hn
			,inv.patient_name as [Patient Name]
			,apv.sex_name_l as [Gender]
			,datediff (year,date_of_birth,getdate()) as [Age]
			,cc.name_l as service_provider
			,invd.main_itemgroupcode
			,invd.main_itemgroup
			,invd.item_code
			,invd.itemname
			,invd.gross_amount
			,invd.gl_acct_code_code
			,invd.gl_acct_name
			--,invd.policy_id
			,invd.policy_name
	from HISReport.dbo.rpt_invoice_pf inv inner JOIN ar_invoice_nl_view ar on inv.invoice_id = ar.ar_invoice_id
										  inner JOIN HISReport.dbo.rpt_invoice_pf_detailed invd on inv.invoice_id = invd.invoice_id
										  inner JOIN charge_detail_nl_view cd on invd.charge_detail_id = cd.charge_detail_id
										  inner JOIN costcentre_nl_view cc on cd.service_provider_costcentre_id = cc.costcentre_id
										  inner join api_patient_view apv on inv.patient_id = apv.patient_id
	where ar.system_transaction_type_rcd = 'INVR'
		--and invd.main_itemgroupcode in ('160','ACI')
		--and cd.charged_date_time between '06/01/2018 00:00:00' and '06/30/2018 23:59:59'
		and ar.visit_type_rcd IN ('V28','V21','V30','V31','V32')
		--and ar.visit_type_rcd = 'v28'
		and invd.gl_acct_code_code not in  ('2152100','4445000')
		and cd.service_provider_costcentre_id <> 'BB4A131C-FFCD-11D9-A79B-001143B8816C'
		and cd.charged_date_time between @From and @To
		and inv.visit_type in (@VisitType)
	order by inv.invoice_no