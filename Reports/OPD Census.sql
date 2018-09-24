/*DECLARE @date smalldatetime
DECLARE @date2 smalldatetime

SET @date = getdate()
SET @date2 = DATEADD(hh, -1,@date)*/

 
SELECT --DISTINCT temp.hn
	 DISTINCT --temp.patient_visit_id,
	   temp.charge_type_rcd as [Charge Type],
	   temp.visit_start as [Visit Start Date],
	   format(temp.visit_start,'hh:mm tt') as [Visit Start Time],
	   temp.visit_type_rcd as [Visit Type rcd],
	   temp.visit_type as [Visit Type],
	   temp.visit_no as [Visit No],
	   temp.primary_service_rcd as [Primary Service rcd],
	   temp.primary_service as [Primary Service],
	   temp.visit_reason as [Visit Reason],
	   --temp.patient_id,
	  temp.policy_name as [Visit Policies],
	   temp.hn as [HN],
	   temp.patient_name as [Patient Name],
	   temp.age as [Age],
	   temp.date_of_birth as [Date of Birth],
	   temp.nationality as [Nationality],
	   temp.race_rcd as [Race],
	   temp.religion [Religion],
	   temp.sex as [Gender],
	   temp.packages as [Packages],
	   temp.created_by as [Created By],
	   temp.closure_date_time as [Closure Date],
	   format(temp.closure_date_time,'hh:mm tt') as [Closure Time],
	   --temp.city_id,
	   temp.city as [City],
	   temp.home_address as [Home Address],
	   --temp.subregion_id,
	   temp.subregion as [Subregion],
	   temp.country_rcd as [Country rcd],
	   temp.country as [Country],
	   --temp.region_id,
	   temp.region_name as [Region Name]
	--     case when temp.region_id in ('BB9EF3AD-E153-4264-A4D1-585CA49663D1',
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
	--end as cardinal_direction
	
from
(
	SELECT DISTINCT pv.patient_visit_id,
			pv.charge_type_rcd,
			pv.actual_visit_date_time as visit_start,
			pv.visit_type_rcd,
			vtr.name_l as visit_type,
			pv.visit_code as visit_no,	
			visit_reason = (SELECT name_l 
							FROM AmalgaPROD.dbo.visit_reason_ref_nl_view 
							WHERE visit_reason_rcd = (SELECT TOP 1 visit_reason_rcd 
													   FROM AmalgaPROD.dbo.patient_visit_reason_nl_view 
													   WHERE patient_visit_id = PV.patient_visit_id 
													   ORDER BY lu_updated DESC)),
			pv.patient_id,
			pc.name_l as policy_name,
			phu.visible_patient_id as hn,
			pfn.display_name_l as patient_name,
			DATEDIFF(dd,p.date_of_birth,GETDATE()) / 365 as age,
			p.date_of_birth,
			nr.name_l as nationality,
			ra.race_rcd,
			rr.name_l as religion,
			sr.name_l as sex,
			packages = (SELECT name_l 
						 FROM AmalgaPROD.dbo.item_nl_view 
						 WHERE item_id = (SELECT TOP 1 package_item_id 
										  FROM AmalgaPROD.dbo.patient_visit_package_nl_view 
										  WHERE patient_visit_id = PV.patient_visit_id 
												AND patient_visit_package_status_rcd = 'CRE' 
										  ORDER BY creation_date_time DESC)),
		  created_by = (SELECT display_name_l 
						FROM AmalgaPROD.dbo.person_formatted_name_iview_nl_view 
						WHERE person_id = (SELECT person_id 
										   FROM AmalgaPROD.dbo.user_account_nl_view 
										   WHERE user_id = PV.created_by)),
		 pv.closure_date_time,
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
	   pv.primary_service_rcd,
	   psr.name_l as primary_service,
	   ISNULL(person_address_type_rcd,'N/A') AS person_address_type_rcd,
	   case when person_address_type_rcd is NULL then 'N/A' else person_address_type_rcd end as address_type
	from AmalgaPROD.dbo.patient_visit pv 
					INNER JOIN AmalgaPROD.dbo.patient_hospital_usage phu ON pv.patient_id = phu.patient_id
					INNER JOIN AmalgaPROD.dbo.person_formatted_name_iview_nl_view pfn on phu.patient_id = pfn.person_id
					INNER JOIN AmalgaPROD.dbo.nationality_ref nr on pfn.nationality_rcd = nr.nationality_rcd
					INNER JOIN AmalgaPROD.dbo.person p on pfn.person_id = p.person_id
					INNER JOIN AmalgaPROD.dbo.sex_ref sr on p.sex_rcd = sr.sex_rcd
					LEFT OUTER JOIN AmalgaPROD.dbo.religion_ref rr on p.religion_rcd = rr.religion_rcd
					LEFT OUTER JOIN AmalgaPROD.dbo.race_ref ra on p.race_rcd = ra.race_rcd
					LEFT outer JOIN AmalgaPROD.dbo.patient_visit_policy_nl_view pvp on pv.patient_visit_id = pvp.patient_visit_id
					LEFT outer JOIN AmalgaPROD.dbo.policy_nl_view pc on pvp.policy_id = pc.policy_id
					inner JOIN  AmalgaPROD.dbo.visit_type_ref_nl_view vtr on pv.visit_type_rcd = vtr.visit_type_rcd
					LEFT OUTER JOIN AmalgaPROD.dbo.person_address_nl_view panv ON p.person_id = panv.person_id
					LEFT OUTER JOIN AmalgaPROD.dbo.address_nl_view adnv ON panv.address_id = adnv.address_id
					LEFT OUTER JOIN AmalgaPROD.dbo.city_nl_view city on ADNV.city_id = city.city_id
				    left outer JOIN AmalgaPROD.dbo.country_ref cref on adnv.country_rcd = cref.country_rcd
					inner JOIN AmalgaPROD.dbo.primary_service_ref psr on pv.primary_service_rcd = psr.primary_service_rcd
	WHERE vtr.visit_type_group_rcd = 'OPD'
			and pv.cancelled_date_time is NULL
			and panv.effective_until_date is NULL
) as temp
where temp.address_type in ('H1','N/A')
			and year(temp.visit_start) = @year
			and month(temp.visit_start) = @month
order by temp.visit_start