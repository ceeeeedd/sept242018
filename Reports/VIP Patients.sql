--VIP PATIENTS

SELECT distinct phu.visible_patient_id as [HN],
		pfn.display_name_l as [Patient Name],
		CONVERT(VARCHAR(10),pfn.date_of_birth,101) as [Date of Birth],
		ISNULL(pa.home_address_line_1_l,'') + isnull(pa.home_address_line_2_l,'') + ISNULL(pa.home_address_line_3_l,'') as [Home Address],
	    case when pa.home_city_name_l is null then ISNULL(pa.home_subregion_name_l,'') else ISNULL(pa.home_city_name_l,'') end as [City],
		ISNULL(phpr.name_l,'') as [Phone Type],
		ISNULL(ph.phone_number,'') as [Contact Number]
from patient p inner JOIN person_indicator pin on p.patient_id = pin.person_id
			   inner JOIN person_formatted_name_iview_nl_view pfn on p.patient_id = pfn.person_id
			   inner JOIN patient_hospital_usage_nl_view phu on p.patient_id = phu.patient_id
			   inner JOIN patient_address_view pa on p.patient_id = pa.patient_id
			   LEFT OUTER JOIN person_phone pp on p.patient_id = pp.person_id
			   LEFT OUTER JOIN person_phone_type_ref phpr on pp.person_phone_type_rcd = phpr.person_phone_type_rcd
			   LEFT OUTER JOIN phone ph on pp.phone_id = ph.phone_id
			  
where pin.person_indicator_rcd = 'VPI'
    and pin.active_flag = 1
	and pp.effective_until_date is NULL
	--and pa.home_city_name_l = @pa.home_city_name_l
order by pfn.display_name_l