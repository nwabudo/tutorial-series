CREATE OR REPLACE FUNCTION BEFORE_EOD_BALANCE(p_acid varchar2,p_date DATE) return number as
v_pbal number:=0;
v_totalCRbal number:=0;
v_totalDRbal number:=0;
v_totalbal number:=0;
v_acctNo varchar2(10);

BEGIN
Begin
SELECT accountNo,tran_date_bal as previous_bal,sum(nvl(decode(part_tran_type,’C’,tran_amt),0)) 
as today_total_credit, sum(nvl(decode(part_tran_type,’D’,tran_amt),0)) as today_total_debit 
INTO v_acctNo,v_pbal,v_totalCRbal,v_totalDRbal FROM general_master a,endofday b,dailytransaction c 
WHERE a.acid = b.acid AND a.acid = c.acid AND c.acid = b.acid AND acct_cls_flg=’N’ AND entity_cre_flg=’Y’ 
AND c.eod_date = (SELECT max(eod_date) FROM (SELECT acid, eod_date FROM endofday where acid = p_acid 
GROUP BY acid,eod_date HAVING max(eod_date) < p_date)) AND a.acid = p_acid AND d.del_flg =’N’ AND pstd_flg = ‘Y’ 
AND tran_date = p_date GROUP BY foracid,tran_date_bal;

End;
v_totalbal:=greatest(v_pbal + v_totalCRbal — v_totalDRbal,0);
return v_totalbal;

End BEFORE_EOD_BALANCE;
