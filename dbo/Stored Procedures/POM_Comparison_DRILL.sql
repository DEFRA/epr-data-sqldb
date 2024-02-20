CREATE PROC [dbo].[POM_Comparison_DRILL] @filename1 [nvarchar](4000),@filename2 [nvarchar](4000),@ProducerCS [nvarchar](100),@organisation_id [int],@compliance_scheme [nvarchar](200),@securityquery [nvarchar](200),@BreakdownType [nvarchar](100),@packaging_type [nvarchar](100),@packaging_material [nvarchar](100),@packaging_class [nvarchar](100),@relative_move [nvarchar](100),@from_nation [nvarchar](100) AS
BEGIN
    --declare @organisation_id [int]
    --set @organisation_id = '100230'

    SELECT [organisation_id]
      , [subsidiary_id]
      , [organisation_size]
      , [submission_period]
      , [packaging_activity]
      , [packaging_type]
      , [packaging_class]
      , [packaging_material]
      , [packaging_sub_material]
      , [from_nation]
      , [to_nation]
      , [quantity_kg]
      , [quantity_unit]
      , [FileName]
      , [Quantity_kg_extrapolated] 
      , [Quantity_units_extrapolated] 
      , [relative_move]
	  , submission_date
	  , org_sub_type
	  , org_name
	    , compliance_scheme
        , registration_type_code
    into #file1
    FROM [dbo].[t_POM_Submissions_POM_Comparison]
    WHERE nation = @securityquery
        and FileName = @filename1
        AND
        (
    (@producerCS = 'Producer' AND [organisation_id] = @organisation_id)
        OR
        (@producerCS = 'Compliance Scheme' AND compliance_scheme = @compliance_scheme and data_type = 'Member'
	)
  )

    SELECT [organisation_id]
      , [subsidiary_id]
      , [organisation_size]
      , [submission_period]
      , [packaging_activity]
      , [packaging_type]
      , [packaging_class]
      , [packaging_material]
      , [packaging_sub_material]
      , [from_nation]
      , [to_nation]
      , [quantity_kg]
      , [quantity_unit]
      , [FileName]
      , [Quantity_kg_extrapolated]
      , [Quantity_units_extrapolated]
      , [relative_move]
	  , submission_date
	  , org_sub_type
	  , org_name
	  , compliance_scheme
     , registration_type_code
    into #file2
    FROM [dbo].[t_POM_Submissions_POM_Comparison]
    where  nation = @securityquery
        and FileName = @filename2

        AND
        (
    (@producerCS = 'Producer' AND [organisation_id] = @organisation_id)
        OR
        (@producerCS = 'Compliance Scheme' AND compliance_scheme = @compliance_scheme and data_type = 'Member'
	)
  )

    select coalesce(a.[organisation_id],b.[organisation_id]) OrganisationName ,
        coalesce(a.[subsidiary_id],b.[subsidiary_id]) [subsidiary_id] ,
        coalesce(a.packaging_material,b.packaging_material) packaging_material
 , coalesce(a.[from_nation],b.[from_nation]) [from_nation]
 , coalesce(a.packaging_activity,b.packaging_activity)packaging_activity
 , coalesce(a.packaging_class,b.packaging_class)packaging_class

 , coalesce(a.packaging_sub_material,b.packaging_sub_material)packaging_sub_material
 , coalesce(a.to_nation,b.to_nation)to_nation
 , coalesce(a.relative_move,b.relative_move)relative_move

  , coalesce(a.packaging_type,b.packaging_type)packaging_type 
 , a.quantity_kg file1_quantity_kg, b.quantity_kg file2_quantity_kg
   , a.quantity_unit file1_quantity_unit, b.quantity_unit file2_quantity_unit
   , a.Quantity_kg_extrapolated file1_Quantity_kg_extrapolated, b.Quantity_kg_extrapolated file2_Quantity_kg_extrapolated
   , isnull(b.quantity_kg, '0') - isnull(a.quantity_kg,'0') as quantity_kg_diff
	  , isnull(b.quantity_unit,'0') - isnull(a.quantity_unit,'0') as quantity_unit_diff
	  , isnull(b.Quantity_kg_extrapolated,'0') - isnull(a.Quantity_kg_extrapolated,'0') as Quantity_kg_extrapolated_diff
	  , isnull(b.Quantity_units_extrapolated,'0') - isnull(a.Quantity_units_extrapolated,'0') as Quantity_units_extrapolated_diff
	  , a.filename filename1
	  , b.filename filename2
	  , a.submission_date file1_submission_date
	  , b.submission_date file2_submission_date
	  , coalesce(a.org_sub_type,b.org_sub_type)org_sub_type 
	  , coalesce(a.org_name,b.org_name)org_name 
	    , coalesce(a.organisation_size,b.organisation_size)organisation_size 
		  , coalesce(a.compliance_scheme,b.compliance_scheme)compliance_scheme
          	  , coalesce(a.registration_type_code,b.registration_type_code)registration_type_code
    --US 246659 - Org size added
    into #file_joined_1
    from #file1 a
        full outer join #file2 b on isnull(a.[organisation_id],'') = isnull(b.[organisation_id],'')
            and isnull(a.[subsidiary_id],'') = isnull(b.[subsidiary_id],'')
            and isnull(a.organisation_id,'') = isnull(b.organisation_id,'')
            and isnull(a.[packaging_activity],'') = isnull(b.packaging_activity,'')
            and isnull(a.[packaging_type],'') = isnull(b.packaging_type,'')
            and isnull(a.[packaging_class],'') =isnull(b.packaging_class,'')
            and isnull(a.[packaging_material],'') = isnull(b.packaging_material,'')
            and isnull(a.[packaging_sub_material],'') = isnull(b.packaging_sub_material,'')
            and isnull(a.[from_nation],'') = isnull(b.from_nation,'')
            and isnull(a.[to_nation],'') = isnull(b.to_nation,'')
   and isnull(a.[organisation_size],'') = isnull(b.organisation_size,'')

    select *, case when packaging_type in ('Total Non-Household packaging','Total Household packaging','Public binned','Reusable packaging','Household drinks containers','Non-household drinks containers')
