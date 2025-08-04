CREATE VIEW [dbo].[companydetails_brand_partner_set] AS with 
Brands_set
as
(
	select RegistrationSetId as 'Brand_RegistrationSetId', FileId 'Brand_FileId', FileName 'Brand_FileName'
	from [rpd].[cosmos_file_metadata] 
	where FileType = 'Brands'
),

Partnerships_set as
(
	select RegistrationSetId as 'Partnerships_RegistrationSetId', FileId 'Partnerships_FileId', FileName 'Partnerships_FileName'
	from [rpd].[cosmos_file_metadata] 
	where FileType = 'Partnerships'
),
CompanyDetails_set as
(
	select RegistrationSetId as 'CompanyDetails_RegistrationSetId', FileId 'CompanyDetails_FileId', FileName 'CompanyDetails_FileName'
	from [rpd].[cosmos_file_metadata] 
	where FileType = 'CompanyDetails'
)

select distinct
	CompanyDetails_set.CompanyDetails_RegistrationSetId
	,CompanyDetails_set.CompanyDetails_FileId
	,CompanyDetails_set.CompanyDetails_FileName
	,Brands_set.Brand_FileId
	,Brands_set.Brand_FileName
	,Partnerships_set.Partnerships_FileId
	,Partnerships_set.Partnerships_FileName
from CompanyDetails_set
left join Brands_set on CompanyDetails_set.CompanyDetails_RegistrationSetId = Brands_set.Brand_RegistrationSetId
left join Partnerships_set on CompanyDetails_set.CompanyDetails_RegistrationSetId = Partnerships_set.Partnerships_RegistrationSetId;