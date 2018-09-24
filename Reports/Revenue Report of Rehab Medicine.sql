--Revenue Rehab Medicine

SELECT 
			temp.[Charged Date]
			,temp.[Charged Time]
			,temp.[Serviced Date]
			,temp.[Serviced Time]
			,temp.[Closed Date]
			,temp.[Closed Time]
			,temp.parent_item_group_code as [Parent Item Group Code]
			,temp.parent_item_group as [Parent Item Group]
			,temp.costcentre_code as [Service Provider Costcentre Code]
			,temp.service_provider as [Service Provider]
			,temp.item_code as [Item Code]
			,temp.item as [Item]
			,temp.charged_by_employee as [Charged By Employee]
			,temp.clinician as [Clinician]
			,temp.hn as [HN]
			,temp.patient_name as [Patient Name]
			,temp.quantity as [Quantity]
			,temp.amount as [Amount]
			,temp.payment_status as [Payment Status]
			,temp.Guarantor as [Payor]
			--,temp.policy_name as [Payor]
			--,temp.Payment_Type

FROM
(

			SELECT 
						cd.charge_detail_id
						,cd.patient_visit_id
						,pv.patient_id
						,cd.charged_date_time as [Charged Date]
						,format(cd.charged_date_time,'hh:mm tt') as [Charged Time]
						,cast(cd.serviced_date_time as date) as [Serviced Date]
						,format(cd.serviced_date_time,'hh:mm tt') as [Serviced Time]
						,cast(cd.closed_date_time as date) as [Closed Date]
						,format(cd.closed_date_time,'hh:mm tt') as [Closed Time]
						,ig.parent_item_group_id
						,parent_ig.item_group_code as parent_item_group_code
						,parent_ig.name_l as parent_item_group
						,ig.item_group_id
						,ig.item_group_code
						,ig.name_l as item_group
						,cc.costcentre_code
						,cc.name_l as service_provider
						,cd.item_id
						,i.item_code
						,i.name_l as item
						,caregiver.display_name_l as clinician
						,employee.display_name_l as charged_by_employee
						,phu.visible_patient_id as hn
						,patient.display_name_l as patient_name
						,cd.quantity
						,cd.amount
						,spsr.name_l as payment_status
						,p.name_l as policy_name
						,fcr.name_l as Payment_Type
						,guarantor.display_name_l as Guarantor

						--,*

			FROM charge_detail cd
							INNER JOIN patient_visit pv ON cd.patient_visit_id = pv.patient_visit_id
							INNER JOIN item i ON cd.item_id = i.item_id
							INNER JOIN item_group ig ON i.item_group_id = ig.item_group_id
							INNER JOIN item_group parent_ig ON ig.parent_item_group_id = parent_ig.item_group_id
							INNER JOIN costcentre cc ON cd.service_provider_costcentre_id = cc.costcentre_id
							INNER JOIN person_formatted_name_iview caregiver ON cd.caregiver_employee_id = caregiver.person_id
							INNER JOIN person_formatted_name_iview employee ON cd.charged_by_employee_id = employee.person_id
							INNER JOIN patient_hospital_usage phu ON pv.patient_id = phu.patient_id
							INNER JOIN person_formatted_name_iview patient ON pv.patient_id = patient.person_id
							INNER JOIN swe_payment_status_ref spsr ON cd.payment_status_rcd = spsr.swe_payment_status_rcd
							inner join patient_visit_policy pvp on pv.patient_visit_id = pvp.patient_visit_id
							inner join policy p on pvp.policy_id = p.policy_id
							inner join financial_class_ref fcr on p.financial_class_rcd = fcr.financial_class_rcd
							inner join person_formatted_name_iview guarantor on pv.guarantor_person_id = guarantor.person_id
							


			WHERE
					--cd.service_provider_costcentre_id = 'AAEAA762-F4FF-11D9-A79A-001143B8816C'		--Rehabilitation Medicine
					--cd.service_provider_costcentre_id = '12B4E2EC-A284-11E3-AFCC-78E3B597EAF4'			--Sports Medicine and Human Performance Center
cd.service_provider_costcentre_id in (@Costcentre)
					AND cd.payment_status_rcd NOT IN ('VOI', 'UNK')
					AND cd.deleted_date_time IS NULL
					--AND cd.charged_date_time BETWEEN '2018-01-01 00:00:00.000' AND '2018-01-31 23:59:59.998'
					AND month(cd.charged_date_time) BETWEEN @From AND @To
					AND year(cd.charged_date_time) = @Year
					--AND month(cd.charged_date_time) BETWEEN 1 AND 6
					--AND year(cd.charged_date_time) = 2018
					and fcr.financial_class_rcd = 'self'
					--and p.name_l in (@Policy)
					--and fcr.financial_class_rcd in (@PaymentType)
					AND pv.cancelled_date_time IS NULL
					--AND cd.patient_visit_id = 'C44155C4-F045-11E7-8344-DC4A3E729D51' 
					--AND pv.patient_id = '72267B98-4E3A-4C74-8251-57B112C59818'		--Tibayan, Corazon Agoncillo
)as temp

order BY [Charged Date]