CREATE VIEW [dbo].[v_POM_FileNames]
AS SELECT distinct
p.FileName

 FROM [dbo].[v_Pom] p
   join [dbo].[v_rpd_data_SECURITY_FIX] dsf
 on p.[organisation_id]  = dsf.[FromOrganisation_ReferenceNumber] 
   join [dbo].[v_cosmos_file_metadata] meta
 on p.filename = meta.filename;