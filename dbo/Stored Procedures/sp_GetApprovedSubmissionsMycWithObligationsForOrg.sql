CREATE PROCEDURE [dbo].[sp_GetApprovedSubmissionsMycWithObligationsForOrg]
    @PeriodYear [varchar](4),
    @ExternalId [varchar](max)
AS
BEGIN

  DECLARE @start_dt datetime;
  DECLARE @batch_id INT;

  select @batch_id  = ISNULL(max(batch_id),0)+1 from [dbo].[batch_log]
  set @start_dt = getdate();

    BEGIN
        SET NOCOUNT ON;

        declare @RelevantYear varchar(4) = cast(cast(@PeriodYear as int) + 1 as varchar);
        declare @RequestedExternalId uniqueidentifier = try_convert(uniqueidentifier, @ExternalId);

        with
        LatestAcceptedPomFiles as (
          select
            FileId
          , Created
          from (
            select
              FileId
            , Created
            , row_number() over (partition by SubmissionId order by Created desc) as rn
            from rpd.SubmissionEvents
            where Type     = 'RegulatorPoMDecision'
              and Decision = 'Accepted'
              and FileId   is not null
          ) a
          where a.rn = 1
        ),

        activeRpdOrgs as (
            select ExternalId, ReferenceNumber
            from rpd.Organisations
            where IsDeleted = 0
        ),

        LatestAcceptedPoms as (
          select
            FileName
          , organisation_id
          , subsidiary_id
          , submission_period
          , submission_period_year
          , submitter_id
          , producer_id
          , submitter_type
          from (
            select
              cfm.FileName
            --ST005 Updated logic to determine the latest accepted file submission with data for a given organisation
            , row_number() over(
                partition by
                  p.organisation_id,
                  nullif(trim(p.subsidiary_id), ''), -- important - sometimes is blank, sometimes is null
                  p.submission_period,
                  coalesce(cfm.ComplianceSchemeId, o.ExternalId)  -- keep alternative submissions... (especially submitter_type)
                order by latest.created desc
              ) as rn
            , p.organisation_id
            , nullif(trim(p.subsidiary_id), '') as subsidiary_id
            , p.submission_period
            , right(dbo.udf_DQ_SubmissionPeriod(cfm.SubmissionPeriod), 4)        as submission_period_year
            , coalesce(cfm.ComplianceSchemeId, o.ExternalId)                     as submitter_id
            , coalesce(nullif(trim(p.subsidiary_id), ''), cast(p.organisation_id as nvarchar(50))) as producer_id
            , case
                when nullif(trim(cfm.ComplianceSchemeId), '') is null
                    then 'DirectRegistrant'
                    else 'ComplianceScheme'
              end as submitter_type
            from rpd.Pom as p
            inner join activeRpdOrgs o
              on  o.ReferenceNumber     = p.organisation_id
            inner join rpd.cosmos_file_metadata as cfm
              on  cfm.FileName          = p.FileName
            inner join LatestAcceptedPomFiles as latest
              on  latest.FileId         = cfm.FileId
            where p.organisation_size = 'L'
                and (
                  (
                    @PeriodYear = '2024'
                    and p.submission_period in (
                      concat(@PeriodYear, '-P1'),
                      concat(@PeriodYear, '-P2'),
                      concat(@PeriodYear, '-P3'),
                      concat(@PeriodYear, '-P4')
                    )
                  )
                  or (
                    @PeriodYear > '2024'
                    and p.submission_period in (
                      concat(@PeriodYear, '-H1'),
                      concat(@PeriodYear, '-H2')
                    )
                  ))
              and exists (
                select 1
                from rpd.Organisations as producerOrg
                where producerOrg.ReferenceNumber = coalesce(
                  nullif(trim(p.subsidiary_id), ''),
                  cast(p.organisation_id as nvarchar(50))
                )
                  and try_convert(uniqueidentifier, producerOrg.ExternalId) = @RequestedExternalId
              )
          ) a
          where a.rn = 1
        ),

        LatestAcceptedPomsWithPeriodFlags as (
          select
            lap.*
          , max(case
              when (
                @PeriodYear = '2024'
                and lap.submission_period in (
                  concat(@PeriodYear, '-P1'),
                  concat(@PeriodYear, '-P2'),
                  concat(@PeriodYear, '-P3')
                )
              )
                or (
                  @PeriodYear > '2024'
                  and lap.submission_period = concat(@PeriodYear, '-H1')
                )
              then 1
              else 0
            end) over (partition by lap.producer_id, lap.submitter_id) as HasFirstPeriod
          , max(case
              when (
                @PeriodYear = '2024'
                and lap.submission_period = concat(@PeriodYear, '-P4')
              )
                or (
                  @PeriodYear > '2024'
                  and lap.submission_period = concat(@PeriodYear, '-H2')
                )
              then 1
              else 0
            end) over (partition by lap.producer_id, lap.submitter_id) as HasSecondPeriod
          from LatestAcceptedPoms as lap
        ),

        LatestAcceptedPomsWith2Period as (
          select
            FileName
          , organisation_id
          , subsidiary_id
          , submission_period
          , submission_period_year
          , submitter_id
          , producer_id
          , submitter_type
          from LatestAcceptedPomsWithPeriodFlags
          where producer_id is not null
            and submitter_id is not null
            and HasFirstPeriod = 1
            and HasSecondPeriod = 1
        ),
        RegistrationsWithObligations as (
          select
            organisation_id
          , subsidiary_id
          , status_code  as leaver_code
          , leaver_date
          , joiner_date
          , submitter_id
          , obligation_status
          , num_days_obligated
          from dbo.t_producer_obligation_determination
          where submission_period_year = @RelevantYear
        ),

        LatestAcceptedPomEntries as (
          select
            lap.organisation_id
          , lap.subsidiary_id
          , lap.submitter_id
          , prodOrg.ExternalId as external_producer_id
          , lap.submitter_type
          , lap.submission_period_year
          , pom.packaging_type
          , pom.packaging_material
          , -- TODO could use v_POM which already does this
            case
              when pom.submission_period = '2023-P2' then cast(pom.packaging_material_weight * 1.50     as decimal(16,2))
              when pom.submission_period = '2024-P2' then cast(pom.packaging_material_weight * 2        as decimal(16,2))
              when pom.submission_period = '2024-P3' then cast(pom.packaging_material_weight * 182.0/61 as decimal(16,2)) -- v_POM uses 3 - but 182/61 preserves value previously used (for 182 days in P1, 61 in P3)
              else pom.packaging_material_weight
            end as packaging_material_weight
          , pom.transitional_packaging_units
          from LatestAcceptedPomsWith2Period as lap
          inner join rpd.Organisations prodOrg
            on prodOrg.ReferenceNumber = lap.producer_id
            and try_convert(uniqueidentifier, prodOrg.ExternalId) = @RequestedExternalId
          inner join rpd.Pom as pom
            on  pom.FileName           = lap.FileName
            and coalesce(nullif(trim(pom.subsidiary_id), ''), '') = coalesce(lap.subsidiary_id, '')
            and pom.organisation_id    = lap.organisation_id
        )

        select
          pom.submission_period_year                     as SubmissionPeriod
        , pom.submitter_type                             as SubmitterType
        , cast(pom.submitter_id as uniqueidentifier)     as SubmitterId
        , cast(external_producer_id as uniqueidentifier) as OrganisationId
        , packaging_material                             as PackagingMaterial
        , cast(
            round(
              (sum(packaging_material_weight) - coalesce(sum(transitional_packaging_units), 0)) / 1000.0,
              0
            ) as int
          )                                              as PackagingMaterialWeight
        , obl.num_days_obligated                         as NumberOfDaysObligated
        , cast(
            round(
              sum(packaging_material_weight) - coalesce(sum(transitional_packaging_units), 0),
              0
            ) as bigint
          )                                              as PackagingMaterialWeightKg
        , obl.obligation_status                           as ObligationStatus
        , obl.leaver_code                                 as LeaverCode
        , try_convert(date, obl.joiner_date, 103)          as JoinerDate
        , try_convert(date, obl.leaver_date, 103)          as LeaverDate
        from LatestAcceptedPomEntries as pom
        left join RegistrationsWithObligations as obl
          on  pom.organisation_id             = obl.organisation_id
          and coalesce(pom.subsidiary_id, '') = coalesce(obl.subsidiary_id, '')
          and pom.submitter_id                = obl.submitter_id

        where packaging_material              in ('AL','FC','GL','PC','PL','ST','WD')
          and packaging_type                  in ('HH','NH','PB','HDC','NDC')
        group by
          pom.submission_period_year
        , pom.submitter_id
        , pom.submitter_type
        , external_producer_id
        , packaging_material
        , obl.num_days_obligated
        , obl.obligation_status
        , obl.leaver_code
        , obl.joiner_date
        , obl.leaver_date
        order by
          pom.submitter_id
        , external_producer_id
        , packaging_material

    END

  INSERT INTO [dbo].[batch_log] ([ID],[ProcessName],[SubProcessName],[Count],[start_time_stamp],[end_time_stamp],[Comments],batch_id)
  select (select ISNULL(max(id),1)+1 from [dbo].[batch_log]),'dbo.sp_GetApprovedSubmissionsMycWithObligationsForOrg','', NULL, @start_dt, getdate(), '',@batch_id
END
