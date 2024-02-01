CREATE VIEW [dbo].[v_Producer_CS_Lookup] AS SELECT DISTINCT
cs.[CompaniesHouseNumber] as Operator_CompaniesHouseNumber
,o.Name as Operator_Name
,o.ReferenceNumber as Operator_Id
,org.Name as Producer_Name
,org.ReferenceNumber as Producer_Id
,pn.Name as Producer_Nation
,cs.[Name] as ComplianceScheme_Name
,cs.[Id] as ComplianceScheme_Id
,csn.Name as ComplianceScheme_Nation

FROM [rpd].[ComplianceSchemes] cs

JOIN rpd.Nations csn
ON cs.NationId = csn.Id

JOIN rpd.Organisations o
ON cs.CompaniesHouseNumber = o.CompaniesHouseNumber

JOIN rpd.SelectedSchemes ss
ON cs.Id = ss.ComplianceSchemeId

JOIN rpd.OrganisationsConnections oc
ON ss.OrganisationConnectionId = oc.Id

JOIN rpd.Organisations org
ON oc.FromOrganisationId = org.Id

JOIN rpd.Nations pn
ON org.NationId = pn.Id

WHERE cs.IsDeleted = 0;