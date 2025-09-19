CREATE VIEW [dbo].[v_PRN_Obligations] AS With 
org As (  
/****************************************************************************************************************************
	History:
 
	Created: 2024-11-20:	SN001:	Ticket - 464577:	Creation of View for Obligations for POwer BI reporting
	Updated: 2024-11-28:	SN002:						Added Summ PrnTonnage and concatenated Address to reduce DAX usage4
	Updated: 2025-01-13		SN003:						Include Ability to map CSIds 
	Updated: 2025-01-30		SN004:	Ticket  - 501253	ComplianceSchemes not in Metafile data joined by Companies House no.
	Updated: 2025-02-28		SN006:	N/A					v_Organisations_Active replaced with v_Organisations_Active_pom
	Updated: 2025-03-18		SN007:	Ticket - 527574		Change to accomodate MaterialId replacing MaterialName
	Updated: 2025-02-28		SN008:	Ticket - 527557		Update cs_ch Nation to remove duplicate nation in UNION
	Updated: 2025-06-30		SN009:	Ticket - 552710		Update Update to take into account SubmitterId addition columns in 
														ObligationCalculations
	Updated: 2025-06-30		SN010:						Regrouping Material to match front end PRN
	Updated: 2025-08-05		SN011:	Ticket - 513680     Added NationId to check the RLS (Row level security) for PRN Details and Obligations Power BI report
	Updated: 2025-09-04		SN012:  Replace o.Name with cs.Name in CTEs csa and cs_ch
******************************************************************************************************************************/

/*** SN:003 ***/
	Select
		 o.ExternalID
		,OrganistionName		= o.[Name]
		,o.ReferenceNumber
		,o.NationId
		,o.IsComplianceScheme
		,o.Town
		,o.Postcode 
		,o.SubBuildingName
		,o.BuildingNumber
		,o.BuildingName
		,o.Street
		,o.Country
		,o.County
		,o.ValidatedWithCompaniesHouse
		,RowNumber	=1
	From
		dbo.v_rpd_Organisations_Active_pom	o /*** SN006: Replaced ***/
),
cs_ch As (  /*** SN004: Added ***/
	Select
	 cs.ExternalID
	,OrganistionName		= cs.[Name]  /** SN012: **/
	,o.ReferenceNumber
	,NationId = Case When IScomplianceScheme = 1 Then cs.NationId Else o.NationId End  /*** SN008: Updated ***/
	,o.IsComplianceScheme
	,o.Town
	,o.Postcode
	,o.SubBuildingName
	,o.BuildingNumber
	,o.BuildingName
	,o.Street
	,o.Country
	,o.County
	,o.ValidatedWithCompaniesHouse
	,RowNumber	=1
From
	dbo.v_rpd_Organisations_Active_pom	o /*** SN006: Replaced ***/
Join
	rpd.ComplianceSchemes			cs On o.CompaniesHouseNumber = cs.CompaniesHouseNumber
), /*** SN004: Added ***/
csa As (
	Select  
		 ExternalID			= c.ComplianceSchemeId
		,OrganistionName	= cs.[Name]				/** SN012: **/
		,ReferenceNumber	= o.ReferenceNumber
		,cs.NationId		
		,IsComplianceScheme = 1
		,o.Town
		,o.PostCode
		,o.SubBuildingName
		,o.BuildingNumber
		,o.BuildingName
		,o.Street
		,o.Country
		,o.County
		,o.ValidatedWithCompaniesHouse
		,RowNumber			= Row_Number() Over(Partition by c.organisationid,c.submissionperiod order by CONVERT(DATETIME, Substring(c.[created], 1, 23)) desc ) 
	From 
		dbo.v_rpd_Organisations_Active_pom o
	Join 
		rpd.cosmos_file_metadata	c	On o.externalid = c.organisationid
	Join 
		rpd.ComplianceSchemes		cs	On c.ComplianceSchemeId = cs.externalid And FileType = 'CompanyDetails'
	Where 
		o.IsComplianceScheme = 1 
),
org_csa As (
	Select 
		 org.ExternalID		
		,org.OrganistionName
		,org.ReferenceNumber	
		,org.NationId
		,org.IsComplianceScheme 
		,org.Town
		,org.PostCode
		,org.SubBuildingName
		,org.BuildingNumber
		,org.BuildingName
		,org.Street
		,org.Country
		,org.County
		,org.ValidatedWithCompaniesHouse
	From 
		org
	Union
	Select 
		 csa.ExternalID
		,csa.OrganistionName
		,csa.ReferenceNumber	
		,csa.NationId
		,csa.IsComplianceScheme 
		,csa.Town
		,csa.PostCode
		,csa.SubBuildingName
		,csa.BuildingNumber
		,csa.BuildingName
		,csa.Street
		,csa.Country
		,csa.County
		,csa.ValidatedWithCompaniesHouse
	From 
		csa 
	Where csa.RowNumber = 1
	 /*** SN004: Added ***/
	Union
	Select 
		 cs_ch.ExternalID	
		,cs_ch.OrganistionName
		,cs_ch.ReferenceNumber	
		,cs_ch.NationId
		,cs_ch.IsComplianceScheme 
		,cs_ch.Town
		,cs_ch.PostCode
		,cs_ch.SubBuildingName
		,cs_ch.BuildingNumber
		,cs_ch.BuildingName
		,cs_ch.Street
		,cs_ch.Country
		,cs_ch.County
		,cs_ch.ValidatedWithCompaniesHouse
	From 
		cs_ch 
),
pmm As ( /*** Select Distinct to avoid cartisian join issue ***/
	Select Distinct
		 PRNMaterialId	
		,PRNMaterialCode
		,PRNMaterialName
		,PRNMaterialGroupName
		,PRNMaterialGroupNameIncGlass
	From 
		dbo.v_PRN_MaterialGroups /*** SN010: ***/	
),

