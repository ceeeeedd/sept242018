

SELECT 
			temp.vendor_invoice_date_time as [Vendor Invoice Date and Time]
			,temp.[Vendor Invoice Time]
			--,temp.created_on_date_time as [Created on Date and Time]
			--,temp.effective_date as [Effective Date and Time]
			,temp.vendor_code as [Vendor Code]
			,temp.vendor_name as [Vendor Name]
			,temp.tax_number as [Tax Number]
			,address as [Address]
			,temp.tel_no  as [Business Phone No.]
			,temp.fax_no as [Fax No.]
			,temp.contact_person as [Contact Person]
			,temp.email_address as [Email Address]
			,temp.system_transaction_type as [System Transaction Type]
			,temp.transaction_status as [Transaction Status]
			,temp.payment_status as [Payment Status]
			,temp.vendor_invoice_no as [Vendor Invoice No.]
			,temp.item_costcentre_code as [Costcentre Code]
			,temp.item_costcentre as [Costcentre]
			,temp.item_gl_account_code as [GL Account Code]
			,temp.item_gl_account as [GL Account]
			,temp.item_type as [Item Type]
			,temp.sub_item_type as [Sub Item Type]
			,temp.item_code as [Item Code]
			,temp.item as [Item]
			,temp.uom_rcd as [UOM]
			,temp.quantity as [Quantity]
			,temp.unit_price as [Unit Price]
			,temp.gross_amt_from_ap_transaction_detail as [Gross Amount]
			,temp.net_amt_from_ap_transaction_detail as [Net Amount]
			,temp.discount_amt_from_ap_transaction_detail as [Discount Amount]
			,temp.discount_percentage as [Discount Percentage]
			,temp.tax_amt_from_ap_transaction_detail as [Tax Amount]
			,temp.wth_tax_amt_from_ap_transaction_detail as [Withholding Tax Amount]
			,temp.tax_code as [Tax Code]
			,temp.tax_code_name as [Tax Code Name]
			,temp.tax_percentage as [Tax Percentage]
			,temp.withholding_tax_code as [Withholding Tax Code]
			,temp.withholding_tax_code_name as [Withholding Tax Name]
			,temp.withholding_tax_percentage as [Withholding Tax Percentage]


