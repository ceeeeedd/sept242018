--38841
--3177 filtered OB (IPD)
--Obstetrics and Gynecology (IPD) - (Request for maternal and child data for 2017)


SELECT 
			temp.visit_code as [Visit Code]
			,temp.hn as [HN]
			,temp.patient_name as [Patient Name]
			,temp.gender as [Gender]
			,temp.nationality as [Nationality]
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
			,temp.country_of_residence as [Country of Residence]
			--,temp.postcode as [Postcode]
			,temp.group_code as [Group Code]
			,temp.code as [Code]
			,temp.payment_status as [Payment Status]
			,temp.transaction_status as [Transaction Status]

			,temp.gross_amount as [Gross Amount]
			,temp.discount_amount as [Discount Amount]
			,temp.net_amount as [Net Amount]

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

			,temp.coding_system_rcd as [Coding System]
			,temp.coding_type as [Coding Type]
			,temp.admitting_doctor as [Admitting Doctor]
			,temp.specialty as [Specialty]
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
						,ar.gross_amount
						,ar.discount_amount
						,ar.net_amount

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

						,pd.code
						,pd.coding_system_rcd
						,pd.coding_type
						,pv.visit_code
						,pd.diagnosis
						,(SELECT name_l from department_info_view where department_id = 
							(SELECT top 1 department_id from costcentre_department where service_requester_flag = 1 AND costcentre_id =
									(SELECT top 1 service_requester_costcentre_id from charge_detail where charge_detail_id =
										(SELECT top 1 charge_detail_id from ar_invoice_detail where ar_invoice_id = ipf.invoice_id))))as service_requestor

						,(SELECT display_name_l from AmalgaPROD.dbo.person_formatted_name_iview where person_id = 
								(SELECT top 1 employee_id from caregiver_role where patient_id = ipf.patient_id)) as admitting_doctor

						,(SELECT name_l from specialty_ref where specialty_rid =
								(SELECT top 1 specialty_rid from sub_specialty_ref where sub_specialty_rid =
										(SELECT top 1 clinical_specialty_rid from specialty where employee_id = 
											(SELECT top 1 employee_id from caregiver_role where patient_id = ipf.patient_id))))as specialty

						,ar.transaction_text
						,ar.system_transaction_type_rcd
						,cd.patient_visit_id

						,sr.name_l as gender
						,nr.name_l as nationality
						,cr.name_l as country_of_residence
						--,a.postcode
						,csge.group_code


			FROM ar_invoice ar
							LEFT OUTER JOIN HISReport.dbo.rpt_invoice_pf ipf ON ipf.invoice_id = ar.ar_invoice_id
							LEFT OUTER JOIN person_formatted_name_iview pfn ON ipf.patient_id = pfn.person_id
							LEFT OUTER JOIN visit_type_ref vtr ON ar.visit_type_rcd = vtr.visit_type_rcd
							LEFT OUTER JOIN swe_payment_status_ref spsr ON ar.swe_payment_status_rcd = spsr.swe_payment_status_rcd
							LEFT OUTER JOIN transaction_status_ref tsr ON ar.transaction_status_rcd = tsr.transaction_status_rcd			
				
							LEFT OUTER JOIN ar_invoice_detail ard ON ar.ar_invoice_id = ard.ar_invoice_id
							LEFT OUTER JOIN charge_detail cd ON ard.charge_detail_id = cd.charge_detail_id
							LEFT OUTER JOIN patient_visit pv ON cd.patient_visit_id = pv.patient_visit_id
					
							LEFT OUTER JOIN HISViews.dbo.GEN_vw_patient_diagnosis pd ON cd.patient_visit_id = pd.patient_visit_id	AND pd.primary_flag = 1 AND pd.current_visit_diagnosis_flag = 1		
							
							LEFT OUTER JOIN sex_ref sr ON pfn.sex_rcd = sr.sex_rcd
							LEFT OUTER JOIN nationality_ref nr on pfn.nationality_rcd = nr.nationality_rcd
							LEFT OUTER JOIN person p ON pfn.person_id = p.person_id
							LEFT OUTER JOIN country_ref cr ON p.residence_country_rcd = cr.country_rcd	
							--LEFT OUTER JOIN person_address pa ON pfn.person_id = pa.person_id
							--LEFT OUTER JOIN address a ON pa.address_id = a.address_id
							
							LEFT OUTER JOIN coding_system_group_element csge ON pd.code = csge.element_code	
								

			WHERE	--ar.transaction_date_time BETWEEN '06/01/2018 00:00:00:000' AND '06/02/2018 23:59:59:998'
					ar.transaction_date_time BETWEEN @From and @To
					 and ar.visit_type_rcd IN ('V1', 'V2')						--IPD
					 --and ar.visit_type_rcd NOT IN ('V1', 'V2')				--OPD
					 and ar.transaction_status_rcd not in  ('unk','voi')
					 AND pv.cancelled_date_time IS NULL
					 AND vtr.visit_type_group_rcd IN ('IPD')
					-- AND (pa.person_address_type_rcd = 'H1' AND pa.primary_flag = 1 AND pa.effective_until_date IS NULL)

)as temp

where temp.specialty = 'Obstetrics & Gynecology'

ORDER BY temp.patient_name