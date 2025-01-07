﻿CREATE TABLE [dbo].[t_latest_accepted_orgfile_by_year] (
    [file_submitted_organisation_reference]          NVARCHAR (4000) NULL,
    [file_submitted_organisation_IsComplianceScheme] BIT             NULL,
    [meta_OrganisationId]                            NVARCHAR (4000) NULL,
    [SubmissionPeriod]                               NVARCHAR (4000) NULL,
    [ReportingYear]                                  NVARCHAR (4)    NULL,
    [Submission_time]                                DATETIME        NULL,
    [FileType]                                       NVARCHAR (4000) NULL,
    [meta_filename]                                  NVARCHAR (4000) NULL,
    [Regulator_Status]                               NVARCHAR (4000) NULL,
    [ComplianceSchemeName]                           NVARCHAR (4000) NULL,
    [CS_id]                                          INT             NULL,
    [organisation_id]                                INT             NULL,
    [subsidiary_id]                                  NVARCHAR (4000) NULL,
    [subsidiary_id_sys_gen]                          NVARCHAR (4000) NULL,
    [organisation_name]                              NVARCHAR (4000) NULL,
    [companies_house_number]                         NVARCHAR (4000) NULL,
    [organisation_size]                              NVARCHAR (4000) NULL,
    [registered_addr_line1]                          NVARCHAR (4000) NULL,
    [registered_addr_line2]                          NVARCHAR (4000) NULL,
    [registered_city]                                NVARCHAR (4000) NULL,
    [registered_addr_county]                         NVARCHAR (4000) NULL,
    [registered_addr_postcode]                       NVARCHAR (4000) NULL,
    [registered_addr_country]                        NVARCHAR (4000) NULL,
    [registered_addr_phone_number]                   NVARCHAR (4000) NULL,
    [approved_person_email]                          NVARCHAR (4000) NULL,
    [delegated_person_email]                         NVARCHAR (4000) NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = ROUND_ROBIN);

