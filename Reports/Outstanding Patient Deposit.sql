select a.hn as [HN]
	  ,a.patient_name as [Patient Name] 
	  ,a.transaction_nr as [Transaction NR]
	  ,a.effective_date as [Effective Date]
	  ,a.visit_type as [Visit Type]
	  ,a.amount as [Amount]
	  ,a.deposit_type as [Deposit Type]
	  ,a.used_deposit_transaction_nr as [Used Deposit Transcation NR]
	  ,a.discharge_date as [Discharge Date]

from cnl.outstanding_patient_deposit a
--where month(a.effective_date) between 8 and 9 and
--	  year(a.effective_date) between 2018 and 2018
	  
order by a.effective_date, a.patient_name