CREATE VIEW [dbo].[v_POM_Material_Order_ST]
AS SELECT distinct
p.packaging_material as packaging_material_code,
p.packaging_material_subtype as packaging_material_subtype
,case 
	when p.packaging_material = 'PL' AND p.packaging_material_subtype = 'Rigid' then 'Plastic-Rigid'
	when p.packaging_material = 'PL' AND p.packaging_material_subtype = 'Flexible' then 'Plastic-Flexible'
    when p.packaging_material = 'AL' then 'Aluminium'
    when p.packaging_material = 'FC' then 'Fibre Composite'
    when p.packaging_material = 'GL' then 'Glass'
    when p.packaging_material = 'PC' then 'Paper / Card'
    when p.packaging_material = 'PL' then 'Plastic'
    when p.packaging_material = 'ST' then 'Steel'
    when p.packaging_material = 'WD' then 'Wood'
    when p.packaging_material = 'OT' then 'Other'
    else p.packaging_material
end packaging_material

,case 
	when p.packaging_material = 'PL' AND p.packaging_material_subtype = 'Flexible' then 2
	when p.packaging_material = 'PL' AND p.packaging_material_subtype = 'Rigid' then 3
    when p.packaging_material = 'PL' then 1
    when p.packaging_material = 'WD' then 4
    when p.packaging_material = 'AL' then 5
    when p.packaging_material = 'ST' then 6
    when p.packaging_material = 'GL' then 7
    when p.packaging_material = 'PC' then 8
    when p.packaging_material = 'FC' then 9
    when p.packaging_material = 'OT' then 10
	
-- else p.packaging_material
end packaging_material_order
from rpd.Pom p
where packaging_material in (
    'PL', 'WD', 'AL', 'ST',
    'GL', 'PC', 'FC', 'OT'
);