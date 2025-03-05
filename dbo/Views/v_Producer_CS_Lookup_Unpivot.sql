CREATE VIEW [dbo].[v_Producer_CS_Lookup_Unpivot] AS SELECT DISTINCT Producer_Id
,Producer_Name
,Operator_Id
,Operator_Name
,Operator_CompaniesHouseNumber
,CS_Id
,CS_Name
,Submission_Type
,StartPoint
,SecurityQuery


FROM dbo.t_Producer_CS_Lookup_Pivot

UNPIVOT (
    SecurityQuery FOR Producer_Or_CS IN (Producer_Nation, CS_Nation)
) unpvt;