FROM
(
				SELECT DISTINCT
							sat.ap_invoice_id
							,satd.ap_invoice_detail_id
							,sat.vendor_id
							,sat.costcentre_credit_id
							,sat.gl_acct_code_credit_id
							,sat.rounding_costcentre_id
							,sat.rounding_gl_acct_code_id
							,sat.ap_payment_type_rid
							,sat.gl_transaction_id
							,sat.user_transaction_type_id
							,sat.transaction_text
							,sat.transaction_nr
							,sat.system_transaction_type_rcd
							,sttr.name_l as system_transaction_type
							,sat.transaction_status_rcd
							,tsr.name_l as transaction_status
							,sat.currency_rcd
							,sat.currency_rate
							,sat.swe_payment_status_rcd
							,spsr.name_l as payment_status
							,sat.vendor_invoice_no
							,sat.vendor_invoice_date_time
							,format(sat.vendor_invoice_date_time,'hh:mm tt') as [Vendor Invoice Time]
							,sat.created_on_date_time
							,sat.effective_date
							,sat.gross_amount
							,sat.net_amount
							,sat.tax_amount
							,sat.wth_tax_amount
							,sat.discount_amount
							,sat.owing_amount
							,sat.book_gross_amount
							,sat.book_rounding_amount
							,sat.book_discount_amount
							,sat.book_tax_amount
							,sat.book_net_amount
							,sat.debit_factor

							,satd.item_id
							,satd.costcentre_debit_id
							,satd.gl_acct_code_debit_id
							,satd.purchase_order_detail_id
							,satd.purchase_distribute_detail_id
							,satd.item_gl_acct_code_debit_id
							,satd.item_costcentre_debit_id
							,satd.detail_num
							,satd.uom_rcd
							,satd.gross_amount as gross_amt_from_ap_transaction_detail
							,satd.tax_amount as tax_amt_from_ap_transaction_detail
							,satd.wth_tax_amount as wth_tax_amt_from_ap_transaction_detail
							,satd.discount_amount as discount_amt_from_ap_transaction_detail
							--,CAST(satd.unit_price as DECIMAL(10,2)) as unit_price
							,satd.unit_price
							,satd.quantity
							,satd.discount_percentage
							,satd.book_received_amount
							,satd.include_vat_in_item_cost_flag
							,satd.costcentre_origin_rcd
							,satd.gl_account_origin_rcd

							,utt.name_l as user_transaction_type
							,i.item_code
							,i.name_l as item
							,i.item_type_rcd
							,i.sub_item_type_rcd
							,itr.name_l as item_type
							,sitr.name_l as sub_item_type
							,cc.name_l as item_costcentre
							,cc.costcentre_code as item_costcentre_code
							,gl.gl_acct_code_code as item_gl_account_code
							,gl.name_l as item_gl_account
							,((satd.gross_amount - satd.discount_amount) + satd.tax_amount) as  net_amt_from_ap_transaction_detail

							,(SELECT tax_code_rcd from ap_tax_detail where tax_rule_rcd = 'VAT'
										AND ap_invoice_detail_id = satd.ap_invoice_detail_id )as tax_code
							,(SELECT tax_percentage from ap_tax_detail where tax_rule_rcd = 'VAT'
										AND ap_invoice_detail_id = satd.ap_invoice_detail_id )as tax_percentage
							,(SELECT tax_code_rcd from ap_tax_detail where tax_rule_rcd = 'WTH'
										AND ap_invoice_detail_id = satd.ap_invoice_detail_id )as withholding_tax_code
							,(SELECT tax_percentage from ap_tax_detail where tax_rule_rcd = 'WTH'
										AND ap_invoice_detail_id = satd.ap_invoice_detail_id )as withholding_tax_percentage
			
							,(SELECT name_l from tax_code_ref where tax_code_rcd = 
									(SELECT top 1 tax_code_rcd from ap_tax_detail where tax_rule_rcd =  'VAT'
										AND ap_invoice_detail_id = satd.ap_invoice_detail_id))as tax_code_name

							,(SELECT name_l from tax_code_ref where tax_code_rcd = 
									(SELECT top 1 tax_code_rcd from ap_tax_detail where tax_rule_rcd =  'WTH'
										AND ap_invoice_detail_id = satd.ap_invoice_detail_id))as withholding_tax_code_name

							--,v.vendor_id
							,v.vendor_code
							,CASE WHEN v.person_id IS NOT NULL THEN
									(SELECT display_name_l from person_formatted_name_iview where person_id = v.person_id)
								ELSE (SELECT name_l from organisation where organisation_id = v.organisation_id) END as vendor_name

							,(SELECT tax_number from organisation where organisation_id = v.organisation_id)as tax_number

							,v.person_id
							,v.organisation_id

							,CASE WHEN v.person_id IS NOT NULL THEN
									(SELECT address_line_1_l + ' ' + address_line_2_l + ' ' + address_line_3_l FROM address where address_id =
										(SELECT top 1 address_id from person_address where effective_until_date IS NULL AND person_address_type_rcd = 'H1'
											AND person_id = v.person_id))
							   ELSE (SELECT address_line_1_l + ' ' + address_line_2_l + ' ' + address_line_3_l FROM address where address_id =
											(SELECT top 1 address_id from organisation_address where  effective_until_date IS NULL AND organisation_address_type_rcd = 'B1' 
											AND organisation_id = v.organisation_id ))END as address

							--,v.vendor_description
							--,v.vendor_email
							--,v.vendor_tax_category_rcd

								,CASE WHEN v.person_id IS NOT NULL THEN 
									(SELECT phone_number from phone where phone_id = 
										(SELECT top 1 phone_id from person_phone
												 where person_id = v.person_id
															AND person_phone_type_rcd = 'B1'
															AND effective_until_date is NULL))
								ELSE (SELECT phone_number from phone where phone_id = 
											(SELECT top 1 phone_id from organisation_phone
													 where organisation_id = v.organisation_id
																AND organisation_phone_type_rcd = 'B1'
																AND effective_until_date is NULL)) end as tel_no

							,CASE WHEN v.person_id IS NOT NULL THEN 
									(SELECT phone_number from phone where phone_id = 
										(SELECT top 1 phone_id from person_phone
												 where person_id = v.person_id
															AND person_phone_type_rcd = 'F1'
															AND effective_until_date is NULL))
									ELSE (SELECT phone_number from phone where phone_id = 
												(SELECT top 1 phone_id from organisation_phone
														 where organisation_id = v.organisation_id
																	AND organisation_phone_type_rcd = 'F1'
																	AND effective_until_date is NULL)) end as fax_no

							,(SELECT display_name_l from person_formatted_name_iview where person_id = 
									(SELECT top 1 organisation_contact_id from organisation_contact where organisation_id = v.organisation_id))as contact_person

							,(SELECT email_address from email where person_id = 
									(SELECT top 1 organisation_contact_id from organisation_contact where organisation_id = v.organisation_id))as email_address

							--,atd.*
							--,*


				FROM swe_ap_transaction sat
							INNER JOIN swe_ap_transaction_detail satd ON sat.ap_invoice_id = satd.ap_invoice_id
							INNER JOIN item i ON satd.item_id = i.item_id
							INNER JOIN item_type_ref itr ON i.item_type_rcd = itr.item_type_rcd
							INNER JOIN sub_item_type_ref sitr ON i.sub_item_type_rcd = sitr.sub_item_type_rcd
							INNER JOIN costcentre cc ON satd.item_costcentre_debit_id = cc.costcentre_id
							INNER JOIN gl_acct_code gl ON satd.item_gl_acct_code_debit_id = gl.gl_acct_code_id

							INNER JOIN user_transaction_type utt ON sat.user_transaction_type_id = utt.user_transaction_type_id
							INNER JOIN transaction_status_ref tsr ON sat.transaction_status_rcd = tsr.transaction_status_rcd
							INNER JOIN swe_payment_status_ref spsr ON sat.swe_payment_status_rcd = spsr.swe_payment_status_rcd
							INNER JOIN system_transaction_type_ref sttr ON sat.system_transaction_type_rcd = sttr.system_transaction_type_rcd

							--INNER JOIN ap_tax_detail atd ON satd.ap_invoice_detail_id = atd.ap_invoice_detail_id
							--INNER JOIN tax_code_ref tcr ON atd.tax_code_rcd = tcr.tax_code_rcd

							INNER JOIN vendor v ON sat.vendor_id = v.vendor_id
			

				WHERE
						v.active_flag = 1
						AND sat.swe_payment_status_rcd NOT IN ('VOI', 'UNK')
						AND sat.transaction_status_rcd NOT IN ('VOI', 'UNK')
						--AND sat.vendor_id = '846D719B-096F-11DA-A79C-001143B8816C' --AND sat.transaction_text = 'IAP-2016-010003'
						
						and year(sat.vendor_invoice_date_time) between @Start_Year and @End_Year
)as temp

order by temp.vendor_invoice_date_time	