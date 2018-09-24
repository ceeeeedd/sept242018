--icu charges pf and df
--year filtratrion

SELECT pfn.display_name_l as [Patient Name],
	   phu.visible_patient_id as HN,
	   i.item_code as [Item Code],
	   i.name_l as [Item Name],
	   cd.charged_date_time as [Charged Date],
	   format(cd.charged_date_time,'hh:mm tt') as [Time Charged],
	   cd.amount as [Amount],
	   (select name_l from costcentre where costcentre_id = cd.service_requester_costcentre_id) as [Service Requestor],
	   (select name_l from costcentre where costcentre_id = cd.service_provider_costcentre_id) as [Service Provider],
	   gac.gl_acct_code_code as [GL Account Code],
	   gac.name_l as [GL Account Name]
from charge_detail cd inner JOIN patient_visit_nl_view pv on cd.patient_visit_id = pv.patient_visit_id
					  inner JOIN person_formatted_name_iview_nl_view pfn on pv.patient_id = pfn.person_id
					  inner JOIN patient_hospital_usage phu on pfn.person_id = phu.patient_id
					  inner JOIN bed_entry_info_view bei on pv.patient_visit_id = bei.patient_visit_id
					  inner JOIN item_nl_view i on cd.item_id = i.item_id
					  inner JOIN visit_type_ref vt on pv.visit_type_rcd = vt.visit_type_rcd
					  inner JOIN item_group_gl igg on i.item_group_id = igg.item_group_id
					  inner JOIN gl_acct_code gac on igg.gl_acct_code_id = gac.gl_acct_code_id
					  inner JOIN bed_info_view biv on bei.bed_id = biv.bed_id

	and deleted_date_time is NULL
	--and cd.charged_date_time BETWEEN  bei.start_date_time and (case when bei.actual_end_date_time is NULL then GETDATE() else bei.actual_end_date_time end)
	and igg.item_account_type_rcd in ('ipd_revenue','opd_revenue')
	and reverse(STUFF(reverse(igg.item_account_type_rcd),1,8,'')) = vt.visit_type_group_rcd
	and gac.gl_acct_code_code = '2152100'
	and bei.ward_name_l in ('CVICU','MSICU')
UNION ALL
SELECT  TOP 10 pfn.display_name_l as [Patient Name],
	   phu.visible_patient_id as HN,
	   i.item_code as [Item Code],
	   i.name_l as [Item Name],
	   cd.charged_date_time as [Charged Date],
	   format(cd.charged_date_time,'hh:mm tt') as [Time Charged],
	   cd.amount as [Amount],
	   (select name_l from costcentre where costcentre_id = cd.service_requester_costcentre_id) as [Service Requestor],
	   (select name_l from costcentre where costcentre_id = cd.service_provider_costcentre_id) as [Service Provider],
	   gac.gl_acct_code_code as [GL Account Code],
	   gac.name_l as [GL Account Name]
from charge_detail cd inner JOIN patient_visit_nl_view pv on cd.patient_visit_id = pv.patient_visit_id
					  inner JOIN person_formatted_name_iview_nl_view pfn on pv.patient_id = pfn.person_id
					  inner JOIN patient_hospital_usage phu on pfn.person_id = phu.patient_id
					  inner JOIN bed_entry_info_view bei on pv.patient_visit_id = bei.patient_visit_id
					  inner JOIN item_nl_view i on cd.item_id = i.item_id
					  inner JOIN visit_type_ref vt on pv.visit_type_rcd = vt.visit_type_rcd
					  inner JOIN item_group_gl igg on i.item_group_id = igg.item_group_id
					  inner JOIN gl_acct_code gac on igg.gl_acct_code_id = gac.gl_acct_code_id
					  inner JOIN bed_info_view biv on bei.bed_id = biv.bed_id

	and deleted_date_time is NULL
	--and cd.charged_date_time BETWEEN  bei.start_date_time and (case when bei.actual_end_date_time is NULL then GETDATE() else bei.actual_end_date_time end)
	and igg.item_account_type_rcd in ('ipd_revenue','opd_revenue')
	and reverse(STUFF(reverse(igg.item_account_type_rcd),1,8,'')) = vt.visit_type_group_rcd
	and cd.item_id in (SELECT child_item_id
						from item_exploding_nl_view
						where child_item_id = cd.item_id)
	and bei.ward_name_l in ('CVICU','MSICU')
	and gac.gl_acct_code_code <> '4218000'
	--and gac.name_l  = @GL_Account_Name OR @GL_Account_Name IS NULL
	and cd.charged_date_time between @From and @To
order by cd.charged_date_time