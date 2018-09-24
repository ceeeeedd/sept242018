SELECT DISTINCT SPR.transaction_text as [Transaction No.],
				SPR.received_on_date as [Received On Date],
				--SPR.swe_purchase_status_rcd,
				SPSR.name_l as [Status],
				V.vendor_code as [Vendor Code],
				(CASE WHEN v.person_id IS NOT NULL THEN 
																	(SELECT
																		display_name_l
																	FROM person_formatted_name_view
																	WHERE person_id = v.person_id)
																	ELSE (SELECT
																				name_l
																		  FROM organisation
																		  WHERE organisation_id = v.organisation_id)
																	END)as [Vendor Name],
				SPR.vendor_invoice_no as [Vendor Invoice No.],
				SPR.vendor_invoice_date as [Vendor Invoice Date],
				SPO.transaction_text as [Purchase Order No.],
				SVI.vendor_item_code as [Vendor Item Code],
				SVI.vendor_item_name_l as [Vendor Item Name],
				SPRD.uom_rcd as [UOM],
				SVIU.conversion_factor as [Conversion Factor],
				SPOD.pending_qty as [Pending Qty],
				SPRD.received_qty as [Received Qty],
				SPRD.accepted_qty as [Accepted Qty],
				SPRD.returned_qty as [Returned Qty],
				SPOD.promised_on_date as [New Promised On Date],
				SPRD.unit_price as [Unit Price],
				SPRD.gross_amount as [Gross Amount],
				(SELECT CASE WHEN SPRD.gross_amount = 0 THEN NULL
								ELSE (SPRD.discount_amount / SPRD.gross_amount) * 100 END) AS [Discount %],
				--discount_percent = (SPRD.discount_amount / SPRD.gross_amount) * 100,
				SPRD.discount_amount as [Discount Amount],
				SPRD.tax_amount as [Tax Amount],
				SPRD.book_net_amount as [Net Amount]



FROM swe_purchase_receive AS SPR
				LEFT OUTER JOIN swe_purchase_receive_detail AS SPRD ON SPR.purchase_receive_id = SPRD.purchase_receive_id
				LEFT OUTER JOIN vendor AS V ON SPR.vendor_id = V.vendor_id
				LEFT OUTER JOIN swe_vendor_item AS SVI ON SPRD.vendor_item_id = SVI.vendor_item_id
				LEFT OUTER JOIN swe_purchase_order_detail AS SPOD ON SPRD.purchase_order_detail_id = SPOD.purchase_order_detail_id
				LEFT OUTER JOIN swe_purchase_order AS SPO ON SPOD.purchase_order_id = SPO.purchase_order_id
				INNER JOIN swe_purchase_status_ref AS SPSR ON SPR.swe_purchase_status_rcd = SPSR.swe_purchase_status_rcd
				LEFT OUTER JOIN swe_vendor_item_uom AS SVIU ON SVI.vendor_item_id = SVIU.vendor_item_id


WHERE month(SPR.received_on_date) between @From and @To
	and year(SPR.received_on_date) = @year
	--month(SPR.received_on_date) = 7
	--and year(SPR.received_on_date) = 2018
				  --SPR.received_on_date BETWEEN  '07/01/2018 00:00:00:000' and '07/31/2018 23:59:59:998'
				--AND SPR.swe_purchase_site_id = '2198E881-0E1D-11DA-A79E-001143B8816C'		--For Pharmacy Purchasing
				--AND SPR.swe_purchase_site_id = '31488C46-FDB0-11D9-A79B-001143B8816C'		--For Central Purchasing
				AND spr.swe_purchase_site_id = 'E843EC8F-3399-11E7-9BAA-78E3B58FE3DB'			--NPO Purchasing
				
				--AND spr.transaction_text = 'RRC-2016-021510'
				--AND spr.transaction_text = 'RRP-2016-008373'
				AND SPR.swe_purchase_status_rcd <> 'voi'

ORDER BY SPR.received_on_date ASC

