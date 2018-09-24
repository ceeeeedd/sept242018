--REVENUE MSU


SELECT  DISTINCT
			--*,	
			temp.[Date Charged]
			,temp.[Time Charged]
			,temp.[Date Serviced]
			,temp.[Time Serviced]
			,temp.[Date Closed]
			,temp.[Time Closed]
			,(SELECT name_l from item_group WHERE item_group_id = temp.parent_item_group_id)as [Parent Item Group] 
			,(SELECT item_group_code from item_group WHERE item_group_id = temp.parent_item_group_id)as [Parent Item Group Code]
			,temp.item_group as [Item Group]
			,temp.item_group_code as [Item Group Code]
			,temp.service_provider as [Service Provider]
			,temp.service_requestor as [Service Requestor]
			,temp.item_code as [Item Code]
			,temp.item_name as [Item Name]
			,temp.item_type as [Item Type]
			,temp.payment_status as [Payment Status]
			,temp.charge_type_rcd as [Charge Type]
			,temp.hn as [HN]
			,temp.patient_name as [Patient Name]
			,temp.quantity as [Quantity]
			,temp.[Amount]

from (
			SELECT --*,
						--ig.*,
						cd.charge_detail_id
						,cast(cd.charged_date_time as date) as [Date Charged]
						,format(cd.charged_date_time,'hh:mm tt') as [Time Charged]
						,cast(cd.serviced_date_time as date) as [Date Serviced]
						,format(cd.serviced_date_time,'hh:mm tt') as [Time Serviced]
						,cast(cd.closed_date_time as date) as [Date Closed]
						,format(cd.closed_date_time,'hh:mm tt') as [Time Closed]

						,ig.parent_item_group_id
						,ig.name_l as item_group
						,ig.item_group_code
						--,(SELECT name_l from item_group where parent_item_group_id =  i.item_group_id)as parent_item_group

						,(SELECT name_l from costcentre where costcentre_id = cd.service_provider_costcentre_id) as service_provider
						,(SELECT name_l from costcentre where costcentre_id = cd.service_requester_costcentre_id) as service_requestor
						,i.item_code
						,i.name_l as item_name
						,itr.name_l as item_type
						,spsr.name_l as payment_status
						,pv.charge_type_rcd
						,phu.visible_patient_id as hn
						,pfn.display_name_l as patient_name
						,cd.quantity
						,cast(cd.amount as decimal(10,2)) as [Amount]
			
			FROM charge_detail cd
							LEFT OUTER JOIN item i ON cd.item_id = i.item_id
							LEFT OUTER JOIN item_group ig ON i.item_group_id = ig.item_group_id
							LEFT OUTER JOIN patient_visit pv ON cd.patient_visit_id = pv.patient_visit_id
							LEFT OUTER JOIN patient_hospital_usage phu ON pv.patient_id = phu.patient_id
							LEFT OUTER JOIN person_formatted_name_iview_nl_view pfn ON pv.patient_id = pfn.person_id
							LEFT OUTER JOIN item_type_ref itr ON i.item_type_rcd = itr.item_type_rcd
							LEFT OUTER JOIN swe_payment_status_ref spsr ON cd.payment_status_rcd = spsr.swe_payment_status_rcd

			where --cd.charged_date_time BETWEEN '2018-06-01 00:00:00:000' AND '2018-06-30 23:59:59:998'				--102547
cd.charged_date_time between @From and @To
						AND cd.service_provider_costcentre_id = 'AAEAA744-F4FF-11D9-A79A-001143B8816C'		--MSU
						AND cd.deleted_date_time IS NULL
						
						AND i.active_flag = 1
						AND ig.active_flag = 1
						AND pv.cancelled_date_time IS NULL		--102543
						AND itr.active_status = 'A'
						
						--AND i.item_code = '588-0003'
						--AND phu.visible_patient_id = '00403948'
						--AND ig.parent_item_group_id = '9B781569-360A-11DA-BB34-000E0C7F3ED2'
)as temp
--where --temp.parent_item_group_id = '9B781569-360A-11DA-BB34-000E0C7F3ED2'		--MSU
--temp.hn = '00533667'

order by temp.[Date Charged],temp.[Time Charged]