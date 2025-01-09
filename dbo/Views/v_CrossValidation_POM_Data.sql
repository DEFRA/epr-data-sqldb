CREATE VIEW [dbo].[v_CrossValidation_POM_Data]
AS (
/*****************************************************************************************************************
	History:

	Created 2024-07-23: ST000: View contains POM (packaging data) - The data on rpd.POM is not held at a per file level
								Instead, a record is given for each submission of packaging_activity/Packaging_Type
								Therefore - the script has to pivot the data so that we sum up the various packaging weights into the respective packaging activites
	Updated 2024-MM-DD: 

*****************************************************************************************************************/


SELECT
pvt.organisation_id, 
pvt.subsidiary_Id,
pvt.organisation_size,
pvt.fileName,
sp.text as SubmissionPeriod_PackagingDataFile,
CASE WHEN sub1.Decision IS NULL THEN 'Pending' 
ELSE sub1.Decision 
END as Packaging_Data_Status,
c.created as SubmissionDate_PackagingDataFile,
[SO] AS BrandOwner,	
[IM] AS Importer,	
[PF] PackerFiller,	
[HL] ServiceProvider,	
[SE] Distributor,	
[OM] OnlineMktplace,
sub1.rn
FROM
(SELECT Organisation_Id, subsidiary_Id, organisation_size, FileName, submission_period, Packaging_activity, Packaging_material_weight 
FROM rpd.POM ) sub
PIVOT
(SUM(packaging_material_weight)
FOR Packaging_Activity IN
([SO], [IM], [PF], [HL], [SE], [OM])
) AS pvt
LEFT JOIN dbo.t_PoM_Codes sp ON sp.Code = pvt.submission_period AND sp.Type = 'submission_period'
LEFT JOIN  rpd.cosmos_file_metadata c ON c.FileName = pvt.FileName
--Possible to have multiple Submission events associated to the file
--Subquery finds the latest submission event
LEFT JOIN (SELECT fileid, Decision, load_ts, row_number() over (Partition by fileid Order by Load_ts desc) as rn 
			FROM [rpd].[SubmissionEvents] se WHERE  se.[type] = 'RegulatorPoMDecision'
			) sub1 on sub1.fileid = c.fileid
--Making sure to just bring back the latest submission event to avoid duplicate records
WHERE sub1.rn = 1);