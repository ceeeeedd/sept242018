--journal entries (GL JOURNAL TRANSACTIONS)

declare @company_code varchar(3)
declare @from_effective_date datetime
declare @to_effective_date datetime

set @company_code = 'AHI'
set @from_effective_date = @From
set @to_effective_date = @To

select 		gt.transaction_text as transaction_number
			,gt.transaction_date_time as transaction_date
			,gt.effective_date
			,gt.gl_manual_journal_no as journal_number
			,REPLACE(REPLACE(gt.transaction_description,'''','*'),'"','*') as journal_description
			,REPLACE(REPLACE(gt.transaction_comment,'''','*'),'"','*') as comment
			,gac.gl_acct_code_code as account_code
			--,gac.name_e as account_name_e
			,gac.name_l as account_name_l
			,cc.costcentre_code
			--,cc.name_e as costcentre_name_e
			,cc.name_l as costcentre_name_l
			,debit_amount = case when debit_flag = 1 then amount else null end
			,credit_amount = case when debit_flag = 0 then amount else null end
			,detail_description = case when isnull(gtd.description, '') <> gt.transaction_description then case when isnull(gtd.description, '') <> '' then REPLACE(REPLACE(gtd.description,'''','*'),'"','*') else null end end
			--,pfn.display_name_e as created_by_e
			,pfn.display_name_l as created_by_l
			--,coalesce(gpt.name_e, 'General Ledger') as source_e
			,coalesce(gpt.name_l, 'General Ledger') as source_l
from		gl_transaction_nl_view gt
inner join	gl_transaction_detail_nl_view gtd on gtd.gl_transaction_id = gt.gl_transaction_id 
inner join	gl_acct_code_nl_view gac on gac.gl_acct_code_id = gtd.gl_acct_code_id
inner join	costcentre_nl_view cc on cc.costcentre_id = gtd.costcentre_id
left join	user_account_nl_view ua on ua.user_id = gt.created_by_user_id
left  join	person_formatted_name_iview_nl_view pfn on pfn.person_id = ua.person_id
left join	gl_posting_type_ref_nl_view gpt on gpt.gl_posting_type_rid = gt.gl_posting_type_rid
where		month(gt.effective_date) between @from_effective_date and @to_effective_date and
			year(gt.effective_date) = @year
and			gt.company_code = @company_code
and			gt.transaction_status_rcd = 'POS'
order by	gt.effective_date 
			,gt.transaction_text
			,debit_flag


