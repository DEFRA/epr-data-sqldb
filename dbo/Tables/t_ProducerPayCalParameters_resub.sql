CREATE TABLE [dbo].[t_ProducerPayCalParameters_resub] (
    [OrganisationExternalId]        NVARCHAR (4000) NULL,
    [OrganisationId]                INT             NULL,
    [FileName]                      NVARCHAR (4000) NULL,
    [FileId]                        NVARCHAR (4000) NULL,
    [RegistrationSetId]             NVARCHAR (4000) NULL,
    [IsOnlineMarketPlace]           BIT             NULL,
    [OrganisationSize]              NVARCHAR (4000) NOT NULL,
    [ProducerSize]                  NVARCHAR (4000) NOT NULL,
    [NationId]                      INT             NULL,
    [NumberOfSubsidiaries]          INT             NOT NULL,
    [OnlineMarketPlaceSubsidiaries] INT             NOT NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = ROUND_ROBIN);

