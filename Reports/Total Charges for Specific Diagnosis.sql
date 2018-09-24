--total charges for specific diagnosis
-- 01/01/2010 to 07/09/2018
SELECT  distinct inv.invoice_no as [Invoice No.],
	   inv.transaction_date_time as [Transaction Date and Time],
	   format(inv.transaction_date_time,'hh:mm tt') as [Transaction Time],
	   inv.hn as [Hospital Number],
	   inv.patient_name as [Patient Name],
	   inv.visit_type as [Visit Type],
	   cse.code as [Code],
	   cse.description as [Description],
	   dtr.name_l as [Diagnosis Type],
	   ctr.name_l as  [Coding Type],
	   gross_hb + (philhealth + inv.philhealth_pf) as [Gross Hospital Bill Amount],
	   discount_hb as [Discount Hospital Bill Amount] ,
	   (gross_hb + (philhealth + inv.philhealth_pf)) - discount_hb as [Net Hospital Bill Amount],
	   gross_df + gross_pf + gross_er_pf as [Gross PF Amount],
	   discount_df + discount_pf + discount_er_pf as [Discount PF Amount],
	   (gross_df + gross_pf + gross_er_pf) - (discount_df + discount_pf + discount_er_pf) as [Net PF Amount],
	   total_amt as [Total Amount],
	   inv.ar_net_amt as [Net Amount]
from HISReport.dbo.rpt_invoice_pf inv inner join HISReport.dbo.rpt_invoice_pf_detailed invd on inv.invoice_id = invd.invoice_id
								      INNER JOIN patient_visit_diagnosis_view pvdv on invd.patient_visit_id = pvdv.patient_visit_id
									  inner JOIN coding_system_element_description_nl_view cse on pvdv.code = cse.code
								      inner JOIN ar_invoice ar on inv.invoice_id = ar.ar_invoice_id
									  inner JOIN diagnosis_type_ref dtr on pvdv.diagnosis_type_rcd = dtr.diagnosis_type_rcd
									  inner JOIN coding_type_ref ctr on pvdv.coding_type_rcd = ctr.coding_type_rcd
									  inner JOIN charge_detail cd on invd.charge_detail_id = cd.charge_detail_id
where --inv.invoice_no = 'PINV-2017-226927'
  pvdv.active_flag = 1
    and pvdv.diagnosis_type_rcd in ('dis','adm')
	and pvdv.coding_type_rcd = 'PRI'
	and ar.user_transaction_type_id = 'F8EF2162-3311-11DA-BB34-000E0C7F3ED2'
	and  cse.code in ('j10','j11','j12','j13','j14','j15','j16','j17','j18','n30','N11.0','N11.1')
	and ar.visit_type_rcd in ('v1','v4')
	and pvdv.current_visit_diagnosis_flag = 1
	 --and CAST(CONVERT(VARCHAR(10),inv.transaction_date_time,101) as SMALLDATETIME) >= CAST(CONVERT(VARCHAR(10),'01/01/2010',101) as SMALLDATETIME)
	--and CAST(CONVERT(VARCHAR(10),inv.transaction_date_time,101) as SMALLDATETIME) <= CAST(CONVERT(VARCHAR(10),'07/09/2018',101) as SMALLDATETIME)
and dtr.name_l in (@Diagnosis_Type)
and inv.transaction_date_time between @From and @To
order by inv.transaction_date_time