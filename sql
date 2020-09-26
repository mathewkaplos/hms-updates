-- select issued from adempiere.hms_billing
--  update adempiere.hms_billing set issued ='N'








  	CREATE OR REPLACE FUNCTION adempiere.issue(
	bill_id numeric, pharm text)
    RETURNS numeric 
	   LANGUAGE 'plpgsql'
   AS $BODY$
    DECLARE
	q numeric:=(SELECT qty  FROM adempiere.hms_billing WHERE hms_billing_ID=$1);
	pro numeric:=(SELECT M_Product_ID  FROM adempiere.hms_billing WHERE hms_billing_ID=$1);
   BEGIN
UPDATE adempiere.hms_billing 
SET M_Warehouse_ID =1000007, issued_by =$2,issued='Y'
WHERE hms_billing_ID=$1;
UPDATE adempiere.M_storage SET qtyonhand =qtyonhand - q  WHERE 
M_locator_ID =1000007 AND M_Product_ID =pro 
AND m_attributesetinstance_id = (
SELECT MAX(m_attributesetinstance_id) FROM adempiere.M_storage WHERE 
M_locator_ID =1000007 AND M_Product_ID =pro);
return 0;
   END;
   $BODY$; 
   
--   select adempiere.issue(1281060 ,'you')






CREATE OR REPLACE view adempiere.treatments
AS 
 SELECT bill.hms_treatment_doc_ID , bill.hms_billing_ID,issued, is_prescription FROM adempiere.hms_billing bill 
				 INNER JOIN adempiere.m_product pro ON pro.M_Product_ID = bill.M_Product_ID
		 WHERE   bill.is_prescription ='Y'
			 AND pro.producttype='I' ;
		
	
	---	SELECT COUNT(1) FROM adempiere.treatments 		WHERE hms_treatment_doc_ID = 1038243  
			 
	CREATE OR REPLACE FUNCTION adempiere.get_all_prescription(
	treat_id numeric)
    RETURNS numeric 
	   LANGUAGE 'plpgsql'
   AS $BODY$
   BEGIN
  return (SELECT COUNT(1) FROM adempiere.treatments 
		WHERE hms_treatment_doc_ID = $1 AND is_prescription ='Y');
   END;
   $BODY$; 
   --  select adempiere.get_all_prescription(1053200)
   	CREATE OR REPLACE FUNCTION adempiere.get_IssuedDrugs(
	treat_id numeric)
    RETURNS numeric 
	   LANGUAGE 'plpgsql'
   AS $BODY$
   BEGIN
  return (SELECT COUNT(1) FROM adempiere.treatments 
		WHERE hms_treatment_doc_ID = $1 AND is_prescription ='Y' AND issued ='Y');
   END;
   $BODY$; 
	--- 	 select adempiere.get_IssuedDrugs(1053200)

   	CREATE OR REPLACE FUNCTION adempiere.get_getUnIssuedDrugs(
	treat_id numeric)
    RETURNS numeric 
	   LANGUAGE 'plpgsql'
   AS $BODY$
   BEGIN
  return (SELECT COUNT(1) FROM adempiere.treatments 
		WHERE hms_treatment_doc_ID = $1 AND is_prescription ='Y' AND issued ='N');
   END;
   $BODY$; 
	-- 	 select adempiere.get_getUnIssuedDrugs(1053201)




   	CREATE OR REPLACE FUNCTION adempiere.update_treatment_doc(
	treat_id numeric)
    RETURNS numeric 
	   LANGUAGE 'plpgsql'
   AS $BODY$
   BEGIN
UPDATE adempiere.hms_treatment_doc SET drugs_ordered =adempiere.get_all_prescription(hms_treatment_doc_id),
drugs_issued =adempiere.get_IssuedDrugs(hms_treatment_doc_id),
drugs_not_issued = adempiere.get_getUnIssuedDrugs(hms_treatment_doc_id) WHERE hms_treatment_doc_ID =$1;
UPDATE  adempiere.m_storage set qtyonhand=0 WHERE qtyonhand<0 and m_locator_id=1000007;
UPDATE adempiere.m_storage  SET qtyonhand = 
CAST(to_char(qtyonhand, 'FM999999999990.999999') AS NUMERIC);
return 0;
   END;
   $BODY$; 

--  select adempiere.update_treatment_doc(1053200)
--   select adempiere.issue(1281060 ,'you')

--  update  adempiere.hms_billing set issued ='N' where hms_treatment_doc_id =1053201


