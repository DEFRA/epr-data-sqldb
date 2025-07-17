CREATE VIEW [dbo].[v_PRN_MaterialGroups] AS With 

pmm As (
/****************************************************************************************************************************
	History:
 
	Created: 2025-07-14:	SN001:			:	Creation of View for PRN and Obligations to allow easier manipulation of	
												materials and how they're grouped based on PRN team feedback and what material
												descripstions are visible in front end

 ****************************************************************************************************************************/
	Select 
		 PRNMaterialId			= Case When m.MaterialCode='FC' Then 8 Else m.Id End 
		,NPWDMaterialName		= Case When m.MaterialCode='FC' Then 'FirbreComposite' Else pmm.NPWDMaterialName End
		,PRNMaterialCode		= m.MaterialCode
		,PRNMaterialName		= m.MaterialName
	From 
		rpd.PrnMaterialMapping	pmm
	Right Join
		rpd.Material			m
			on pmm.PRNMaterialId = m.Id

)
Select
	 PRNMaterialId
	,PRNMaterialCode
	,NPWDMaterialName				= Replace(NPWDMaterialName,' ','')
	,PRNMaterialName				= Replace(PRNMaterialName,' ','')
	,PRNMaterialGroupName			= Case	When PRNMaterialCode in ('FC','PC') Then 'Paper, board or fibre-based composite material' Else PRNMaterialName End
	,PRNMaterialGroupNameIncGlass	= Case	When PRNMaterialCode in ('FC','PC') Then 'Paper, board or fibre-based composite material'
											When PRNMaterialCode in ('GR','GL') Then 'Glass'
											Else PRNMaterialName 
									  End
From 
	pmm;