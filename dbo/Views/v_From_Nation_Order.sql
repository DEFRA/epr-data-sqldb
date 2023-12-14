CREATE VIEW [v_From_Nation_Order]
AS with cte_a as (
    -- England
    select
    'England' as from_nation

    -- Scotland
    union
    select
    'Scotland'

    union
    select
    'Wales'

    union
    select
    'Northern Ireland'
)

select *
,case
    when from_nation = 'England' then 1
    when from_nation = 'Scotland' then 2
    when from_nation = 'Wales' then 3
    when from_nation = 'Northern Ireland' then 4
end from_nation_order

from cte_a;