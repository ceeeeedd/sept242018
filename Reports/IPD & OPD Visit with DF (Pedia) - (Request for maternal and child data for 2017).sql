--336357
--323458	not voided and unknown
--323457	join patient_visit
--58374		filter all pedia patients
--48164		OPD
--IPD & OPD Visit with DF (Pedia) - (Request for maternal and child data for 2017)


SELECT 
			temp.visit_code as [Visit Code]
			,temp.hn as [HN]
			,temp.patient_name as [Patient Name]
			,temp.policy_name as [Policy]
			,temp.invoice_no as [Invoice No]
			,temp.visit_type as [Visit Type]
			,temp.visit_type_group_rcd as [Visit Type Group]
			,temp.[Transaction Date]
			,temp.[Transaction Time]
			,temp.[Discharge Date]
			,temp.[Discharge Time]
			,temp.[Date of Birth]
			,temp.age as [Age]
			,temp.payment_status as [Payment Status]
			,temp.transaction_status as [Transaction Status]

			,temp.[Gross Amount]
			,temp.[Discount Amount]
			,temp.[Net Amount]

			,temp.gross_df as [Gross DF]
			,temp.discount_df as [Discount DF]
			,temp.net_df as [Net DF]

			,temp.gross_hb as [Gross HB]
			,temp.discount_hb as [Discount HB]
			,temp.net_hb as [Net HB]

			,temp.gross_pf as [Gross PF]
			,temp.discount_pf as [Discount PF]
			,temp.net_pf as [Net PF]

			,temp.philhealth as [Philhealth]
			,temp.philhealth_pf as [Philhealth PF]

			,temp.gross_er_pf as [Gross ER PF]
			,temp.discount_er_pf as [Discount ER PF]
			,temp.net_er_pf as [Net ER PF]

			,temp.diagnosis as [Diagnosis]
			,temp.service_requestor as [Service Requestor]



FROM
(
			SELECT DISTINCT
						ipf.hn
						,ipf.patient_name
						,ipf.policy_name
						,ipf.invoice_no
						,ipf.visit_type
						,vtr.visit_type_group_rcd
						,cast(ar.transaction_date_time as date) as [Transaction Date]
						,cast(ipf.discharge_date_time as date) as [Discharge Date]
						,format(ar.transaction_date_time,'hh:mm tt') as [Transaction Time]
						,format(ipf.discharge_date_time,'hh:mm tt') as [Discharge Time]
						,cast(pfn.date_of_birth as date) as [Date of Birth]
						,DATEDIFF(dd,pfn.date_of_birth,GETDATE()) / 365 as age
						,spsr.name_l as payment_status
						,tsr.name_l as transaction_status
						,cast(ar.gross_amount as decimal(10,2)) as [Gross Amount]
						,cast(ar.discount_amount as decimal(10,2)) as [Discount Amount]
						,cast(ar.net_amount as decimal(10,2)) as [Net Amount]

						,ipf.gross_df
						,ipf.discount_df
						,ipf.net_df

						,ipf.gross_hb
						,ipf.discount_hb
						,ipf.net_hb

						,ipf.gross_pf
						,ipf.discount_pf
						,ipf.net_pf

						,ipf.philhealth
						,ipf.philhealth_pf

						,ipf.gross_er_pf
						,ipf.discount_er_pf
						,ipf.net_er_pf

						,pv.visit_code
						,pd.diagnosis
						,(SELECT name_l from department_info_view where department_id = 
							(SELECT top 1 department_id from costcentre_department where service_requester_flag = 1 AND costcentre_id =
									(SELECT top 1 service_requester_costcentre_id from charge_detail where charge_detail_id =
										(SELECT top 1 charge_detail_id from ar_invoice_detail where ar_invoice_id = ipf.invoice_id))))as service_requestor
			
						--,ipf.patient_visit_id
						,ipf.patient_id

						,ar.transaction_text
						,ar.system_transaction_type_rcd
						,cd.patient_visit_id

			FROM ar_invoice ar
								LEFT OUTER JOIN HISReport.dbo.rpt_invoice_pf ipf ON ar.ar_invoice_id = ipf.invoice_id
								LEFT OUTER JOIN person_formatted_name_iview pfn ON ipf.patient_id = pfn.person_id
								LEFT OUTER JOIN visit_type_ref vtr ON ar.visit_type_rcd = vtr.visit_type_rcd
								LEFT OUTER JOIN swe_payment_status_ref spsr ON ar.swe_payment_status_rcd = spsr.swe_payment_status_rcd
								LEFT OUTER JOIN transaction_status_ref tsr ON ar.transaction_status_rcd = tsr.transaction_status_rcd

								LEFT OUTER JOIN ar_invoice_detail ard ON ar.ar_invoice_id = ard.ar_invoice_id
								LEFT OUTER JOIN charge_detail cd ON ard.charge_detail_id = cd.charge_detail_id
								LEFT OUTER JOIN patient_visit pv ON cd.patient_visit_id = pv.patient_visit_id
					
								LEFT OUTER JOIN HISViews.dbo.GEN_vw_patient_diagnosis pd ON cd.patient_visit_id = pd.patient_visit_id AND pd.primary_flag = 1 AND pd.current_visit_diagnosis_flag = 1

			WHERE	ar.transaction_date_time BETWEEN '06/01/2018 00:00:00:000' AND '06/02/2018 23:59:59:998'
					--ar.transaction_date_time BETWEEN @From AND @To
					and ar.transaction_status_rcd not in  ('unk','voi')
					--AND ar.visit_type_rcd NOT IN ('V1', 'V2')	--OPD
					--AND ar.visit_type_rcd IN ('V1', 'V2')			--IPD
					AND vtr.visit_type_group_rcd IN ('IPD', 'OPD')
					AND pv.cancelled_date_time IS NULL
					--AND (pd.primary_flag = 1 AND pd.current_visit_diagnosis_flag = 1)


) as temp

where temp.age <= 18


ORDER BY temp.patient_name 