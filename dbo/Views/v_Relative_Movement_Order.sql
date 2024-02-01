CREATE VIEW [dbo].[v_Relative_Movement_Order] AS with cte_a as (
    -- England
    select
    'England to Scotland' as relative_move

    union
    select
    'England to Wales'

    union
    select
    'England to Northern Ireland'

    -- Scotland
    union
    select
    'Scotland to England'

    union
    select
    'Scotland to Wales'

    union
    select
    'Scotland to Northern Ireland'

    -- Wales
    union
    select
    'Wales to England'

    union
    select
    'Wales to Scotland'

    union
    select
    'Wales to Northern Ireland'

    -- Northern Ireland
    union
    select
    'Northern Ireland to England'

    union
    select
    'Northern Ireland to Scotland'

    union
    select
    'Northern Ireland to Wales'
)

select *
,case
    when relative_move = 'England to Scotland' then 'England'
    when relative_move = 'England to Wales' then 'England'
    when relative_move = 'England to Northern Ireland' then 'England'

    when relative_move = 'Scotland to England' then 'Scotland'
    when relative_move = 'Scotland to Wales' then 'Scotland'
    when relative_move = 'Scotland to Northern Ireland' then 'Scotland'

    when relative_move = 'Wales to England' then 'Wales'
    when relative_move = 'Wales to Scotland' then 'Wales'
    when relative_move = 'Wales to Northern Ireland' then 'Wales'

    when relative_move = 'Northern Ireland to England' then 'Northern Ireland'
    when relative_move = 'Northern Ireland to Scotland' then 'Northern Ireland'
    when relative_move = 'Northern Ireland to Wales' then 'Northern Ireland'

end relative_move_home

,case
    when relative_move = 'England to Scotland' then 1
    when relative_move = 'England to Wales' then 2
    when relative_move = 'England to Northern Ireland' then 3

    when relative_move = 'Scotland to England' then 4
    when relative_move = 'Scotland to Wales' then 5
    when relative_move = 'Scotland to Northern Ireland' then 6

    when relative_move = 'Wales to England' then 7
    when relative_move = 'Wales to Scotland' then 8
    when relative_move = 'Wales to Northern Ireland' then 9

    when relative_move = 'Northern Ireland to England' then 10
    when relative_move = 'Northern Ireland to Scotland' then 11
    when relative_move = 'Northern Ireland to Wales' then 12

end relative_move_order
from cte_a;