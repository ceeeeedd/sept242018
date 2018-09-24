--Charge Type Per Count (Nuero ICU)
--Orionmirror.OrionsnapshotDaily = AmalgaPROD
SELECT
    datename(month,charged_date_time) as _monthname,
	MONTH(charged_date_time) as month_id,
	b.charge_type_rcd,
	main_item_group = (SELECT
			name_l
		FROM dbo.item_group_nl_view
		WHERE item_group_id = (SELECT
				parent_item_group_id
			FROM dbo.item_group_nl_view
			WHERE item_group_id = c.item_group_id)),
	item_group = (SELECT
			name_l
		FROM dbo.item_group_nl_view
		WHERE item_group_id = c.item_group_id),
	c.item_code,
	c.name_l AS item_desc,
	SUM(a.quantity) AS qty
FROM	dbo.charge_detail_nl_view a,
		dbo.patient_visit_nl_view b,
		dbo.item_nl_view c
WHERE a.patient_visit_id = b.patient_visit_id
AND a.item_id = c.item_id
AND (
MONTH(a.charged_date_time) = 6
AND YEAR(a.charged_date_time) = 2017
)
AND a.deleted_date_time IS NULL
AND a.patient_visit_package_id IS NULL
GROUP BY	b.charge_type_rcd,
			c.item_group_id,
			c.item_code,
			c.name_l,
			service_provider_costcentre_id,
			datename(month,charged_date_time),
			MONTH(charged_date_time)
UNION 
SELECT
    datename(month,charged_date_time) as _monthname,
	MONTH(charged_date_time) as month_id,
	b.charge_type_rcd,
	main_item_group = (SELECT
			name_l
		FROM dbo.item_group_nl_view
		WHERE item_group_id = (SELECT
				parent_item_group_id
			FROM dbo.item_group_nl_view
			WHERE item_group_id = c.item_group_id)),
	item_group = (SELECT
			name_l
		FROM .dbo.item_group_nl_view
		WHERE item_group_id = c.item_group_id),
	c.item_code,
	c.name_l AS item_desc,
	SUM(a.quantity) AS qty
FROM	charge_detail_nl_view a,
		patient_visit_nl_view b,
		item_nl_view c
WHERE a.patient_visit_id = b.patient_visit_id
AND a.item_id = c.item_id
AND a.charged_date_time between @From and @To
AND a.deleted_date_time IS NULL
AND patient_visit_package_id IS NOT NULL
AND parent_charge_detail_id IS NULL
GROUP BY	b.charge_type_rcd,
			c.item_group_id,
			c.item_code,
			c.name_l,
			service_provider_costcentre_id,
		    datename(month,charged_date_time),
			MONTH(charged_date_time)