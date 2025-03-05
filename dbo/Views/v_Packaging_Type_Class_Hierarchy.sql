CREATE VIEW [dbo].[v_Packaging_Type_Class_Hierarchy] AS select distinct packaging_type,
packaging_class
from dbo.v_POM
where packaging_type in (
    'Total Household packaging'
    ,'Total Non-Household packaging'
    ,'Self-managed consumer waste'
    ,'Self-managed organisation waste'
    ,'Public binned'
    ,'Reusable packaging'
    ,'Household drinks containers'
    ,'Non-household drinks containers'
    ,'Small organisation packaging - all'
);