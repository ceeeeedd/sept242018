SELECT
	employee_nr as [Emp Nr],
	caregiver_lname as [Dr Last Name],
	caregiver_fname as [Dr First Name],
	caregiver_job_type as [Job Type],
	upi as [Px UPI],
	lname as [Px Last Name],
	fname as [Px First Name],
	mname as [Px Middle Name],
	admission_date as [Admission Date],
	admission_type as [Type],
	visit_type as [Visit Type],
	item_code as [Item Code],
	item_desc as [Item Description],
	total_amt as [Gross Amt],
	discount_amt as [Disc Amt],
	adjustment_amt as [Adjust Amt],
	ISNULL(net_amt, 0.00) as [Net Amt],
	validated as [Validated],
	paid as [Paid],
	processed as [Processed],
	lu_updated_datetime as [Date Created],
	lu_updated_by as [Created By]
FROM ITWORKSDS01.DIS.dbo.df_browse_manual_entry
WHERE charge_id IS NOT NULL
AND deleted_date_time IS NULL
AND costcentre_group_id = 'AB6E7119-BFE4-4C74-96E5-6A202CE4897A'
AND validated = 'NO'
ORDER BY lu_updated_datetime DESC