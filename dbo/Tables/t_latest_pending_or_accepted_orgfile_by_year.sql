﻿CREATE TABLE [dbo].[t_latest_pending_or_accepted_orgfile_by_year] (
    [file_submitted_organisation_reference]          NVARCHAR (4000) NULL,
    [file_submitted_organisation_IsComplianceScheme] BIT             NULL,
    [CS_Nation_name]                                 NVARCHAR (4000) NULL,
    [meta_OrganisationId]                            NVARCHAR (4000) NULL,
    [SubmissionPeriod]                               NVARCHAR (4000) NULL,
    [ReportingYear]                                  INT             NULL,
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
    [approved_person_first_name]                     NVARCHAR (4000) NULL,
    [approved_person_last_name]                      NVARCHAR (4000) NULL,
    [approved_person_email]                          NVARCHAR (4000) NULL,
    [approved_person_phone_number]                   NVARCHAR (4000) NULL,
    [delegated_person_first_name]                    NVARCHAR (4000) NULL,
    [delegated_person_last_name]                     NVARCHAR (4000) NULL,
    [delegated_person_email]                         NVARCHAR (4000) NULL,
    [delegated_person_phone_number]                  NVARCHAR (4000) NULL,
    [primary_contact_person_first_name]              NVARCHAR (4000) NULL,
    [primary_contact_person_last_name]               NVARCHAR (4000) NULL,
    [primary_contact_person_email]                   NVARCHAR (4000) NULL,
    [primary_contact_person_phone_number]            NVARCHAR (4000) NULL,
    [Subsidiary_RelationFromDate]                    DATETIME2 (7)   NULL,
    [Subsidiary_RelationToDate]                      DATETIME2 (7)   NULL,
    [Organisation_Nation_Name]                       NVARCHAR (4000) NULL,
    [Organisation_Nation_Id]                         INT             NULL,
    [leaver_code]                                    NVARCHAR (4000) NOT NULL,
    [leaver_date]                                    NVARCHAR (4000) NULL,
    [Organisation_change_reason]                     NVARCHAR (4000) NULL,
    [joiner_date]                                    NVARCHAR (4000) NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = ROUND_ROBIN);