then 'Total Packaging' else null end Total_Packaging
    into
      #file_joined
    from #file_joined_1



if @BreakdownType = 'relative_move'


select  OrganisationName,subsidiary_id, packaging_material field2, relative_move field3
, file1_Quantity_kg_extrapolated,file2_Quantity_kg_extrapolated,
quantity_kg_diff ,file1_submission_date,file2_submission_date,Quantity_kg_extrapolated_diff
 from   #file_joined
where @packaging_material = packaging_material 
and @relative_move  = relative_move 
and packaging_type = 'Self-managed consumer waste'



if @BreakdownType = 'from_nation'

select  OrganisationName,subsidiary_id, packaging_material field2, from_nation field3
, file1_Quantity_kg_extrapolated,file2_Quantity_kg_extrapolated,
quantity_kg_diff ,file1_submission_date,file2_submission_date,Quantity_kg_extrapolated_diff
 from   #file_joined
where @packaging_material = packaging_material 
and from_nation = @from_nation
and packaging_type = 'Self-managed consumer waste'
and isnull(relative_move,'') =''


if @BreakdownType = 'from_org'

select  OrganisationName,subsidiary_id, packaging_material field2, from_nation field3
, file1_Quantity_kg_extrapolated,file2_Quantity_kg_extrapolated,
quantity_kg_diff ,file1_submission_date,file2_submission_date,Quantity_kg_extrapolated_diff
 from   #file_joined
where @packaging_material = packaging_material 
and from_nation = @from_nation
and packaging_type = 'Self-managed organisation waste'
and isnull(relative_move,'') =''



if @BreakdownType = 'relative_move_org'


select  OrganisationName,subsidiary_id, packaging_material field2, relative_move field3
, file1_Quantity_kg_extrapolated,file2_Quantity_kg_extrapolated,
quantity_kg_diff ,file1_submission_date,file2_submission_date,Quantity_kg_extrapolated_diff
 from   #file_joined
where @packaging_material = packaging_material 
and @relative_move  = relative_move 
and packaging_type = 'Self-managed organisation waste'


-------
--ALL PACKAGING
-------

if @BreakdownType = 'hp_all'


select  OrganisationName,subsidiary_id, packaging_material field2, packaging_class field3
, file1_Quantity_kg_extrapolated,file2_Quantity_kg_extrapolated,
quantity_kg_diff ,file1_submission_date,file2_submission_date,Quantity_kg_extrapolated_diff
 from   #file_joined
where @packaging_material = packaging_material 
and @packaging_class = packaging_class
and packaging_type = 'Total Household Packaging'

if @BreakdownType = 'nhp_all'


select  OrganisationName,subsidiary_id, packaging_material field2, packaging_class field3
, file1_Quantity_kg_extrapolated,file2_Quantity_kg_extrapolated,
quantity_kg_diff ,file1_submission_date,file2_submission_date,Quantity_kg_extrapolated_diff
 from   #file_joined
where @packaging_material = packaging_material 
and @packaging_class = packaging_class
and packaging_type = 'Total Non-Household Packaging'





if @BreakdownType = 'hdc_all'


select  OrganisationName,subsidiary_id, packaging_material field2, '' field3
, file1_Quantity_kg_extrapolated,file2_Quantity_kg_extrapolated,
quantity_kg_diff ,file1_submission_date,file2_submission_date,Quantity_kg_extrapolated_diff
 from   #file_joined
where @packaging_material = packaging_material 
and packaging_type = 'Household drinks containers'

if @BreakdownType = 'nhdc_all'

select  OrganisationName,subsidiary_id, packaging_material field2, '' field3
, file1_Quantity_kg_extrapolated,file2_Quantity_kg_extrapolated,
quantity_kg_diff ,file1_submission_date,file2_submission_date,Quantity_kg_extrapolated_diff
 from   #file_joined
where @packaging_material = packaging_material 
and packaging_type = 'Non-Household drinks containers'



if @BreakdownType = 'drinks_all'


select  OrganisationName,subsidiary_id, packaging_material field2, '' field3
, file1_Quantity_kg_extrapolated,file2_Quantity_kg_extrapolated,
quantity_kg_diff ,file1_submission_date,file2_submission_date,Quantity_kg_extrapolated_diff
 from   #file_joined
where @packaging_material = packaging_material 
and packaging_type like  '%Household drinks containers'


if @BreakdownType = 'rp_all'


select  OrganisationName,subsidiary_id, packaging_material field2, packaging_class field3
, file1_Quantity_kg_extrapolated,file2_Quantity_kg_extrapolated,
quantity_kg_diff ,file1_submission_date,file2_submission_date,Quantity_kg_extrapolated_diff
 from   #file_joined
where @packaging_material = packaging_material 
and @packaging_class = packaging_class
and packaging_type = 'reusable packaging'


if @BreakdownType = 'tp_all'


