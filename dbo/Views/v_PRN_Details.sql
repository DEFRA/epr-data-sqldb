CREATE VIEW [dbo].[v_PRN_Details] AS With st As (
/****************************************************************************************************************************
	History:
 
	Created: 2024-11-20:	SN001:	Ticket - 464576:	Creation of View for PRN details for POwer BI reporting
	Updated: 2024-12-13		SN002:						Typo on nation description
	Updated: 2025-01-13		SN003:						Include Ability to map CSIds
	Updated: 2025-01-29		SN004:	Ticket  - 501685	Remove Duplicate Status coming from PrnStatusHistory
	Updated: 2025-01-30		SN005:	Ticket  - 501253	ComplianceSchemes not in Metafile data joined by Companies House no.
	Updated: 2025-02-28		SN006:	N/A					v_Organisations_Active replaced with v_Organisations_Active_pom
	Updated: 2025-02-28		SN007:	Ticket	- 527575	Added PRNMaterialMapping table to resolve NPWD and PRN materialname mismatch
	Updated: 2025-02-28		SN008:	Ticket	- 527557	Update cs_ch Nation to remove duplicate nation in UNION
*****************************************************************************************************************************/
	Select 
		 PrnStatusHistoryId		= sth.Id
		,PrnIdFk				= sth.PrnIdFk
		,PrnStatusName			= st.StatusName 
		,PrnStatusDate			= sth.CreatedOn
		,IsLatest				= Row_Number() Over (Partition By sth.PrnIdFk Order By sth.Id Desc)  /*** SN0004: Added ***/
	From
		rpd.PrnStatusHistory	sth
	Left Join 
		rpd.PrnStatus			st	on sth.PrnStatusIdFk = st.Id
),

st_pvt As (
	Select  
		 PrnStatusHistoryId	
		,PrnIdFk	
		,PrnAcceptedDate			= ACCEPTED	
		,PrnRejectedDate			= REJECTED	
		,PrnCancelledDate			= CANCELLED	
		,PrnAwaitingAcceptanceDate	= AWAITINGACCEPTANCE
	From  st 
	Pivot (		
			Max(PrnStatusDate) for PrnStatusName In ([ACCEPTED],[REJECTED],[CANCELLED],[AWAITINGACCEPTANCE])
	) stp Where IsLatest=1			/*** SN0004: Added ***/
), 

