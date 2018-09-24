--organisation

SELECT temp.vendor_id as [Vendor ID],
	   temp.vendor_code as [Vendor Code],
	   temp.vendor_name_l as [Vendor Name],
	   temp.company_name as [Company Name],
	   temp.gl_acct_code_code as [GL Account Code],
	   temp.gl_acct_code_name as [GL Account Name],
	   temp.credit_term as [Credit Term],
	   temp.vendor_type as [Vendor Type],
	   temp.tax_number as [Tax Number],
	   temp.currency as [Currency],
	   temp.address as [Address],
	   temp.country as [Country],
	   temp.postcode as [Post Code],
	   temp.city as [City],
	   temp.payment_type as [Payment Type],
	   temp.business_phone_no as [Business Phone No.],
	   temp.fax_no as [Fax No.],
	   LEFT(temp.purchase_site,LEN(temp.purchase_site)-1) as [Purchase Site],
	   'ORGANIZATION' as [Category]

	    ,temp.lu_updated	as [Last Updated Date]
		,format(temp.lu_updated,'hh:mm tt') as [Last Updated Time]	--added line
from
(
	select v.vendor_id,
		   v.vendor_code,
			c.name_l as company_name,
			coalesce(coalesce(o.name_l,o.name_e),pn.list_name_l) as vendor_name_l,
			gac.name_l as gl_acct_code_name,
			gac.gl_acct_code_code,
			ctr.name_l as credit_term,
			vtr.name_l as vendor_type,
			o.tax_number,
			cr.name_l as currency,
			ISNULL(a.address_line_1_l,'') + ' ' + ISNULL(a.address_line_2_l,'') + ' ' + ISNULL(a.address_line_3_l,'') as address,
			oatr.name_l as address_type,
			cor.name_l as country,
			a.postcode,
			COALESCE(a.city,cty.name_l) as city,
			v.ap_payment_type_rid,
			appt.name_l as payment_type,
			(SELECT b.phone_number as business
			from organisation_phone_nl_view a inner JOIN phone b on a.phone_id = b.phone_id
			where a.organisation_phone_type_rcd = 'B1'
				and a.organisation_id = o.organisation_id
				and a.effective_until_date is NULL) as business_phone_no,
			(SELECT b.phone_number as fax
			from organisation_phone_nl_view a inner JOIN phone b on a.phone_id = b.phone_id
			where a.organisation_phone_type_rcd = 'F1'
				and a.organisation_id = o.organisation_id
				and a.effective_until_date is NULL) as fax_no,
			(SELECT b.name_l + ', ' as [text()]
			from swe_purchase_site_vendor_mapping a inner JOIN swe_purchase_site_nl_view b on a.swe_purchase_site_id = b.swe_purchase_site_id
			where vendor_id = v.vendor_id
			for xml PATH('')) as purchase_site

			,v.lu_user_id		--added line
			,v.lu_updated	--added line
	from vendor_nl_view v left join organisation_nl_view o on o.organisation_id = v.organisation_id
						  left join person_formatted_name_iview_nl_view pn on pn.person_id = v.person_id
						  inner JOIN company c on v.created_by_company_code = c.company_code
						  inner JOIN specific_vendor_detail_nl_view svd on v.vendor_id = svd.vendor_id
						  inner JOIN gl_acct_code gac on svd.gl_acct_code_credit_id =  gac.gl_acct_code_id
						  inner JOIN credit_term_ref ctr on svd.credit_term_rid = ctr.credit_term_rid
						  inner JOIN vendor_type_ref vtr on svd.vendor_type_rid = vtr.vendor_type_rid
						  inner JOIN currency_ref cr on v.currency_rcd = cr.currency_rcd
						  LEFT OUTER JOIN  organisation_address_nl_view od on o.organisation_id = od.organisation_id
						  LEFT OUTER JOIN  address a on od.address_id = a.address_id
						  LEFT OUTER JOIN  country_ref cor on a.country_rcd = cor.country_rcd
						  LEFT OUTER JOIN organisation_address_type_ref oatr on od.organisation_address_type_rcd = oatr.organisation_address_type_rcd
						  left outer JOIN city_nl_view cty on a.city_id = cty.city_id
						  LEFT OUTER JOIN ap_payment_type_ref appt on v.ap_payment_type_rid = appt.ap_payment_type_rid
	where od.effective_until_date is NULL
	    and v.active_flag = 1
		and LEN(o.name_l) > 0
		--AND v.lu_updated BETWEEN '2018-07-01 00:00:00.000' AND '2018-07-31 23:59:59.998' --added line
		and month(v.lu_updated) = @From
		--and month(v.lu_updated) = @To
		and Year(v.lu_updated) = @Year
) as temp

