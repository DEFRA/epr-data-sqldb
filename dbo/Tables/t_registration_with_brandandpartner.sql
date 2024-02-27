﻿CREATE TABLE [dbo].[t_registration_with_brandandpartner] (
    [organisation_id]                                                INT             NULL,
    [subsidiary_id]                                                  NVARCHAR (4000) NULL,
    [organisation_name]                                              NVARCHAR (4000) NULL,
    [trading_name]                                                   NVARCHAR (4000) NULL,
    [companies_house_number]                                         NVARCHAR (4000) NULL,
    [home_nation_code]                                               NVARCHAR (4000) NULL,
    [main_activity_sic]                                              NVARCHAR (4000) NULL,
    [organisation_type_code]                                         NVARCHAR (4000) NULL,
    [organisation_sub_type_code]                                     NVARCHAR (4000) NULL,
    [packaging_activity_so]                                          NVARCHAR (4000) NULL,
    [packaging_activity_pf]                                          NVARCHAR (4000) NULL,
    [packaging_activity_im]                                          NVARCHAR (4000) NULL,
    [packaging_activity_se]                                          NVARCHAR (4000) NULL,
    [packaging_activity_hl]                                          NVARCHAR (4000) NULL,
    [packaging_activity_om]                                          NVARCHAR (4000) NULL,
    [packaging_activity_sl]                                          NVARCHAR (4000) NULL,
    [registration_type_code]                                         NVARCHAR (4000) NULL,
    [turnover]                                                       FLOAT (53)      NULL,
    [total_tonnage]                                                  FLOAT (53)      NULL,
    [produce_blank_packaging_flag]                                   BIT             NULL,
    [liable_for_disposal_costs_flag]                                 BIT             NULL,
    [meet_reporting_requirements_flag]                               BIT             NULL,
    [registered_addr_line1]                                          NVARCHAR (4000) NULL,
    [registered_addr_line2]                                          NVARCHAR (4000) NULL,
    [registered_city]                                                NVARCHAR (4000) NULL,
    [registered_addr_county]                                         NVARCHAR (4000) NULL,
    [registered_addr_postcode]                                       NVARCHAR (4000) NULL,
    [registered_addr_country]                                        NVARCHAR (4000) NULL,
    [registered_addr_phone_number]                                   NVARCHAR (4000) NULL,
    [audit_addr_line1]                                               NVARCHAR (4000) NULL,
    [audit_addr_line2]                                               NVARCHAR (4000) NULL,
    [audit_addr_city]                                                NVARCHAR (4000) NULL,
    [audit_addr_county]                                              NVARCHAR (4000) NULL,
    [audit_addr_postcode]                                            NVARCHAR (4000) NULL,
    [audit_addr_country]                                             NVARCHAR (4000) NULL,
    [service_of_notice_addr_line1]                                   NVARCHAR (4000) NULL,
    [service_of_notice_addr_line2]                                   NVARCHAR (4000) NULL,
    [service_of_notice_addr_city]                                    NVARCHAR (4000) NULL,
    [service_of_notice_addr_county]                                  NVARCHAR (4000) NULL,
    [service_of_notice_addr_postcode]                                NVARCHAR (4000) NULL,
    [service_of_notice_addr_country]                                 NVARCHAR (4000) NULL,
    [service_of_notice_addr_phone_number]                            NVARCHAR (4000) NULL,
    [principal_addr_line1]                                           NVARCHAR (4000) NULL,
    [principal_addr_line2]                                           NVARCHAR (4000) NULL,
    [principal_addr_city]                                            NVARCHAR (4000) NULL,
    [principal_addr_county]                                          NVARCHAR (4000) NULL,
    [principal_addr_postcode]                                        NVARCHAR (4000) NULL,
    [principal_addr_country]                                         NVARCHAR (4000) NULL,
    [principal_addr_phone_number]                                    NVARCHAR (4000) NULL,
    [sole_trader_first_name]                                         NVARCHAR (4000) NULL,
    [sole_trader_last_name]                                          NVARCHAR (4000) NULL,
    [sole_trader_phone_number]                                       NVARCHAR (4000) NULL,
    [sole_trader_email]                                              NVARCHAR (4000) NULL,
    [approved_person_first_name]                                     NVARCHAR (4000) NULL,
    [approved_person_last_name]                                      NVARCHAR (4000) NULL,
    [approved_person_phone_number]                                   NVARCHAR (4000) NULL,
    [approved_person_email]                                          NVARCHAR (4000) NULL,
    [approved_person_job_title]                                      NVARCHAR (4000) NULL,
    [delegated_person_first_name]                                    NVARCHAR (4000) NULL,
    [delegated_person_last_name]                                     NVARCHAR (4000) NULL,
    [delegated_person_phone_number]                                  NVARCHAR (4000) NULL,
    [delegated_person_email]                                         NVARCHAR (4000) NULL,
    [delegated_person_job_title]                                     NVARCHAR (4000) NULL,
    [primary_contact_person_first_name]                              NVARCHAR (4000) NULL,
    [primary_contact_person_last_name]                               NVARCHAR (4000) NULL,
    [primary_contact_person_phone_number]                            NVARCHAR (4000) NULL,
    [primary_contact_person_email]                                   NVARCHAR (4000) NULL,
    [primary_contact_person_job_title]                               NVARCHAR (4000) NULL,
    [secondary_contact_person_first_name]                            NVARCHAR (4000) NULL,
    [secondary_contact_person_last_name]                             NVARCHAR (4000) NULL,
    [secondary_contact_person_phone_number]                          NVARCHAR (4000) NULL,
    [secondary_contact_person_email]                                 NVARCHAR (4000) NULL,
    [secondary_contact_person_job_title]                             NVARCHAR (4000) NULL,
    [load_ts]                                                        DATETIME2 (7)   NOT NULL,
    [FileName]                                                       NVARCHAR (4000) NULL,
    [brand_name]                                                     NVARCHAR (4000) NULL,
    [brand_type_code]                                                NVARCHAR (4000) NULL,
    [partner_first_name]                                             NVARCHAR (4000) NULL,
    [partner_last_name]                                              NVARCHAR (4000) NULL,
    [partner_phone_number]                                           NVARCHAR (4000) NULL,
    [partner_email]                                                  NVARCHAR (4000) NULL,
    [Organisations_Id]                                               VARCHAR (20)    NULL,
    [FromOrganisation_TypeId]                                        INT             NULL,
    [FromOrganisation_Type]                                          NVARCHAR (4000) NULL,
    [FromOrganisation_CompaniesHouseNumber]                          NVARCHAR (4000) NULL,
    [FromOrganisation_Name]                                          NVARCHAR (4000) NULL,
    [FromOrganisation_TradingName]                                   NVARCHAR (4000) NULL,
    [FromOrganisation_ReferenceNumber]                               NVARCHAR (4000) NULL,
    [FromOrganisation_SubBuildingName]                               NVARCHAR (4000) NULL,
    [FromOrganisation_BuildingName]                                  NVARCHAR (4000) NULL,
    [FromOrganisation_BuildingNumber]                                NVARCHAR (4000) NULL,
    [FromOrganisation_Street]                                        NVARCHAR (4000) NULL,
    [FromOrganisation_Locality]                                      NVARCHAR (4000) NULL,
    [FromOrganisation_DependentLocality]                             NVARCHAR (4000) NULL,
    [FromOrganisation_Town]                                          NVARCHAR (4000) NULL,
    [FromOrganisation_County]                                        NVARCHAR (4000) NULL,
    [FromOrganisation_Country]                                       NVARCHAR (4000) NULL,
    [FromOrganisation_Postcode]                                      NVARCHAR (4000) NULL,
    [FromOrganisation_ValidatedWithCompaniesHouse]                   BIT             NULL,
    [FromOrganisation_IsComplianceScheme]                            BIT             NULL,
    [FromOrganisation_NationId]                                      INT             NULL,
    [Organisations_CreatedOn]                                        NVARCHAR (4000) NULL,
    [FromOrganisation_IsDeleted]                                     BIT             NULL,
    [FromOrganisation_ProducerTypeId]                                INT             NULL,
    [FromOrganisation_TransferNationId]                              INT             NULL,
    [ToOrganisation_TypeId]                                          INT             NULL,
    [ToOrganisation_Type]                                            NVARCHAR (4000) NULL,
    [ToOrganisation_CompaniesHouseNumber]                            NVARCHAR (4000) NULL,
    [ToOrganisation_Name]                                            NVARCHAR (4000) NULL,
    [ToOrganisation_TradingName]                                     NVARCHAR (4000) NULL,
    [ToOrganisation_ReferenceNumber]                                 NVARCHAR (4000) NULL,
    [ToOrganisation_SubBuildingName]                                 NVARCHAR (4000) NULL,
    [ToOrganisation_BuildingName]                                    NVARCHAR (4000) NULL,
    [ToOrganisation_BuildingNumber]                                  NVARCHAR (4000) NULL,
    [ToOrganisation_Street]                                          NVARCHAR (4000) NULL,
    [ToOrganisation_Locality]                                        NVARCHAR (4000) NULL,
    [ToOrganisation_DependentLocality]                               NVARCHAR (4000) NULL,
    [ToOrganisation_Town]                                            NVARCHAR (4000) NULL,
    [ToOrganisation_County]                                          NVARCHAR (4000) NULL,
    [ToOrganisation_Country]                                         NVARCHAR (4000) NULL,
    [ToOrganisation_Postcode]                                        NVARCHAR (4000) NULL,
    [ToOrganisation_ValidatedWithCompaniesHouse]                     BIT             NULL,
    [ToOrganisation_IsComplianceScheme]                              BIT             NULL,
    [ToOrganisation_NationId]                                        INT             NULL,
    [ToOrganisation_IsDeleted]                                       BIT             NULL,
    [ToOrganisation_ProducerTypeId]                                  INT             NULL,
    [ToOrganisation_TransferNationId]                                INT             NULL,
    [OrganisationConnections_Id]                                     INT             NULL,
    [OrganisationConnections_FromOrganisationId]                     INT             NULL,
    [OrganisationConnections_FromOrganisationRoleId]                 INT             NULL,
    [OrganisationConnections_ToOrganisationId]                       INT             NULL,
    [OrganisationConnections_ToOrganisationRoleId]                   INT             NULL,
    [OrganisationConnections_CreatedOn]                              NVARCHAR (4000) NULL,
    [OrganisationConnections_LastUpdatedOn]                          NVARCHAR (4000) NULL,
    [OrganisationConnections_IsDeleted]                              BIT             NULL,
    [SelectedSchemes_Id]                                             INT             NULL,
    [SelectedSchemes_OrganisationConnectionId]                       INT             NULL,
    [SelectedSchemes_ComplianceSchemeId]                             INT             NULL,
    [SelectedSchemes_CreatedOn]                                      NVARCHAR (4000) NULL,
    [SelectedSchemes_LastUpdatedOn]                                  NVARCHAR (4000) NULL,
    [SelectedSchemes_IsDeleted]                                      BIT             NULL,
    [ComplianceSchemes_Id]                                           INT             NULL,
    [ComplianceSchemes_Name]                                         NVARCHAR (4000) NULL,
    [ComplianceSchemes_CreatedOn]                                    NVARCHAR (4000) NULL,
    [ComplianceSchemes_LastUpdatedOn]                                NVARCHAR (4000) NULL,
    [ComplianceSchemes_IsDeleted]                                    BIT             NULL,
    [ComplianceSchemes_CompaniesHouseNumber]                         NVARCHAR (4000) NULL,
    [InterOrganisationRoles_FromOrganisationRole]                    NVARCHAR (4000) NULL,
    [InterOrganisationRoles_ToOrganisationRole]                      NVARCHAR (4000) NULL,
    [PersonOrganisationConnections_Id]                               INT             NULL,
    [PersonOrganisationConnections_OrganisationId]                   INT             NULL,
    [PersonOrganisationConnections_JobTitle]                         NVARCHAR (4000) NULL,
    [PersonOrganisationConnections_ExternalId]                       NVARCHAR (4000) NULL,
    [PersonOrganisationConnections_CreatedOn]                        NVARCHAR (4000) NULL,
    [PersonOrganisationConnections_LastUpdatedOn]                    NVARCHAR (4000) NULL,
    [PersonOrganisationConnections_IsDeleted]                        BIT             NULL,
    [OrganisationToPersonRoles_Role]                                 NVARCHAR (4000) NULL,
    [PersonInOrganisationRoles_Role]                                 NVARCHAR (4000) NULL,
    [Persons_Id]                                                     INT             NULL,
    [Persons_FirstName]                                              NVARCHAR (4000) NULL,
    [Persons_LastName]                                               NVARCHAR (4000) NULL,
    [Persons_Email]                                                  NVARCHAR (4000) NULL,
    [Persons_Telephone]                                              NVARCHAR (4000) NULL,
    [Persons_CreatedOn]                                              NVARCHAR (4000) NULL,
    [Persons_LastUpdatedOn]                                          NVARCHAR (4000) NULL,
    [Persons_IsDeleted]                                              BIT             NULL,
    [Users_Email]                                                    NVARCHAR (4000) NULL,
    [Users_IsDeleted]                                                BIT             NULL,
    [Users_InviteToken]                                              NVARCHAR (4000) NULL,
    [Users_InvitedBy]                                                NVARCHAR (4000) NULL,
    [Enrolment_Id]                                                   INT             NULL,
    [Enrolment_ConnectionId]                                         INT             NULL,
    [Enrolment_ServiceRoleId]                                        INT             NULL,
    [Enrolment_ValidFrom]                                            NVARCHAR (4000) NULL,
    [Enrolment_ValidTo]                                              NVARCHAR (4000) NULL,
    [Enrolment_ExternalId]                                           NVARCHAR (4000) NULL,
    [Enrolment_CreatedOn]                                            NVARCHAR (4000) NULL,
    [Enrolment_LastUpdatedOn]                                        NVARCHAR (4000) NULL,
    [Enrolment_IsDeleted]                                            BIT             NULL,
    [Enrolment_RegulatorCommentId]                                   INT             NULL,
    [EnrolmentStatuses_EnrolmentStatus]                              NVARCHAR (4000) NULL,
    [ServiceRoles_Id]                                                INT             NULL,
    [ServiceRoles_ServiceId]                                         INT             NULL,
    [ServiceRoles_Key]                                               NVARCHAR (4000) NULL,
    [ServiceRoles_Role]                                              NVARCHAR (4000) NULL,
    [ServiceRoles_Description]                                       NVARCHAR (4000) NULL,
    [Services_Key]                                                   NVARCHAR (4000) NULL,
    [Services_Service]                                               NVARCHAR (4000) NULL,
    [Services_Description]                                           NVARCHAR (4000) NULL,
    [DelegatedPersonEnrolment_RelationshipType]                      NVARCHAR (4000) NULL,
    [DelegatedPersonEnrolment_ConsultancyName]                       NVARCHAR (4000) NULL,
    [DelegatedPersonEnrolment_ComplianceSchemeName]                  NVARCHAR (4000) NULL,
    [DelegatedPersonEnrolment_OtherOrganisationNation]               NVARCHAR (4000) NULL,
    [DelegatedPersonEnrolment_OtherRelationshipDescription]          NVARCHAR (4000) NULL,
    [DelegatedPersonEnrolment_NominatorDeclaration]                  NVARCHAR (4000) NULL,
    [DelegatedPersonEnrolment_NominatorDeclarationTime]              NVARCHAR (4000) NULL,
    [DelegatedPersonEnrolment_NomineeDeclaration]                    NVARCHAR (4000) NULL,
    [DelegatedPersonEnrolment_NomineeDeclarationTime]                NVARCHAR (4000) NULL,
    [DelegatedPersonEnrolment_CreatedOn]                             NVARCHAR (4000) NULL,
    [DelegatedPersonEnrolment_LastUpdatedOn]                         NVARCHAR (4000) NULL,
    [DelegatedPersonEnrolment_IsDeleted]                             BIT             NULL,
    [NominatedDelegatedPersonEnrolment_RelationshipType]             NVARCHAR (4000) NULL,
    [NominatedDelegatedPersonEnrolment_ConsultancyName]              NVARCHAR (4000) NULL,
    [NominatedDelegatedPersonEnrolment_ComplianceSchemeName]         NVARCHAR (4000) NULL,
    [NominatedDelegatedPersonEnrolment_OtherOrganisationNation]      NVARCHAR (4000) NULL,
    [NominatedDelegatedPersonEnrolment_OtherRelationshipDescription] NVARCHAR (4000) NULL,
    [NominatedDelegatedPersonEnrolment_NominatorDeclaration]         NVARCHAR (4000) NULL,
    [NominatedDelegatedPersonEnrolment_NominatorDeclarationTime]     NVARCHAR (4000) NULL,
    [NominatedDelegatedPersonEnrolment_NomineeDeclaration]           NVARCHAR (4000) NULL,
    [NominatedDelegatedPersonEnrolment_NomineeDeclarationTime]       NVARCHAR (4000) NULL,
    [NominatedDelegatedPersonEnrolment_CreatedOn]                    NVARCHAR (4000) NULL,
    [NominatedDelegatedPersonEnrolment_LastUpdatedOn]                NVARCHAR (4000) NULL,
    [NominatedDelegatedPersonEnrolment_IsDeleted]                    BIT             NULL,
    [FromOrganisation_NationName]                                    NVARCHAR (4000) NULL,
    [ToOrganisation_NationName]                                      NVARCHAR (4000) NULL,
    [Security_Id]                                                    BIGINT          NULL,
    [SecurityQuery]                                                  NVARCHAR (4000) NULL,
    [SecurityQuery_OrganisationOrigin]                               INT             NULL,
    [ApprovedPerson_Id]                                              INT             NULL,
    [ApprovedPerson_FirstName]                                       NVARCHAR (4000) NULL,
    [ApprovedPerson_LastName]                                        NVARCHAR (4000) NULL,
    [ApprovedPerson_Email]                                           NVARCHAR (4000) NULL,
    [ApprovedPerson_Telephone]                                       NVARCHAR (4000) NULL,
    [ApprovedPerson_CreatedOn]                                       NVARCHAR (4000) NULL,
    [ApprovedPerson_LastUpdatedOn]                                   NVARCHAR (4000) NULL,
    [ApprovedPerson_IsDeleted]                                       BIT             NULL,
    [ApprovedPerson_JobTitle]                                        NVARCHAR (4000) NULL,
    [DelegatedPerson_Id]                                             INT             NULL,
    [DelegatedPerson_FirstName]                                      NVARCHAR (4000) NULL,
    [DelegatedPerson_LastName]                                       NVARCHAR (4000) NULL,
    [DelegatedPerson_Email]                                          NVARCHAR (4000) NULL,
    [DelegatedPerson_Telephone]                                      NVARCHAR (4000) NULL,
    [DelegatedPerson_CreatedOn]                                      NVARCHAR (4000) NULL,
    [DelegatedPerson_LastUpdatedOn]                                  NVARCHAR (4000) NULL,
    [DelegatedPerson_IsDeleted]                                      BIT             NULL,
    [DelegatedPerson_JobTitle]                                       NVARCHAR (4000) NULL,
    [SubmissionId]                                                   NVARCHAR (4000) NULL,
    [FileId]                                                         NVARCHAR (4000) NULL,
    [UserId]                                                         NVARCHAR (4000) NULL,
    [SubmittedBy]                                                    NVARCHAR (4000) NOT NULL,
    [BlobName]                                                       NVARCHAR (4000) NULL,
    [BlobContainerName]                                              NVARCHAR (4000) NULL,
    [FileType]                                                       NVARCHAR (4000) NULL,
    [Created]                                                        DATETIME        NULL,
    [OriginalFileName]                                               NVARCHAR (4000) NULL,
    [OrganisationId]                                                 NVARCHAR (4000) NULL,
    [DataSourceType]                                                 NVARCHAR (4000) NULL,
    [SubmissionPeriod]                                               NVARCHAR (4000) NULL,
    [IsSubmitted]                                                    BIT             NULL,
    [SubmissionType]                                                 NVARCHAR (4000) NULL,
    [TargetDirectoryName]                                            NVARCHAR (4000) NULL,
    [TargetContainerName]                                            NVARCHAR (4000) NULL,
    [SourceContainerName]                                            NVARCHAR (4000) NULL,
    [cosmos_file_name]                                               NVARCHAR (4000) NULL,
    [cosmos_load_ts]                                                 DATETIME2 (7)   NULL,
    [SubmtterEmail]                                                  NVARCHAR (4000) NULL,
    [ServiceRoles_Name]                                              NVARCHAR (4000) NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = ROUND_ROBIN);

