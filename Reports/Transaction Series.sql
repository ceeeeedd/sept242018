--TRANSACTION SERIES
-- change aliases 

DECLARE @year VARCHAR(100)

SET @year = @FromYear --2003 --today
--SET @date1 = '2011-01-01 00:00:00.000'
--SET @date2 = '2011-12-31 23:59:59.998'

--INVOICE
--select top 100 * from ar_invoice
SELECT 
	DISTINCT 'AR Invoice', b.user_transaction_type_code as ar_transaction_type_code, b.name_l as ar_name_l, min(transaction_nr) as ar_min_tran_nr, max(transaction_nr) as ar_max_tran_nr, MIN(transaction_text) as min_ar_transaction_text, MAX(transaction_text) as max_ar_transaction_text
FROM
	ar_invoice a, user_transaction_type b
WHERE
	a.user_transaction_type_id = b.user_transaction_type_id AND
	transaction_text like '%'+'-'+ @year +'-' + '%'
	--and transaction_text in (@YEARS)
GROUP BY
	b.user_transaction_type_code, b.name_l

	
UNION ALL
--select top 100 * from remittance
--REMITTANCE
SELECT 
	DISTINCT 'Remittance', d.user_transaction_type_code as r_transaction_type_code, d.name_l as r_name_l, min(transaction_nr) as r_min_tran_nr, max(transaction_nr) as r_max_tran_nr, MIN(transaction_text) as min_r_transaction_text, MAX(transaction_text) as max_r_transaction_text
FROM
	remittance c, user_transaction_type d
WHERE
	c.user_transaction_type_id = d.user_transaction_type_id AND
	transaction_text like '%'+'-'+ @year +'-' + '%'
	--and transaction_text in (@YEARS)
GROUP BY
	d.user_transaction_type_code, d.name_l

UNION ALL
	--select top 100 * from swe_ap_transaction
--AP-INVOICE
SELECT 
	DISTINCT 'SWE AP Transaction', f.user_transaction_type_code as ap_transaction_type_code, f.name_l as ap_name_l, min(transaction_nr) as ap_min_tran_nr, max(transaction_nr) as ap_max_tran_nr, MIN(transaction_text) as min_ap_transaction_text, MAX(transaction_text) as max_ap_transaction_text
fROM 
	swe_ap_transaction e, user_Transaction_type f
WHERE 
	e.user_transaction_type_id = f.user_transaction_type_id AND
	transaction_text like '%'+'-'+ @year +'-' + '%'
	--and transaction_text in (@YEARS)
GROUP BY
	f.user_transaction_type_code, f.name_l
	 
UNION ALL
	--select top 100 * from ap_payment
--AP-PAYMENT
SELECT
	DISTINCT 'AP Payment', h.user_transaction_type_code as pay_transaction_type_code, h.name_l as pay_name_l, min(transaction_nr) as pay_min_tran_nr, max(transaction_nr) as pay_max_tran_nr, MIN(transaction_text), MAX(transaction_text) as max_pay_transaction_text
FROM
	ap_payment g, user_Transaction_type h
WHERE
	g.user_transaction_type_id = h.user_transaction_type_id AND
	transaction_text like '%'+'-'+ @year +'-' + '%'
	--and transaction_text in (@YEARS)
GROUP BY
	h.user_transaction_type_code, h.name_l

UNION ALL
	--select top 100 * from bank_deposit
--BANK DEPOSIT
SELECT
	DISTINCT 'Bank Deposit', j.user_transaction_type_code as bd_transaction_type_code, j.name_l as bd_name_l, min(transaction_nr) as spd_min_tran_nr, max(transaction_nr) as spd_max_tran_nr, MIN(transaction_text) as min_spd_transaction_text, MAX(transaction_text) as max_spd_transaction_text
FROM
	bank_deposit i, user_transaction_type j
WHERE
	i.user_transaction_type_id = j.user_transaction_type_id AND
	transaction_text like '%'+'-'+ @year +'-' + '%'
	--and transaction_text in (@YEARS)