select  OrganisationName,subsidiary_id, packaging_material field2, '' field3
, file1_Quantity_kg_extrapolated,file2_Quantity_kg_extrapolated,
quantity_kg_diff ,file1_submission_date,file2_submission_date,Quantity_kg_extrapolated_diff
 from   #file_joined
where @packaging_material = packaging_material 
and total_packaging = 'Total packaging'


if @BreakdownType = 'hp_all_total'


select  OrganisationName,subsidiary_id, packaging_material field2, ''field3
, file1_Quantity_kg_extrapolated,file2_Quantity_kg_extrapolated,
quantity_kg_diff ,file1_submission_date,file2_submission_date,Quantity_kg_extrapolated_diff
 from   #file_joined
where @packaging_material = packaging_material 
and packaging_type = ('Total Household Packaging')

if @BreakdownType = 'nhp_all_total'


select  OrganisationName,subsidiary_id, packaging_material field2, ''field3
, file1_Quantity_kg_extrapolated,file2_Quantity_kg_extrapolated,
quantity_kg_diff ,file1_submission_date,file2_submission_date,Quantity_kg_extrapolated_diff
 from   #file_joined
where @packaging_material = packaging_material 
and packaging_type = ('Total Non-Household Packaging')

if @BreakdownType = 'rp_all_total'


select  OrganisationName,subsidiary_id, packaging_material field2, '' field3
, file1_Quantity_kg_extrapolated,file2_Quantity_kg_extrapolated,
quantity_kg_diff ,file1_submission_date,file2_submission_date,Quantity_kg_extrapolated_diff
 from   #file_joined
where @packaging_material = packaging_material 
and packaging_type = 'reusable packaging'




---
--BRAND Owner
---




if @BreakdownType = 'all_pm_hh_pa'
select  OrganisationName,subsidiary_id, packaging_material field2, packaging_class field3
, file1_Quantity_kg_extrapolated,file2_Quantity_kg_extrapolated,
quantity_kg_diff ,file1_submission_date,file2_submission_date,Quantity_kg_extrapolated_diff
 from   #file_joined
where @packaging_material = packaging_material 
and @packaging_class = packaging_class
and packaging_activity = 'Brand Owner'
and packaging_type = 'Total Household Packaging'

--pubic binned
if @BreakdownType = 'all_pm_pb_pa'
select  OrganisationName,subsidiary_id, packaging_material field2, packaging_class field3
, file1_Quantity_kg_extrapolated,file2_Quantity_kg_extrapolated,
quantity_kg_diff ,file1_submission_date,file2_submission_date,Quantity_kg_extrapolated_diff
 from   #file_joined
where @packaging_material = packaging_material 
and @packaging_class = packaging_class
and packaging_activity = 'Brand Owner'
and packaging_type = 'Public Binned'

--non-household
if @BreakdownType = 'all_pm_tnh_pa'
select  OrganisationName,subsidiary_id, packaging_material field2, packaging_class field3
, file1_Quantity_kg_extrapolated,file2_Quantity_kg_extrapolated,
quantity_kg_diff ,file1_submission_date,file2_submission_date,Quantity_kg_extrapolated_diff
 from   #file_joined
where @packaging_material = packaging_material 
and @packaging_class = packaging_class
and packaging_activity = 'Brand Owner'
and packaging_type = 'Total non-Household Packaging'

--HH drinks
if @BreakdownType = 'all_pm_pa_HH_drinks'
select  OrganisationName,subsidiary_id, packaging_material field2, '' field3
, file1_Quantity_kg_extrapolated,file2_Quantity_kg_extrapolated,
quantity_kg_diff ,file1_submission_date,file2_submission_date,Quantity_kg_extrapolated_diff
 from   #file_joined
where @packaging_material = packaging_material 
and packaging_activity = 'Brand Owner'
and packaging_type = 'Household drinks containers'

--non HH drinks
if @BreakdownType = 'all_pm_pa_nHH_drinks'
select  OrganisationName,subsidiary_id, packaging_material field2, '' field3
, file1_Quantity_kg_extrapolated,file2_Quantity_kg_extrapolated,
quantity_kg_diff ,file1_submission_date,file2_submission_date,Quantity_kg_extrapolated_diff
 from   #file_joined
where @packaging_material = packaging_material 
and packaging_activity = 'Brand Owner'
and packaging_type = 'Non-household drinks containers'

--all drinks
if @BreakdownType = 'all_pm_pa_all_drinks'
select  OrganisationName,subsidiary_id, packaging_material field2, '' field3
, file1_Quantity_kg_extrapolated,file2_Quantity_kg_extrapolated,
quantity_kg_diff ,file1_submission_date,file2_submission_date,Quantity_kg_extrapolated_diff
 from   #file_joined
where @packaging_material = packaging_material 
and packaging_activity = 'Brand Owner'
and packaging_type like  '%Household drinks containers'


--reusable packclass
if @BreakdownType = 'all_pm_pa_reusable'
select  OrganisationName,subsidiary_id, packaging_material field2, packaging_class field3
, file1_Quantity_kg_extrapolated,file2_Quantity_kg_extrapolated,
quantity_kg_diff ,file1_submission_date,file2_submission_date,Quantity_kg_extrapolated_diff
 from   #file_joined
where @packaging_material = packaging_material 
and @packaging_class = packaging_class
and packaging_activity = 'Brand Owner'
and packaging_type = 'Reusable packaging'

