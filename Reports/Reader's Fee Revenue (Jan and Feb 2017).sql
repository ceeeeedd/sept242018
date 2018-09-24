----20755
--SELECT SUM(temp.gross_amount)
---- temp.costcentre_code,
-- --temp.costcentre
--from
--(
--Reader's Fee Revenue (Jan and Feb 2017)
--SQL Server Native Client 11.0 does not support connections to SQL Server 2000 or earlier versions.


			SELECT DISTINCT ard.ar_invoice_id
			 ,'Paid' as [Payment Status]
			,spsr.name_l as payment_status
			,ar.transaction_date_time as Transaction_Date
			,ar.transaction_date_time as transaction_time
			,cd.charged_date_time as Charged_Date
			,cd.charged_date_time as time_charged
			,phu.visible_patient_id
			,pfn.display_name_l
			,gac.gl_acct_code_code
			,gac.name_l as gl_acct_name
			,i.item_code
			,i.name_l as item
			,itr.name_l as item_type
			,ard.quantity
			,ur.name_l as uom
			,ard.unit_price
			,ard.gross_amount
			,ard.discount_amount
			,(ard.gross_amount - ard.discount_amount) as net_amount
			,ard.tax_amount
			,ard.discount_percentage
			,cd.adjustment_amount
			,ISNULL(cd2.commission_rate,0) as [Commission Rate]
		    ,ISNULL(cd2.discount_amt_scd,0) as [Discount Amount SCD]
		    ,ISNULL(cd2.discount_amt_other,0) as [Discount Amount Other]
		    ,ISNULL(cd2.remaining_balance,0) as [Remaining Balance]
		    ,ISNULL(cd2.accumulated_amount,0) as [Accumulated Amount]

			,(SELECT name_l from [DBPROD03].AmalgaPROD.dbo.costcentre WHERE costcentre_id = cd.service_requester_costcentre_id) as service_requestor
			,(SELECT name_l from [DBPROD03].AmalgaPROD.dbo.costcentre where costcentre_id = cd.service_provider_costcentre_id) as service_provider
			,vtr.name_l as visit_type
			,cc.costcentre_code
			,cc.name_l as costcentre
			,tsr.name_l as transaction_status
			,sttr.name_l as system_transaction_type
			,ar.transaction_nr
			,ar.transaction_text

			--,ard.book_gross_amount as gross_amount
			--,ard.book_discount_amount
			--cd.charge_detail_id,
			--pv.patient_visit_id,
			--,i.item_icon_rcd
			--,i.sub_item_type_rcd

			from [DBPROD03].HISViews.dbo.ar_invoice_vw ar 
						inner JOIN [DBPROD03].AmalgaPROD.dbo.ar_invoice_detail ard on ar.ar_invoice_id = ard.ar_invoice_id 
						INNER JOIN [DBPROD03].AmalgaPROD.dbo.charge_detail cd ON ard.charge_detail_id = cd.charge_detail_id
						inner JOIN [DBPROD03].AmalgaPROD.dbo.gl_acct_code gac on ard.gl_acct_code_credit_id = gac.gl_acct_code_id
						inner JOIN [DBPROD03].AmalgaPROD.dbo.item i on ard.item_id = i.item_id
						inner JOIN [DBPROD03].AmalgaPROD.dbo.item_group_costcentre_nl_view igc on i.item_group_id = igc.item_group_id 
						inner JOIN [DBPROD03].AmalgaPROD.dbo.costcentre_nl_view cc on igc.costcentre_id = cc.costcentre_id
						INNER JOIN [DBPROD03].AmalgaPROD.dbo.swe_payment_status_ref spsr ON ar.swe_payment_status_rcd = spsr.swe_payment_status_rcd
						INNER JOIN [DBPROD03].AmalgaPROD.dbo.transaction_status_ref tsr ON ar.transaction_status_rcd = tsr.transaction_status_rcd
						INNER JOIN [DBPROD03].AmalgaPROD.dbo.system_transaction_type_ref sttr ON ar.system_transaction_type_rcd = sttr.system_transaction_type_rcd
					
						INNER JOIN [DBPROD03].HISViews.dbo.patient_visit_vw pv ON cd.patient_visit_id = pv.patient_visit_id
						INNER JOIN [DBPROD03].AmalgaPROD.dbo.patient_hospital_usage phu ON pv.patient_id = phu.patient_id
						INNER JOIN [DBPROD03].AmalgaPROD.dbo.person_formatted_name_iview pfn ON pv.patient_id = pfn.person_id
						INNER JOIN [DBPROD03].AmalgaPROD.dbo.visit_type_ref vtr ON pv.visit_type_rcd = vtr.visit_type_rcd
						INNER JOIN [DBPROD03].AmalgaPROD.dbo.item_type_ref itr ON i.item_type_rcd = itr.item_type_rcd
						LEFT OUTER JOIN [DBPROD03].AmalgaPROD.dbo.uom_ref as ur ON ard.uom_rcd = ur.uom_rcd
						LEFT OUTER JOIN itworksds01.dis.dbo.payment_period_detail_history ppdh on ard.ar_invoice_detail_id = ppdh.ar_invoice_detail_id 
						left OUTER JOIN itworksds01.dis.dbo.df_browse_all df ON ppdh.charge_id = df.charge_id
						left outer JOIN itworksds01.dis.dbo.charge_detail cd2 ON df.charge_id = cd2.charge_id

			where --MONTH(ar.transaction_date_time) = 1
						--and YEAR(ar.transaction_date_time) = 2017
			--ar.transaction_date_time between @From and @To
			ar.transaction_date_time between '1/1/2018 00:00:00' and '1/2/2018 23:59:59'
			and ar.transaction_status_rcd not in ('voi','unk')
			and gac.gl_acct_code_code = '4264000'
			and i.item_type_rcd = 'srv'
			and i.sub_item_type_rcd = 'drfee'
			and ard.gross_amount > 0
			 and df.charge_id in (select charge_id from itworksds01.dis.dbo.payment_period_detail_history) --PAID
			--and ard.item_id = cd.item_id
			--AND cd.deleted_date_time IS NULL

			UNION ALL

			SELECT DISTINCT ard.ar_invoice_id
			 ,'Unpaid' as [Payment Status]
			,spsr.name_l as payment_status
			,ar.transaction_date_time as Transaction_Date
			,ar.transaction_date_time as transaction_time
			,cd.charged_date_time as Charged_Date
			,cd.charged_date_time as time_charged
			,phu.visible_patient_id
			,pfn.display_name_l
			,gac.gl_acct_code_code
			,gac.name_l as gl_acct_name
			,i.item_code
			,i.name_l as item
			,itr.name_l as item_type
			,ard.quantity
			,ur.name_l as uom
			,ard.unit_price
			,ard.gross_amount
			,ard.discount_amount
			,(ard.gross_amount - ard.discount_amount) as net_amount
			,ard.tax_amount
			,ard.discount_percentage
			,cd.adjustment_amount
			,ISNULL(cd2.commission_rate,0) as [Commission Rate]
		    ,ISNULL(cd2.discount_amt_scd,0) as [Discount Amount SCD]
		    ,ISNULL(cd2.discount_amt_other,0) as [Discount Amount Other]
		    ,ISNULL(cd2.remaining_balance,0) as [Remaining Balance]
		    ,ISNULL(cd2.accumulated_amount,0) as [Accumulated Amount]

			,(SELECT name_l from [DBPROD03].AmalgaPROD.dbo.costcentre WHERE costcentre_id = cd.service_requester_costcentre_id) as service_requestor
			,(SELECT name_l from [DBPROD03].AmalgaPROD.dbo.costcentre where costcentre_id = cd.service_provider_costcentre_id) as service_provider
			,vtr.name_l as visit_type
			,cc.costcentre_code
			,cc.name_l as costcentre
			,tsr.name_l as transaction_status
			,sttr.name_l as system_transaction_type
			,ar.transaction_nr
			,ar.transaction_text

			--,ard.book_gross_amount as gross_amount
			--,ard.book_discount_amount
			--cd.charge_detail_id,
			--pv.patient_visit_id,
			--,i.item_icon_rcd
			--,i.sub_item_type_rcd

			from [DBPROD03].HISViews.dbo.ar_invoice_vw ar 
						inner JOIN [DBPROD03].AmalgaPROD.dbo.ar_invoice_detail ard on ar.ar_invoice_id = ard.ar_invoice_id 
						INNER JOIN [DBPROD03].AmalgaPROD.dbo.charge_detail cd ON ard.charge_detail_id = cd.charge_detail_id
						inner JOIN [DBPROD03].AmalgaPROD.dbo.gl_acct_code gac on ard.gl_acct_code_credit_id = gac.gl_acct_code_id
						inner JOIN [DBPROD03].AmalgaPROD.dbo.item i on ard.item_id = i.item_id
						inner JOIN [DBPROD03].AmalgaPROD.dbo.item_group_costcentre_nl_view igc on i.item_group_id = igc.item_group_id 
						inner JOIN [DBPROD03].AmalgaPROD.dbo.costcentre_nl_view cc on igc.costcentre_id = cc.costcentre_id
						INNER JOIN [DBPROD03].AmalgaPROD.dbo.swe_payment_status_ref spsr ON ar.swe_payment_status_rcd = spsr.swe_payment_status_rcd
						INNER JOIN [DBPROD03].AmalgaPROD.dbo.transaction_status_ref tsr ON ar.transaction_status_rcd = tsr.transaction_status_rcd
						INNER JOIN [DBPROD03].AmalgaPROD.dbo.system_transaction_type_ref sttr ON ar.system_transaction_type_rcd = sttr.system_transaction_type_rcd
					
						INNER JOIN [DBPROD03].HISViews.dbo.patient_visit_vw pv ON cd.patient_visit_id = pv.patient_visit_id
						INNER JOIN [DBPROD03].AmalgaPROD.dbo.patient_hospital_usage phu ON pv.patient_id = phu.patient_id
						INNER JOIN [DBPROD03].AmalgaPROD.dbo.person_formatted_name_iview pfn ON pv.patient_id = pfn.person_id
						INNER JOIN [DBPROD03].AmalgaPROD.dbo.visit_type_ref vtr ON pv.visit_type_rcd = vtr.visit_type_rcd
						INNER JOIN [DBPROD03].AmalgaPROD.dbo.item_type_ref itr ON i.item_type_rcd = itr.item_type_rcd
						LEFT OUTER JOIN [DBPROD03].AmalgaPROD.dbo.uom_ref as ur ON ard.uom_rcd = ur.uom_rcd
						LEFT OUTER JOIN itworksds01.dis.dbo.payment_period_detail_history ppdh on ard.ar_invoice_detail_id = ppdh.ar_invoice_detail_id 
						left OUTER JOIN itworksds01.dis.dbo.df_browse_all df ON ppdh.charge_id = df.charge_id
						left outer JOIN itworksds01.dis.dbo.charge_detail cd2 ON df.charge_id = cd2.charge_id

			where --MONTH(ar.transaction_date_time) = 1
						--and YEAR(ar.transaction_date_time) = 2017
						--ar.transaction_date_time between @From and @To
						ar.transaction_date_time between '1/1/2018 00:00:00' and '1/1/2018 23:59:59'
			and ar.transaction_status_rcd not in ('voi','unk')
			and gac.gl_acct_code_code = '4264000'
			and i.item_type_rcd = 'srv'
			and i.sub_item_type_rcd = 'drfee'
			and ard.gross_amount > 0
			 and df.charge_id not in (select charge_id from itworksds01.dis.dbo.payment_period_detail_history) --UNPAID
			--and ard.item_id = cd.item_id
			--AND cd.deleted_date_time IS NULL

--) as temp
--GROUP by temp.costcentre_code,
-- temp.costcentre
--order by temp.costcentre_code

