CREATE VIEW [dbo].[v_POM_Packaging_Order] 
/****************************************************************************************************************************
	History:
 
	Updated: 2024-11-21:	YM001:	Ticket - 460891:	Added (packaging_type = 'SP' as 'Small organisation packaging - all') as part of small producer change
	Updated: 2024-11-25:	SN002:  Ticket - 460891:	Added (packaging_type_inc_OrgSize which shows breakdow	'Household drinks containers' between large and small producers (SP)'
	Updated: 2024-12-02:	SN003:  Ticket - 460891:	changed to use packaging type code, not full description. Changed JOinColumn name to PkgOrgJoinColumn
	Updated: 2026-07-10:	EMR-497				   :	Added in CLR via POM_Codes so can be centrally managed and bring through CLR packaging types.
		
******************************************************************************************************************************/

AS 
	 
With pkg as (
	Select Distinct p.packaging_type as packaging_type_code
		,ptc.[Text] AS packaging_type
		,case
			when p.packaging_type = 'CW' then 1
			when p.packaging_type = 'OW' then 2
			when p.packaging_type = 'HH' then 3
			when p.packaging_type = 'NH' then 5
			when p.packaging_type = 'HDC' then 6
			when p.packaging_type = 'NDC' then 7
			when p.packaging_type = 'PB' then 4 --changed order
			when p.packaging_type = 'RU' then 8
			when p.packaging_type = 'SP' then 9 /**YM001 **/
			when p.packaging_type = 'CLR' then 10
		end packaging_type_order

		-- Section added for bug 233562; grouping HDC and NDC into Household/non-household waste. Used in POM summary report.
		,ptc.[Text] AS packaging_type_group
		,organisation_size
	from rpd.Pom p
	INNER JOIN [dbo].[t_PoM_Codes] ptc ON ptc.Code = p.packaging_type AND ptc.[Type] = 'packaging_type'
)

Select 
	 pkg.* 
	 /** SN002 **/
	,packaging_type_inc_OrgSize = Case When packaging_type = 'Household drinks containers' Then
									Case organisation_size
										When 'L' Then 'Household drinks containers (LP)'
										When 'S' Then 'Household drinks containers (SP)'
										Else 'Household drinks containers (Not Set)'  
									End
									Else packaging_type 
									End
	,JoinColumn = Concat(packaging_type_code,'-',organisation_size)	/**SN003**/
From pkg;