/*** SN007: Added ***/
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
), /*** SN007: Added ***/
org As (  /*** SN:003 ***/
	Select
		 o.ExternalID
		,o.ReferenceNumber
		,o.NationId
		,o.IsComplianceScheme
		,o.Town
		,o.Postcode 
		,RowNumber	=1
	From
		dbo.v_rpd_Organisations_Active_POM	o /*** SN006: Replaced ***/
),
cs_ch As (  /*** SN005: Added ***/
	Select
		 cs.ExternalID
		,o.ReferenceNumber
		,NationId = Case When IScomplianceScheme = 1 Then cs.NationId Else o.NationId End  /*** SN008: Updated ***/
		,o.IsComplianceScheme
		,o.Town
		,o.Postcode 
		,RowNumber	=1
	From
		dbo.v_rpd_Organisations_Active_POM	o		/*** SN006: Replaced ***/
	Join
		rpd.ComplianceSchemes			cs On o.CompaniesHouseNumber = cs.CompaniesHouseNumber
),
csa As (
	Select  
		 ExternalID			= c.ComplianceSchemeId
		,ReferenceNumber	= o.ReferenceNumber
		,cs.NationId
		,IsComplianceScheme = 1
		,o.Town
		,o.PostCode
		,RowNumber			= Row_Number() Over(Partition by c.organisationid,c.submissionperiod order by CONVERT(DATETIME, Substring(c.[created], 1, 23)) desc ) 
	From 
		rpd.organisations o
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
	From 
		csa 
	Where csa.RowNumber = 1
	Union
	Select /*** SN005: Added ***/
		 cs_ch.ExternalID			
		,cs_ch.ReferenceNumber	
		,cs_ch.NationId
		,cs_ch.IsComplianceScheme 
		,cs_ch.Town
		,cs_ch.PostCode
	From 
		cs_ch 
	
), /*** SN:003 ***/
prn As (
	Select 
		 p.Id
		,p.ExternalId
		,p.PrnNumber
		,ExternalOrgId				= p.OrganisationId
		,p.OrganisationName
		,p.ProducerAgency
		,p.ReprocessorExporterAgency
		,p.PrnStatusId
		,PrnStatus					= s.StatusDescription
		,p.TonnageValue
		,MaterialName				= Coalesce(pmm.PRNMaterialName,p.MaterialName,null) /*** SN008: Added ***/
		,p.IssuerNotes
		,p.IssuerReference
		,p.PrnSignatory
		,p.PrnSignatoryPosition
		,p.[Signature]
		,IssueDate					= convert(date,p.IssueDate)
		,IssueTime					= convert(time,p.IssueDate)
		,AcceptedDate				= convert(date,st.PrnAcceptedDate)
		,AcceptedTime				= convert(time,st.PrnAcceptedDate)
		,CancelledDate				= convert(date,st.PrnCancelledDate)
		,CancelledTime				= convert(time,st.PrnCancelledDate)
		,p.ProcessToBeUsed
		,p.DecemberWaste
		,p.StatusUpdatedOn
		,p.IssuedByOrg
		,p.AccreditationNumber
		,p.ReprocessingSite
		,p.AccreditationYear
		,p.ObligationYear
		,p.PackagingProducer
		,p.CreatedBy
		,p.CreatedOn
		,p.LastUpdatedBy
		,p.LastUpdatedDate
		,p.IsExport
	From 
		rpd.Prn					p
	Left Join
		st_pvt					st
			On p.Id = st.PrnIdFk 
	Left Join
		rpd.PrnStatus			s
			On p.PrnStatusId = s.id
	Left Join 
		pmm 
			on rTrim(p.MaterialName) = rTrim(pmm.NPWDMaterialName) /*** SN007: Added ***/
)

Select p.id,
	 p.PrnNumber
	,p.ExternalOrgId
	,OrganisationId					= o.[ReferenceNumber]
	,p.OrganisationName
	,p.ProducerAgency
	,p.ReprocessorExporterAgency
	,p.PrnStatus
	,p.TonnageValue
	,p.MaterialName
	,p.IssuerNotes
	,p.IssuerReference
	,p.PrnSignatory
	,p.PrnSignatoryPosition
	,p.[Signature]
	,p.IssueDate
	,p.IssueTime
	,p.AcceptedDate
	,p.AcceptedTime
	,p.CancelledDate
	,p.CancelledTime
	,p.ProcessToBeUsed
	,p.DecemberWaste
	,p.StatusUpdatedOn
	,IssuedByOrganisationName		= p.IssuedByOrg
	,p.AccreditationNumber
	,p.ReprocessingSite
	,p.AccreditationYear
	,p.ObligationYear
	,p.PackagingProducer
	,p.CreatedBy
	,p.CreatedOn
	,p.LastUpdatedBy
	,p.LastUpdatedDate
	,p.IsExport						/*** 0 = PRN, 1 = PERN ***/
	,ProducerType					= Case o.[IsComplianceScheme] When 1 Then 'Compliance Scheme' When 0 Then 'Direct Registrant' Else NULL End
	,o.Town
	,o.Postcode
	,Nation							= Case o.NationId					/** SN002 **/
										When 1 Then 'England'
										When 2 Then 'Northern Ireland'
										When 3 Then 'Scotland'
										When 4 Then 'Wales'
										Else 'Not Set'
									 End
	,PrnObliJoin			= Concat(Ltrim(Rtrim(p.ExternalOrgId)),'-',Ltrim(Rtrim(p.MaterialName)),'-',Ltrim(Rtrim(p.ObligationYear)))
From
	prn											p
Join
	org_csa				o
		on p.ExternalOrgId = o.ExternalID;