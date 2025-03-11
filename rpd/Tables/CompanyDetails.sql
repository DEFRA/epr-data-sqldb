﻿CREATE TABLE [rpd].[CompanyDetails] (
    [organisation_id]                       INT             NULL,
    [subsidiary_id]                         NVARCHAR (4000) NULL,
    [organisation_name]                     NVARCHAR (4000) NULL,
    [trading_name]                          NVARCHAR (4000) NULL,
    [companies_house_number]                NVARCHAR (4000) NULL,
    [home_nation_code]                      NVARCHAR (4000) NULL,
    [main_activity_sic]                     NVARCHAR (4000) NULL,
    [organisation_type_code]                NVARCHAR (4000) NULL,
    [organisation_sub_type_code]            NVARCHAR (4000) NULL,
    [packaging_activity_so]                 NVARCHAR (4000) NULL,
    [packaging_activity_pf]                 NVARCHAR (4000) NULL,
    [packaging_activity_im]                 NVARCHAR (4000) NULL,
    [packaging_activity_se]                 NVARCHAR (4000) NULL,
    [packaging_activity_hl]                 NVARCHAR (4000) NULL,
    [packaging_activity_om]                 NVARCHAR (4000) NULL,
    [packaging_activity_sl]                 NVARCHAR (4000) NULL,
    [registration_type_code]                NVARCHAR (4000) NULL,
    [turnover]                              FLOAT (53)      NULL,
    [total_tonnage]                         FLOAT (53)      NULL,
    [produce_blank_packaging_flag]          NVARCHAR (4000) NULL,
    [liable_for_disposal_costs_flag]        NVARCHAR (4000) NULL,
    [meet_reporting_requirements_flag]      NVARCHAR (4000) NULL,
    [registered_addr_line1]                 NVARCHAR (4000) NULL,
    [registered_addr_line2]                 NVARCHAR (4000) NULL,
    [registered_city]                       NVARCHAR (4000) NULL,
    [registered_addr_county]                NVARCHAR (4000) NULL,
    [registered_addr_postcode]              NVARCHAR (4000) NULL,
    [registered_addr_country]               NVARCHAR (4000) NULL,
    [registered_addr_phone_number]          NVARCHAR (4000) NULL,
    [audit_addr_line1]                      NVARCHAR (4000) NULL,
    [audit_addr_line2]                      NVARCHAR (4000) NULL,
    [audit_addr_city]                       NVARCHAR (4000) NULL,
    [audit_addr_county]                     NVARCHAR (4000) NULL,
    [audit_addr_postcode]                   NVARCHAR (4000) NULL,
    [audit_addr_country]                    NVARCHAR (4000) NULL,
    [service_of_notice_addr_line1]          NVARCHAR (4000) NULL,
    [service_of_notice_addr_line2]          NVARCHAR (4000) NULL,
    [service_of_notice_addr_city]           NVARCHAR (4000) NULL,
    [service_of_notice_addr_county]         NVARCHAR (4000) NULL,
    [service_of_notice_addr_postcode]       NVARCHAR (4000) NULL,
    [service_of_notice_addr_country]        NVARCHAR (4000) NULL,
    [service_of_notice_addr_phone_number]   NVARCHAR (4000) NULL,
    [principal_addr_line1]                  NVARCHAR (4000) NULL,
    [principal_addr_line2]                  NVARCHAR (4000) NULL,
    [principal_addr_city]                   NVARCHAR (4000) NULL,
    [principal_addr_county]                 NVARCHAR (4000) NULL,
    [principal_addr_postcode]               NVARCHAR (4000) NULL,
    [principal_addr_country]                NVARCHAR (4000) NULL,
    [principal_addr_phone_number]           NVARCHAR (4000) NULL,
    [sole_trader_first_name]                NVARCHAR (4000) NULL,
    [sole_trader_last_name]                 NVARCHAR (4000) NULL,
    [sole_trader_phone_number]              NVARCHAR (4000) NULL,
    [sole_trader_email]                     NVARCHAR (4000) NULL,
    [approved_person_first_name]            NVARCHAR (4000) NULL,
    [approved_person_last_name]             NVARCHAR (4000) NULL,
    [approved_person_phone_number]          NVARCHAR (4000) NULL,
    [approved_person_email]                 NVARCHAR (4000) NULL,
    [approved_person_job_title]             NVARCHAR (4000) NULL,
    [delegated_person_first_name]           NVARCHAR (4000) NULL,
    [delegated_person_last_name]            NVARCHAR (4000) NULL,
    [delegated_person_phone_number]         NVARCHAR (4000) NULL,
    [delegated_person_email]                NVARCHAR (4000) NULL,
    [delegated_person_job_title]            NVARCHAR (4000) NULL,
    [primary_contact_person_first_name]     NVARCHAR (4000) NULL,
    [primary_contact_person_last_name]      NVARCHAR (4000) NULL,
    [primary_contact_person_phone_number]   NVARCHAR (4000) NULL,
    [primary_contact_person_email]          NVARCHAR (4000) NULL,
    [primary_contact_person_job_title]      NVARCHAR (4000) NULL,
    [secondary_contact_person_first_name]   NVARCHAR (4000) NULL,
    [secondary_contact_person_last_name]    NVARCHAR (4000) NULL,
    [secondary_contact_person_phone_number] NVARCHAR (4000) NULL,
    [secondary_contact_person_email]        NVARCHAR (4000) NULL,
    [secondary_contact_person_job_title]    NVARCHAR (4000) NULL,
    [load_ts]                               DATETIME2 (7)   NOT NULL,
    [FileName]                              NVARCHAR (4000) NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = ROUND_ROBIN);







