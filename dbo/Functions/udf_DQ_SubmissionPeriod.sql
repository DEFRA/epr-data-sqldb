CREATE FUNCTION [dbo].[udf_DQ_SubmissionPeriod] (@SubmissionPeriod [nvarchar](250)) RETURNS nvarchar(250)
AS
BEGIN
/*****************************************************************************************************************
	History:

	Created 2024-07-25: SN000:  New function to correctly format erroneous Submission Period Values. Ticket 416355
	Updated 2024-12-19: SN001:	Updated to account for New values containing year for each month in string
	Updated 2025-01-16: SN002:	Updated to account for Jul to July
*****************************************************************************************************************/

    DECLARE @iYrPos	int, @FrmtSubmissionPeriod nvarchar(250), @SPYear int, @FrmtYear int, @nxtChr int
	Begin
		If Isnull(@SubmissionPeriod,'') <> ''
		/*** New Code SN001  ***/

			Set @iYrPos					= PatIndex('%[0-9]%', Reverse(@SubmissionPeriod))
			Set @nxtChr					= CharIndex(' ', Reverse(@SubmissionPeriod))
			Set @SPYear					= Reverse(Substring(Reverse(@SubmissionPeriod),@iYrPos,@nxtChr))
			Set @SubmissionPeriod		= Substring(@SubmissionPeriod,1,Len(@SubmissionPeriod)-(@nxtChr-1)) 
			Set @FrmtYear				= Case When @SPYear	<2000 Then @SPYear + 2000 Else @SPYear End
			Set @FrmtSubmissionPeriod	= Rtrim(Replace(Replace(Replace(Replace(Replace(Replace(@SubmissionPeriod,'Jan ','January '),'Jun ','June '),'Dec ', 'December'),'Mar ','March '),'Apr ','April '),'Jul ','July '))
			Set @FrmtSubmissionPeriod	= Concat(@FrmtSubmissionPeriod,' ', @FrmtYear)
		/*** New Code SN001  ***/

		/*****  Old Code
			Set @iYrPos					= PatIndex('%[0-9]%', @SubmissionPeriod )
			Set @SPYear					= Convert(Int,Substring(@SubmissionPeriod, @iYrPos, Len(@SubmissionPeriod)- @iYrPos+1))
			Set @FrmtYear				= Case When @SPYear	<2000 Then @SPYear + 2000 Else @SPYear End
			Set @FrmtSubmissionPeriod	= Rtrim(Replace(Replace(Replace(Replace(Replace(Left(@SubmissionPeriod,@iYrPos-1),'Jan ','January '),'Jun ','June '),'Dec ', 'December'),'Mar ','March '),'Apr ','April '))
			Set @FrmtSubmissionPeriod	= Concat(@FrmtSubmissionPeriod,' ',@FrmtYear)
		******/
		End
	RETURN @FrmtSubmissionPeriod
END