--total packaging
if @BreakdownType = 'all_pm_pa_tp'
select  OrganisationName,subsidiary_id, packaging_material field2, packaging_class field3
, file1_Quantity_kg_extrapolated,file2_Quantity_kg_extrapolated,
quantity_kg_diff ,file1_submission_date,file2_submission_date,Quantity_kg_extrapolated_diff
 from   #file_joined
where @packaging_material = packaging_material 
and packaging_activity = 'Brand Owner'
and Total_Packaging = 'total packaging'

--hh
if @BreakdownType = 'all_pm_pa_total_hh'
select  OrganisationName,subsidiary_id, packaging_material field2, packaging_class field3
, file1_Quantity_kg_extrapolated,file2_Quantity_kg_extrapolated,
quantity_kg_diff ,file1_submission_date,file2_submission_date,Quantity_kg_extrapolated_diff
 from   #file_joined
where @packaging_material = packaging_material 
and packaging_activity = 'Brand Owner'
and packaging_type = 'Total Household packaging'


--nhh
if @BreakdownType = 'all_pm_pa_total_nonhh'
select  OrganisationName,subsidiary_id, packaging_material field2, packaging_class field3
, file1_Quantity_kg_extrapolated,file2_Quantity_kg_extrapolated,
quantity_kg_diff ,file1_submission_date,file2_submission_date,Quantity_kg_extrapolated_diff
 from   #file_joined
where @packaging_material = packaging_material 
and packaging_activity = 'Brand Owner'
and packaging_type = 'Total Non-Household packaging'

--reuse

if @BreakdownType = 'all_pm_pa_total_reusable'
select  OrganisationName,subsidiary_id, packaging_material field2, packaging_class field3
, file1_Quantity_kg_extrapolated,file2_Quantity_kg_extrapolated,
quantity_kg_diff ,file1_submission_date,file2_submission_date,Quantity_kg_extrapolated_diff
 from   #file_joined
where @packaging_material = packaging_material 
and packaging_activity = 'Brand Owner'
and packaging_type = 'Reusable packaging'






--PACKER FILLER




if @BreakdownType = 'all_pm_hh_pa_pack'
select  OrganisationName,subsidiary_id, packaging_material field2, packaging_class field3
, file1_Quantity_kg_extrapolated,file2_Quantity_kg_extrapolated,
quantity_kg_diff ,file1_submission_date,file2_submission_date,Quantity_kg_extrapolated_diff
 from   #file_joined
where @packaging_material = packaging_material 
and @packaging_class = packaging_class
and packaging_activity = 'Packer / Filler'
and packaging_type = 'Total Household packaging'

--pubic binned
if @BreakdownType = 'all_pm_pb_pa_pack'
select  OrganisationName,subsidiary_id, packaging_material field2, packaging_class field3
, file1_Quantity_kg_extrapolated,file2_Quantity_kg_extrapolated,
quantity_kg_diff ,file1_submission_date,file2_submission_date,Quantity_kg_extrapolated_diff
 from   #file_joined
where @packaging_material = packaging_material 
and @packaging_class = packaging_class
and packaging_activity = 'Packer / Filler'
and packaging_type = 'Public Binned'


--non-household
if @BreakdownType = 'all_pm_tnh_pa_pack'
select  OrganisationName,subsidiary_id, packaging_material field2, packaging_class field3
, file1_Quantity_kg_extrapolated,file2_Quantity_kg_extrapolated,
quantity_kg_diff ,file1_submission_date,file2_submission_date,Quantity_kg_extrapolated_diff
 from   #file_joined
where @packaging_material = packaging_material 
and @packaging_class = packaging_class
and packaging_activity = 'Packer / Filler'
and packaging_type = 'Total Non-Household packaging'

--HH drinks
if @BreakdownType = 'all_pm_pa_HH_drinks_pack'
select  OrganisationName,subsidiary_id, packaging_material field2, '' field3
, file1_Quantity_kg_extrapolated,file2_Quantity_kg_extrapolated,
quantity_kg_diff ,file1_submission_date,file2_submission_date,Quantity_kg_extrapolated_diff
 from   #file_joined
where @packaging_material = packaging_material 
and packaging_activity = 'Packer / Filler'
and packaging_type = 'Household drinks containers'

--non HH drinks
if @BreakdownType = 'all_pm_pa_nHH_drinks_pack'
select  OrganisationName,subsidiary_id, packaging_material field2, '' field3
, file1_Quantity_kg_extrapolated,file2_Quantity_kg_extrapolated,
quantity_kg_diff ,file1_submission_date,file2_submission_date,Quantity_kg_extrapolated_diff
 from   #file_joined
where @packaging_material = packaging_material 
and packaging_activity = 'Packer / Filler'
and packaging_type = 'Non-household drinks containers'


--all drinks
if @BreakdownType = 'all_pm_pa_all_drinks_pack'
select  OrganisationName,subsidiary_id, packaging_material field2, '' field3
, file1_Quantity_kg_extrapolated,file2_Quantity_kg_extrapolated,
quantity_kg_diff ,file1_submission_date,file2_submission_date,Quantity_kg_extrapolated_diff
 from   #file_joined
where @packaging_material = packaging_material 
and packaging_activity = 'Packer / Filler'
and packaging_type like  '%Household drinks containers'

--reusable packclass
if @BreakdownType = 'all_pm_pa_reusable_pack'
select  OrganisationName,subsidiary_id, packaging_material field2, packaging_class field3
, file1_Quantity_kg_extrapolated,file2_Quantity_kg_extrapolated,
quantity_kg_diff ,file1_submission_date,file2_submission_date,Quantity_kg_extrapolated_diff
 from   #file_joined
