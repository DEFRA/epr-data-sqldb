CREATE VIEW [dbo].[v_PRN_Obligations]
AS With obgns As (
/****************************************************************************************************************************
	History:
 
	Created: 2024-11-20:	SN001:	Ticket - 464577:	Creation of View for Obligations for POwer BI reporting
	Updated: 2024-11-28:	SN002:						Added Summ PrnTonnage and concatenated Address to reduce DAX usage

******************************************************************************************************************************/

	Select
		 ExternalOrgId			= ob.OrganisationId
		,OrganisationId			= o.[ReferenceNumber]
		,MaterialName
		,MaterialObligationValue
		,ObligationYear			= [Year]
		,CalculatedOn
		,Tonnage
		,LatestFlg				= Case Row_Number() Over (Partition By ob.OrganisationId, MaterialName, [Year] Order By CalculatedOn Desc) When 1 Then 1 Else 0 End
		,PrnObliJoin			= Concat(Ltrim(Rtrim(ob.OrganisationId)),'-',Ltrim(Rtrim(MaterialName)),'-',Ltrim(Rtrim([Year])))
		/*** vvvv ** SN002 ** vvvv ***/
		--,o.SubBuildingName
		--,o.BuildingNumber
		--,o.BuildingName
		--,o.Street
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
		rpd.ObligationCalculations ob
	 Join
		dbo.v_rpd_Organisations_Active	o
			on ob.OrganisationId = o.ExternalID
), 
/*** vvvv ** SN002 ** vvvv ***/
prnTt As (
	Select
		 p.OrganisationId
		,p.MaterialName
		,p.ObligationYear
		,TotTonnage			= sum(p.TonnageValue)
		,PrnObliJoin		= Concat(Ltrim(Rtrim(p.OrganisationId)),'-',Ltrim(Rtrim(p.MaterialName)),'-',Ltrim(Rtrim(p.ObligationYear)))
	From 
			rpd.Prn					p
	Group By
		 p.OrganisationId
		,p.MaterialName
		,p.ObligationYear
)


/*** ^^^^ ** SN002 ** ^^^^ ***/

	Select 
		o.*
		,p.TotTonnage				/** SN002 **/
		,RemainObligation	= o.MaterialObligationValue - p.TotTonnage
	From
		obgns		o
	Join
		prnTt		p on o.PrnObliJoin=p.PrnObliJoin
	Where 
		o.LatestFlg = 1;