------raw script

/** Volume and Revenue for Budget Report **/

DECLARE @month INT
DECLARE @year INT

SET @month = 7		--11256
SET @year = 2018

/** 1. Dump Charge Detail**/ 
INSERT INTO
	HISReport.dbo.rpt_bgt_charge_detail
		--Charges  
		SELECT
			cd.service_provider_costcentre_id
			,cd.gl_acct_code_id
			,pv.charge_type_rcd
			,cd.item_id    
			,YEAR(charged_date_time)
			,MONTH(charged_date_time)
			,SUM(cd.quantity) AS volume        
			,SUM(ROUND(cd.amount,2)) AS revenue        
			,CAST(0 AS bit) AS deleted_flag        
		FROM         
			--OrionSnapshotDaily.dbo.charge_detail_nl_view AS cd     
			AmalgaPROD.dbo.charge_detail_nl_view as cd
		INNER JOIN
			--OrionSnapshotDaily.dbo.patient_visit_nl_view AS pv ON cd.patient_visit_id = pv.patient_visit_id
			AmalgaPROD.dbo.patient_visit_nl_view as pv on cd.patient_visit_id = pv.patient_visit_id
		WHERE        
			MONTH(cd.charged_date_time) = @month
		AND
			YEAR(cd.charged_date_time) = @year
		AND cd.deleted_date_time IS NULL
		GROUP BY     
			cd.service_provider_costcentre_id
			,cd.gl_acct_code_id
			,pv.charge_type_rcd
			,cd.item_id    
			,YEAR(charged_date_time)
			,MONTH(charged_date_time)
	
		UNION ALL

		--Deletes 
		SELECT  
			cd.service_provider_costcentre_id
			,cd.gl_acct_code_id
			,pv.charge_type_rcd
			,cd.item_id    
			,YEAR(charged_date_time)
			,MONTH(charged_date_time)
			,SUM(-cd.quantity) AS volume        
			,SUM(ROUND(-cd.amount,2)) AS amount        
			,CAST(1 AS bit) AS deleted_flag        
		FROM         
			--OrionSnapshotDaily.dbo.charge_detail_nl_view AS cd     
			AmalgaPROD.dbo.charge_detail_nl_view as cd
		INNER JOIN
			--OrionSnapshotDaily.dbo.patient_visit_nl_view AS pv ON cd.patient_visit_id = pv.patient_visit_id
			AmalgaPROD.dbo.patient_visit_nl_view as pv on cd.patient_visit_id = pv.patient_visit_id
		INNER JOIN    
			--OrionSnapshotDaily.dbo.charge_delete_reason_ref AS cdr ON cd.charge_delete_reason_rcd = cdr.charge_delete_reason_rcd
			AmalgaPROD.dbo.charge_delete_reason_ref as cdr on cd.charge_delete_reason_rcd = cdr.charge_delete_reason_rcd
		WHERE        
			MONTH(cd.charged_date_time) = @month
		AND
			YEAR(cd.charged_date_time) = @year

		GROUP BY     
			cd.service_provider_costcentre_id
			,cd.gl_acct_code_id
			,pv.charge_type_rcd
			,cd.item_id    
			,YEAR(charged_date_time)
			,MONTH(charged_date_time)

GO

/******************************************************************/

select * from HISReport.dbo.rpt_bgt_charge_detail

select * from HISReport.dbo.rpt_bgt_item --186381

/** 2. Dump Distinct Items - Exclude DF and Balance Sheet **/ 
INSERT INTO HISReport.dbo.rpt_bgt_item				--6785
		SELECT DISTINCT
			RBCD.service_provider_costcentre_id
			,gl_acct_code_id
			,RBCD.item_id
			,RBCD.charge_type_rcd
			,GVI.item_type_rcd
		FROM HISReport.dbo.rpt_bgt_charge_detail RBCD INNER JOIN HISViews.dbo.GEN_vw_item GVI ON RBCD.item_id = GVI.item_id
		WHERE (GVI.item_type_rcd= 'SRV' AND GVI.sub_item_type_rcd = 'SRV')
			 AND RBCD.service_provider_costcentre_id NOT IN (SELECT costcentre_id FROM AmalgaPROD.dbo.costcentre where name_l = 'Balance Sheet') --OrionSnapshotDaily.dbo.costcentre WHERE name_l = 'Balance Sheet')
			 and RBCD.month = 7
			 and RBCD.year = 2018
		GROUP BY
			RBCD.service_provider_costcentre_id
			,RBCD.gl_acct_code_id
			,RBCD.item_id
			,RBCD.charge_type_rcd
			,GVI.item_type_rcd

		UNION ALL

		SELECT DISTINCT
			RBCD.service_provider_costcentre_id
			,RBCD.gl_acct_code_id
			,RBCD.item_id
			,RBCD.charge_type_rcd
			,GVI.item_type_rcd
		FROM HISReport.dbo.rpt_bgt_charge_detail RBCD INNER JOIN HISViews.dbo.GEN_vw_item GVI ON RBCD.item_id = GVI.item_id
		WHERE GVI.item_type_rcd= 'INV'
			 AND RBCD.service_provider_costcentre_id NOT IN (SELECT costcentre_id FROM AmalgaPROD.dbo.costcentre where name_l = 'Balance Sheet') --OrionSnapshotDaily.dbo.costcentre WHERE name_l = 'Balance Sheet')
			 and RBCD.month = 7
			 and RBCD.year = 2018
		GROUP BY
			RBCD.service_provider_costcentre_id
			,RBCD.gl_acct_code_id
			,RBCD.item_id
			,charge_type_rcd
			,GVI.item_type_rcd