where @packaging_material = packaging_material 
and @packaging_class = packaging_class
and packaging_activity = 'Packer / Filler'
and packaging_type = 'Reusable packaging'

--total packaging
if @BreakdownType = 'all_pm_pa_tp'
select  OrganisationName,subsidiary_id, packaging_material field2, packaging_class field3
, file1_Quantity_kg_extrapolated,file2_Quantity_kg_extrapolated,
quantity_kg_diff ,file1_submission_date,file2_submission_date,Quantity_kg_extrapolated_diff
 from   #file_joined
where @packaging_material = packaging_material 
and packaging_activity = 'Packer / Filler'
and Total_Packaging = 'total packaging'


--hh
if @BreakdownType = 'all_pm_pa_total_hh_pack'
select  OrganisationName,subsidiary_id, packaging_material field2, packaging_class field3
, file1_Quantity_kg_extrapolated,file2_Quantity_kg_extrapolated,
quantity_kg_diff ,file1_submission_date,file2_submission_date,Quantity_kg_extrapolated_diff
 from   #file_joined
where @packaging_material = packaging_material 
and packaging_activity = 'Packer / Filler'
and packaging_type = 'Total Household packaging'

--nhh
if @BreakdownType = 'all_pm_pa_total_nonhh_pack'
select  OrganisationName,subsidiary_id, packaging_material field2, packaging_class field3
, file1_Quantity_kg_extrapolated,file2_Quantity_kg_extrapolated,
quantity_kg_diff ,file1_submission_date,file2_submission_date,Quantity_kg_extrapolated_diff
 from   #file_joined
where @packaging_material = packaging_material 
and packaging_activity = 'Packer / Filler'
and packaging_type = 'Total Non-Household packaging'


--reuse

if @BreakdownType = 'all_pm_pa_total_reusable_pack'
select  OrganisationName,subsidiary_id, packaging_material field2, packaging_class field3
, file1_Quantity_kg_extrapolated,file2_Quantity_kg_extrapolated,
quantity_kg_diff ,file1_submission_date,file2_submission_date,Quantity_kg_extrapolated_diff
 from   #file_joined
where @packaging_material = packaging_material 
and packaging_activity = 'Packer / Filler'
and packaging_type = 'Reusable packaging'




-----Imported



if @BreakdownType = 'all_pm_hh_pa_Imported'
select  OrganisationName,subsidiary_id, packaging_material field2, packaging_class field3
, file1_Quantity_kg_extrapolated,file2_Quantity_kg_extrapolated,
quantity_kg_diff ,file1_submission_date,file2_submission_date,Quantity_kg_extrapolated_diff
 from   #file_joined
where @packaging_material = packaging_material 
and @packaging_class = packaging_class
and packaging_activity = 'Imported'
and packaging_type = 'Total Household packaging'

--pubic binned
if @BreakdownType = 'all_pm_pb_pa_Imported'
select  OrganisationName,subsidiary_id, packaging_material field2, packaging_class field3
, file1_Quantity_kg_extrapolated,file2_Quantity_kg_extrapolated,
quantity_kg_diff ,file1_submission_date,file2_submission_date,Quantity_kg_extrapolated_diff
 from   #file_joined
where @packaging_material = packaging_material 
and @packaging_class = packaging_class
and packaging_activity = 'Imported'
and packaging_type = 'Public Binned'

--non-household
if @BreakdownType = 'all_pm_tnh_pa_Imported'
select  OrganisationName,subsidiary_id, packaging_material field2, packaging_class field3
, file1_Quantity_kg_extrapolated,file2_Quantity_kg_extrapolated,
quantity_kg_diff ,file1_submission_date,file2_submission_date,Quantity_kg_extrapolated_diff
 from   #file_joined
where @packaging_material = packaging_material 
and @packaging_class = packaging_class
and packaging_activity = 'Imported'
and packaging_type = 'Total Non-Household packaging'

--HH drinks
if @BreakdownType = 'all_pm_pa_HH_drinks_Imported'
select  OrganisationName,subsidiary_id, packaging_material field2, '' field3
, file1_Quantity_kg_extrapolated,file2_Quantity_kg_extrapolated,
quantity_kg_diff ,file1_submission_date,file2_submission_date,Quantity_kg_extrapolated_diff
 from   #file_joined
where @packaging_material = packaging_material 
and packaging_activity = 'Imported'
and packaging_type = 'Household drinks containers'

--non HH drinks
if @BreakdownType = 'all_pm_pa_nHH_drinks_Imported'
select  OrganisationName,subsidiary_id, packaging_material field2, '' field3
, file1_Quantity_kg_extrapolated,file2_Quantity_kg_extrapolated,
quantity_kg_diff ,file1_submission_date,file2_submission_date,Quantity_kg_extrapolated_diff
 from   #file_joined
where @packaging_material = packaging_material 
and packaging_activity = 'Imported'
and packaging_type = 'Non-household drinks containers'

--all drinks
if @BreakdownType = 'all_pm_pa_all_drinks_Imported'
select  OrganisationName,subsidiary_id, packaging_material field2, '' field3
, file1_Quantity_kg_extrapolated,file2_Quantity_kg_extrapolated,
quantity_kg_diff ,file1_submission_date,file2_submission_date,Quantity_kg_extrapolated_diff
 from   #file_joined
where @packaging_material = packaging_material 
and packaging_activity = 'Imported'
and packaging_type like  '%Household drinks containers'

