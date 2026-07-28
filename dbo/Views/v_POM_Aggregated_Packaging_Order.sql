CREATE VIEW [dbo].[v_POM_Aggregated_Packaging_Order] 
/****************************************************************************************************************************
	History:
 
	Updated: 2024-11-19:	YM001:	Ticket - 460891:	Added (packaging_type = 'SP' as 'Small organisation packaging - all') as part of small producer change
	Updated: 2024-11-25:	SN002:  Ticket - 460891:	Added (packaging_type_inc_OrgSize which shows breakdow	'Household drinks containers' between large and small producers (SP)'
	Updated: 2024-12-02:	SN003:  Ticket - 460891:	changed to use packaging type code, not full description. Changed JOinColumn name to PkgOrgJoinColumn
	Updated: 2026-07-10:	EMR-497				   :	Added in CLR via POM_Codes so can be centrally managed and bring through CLR packaging types.
						
******************************************************************************************************************************/
AS with cte_packaging as (
	SELECT distinct p.packaging_type as packaging_type_code
		, ptc.[Text] AS packaging_type
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
		  ELSE  -1
		end packaging_type_order

		,packaging_class AS packaging_class_code
		,pcc.[Text] AS packaging_class
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
			ELSE -1
		end packaging_class_order
		,organisation_size /** SN002 ^^^ **/
		,concat(p.packaging_type,'-',packaging_class) as Ignore_column
		from rpd.Pom p
		INNER JOIN [dbo].[t_PoM_Codes] ptc ON ptc.Code = p.packaging_type AND ptc.[Type] = 'packaging_type'
		LEFT JOIN [dbo].[t_PoM_Codes] pcc ON pcc.Code = p.packaging_class AND pcc.[Type] = 'packaging_class'
	)

select packaging_type_code
	,packaging_type
	,packaging_type_order
	,Ignore_column
	,packaging_class_code
	,packaging_class
	,packaging_class_order
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
	,PkgOrgJoinColumn = Concat(packaging_type_code,'-',organisation_size) /** SN003 **/
from cte_packaging;