GO	

/******************************************************************/

/** 3. Dump Revenue Detail- Exclude DF and Balance Sheet **/

INSERT INTO HISReport.dbo.rpt_bgt_revenue_detail		--9139
		SELECT *
		FROM HISReport.dbo.rpt_bgt_charge_detail
		WHERE item_id IN (SELECT item_id FROM HISViews.dbo.GEN_vw_item WHERE sub_item_type_rcd = 'SRV')
			AND	service_provider_costcentre_id NOT IN (SELECT costcentre_id FROM AmalgaPROD.dbo.costcentre where name_l = 'Balance Sheet') --OrionSnapshotDaily.dbo.costcentre WHERE name_l = 'Balance Sheet')
			and month = 7
			and year = 2018
		UNION ALL
		SELECT 
			*
		FROM HISReport.dbo.rpt_bgt_charge_detail
		WHERE item_id IN (SELECT item_id FROM HISViews.dbo.GEN_vw_item WHERE item_type_rcd = 'INV')
		   AND service_provider_costcentre_id NOT IN (SELECT costcentre_id FROM AmalgaPROD.dbo.costcentre where name_l = 'Balance Sheet') --OrionSnapshotDaily.dbo.costcentre WHERE name_l = 'Balance Sheet')
		   and month = 7
			and year = 2018


GO

/*****************************************************/
/*CHECKING IF DATA IS DUMPED PER MONTH*/
SELECT DISTINCT 
				year
				,month
FROM HISReport.dbo.rpt_bgt_revenue_detail
where year = 2018
group BY year
				,month
order by year,month 

/******************************************************************/

/*
/** 4. Generate Report **/

SELECT 
	costcentre_code = (SELECT costcentre_code FROM OrionSnapshotDaily.dbo.costcentre WHERE costcentre_id = RBI.service_provider_costcentre_id)
	,costcentre = (SELECT name_l FROM OrionSnapshotDaily.dbo.costcentre WHERE costcentre_id = RBI.service_provider_costcentre_id)
	,gl_acct_code_code = (SELECT gl_acct_code_code FROM OrionSnapshotDaily.dbo.gl_acct_code WHERE gl_acct_code_id = RBI.gl_acct_code_id)
	,gl_acct_code = (SELECT name_l FROM OrionSnapshotDaily.dbo.gl_acct_code WHERE gl_acct_code_id = RBI.gl_acct_code_id)
	,item_code = (SELECT item_code FROM OrionSnapshotDaily.dbo.item WHERE item_id = RBI.item_id)
	,item_description = (SELECT name_l FROM OrionSnapshotDaily.dbo.item WHERE item_id = RBI.item_id)
	,RBI.charge_type_rcd
	
	,RY.year_id
	,RM.month_id
	,volume = (	SELECT SUM(volume) 
				FROM HISReport.dbo.rpt_bgt_revenue_detail 
				WHERE service_provider_costcentre_id = RBI.service_provider_costcentre_id
				AND gl_acct_code_id = RBI.gl_acct_code_id
				AND item_id = RBI.item_id
				AND charge_type_rcd = RBI.charge_type_rcd
				AND year = RY.year_id
				AND month = RM.month_id)
	,revenue = (SELECT SUM(amount)	FROM HISReport.dbo.rpt_bgt_revenue_detail 
									WHERE service_provider_costcentre_id = RBI.service_provider_costcentre_id
				AND gl_acct_code_id = RBI.gl_acct_code_id
				AND item_id = RBI.item_id
				AND charge_type_rcd = RBI.charge_type_rcd
				AND year = RY.year_id
				AND month = RM.month_id)
