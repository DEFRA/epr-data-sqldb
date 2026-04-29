CREATE VIEW [dbo].[v_myc_error_report]
AS with

Periods as (
  -- P1/P2/P3 (one of) for 2024 is handled separately
  select 'P4' as period, '2024' as year
  union
  select 'H1', '2025'
  union
  select 'H2', '2025'
  union
  select 'H1', '2026'
  union
  select 'H2', '2026'
  union
  select 'H1', '2027'
  union
  select 'H2', '2027'
  union
  select 'H1', '2028'
  union
  select 'H2', '2028'
),

-- PART 1
-- Get the org obligation:
RegistrationFiles as (
  select
      cfm.filename
    , cd.organisation_id
    , right(dbo.udf_DQ_SubmissionPeriod(cfm.SubmissionPeriod), 4) as submission_period_year
    , cast(coalesce(cfm.ComplianceSchemeId, o.ExternalId) as uniqueidentifier) as submitter_id -- cast added for consistent case
    , case
        when nullif(trim(cfm.ComplianceSchemeId), '') is null
        then 'DirectRegistrant'
        else 'ComplianceScheme'
      end as submitter_type
    , coalesce(cs.Name, '') as compliance_scheme_name
    -- , row_number() over(
    --     partition by
    --       cd.organisation_id,
    --       right(dbo.udf_DQ_SubmissionPeriod(cfm.SubmissionPeriod), 4)
    --     order by cfm.created desc
    --   ) as rn
    , try_cast(sofs.Decision_Date as date) as accepted_date
    , cfm.Created
    , sofs.Regulator_Status as regulator_status
    from rpd.CompanyDetails as cd
    inner join rpd.Organisations as o
      on  o.ReferenceNumber = cd.organisation_id
      and o.IsDeleted       = 0
    inner join rpd.cosmos_file_metadata as cfm
      on  cfm.FileName      = cd.FileName
      and cfm.FileType      = 'CompanyDetails'
    inner join dbo.v_submitted_pom_org_file_status sofs
      on  sofs.cfm_fileid   = cfm.fileid
      and sofs.filetype     = 'CompanyDetails'
      and sofs.Regulator_Status in ('Granted','Accepted', 'Cancelled')
  left join rpd.ComplianceSchemes cs
    on cs.ExternalId        = cfm.ComplianceSchemeId
),
LatestRegistrationFiles as (
  select * from (
    select distinct
        rf.filename
      , rf.organisation_id
      , rf.submission_period_year
      , rf.submitter_id
      , rf.submitter_type
      , rf.compliance_scheme_name
      , rf.accepted_date
      ,row_number() over(
          partition by
            rf.organisation_id,
            rf.submission_period_year
          order by rf.created desc
        ) as rn
      from RegistrationFiles as rf
  ) a
  where rn = 1
),
LatestAcceptedRegistrationFiles as (
  select * from (
    select
        rf.filename
      , rf.organisation_id
      , rf.submission_period_year
      , rf.submitter_id
      , rf.submitter_type
      , rf.compliance_scheme_name
      , rf.accepted_date
      ,row_number() over(
          partition by
            rf.organisation_id,
            rf.submission_period_year
          order by rf.created desc
        ) as rn
      from RegistrationFiles as rf
      where rf.regulator_status in ('Granted','Accepted')
  ) a
  where rn = 1
),
LatestCancelledRegistrationFiles as (
  select * from (
    select
        rf.filename
      , rf.organisation_id
      , rf.submission_period_year
      , rf.submitter_id
      , rf.submitter_type
      , rf.compliance_scheme_name
      , rf.accepted_date
      ,row_number() over(
          partition by
            rf.organisation_id,
            rf.submission_period_year
          order by rf.created desc
        ) as rn
      from RegistrationFiles as rf
      where rf.regulator_status = 'Cancelled'
  ) a
  where rn = 1
),
LatestAcceptedRegistrations as (
  select
    larf.filename
  , cd.organisation_id
  , cd.organisation_name
  , cd.trading_name
  , cd.leaver_code
  , cd.leaver_date
  , cd.joiner_date
  , coalesce(nullif(trim(cd.subsidiary_id), ''), '') as subsidiary_id
  , larf.submission_period_year
  , larf.submitter_id
  , larf.submitter_type
  , larf.compliance_scheme_name
  , larf.accepted_date
  from LatestAcceptedRegistrationFiles larf
  inner join rpd.CompanyDetails cd
    on  cd.organisation_id   = larf.organisation_id
    and cd.filename          = larf.filename
    and cd.organisation_size = 'L'
),
LatestCancelledRegistrations as (
  select
    larf.filename
  , cd.organisation_id
  , cd.organisation_name
  , cd.trading_name
  , cd.leaver_code
  , cd.leaver_date
  , cd.joiner_date
  , coalesce(nullif(trim(cd.subsidiary_id), ''), '') as subsidiary_id
  , larf.submission_period_year
  , larf.submitter_id
  , larf.submitter_type
  , larf.compliance_scheme_name
  , larf.accepted_date
  from LatestCancelledRegistrationFiles larf
  inner join rpd.CompanyDetails cd
    on  cd.organisation_id   = larf.organisation_id
    and cd.filename          = larf.filename
    and cd.organisation_size = 'L'
),
AcceptedRegistrationsWithObligations as (
  select
    reg.organisation_id
  , reg.subsidiary_id
  , reg.organisation_name
  , reg.trading_name
  , reg.leaver_code
  , reg.leaver_date
  , reg.joiner_date
  , reg.submitter_id
  , reg.submission_period_year
  , obl.obligation_status
  , obl.error_code
  , reg.compliance_scheme_name
  , reg.submitter_type
  , reg.accepted_date
  from dbo.t_producer_obligation_determination obl
  inner join LatestAcceptedRegistrations as reg
    on  reg.organisation_id        = obl.organisation_id
    and reg.subsidiary_id          = coalesce(nullif(trim(obl.subsidiary_id), ''), '')
    and reg.submitter_id           = cast(obl.submitter_id as uniqueidentifier)
    and reg.submission_period_year = obl.submission_period_year
),
CancelledRegistrationsWithObligations as (
  select
    reg.organisation_id
  , reg.subsidiary_id
  , reg.organisation_name
  , reg.trading_name
  , reg.leaver_code
  , reg.leaver_date
  , reg.joiner_date
  , reg.submitter_id
  , reg.submission_period_year
  , obl.obligation_status
  , obl.error_code
  , reg.compliance_scheme_name
  , reg.submitter_type
  , reg.accepted_date
  from dbo.t_producer_obligation_determination obl
  inner join LatestCancelledRegistrations as reg
    on  reg.organisation_id        = obl.organisation_id
    and reg.subsidiary_id          = coalesce(nullif(trim(obl.subsidiary_id), ''), '')
    and reg.submitter_id           = cast(obl.submitter_id as uniqueidentifier)
    and reg.submission_period_year = obl.submission_period_year
),
-- PART 2
-- Get the latest accepted poms
LatestAcceptedPomFiles as (
  select
    FileId
  , SubmissionId
  , try_cast(Created as date) as AcceptedDate
  from (
    select
      FileId
    , SubmissionId
    , Created
    , row_number() over (partition by SubmissionId order by Created desc) as rn
    from rpd.SubmissionEvents
    where Type     = 'RegulatorPoMDecision'
      and Decision = 'Accepted'
      and FileId   is not null
  ) a
  where a.rn = 1
),

