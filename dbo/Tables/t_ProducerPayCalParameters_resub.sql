CREATE TABLE [dbo].[t_ProducerPayCalParameters_resub]
(
    [OrganisationExternalId]        NVARCHAR (4000)  NULL,      -- cfm.OrganisationId      VERIFY (rpd.cosmos_file_metadata)
    [OrganisationId]                INT              NULL,      -- cd.Organisation_Id      VERIFY (rpd.CompanyDetails)
    [FileName]                      NVARCHAR (4000)  NULL,      -- cd.FileName             VERIFY (rpd.CompanyDetails)
    [FileId]                        NVARCHAR (4000)  NULL,      -- cfm.FileId              VERIFY (rpd.cosmos_file_metadata)
    [RegistrationSetId]             NVARCHAR (4000)  NULL,      -- cfm.RegistrationSetId   VERIFY (rpd.cosmos_file_metadata)
    [IsOnlineMarketPlace]           BIT              NULL,      -- CAST(... AS BIT)        confirmed
    [OrganisationSize]              NVARCHAR (4000)  NOT NULL,      -- cd.Organisation_Size    VERIFY (rpd.CompanyDetails)
    [ProducerSize]                  NVARCHAR (4000)  NOT NULL,      -- CASE over Organisation_Size; same family, len >= 5  VERIFY
    [NationId]                      INT              NULL,      -- CASE -> 1..4, no ELSE   confirmed (nullable)
    [NumberOfSubsidiaries]          INT              NOT NULL,  -- ISNULL(COUNT(DISTINCT ...),0)  confirmed
    [OnlineMarketPlaceSubsidiaries] INT              NOT NULL   -- ISNULL(COUNT(...),0)           confirmed
)
WITH
(
    DISTRIBUTION = ROUND_ROBIN,
    CLUSTERED COLUMNSTORE INDEX
);
GO