FROM
	HISReport.dbo.rpt_bgt_item RBI, HISReport.dbo.ref_year RY, HISReport.dbo.ref_month RM
WHERE
	RY.year_id IN (2016)
AND
	RBI.item_type_rcd = 'SRV'
	--RBI.item_type_rcd = 'SRV'
order by month_id

select 
* 
from

HISReport.dbo.rpt_bgt_item RBI 
inner join  HISReport.dbo.rpt_bgt_revenue_detail RBRD
on RBI.service_provider_costcentre_id = RBRD.service_provider_costcentre_id

select * from  HISReport.dbo.ref_year RY, HISReport.dbo.ref_month RM

select * from HISReport.dbo.rpt_bgt_revenue_detail
select * from HISReport.dbo.rpt_bgt_item 
select * from HISReport.dbo.rpt_bgt_charge_detail

SELECT * FROM HISReport.dbo.rpt_bgt_revenue_detail  where service_provider_costcentre_id IN(select service_provider_costcentre_id from HISReport.dbo.rpt_bgt_item)

select * from HISReport.dbo.rpt_bgt_item RBI, HISReport.dbo.ref_year RY, HISReport.dbo.ref_month RM



select * from 	HISViews.dbo.GEN_vw_item GVI  where item_type_rcd='SRV'
--delete from HISReport.dbo.rpt_bgt_revenue_detail
--delete from HISReport.dbo.rpt_bgt_item 
--delete from HISReport.dbo.rpt_bgt_charge_detail



----------------------------formatting and report generation

SELECT 
	costcentre_code = (SELECT costcentre_code FROM OrionSnapshotDaily.dbo.costcentre WHERE costcentre_id = TI.service_provider_costcentre_id)
	,costcentre = (SELECT name_l FROM OrionSnapshotDaily.dbo.costcentre WHERE costcentre_id = TI.service_provider_costcentre_id)
	,gl_acct_code_code = (SELECT gl_acct_code_code FROM OrionSnapshotDaily.dbo.gl_acct_code WHERE gl_acct_code_id = TI.gl_acct_code_id)
	,gl_acct_code = (SELECT name_l FROM OrionSnapshotDaily.dbo.gl_acct_code WHERE gl_acct_code_id = TI.gl_acct_code_id)
	,item_code = (SELECT item_code FROM OrionSnapshotDaily.dbo.item WHERE item_id = TI.item_id)
	,item_description = (SELECT name_l FROM OrionSnapshotDaily.dbo.item WHERE item_id = TI.item_id)
	,TI.charge_type_rcd
	
	,TI.year_id
	,TI.month_id
	,volume = (	SELECT SUM(volume) 
				FROM HISReport.dbo.rpt_bgt_revenue_detail 
				WHERE service_provider_costcentre_id = TI.service_provider_costcentre_id
				AND gl_acct_code_id = TI.gl_acct_code_id
				AND item_id = TI.item_id
				AND charge_type_rcd = TI.charge_type_rcd
				AND year=TI.year_id
				AND month=TI.month_id)
	,revenue = (SELECT SUM(amount)	FROM HISReport.dbo.rpt_bgt_revenue_detail 
									WHERE service_provider_costcentre_id = TI.service_provider_costcentre_id
				AND gl_acct_code_id = TI.gl_acct_code_id
				AND item_id = TI.item_id
				AND charge_type_rcd = TI.charge_type_rcd
				AND year=TI.year_id
				AND month=TI.month_id)

FROM
	##temp_items TI
WHERE
	TI.year_id IN (2016)
AND
	TI.item_type_rcd = 'INV'
AND TI.month_id = 3
	--RBI.item_type_rcd = 'SRV'
order by month_id

select * FROM HISReport.dbo.rpt_bgt_revenue_detail  where year = 2016 and month = 3

select * from ##temp_items

select
 * 
into ##temp_items
FROM HISReport.dbo.rpt_bgt_item RBI, HISReport.dbo.ref_year RY, HISReport.dbo.ref_month RM
order by year_id,month_id

	
	select * FROM HISReport.dbo.rpt_bgt_item RBI where service_provider_costcentre_id IN(select service_provider_costcentre_id FROM HISReport.dbo.rpt_bgt_revenue_detail  where year=2016 and month = 3)
	


select
RBRD.service_provider_costcentre_id
,SUM(RBRD.amount)
,RBRD.month
FROM 
HISReport.dbo.rpt_bgt_revenue_detail RBRD
where 
year = 2016 
and month = 3
group by
RBRD.service_provider_costcentre_id
,RBRD.month

select * from HISReport.dbo.rpt_bgt_revenue_detail 
*/