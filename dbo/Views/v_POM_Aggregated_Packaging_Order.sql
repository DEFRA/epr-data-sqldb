CREATE VIEW [dbo].[v_POM_Aggregated_Packaging_Order] AS with cte_packaging as (
/****************************************************************************************************************************
	History:
 
	Updated: 2024-11-19:	YM001:	Ticket - 460891:	Added (packaging_type = 'SP' as 'Small organisation packaging - all') as part of small producer change
	Updated: 2024-11-25:	SN002:  Ticket - 460891:	Added (packaging_type_inc_OrgSize which shows breakdow	'Household drinks containers' between large and small producers (SP)'
	Updated: 2024-12-02:	SN003:  Ticket - 460891:	changed to use packaging type code, not full description. Changed JOinColumn name to PkgOrgJoinColumn
	
						
******************************************************************************************************************************/
    SELECT distinct p.packaging_type as packaging_type_code

    ,case
    when p.packaging_type = 'CW' then 'Self-managed consumer waste'
    when p.packaging_type = 'OW' then 'Self-managed organisation waste'
    when p.packaging_type = 'HH' then 'Total Household packaging'
    when p.packaging_type = 'NH' then 'Total Non-Household packaging'
    when p.packaging_type = 'HDC' then 'Household drinks containers'
    when p.packaging_type = 'NDC' then 'Non-household drinks containers'
    when p.packaging_type = 'PB' then 'Public binned'
    when p.packaging_type = 'RU' then 'Reusable packaging'
	when p.packaging_type = 'SP' then 'Small organisation packaging - all' /**YM001 **/
    end packaging_type

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
    end packaging_type_order

    ,packaging_class
	,organisation_size /** SN002 ^^^ **/
	,concat(p.packaging_type,'-',packaging_class) as Ignore_column
    from rpd.Pom p
    where packaging_type in (
        'CW', 'OW', 'HH', 'NH',
        'HDC', 'NDC', 'PB', 'RU','SP' /**YM001 **/
    ) 
)

select packaging_type_code
,packaging_type
,packaging_type_order
,Ignore_column

,case
    when packaging_class = 'P1' then 'Primary packaging'
    when packaging_class = 'P2' then 'Secondary packaging'
    when packaging_class = 'P3' then 'Shipment packaging'
    when packaging_class = 'P4' then 'Tertiary packaging'
    when packaging_class = 'P5' then 'Non-primary reusable packaging'
    when packaging_class = 'P6' then 'Online marketplace total'
    when packaging_class = 'O1' then 'Consumer waste'
    when packaging_class = 'O2' then 'Organisation waste'
    when packaging_class = 'B1' then 'Public bin'
    else packaging_class
end packaging_class

,case
    when packaging_class = 'P1' then 1
    when packaging_class = 'P2' then 2
    when packaging_class = 'P3' then 3
    when packaging_class = 'P4' then 5
    when packaging_class = 'P5' then 6
    when packaging_class = 'P6' then 7
    when packaging_class = 'O1' then 8
    when packaging_class = 'O2' then 9
    when packaging_class = 'B1' then 4
end packaging_class_order
 /** SN002 vvv **/
	,packaging_type_inc_OrgSize = Case When packaging_type = 'Household drinks containers' Then
									Case organisation_size
										When 'L' Then 'Household drinks containers (LP)'
										When 'S' Then 'Household drinks containers (SP)'
										Else 'Household drinks containers (Not Set)'  
									End
									Else packaging_type 
									End
	/** SN002 ^^^ **/
	,PkgOrgJoinColumn = Concat(packaging_type_code,'-',organisation_size)		 /** SN003 **/
from cte_packaging;