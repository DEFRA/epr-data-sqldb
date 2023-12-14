CREATE VIEW [dbo].[v_POM_Aggregated_Packaging_Type_Filter] AS select distinct
case
    when packaging_type = 'CW' then 'Self-managed consumer waste'
    when packaging_type = 'OW' then 'Self-managed organisation waste'
end packaging_type

,case
    when packaging_type = 'CW' then 1
    when packaging_type = 'OW' then 2
end packaging_type_order

from rpd.Pom
where packaging_type in ('CW', 'OW');