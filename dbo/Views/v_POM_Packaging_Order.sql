CREATE VIEW [dbo].[v_POM_Packaging_Order] AS SELECT distinct
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
end packaging_type_group

from rpd.Pom p
where packaging_type in (
    'CW', 'OW', 'HH',
    'NH', 'PB', 'RU',
    'HDC', 'NDC'
);