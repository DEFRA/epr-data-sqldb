CREATE PROC [dbo].[sp_Create_Report_Lookup] AS
BEGIN
    -- Disable row count for performance
    SET NOCOUNT ON;

IF OBJECT_ID('dbo.rpt_PoM_Codes', 'U') IS NOT NULL
    DROP TABLE dbo.rpt_PoM_Codes;


SELECT 'EN'      Code, 'nation'             Type, 'England'                            Text into dbo.rpt_PoM_Codes  UNION ALL 
SELECT 'NI'      Code, 'nation'             Type, 'Northern Ireland'                   Text UNION ALL
SELECT 'SC'      Code, 'nation'             Type, 'Scotland'                           Text UNION ALL
SELECT 'WS'      Code, 'nation'             Type, 'Wales'			                   Text UNION ALL    
SELECT '2023-P1' Code, 'submission_period'  Type, '1 Jan to 30 Jun 2023'               Text UNION ALL 
SELECT '2023-P2' Code, 'submission_period'  Type, '1 Jan to 30 Jun 2023'               Text UNION ALL
SELECT '2023-P3' Code, 'submission_period'  Type, '1 Jul to 31 Dec 2023'               Text UNION ALL
SELECT 'SO'      Code, 'packaging_activity' Type, 'Brand Owner'                        Text UNION ALL
SELECT 'PF'      Code, 'packaging_activity' Type, 'Packer / Filler'	                   Text UNION ALL
SELECT 'IM'      Code, 'packaging_activity' Type, 'Imported'		                   Text UNION ALL
SELECT 'SE'      Code, 'packaging_activity' Type, 'Sold as empty'	                   Text UNION ALL
SELECT 'HL'      Code, 'packaging_activity' Type, 'Hired or loaned'	                   Text UNION ALL
SELECT 'OM'      Code, 'packaging_activity' Type, 'Online marketplace'                 Text UNION ALL
SELECT 'HH'      Code, 'packaging_type'     Type, 'Total Household packaging'          Text UNION ALL
SELECT 'NH'      Code, 'packaging_type'     Type, 'Total Non-Household packaging'	   Text UNION ALL
SELECT 'CW'      Code, 'packaging_type'     Type, 'Self-managed consumer waste'		   Text UNION ALL
SELECT 'OW'      Code, 'packaging_type'     Type, 'Self-managed organisation waste'	   Text UNION ALL
SELECT 'PB'      Code, 'packaging_type'     Type, 'Public binned'					   Text UNION ALL
SELECT 'RU'      Code, 'packaging_type'     Type, 'Reusable packaging'				   Text UNION ALL
SELECT 'HDC'     Code, 'packaging_type'     Type, 'Household drinks containers'		   Text UNION ALL
SELECT 'NDC'     Code, 'packaging_type'     Type, 'Non-household drinks containers'	   Text UNION ALL
SELECT 'SP'      Code, 'packaging_type'     Type, 'Small organisation packaging - all' Text UNION ALL
SELECT 'P1'      Code, 'packaging_class'    Type, 'Primary packaging'                  Text UNION ALL 
SELECT 'P2'      Code, 'packaging_class'    Type, 'Secondary packaging'			       Text UNION ALL
SELECT 'P3'      Code, 'packaging_class'    Type, 'Shipment packaging'			       Text UNION ALL
SELECT 'P4'      Code, 'packaging_class'    Type, 'Tertiary packaging'			       Text UNION ALL
SELECT 'P5'      Code, 'packaging_class'    Type, 'Non-primary reusable packaging'     Text UNION ALL
SELECT 'P6'      Code, 'packaging_class'    Type, 'Online marketplace total'	       Text UNION ALL
SELECT 'O1'      Code, 'packaging_class'    Type, 'Consumer waste'				       Text UNION ALL
SELECT 'O2'      Code, 'packaging_class'    Type, 'Organisation waste'			       Text UNION ALL
SELECT 'B1'      Code, 'packaging_class'    Type, 'Public bin'					       Text UNION ALL
SELECT 'AL'      Code, 'packaging_material' Type, 'Aluminium'		                   Text UNION ALL
SELECT 'FC'      Code, 'packaging_material' Type, 'Fibre Composite'                    Text UNION ALL
SELECT 'GL'      Code, 'packaging_material' Type, 'Glass'			                   Text UNION ALL
SELECT 'PC'      Code, 'packaging_material' Type, 'Paper / Card'	                   Text UNION ALL
SELECT 'PL'      Code, 'packaging_material' Type, 'Plastic'			                   Text UNION ALL
SELECT 'ST'      Code, 'packaging_material' Type, 'Steel'			                   Text UNION ALL
SELECT 'WD'      Code, 'packaging_material' Type, 'Wood'			                   Text UNION ALL
SELECT 'OT'      Code, 'packaging_material' Type, 'Other'			                   Text

end