LatestAcceptedPoms as (
  select * from (
    select distinct
      latest.SubmissionId
    , latest.FileId
    , cfm.FileName
    , cfm.submissionperiod                                                                 as submission_period_desc
    , latest.AcceptedDate                                                                  as accepted_date
    , row_number() over(
        partition by
          p.organisation_id,
          nullif(trim(p.subsidiary_id), ''), -- important - sometimes is blank, sometimes is null
          p.submission_period,
          coalesce(cfm.ComplianceSchemeId, o.ExternalId)  -- keep alternative submissions... (especially submitter_type)
        order by cfm.created desc
      )                                                                                    as rn
    , p.organisation_id
    , coalesce(nullif(trim(p.subsidiary_id), ''), '')                                      as subsidiary_id
    , p.submission_period
    , right(dbo.udf_DQ_SubmissionPeriod(cfm.SubmissionPeriod), 4)                          as submission_period_year
    , cast(coalesce(cfm.ComplianceSchemeId, o.ExternalId) as uniqueidentifier)             as submitter_id -- cast added for consistent case
    , case
        when nullif(trim(cfm.ComplianceSchemeId), '') is null
        then 'DirectRegistrant'
        else 'ComplianceScheme'
      end as submitter_type
    , coalesce(cs.Name, '')                                                                as compliance_scheme_name
    , coalesce(nullif(trim(p.subsidiary_id), ''), cast(p.organisation_id as nvarchar(50))) as producer_id
    from rpd.Pom as p
    inner join rpd.Organisations o
      on  o.ReferenceNumber     = p.organisation_id
      and o.IsDeleted           = 0
    inner join rpd.cosmos_file_metadata as cfm
      on  cfm.FileName          = p.FileName
    inner join LatestAcceptedPomFiles as latest
      on  latest.FileId         = cfm.FileId
    left join rpd.ComplianceSchemes cs
      on cs.ExternalId          = cfm.ComplianceSchemeId
    where p.organisation_size   = 'L'
  ) a
  where a.rn = 1
),

