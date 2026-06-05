CREATE PROCEDURE [dbo].[sp_CSO_Pom_Resubmitted_ByCSID]
    @CSOrganisation_ID [int],
    @ComplianceSchemeId [nvarchar](40),
    @SubmissionPeriod [varchar](100),
    @MemberCount [int] OUTPUT
AS
BEGIN
SET NOCOUNT ON;

select @MemberCount=MemberCount from [dbo].[t_CSO_Pom_Resubmitted_ByCSID] where 
CS_Reference_number= @CSOrganisation_ID and CSid=@ComplianceSchemeId and submissionperiod=@SubmissionPeriod;

END;