GROUP BY
	j.user_transaction_type_code, j.name_l

UNION ALL
	--select top 100 * from swe_purchase_order
--PURCHASE ORDER
SELECT 
	DISTINCT 'SWE Purchase Order', l.user_transaction_type_code as spo_transaction_type_code, l.name_l as spo_name_l, min(transaction_nr) as spd_min_tran_nr, max(transaction_nr) as spd_max_tran_nr, MIN(transaction_text) as min_spd_transaction_text, MAX(transaction_text) as max_spd_transaction_text
FROM 
	SWE_purchase_order k, user_transaction_type l
WHERE
	k.user_transaction_type_id = l.user_transaction_type_id AND	
	transaction_text like '%'+'-'+ @year +'-' + '%'
	--and transaction_text in (@YEARS)
GROUP BY
	l.user_transaction_type_code, l.name_l

UNION ALL
	--select top 100 * from swe_purchase_distribute
--PURCHASE DISTRIBUTE
SELECT 
	DISTINCT 'SWE Purchase Distribute', n.user_transaction_type_code as spd_transaction_type_code, n.name_l as spd_name_l, min(transaction_nr) as spd_min_tran_nr, max(transaction_nr) as spd_max_tran_nr, MIN(transaction_text) as min_spd_transaction_text, MAX(transaction_text) as max_spd_transaction_text
FROM
	swe_purchase_distribute m, user_transaction_type n
WHERE
	m.user_transaction_type_id = n.user_transaction_type_id AND
	transaction_text like '%'+'-'+ @year +'-' + '%'
	--and transaction_text in (@YEARS)
GROUP BY
	n.user_transaction_type_code, n.name_l

UNION ALL
	--select top 100 * from swe_purchase_receive
--PURCHASE_RECEIVE
SELECT 
	DISTINCT 'SWE Purchase Receive', p.user_transaction_type_code as spr_transaction_type_code, p.name_l spr_name_l, min(transaction_nr) as spr_min_tran_nr, max(transaction_nr) as spr_max_tran_nr, MIN(transaction_text) as min_spr_transaction_text, MAX(transaction_text) as max_spr_transaction_text
FROM 
	SWE_purchase_receive o, user_Transaction_type p
WHERE
	o.user_transaction_type_id = p.user_transaction_type_id AND
	transaction_text like '%'+'-'+ @year +'-' + '%'
	--and transaction_text in (@YEARS)
GROUP BY
	p.user_transaction_type_code, p.name_l

UNION ALL
--select top 100 * from swe_purchase request
--PURCHASE REQUEST
SELECT 
	DISTINCT 'SWE Purchase Request', r.user_transaction_type_code as swp_transaction_type_code, r.name_l as swp_name_l, min(transaction_nr) as swp_min_tran_nr, max(transaction_nr) as swp_max_tran_nr, MIN(transaction_text) as min_swp_transaction_text, MAX(transaction_text) as max_swp_transaction_text
FROM 
	SWE_purchase_request q, user_transaction_type r, swe_purchase_request_detail s
WHERE
	q.user_transaction_type_id = r.user_transaction_type_id AND
	q.purchase_request_id = s.purchase_request_id AND
	transaction_text like '%'+'-'+ @year +'-' + '%'
	--and transaction_text in (@YEARS)
	--a.lu_updated between '2006-01-01 00:00:00.000' and '2006-12-31 23:59:59.998'
GROUP BY
	r.user_transaction_type_code, r.name_l

UNION ALL
	--select top 100 * from swe_purchase_return
--PURCHASE RETURN
SELECT 
	DISTINCT 'Purchase Return', u.user_transaction_type_code as pr_transaction_type_code, u.name_l as pr_name_l, min(transaction_nr) as pr_min_tran_nr, max(transaction_nr) as pr_max_tran_nr, MIN(transaction_text) as min_pr_transaction_text, MAX(transaction_text) as max_pr_transaction_text
FROM
	swe_purchase_return t, user_transaction_type u
WHERE 
	t.user_transaction_type_id = u.user_transaction_type_id AND
	transaction_text like '%'+'-'+ @year +'-' + '%'
	--and transaction_text in (@YEARS)