--
-- PART 3
-- Collect the errors
--
MissingRegistrations as (
  select distinct
    pom.submission_period_year + 1     as relevant_year
  , pom.organisation_id
  , pom.subsidiary_id
  , pom.submitter_id
  , producer.Name                        as organisation_name
  , pom.compliance_scheme_name
  , pom.submitter_type                   as submitter_type
  , ''                                   as leaver_code
  , 'Missing Registration'               as error_code
  , max(pom.accepted_date)               as PomAcceptedDate -- max, since we have multiple pom periods
  , cast(null as date)                   as RegAcceptedDate
  from LatestAcceptedPoms as pom
  inner join rpd.Organisations as producer
    on producer.ReferenceNumber = pom.producer_id
  where 
  (
    (
      not exists 
      (
        select 1
        from AcceptedRegistrationsWithObligations as reg
        where pom.organisation_id        = reg.organisation_id
          and pom.subsidiary_id          = reg.subsidiary_id
          and pom.submitter_id           = reg.submitter_id
          and pom.submission_period_year = reg.submission_period_year - 1
      )
      and not exists (
          select 1
          from CancelledRegistrationsWithObligations as reg
          where pom.organisation_id        = reg.organisation_id
            and pom.subsidiary_id          = reg.subsidiary_id
            and pom.submitter_id           = reg.submitter_id
            and pom.submission_period_year = reg.submission_period_year - 1           
      )
    )
    or (
      exists (
        select 1
        from CancelledRegistrationsWithObligations as reg
        where pom.organisation_id        = reg.organisation_id
          and pom.subsidiary_id          = reg.subsidiary_id
          and pom.submitter_id           = reg.submitter_id
          and pom.submission_period_year = reg.submission_period_year - 1
      )
      and not exists (
          select 1
          from AcceptedRegistrationsWithObligations as reg
          where pom.organisation_id        = reg.organisation_id
            and pom.subsidiary_id          = reg.subsidiary_id
            -- and pom.submitter_id           = reg.submitter_id
            and pom.submission_period_year = reg.submission_period_year - 1           
      )
    )
  ) 
  group by
    pom.submission_period_year
  , pom.organisation_id
  , pom.subsidiary_id
  , pom.submitter_id
  , producer.Name
  , pom.compliance_scheme_name
  , pom.submitter_type
),
NotObligated as (
  select distinct
    pom.submission_period_year + 1     as relevant_year
  , pom.organisation_id
  , pom.subsidiary_id
  , pom.submitter_id
  , producer.Name                        as organisation_name
  , pom.compliance_scheme_name
  , pom.submitter_type                   as submitter_type
  , ''                                   as leaver_code
  , 'Not Obligated'               as error_code
  , max(pom.accepted_date)               as PomAcceptedDate -- max, since we have multiple pom periods
  , cast(null as date)                   as RegAcceptedDate
  from LatestAcceptedPoms as pom
  inner join rpd.Organisations as producer
    on producer.ReferenceNumber = pom.producer_id
  where 
  (
    exists 
    (
      select 1
      from CancelledRegistrationsWithObligations as reg
      where pom.organisation_id        = reg.organisation_id
        and pom.subsidiary_id          = reg.subsidiary_id
        and pom.submitter_id           = reg.submitter_id
        and pom.submission_period_year = reg.submission_period_year - 1
    )
    and exists (
        select 1
        from AcceptedRegistrationsWithObligations as reg
        where pom.organisation_id        = reg.organisation_id
          and pom.subsidiary_id          = reg.subsidiary_id
          -- and pom.submitter_id           = reg.submitter_id
          and pom.submission_period_year = reg.submission_period_year - 1           
    )
  ) 
  group by
    pom.submission_period_year
  , pom.organisation_id
  , pom.subsidiary_id
  , pom.submitter_id
  , producer.Name
  , pom.compliance_scheme_name
  , pom.submitter_type
),
MissingPoms as (
  select distinct
    reg.submission_period_year             as relevant_year
  , reg.organisation_id
  , reg.subsidiary_id
  , reg.submitter_id
  , reg.organisation_name
  , reg.compliance_scheme_name
  , reg.submitter_type
  , reg.leaver_code
  , concat('Missing POM ', period.period)  as error_code
  , cast(null              as date)        as PomAcceptedDate
  , reg.accepted_date                      as RegAcceptedDate
  from AcceptedRegistrationsWithObligations as reg
  inner join Periods period
    on period.year = reg.submission_period_year - 1
  where reg.obligation_status = 'O'
    and not exists (
      select 1
      from LatestAcceptedPoms as pom
      where pom.organisation_id        = reg.organisation_id
        and pom.subsidiary_id          = reg.subsidiary_id
        and pom.submitter_id           = reg.submitter_id
        and pom.submission_period_year = reg.submission_period_year - 1
        and pom.submission_period      = concat(period.year, '-', period.period)
    )
),