--reusable packclass
if @BreakdownType = 'all_pm_pa_reusable_Imported'
select  OrganisationName,subsidiary_id, packaging_material field2, packaging_class field3
, file1_Quantity_kg_extrapolated,file2_Quantity_kg_extrapolated,
quantity_kg_diff ,file1_submission_date,file2_submission_date,Quantity_kg_extrapolated_diff
 from   #file_joined
where @packaging_material = packaging_material 
and @packaging_class = packaging_class
and packaging_activity = 'Imported'
and packaging_type = 'Reusable packaging'

--total packaging
if @BreakdownType = 'all_pm_pa_tp_Imported'
select  OrganisationName,subsidiary_id, packaging_material field2, packaging_class field3
, file1_Quantity_kg_extrapolated,file2_Quantity_kg_extrapolated,
quantity_kg_diff ,file1_submission_date,file2_submission_date,Quantity_kg_extrapolated_diff
 from   #file_joined
where @packaging_material = packaging_material 
and packaging_activity = 'Imported'
and Total_Packaging = 'total packaging'

--hh
if @BreakdownType = 'all_pm_pa_total_hh_Imported'
select  OrganisationName,subsidiary_id, packaging_material field2, packaging_class field3
, file1_Quantity_kg_extrapolated,file2_Quantity_kg_extrapolated,
quantity_kg_diff ,file1_submission_date,file2_submission_date,Quantity_kg_extrapolated_diff
 from   #file_joined
where @packaging_material = packaging_material 
and packaging_activity = 'Imported'
and packaging_type = 'Total Household packaging'

--nhh
if @BreakdownType = 'all_pm_pa_total_nonhh_Imported'
select  OrganisationName,subsidiary_id, packaging_material field2, packaging_class field3
, file1_Quantity_kg_extrapolated,file2_Quantity_kg_extrapolated,
quantity_kg_diff ,file1_submission_date,file2_submission_date,Quantity_kg_extrapolated_diff
 from   #file_joined
where @packaging_material = packaging_material 
and packaging_activity = 'Imported'
and packaging_type = 'Total Non-Household packaging'

--reuse

if @BreakdownType = 'all_pm_pa_total_reusable_Imported'
select  OrganisationName,subsidiary_id, packaging_material field2, packaging_class field3
, file1_Quantity_kg_extrapolated,file2_Quantity_kg_extrapolated,
quantity_kg_diff ,file1_submission_date,file2_submission_date,Quantity_kg_extrapolated_diff
 from   #file_joined
where @packaging_material = packaging_material 
and packaging_activity = 'Imported'
and packaging_type = 'Reusable packaging'






---Sold as empty







if @BreakdownType = 'all_pm_hh_pa_sold'
select  OrganisationName,subsidiary_id, packaging_material field2, packaging_class field3
, file1_Quantity_kg_extrapolated,file2_Quantity_kg_extrapolated,
quantity_kg_diff ,file1_submission_date,file2_submission_date,Quantity_kg_extrapolated_diff
 from   #file_joined
where @packaging_material = packaging_material 
and @packaging_class = packaging_class
and packaging_activity = 'Sold as empty'
and packaging_type = 'Total Household packaging'

--pubic binned
if @BreakdownType = 'all_pm_pb_pa_sold'
select  OrganisationName,subsidiary_id, packaging_material field2, packaging_class field3
, file1_Quantity_kg_extrapolated,file2_Quantity_kg_extrapolated,
quantity_kg_diff ,file1_submission_date,file2_submission_date,Quantity_kg_extrapolated_diff
 from   #file_joined
where @packaging_material = packaging_material 
and @packaging_class = packaging_class
and packaging_activity = 'Sold as empty'
and packaging_type = 'Public Binned'

--non-household
if @BreakdownType = 'all_pm_tnh_pa_sold'
select  OrganisationName,subsidiary_id, packaging_material field2, packaging_class field3
, file1_Quantity_kg_extrapolated,file2_Quantity_kg_extrapolated,
quantity_kg_diff ,file1_submission_date,file2_submission_date,Quantity_kg_extrapolated_diff
 from   #file_joined
where @packaging_material = packaging_material 
and @packaging_class = packaging_class
and packaging_activity = 'Sold as empty'
and packaging_type = 'Total Non-Household packaging'

--HH drinks
if @BreakdownType = 'all_pm_pa_HH_drinks_sold'
select  OrganisationName,subsidiary_id, packaging_material field2, '' field3
, file1_Quantity_kg_extrapolated,file2_Quantity_kg_extrapolated,
quantity_kg_diff ,file1_submission_date,file2_submission_date,Quantity_kg_extrapolated_diff
 from   #file_joined
where @packaging_material = packaging_material 
and packaging_activity = 'Sold as empty'
and packaging_type = 'Household drinks containers'

--non HH drinks
if @BreakdownType = 'all_pm_pa_nHH_drinks_sold'
select  OrganisationName,subsidiary_id, packaging_material field2, '' field3
, file1_Quantity_kg_extrapolated,file2_Quantity_kg_extrapolated,
quantity_kg_diff ,file1_submission_date,file2_submission_date,Quantity_kg_extrapolated_diff
 from   #file_joined
where @packaging_material = packaging_material 
and packaging_activity = 'Sold as empty'
and packaging_type = 'Non-household drinks containers'