GROUP BY
	u.user_transaction_type_code, u.name_l

UNION ALL
		--select top 100 * from asset_addition
--ASSET ADDITION
SELECT 
	DISTINCT 'Asset Addition', w.user_transaction_type_code as aa_transaction_type_code, w.name_l as aa_name_l, min(transaction_nr) as aa_min_tran_nr, max(transaction_nr) as aa_max_tran_nr, MIN(transaction_text) as min_aa_transaction_text, MAX(transaction_text) as max_aa_transaction_text
FROM
	asset_addition v, user_transaction_type w
WHERE 
	v.user_transaction_type_id = w.user_transaction_type_id AND
	transaction_text like '%'+'-'+ @year +'-' + '%'
	--and transaction_text in (@YEARS)
GROUP BY
	w.user_transaction_type_code, w.name_l

UNION ALL
	--select top 100 * from asset_depreciation_run
--ASSET DEPRECIATION RUN
SELECT 
	DISTINCT 'Asset Depreciation Run', y.user_transaction_type_code as adr_transaction_type_code, y.name_l as adr_name_l, min(transaction_nr) as adr_min_tran_nr, max(transaction_nr) as adr_max_tran_nr, MIN(transaction_text) as min_adr_transaction_text , MAX(transaction_text) as max_adr_transaction_text
FROM
	asset_depreciation_run x, user_transaction_type y
WHERE 
	x.user_transaction_type_id = y.user_transaction_type_id AND
	transaction_text like '%'+'-'+ @year +'-' + '%'
	--and transaction_text in (@YEARS)
GROUP BY
	y.user_transaction_type_code, y.name_l

UNION ALL
	--select top 100 * from asset_retirement
--ASSET RETIREMENT
SELECT 
	DISTINCT 'Asset Retirement',aa.user_transaction_type_code as asr_transaction_type_code, aa.name_l as asr_name_l, min(transaction_nr) as asr_min_tran_nr, max(transaction_nr) as asr_max_tran_nr, MIN(transaction_text) as min_asr_transaction_text, MAX(transaction_text) as max_asr_transaction_text
FROM
	asset_retirement z, user_transaction_type aa
WHERE 
	z.user_transaction_type_id = aa.user_transaction_type_id AND
	transaction_text like '%'+'-'+ @year +'-' + '%'
	--and transaction_text in (@YEARS)
GROUP BY
	aa.user_transaction_type_code, aa.name_l

UNION ALL
	--select top 100 * from asset_transfer
--ASSET TRANSFER
SELECT 
	DISTINCT 'Asset Transfer', cc.user_transaction_type_code as at_transaction_type_code, cc.name_l as at_name_l, min(transaction_nr) as at_min_tran_nr, max(transaction_nr) as at_max_tran_nr, MIN(transaction_text) as min_at_transaction_text, MAX(transaction_text) as max_at_transaction_text
FROM
	asset_transfer bb, user_transaction_type cc
WHERE 
	bb.user_transaction_type_id = cc.user_transaction_type_id AND
	transaction_text like '%'+'-'+ @year +'-' + '%'
	--and transaction_text in (@YEARS)
GROUP BY
	cc.user_transaction_type_code, cc.name_l

UNION ALL
	--select top 100 * from gl_transaction
--GL TRANSACTION	
SELECT 
	DISTINCT 'GL Transaction', ee.user_transaction_type_code as glt_transaction_type_code, ee.name_l as glt_name_l, min(transaction_nr) as glt_min_tran_nr, max(transaction_nr) as glt_max_tran_nr, MIN(transaction_text) as min_glt_transaction_text , MAX(transaction_text) as max_glt_transaction_text
FROM
	gl_transaction dd, user_transaction_type ee
WHERE 
	dd.user_transaction_type_id = ee.user_transaction_type_id AND
	transaction_text like '%'+'-'+ @year +'-' + '%'
	--and transaction_text in (@YEARS)
GROUP BY
	ee.user_transaction_type_code, ee.name_l