select temp.department_code,
	   temp.department_name_l,
	   temp.job_title_name_l,
	   temp.usergroup,
	   temp.context_security
from 
(
SELECT eei.department_code,
	   eei.department_name_l,
	   eei.job_title_name_l,
	   ugr.name_l as usergroup,
	   scr.name_l as context_security
	   --eei.first_name_l + ' ' + eei.last_name_l as [Username]
	   --ua.user_name as [Username]
	   --pfn.display_name_l as [Employee Name]
from user_account ua inner join employee_employment_info_view eei on ua.person_id = eei.person_id
					 inner join user_group_user_nl_view ugu on ua.user_id = ugu.user_id
					 inner JOIN user_group_ref ugr on ugu.user_group_rcd = ugr.user_group_rcd
					 inner join security_context_user_group_membership scugm on ua.user_id = scugm.user_id
					 inner JOIN security_context_user_group scug on scugm.security_context_user_group_id = scug.security_context_user_group_id
					 inner join security_context_ref scr on scug.security_context_rcd = scr.security_context_rcd
					 --inner join person_formatted_name_iview pfn on ua.person_id = pfn.person_id
where ugr.active_status = 'A'
	 and scr.active_status = 'A'
	 and ISNULL(ua.active_flag,0) = 1
	 and month(ua.lu_updated) = @From
	 and year(ua.lu_updated) = @Year 
group by ugu.user_group_rcd,
	     eei.department_code,
		 eei.department_name_l,
		 eei.job_title_name_l,
		 ugr.name_l,
		 scr.name_l
		 --eei.first_name_l,
		 --eei.last_name_l
	   --ua.user_name
	   --pfn.display_name_l
--order by eei.job_title_name_l

UNION ALL

SELECT eei.department_code,
	   eei.department_name_l,
	   eei.job_title_name_l,
	   ugr.name_l as usergroup,
	   scr.name_l as context_security
	   --eei.first_name_l + ' ' + eei.last_name_l as [Username]
	   --ua.user_name as [Username]
	   --pfn.display_name_l as [Employee Name]
from user_account ua inner join employee_employment_info_view eei on ua.person_id = eei.person_id
					 inner join user_group_user_nl_view ugu on ua.user_id = ugu.user_id
					 inner JOIN user_group_ref ugr on ugu.user_group_rcd = ugr.user_group_rcd
					 inner join security_context_user_group_membership scugm on ua.user_id = scugm.user_id
					 inner JOIN security_context_user_group scug on scugm.security_context_user_group_id = scug.security_context_user_group_id
					 inner join security_context_ref scr on scug.security_context_rcd = scr.security_context_rcd
					 --inner join person_formatted_name_iview pfn on ua.person_id = pfn.person_id
where ugr.active_status = 'A'
	 and scr.active_status = 'A'
	 and ISNULL(ua.active_flag,0) = 1
	 and month(ua.lu_updated) = @To
	 and year(ua.lu_updated) = @Year
group by ugu.user_group_rcd,
	     eei.department_code,
		 eei.department_name_l,
		 eei.job_title_name_l,
		 ugr.name_l,
		 scr.name_l
		 --eei.first_name_l,
		 --eei.last_name_l
	   --ua.user_name
	   --pfn.display_name_l
--order by eei.job_title_name_l

) as temp
order by temp.job_title_name_l