UNION ALL

SELECT temp.vendor_id,
	   temp.vendor_code,
	   temp.vendor_name_l,
	   temp.company_name,
	   temp.gl_acct_code_code,
	   temp.gl_acct_code_name,
	   temp.credit_term,
	   temp.vendor_type,
	   temp.tax_number,
	   temp.currency,
	   temp.address,
	   temp.country,
	   temp.postcode,
	   temp.city,
	   temp.payment_type,
	   COALESCE(temp.home_no,temp.mobile_no) as business_phone_no,
	   temp.fax_no,
	   LEFT(temp.purchase_site,LEN(temp.purchase_site)-1) as purchase_site,
	   'PERSON' as category

	   ,temp.lu_updated	as [Last Updated Date]
		,format(temp.lu_updated,'hh:mm tt') as [Last Updated Time]		--added line
from
(
	select v.vendor_id,
		    v.vendor_code,
			c.name_l as company_name,
			pnf.display_name_l as vendor_name_l,
			gac.name_l as gl_acct_code_name,
			gac.gl_acct_code_code,
			ctr.name_l as credit_term,
			vtr.name_l as vendor_type,
			'' as tax_number,
			cr.name_l as currency,
			ISNULL(a.address_line_1_l,'') + ' ' + ISNULL(a.address_line_2_l,'') + ' ' + ISNULL(a.address_line_3_l,'') as address,
			patr.name_l as address_type,
			cor.name_l as country,
			a.postcode,
			COALESCE(a.city,cty.name_l) as city,
			(SELECT b.name_l + ', ' as [text()]
				from swe_purchase_site_vendor_mapping a inner JOIN swe_purchase_site_nl_view b on a.swe_purchase_site_id = b.swe_purchase_site_id
				where vendor_id = v.vendor_id
				for xml PATH('')) as purchase_site,
			v.ap_payment_type_rid,
			appt.name_l as payment_type,
		   (SELECT b.phone_number as mobile_no
			from person_phone_nl_view a inner JOIN phone b on a.phone_id = b.phone_id
			where a.effective_until_date is NULL
				 and a.person_phone_type_rcd = 'H1'
				 and  a.person_id = p.person_id) as home_no,
		   (SELECT b.phone_number as mobile_no
			from person_phone_nl_view a inner JOIN phone b on a.phone_id = b.phone_id
			where a.effective_until_date is NULL
				 and a.person_phone_type_rcd = 'M1'
				 and  a.person_id = p.person_id) as mobile_no,
			(SELECT b.phone_number as fax_no
			from person_phone_nl_view a inner JOIN phone b on a.phone_id = b.phone_id
			where a.effective_until_date is NULL
				 and a.person_phone_type_rcd = 'F1'
				 and  a.person_id = p.person_id) as fax_no

			,v.lu_user_id		--added line
			,v.lu_updated	--added line
	from vendor_nl_view v INNER join person p on v.person_id = p.person_id
						  inner join person_formatted_name_iview_nl_view pnf on pnf.person_id = v.person_id
						  inner JOIN company c on v.created_by_company_code = c.company_code
						  inner JOIN specific_vendor_detail_nl_view svd on v.vendor_id = svd.vendor_id
						  inner JOIN gl_acct_code gac on svd.gl_acct_code_credit_id =  gac.gl_acct_code_id
						  inner JOIN credit_term_ref ctr on svd.credit_term_rid = ctr.credit_term_rid
						  inner JOIN vendor_type_ref vtr on svd.vendor_type_rid = vtr.vendor_type_rid
						  inner JOIN currency_ref cr on v.currency_rcd = cr.currency_rcd
						  LEFT OUTER JOIN  person_address_nl_view pa on p.person_id = pa.person_id
						  LEFT OUTER JOIN  address a on pa.address_id = a.address_id
						  LEFT OUTER JOIN  country_ref cor on a.country_rcd = cor.country_rcd
						  LEFT OUTER JOIN person_address_type_ref_nl_view patr on pa.person_address_type_rcd = patr.person_address_type_rcd
						  left outer JOIN city_nl_view cty on a.city_id = cty.city_id
						  LEFT OUTER JOIN ap_payment_type_ref appt on v.ap_payment_type_rid = appt.ap_payment_type_rid
	where pa.effective_until_date is NULL
	    and v.active_flag = 1
		--AND v.lu_updated BETWEEN '2018-07-01 00:00:00.000' AND '2018-07-31 23:59:59.998' --added line
		--and month(v.lu_updated) = @From
		and month(v.lu_updated) = @To
		and Year(v.lu_updated) = @Year
) as temp
order by temp.lu_updated DESC, temp.vendor_name_l,
	     temp.vendor_type