MissingPoms2024P1P2P3 as (
  select distinct
    reg.submission_period_year             as relevant_year
  , reg.organisation_id
  , reg.subsidiary_id
  , reg.submitter_id
  , reg.organisation_name
  , reg.compliance_scheme_name
  , reg.submitter_type
  , reg.leaver_code
  , 'Missing POM P1/P2/P3'                 as error_code
  , cast(null as date)                     as PomAcceptedDate
  , reg.accepted_date                      as RegAcceptedDate
  from AcceptedRegistrationsWithObligations as reg
  where reg.obligation_status = 'O'
    and reg.submission_period_year = '2025'
    and not exists (
      select 1
      from LatestAcceptedPoms as pom
      where pom.organisation_id        = reg.organisation_id
        and pom.subsidiary_id          = reg.subsidiary_id
        and pom.submitter_id           = reg.submitter_id
        and pom.submission_period_year = reg.submission_period_year - 1
        and pom.submission_period      in ('2024-P1', '2024-P2', '2024-P3') -- any is acceptable
    )
),

RegistrationErrors as (
  select
    reg.submission_period_year         as relevant_year
  , reg.organisation_id
  , reg.subsidiary_id
  , reg.submitter_id
  , reg.organisation_name
  , reg.compliance_scheme_name
  , reg.submitter_type
  , reg.leaver_code
  , reg.error_code
  , max(pom.accepted_date)             as PomAcceptedDate -- max, since we have multiple pom periods
  , reg.accepted_date                  as RegAcceptedDate
  from AcceptedRegistrationsWithObligations as reg
  left join LatestAcceptedPoms as pom
    on  pom.organisation_id        = reg.organisation_id
    and pom.subsidiary_id          = reg.subsidiary_id
    and pom.submitter_id           = reg.submitter_id
    and pom.submission_period_year = reg.submission_period_year - 1
  where (
      reg.obligation_status = 'E'
      -- also show any warning when there is pom data, or there is an obligation (otherwise it will just say Missing POM)
      or (reg.error_code is not null and reg.obligation_status = 'O')
      or (reg.error_code is not null and pom.organisation_id is not null)
    ) and not exists (
      select 1 from NotObligated no where no.organisation_id = reg.organisation_id
      and no.subsidiary_id = reg.subsidiary_id
      and no.relevant_year = reg.submission_period_year
    )
  group by
    reg.submission_period_year
  , reg.organisation_id
  , reg.subsidiary_id
  , reg.submitter_id
  , reg.organisation_name
  , reg.compliance_scheme_name
  , reg.submitter_type
  , reg.leaver_code
  , reg.error_code
  , reg.accepted_date
),

ObligationMismatch as (
  select
    reg.submission_period_year         as relevant_year
  , reg.organisation_id
  , reg.subsidiary_id
  , reg.submitter_id
  , reg.organisation_name
  , reg.compliance_scheme_name
  , reg.submitter_type
  , reg.leaver_code
  , 'Reporting obligations mismatch'   as error_code
  , max(pom.accepted_date)             as PomAcceptedDate -- max, since we have multiple pom periods
  , reg.accepted_date                  as RegAcceptedDate
  from AcceptedRegistrationsWithObligations as reg
  inner join LatestAcceptedPoms as pom
    on  pom.organisation_id        = reg.organisation_id
    and pom.subsidiary_id          = reg.subsidiary_id
    and pom.submitter_id           = reg.submitter_id
    and pom.submission_period_year = reg.submission_period_year - 1
  where reg.obligation_status = 'N'
  group by
    reg.submission_period_year
  , reg.organisation_id
  , reg.subsidiary_id
  , reg.submitter_id
  , reg.organisation_name
  , reg.compliance_scheme_name
  , reg.submitter_type
  , reg.leaver_code
  , reg.error_code
  , reg.accepted_date
)

select * from MissingRegistrations
union
select * from NotObligated
union
select * from MissingPoms
union
select * from MissingPoms2024P1P2P3
union
select * from RegistrationErrors
union
select * from ObligationMismatch;
GO
