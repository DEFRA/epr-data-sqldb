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
	Updated: 2025-06-02		SN009:  N/A					Nation case statemnt (SN002) replaced with lookup to rpd.nations table
	Updated: 2025-06-06		SN010:	Ticket	- 517612	Use prn.StatusUpdatedOn intially for Accepted/Rejected/Cancelled/Rejected 
														datetime.  If null uses PrnStatusHistory.CreatedOn
	Updated: 2025-06-09		SN011:						Join commented out as no longer in use in PowerBI. Left as placeholder
	Updated: 2026-04-01	    MO-102:                     Updated material casting for paper and fibre
                                                        Added ObligationsMaterialName field to map to v_PRN_MaterialGroups 
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
	Select *
	From
		dbo.v_PRN_MaterialGroups
	
), /*** SN007: Added ***/
/*** SN:003 ***/
org As (  
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
	Select Distinct
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
		,MaterialName				= Replace(Coalesce(pmm.PRNMaterialName,pmmNPWD.PRNMaterialName,p.MaterialName,null),' ','') /*** SN008: Added ***/
		,p.IssuerNotes
		,p.IssuerReference
		,p.PrnSignatory
		,p.PrnSignatoryPosition
		,p.[Signature]
		,IssueDate					= convert(date,p.IssueDate)
		,IssueTime					= convert(time,p.IssueDate)
		,AcceptedDate				= convert(date,Case When p.PrnStatusId=1 Then Coalesce(p.StatusUpdatedOn, st.PrnAcceptedDate, p.CreatedOn) Else Null End)			/*** SN010:***/
		,AcceptedTime				= convert(time,Case When p.PrnStatusId=1 Then Coalesce(p.StatusUpdatedOn, st.PrnAcceptedDate, p.CreatedOn) Else Null End)			/*** SN010:***/
		,RejectedDate				= convert(date,Case When p.PrnStatusId=2 Then Coalesce(p.StatusUpdatedOn, st.PrnRejectedDate, p.CreatedOn) Else Null End)			/*** SN010:***/
		,RejectedTime				= convert(time,Case When p.PrnStatusId=2 Then Coalesce(p.StatusUpdatedOn, st.PrnRejectedDate, p.CreatedOn) Else Null End)			/*** SN010:***/
		,CancelledDate				= convert(date,Case When p.PrnStatusId=3 Then Coalesce(p.StatusUpdatedOn, st.PrnCancelledDate, p.CreatedOn) Else Null End)			/*** SN010:***/
		,CancelledTime				= convert(time,Case When p.PrnStatusId=3 Then Coalesce(p.StatusUpdatedOn, st.PrnCancelledDate, p.CreatedOn) Else Null End)			/*** SN010:***/
		,AwaitingAcceptanceDate		= convert(date,Case When p.PrnStatusId=4 Then Coalesce(p.StatusUpdatedOn, st.PrnAwaitingAcceptanceDate, p.CreatedOn) Else Null End)	/*** SN010:***/
		,AwaitingAcceptanceTime		= convert(time,Case When p.PrnStatusId=4 Then Coalesce(p.StatusUpdatedOn, st.PrnAwaitingAcceptanceDate, p.CreatedOn) Else Null End)	/*** SN010:***/
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
		pmm			pmmNPWD 
			on Replace(rTrim(p.MaterialName),' ','') = Replace(rTrim(pmmNPWD.NPWDMaterialName),' ','') /*** SN007: Added ***/
	Left Join 
		pmm 
			on Replace(rTrim(p.MaterialName),' ','') = Replace(rTrim(pmm.PRNMaterialName),' ','') /*** SN007: Added ***/
)

Select p.id,
	 p.PrnNumber
	,p.ExternalOrgId
	,OrganisationId					= o.ReferenceNumber
	,p.OrganisationName
	,p.ProducerAgency
	,p.ReprocessorExporterAgency
	,p.PrnStatus
	,p.StatusUpdatedOn
	,p.IssueDate
	,p.IssueTime
	,p.AcceptedDate
	,p.AcceptedTime
	,p.RejectedDate
	,p.RejectedTime
	,p.CancelledDate
	,p.CancelledTime
	,p.AwaitingAcceptanceDate
	,p.AwaitingAcceptanceTime
	,p.TonnageValue
	,MaterialName = Case 
		When p.MaterialName in ('Paper', 'Paperandboard') Then 'Paper or board'  
		When p.MaterialName = 'Fibre' Then 'Fibre-based composite material' 
		Else p.MaterialName 
	End
	,ObligationsMaterialName = Case
		When p.MaterialName = 'Paperandboard' Then 'Paper'  
		When p.MaterialName = 'Fibre' Then 'FibreComposite' 
		Else p.MaterialName
	End 
	,p.IssuerNotes
	,p.IssuerReference
	,p.PrnSignatory
	,p.PrnSignatoryPosition
	,p.[Signature]
	,p.ProcessToBeUsed
	,p.DecemberWaste
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
	,Nation					= IsNull(na.[Name],'Not Set')	/*** SN009: Added ***/
	,PrnObliJoin			= Concat(Ltrim(Rtrim(p.ExternalOrgId)),'-',Ltrim(Rtrim(p.MaterialName)),'-',Ltrim(Rtrim(p.ObligationYear))) 
From
	prn											p
Join
	org_csa				o
		on p.ExternalOrgId = o.ExternalID
Left Join
	rpd.nations			na
		on o.NationId = na.Id;