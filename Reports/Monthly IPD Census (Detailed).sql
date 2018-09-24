SELECT DISTINCT  
	   temp.actual_visit_date_time as [Visit Start Date],
	   format(temp.actual_visit_date_time, 'hh:mm tt') as [Visit Start time],
	   temp.closure_date_time as [Closure Date],
	   format(temp.closure_date_time,'hh:mm tt') as [Closure Time],
	   temp.length_of_stay as [Length of Stay],
	   temp.visible_patient_id as [HN],
	   temp.display_name_l as [Patient Name],
	   temp.age as [Age],
	   temp.date_of_birth as [Date of Birth],
	   temp.sex as [Sex],
	   temp.patient_height
	   ,temp.patient_weight
	   ,case when (temp.patient_height > 0 and temp.patient_weight > 0) then cast(ROUND(temp.patient_weight / ((temp.patient_height / 100) * (temp.patient_height / 100)),2) as numeric(12,1)) else 0 
	   END as bmi
	   ,case when temp.age <= 18 then 'Pedia' 
			 when temp.age >= 61 then 'Geriatric' else 'Adult' end as Age_Group,
case when (case when (temp.patient_height > 0 and temp.patient_weight > 0) then cast(ROUND(temp.patient_weight / ((temp.patient_height / 100) * (temp.patient_height / 100)),2) as numeric(12,1)) else 0 end) < per.BMI and per.Percentile = '1st' and per.Gender = temp.sex then 'Less than 1st'
when (case when (temp.patient_height > 0 and temp.patient_weight > 0) then cast(ROUND(temp.patient_weight / ((temp.patient_height / 100) * (temp.patient_height / 100)),2) as numeric(12,1)) else 0 end) > per.BMI and per.Percentile = '99th' and per.Gender = temp.sex then 'Greater than 99th'
else (select top 1 Percentile from AHMC_DataAnalyticsDB.dbo.Percentiles
where   age = temp.age
	  and gender = temp.sex
	  and BMI = case when (temp.patient_height > 0 and temp.patient_weight > 0) then cast(ROUND(temp.patient_weight / ((temp.patient_height / 100) * (temp.patient_height / 100)),2) as numeric(12,1)) else 0 END
) end as percentile 



