CREATE VIEW [dbo].[v_POM_Material_Order]
AS SELECT distinct

p.packaging_material as packaging_material_code

,case 
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
    when p.packaging_material = 'PL' then 1
    when p.packaging_material = 'WD' then 2
    when p.packaging_material = 'AL' then 3
    when p.packaging_material = 'ST' then 4
    when p.packaging_material = 'GL' then 5
    when p.packaging_material = 'PC' then 6
    when p.packaging_material = 'FC' then 7
    when p.packaging_material = 'OT' then 8
-- else p.packaging_material
end packaging_material_order
from rpd.Pom p
where packaging_material in (
    'PL', 'WD', 'AL', 'ST',
    'GL', 'PC', 'FC', 'OT'
);