--all drinks
if @BreakdownType = 'all_pm_pa_all_drinks_sold'
select  OrganisationName,subsidiary_id, packaging_material field2, '' field3
, file1_Quantity_kg_extrapolated,file2_Quantity_kg_extrapolated,
quantity_kg_diff ,file1_submission_date,file2_submission_date,Quantity_kg_extrapolated_diff
 from   #file_joined
where @packaging_material = packaging_material 
and packaging_activity = 'Sold as empty'
and packaging_type like  '%Household drinks containers'

--reusable packclass
if @BreakdownType = 'all_pm_pa_reusable_sold'
select  OrganisationName,subsidiary_id, packaging_material field2, packaging_class field3
, file1_Quantity_kg_extrapolated,file2_Quantity_kg_extrapolated,
quantity_kg_diff ,file1_submission_date,file2_submission_date,Quantity_kg_extrapolated_diff
 from   #file_joined
where @packaging_material = packaging_material 
and @packaging_class = packaging_class
and packaging_activity = 'Sold as empty'
and packaging_type = 'Reusable packaging'

--total packaging
if @BreakdownType = 'all_pm_pa_tp_sold'
select  OrganisationName,subsidiary_id, packaging_material field2, packaging_class field3
, file1_Quantity_kg_extrapolated,file2_Quantity_kg_extrapolated,
quantity_kg_diff ,file1_submission_date,file2_submission_date,Quantity_kg_extrapolated_diff
 from   #file_joined
where @packaging_material = packaging_material 
and packaging_activity = 'Sold as empty'
and Total_Packaging = 'total packaging'

--hh
if @BreakdownType = 'all_pm_pa_total_hh_sold'
select  OrganisationName,subsidiary_id, packaging_material field2, packaging_class field3
, file1_Quantity_kg_extrapolated,file2_Quantity_kg_extrapolated,
quantity_kg_diff ,file1_submission_date,file2_submission_date,Quantity_kg_extrapolated_diff
 from   #file_joined
where @packaging_material = packaging_material 
and packaging_activity = 'Sold as empty'
and packaging_type = 'Total Household packaging'

--nhh
if @BreakdownType = 'all_pm_pa_total_nonhh_sold'
select  OrganisationName,subsidiary_id, packaging_material field2, packaging_class field3
, file1_Quantity_kg_extrapolated,file2_Quantity_kg_extrapolated,
quantity_kg_diff ,file1_submission_date,file2_submission_date,Quantity_kg_extrapolated_diff
 from   #file_joined
where @packaging_material = packaging_material 
and packaging_activity = 'Sold as empty'
and packaging_type = 'Total Non-Household packaging'
--reuse

if @BreakdownType = 'all_pm_pa_total_reusable_sold'
select  OrganisationName,subsidiary_id, packaging_material field2, packaging_class field3
, file1_Quantity_kg_extrapolated,file2_Quantity_kg_extrapolated,
quantity_kg_diff ,file1_submission_date,file2_submission_date,Quantity_kg_extrapolated_diff
 from   #file_joined
where @packaging_material = packaging_material 
and packaging_activity = 'Sold as empty'
and packaging_type = 'Reusable packaging'






---Hired or loaned




if @BreakdownType = 'all_pm_hh_pa_hired'
select  OrganisationName,subsidiary_id, packaging_material field2, packaging_class field3
, file1_Quantity_kg_extrapolated,file2_Quantity_kg_extrapolated,
quantity_kg_diff ,file1_submission_date,file2_submission_date,Quantity_kg_extrapolated_diff
 from   #file_joined
where @packaging_material = packaging_material 
and @packaging_class = packaging_class
and packaging_activity = 'Hired or loaned'
and packaging_type = 'Total Household packaging'

--pubic binned
if @BreakdownType = 'all_pm_pb_pa_Imported'
select  OrganisationName,subsidiary_id, packaging_material field2, packaging_class field3
, file1_Quantity_kg_extrapolated,file2_Quantity_kg_extrapolated,
quantity_kg_diff ,file1_submission_date,file2_submission_date,Quantity_kg_extrapolated_diff
 from   #file_joined
where @packaging_material = packaging_material 
and @packaging_class = packaging_class
and packaging_activity = 'Hired or loaned'
and packaging_type = 'Public Binned'

--non-household
if @BreakdownType = 'all_pm_tnh_pa_hired'
select  OrganisationName,subsidiary_id, packaging_material field2, packaging_class field3
, file1_Quantity_kg_extrapolated,file2_Quantity_kg_extrapolated,
quantity_kg_diff ,file1_submission_date,file2_submission_date,Quantity_kg_extrapolated_diff
 from   #file_joined
where @packaging_material = packaging_material 
and @packaging_class = packaging_class
and packaging_activity = 'Hired or loaned'
and packaging_type = 'Total Non-Household packaging'

--HH drinks
if @BreakdownType = 'all_pm_pa_HH_drinks_hired'
select  OrganisationName,subsidiary_id, packaging_material field2, '' field3
, file1_Quantity_kg_extrapolated,file2_Quantity_kg_extrapolated,
quantity_kg_diff ,file1_submission_date,file2_submission_date,Quantity_kg_extrapolated_diff
 from   #file_joined
where @packaging_material = packaging_material 
and packaging_activity = 'Hired or loaned'
and packaging_type = 'Household drinks containers'

--non HH drinks
if @BreakdownType = 'all_pm_pa_nHH_drinks_hired'
select  OrganisationName,subsidiary_id, packaging_material field2, '' field3
, file1_Quantity_kg_extrapolated,file2_Quantity_kg_extrapolated,
quantity_kg_diff ,file1_submission_date,file2_submission_date,Quantity_kg_extrapolated_diff
 from   #file_joined
