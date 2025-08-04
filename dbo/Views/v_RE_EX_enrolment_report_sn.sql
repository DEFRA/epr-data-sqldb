CREATE VIEW [dbo].[v_RE_EX_enrolment_report_sn]
AS With enrolmentBase as (
/****************************************************************************************************************************
	History:
 
	Created: 2025-07-08:	SN001:	Ticket - 563084: Performance improvements

****************************************************************************************************************************/

Select 
	 ApprovedPerson_Email
	,ApprovedPerson_FirstName
	,ApprovedPerson_LastName
	,ApprovedPerson_LastUpdatedOn	
	,ApprovedPerson_JobTitle
	,ApprovedPerson_Telephone
	,ComplianceSchemes_Name
	,Enrolment_CreatedOn 
	,Enrolment_ExternalId
	,Enrolment_Id
	,EnrolmentStatuses_EnrolmentStatus
    ,[FromOrganisation_TypeId]
     ,[FromOrganisation_Type]
     ,[FromOrganisation_CompaniesHouseNumber]
      ,[FromOrganisation_Name]
      ,[FromOrganisation_TradingName]
      ,[FromOrganisation_ReferenceNumber]
      ,[FromOrganisation_SubBuildingName]
      ,[FromOrganisation_BuildingName]
      ,[FromOrganisation_BuildingNumber]
      ,[FromOrganisation_Street]
      ,[FromOrganisation_Locality]
      ,[FromOrganisation_DependentLocality]
      ,[FromOrganisation_Town]
      ,[FromOrganisation_County]
      ,[FromOrganisation_Country]
      ,[FromOrganisation_Postcode]
      ,[FromOrganisation_ValidatedWithCompaniesHouse]
      ,[FromOrganisation_IsComplianceScheme]
      ,[FromOrganisation_NationId]
	  ,[FromOrganisation_NationName]
	,CONVERT(int,Organisations_Id) AS Organisations_Id
	,ServiceRoles_Role
	,Services_Key
	,[Status]
	,SelectedSchemes_IsDeleted
	,[Security_Id]
    ,[SecurityQuery]
	,[OrganisationConnections_CreatedOn]
	,Persons_Id
	/*** SN001:  Moved inside main query ***/
	,Case When Row_Number () over(partition by [FromOrganisation_ReferenceNumber],Persons_Id, SecurityQuery
				Order By isnull(SelectedSchemes_IsDeleted, '0') asc, isnull(Convert(DATETIME,substring([OrganisationConnections_CreatedOn],1,23)), getdate()) )=1 
					And ISNULL(SelectedSchemes_IsDeleted,0) = 0 
						then 'Latest Enrolment' 
				Else 'Old Enrolment' 
			End IsLatestEnrolment
From
	[dbo].[v_rpd_data_SECURITY_FIX_for_enrolment] 

/*** SN001:  Moved inside main query ***/
where Services_Key='ReprocessorExporter' -- only returns Re/EX organisations
and serviceRoles_role ='Approved Person'

	/*this is the base query used in v_enrolment_report with some fields removed and others added */
),

/*** SN001:  Moved inside main query, commented out for now ***/
--src as (
--		Select 	 
--			 eb.*
			
--			,Case When Row_Number () over(partition by [FromOrganisation_ReferenceNumber],Persons_Id, SecurityQuery
--				Order By isnull(SelectedSchemes_IsDeleted, '0') asc, isnull(Convert(DATETIME,substring(eb.[OrganisationConnections_CreatedOn],1,23)), getdate()) )=1 
--					And ISNULL(SelectedSchemes_IsDeleted,0) = 0 
--						then 'Latest Enrolment' 
--				Else 'Old Enrolment' 
--			End IsLatestEnrolment

--		From 
--			enrolmentBase eb  
--		) /*This is the same logic from the v_enrolment_report view */
--,
cte_OrganisationPerson as 
(
	SELECT poc.ID,poc.OrganisationID, poc.PersonID,
 per.FirstName, per.LastName,per.Email, per.Telephone,
Row_Number () over(partition by poc.OrganisationID
				Order By poc.CreatedOn asc) as ConnectionOrder

				from rpd.PersonOrganisationConnections poc inner join rpd.Persons per on poc.PersonID=per.ID
) /*This finds all the people connected to an organisation order by created on date to allow us to find the first*/
,
cte_OrganisationFirstPerson as 
(
	SELECT * from cte_OrganisationPerson where ConnectionOrder=1
) /*This returns the earliest person connected to an organisation, this must be the account creator */



SELECT 
[FromOrganisation_Name] as OrganisationName
,[FromOrganisation_ReferenceNumber] as OrganisationId
,[FromOrganisation_TradingName] as OrganisationTradingName
,[FromOrganisation_Type] as OrganisationType
,[FromOrganisation_ValidatedWithCompaniesHouse] as ListedOnCompaniesHouse
,[FromOrganisation_Name] as CompaniesHouseName
,[FromOrganisation_CompaniesHouseNumber] as CompaniesHouseNumber
,CASE WHEN FromOrganisation_subbuildingname is  null then
		CASE WHEN FromOrganisation_BuildingName is null then
				trim(concat( FromOrganisation_BuildingNumber,' ' ,FromOrganisation_street)) 
		ELSE
				trim(concat( FromOrganisation_buildingname, ' ', FromOrganisation_BuildingNumber,' ' ,FromOrganisation_street)) 
		END
	else
			trim(concat(FromOrganisation_subbuildingname,' ', FromOrganisation_buildingname, ' ', FromOrganisation_BuildingNumber,' ' ,FromOrganisation_street)) 
	end
	as FirstLineofAddress
, trim(concat(FromOrganisation_Locality,' ', FromOrganisation_DependentLocality)) as SecondLineOfAddress
, FromOrganisation_Town as Town 
, FromOrganisation_Postcode as PostCode
,[Enrolment_CreatedOn] as EnrolmentDate
,[FromOrganisation_NationName] as NationOfEnrolment
, ofp.FirstName as AccountCreatorFirstName
, ofp.lastName as AccountCreatorLastName
, ofp.Telephone as AccountCreatorTelephone
, ofp.Email as AccountCreatorEmail
,[ApprovedPerson_JobTitle] As APRole
,[ApprovedPerson_FirstName] as APFirstName
,[ApprovedPerson_LastName] as APLastName
,[ApprovedPerson_Telephone] as APTelephone
,[ApprovedPerson_Email] as APEmail
,[IsLatestEnrolment] as IsLatestEnrolment
  FROM enrolmentBase eb    /*** SN001:  enrolementBase replaced src ***/
  inner join cte_OrganisationFirstPerson ofp on eb.Organisations_id=ofp.OrganisationID;