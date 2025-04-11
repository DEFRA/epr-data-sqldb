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
******************************************************************************************************************************/

/*** SN:003 ***/
	Select
		 o.ExternalID
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
		 csa.ExternalID			
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
),
pmm As (
	Select 
		 pmm.PRNMaterialId
		,pmm.NPWDMaterialName
		,PRNMaterialCode	= m.MaterialCode
		,PRNMaterialName	= m.MaterialName
	From 
		rpd.PrnMaterialMapping	pmm
	Left Join
		rpd.Material			m
			on pmm.PRNMaterialId = m.Id
),
obgns As (

	Select
		 ExternalOrgId			= ob.OrganisationId
		,OrganisationId			= o.[ReferenceNumber]
		,m.MaterialName			/*** SN007: Added ***/
		,MaterialObligationValue
		,ObligationYear			= [Year]
		,CalculatedOn
		,Tonnage
		,LatestFlg				= Case Row_Number() Over (Partition By ob.OrganisationId, MaterialName, [Year] Order By CalculatedOn Desc) When 1 Then 1 Else 0 End
		,PrnObliJoin			= Concat(Ltrim(Rtrim(ob.OrganisationId)),'-',Ltrim(Rtrim(MaterialName)),'-',Ltrim(Rtrim([Year])))
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
	From 
		rpd.ObligationCalculations	ob
	/*** SN007: Added ***/
	Left Join
		rpd.Material				m
			on ob.MaterialId = m.Id
	Join
		org_csa	o
			on ob.OrganisationId = o.ExternalID
), 
/*** vvvv ** SN002 ** vvvv ***/

prnTt As (
	Select
		 p.OrganisationId
		,MaterialName		= Coalesce(pmm.PRNMaterialName,p.MaterialName,null) 
		,p.ObligationYear
		,TotTonnage			= sum(p.TonnageValue)
		,PrnObliJoin		= Concat(Ltrim(Rtrim(p.OrganisationId)),'-',Ltrim(Rtrim(Coalesce(pmm.PRNMaterialName,p.MaterialName,null))),'-',Ltrim(Rtrim(p.ObligationYear)))
	From 
			rpd.Prn					p
	left Join
			pmm
				on rTrim(p.MaterialName) = rTrim(pmm.NPWDMaterialName)
	Group By
		 p.OrganisationId
		,Coalesce(pmm.PRNMaterialName,p.MaterialName,null) 
		,p.ObligationYear
)


/*** ^^^^ ** SN002 ** ^^^^ ***/

	Select 
		o.*
		,TotTonnage			= IsNull(p.TotTonnage,0)				/** SN002 **/
		,RemainObligation	= o.MaterialObligationValue - IsNull(p.TotTonnage,0)
	From
		obgns		o
	left Join
		prnTt		p on o.PrnObliJoin=p.PrnObliJoin
	Where 
		o.LatestFlg = 1;