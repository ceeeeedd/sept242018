SELECT glc.gl_acct_code_code,
	   gl_account_name = glc.name_l,
	   service_provider = cc.name_l,
	   item.item_code,
	   item_desc = item.name_l,
	   item_type = item.item_type_rcd,
	   rbi.volume,
	   rbi.amount as revenue,
	   rbi.year,
	   rbi.month,
       transaction_type = case when ISNULL(rbi.deleted_flag,0) = 1 then 'Delete' else 'Charge' end,
       rbi.charge_type_rcd
from HISReport.dbo.rpt_bgt_revenue_detail rbi inner join AmalgaPROD.dbo.gl_acct_code glc on rbi.gl_acct_code_id = glc.gl_acct_code_id
								inner JOIN AmalgaPROD.dbo.costcentre cc on rbi.service_provider_costcentre_id = cc.costcentre_id
								inner join AmalgaPROD.dbo.item item on rbi.item_id = item.item_id
where rbi.month >= 7 and rbi.month <= 7
	 and rbi.year >= 2018 and rbi.year <= 2018
	 --rbi.year = @Year and rbi.month = @NoOfMonth
	--and rbi.charge_type_rcd in (@ChargeType)
	  --and item.item_code in ('090-20-1450',
			--				'090-20-0370',
			--				'090-20-0010',
			--				'090-30-2103',
			--				'210-10-0160',
			--				'100-30-0108',
			--				'090-10-0010',
			--				'090-20-0170',
			--				'090-20-0160',
			--				'210-40-0174',
			--				'090-20-0040',
			--				'090-20-0030',
			--				'090-20-0050',
			--				'090-20-0250',
			--				'090-20-0240',
			--				'090-45-0010',
			--				'090-45-0070',
			--				'110-10-0105',
			--				'084-30-0144',
			--				'110-10-0102')
		and ISNULL(rbi.deleted_flag,0) <> 1
order by rbi.year,rbi.month, glc.gl_acct_code_code,item.item_code