CREATE VIEW [dbo].[v_POM_Org_Names]
AS SELECT distinct
dsf.FromOrganisation_Name [Org_Name]

 FROM [dbo].[v_Pom] p
   join [dbo].[v_rpd_data_SECURITY_FIX] dsf
 on p.[organisation_id]  = dsf.[FromOrganisation_ReferenceNumber] 
   join [dbo].[v_cosmos_file_metadata] meta
 on p.filename = meta.filename;