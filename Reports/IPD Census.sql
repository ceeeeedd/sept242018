--Monthly IPD Census
SELECT DISTINCT  
	   --temp.bed_schedule_entry_id,
	   --temp.patient_visit_id,
	   temp.visit_type_name as [Visit Type Name],
	   temp.visit_reason as [Visit Reason],
	   temp.created_by as [Created By],
	   temp.place_of_admission as [Place of Admission],
	   temp.actual_visit_date_time as [Visit Start Date],
	   format(temp.actual_visit_date_time, 'hh:mm tt') as [Visit Start time],
	   temp.expected_discharge_date_time as [Expected Discharge Date],
	   format(temp.expected_discharge_date_time, 'hh:mm tt') as [Expected Discharge Time],
	   temp.closure_date_time as [Closure Date],
	   format(temp.closure_date_time,'hh:mm tt') as [Closure Time],
	   --temp.expected_length_of_stay,
	   temp.length_of_stay as [Length of Stay],
	   temp.policy_name as [Visit Policies],
	   temp.visible_patient_id as [HN],
	   temp.display_name_l as [Patient Name],
	   temp.age as [Age],
	   temp.date_of_birth as [Date of Birth],
	   temp.nationality as [Nationality],
	   temp.ethnic_group as [Ethnic Group],
	   temp.religion as [Religion],
	   temp.sex as [Sex],
	   temp.country as [Country],
	   temp.city as [City],
	   temp.home_address as [Home Address],
	   temp.subregion as [Subregion],
	   temp.region_name as [Region],
	   temp.ward as [Ward],
	   temp.nurse_station_name_l as [Nurse Station],
	   temp.ipd_room_code as [Room Code],
	   temp.room_class_name as [Room Class Name],
	   temp.bed as [Bed],
	   temp.bed_type as [Bed Type],
	   temp.diagnosis as [Diagnosis],
	   temp.recorded_at_date_time as [Recorded At Date],
	   format(temp.recorded_at_date_time,'hh:mm tt') as [Recorded At Time],
	   temp.coding_by as [Coding By],
	   temp.primary_caregiver as [Primary Caregiver],
	   temp.primary_caregiver_subspecialty as [Primary Caregiver Subspecialty],
	   temp.admitting_doctor as [Admitting Doctor],
	   temp.admitting_doctor_subspecialty as [Admitting Doctor Subspecialty],
	   temp.discharging_doctor as [Discharging Doctor],
	   temp.discharging_doctor_subspecialty as [Discharging Doctor Subspecialty]
	   ,temp.visit_code as [Visit Code]
	   ,temp.bed_action as [Bed Action]
	   ,temp.bed_transfer_reason as [Bed Transfer Reason]
	   ,temp.outgoing_bed_action as [Outgoing Bed Action]
	   ,temp.patient_height
	   ,temp.patient_weight
	   ,case when (temp.patient_height > 0 and temp.patient_weight > 0) then cast(ROUND(temp.patient_weight / ((temp.patient_height / 100) * (temp.patient_height / 100)),2) as numeric(12,2)) else 0 END as bmi
	   ,case when temp.age <= 18 then 'Pedia' 
			 when temp.age >= 61 then 'Geriatric' else 'Adult' end as [Age Group]
			 -- case when a.bmi <= 18.5 then 'Underweight'
			--when a.bmi <= 24.9 then 'Normal'
			--when a.bmi <= 29.9 then 'Overweight'
			--when a.bmi >= 30 then 'Obese' else 'Normal' end as [Classification]

	--   temp.bed_start_date_time,
	--   temp.diagnosis_comment,
	--   temp.bed_end_date_time,
	--   temp.as_of_date,
	--   temp.care_giver_id,
	--   temp.city_id,
	--   temp.subregion_id,
	--   temp.country_rcd,
	--   temp.region_id,

	--   case when temp.region_id in ('BB9EF3AD-E153-4264-A4D1-585CA49663D1',
	--								'782EDCE7-54A8-45E1-A28F-CC968E8085ED',
	--								'EB2A431D-6A54-4A15-9290-E0FCD8CC7E2F',
	--								'8567E599-6446-4C44-AEC1-180A15CAC7B4',
	--								'A819A2A7-9C56-4F9F-980D-42EDBA3DF706') then 'North'
	--	when temp.region_id = '5492EC17-D67E-4110-AEF7-AFEDB0019D3D' then (case when temp.subregion_id in ('E3B8E064-3631-4D65-8F75-699C5AD98B38',
	--																										  '6419D7CE-F964-419B-9821-848B60EAD536') then 'South' 
	--																		   when temp.subregion_id = '69949CD1-5D65-4360-9146-F9EA75D52FE7' then 'West'
	--																		   when temp.subregion_id = '0A1795AE-7F91-47FD-8B61-DAC5619DCB3C' then 'East'
	--																		   when temp.subregion_id in ('B8A497E3-242A-4DCD-8E98-475B07F04738','D3A47087-E4F8-4203-A8E3-FF729E511EA0') then 'North'
																			   
	--															       end)
	--	 when temp.region_id in ('9641BDC3-66E8-4356-BD8B-036635144D0A',
	--								'6E295C6A-403B-4A3E-BBA5-2422BC275747',
	--								'5843FFE5-2C44-4B8A-A0AF-31434FC2976E',
	--								'D409522B-EADD-4ED4-BA17-569CA5F79AB5',
	--								'A05FE1A4-6191-4314-8166-581D3CC8DF85',
	--								'7E9C4BFC-7CF7-49ED-8D1E-86D577C8FBF1',
	--								'19C7AF39-03F5-4565-A37C-C90302F68607',
	--								'02154BC9-2DC5-410D-8818-C93CD3083621',
	--								'D5C0A045-2C5F-45BC-B650-E39FA4C1164C',
	--								'64B41AB2-126C-442E-A007-26F87D3540AE',
	--								'43419A2D-316F-4220-8D77-F0E392DEFBFC') then 'South'
	--end as cardinal_direction,
	--temp.in_census_flag

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
					sr.name_l as sex,
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
					sr.name_l as sex,
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
where year(temp.actual_visit_date_time) = 2018
and month(temp.actual_visit_date_time) between 1 and 2
    --  year(temp.start_date_time) = 2014
	and temp.address_type in ('H1','N/A')


	--AND temp.patient_visit_id = '9E774B46-EE48-11E7-8733-001E0BACC260'
  order by temp.actual_visit_date_time, [Patient Name] asc