where @packaging_material = packaging_material 
and packaging_activity = 'Hired or loaned'
and packaging_type = 'Non-household drinks containers'

--all drinks
if @BreakdownType = 'all_pm_pa_all_drinks_hired'
select  OrganisationName,subsidiary_id, packaging_material field2, '' field3
, file1_Quantity_kg_extrapolated,file2_Quantity_kg_extrapolated,
quantity_kg_diff ,file1_submission_date,file2_submission_date,Quantity_kg_extrapolated_diff
 from   #file_joined
where @packaging_material = packaging_material 
and packaging_activity = 'Hired or loaned'
and packaging_type like  '%Household drinks containers'

--reusable packclass
if @BreakdownType = 'all_pm_pa_reusable_hired'
select  OrganisationName,subsidiary_id, packaging_material field2, packaging_class field3
, file1_Quantity_kg_extrapolated,file2_Quantity_kg_extrapolated,
quantity_kg_diff ,file1_submission_date,file2_submission_date,Quantity_kg_extrapolated_diff
 from   #file_joined
where @packaging_material = packaging_material 
and @packaging_class = packaging_class
and packaging_activity = 'Hired or loaned'
and packaging_type = 'Reusable packaging'

--total packaging
if @BreakdownType = 'all_pm_pa_tp__hired'
select  OrganisationName,subsidiary_id, packaging_material field2, packaging_class field3
, file1_Quantity_kg_extrapolated,file2_Quantity_kg_extrapolated,
quantity_kg_diff ,file1_submission_date,file2_submission_date,Quantity_kg_extrapolated_diff
 from   #file_joined
where @packaging_material = packaging_material 
and packaging_activity = 'Hired or loaned'
and Total_Packaging = 'total packaging'

--hh
if @BreakdownType = 'all_pm_pa_total_hh_hired'
select  OrganisationName,subsidiary_id, packaging_material field2, packaging_class field3
, file1_Quantity_kg_extrapolated,file2_Quantity_kg_extrapolated,
quantity_kg_diff ,file1_submission_date,file2_submission_date,Quantity_kg_extrapolated_diff
 from   #file_joined
where @packaging_material = packaging_material 
and packaging_activity = 'Hired or loaned'
and packaging_type = 'Total Household packaging'

--nhh
if @BreakdownType = 'all_pm_pa_total_nonhh_hired'
select  OrganisationName,subsidiary_id, packaging_material field2, packaging_class field3
, file1_Quantity_kg_extrapolated,file2_Quantity_kg_extrapolated,
quantity_kg_diff ,file1_submission_date,file2_submission_date,Quantity_kg_extrapolated_diff
 from   #file_joined
where @packaging_material = packaging_material 
and packaging_activity = 'Hired or loaned'
and packaging_type = 'Total Non-Household packaging'
--reuse

if @BreakdownType = 'all_pm_pa_total_reusable_hired'
select  OrganisationName,subsidiary_id, packaging_material field2, packaging_class field3
, file1_Quantity_kg_extrapolated,file2_Quantity_kg_extrapolated,
quantity_kg_diff ,file1_submission_date,file2_submission_date,Quantity_kg_extrapolated_diff
 from   #file_joined
where @packaging_material = packaging_material 
and packaging_activity = 'Hired or loaned'
and packaging_type = 'Reusable packaging'



---ONLINE


if @BreakdownType = 'all_pm_online'
select  OrganisationName,subsidiary_id, packaging_material field2, packaging_class field3
, file1_Quantity_kg_extrapolated,file2_Quantity_kg_extrapolated,
quantity_kg_diff ,file1_submission_date,file2_submission_date,Quantity_kg_extrapolated_diff
 from   #file_joined
where @packaging_material = packaging_material 
and @packaging_class = packaging_class
and packaging_type = 'Total Household Packaging'
--and packaging_activity = 'Online Marketplace'

if @BreakdownType = 'all_pm_tnh_pa_online'
select  OrganisationName,subsidiary_id, packaging_material field2, packaging_class field3
, file1_Quantity_kg_extrapolated,file2_Quantity_kg_extrapolated,
quantity_kg_diff ,file1_submission_date,file2_submission_date,Quantity_kg_extrapolated_diff
 from   #file_joined
where @packaging_material = packaging_material 
and @packaging_class = packaging_class
and packaging_type = 'Total Non-Household packaging'
--and packaging_activity = 'Online Marketplace'

--public binned all
if @BreakdownType = 'all_public_binned'
select  OrganisationName,subsidiary_id, packaging_material field2, packaging_class field3
, file1_Quantity_kg_extrapolated,file2_Quantity_kg_extrapolated,
quantity_kg_diff ,file1_submission_date,file2_submission_date,Quantity_kg_extrapolated_diff
 from   #file_joined
where @packaging_material = packaging_material 
and @packaging_class = packaging_class
and packaging_type = 'Public Binned'

--online non
if @BreakdownType = 'all_pm_online_non'
select  OrganisationName,subsidiary_id, packaging_material field2, packaging_class field3
, file1_Quantity_kg_extrapolated,file2_Quantity_kg_extrapolated,
quantity_kg_diff ,file1_submission_date,file2_submission_date,Quantity_kg_extrapolated_diff
 from   #file_joined
where @packaging_material = packaging_material 
and @packaging_class = packaging_class
and packaging_type = 'Total non-Household Packaging'
--and packaging_activity = 'Online Marketplace'



END;