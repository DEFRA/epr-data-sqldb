CREATE VIEW [dbo].[v_PRN_Details]
AS With st As (
/****************************************************************************************************************************
	History:
 
	Created: 2024-11-20:	SN001:	Ticket - 464576:	Creation of View for PRN details for POwer BI reporting
	Updated: 2024-12-13		SN002:						Typo on nation description

******************************************************************************************************************************/
	Select 
		 PrnStatusHistoryId		= sth.Id
		,PrnIdFk				= sth.PrnIdFk
		,PrnStatusName			= st.StatusName 
		,PrnStatusDate			= sth.CreatedOn
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
	) stp
), 

prn As (
	Select 
		 p.Id
		,p.ExternalId
		,p.PrnNumber
		,ExternalOrgId					= p.OrganisationId
		,p.OrganisationName
		,p.ProducerAgency
		,p.ReprocessorExporterAgency
		,p.PrnStatusId
		,PrnStatus						= s.StatusDescription
		,p.TonnageValue
		,p.MaterialName
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
)

Select
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
	,p.IsExport
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
	dbo.v_rpd_Organisations_Active				o
		on p.ExternalOrgId = o.ExternalID;