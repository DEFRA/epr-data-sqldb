CREATE VIEW [dbo].[v_POM_Packaging_Order] AS With pkg as (
Select Distinct
/****************************************************************************************************************************
	History:
 
	Updated: 2024-11-21:	YM001:	Ticket - 460891:	Added (packaging_type = 'SP' as 'Small organisation packaging - all') as part of small producer change
	Updated: 2024-11-25:	SN002:  Ticket - 460891:	Added (packaging_type_inc_OrgSize which shows breakdow	'Household drinks containers' between large and small producers (SP)'
	Updated: 2024-12-02:	SN003:  Ticket - 460891:	changed to use packaging type code, not full description. Changed JOinColumn name to PkgOrgJoinColumn
		
******************************************************************************************************************************/
p.packaging_type as packaging_type_code

,case
when p.packaging_type = 'CW' then 'Self-managed consumer waste'
when p.packaging_type = 'OW' then 'Self-managed organisation waste'
when p.packaging_type = 'HH' then 'Total Household packaging'
when p.packaging_type = 'NH' then 'Total Non-Household packaging'
when p.packaging_type = 'PB' then 'Public binned'
when p.packaging_type = 'RU' then 'Reusable packaging'
when p.packaging_type = 'HDC' then 'Household drinks containers'
when p.packaging_type = 'NDC' then 'Non-household drinks containers'
when p.packaging_type = 'SP' then 'Small organisation packaging - all' /**YM001 **/
end packaging_type

,case
when p.packaging_type = 'CW' then 1
when p.packaging_type = 'OW' then 2
when p.packaging_type = 'HH' then 3
when p.packaging_type = 'NH' then 4
when p.packaging_type = 'PB' then 5
when p.packaging_type = 'RU' then 6
when p.packaging_type = 'HDC' then 3
when p.packaging_type = 'NDC' then 4
when p.packaging_type = 'SP' then 7 /**YM001 **/
end packaging_type_order

-- Section added for bug 233562; grouping HDC and NDC into Household/non-household waste. Used in POM summary report.
,case 
when p.packaging_type = 'CW' then 'Self-managed consumer waste'
when p.packaging_type = 'OW' then 'Self-managed organisation waste'
when p.packaging_type = 'HH' then 'Total Household packaging'
when p.packaging_type = 'NH' then 'Total Non-Household packaging'
when p.packaging_type = 'PB' then 'Public binned'
when p.packaging_type = 'RU' then 'Reusable packaging'
when p.packaging_type = 'HDC' then 'Total Household packaging'
when p.packaging_type = 'NDC' then 'Total Non-Household packaging'
when p.packaging_type = 'SP' then 'Small organisation packaging - all' /**YM001 **/
end packaging_type_group
,organisation_size
from rpd.Pom p
where packaging_type in (
    'CW', 'OW', 'HH',
    'NH', 'PB', 'RU',
    'HDC', 'NDC','SP'/**YM001 **/
)

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