prnLtst As (
	Select
		 p.OrganisationId
		,p.ExternalOrgId
		,p.ObligationYear
		,p.PrnSignatory
		,p.PrnSignatoryPosition
		,p.[Signature]
		,pmm.PRNMaterialGroupName
		--,MaxDate = Max(IsNull(p.StatusUpdatedOn,p.CreatedOn))
		,IsLatest				= Row_Number() Over(Partition By p.OrganisationId,pmm.PRNMaterialGroupName Order By IsNull(p.StatusUpdatedOn,p.CreatedOn) Desc)
	From 
				dbo.v_PRN_Details					p
	Left Join
		dbo.v_PRN_MaterialGroups pmm 
			on p.MaterialName = pmm.PRNMaterialName
	
),

obgns As (
	Select 
		 ExternalOrgId			= ob.SubmitterId
		,o.OrganistionName
		,ProducerType			= ost.TypeName
		,OrganisationId			= o.[ReferenceNumber]
		--,m.MaterialName			/*** SN007: Added ***/
		,FEMaterialName			= pmm.PRNMaterialGroupName
		,MaterialObligationValue
		,ObligationYear			= [Year]
		,CalculatedOn			
		,Tonnage
		,LatestFlg				= Case Row_Number() Over (Partition By ob.OrganisationId, m.MaterialName, [Year] Order By CalculatedOn Desc) When 1 Then 1 Else 0 End
		,PrnObliJoin			= Concat(Ltrim(Rtrim(ob.SubmitterId)),'-',Ltrim(Rtrim(m.MaterialName)),'-',Ltrim(Rtrim([Year])))
		/*** vvvv ** SN002 ** vvvv ***/
		,ContactAddress			= Concat(Case When Ltrim(Rtrim(o.SubBuildingName)) Is Null  Then '' Else Ltrim(Rtrim(o.SubBuildingName))+', ' End,	
										Ltrim(Rtrim(o.BuildingNumber))+ ' ', 
										Case When Ltrim(Rtrim(o.BuildingName)) Is Null  Then '' Else Ltrim(Rtrim(o.BuildingName))+', ' End,
											Ltrim(Rtrim(o.Street)) 
									)
									
		/*** ^^^^ ** SN002 ** ^^^^ ***/
      ,[Town]
      ,[County]
      ,[Country]
      ,[Postcode]
      ,[ValidatedWithCompaniesHouse]
      ,[IsComplianceScheme]
	  ,pl.PrnSignatory
	  ,pl.PrnSignatoryPosition
	  ,pl.[Signature]
	  ,o.NationId  --513680--

	From 
		rpd.ObligationCalculations	ob
	/*** SN007: Added ***/
	Left Join
		rpd.Material				m
			on ob.MaterialId = m.Id 								/*** SN:009 ***/
	Join
		org_csa	o
			on ob.SubmitterId = o.ExternalID 	/*** SN:009 ***/
	Left Join
		rpd.ObligationCalculationOrganisationSubmitterType			ost
			on ob.SubmitterTypeId = ost.Id
	Left Join
		pmm 
			on m.MaterialName = pmm.PRNMaterialName
	Left Join
		prnLtst		pl	on ob.SubmitterId=pl.ExternalOrgId 
							and  pmm.PRNMaterialGroupName = pl.PRNMaterialGroupName
								And  pl.Islatest = 1
	Where  ob.IsDeleted = 0 
), 
/*** vvvv ** SN002 ** vvvv ***/
prnTt As (
	Select
		 p.OrganisationId		
		,p.ExternalOrgId
		,MaterialName		= p.MaterialName
		,p.ObligationYear
		,AcceptedTonnage	= sum(Case When PrnStatus='Prn Accepted' Then p.TonnageValue Else 0 End)
		,AwaitingTonnage	= sum(Case When PrnStatus='Prn Awaiting Acceptance' Then p.TonnageValue Else 0 End)
		,PrnObliJoin		= Concat(Ltrim(Rtrim(p.ExternalOrgId)),'-',p.MaterialName  ,'-',Ltrim(Rtrim(p.ObligationYear)))
	From 
			dbo.v_PRN_Details					p	
	Group By
		 p.ExternalOrgId
		,p.OrganisationId
		,p.ObligationYear
		,p.MaterialName
),

