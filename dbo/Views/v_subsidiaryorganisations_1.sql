CREATE VIEW [dbo].[v_subsidiaryorganisations] AS select 
	R.FirstOrganisationId
	,FO.ReferenceNumber as FirstOrganisation_ReferenceNumber
	,R.SecondOrganisationId
	,SO.ReferenceNumber as SecondOrganisation_ReferenceNumber
	,sub.SubsidiaryId 
	,SO.CompaniesHouseNumber as SecondOrganisation_CompaniesHouseNumber
	,R.RelationFromDate
	,R.RelationToDate
	,R.RelationExpiryReason
	,R.OrganisationRelationshipTypeId
	,RLT.Name as OrganisationRelationshipType_Name
	,R.OrganisationRegistrationTypeId
	,RGT.Name as OrganisationRegistrationType_Name
from rpd.OrganisationRelationships R
left join rpd.Organisations FO on FO.id = R.FirstOrganisationId 
left join rpd.Organisations SO on SO.id = R.SecondOrganisationId 
left join rpd.OrganisationRelationshipTypes RLT on RLT.Id = R.OrganisationRelationshipTypeId
left join rpd.OrganisationRegistrationTypes RGT on RGT.Id = R.OrganisationRegistrationTypeId
left join rpd.SubsidiaryOrganisations sub on sub.OrganisationId = R.SecondOrganisationId;