from
(
		SELECT DISTINCT be.bed_schedule_entry_id,
					be.actual_end_date_time,
					pv.patient_visit_id,
					be.ward_name_l as ward,
					be.bed_code as bed,
					
					pfn.display_name_l, 
					phu.visible_patient_id,
					nr.name_l as nationality, 
					p.residence_country_rcd,
					rr.name_l as religion,
					case when sr.name_l = 'Male' then 'M' else 'F' end as sex,
					p.date_of_birth,
					DATEDIFF(dd,p.date_of_birth,GETDATE()) / 365 as age,
					pv.actual_visit_date_time,
					be.start_date_time as bed_start_date_time,
					DATEDIFF (dd, pv.actual_visit_date_time,pv.closure_date_time) as length_of_stay,

					CAST((SELECT description 
							FROM AmalgaPROD.dbo.coding_system_element_description_nl_view 
							WHERE coding_system_rcd = pvdv.coding_system_rcd AND code = pvdv.code) as VARCHAR(600)) as diagnosis,

					pvdv.diagnosis_other as diagnosis_comment,

					(SELECT display_name_l
						from AmalgaPROD.dbo.person_formatted_name_iview_nl_view 
						where person_id = cr.employee_id ) as primary_caregiver,

					(SELECT display_name_l
						from AmalgaPROD.dbo.person_formatted_name_iview_nl_view 
						where person_id = cr.employee_id) as admitting_doctor,

					--NULL as bed_end_date_time,
					cr.employee_id as care_giver_id,
					pv.closure_date_time,
					--GETDATE() as as_of_date,
					case when ADNV.city is NULL then city.city_id else ADNV.city_id end as city_id,
					case when ADNV.city is NULL then city.name_l else ADNV.city end as city,

					ISNULL(ADNV.address_line_1_l,'') + ' ' + ISNULL(adnv.address_line_2_l,'') + ISNULL(adnv.address_line_3_l,'') as home_address,
						case when adnv.city_id is not NULL then (SELECT subr.subregion_id as subregion
															from AmalgaPROD.dbo.subregion_nl_view subr
															where subr.subregion_id = city.subregion_id) else (SELECT subr.subregion_id as subregion
																												from AmalgaPROD.dbo.subregion_nl_view subr
																												where subr.subregion_id = adnv.subregion_id) end as subregion_id,

					case when adnv.city_id is not NULL then (SELECT subr.name_l as subregion
															from AmalgaPROD.dbo.subregion_nl_view subr
															where subr.subregion_id = city.subregion_id) else (SELECT subr.name_l as subregion
																												from AmalgaPROD.dbo.subregion_nl_view subr
																												where subr.subregion_id = adnv.subregion_id) end as subregion,
					adnv.country_rcd,
					cref.name_l as country,

					case when adnv.city_id is NOT NULL then  (SELECT region_id
																from AmalgaPROD.dbo.region
																where region_id = (SELECT region_id
																			from AmalgaPROD.dbo.city_nl_view
																			where city_id = adnv.city_id)) 
														else (SELECT region_id								
															from AmalgaPROD.dbo.region
															where region_id = (SELECT region_id
																				from AmalgaPROD.dbo.subregion_nl_view
																				where subregion_id = adnv.subregion_id))  end as region_id,

					case when adnv.city_id is NOT NULL then  (SELECT name_l
																from AmalgaPROD.dbo.region
																where region_id = (SELECT region_id
																			from AmalgaPROD.dbo.city_nl_view
																			where city_id = adnv.city_id)) 
														else (SELECT name_l								
															from AmalgaPROD.dbo.region
															where region_id = (SELECT region_id
																				from AmalgaPROD.dbo.subregion_nl_view
																				where subregion_id = adnv.subregion_id))  end as region_name,

					be.in_census_flag,
					be.start_date_time,
					case when panv.person_address_type_rcd is NULL then 'N/A' ELSE panv.person_address_type_rcd end as address_type

					,pc.name_l as policy_name
					,vtr.name_l as visit_type_name
					,vrr.name_l as visit_reason
					,(select display_name_l from person_formatted_name_iview where person_id =
							(SELECT top 1 person_id from user_account where user_id = pv.created_by))as created_by

					,pv.expected_discharge_date_time

					,(SELECT name_l from sub_specialty_ref where sub_specialty_rid =
							(SELECT top 1 clinical_specialty_rid from specialty where employee_id = cr.employee_id))as primary_caregiver_subspecialty

				,(SELECT name_l from sub_specialty_ref where sub_specialty_rid =
							(SELECT top 1 clinical_specialty_rid from specialty where employee_id = cr.employee_id))as admitting_doctor_subspecialty

				--	,(SELECT name_l from sub_specialty_ref where sub_specialty_rid =
				--			(SELECT top 1 sub_specialty_rid from specialty where employee_id = cr.employee_id and cr.caregiver_role_type_rcd = 'ADMDR')) as admitting_doctor_subspecialty

				--,(SELECT name_l from sub_specialty_ref where sub_specialty_rid =
				--			(SELECT top 1 sub_specialty_rid from specialty where employee_id = cr.employee_id and cr.caregiver_role_type_rcd = 'DISDR'))as discharging_doctor_subspecialty

				,pv.expected_length_of_stay
				,btr.name_l as bed_type
				,be.ipd_room_code
				,ircr.name_l as room_class_name
				,iriv.nurse_station_name_l

				,(SELECT name_l from ethnic_group_ref where ethnic_group_rcd = 
					(SELECT top 1 ethnic_group_rcd from person_ethnic_group where person_id = pfn.person_id))as ethnic_group

				,a.name_l as place_of_admission
				,pvdv.recorded_at_date_time

				,(SELECT display_name_l from person_formatted_name_iview where person_id = pvdv.coding_employee_id)as coding_by
				,(select display_name_l from person_formatted_name_iview where person_id = pvdv.done_by_employee_id)as discharging_doctor

				,(SELECT name_l from sub_specialty_ref where sub_specialty_rid =
							(SELECT top 1 clinical_specialty_rid from specialty where employee_id = pvdv.done_by_employee_id))as discharging_doctor_subspecialty
				,pv.visit_code
				,be.bed_action_rcd
				,bar.name_l as bed_action
				,be.patient_visit_transfer_reason_rcd
				,btrr.name_l as bed_transfer_reason
				,be.outgoing_bed_action_rcd
				,bar2.name_l as outgoing_bed_action
				,ISNULL((SELECT TOP 1 pcod.numeric_value as patient_height
				  from patient_clinical_observation pco inner join patient_clinical_observation_detail pcod on pco.patient_clinical_observation_id = pcod.patient_clinical_observation_id
				  where patient_id = pv.patient_id
					   and clinical_observation_item_rid = '7FE3127B-9CF1-40A5-8E2C-7F6CF09062FD'
				  order by pcod.lu_updated DESC),0) as patient_height,

					ISNULL((SELECT TOP 1 pcod.numeric_value as patient_weight
					from patient_clinical_observation pco inner join patient_clinical_observation_detail pcod on pco.patient_clinical_observation_id = pcod.patient_clinical_observation_id
					where patient_id = pv.patient_id
						 and clinical_observation_item_rid = '241526D4-FF6B-4FD0-9BBD-A41C3F312E75'
					order by pcod.lu_updated DESC),0) as patient_weight

	from AmalgaPROD.dbo.patient_visit pv 
					INNER JOIN AmalgaPROD.dbo.patient_hospital_usage phu ON pv.patient_id = phu.patient_id
					INNER join AmalgaPROD.dbo.person_formatted_name_iview_nl_view pfn on phu.patient_id = pfn.person_id
					INNER join AmalgaPROD.dbo.nationality_ref nr on pfn.nationality_rcd = nr.nationality_rcd
					INNER JOIN AmalgaPROD.dbo.person p on pfn.person_id = p.person_id
					INNER join AmalgaPROD.dbo.religion_ref rr on p.religion_rcd = rr.religion_rcd
					inner join AmalgaPROD.dbo.sex_ref sr on p.sex_rcd = sr.sex_rcd
					INNER JOIN AmalgaPROD.dbo.bed_entry_info_view be on pv.patient_visit_id = be.patient_visit_id
					LEFT OUTER JOIN AmalgaPROD.dbo.caregiver_role cr on pv.patient_visit_id = cr.patient_visit_id
					INNER JOIN AmalgaPROD.dbo.patient_visit_diagnosis_view pvdv on pv.patient_visit_id = pvdv.patient_visit_id
					INNER JOIN AmalgaPROD.dbo.person_nl_view pnv ON pfn.person_id = pnv.person_id
						LEFT OUTER JOIN AmalgaPROD.dbo.person_address_nl_view panv ON pnv.person_id = panv.person_id
						LEFT OUTER JOIN AmalgaPROD.dbo.address_nl_view adnv ON panv.address_id = adnv.address_id
						LEFT OUTER JOIN AmalgaPROD.dbo.city_nl_view city on ADNV.city_id = city.city_id
						left OUTER JOIN AmalgaPROD.dbo.country_ref cref on adnv.country_rcd = cref.country_rcd

						LEFT outer JOIN AmalgaPROD.dbo.patient_visit_policy_nl_view pvp on pv.patient_visit_id = pvp.patient_visit_id
					LEFT outer JOIN AmalgaPROD.dbo.policy_nl_view pc on pvp.policy_id = pc.policy_id

					INNER JOIN AmalgaPROD.dbo.visit_type_ref vtr on pv.visit_type_rcd = vtr.visit_type_rcd
					INNER JOIN AmalgaPROD.dbo.patient_visit_reason pvr on pv.patient_visit_id = pvr.patient_visit_id
					INNER JOIN AmalgaPROD.dbo.visit_reason_ref vrr ON pvr.visit_reason_rcd = vrr.visit_reason_rcd
					INNER JOIN AmalgaPROD.dbo.bed_type_ref btr ON be.bed_type_rcd = btr.bed_type_rcd
					INNER JOIN AmalgaPROD.dbo.ipd_room_class_ref ircr ON be.ipd_room_class_rcd = ircr.ipd_room_class_rcd
					INNER JOIN AmalgaPROD.dbo.ipd_room_info_view iriv ON be.nurse_station_id = iriv.nurse_station_id
					INNER join AmalgaPROD.dbo.area a on pv.created_from_area_id = a.area_id
					INNER JOIN AmalgaPROD.dbo.bed_action_ref bar ON be.bed_action_rcd = bar.bed_action_rcd
					--INNER JOIN AmalgaPROD.dbo.bed_transfer_reason_ref btrr on be.bed_transfer_reason_rcd = btrr.bed_transfer_reason_rcd
					INNER JOIN AmalgaPROD.dbo.patient_visit_transfer_reason_ref btrr on be.patient_visit_transfer_reason_rcd = btrr.patient_visit_transfer_reason_rcd
					INNER JOIN AmalgaPROD.dbo.bed_action_ref bar2 ON be.outgoing_bed_action_rcd = bar2.bed_action_rcd
					 
	WHERE pv.visit_type_rcd in ('V1','V2')
		--and be.actual_end_date_time is NULL
		--AND pv.closure_date_time IS NULL
		AND ISNULL(pvdv.current_visit_diagnosis_flag,0) = 1
		AND cr.caregiver_role_type_rcd  = 'PRIDR'
		AND cr.caregiver_role_status_rcd = 'ACTIV'
		AND PANV.effective_until_date IS NULL
		and be.in_census_flag = 1
		AND iriv.active_flag = 1

   UNION ALL
   SELECT DISTINCT be.bed_schedule_entry_id,
					be.actual_end_date_time,
					pv.patient_visit_id,
					be.ward_name_l as ward,
					be.bed_code as bed,
					pfn.display_name_l, 
					phu.visible_patient_id,
					nr.name_l as nationality, 
					p.residence_country_rcd,
					rr.name_l as religion,
					case when sr.name_l = 'Male' then 'M' else 'F' end as sex,
					p.date_of_birth,
					DATEDIFF(dd,p.date_of_birth,GETDATE()) / 365 as age,
					pv.actual_visit_date_time,
					be.start_date_time as bed_start_date_time,

					DATEDIFF (dd, pv.actual_visit_date_time,pv.closure_date_time) as length_of_stay,

					'' as diagnosis,
					'' as diagnosis_comment,

				(SELECT display_name_l
						from AmalgaPROD.dbo.person_formatted_name_iview_nl_view 
						where person_id = cr.employee_id) as primary_caregiver,

				(SELECT display_name_l
						from AmalgaPROD.dbo.person_formatted_name_iview_nl_view 
						where person_id = cr.employee_id) as admitting_doctor,

					--NULL as bed_end_date_time,
					cr.employee_id as care_giver_id,
					pv.closure_date_time,
					--GETDATE() as as_of_date,

					case when ADNV.city is NULL then city.city_id else ADNV.city_id end as city_id,
					case when ADNV.city is NULL then city.name_l else ADNV.city end as city,

					ISNULL(ADNV.address_line_1_l,'') + ' ' + ISNULL(adnv.address_line_2_l,'') + ISNULL(adnv.address_line_3_l,'') as home_address,
						case when adnv.city_id is not NULL then (SELECT subr.subregion_id as subregion
															from AmalgaPROD.dbo.subregion_nl_view subr
															where subr.subregion_id = city.subregion_id) else (SELECT subr.subregion_id as subregion
																												from AmalgaPROD.dbo.subregion_nl_view subr
																												where subr.subregion_id = adnv.subregion_id) end as subregion_id,

					case when adnv.city_id is not NULL then (SELECT subr.name_l as subregion
															from AmalgaPROD.dbo.subregion_nl_view subr
															where subr.subregion_id = city.subregion_id) else (SELECT subr.name_l as subregion
																												from AmalgaPROD.dbo.subregion_nl_view subr
																												where subr.subregion_id = adnv.subregion_id) end as subregion,

					adnv.country_rcd,
					cref.name_l as country,
					case when adnv.city_id is NOT NULL then  (SELECT region_id
																from AmalgaPROD.dbo.region
																where region_id = (SELECT region_id
																			from AmalgaPROD.dbo.city_nl_view
																			where city_id = adnv.city_id)) 
														else (SELECT region_id								
															from AmalgaPROD.dbo.region
															where region_id = (SELECT region_id
																				from AmalgaPROD.dbo.subregion_nl_view
																				where subregion_id = adnv.subregion_id))  end as region_id,

					case when adnv.city_id is NOT NULL then  (SELECT name_l
																from AmalgaPROD.dbo.region
																where region_id = (SELECT region_id
																			from AmalgaPROD.dbo.city_nl_view
																			where city_id = adnv.city_id)) 
														else (SELECT name_l								
															from AmalgaPROD.dbo.region
															where region_id = (SELECT region_id
																				from AmalgaPROD.dbo.subregion_nl_view
																				where subregion_id = adnv.subregion_id))  end as region_name,

					be.in_census_flag,
					be.start_date_time,
					case when panv.person_address_type_rcd is NULL then 'N/A' ELSE panv.person_address_type_rcd end as address_type

					,pc.name_l as policy_name
					,vtr.name_l as visit_type_name
					,vrr.name_l as visit_reason
					,(select display_name_l from person_formatted_name_iview where person_id =
							(SELECT top 1 person_id from user_account where user_id = pv.created_by))as created_by
					,pv.expected_discharge_date_time

					,(SELECT name_l from sub_specialty_ref where sub_specialty_rid =
							(SELECT top 1 clinical_specialty_rid from specialty where employee_id = cr.employee_id))as primary_caregiver_subspecialty

					,(SELECT name_l from sub_specialty_ref where sub_specialty_rid =
							(SELECT top 1 clinical_specialty_rid from specialty where employee_id = cr.employee_id))as admitting_doctor_subspecialty

				,pv.expected_length_of_stay
				,btr.name_l as bed_type
				,be.ipd_room_code
				,ircr.name_l as room_class_name
				,iriv.nurse_station_name_l
				,(SELECT name_l from ethnic_group_ref where ethnic_group_rcd = 
					(SELECT top 1 ethnic_group_rcd from person_ethnic_group where person_id = pfn.person_id))as ethnic_group
				,a.name_l as place_of_admission
				,pvdv.recorded_at_date_time

				,(SELECT display_name_l from person_formatted_name_iview where person_id = pvdv.coding_employee_id)as coding_by
				,(select display_name_l from person_formatted_name_iview where person_id = pvdv.done_by_employee_id)as discharging_doctor

				,(SELECT name_l from sub_specialty_ref where sub_specialty_rid =
							(SELECT top 1 clinical_specialty_rid from specialty where employee_id = pvdv.done_by_employee_id))as discharging_doctor_subspecialty
				,pv.visit_code
				,be.bed_action_rcd
				,bar.name_l as bed_action
				,be.patient_visit_transfer_reason_rcd
				,btrr.name_l as bed_transfer_reason
				,be.outgoing_bed_action_rcd
				,bar2.name_l as outgoing_bed_action
				,ISNULL((SELECT TOP 1 pcod.numeric_value as patient_height
				  from patient_clinical_observation pco inner join patient_clinical_observation_detail pcod on pco.patient_clinical_observation_id = pcod.patient_clinical_observation_id
				  where patient_id = pv.patient_id
					   and clinical_observation_item_rid = '7FE3127B-9CF1-40A5-8E2C-7F6CF09062FD'
				  order by pcod.lu_updated DESC),0) as patient_height,

					ISNULL((SELECT TOP 1 pcod.numeric_value as patient_weight
					from patient_clinical_observation pco inner join patient_clinical_observation_detail pcod on pco.patient_clinical_observation_id = pcod.patient_clinical_observation_id
					where patient_id = pv.patient_id
						 and clinical_observation_item_rid = '241526D4-FF6B-4FD0-9BBD-A41C3F312E75'
					order by pcod.lu_updated DESC),0) as patient_weight
				

	from AmalgaPROD.dbo.patient_visit pv 
					INNER JOIN AmalgaPROD.dbo.patient_hospital_usage phu ON pv.patient_id = phu.patient_id
					INNER join AmalgaPROD.dbo.person_formatted_name_iview_nl_view pfn on phu.patient_id = pfn.person_id
					INNER join AmalgaPROD.dbo.nationality_ref nr on pfn.nationality_rcd = nr.nationality_rcd
					INNER JOIN AmalgaPROD.dbo.person p on pfn.person_id = p.person_id
					INNER join AmalgaPROD.dbo.religion_ref rr on p.religion_rcd = rr.religion_rcd
					inner join AmalgaPROD.dbo.sex_ref sr on p.sex_rcd = sr.sex_rcd
					INNER JOIN AmalgaPROD.dbo.bed_entry_info_view be on pv.patient_visit_id = be.patient_visit_id
					LEFT OUTER JOIN AmalgaPROD.dbo.caregiver_role cr on pv.patient_visit_id = cr.patient_visit_id
					INNER JOIN AmalgaPROD.dbo.patient_visit_diagnosis_view pvdv on pv.patient_visit_id = pvdv.patient_visit_id
					INNER JOIN AmalgaPROD.dbo.person_nl_view pnv ON pfn.person_id = pnv.person_id
					LEFT OUTER JOIN AmalgaPROD.dbo.person_address_nl_view panv ON pnv.person_id = panv.person_id
					LEFT OUTER JOIN AmalgaPROD.dbo.address_nl_view adnv ON panv.address_id = adnv.address_id
					LEFT OUTER JOIN AmalgaPROD.dbo.city_nl_view city on ADNV.city_id = city.city_id
					left outer JOIN AmalgaPROD.dbo.country_ref cref on adnv.country_rcd = cref.country_rcd

						LEFT outer JOIN AmalgaPROD.dbo.patient_visit_policy_nl_view pvp on pv.patient_visit_id = pvp.patient_visit_id
					LEFT outer JOIN AmalgaPROD.dbo.policy_nl_view pc on pvp.policy_id = pc.policy_id

					INNER JOIN AmalgaPROD.dbo.visit_type_ref vtr on pv.visit_type_rcd = vtr.visit_type_rcd
					INNER JOIN AmalgaPROD.dbo.patient_visit_reason pvr on pv.patient_visit_id = pvr.patient_visit_id
					INNER JOIN AmalgaPROD.dbo.visit_reason_ref vrr ON pvr.visit_reason_rcd = vrr.visit_reason_rcd
					INNER JOIN AmalgaPROD.dbo.bed_type_ref btr ON be.bed_type_rcd = btr.bed_type_rcd
					INNER JOIN AmalgaPROD.dbo.ipd_room_class_ref ircr ON be.ipd_room_class_rcd = ircr.ipd_room_class_rcd
					INNER JOIN AmalgaPROD.dbo.ipd_room_info_view iriv ON be.nurse_station_id = iriv.nurse_station_id
					INNER join AmalgaPROD.dbo.area a on pv.created_from_area_id = a.area_id
					INNER JOIN AmalgaPROD.dbo.bed_action_ref bar ON be.bed_action_rcd = bar.bed_action_rcd
					--INNER JOIN AmalgaPROD.dbo.bed_transfer_reason_ref btrr on be.bed_transfer_reason_rcd = btrr.bed_transfer_reason_rcd
					INNER JOIN AmalgaPROD.dbo.patient_visit_transfer_reason_ref btrr on be.patient_visit_transfer_reason_rcd = btrr.patient_visit_transfer_reason_rcd
					INNER JOIN AmalgaPROD.dbo.bed_action_ref bar2 ON be.outgoing_bed_action_rcd = bar2.bed_action_rcd

	WHERE pv.visit_type_rcd in ('V1','V2')
		--and be.actual_end_date_time is NULL
		--AND pv.closure_date_time IS NULL
		AND cr.caregiver_role_type_rcd = 'PRIDR'
		AND cr.caregiver_role_status_rcd = 'ACTIV'
		AND PANV.effective_until_date IS NULL
		and be.in_census_flag = 1
		and pv.patient_visit_id not in (SELECT patient_visit_id
										from AmalgaPROD.dbo.patient_visit_diagnosis_view
										where patient_visit_id = patient_visit_id)
		AND iriv.active_flag = 1
			
) as temp
left JOIN AHMC_DataAnalyticsDB.dbo.percentiles per on temp.age = per.Age
where 
--year(temp.actual_visit_date_time) = 2018
--and month(temp.actual_visit_date_time) = 8
 year(temp.actual_visit_date_time) = @year
and month(temp.actual_visit_date_time) between @month and @month1
    --  year(temp.start_date_time) = 2014
	and temp.address_type in ('H1','N/A')
	--and temp.age <= 18
	--and temp.display_name_l = 'Tan, Francine Louise Teng'
	

	--AND temp.patient_visit_id = '9E774B46-EE48-11E7-8733-001E0BACC260'
  order by temp.actual_visit_date_time, [Patient Name] asc