obgnsGrp As (
	Select
		 o.ExternalOrgId
		,o.OrganistionName
		,o.OrganisationId
		,ProducerType						
		,o.FEMaterialName						/*** SN010: ***/
		,Tonnage				= Max(Tonnage)
		,o.ObligationYear
		,CalculatedOn			= Max(CalculatedOn)
		,LatestFlg
		,PrnObliJoin=o.PrnObliJoin				/*** SN010: ***/
		,ContactAddress
		,Town
		,County
		,Country
		,Postcode	
		,ValidatedWithCompaniesHouse
		,IsComplianceScheme
		,o.PrnSignatory
		,o.PrnSignatoryPosition
		,o.[Signature]
		,MaterialObligationValue =  sum(MaterialObligationValue)
		,o.NationId   --513680---
	From
		obgns		o
	Where o.LatestFlg = 1
	Group By
		 o.ExternalOrgId
		,OrganistionName
		,o.OrganisationId
		,ProducerType
		---,o.MaterialName			/*** SN010: ***/
		,o.FEMaterialName
		,o.ObligationYear
		,LatestFlg
		,o.PrnObliJoin				/*** SN010: ***/
		,ContactAddress
		,Town
		,County
		,Country
		,Postcode
		,ValidatedWithCompaniesHouse
		,IsComplianceScheme
		,o.PrnSignatory
		,o.PrnSignatoryPosition
		,o.[Signature]	
		,o.NationId   --513680---
)

/*** ^^^^ ** SN002 ** ^^^^ ***/
	Select 
		 o.ExternalOrgId
		,OrganistionName
		,o.OrganisationId
		,o.ProducerType		
		,o.FEMaterialName
		,o.ObligationYear				
		,o.ContactAddress
		,o.Town
		,o.County
		,o.Country
		,o.Postcode
		,o.ValidatedWithCompaniesHouse
		,o.IsComplianceScheme
		,o.PrnSignatory
		,o.PrnSignatoryPosition
		,o.[Signature]
		,MaterialObligationValue = sum(o.MaterialObligationValue)
		,AcceptedTonnage	= Sum(IsNull(p.AcceptedTonnage,0))				/** SN002 **/
		,AwaitingTonnage	= Sum(IsNull(p.AwaitingTonnage,0))
		,RemainObligation	= Sum(o.MaterialObligationValue) - Sum(IsNull(p.AcceptedTonnage,0))
		,RemainStatus = Case When Sum(o.MaterialObligationValue) - Sum(IsNull(p.AcceptedTonnage,0)) >0 Then 'Not Met' Else 'Met'	End	
		,Nation	= IsNull(na.[Name],'Not Set')  --513680---
	From
		obgnsgrp		o
	Left Join
		prntt			p		
			on o.PrnObliJoin  = p.PrnObliJoin
	--513680 Start--
	Left Join
	rpd.nations			na
		on o.NationId = na.Id
	--513680 End--
	
	Group By
		o.ExternalOrgId
		,OrganistionName
		,o.OrganisationId
		,o.ProducerType		
		,o.FEMaterialName
		,o.ObligationYear			
		,o.ContactAddress
		,o.Town
		,o.County
		,o.Country
		,o.Postcode
		,o.ValidatedWithCompaniesHouse
		,o.IsComplianceScheme
		,o.PrnSignatory
		,o.PrnSignatoryPosition
		,o.[Signature]
		,na.[Name];