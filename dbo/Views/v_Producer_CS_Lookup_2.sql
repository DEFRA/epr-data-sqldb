CREATE VIEW [v_Producer_CS_Lookup_2]
AS SELECT o.ReferenceNumber AS Producer_Id
,o.Name AS Producer_Name
,op.ReferenceNumber as Operator_Id
,op.Name AS Operator_Name
,cs.CompaniesHouseNumber AS Operator_CompaniesHouseNumber
,cs.Id AS CS_Id
,cs.Name AS CS_Name
,pn.Name AS Producer_Nation
,csn.Name AS CS_Nation

FROM rpd.ComplianceSchemes cs

JOIN rpd.SelectedSchemes ss
ON cs.Id = ss.ComplianceSchemeId

JOIN rpd.OrganisationsConnections oc
ON ss.OrganisationConnectionId = oc.Id

JOIN rpd.Organisations o
ON oc.FromOrganisationId = o.Id

JOIN rpd.Organisations op
ON cs.CompaniesHouseNumber = op.CompaniesHouseNumber

JOIN rpd.Nations pn
ON o.NationId = pn.Id

JOIN rpd.Nations csn
ON cs.NationId = csn.Id

WHERE cs.IsDeleted = 0
AND ss.IsDeleted = 0
AND oc.IsDeleted = 0
AND o.IsDeleted = 0
AND op.IsDeleted = 0;