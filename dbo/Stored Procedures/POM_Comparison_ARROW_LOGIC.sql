CREATE PROC [dbo].[POM_Comparison_ARROW_LOGIC] @filename1 [nvarchar](4000),@filename2 [nvarchar](4000),@ProducerCS [nvarchar](100),@organisation_id [int],@compliance_scheme [nvarchar](200),@securityquery [nvarchar](200),@Upper_Threshold [int],@Lower_Threshold [int],@Threshold_Type [nvarchar](100) AS
BEGIN
    /*
declare @filename1 [nvarchar](4000),@filename2 [nvarchar](4000),@ProducerCS [nvarchar](100),
@organisation_id [int],@compliance_scheme [nvarchar](200),@securityquery [nvarchar](200),@Upper_Threshold [int],
@Lower_Threshold [int],@Threshold_Type [nvarchar](100) 

set @filename1 = '2d326694-b4d8-4c40-8d9a-c76104b3ae2a'
set @filename2 = '96c4f82b-2912-456d-a55f-b92103a98741'
set @organisation_id = NULL
set @compliance_scheme = 'Recycle Wales (NRW)'
set @securityquery = 'England;'
set @Upper_Threshold = 5
set @Lower_Threshold = 5
set @Threshold_Type = 'Value'
*/


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
    into #file_joined
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

 select *, case when packaging_type in ('Total Non-Household packaging','Total Household packaging','Public binned','Reusable packaging','Household drinks containers','Non-household drinks containers')
then 'Total Packaging' else null end Total_Packaging
        into
      #POM_COMP_arrow
        from #file_joined
    union all




        SELECT distinct
            ''orgname, ''subid,
            d.[packaging_material],
            f.[from_nation],
            ''[packaging_activity], ''[packaging_class], ''[packaging_sub_material], ''[to_nation],
            h.[relative_move],
            'Self-managed consumer waste'[packaging_type]
, '' file1kg, ''file2kg, ''file1q, ''file2q, ''file1kge, ''file2kge, ''quanitykgdiff, ''quantitykgediff, ''qu, ''wudiff, ''fname1, ''fname2, ''fsubd, ''f2subd, ''org_sub_type, ''org_name, ''orgsize, ''cs, ''rt, ''tp
        FROM
            (SELECT [packaging_material]
            FROM [dbo].[t_POM]
            GROUP BY [packaging_material]) d
CROSS JOIN
   (SELECT [from_nation]
            FROM [dbo].[t_POM]
            GROUP BY [from_nation])f
CROSS JOIN
    (SELECT [relative_move]
            FROM [dbo].[t_POM]
            GROUP BY [relative_move])h
    union all




        SELECT distinct
            ''orgname, ''subid,
            d.[packaging_material],
            f.[from_nation],
            ''[packaging_activity], ''[packaging_class], ''[packaging_sub_material], ''[to_nation],
            h.[relative_move],
            'Self-managed organisation waste'[packaging_type]
, '' file1kg, ''file2kg, ''file1q, ''file2q, ''file1kge, ''file2kge, ''quanitykgdiff, ''quantitykgediff, ''qu, ''wudiff, ''fname1, ''fname2, ''fsubd, ''f2subd, ''org_sub_type, ''org_name, ''orgsize, ''cs, ''rt, ''tp
        FROM
            (SELECT packaging_material
            FROM [dbo].[t_POM]
            GROUP BY [packaging_material]) d
CROSS JOIN
   (SELECT [from_nation]
            FROM [dbo].[t_POM]
            GROUP BY [from_nation])f
CROSS JOIN
    (SELECT [relative_move]
            FROM [dbo].[t_POM]
            GROUP BY [relative_move])h


    union all




        SELECT distinct
            ''orgname, ''subid,
            d.[packaging_material],
            ''[from_nation],
            ''[packaging_activity], f.[packaging_class], ''[packaging_sub_material], ''[to_nation],
            ''[relative_move],
            'Total Household packaging' [packaging_type]
, '' file1kg, ''file2kg, ''file1q, ''file2q, ''file1kge, ''file2kge, ''quanitykgdiff, ''quantitykgediff, ''qu, ''wudiff, ''fname1, ''fname2, ''fsubd, ''f2subd, ''org_sub_type, ''org_name, ''orgsize, ''cs, ''rt, ''tp
        FROM
            (SELECT [packaging_material]
            FROM [dbo].[t_POM]
            GROUP BY [packaging_material]) d
CROSS JOIN
   (SELECT [packaging_class]
            FROM [dbo].[t_POM]
            where packaging_class in('Primary packaging','Shipment Packaging','Online marketplace total','Public bin')
            GROUP BY [packaging_class])f

    union all




        SELECT distinct
            ''orgname, ''subid,
            d.[packaging_material],
            ''[from_nation],
            pa.[packaging_activity], f.[packaging_class], ''[packaging_sub_material], ''[to_nation],
            ''[relative_move],
            'Total Non-Household packaging' [packaging_type]
, '' file1kg, ''file2kg, ''file1q, ''file2q, ''file1kge, ''file2kge, ''quanitykgdiff, ''quantitykgediff, ''qu, ''wudiff, ''fname1, ''fname2, ''fsubd, ''f2subd, ''org_sub_type, ''org_name, ''orgsize, ''cs, ''rt, ''tp
        FROM
            (SELECT [packaging_material]
            FROM [dbo].[t_POM]
            GROUP BY [packaging_material]) d
CROSS JOIN
   (SELECT [packaging_class]
            FROM [dbo].[t_POM]
            where packaging_class in('Primary packaging','Shipment Packaging','Online marketplace total','secondary packaging','Tertiary packaging')
            GROUP BY [packaging_class])f
CROSS JOIN
   (SELECT [packaging_activity]
            FROM [dbo].[t_POM]
            --  where packaging_class in('Primary packaging','Shipment Packaging','Online marketplace total','secondary packaging','Tertiary packaging')
            GROUP BY [packaging_activity])pa
    union all




        SELECT distinct
            ''orgname, ''subid,
            d.[packaging_material],
            ''[from_nation],
            ''[packaging_activity], f.[packaging_class], ''[packaging_sub_material], ''[to_nation],
            ''[relative_move],
            'Household drinks containers' [packaging_type]
, '' file1kg, ''file2kg, ''file1q, ''file2q, ''file1kge, ''file2kge, ''quanitykgdiff, ''quantitykgediff, ''qu, ''wudiff, ''fname1, ''fname2, ''fsubd, ''f2subd, ''org_sub_type, ''org_name, ''orgsize, ''cs, ''rt, ''tp
        FROM
            (SELECT [packaging_material]
            FROM [dbo].[t_POM]
            GROUP BY [packaging_material]) d
CROSS JOIN
   (SELECT [packaging_class]
            FROM [dbo].[t_POM]
            GROUP BY [packaging_class])f

    union all




        SELECT distinct
            ''orgname, ''subid,
            d.[packaging_material],
            ''[from_nation],
            ''[packaging_activity], f.[packaging_class], ''[packaging_sub_material], ''[to_nation],
            ''[relative_move],
            'Non-Household drinks containers' [packaging_type]
, '' file1kg, ''file2kg, ''file1q, ''file2q, ''file1kge, ''file2kge, ''quanitykgdiff, ''quantitykgediff, ''qu, ''wudiff, ''fname1, ''fname2, ''fsubd, ''f2subd, ''org_sub_type, ''org_name, ''orgsize, ''cs, ''rt, ''tp
        FROM
            (SELECT [packaging_material]
            FROM [dbo].[t_POM]
            GROUP BY [packaging_material]) d
CROSS JOIN
   (SELECT [packaging_class]
            FROM [dbo].[t_POM]
            GROUP BY [packaging_class])f

    union all




        SELECT distinct
            ''orgname, ''subid,
            d.[packaging_material],
            ''[from_nation],
            ''[packaging_activity], f.[packaging_class], ''[packaging_sub_material], ''[to_nation],
            ''[relative_move],
            'reusable packaging' [packaging_type]
, '' file1kg, ''file2kg, ''file1q, ''file2q, ''file1kge, ''file2kge, ''quanitykgdiff, ''quantitykgediff, ''qu, ''wudiff, ''fname1, ''fname2, ''fsubd, ''f2subd, ''org_sub_type, ''org_name, ''orgsize, ''cs, ''rt, ''tp
        FROM
            (SELECT [packaging_material]
            FROM [dbo].[t_POM]
            GROUP BY [packaging_material]) d
CROSS JOIN
   (SELECT [packaging_class]
            FROM [dbo].[t_POM]
            where packaging_class in('Primary packaging','Non-primary reusable packaging')
            GROUP BY [packaging_class])f


    union all




        SELECT distinct
            --    a.packaging_activity,
            -- b.packaging_type,
            --c.[packaging_class]
            ''orgname, ''subid,
            d.[packaging_material],
            --e.[packaging_sub_material],
            ''[from_nation],
            --g.[to_nation],
            ''[packaging_activity], ''[packaging_class], ''[packaging_sub_material], ''[to_nation],
            ''[relative_move],
            '' [packaging_type]
, '' file1kg, ''file2kg, ''file1q, ''file2q, ''file1kge, ''file2kge, ''quanitykgdiff, ''quantitykgediff, ''qu, ''wudiff, ''fname1, ''fname2, ''fsubd, ''f2subd, ''org_sub_type, ''org_name, ''orgsize, ''cs, ''rt, 'Total Packaging'tp
        FROM
            (SELECT [packaging_material]
            FROM [dbo].[t_POM]
            GROUP BY [packaging_material]) d

    union all


        SELECT distinct
            ''orgname, ''subid,
            d.[packaging_material],
            ''[from_nation],
            pa.[packaging_activity], f.[packaging_class], ''[packaging_sub_material], ''[to_nation],
            ''[relative_move],
            'Total Household Packaging' [packaging_type]
, '' file1kg, ''file2kg, ''file1q, ''file2q, ''file1kge, ''file2kge, ''quanitykgdiff, ''quantitykgediff, ''qu, ''wudiff, ''fname1, ''fname2, ''fsubd, ''f2subd, ''org_sub_type, ''org_name, ''orgsize, ''cs, ''rt, ''tp
        FROM
            (SELECT [packaging_material]
            FROM [dbo].[t_POM]
            GROUP BY [packaging_material]) d
CROSS JOIN
   (SELECT [packaging_class]
            FROM [dbo].[t_POM]
            where packaging_class in('Primary packaging','Shipment packaging')
            GROUP BY [packaging_class])f
CROSS JOIN
   (SELECT [packaging_activity]
            FROM [dbo].[t_POM]
            GROUP BY [packaging_activity])pa


    union all





        SELECT distinct
            ''orgname, ''subid,
            d.[packaging_material],
            ''[from_nation],
            pa.[packaging_activity], f.[packaging_class], ''[packaging_sub_material], ''[to_nation],
            ''[relative_move],
            'Public Binned' [packaging_type]
, '' file1kg, ''file2kg, ''file1q, ''file2q, ''file1kge, ''file2kge, ''quanitykgdiff, ''quantitykgediff, ''qu, ''wudiff, ''fname1, ''fname2, ''fsubd, ''f2subd, ''org_sub_type, ''org_name, ''orgsize, ''cs, ''rt, ''tp
        FROM
            (SELECT [packaging_material]
            FROM [dbo].[t_POM]
            GROUP BY [packaging_material]) d
CROSS JOIN
   (SELECT [packaging_class]
            FROM [dbo].[t_POM]
            where packaging_class in('Public bin')
            GROUP BY [packaging_class])f
   CROSS JOIN
   (SELECT [packaging_activity]
            FROM [dbo].[t_POM]
            GROUP BY [packaging_activity])pa
    union all
        SELECT distinct
            ''orgname, ''subid,
            d.[packaging_material],
            ''[from_nation],
            'Online Marketplace'[packaging_activity], f.[packaging_class], ''[packaging_sub_material], ''[to_nation],
            ''[relative_move],
            'Total Household Packaging' [packaging_type]
, '' file1kg, ''file2kg, ''file1q, ''file2q, ''file1kge, ''file2kge, ''quanitykgdiff, ''quantitykgediff, ''qu, ''wudiff, ''fname1, ''fname2, ''fsubd, ''f2subd, ''org_sub_type, ''org_name, ''orgsize, ''cs, ''rt, ''tp
        FROM
            (SELECT [packaging_material]
            FROM [dbo].[t_POM]
            GROUP BY [packaging_material]) d
CROSS JOIN
   (SELECT [packaging_class]
            FROM [dbo].[t_POM]
            where packaging_class ='Online Marketplace total'
            GROUP BY [packaging_class])f



    union all




        SELECT distinct
            ''orgname, ''subid,
            d.[packaging_material],
            ''[from_nation],
            pa.[packaging_activity], f.[packaging_class], ''[packaging_sub_material], ''[to_nation],
            ''[relative_move],
            'Total Non-Household Packaging' [packaging_type]
, '' file1kg, ''file2kg, ''file1q, ''file2q, ''file1kge, ''file2kge, ''quanitykgdiff, ''quantitykgediff, ''qu, ''wudiff, ''fname1, ''fname2, ''fsubd, ''f2subd, ''org_sub_type, ''org_name, ''orgsize, ''cs, ''rt, ''tp
        FROM
            (SELECT [packaging_material]
            FROM [dbo].[t_POM]
            GROUP BY [packaging_material]) d
CROSS JOIN
   (SELECT [packaging_class]
            FROM [dbo].[t_POM]
            where packaging_class in('Primary packaging','Shipment packaging','Secondary packaging')
            GROUP BY [packaging_class])f
 CROSS JOIN
   (SELECT [packaging_activity]
            FROM [dbo].[t_POM]
            GROUP BY [packaging_activity])pa

    union all
        SELECT distinct
            ''orgname, ''subid,
            d.[packaging_material],
            ''[from_nation],
            pa.[packaging_activity], ''[packaging_class], ''[packaging_sub_material], ''[to_nation],
            ''[relative_move],
            'Household drinks containers' [packaging_type]
, '' file1kg, ''file2kg, ''file1q, ''file2q, ''file1kge, ''file2kge, ''quanitykgdiff, ''quantitykgediff, ''qu, ''wudiff, ''fname1, ''fname2, ''fsubd, ''f2subd, ''org_sub_type, ''org_name, ''orgsize, ''cs, ''rt, ''tp
        FROM
            (SELECT [packaging_material]
            FROM [dbo].[t_POM]
            GROUP BY [packaging_material]) d
	CROSS JOIN
   (SELECT [packaging_activity]
            FROM [dbo].[t_POM]
            GROUP BY [packaging_activity])pa
    union all
        SELECT distinct
            ''orgname, ''subid,
            d.[packaging_material],
            ''[from_nation],
            pa.[packaging_activity], ''[packaging_class], ''[packaging_sub_material], ''[to_nation],
            ''[relative_move],
            'Non-Household drinks containers' [packaging_type]
, '' file1kg, ''file2kg, ''file1q, ''file2q, ''file1kge, ''file2kge, ''quanitykgdiff, ''quantitykgediff, ''qu, ''wudiff, ''fname1, ''fname2, ''fsubd, ''f2subd, ''org_sub_type, ''org_name, ''orgsize, ''cs, ''rt, ''tp
        FROM
            (SELECT [packaging_material]
            FROM [dbo].[t_POM]
            GROUP BY [packaging_material]) d
   CROSS JOIN
   (SELECT [packaging_activity]
            FROM [dbo].[t_POM]
            GROUP BY [packaging_activity])pa

    union all


        SELECT distinct
            ''orgname, ''subid,
            d.[packaging_material],
            ''[from_nation],
            pa.[packaging_activity], f.[packaging_class], ''[packaging_sub_material], ''[to_nation],
            ''[relative_move],
            'reusable packaging' [packaging_type]
, '' file1kg, ''file2kg, ''file1q, ''file2q, ''file1kge, ''file2kge, ''quanitykgdiff, ''quantitykgediff, ''qu, ''wudiff, ''fname1, ''fname2, ''fsubd, ''f2subd, ''org_sub_type, ''org_name, ''orgsize, ''cs, ''rt, ''tp
        FROM
            (SELECT [packaging_material]
            FROM [dbo].[t_POM]
            GROUP BY [packaging_material]) d
CROSS JOIN
   (SELECT [packaging_class]
            FROM [dbo].[t_POM]
            where packaging_class in('Primary packaging','Non-primary reusable packaging')
            GROUP BY [packaging_class])f
   CROSS JOIN
   (SELECT [packaging_activity]
            FROM [dbo].[t_POM]
            GROUP BY [packaging_activity])pa
    union all

        SELECT distinct
            ''orgname, ''subid,
            d.[packaging_material],
            ''[from_nation],
            pa.[packaging_activity], ''[packaging_class], ''[packaging_sub_material], ''[to_nation],
            ''[relative_move],
            '' [packaging_type]
, '' file1kg, ''file2kg, ''file1q, ''file2q, ''file1kge, ''file2kge, ''quanitykgdiff, ''quantitykgediff, ''qu, ''wudiff, ''fname1, ''fname2, ''fsubd, ''f2subd, ''org_sub_type, ''org_name, ''orgsize, ''cs, ''rt, 'Total Packaging'tp
        FROM
            (SELECT [packaging_material]
            FROM [dbo].[t_POM]
            GROUP BY [packaging_material]) d
	CROSS JOIN
   (SELECT [packaging_activity]
            FROM [dbo].[t_POM]
            GROUP BY [packaging_activity])pa




    ---ARROW LOGIC

    --self management consumer waste
    --packaging material from nation

    --file 1 is null
 /*               SELECT organisationName, subsidiary_id, packaging_material, from_nation,
            NULL AS quantity_kg_extrapolated_diff,
            CAST('' AS VARCHAR(2)) AS UP_DOWN, 'file1' filecheck, sum(file1_Quantity_kg_extrapolated) file1_Quantity_kg_extrapolated, sum(file2_Quantity_kg_extrapolated) file2_Quantity_kg_extrapolated
        INTO #self_management_consumer_waste_packaging_material_from_nation_1
        FROM #POM_COMP_arrow
        WHERE file1_Quantity_kg_extrapolated IS NULL
            and packaging_type = 'Self-managed consumer waste'
            and isnull(from_nation,'')<>''
            and isnull(to_nation,'') =''
        GROUP BY organisationName, subsidiary_id,packaging_material, from_nation

    union all
        --file2 is null 
        SELECT organisationName, subsidiary_id, packaging_material, from_nation,
            NULL, CAST('' AS VARCHAR(2)), 'file2', sum(file1_Quantity_kg_extrapolated) file1_Quantity_kg_extrapolated, sum(file2_Quantity_kg_extrapolated) file2_Quantity_kg_extrapolated
        FROM #POM_COMP_arrow
        WHERE file2_Quantity_kg_extrapolated IS NULL
            and packaging_type = 'Self-managed consumer waste'
            and isnull(from_nation,'')<>''
            and isnull(to_nation,'') =''
        GROUP BY organisationName, subsidiary_id,packaging_material, from_nation

    union all
*/
        --both file1 and 2 have data
          SELECT organisationName, subsidiary_id, packaging_material, from_nation,
            --   SUM(quantity_kg_extrapolated_diff),

            case  when @Threshold_Type = 'Percentage' and isnull(sum(isnull(file1_Quantity_kg_extrapolated,0)),0) = 0 then 0
when @Threshold_Type = 'Percentage' and isnull(sum(isnull(file2_Quantity_kg_extrapolated,0)),0) = 0 then 0
when @Threshold_Type = 'Percentage' and sum
(isnull(file1_Quantity_kg_extrapolated,0)) < sum
(isnull(file2_Quantity_kg_extrapolated,0)) 
                then
((sum
(isnull(file2_Quantity_kg_extrapolated,0))-sum
(isnull(file1_Quantity_kg_extrapolated,0)))/sum
(isnull(file1_Quantity_kg_extrapolated,0))*100)
                when @Threshold_Type = 'Percentage' and sum
(isnull(file1_Quantity_kg_extrapolated,0)) > sum
(isnull(file2_Quantity_kg_extrapolated,0)) 
              then
((sum
(isnull(file1_Quantity_kg_extrapolated,0))-sum
(isnull(file2_Quantity_kg_extrapolated,0)))/sum
(isnull(file1_Quantity_kg_extrapolated,0))*-100) 
              when @Threshold_Type = 'Value'
              then  SUM
(isnull(quantity_kg_extrapolated_diff,0))
end quantity_kg_extrapolated_diff,
            CAST('' AS VARCHAR(2)) AS UP_DOWN, 'both' filecheck, sum(file1_Quantity_kg_extrapolated) file1_Quantity_kg_extrapolated, sum(file2_Quantity_kg_extrapolated) file2_Quantity_kg_extrapolated
        --    , packaging_activity
              INTO #self_management_consumer_waste_packaging_material_from_nation_1
        FROM #POM_COMP_arrow
        WHERE-- file1_Quantity_kg_extrapolated IS NOT NULL
           -- AND file2_Quantity_kg_extrapolated IS NOT NULL
             packaging_type = 'Self-managed consumer waste'
            and isnull(from_nation,'')<>''
             and isnull(to_nation,'') =''
        GROUP BY organisationName, subsidiary_id,packaging_material, from_nation



    ---add arrow
    update a
set a.up_down = 'u'
from #self_management_consumer_waste_packaging_material_from_nation_1 a
where quantity_kg_extrapolated_diff >= @upper_threshold

    update a
set a.up_down = 'd'
from #self_management_consumer_waste_packaging_material_from_nation_1 a
where quantity_kg_extrapolated_diff <= (@lower_threshold*-1)



    --set ud when both
    update main
set main.UP_DOWN ='ud'
FROM #self_management_consumer_waste_packaging_material_from_nation_1 main
        JOIN (
    SELECT a.packaging_material, a.from_nation
        FROM #self_management_consumer_waste_packaging_material_from_nation_1 a
        WHERE up_down = 'u'
        GROUP BY a.packaging_material, a.from_nation
) AS a
        INNER JOIN (
    SELECT b.packaging_material, b.from_nation
        FROM #self_management_consumer_waste_packaging_material_from_nation_1 b
        WHERE up_down = 'd'
        GROUP BY b.packaging_material, b.from_nation
) AS b
        ON a.from_nation = b.from_nation AND a.packaging_material = b.packaging_material
        ON main.from_nation = a.from_nation AND main.packaging_material = a.packaging_material;

    ---table used for final report
            select packaging_material, from_nation, quantity_kg_extrapolated_diff, file1_quantity_kg_extrapolated, file2_quantity_kg_extrapolated, UP_DOWN
        into #self_management_consumer_waste_packaging_material_from_nation_2
        from #self_management_consumer_waste_packaging_material_from_nation_1
    union all
        SELECT packaging_material, from_nation, '', '', '', ''
        FROM #POM_COMP_arrow
        where isnull(from_nation,'') <> ''
        and isnull(packaging_material,'')<> ''
        group by packaging_material,from_nation


    --relative move

    --self management consumer waste
    --packaging material relative_move

    --file 1 is null
    /*            SELECT organisationName, subsidiary_id, packaging_material, relative_move,
            NULL AS quantity_kg_extrapolated_diff,
            CAST('' AS VARCHAR(2)) AS UP_DOWN, 'file1' filecheck, sum(file1_Quantity_kg_extrapolated) file1_Quantity_kg_extrapolated, sum(file2_Quantity_kg_extrapolated) file2_Quantity_kg_extrapolated
        INTO #self_management_consumer_waste_packaging_material_relative_move_1
        FROM #POM_COMP_arrow
        WHERE file1_Quantity_kg_extrapolated IS NULL
            and packaging_type = 'Self-managed consumer waste'
            and isnull(relative_move,'') <>''
            and isnull(packaging_material,'')<>''
        GROUP BY organisationName, subsidiary_id,packaging_material, relative_move

    union all
        --file2 is null 
        SELECT organisationName, subsidiary_id, packaging_material, relative_move,
            NULL, CAST('' AS VARCHAR(2)), 'file2', sum(file1_Quantity_kg_extrapolated) file1_Quantity_kg_extrapolated, sum(file2_Quantity_kg_extrapolated) file2_Quantity_kg_extrapolated
        FROM #POM_COMP_arrow
        WHERE file2_Quantity_kg_extrapolated IS NULL
            and packaging_type = 'Self-managed consumer waste'
             and isnull(relative_move,'') <>''
             and isnull(packaging_material,'')<>''
        GROUP BY organisationName, subsidiary_id,packaging_material, relative_move

    union all
*/
        --both file1 and 2 have data
              SELECT organisationName, subsidiary_id, packaging_material, relative_move,
            --   SUM(quantity_kg_extrapolated_diff),

            case  when @Threshold_Type = 'Percentage' and isnull(sum(isnull(file1_Quantity_kg_extrapolated,0)),0) = 0 then 0
when @Threshold_Type = 'Percentage' and isnull(sum(isnull(file2_Quantity_kg_extrapolated,0)),0) = 0 then 0
when @Threshold_Type = 'Percentage' and sum
(isnull(file1_Quantity_kg_extrapolated,0)) < sum
(isnull(file2_Quantity_kg_extrapolated,0)) 
                then
((sum
(isnull(file2_Quantity_kg_extrapolated,0))-sum
(isnull(file1_Quantity_kg_extrapolated,0)))/sum
(isnull(file1_Quantity_kg_extrapolated,0))*100)
                when @Threshold_Type = 'Percentage' and sum
(isnull(file1_Quantity_kg_extrapolated,0)) > sum
(isnull(file2_Quantity_kg_extrapolated,0)) 
              then
((sum
(isnull(file1_Quantity_kg_extrapolated,0))-sum
(isnull(file2_Quantity_kg_extrapolated,0)))/sum
(isnull(file1_Quantity_kg_extrapolated,0))*-100) 
              when @Threshold_Type = 'Value'
              then  SUM
(isnull(quantity_kg_extrapolated_diff,0))
end quantity_kg_extrapolated_diff,
            CAST('' AS VARCHAR(2)) AS UP_DOWN, 'both' filecheck, sum(file1_Quantity_kg_extrapolated) file1_Quantity_kg_extrapolated, sum(file2_Quantity_kg_extrapolated) file2_Quantity_kg_extrapolated
            INTO #self_management_consumer_waste_packaging_material_relative_move_1
        FROM #POM_COMP_arrow
        WHERE --file1_Quantity_kg_extrapolated IS NOT NULL
           -- AND file2_Quantity_kg_extrapolated IS NOT NULL
             packaging_type = 'Self-managed consumer waste'
        and isnull(relative_move,'') <>''
            and isnull(packaging_material,'')<>''
        GROUP BY organisationName, subsidiary_id,packaging_material, relative_move




    ---add arrow
    update a
set a.up_down = 'u'
from #self_management_consumer_waste_packaging_material_relative_move_1 a
where quantity_kg_extrapolated_diff >= @upper_threshold

    update a
set a.up_down = 'd'
from #self_management_consumer_waste_packaging_material_relative_move_1 a
where quantity_kg_extrapolated_diff <= (@lower_threshold*-1)


    --set ud when both
    update main
set main.UP_DOWN ='ud'
FROM #self_management_consumer_waste_packaging_material_relative_move_1 main
        JOIN (
    SELECT a.packaging_material, a.relative_move
        FROM #self_management_consumer_waste_packaging_material_relative_move_1 a
        WHERE up_down = 'u'
        GROUP BY a.packaging_material, a.relative_move
) AS a
        INNER JOIN (
    SELECT b.packaging_material, b.relative_move
        FROM #self_management_consumer_waste_packaging_material_relative_move_1 b
        WHERE up_down = 'd'
        GROUP BY b.packaging_material, b.relative_move
) AS b
        ON a.relative_move = b.relative_move AND a.packaging_material = b.packaging_material
        ON main.relative_move = a.relative_move AND main.packaging_material = a.packaging_material;

            select packaging_material, relative_move, quantity_kg_extrapolated_diff, file1_quantity_kg_extrapolated, file2_quantity_kg_extrapolated, UP_DOWN
        into #self_management_consumer_waste_packaging_material_relative_move_2
        from #self_management_consumer_waste_packaging_material_relative_move_1
    union all
        SELECT packaging_material, relative_move, '', '', '', ''
        FROM #POM_COMP_arrow
        where isnull(relative_move,'') <> ''
         and isnull(packaging_material,'') <> ''
        group by packaging_material,relative_move




    --self management organisation waste
    --packaging material from nation

    --file 1 is null
      /*          SELECT organisationName, subsidiary_id, packaging_material, from_nation,
            NULL AS quantity_kg_extrapolated_diff,
            CAST('' AS VARCHAR(2)) AS UP_DOWN, 'file1' filecheck, sum(file1_Quantity_kg_extrapolated) file1_Quantity_kg_extrapolated, sum(file2_Quantity_kg_extrapolated) file2_Quantity_kg_extrapolated
        INTO #self_management_organisation_waste_packaging_material_from_nation_1
        FROM #POM_COMP_arrow
        WHERE file1_Quantity_kg_extrapolated IS NULL
            and packaging_type = 'Self-managed organisation waste'
            and isnull(from_nation,'')<>''
            and isnull(to_nation,'')=''
        and isnull(packaging_material,'')<>''
        GROUP BY organisationName, subsidiary_id,packaging_material, from_nation

    union all
        --file2 is null 
        SELECT organisationName, subsidiary_id, packaging_material, from_nation,
            NULL, CAST('' AS VARCHAR(2)), 'file2', sum(file1_Quantity_kg_extrapolated) file1_Quantity_kg_extrapolated, sum(file2_Quantity_kg_extrapolated) file2_Quantity_kg_extrapolated
        FROM #POM_COMP_arrow
        WHERE file2_Quantity_kg_extrapolated IS NULL
            and packaging_type = 'Self-managed organisation waste'
            and isnull(from_nation,'')<>''
               and isnull(to_nation,'')=''
               and isnull(packaging_material,'')<>''
        GROUP BY organisationName, subsidiary_id,packaging_material, from_nation

    union all
*/
        --both file1 and 2 have data
          SELECT organisationName, subsidiary_id, packaging_material, from_nation,
            --   SUM(quantity_kg_extrapolated_diff),

            case  when @Threshold_Type = 'Percentage' and isnull(sum(isnull(file1_Quantity_kg_extrapolated,0)),0) = 0 then 0
when @Threshold_Type = 'Percentage' and isnull(sum(isnull(file2_Quantity_kg_extrapolated,0)),0) = 0 then 0
when @Threshold_Type = 'Percentage' and sum
(isnull(file1_Quantity_kg_extrapolated,0)) < sum
(isnull(file2_Quantity_kg_extrapolated,0)) 
                then
((sum
(isnull(file2_Quantity_kg_extrapolated,0))-sum
(isnull(file1_Quantity_kg_extrapolated,0)))/sum
(isnull(file1_Quantity_kg_extrapolated,0))*100)
                when @Threshold_Type = 'Percentage' and sum
(isnull(file1_Quantity_kg_extrapolated,0)) > sum
(isnull(file2_Quantity_kg_extrapolated,0)) 
              then
((sum
(isnull(file1_Quantity_kg_extrapolated,0))-sum
(isnull(file2_Quantity_kg_extrapolated,0)))/sum
(isnull(file1_Quantity_kg_extrapolated,0))*-100) 
              when @Threshold_Type = 'Value'
              then  SUM
(isnull(quantity_kg_extrapolated_diff,0))
end quantity_kg_extrapolated_diff,
            CAST('' AS VARCHAR(2)) AS UP_DOWN, 'both' filecheck, sum(file1_Quantity_kg_extrapolated) file1_Quantity_kg_extrapolated, sum(file2_Quantity_kg_extrapolated) file2_Quantity_kg_extrapolated
            INTO #self_management_organisation_waste_packaging_material_from_nation_1
        FROM #POM_COMP_arrow
        WHERE --file1_Quantity_kg_extrapolated IS NOT NULL
            -- file2_Quantity_kg_extrapolated IS NOT NULL
             packaging_type = 'Self-managed organisation waste'
            and isnull(from_nation,'')<>''
           and isnull(to_nation,'')=''
           and isnull(packaging_material,'')<>''
        GROUP BY organisationName, subsidiary_id,packaging_material, from_nation



    ---add arrow
    update a
set a.up_down = 'u'
from #self_management_organisation_waste_packaging_material_from_nation_1 a
where quantity_kg_extrapolated_diff >= @upper_threshold

    update a
set a.up_down = 'd'
from #self_management_organisation_waste_packaging_material_from_nation_1 a
where quantity_kg_extrapolated_diff <= (@lower_threshold*-1)



    --set ud when both
    update main
set main.UP_DOWN ='ud'
FROM #self_management_organisation_waste_packaging_material_from_nation_1 main
        JOIN (
    SELECT a.packaging_material, a.from_nation
        FROM #self_management_organisation_waste_packaging_material_from_nation_1 a
        WHERE up_down = 'u'
        GROUP BY a.packaging_material, a.from_nation
) AS a
        INNER JOIN (
    SELECT b.packaging_material, b.from_nation
        FROM #self_management_organisation_waste_packaging_material_from_nation_1 b
        WHERE up_down = 'd'
        GROUP BY b.packaging_material, b.from_nation
) AS b
        ON a.from_nation = b.from_nation AND a.packaging_material = b.packaging_material
        ON main.from_nation = a.from_nation AND main.packaging_material = a.packaging_material;

    ---table used for final report
            select packaging_material, from_nation, quantity_kg_extrapolated_diff, file1_quantity_kg_extrapolated, file2_quantity_kg_extrapolated, UP_DOWN
        into #self_management_organisation_waste_packaging_material_from_nation_2
        from #self_management_organisation_waste_packaging_material_from_nation_1
    union all
        SELECT packaging_material, from_nation, '', '', '', ''
        FROM #POM_COMP_arrow
        where isnull(from_nation,'') <> ''
           and isnull(packaging_material,'') <> ''
        group by packaging_material,from_nation

    --self management organisation waste
    --packaging material relative_move

    --file 1 is null
 /*               SELECT organisationName, subsidiary_id, packaging_material, relative_move,
            NULL AS quantity_kg_extrapolated_diff,
            CAST('' AS VARCHAR(2)) AS UP_DOWN, 'file1' filecheck, sum(file1_Quantity_kg_extrapolated) file1_Quantity_kg_extrapolated, sum(file2_Quantity_kg_extrapolated) file2_Quantity_kg_extrapolated
        INTO #self_management_organisation_waste_packaging_material_relative_move_1
        FROM #POM_COMP_arrow
        WHERE file1_Quantity_kg_extrapolated IS NULL
            and packaging_type = 'Self-managed organisation waste'
            and isnull(to_nation,'') ='' 
            and isnull(packaging_material,'')<>''
        GROUP BY organisationName, subsidiary_id,packaging_material, relative_move

    union all
        --file2 is null 
        SELECT organisationName, subsidiary_id, packaging_material, relative_move,
            NULL, CAST('' AS VARCHAR(2)), 'file2', sum(file1_Quantity_kg_extrapolated) file1_Quantity_kg_extrapolated, sum(file2_Quantity_kg_extrapolated) file2_Quantity_kg_extrapolated
        FROM #POM_COMP_arrow
        WHERE file2_Quantity_kg_extrapolated IS NULL
            and packaging_type = 'Self-managed organisation waste'
          and isnull(to_nation,'') ='' 
          and isnull(packaging_material,'')<>''
        GROUP BY organisationName, subsidiary_id,packaging_material, relative_move

    union all
*/
        --both file1 and 2 have data
            SELECT organisationName, subsidiary_id, packaging_material, relative_move,
            --   SUM(quantity_kg_extrapolated_diff),

            case  when @Threshold_Type = 'Percentage' and isnull(sum(isnull(file1_Quantity_kg_extrapolated,0)),0) = 0 then 0
when @Threshold_Type = 'Percentage' and isnull(sum(isnull(file2_Quantity_kg_extrapolated,0)),0) = 0 then 0
when @Threshold_Type = 'Percentage' and sum
(isnull(file1_Quantity_kg_extrapolated,0)) < sum
(isnull(file2_Quantity_kg_extrapolated,0)) 
                then
((sum
(isnull(file2_Quantity_kg_extrapolated,0))-sum
(isnull(file1_Quantity_kg_extrapolated,0)))/sum
(isnull(file1_Quantity_kg_extrapolated,0))*100)
                when @Threshold_Type = 'Percentage' and sum
(isnull(file1_Quantity_kg_extrapolated,0)) > sum
(isnull(file2_Quantity_kg_extrapolated,0)) 
              then
((sum
(isnull(file1_Quantity_kg_extrapolated,0))-sum
(isnull(file2_Quantity_kg_extrapolated,0)))/sum
(isnull(file1_Quantity_kg_extrapolated,0))*-100) 
              when @Threshold_Type = 'Value'
              then  SUM
(isnull(quantity_kg_extrapolated_diff,0))
end quantity_kg_extrapolated_diff,
            CAST('' AS VARCHAR(2)) AS UP_DOWN, 'both' filecheck, sum(file1_Quantity_kg_extrapolated) file1_Quantity_kg_extrapolated, sum(file2_Quantity_kg_extrapolated) file2_Quantity_kg_extrapolated
         INTO #self_management_organisation_waste_packaging_material_relative_move_1
        FROM #POM_COMP_arrow
        WHERE --file1_Quantity_kg_extrapolated IS NOT NULL
           -- AND file2_Quantity_kg_extrapolated IS NOT NULL
             packaging_type = 'Self-managed organisation waste'
       and isnull(to_nation,'') <>'' 
       and isnull(packaging_material,'')<>''
        GROUP BY organisationName, subsidiary_id,packaging_material, relative_move



    ---add arrow
    update a
set a.up_down = 'u'
from #self_management_organisation_waste_packaging_material_relative_move_1 a
where quantity_kg_extrapolated_diff >= @upper_threshold

    update a
set a.up_down = 'd'
from #self_management_organisation_waste_packaging_material_relative_move_1 a
where quantity_kg_extrapolated_diff <= (@lower_threshold*-1)



    --set ud when both
    update main
set main.UP_DOWN ='ud'
FROM #self_management_organisation_waste_packaging_material_relative_move_1 main
        JOIN (
    SELECT a.packaging_material, a.relative_move
        FROM #self_management_organisation_waste_packaging_material_relative_move_1 a
        WHERE up_down = 'u'
        GROUP BY a.packaging_material, a.relative_move
) AS a
        INNER JOIN (
    SELECT b.packaging_material, b.relative_move
        FROM #self_management_organisation_waste_packaging_material_relative_move_1 b
        WHERE up_down = 'd'
        GROUP BY b.packaging_material, b.relative_move
) AS b
        ON a.relative_move = b.relative_move AND a.packaging_material = b.packaging_material
        ON main.relative_move = a.relative_move AND main.packaging_material = a.packaging_material;

    ---table used for final report
            select packaging_material, relative_move, quantity_kg_extrapolated_diff, file1_quantity_kg_extrapolated, file2_quantity_kg_extrapolated, UP_DOWN
        into #self_management_organisation_waste_packaging_material_relative_move_2
        from #self_management_organisation_waste_packaging_material_relative_move_1
    union all
        SELECT packaging_material, relative_move, '', '', '', ''
        FROM #POM_COMP_arrow
        where isnull(relative_move,'') <> ''
        and isnull(packaging_material,'') <> ''
        group by packaging_material,relative_move






    ---ARROW LOGIC


    --packaging material Household Pacakaging, packaging_clas

    --file 1 is null
    /*            SELECT organisationName, subsidiary_id, packaging_material, packaging_class,
            NULL AS quantity_kg_extrapolated_diff,
            CAST('' AS VARCHAR(2)) AS UP_DOWN, 'file1' filecheck, sum(file1_Quantity_kg_extrapolated) file1_Quantity_kg_extrapolated, sum(file2_Quantity_kg_extrapolated) file2_Quantity_kg_extrapolated
        INTO #all_packaging_household_packaging_material_packaging_class_1
        FROM #POM_COMP_arrow
        WHERE file1_Quantity_kg_extrapolated IS NULL
            and packaging_type = 'Total Household packaging'
            and packaging_class in ('Primary packaging','Public bin','Shipment packaging')
            and isnull(packaging_material,'')<>''
        GROUP BY organisationName, subsidiary_id,packaging_material, packaging_class

    union all
        --file2 is null 
        SELECT organisationName, subsidiary_id, packaging_material, packaging_class,
            NULL, CAST('' AS VARCHAR(2)), 'file2', sum(file1_Quantity_kg_extrapolated) file1_Quantity_kg_extrapolated, sum(file2_Quantity_kg_extrapolated) file2_Quantity_kg_extrapolated
        FROM #POM_COMP_arrow
        WHERE file2_Quantity_kg_extrapolated IS NULL
            and packaging_type = 'Total Household packaging'
            and packaging_class in ('Primary packaging','Public bin','Shipment packaging')
            and isnull(packaging_material,'')<>''
        GROUP BY organisationName, subsidiary_id,packaging_material, packaging_class

    union all
*/
        --both file1 and 2 have data
            SELECT organisationName, subsidiary_id, packaging_material, packaging_class,
            --   SUM(quantity_kg_extrapolated_diff),

            case  when @Threshold_Type = 'Percentage' and isnull(sum(isnull(file1_Quantity_kg_extrapolated,0)),0) = 0 then 0
when @Threshold_Type = 'Percentage' and isnull(sum(isnull(file2_Quantity_kg_extrapolated,0)),0) = 0 then 0
when @Threshold_Type = 'Percentage' and sum
(isnull(file1_Quantity_kg_extrapolated,0)) < sum
(isnull(file2_Quantity_kg_extrapolated,0)) 
                then
((sum
(isnull(file2_Quantity_kg_extrapolated,0))-sum
(isnull(file1_Quantity_kg_extrapolated,0)))/sum
(isnull(file1_Quantity_kg_extrapolated,0))*100)
                when @Threshold_Type = 'Percentage' and sum
(isnull(file1_Quantity_kg_extrapolated,0)) > sum
(isnull(file2_Quantity_kg_extrapolated,0)) 
              then
((sum
(isnull(file1_Quantity_kg_extrapolated,0))-sum
(isnull(file2_Quantity_kg_extrapolated,0)))/sum
(isnull(file1_Quantity_kg_extrapolated,0))*-100) 
              when @Threshold_Type = 'Value'
              then  SUM
(isnull(quantity_kg_extrapolated_diff,0))
end quantity_kg_extrapolated_diff,
            CAST('' AS VARCHAR(2)) AS UP_DOWN, 'both' filecheck, sum(file1_Quantity_kg_extrapolated) file1_Quantity_kg_extrapolated, sum(file2_Quantity_kg_extrapolated) file2_Quantity_kg_extrapolated
                INTO #all_packaging_household_packaging_material_packaging_class_1
        FROM #POM_COMP_arrow
        WHERE-- file1_Quantity_kg_extrapolated IS NOT NULL
          --  AND file2_Quantity_kg_extrapolated IS NOT NULL
             packaging_type = 'Total Household packaging'
            and packaging_class in ('Primary packaging','Public bin','Shipment packaging')
            and isnull(packaging_material,'')<>''
        GROUP BY organisationName, subsidiary_id,packaging_material, packaging_class



    ---add arrow
    update a
set a.up_down = 'u'
from #all_packaging_household_packaging_material_packaging_class_1 a
where quantity_kg_extrapolated_diff >= @upper_threshold

    update a
set a.up_down = 'd'
from #all_packaging_household_packaging_material_packaging_class_1 a
where quantity_kg_extrapolated_diff <= (@lower_threshold*-1)
--drop table dbo.percent3


    --set ud when both
    update main
set main.UP_DOWN ='ud'
FROM #all_packaging_household_packaging_material_packaging_class_1 main
        JOIN (
    SELECT a.packaging_material, a.packaging_class
        FROM #all_packaging_household_packaging_material_packaging_class_1 a
        WHERE up_down = 'u'
        GROUP BY a.packaging_material, a.packaging_class
) AS a
        INNER JOIN (
    SELECT b.packaging_material, b.packaging_class
        FROM #all_packaging_household_packaging_material_packaging_class_1 b
        WHERE up_down = 'd'
        GROUP BY b.packaging_material, b.packaging_class
) AS b
        ON a.packaging_class = b.packaging_class AND a.packaging_material = b.packaging_material
        ON main.packaging_class = a.packaging_class AND main.packaging_material = a.packaging_material;


    ---table used for final report
            select packaging_material, packaging_class, quantity_kg_extrapolated_diff, file1_quantity_kg_extrapolated, file2_quantity_kg_extrapolated, UP_DOWN
        into #all_packaging_household_packaging_material_packaging_class_2
        from #all_packaging_household_packaging_material_packaging_class_1
    union all
        SELECT packaging_material, packaging_class, '', '', '', ''
        FROM #POM_COMP_arrow
        where  packaging_class in ('Primary packaging','Public bin','Shipment packaging')
         and   isnull(packaging_material,'') <> ''
        group by packaging_material,packaging_class




    --packaging material Non-Household Pacakaging, packaging_clas

    --file 1 is null
  /*              SELECT organisationName, subsidiary_id, packaging_material, packaging_class,
            NULL AS quantity_kg_extrapolated_diff,
            CAST('' AS VARCHAR(2)) AS UP_DOWN, 'file1' filecheck, sum(file1_Quantity_kg_extrapolated) file1_Quantity_kg_extrapolated, sum(file2_Quantity_kg_extrapolated) file2_Quantity_kg_extrapolated
        INTO #all_packaging_Non_household_packaging_material_packaging_class_1
        FROM #POM_COMP_arrow
        WHERE file1_Quantity_kg_extrapolated IS NULL
            and packaging_type = 'Total Non-Household packaging'
            and packaging_class in ('Online marketplace total','Primary packaging','Secondary packaging','Shipment packaging','Tertiary packaging')
            and isnull(packaging_material,'')<>''
        GROUP BY organisationName, subsidiary_id,packaging_material, packaging_class

    union all
        --file2 is null 
        SELECT organisationName, subsidiary_id, packaging_material, packaging_class,
            NULL, CAST('' AS VARCHAR(2)), 'file2', sum(file1_Quantity_kg_extrapolated) file1_Quantity_kg_extrapolated, sum(file2_Quantity_kg_extrapolated) file2_Quantity_kg_extrapolated
        FROM #POM_COMP_arrow
        WHERE file2_Quantity_kg_extrapolated IS NULL
            and packaging_type = 'Total Non-Household packaging'
            and packaging_class in ('Online marketplace total','Primary packaging','Secondary packaging','Shipment packaging','Tertiary packaging')
and isnull(packaging_material,'')<>''
        GROUP BY organisationName, subsidiary_id,packaging_material, packaging_class

    union all
*/
        --both file1 and 2 have data
             SELECT organisationName, subsidiary_id, packaging_material, packaging_class,
            --   SUM(quantity_kg_extrapolated_diff),

            case  when @Threshold_Type = 'Percentage' and isnull(sum(isnull(file1_Quantity_kg_extrapolated,0)),0) = 0 then 0
when @Threshold_Type = 'Percentage' and isnull(sum(isnull(file2_Quantity_kg_extrapolated,0)),0) = 0 then 0
when @Threshold_Type = 'Percentage' and sum
(isnull(file1_Quantity_kg_extrapolated,0)) < sum
(isnull(file2_Quantity_kg_extrapolated,0)) 
                then
((sum
(isnull(file2_Quantity_kg_extrapolated,0))-sum
(isnull(file1_Quantity_kg_extrapolated,0)))/sum
(isnull(file1_Quantity_kg_extrapolated,0))*100)
                when @Threshold_Type = 'Percentage' and sum
(isnull(file1_Quantity_kg_extrapolated,0)) > sum
(isnull(file2_Quantity_kg_extrapolated,0)) 
              then
((sum
(isnull(file1_Quantity_kg_extrapolated,0))-sum
(isnull(file2_Quantity_kg_extrapolated,0)))/sum
(isnull(file1_Quantity_kg_extrapolated,0))*-100) 
              when @Threshold_Type = 'Value'
              then  SUM
(isnull(quantity_kg_extrapolated_diff,0))
end quantity_kg_extrapolated_diff,
            CAST('' AS VARCHAR(2)) AS UP_DOWN, 'both' filecheck, sum(file1_Quantity_kg_extrapolated) file1_Quantity_kg_extrapolated, sum(file2_Quantity_kg_extrapolated) file2_Quantity_kg_extrapolated
       INTO #all_packaging_Non_household_packaging_material_packaging_class_1
        FROM #POM_COMP_arrow
        WHERE --file1_Quantity_kg_extrapolated IS NOT NULL
           -- AND file2_Quantity_kg_extrapolated IS NOT NULL
             packaging_type = 'Total Non-Household packaging'
            and packaging_class in ('Online marketplace total','Primary packaging','Secondary packaging','Shipment packaging','Tertiary packaging')
and isnull(packaging_material,'')<>''
        GROUP BY organisationName, subsidiary_id,packaging_material, packaging_class



    ---add arrow
    update a
set a.up_down = 'u'
from #all_packaging_Non_household_packaging_material_packaging_class_1 a
where quantity_kg_extrapolated_diff >= @upper_threshold

    update a
set a.up_down = 'd'
from #all_packaging_Non_household_packaging_material_packaging_class_1 a
where quantity_kg_extrapolated_diff <= (@lower_threshold*-1)



    --set ud when both
    update main
set main.UP_DOWN ='ud'
FROM #all_packaging_Non_household_packaging_material_packaging_class_1 main
        JOIN (
    SELECT a.packaging_material, a.packaging_class
        FROM #all_packaging_Non_household_packaging_material_packaging_class_1 a
        WHERE up_down = 'u'
        GROUP BY a.packaging_material, a.packaging_class
) AS a
        INNER JOIN (
    SELECT b.packaging_material, b.packaging_class
        FROM #all_packaging_Non_household_packaging_material_packaging_class_1 b
        WHERE up_down = 'd'
        GROUP BY b.packaging_material, b.packaging_class
) AS b
        ON a.packaging_class = b.packaging_class AND a.packaging_material = b.packaging_material
        ON main.packaging_class = a.packaging_class AND main.packaging_material = a.packaging_material;


    ---table used for final report
            select packaging_material, packaging_class, quantity_kg_extrapolated_diff, file1_quantity_kg_extrapolated, file2_quantity_kg_extrapolated, UP_DOWN
        into #all_packaging_Non_household_packaging_material_packaging_class_2
        from #all_packaging_Non_household_packaging_material_packaging_class_1
    union all
        SELECT packaging_material, packaging_class, '', '', '', ''
        FROM #POM_COMP_arrow
            where  packaging_class in ('Online marketplace total','Primary packaging','Secondary packaging','Shipment packaging','Tertiary packaging')
and isnull(packaging_material,'')<>''
        group by packaging_material,packaging_class






    --packaging material Household drinks

    --file 1 is null
   /*             SELECT organisationName, subsidiary_id, packaging_material,
            NULL AS quantity_kg_extrapolated_diff,
            CAST('' AS VARCHAR(2)) AS UP_DOWN, 'file1' filecheck, sum(file1_Quantity_kg_extrapolated) file1_Quantity_kg_extrapolated,
            sum(file2_Quantity_kg_extrapolated) file2_Quantity_kg_extrapolated,
            sum(file2_quantity_unit) file2_quantity_unit
        INTO #all_packaging_household_drinks_material_1
        FROM #POM_COMP_arrow
        WHERE file1_Quantity_kg_extrapolated IS NULL
            and packaging_type = 'Household drinks containers'
            and isnull(packaging_material,'')<>''
        GROUP BY organisationName, subsidiary_id,packaging_material

    union all
        --file2 is null 
        SELECT organisationName, subsidiary_id, packaging_material,
            NULL, CAST('' AS VARCHAR(2)), 'file2', sum(file1_Quantity_kg_extrapolated) file1_Quantity_kg_extrapolated, sum(file2_Quantity_kg_extrapolated) file2_Quantity_kg_extrapolated
                , sum(file2_quantity_unit) file2_quantity_unit
        FROM #POM_COMP_arrow
        WHERE file2_Quantity_kg_extrapolated IS NULL
            and packaging_type = 'Household drinks containers'
            and isnull(packaging_material,'')<>''
        GROUP BY organisationName, subsidiary_id,packaging_material

    union all
*/
        --both file1 and 2 have data
               SELECT organisationName, subsidiary_id, packaging_material,
            --   SUM(quantity_kg_extrapolated_diff),

            case  when @Threshold_Type = 'Percentage' and isnull(sum(isnull(file1_Quantity_kg_extrapolated,0)),0) = 0 then 0
when @Threshold_Type = 'Percentage' and isnull(sum(isnull(file2_Quantity_kg_extrapolated,0)),0) = 0 then 0
when @Threshold_Type = 'Percentage' and sum
(isnull(file1_Quantity_kg_extrapolated,0)) < sum
(isnull(file2_Quantity_kg_extrapolated,0)) 
                then
((sum
(isnull(file2_Quantity_kg_extrapolated,0))-sum
(isnull(file1_Quantity_kg_extrapolated,0)))/sum
(isnull(file1_Quantity_kg_extrapolated,0))*100)
                when @Threshold_Type = 'Percentage' and sum
(isnull(file1_Quantity_kg_extrapolated,0)) > sum
(isnull(file2_Quantity_kg_extrapolated,0)) 
              then
((sum
(isnull(file1_Quantity_kg_extrapolated,0))-sum
(isnull(file2_Quantity_kg_extrapolated,0)))/sum
(isnull(file1_Quantity_kg_extrapolated,0))*-100) 
              when @Threshold_Type = 'Value'
              then  SUM
(isnull(quantity_kg_extrapolated_diff,0))
end quantity_kg_extrapolated_diff,
            CAST('' AS VARCHAR(2)) AS UP_DOWN, 'both' filecheck, sum(file1_Quantity_kg_extrapolated) file1_Quantity_kg_extrapolated, sum(file2_Quantity_kg_extrapolated) file2_Quantity_kg_extrapolated
                , sum(file2_quantity_unit) file2_quantity_unit
     INTO #all_packaging_household_drinks_material_1
           
        FROM #POM_COMP_arrow
        WHERE --file1_Quantity_kg_extrapolated IS NOT NULL
           -- AND file2_Quantity_kg_extrapolated IS NOT NULL
             packaging_type = 'Household drinks containers'
            and isnull(packaging_material,'')<>''
        GROUP BY organisationName, subsidiary_id,packaging_material



    ---add arrow
    update a
set a.up_down = 'u'
from #all_packaging_household_drinks_material_1 a
where quantity_kg_extrapolated_diff >= @upper_threshold

    update a
set a.up_down = 'd'
from #all_packaging_household_drinks_material_1 a
where quantity_kg_extrapolated_diff <= (@lower_threshold*-1)



    --set ud when both
    update main
set main.UP_DOWN ='ud'
FROM #all_packaging_household_drinks_material_1 main
        JOIN (
    SELECT a.packaging_material
        FROM #all_packaging_household_drinks_material_1 a
        WHERE up_down = 'u'
        GROUP BY a.packaging_material
) AS a
        INNER JOIN (
    SELECT b.packaging_material
        FROM #all_packaging_household_drinks_material_1 b
        WHERE up_down = 'd'
        GROUP BY b.packaging_material
) AS b
        ON  a.packaging_material = b.packaging_material
        ON main.packaging_material = a.packaging_material;


    ---table used for final report
            select packaging_material, quantity_kg_extrapolated_diff, file1_quantity_kg_extrapolated, file2_quantity_kg_extrapolated, UP_DOWN , file2_quantity_unit
        into #all_packaging_household_drinks_material_2
        from #all_packaging_household_drinks_material_1
    union all
        SELECT packaging_material, '', '', '', '', ''
        FROM #POM_COMP_arrow
        where isnull(packaging_material,'')<>''
        group by packaging_material




    --packaging material non-Household drinks

    --file 1 is null
  /*              SELECT organisationName, subsidiary_id, packaging_material,
            NULL AS quantity_kg_extrapolated_diff,
            CAST('' AS VARCHAR(2)) AS UP_DOWN, 'file1' filecheck, sum(file1_Quantity_kg_extrapolated) file1_Quantity_kg_extrapolated,
            sum(file2_Quantity_kg_extrapolated) file2_Quantity_kg_extrapolated,
            sum(file2_quantity_unit) file2_quantity_unit
        INTO #all_packaging_non_household_drinks_material_1
        FROM #POM_COMP_arrow
        WHERE file1_Quantity_kg_extrapolated IS NULL
            and packaging_type = 'Non-household drinks containers'
            and isnull(packaging_material,'')<>''
        GROUP BY organisationName, subsidiary_id,packaging_material

    union all
        --file2 is null 
        SELECT organisationName, subsidiary_id, packaging_material,
            NULL, CAST('' AS VARCHAR(2)), 'file2', sum(file1_Quantity_kg_extrapolated) file1_Quantity_kg_extrapolated, sum(file2_Quantity_kg_extrapolated) file2_Quantity_kg_extrapolated
                , sum(file2_quantity_unit) file2_quantity_unit
        FROM #POM_COMP_arrow
        WHERE file2_Quantity_kg_extrapolated IS NULL
            and packaging_type = 'Non-household drinks containers'
            and isnull(packaging_material,'')<>''
        GROUP BY organisationName, subsidiary_id,packaging_material

    union all
*/
               SELECT organisationName, subsidiary_id, packaging_material,
            --   SUM(quantity_kg_extrapolated_diff),

            case  when @Threshold_Type = 'Percentage' and isnull(sum(isnull(file1_Quantity_kg_extrapolated,0)),0) = 0 then 0
when @Threshold_Type = 'Percentage' and isnull(sum(isnull(file2_Quantity_kg_extrapolated,0)),0) = 0 then 0
when @Threshold_Type = 'Percentage' and sum
(isnull(file1_Quantity_kg_extrapolated,0)) < sum
(isnull(file2_Quantity_kg_extrapolated,0)) 
                then
((sum
(isnull(file2_Quantity_kg_extrapolated,0))-sum
(isnull(file1_Quantity_kg_extrapolated,0)))/sum
(isnull(file1_Quantity_kg_extrapolated,0))*100)
                when @Threshold_Type = 'Percentage' and sum
(isnull(file1_Quantity_kg_extrapolated,0)) > sum
(isnull(file2_Quantity_kg_extrapolated,0)) 
              then
((sum
(isnull(file1_Quantity_kg_extrapolated,0))-sum
(isnull(file2_Quantity_kg_extrapolated,0)))/sum
(isnull(file1_Quantity_kg_extrapolated,0))*-100) 
              when @Threshold_Type = 'Value'
              then  SUM
(isnull(quantity_kg_extrapolated_diff,0))
end quantity_kg_extrapolated_diff,
            CAST('' AS VARCHAR(2)) AS UP_DOWN, 'both' filecheck, sum(file1_Quantity_kg_extrapolated) file1_Quantity_kg_extrapolated, sum(file2_Quantity_kg_extrapolated) file2_Quantity_kg_extrapolated
                , sum(file2_quantity_unit) file2_quantity_unit
    INTO #all_packaging_non_household_drinks_material_1
           
        FROM #POM_COMP_arrow
        WHERE --file1_Quantity_kg_extrapolated IS NOT NULL
            --AND file2_Quantity_kg_extrapolated IS NOT NULL
             packaging_type = 'Non-household drinks containers'
            and isnull(packaging_material,'')<>''
        GROUP BY organisationName, subsidiary_id,packaging_material



    ---add arrow
    update a
set a.up_down = 'u'
from #all_packaging_non_household_drinks_material_1 a
where quantity_kg_extrapolated_diff >= @upper_threshold

    update a
set a.up_down = 'd'
from #all_packaging_non_household_drinks_material_1 a
where quantity_kg_extrapolated_diff <= (@lower_threshold*-1)



    --set ud when both
    update main
set main.UP_DOWN ='ud'
FROM #all_packaging_non_household_drinks_material_1 main
        JOIN (
    SELECT a.packaging_material
        FROM #all_packaging_non_household_drinks_material_1 a
        WHERE up_down = 'u'
        GROUP BY a.packaging_material
) AS a
        INNER JOIN (
    SELECT b.packaging_material
        FROM #all_packaging_non_household_drinks_material_1 b
        WHERE up_down = 'd'
        GROUP BY b.packaging_material
) AS b
        ON  a.packaging_material = b.packaging_material
        ON  main.packaging_material = a.packaging_material;


    ---table used for final report
            select packaging_material, quantity_kg_extrapolated_diff, file1_quantity_kg_extrapolated, file2_quantity_kg_extrapolated, UP_DOWN , file2_quantity_unit
        into #all_packaging_non_household_drinks_material_2
        from #all_packaging_non_household_drinks_material_1
    union all
        SELECT packaging_material, '', '', '', '', ''
        FROM #POM_COMP_arrow
        where isnull(packaging_material,'')<>''
        group by packaging_material





    --all drinks

    --file 1 is null
 /*               SELECT organisationName, subsidiary_id, packaging_material,
            NULL AS quantity_kg_extrapolated_diff,
            CAST('' AS VARCHAR(2)) AS UP_DOWN, 'file1' filecheck, sum(file1_Quantity_kg_extrapolated) file1_Quantity_kg_extrapolated,
            sum(file2_Quantity_kg_extrapolated) file2_Quantity_kg_extrapolated
           , sum(file2_quantity_unit) file2_quantity_unit
        INTO #all_packaging_drinks_material_1
        FROM #POM_COMP_arrow
        WHERE file1_Quantity_kg_extrapolated IS NULL
            and (packaging_type = 'Non-household drinks containers' OR packaging_type = 'household drinks containers')
            and isnull(packaging_material,'')<>''
        GROUP BY organisationName, subsidiary_id,packaging_material

    union all
        --file2 is null 
        SELECT organisationName, subsidiary_id, packaging_material,
            NULL, CAST('' AS VARCHAR(2)), 'file2', sum(file1_Quantity_kg_extrapolated) file1_Quantity_kg_extrapolated, sum(file2_Quantity_kg_extrapolated) file2_Quantity_kg_extrapolated
                , sum(file2_quantity_unit) file2_quantity_unit
        FROM #POM_COMP_arrow
        WHERE file2_Quantity_kg_extrapolated IS NULL
            and (packaging_type = 'Non-household drinks containers' OR packaging_type = 'household drinks containers')
            and isnull(packaging_material,'')<>''
        GROUP BY organisationName, subsidiary_id,packaging_material

    union all
*/
        --both file1 and 2 have data
                SELECT organisationName, subsidiary_id, packaging_material,
            --   SUM(quantity_kg_extrapolated_diff),

            case  when @Threshold_Type = 'Percentage' and isnull(sum(isnull(file1_Quantity_kg_extrapolated,0)),0) = 0 then 0
when @Threshold_Type = 'Percentage' and isnull(sum(isnull(file2_Quantity_kg_extrapolated,0)),0) = 0 then 0
when @Threshold_Type = 'Percentage' and sum
(isnull(file1_Quantity_kg_extrapolated,0)) < sum
(isnull(file2_Quantity_kg_extrapolated,0)) 
                then
((sum
(isnull(file2_Quantity_kg_extrapolated,0))-sum
(isnull(file1_Quantity_kg_extrapolated,0)))/sum
(isnull(file1_Quantity_kg_extrapolated,0))*100)
                when @Threshold_Type = 'Percentage' and sum
(isnull(file1_Quantity_kg_extrapolated,0)) > sum
(isnull(file2_Quantity_kg_extrapolated,0)) 
              then
((sum
(isnull(file1_Quantity_kg_extrapolated,0))-sum
(isnull(file2_Quantity_kg_extrapolated,0)))/sum
(isnull(file1_Quantity_kg_extrapolated,0))*-100) 
              when @Threshold_Type = 'Value'
              then  SUM
(isnull(quantity_kg_extrapolated_diff,0))
end quantity_kg_extrapolated_diff,
            CAST('' AS VARCHAR(2)) AS UP_DOWN, 'both' filecheck, sum(file1_Quantity_kg_extrapolated) file1_Quantity_kg_extrapolated, sum(file2_Quantity_kg_extrapolated) file2_Quantity_kg_extrapolated
                , sum(file2_quantity_unit) file2_quantity_unit
                 INTO #all_packaging_drinks_material_1
        FROM #POM_COMP_arrow
        WHERE --file1_Quantity_kg_extrapolated IS NOT NULL
           -- AND file2_Quantity_kg_extrapolated IS NOT NULL
             (packaging_type = 'Non-household drinks containers' OR packaging_type = 'household drinks containers')
            and isnull(packaging_material,'')<>''
        GROUP BY organisationName, subsidiary_id,packaging_material



    ---add arrow
    update a
set a.up_down = 'u'
from #all_packaging_drinks_material_1 a
where quantity_kg_extrapolated_diff >= @upper_threshold

    update a
set a.up_down = 'd'
from #all_packaging_drinks_material_1 a
where quantity_kg_extrapolated_diff <= (@lower_threshold*-1)



    --set ud when both
    update main
set main.UP_DOWN ='ud'
FROM #all_packaging_drinks_material_1 main
        JOIN (
    SELECT a.packaging_material
        FROM #all_packaging_drinks_material_1 a
        WHERE up_down = 'u'
        GROUP BY a.packaging_material
) AS a
        INNER JOIN (
    SELECT b.packaging_material
        FROM #all_packaging_drinks_material_1 b
        WHERE up_down = 'd'
        GROUP BY b.packaging_material
) AS b
        ON  a.packaging_material = b.packaging_material
        ON  main.packaging_material = a.packaging_material;


    ---table used for final report
            select packaging_material, quantity_kg_extrapolated_diff, file1_quantity_kg_extrapolated, file2_quantity_kg_extrapolated, UP_DOWN , file2_quantity_unit
        into #all_packaging_drinks_material_2
        from #all_packaging_drinks_material_1
    union all
        SELECT packaging_material, '', '', '', '', ''
        FROM #POM_COMP_arrow
        where isnull(packaging_material,'')<>''
        group by packaging_material



    --all packaging reusable packaging

    --file 1 is null
  /*              SELECT organisationName, subsidiary_id, packaging_material, packaging_class,
            NULL AS quantity_kg_extrapolated_diff,
            cAST('' AS VARCHAR(2)) AS UP_DOWN, 'file1' filecheck, sum(file1_Quantity_kg_extrapolated) file1_Quantity_kg_extrapolated,
            sum(file2_Quantity_kg_extrapolated) file2_Quantity_kg_extrapolated
        -- sum(file2_quantity_unit) file2_quantity_unit
        INTO #all_packaging_material_reusable1
        FROM #POM_COMP_arrow
        WHERE file1_Quantity_kg_extrapolated IS NULL
            and (packaging_type = 'Reusable packaging' )
            and isnull(packaging_material,'')<>''
        GROUP BY organisationName, subsidiary_id,packaging_material,packaging_class

    union all
        --file2 is null 
        SELECT organisationName, subsidiary_id, packaging_material, packaging_class,
            NULL,
            CAST('' AS VARCHAR(2)), 'file2', sum(file1_Quantity_kg_extrapolated) file1_Quantity_kg_extrapolated, sum(file2_Quantity_kg_extrapolated) file2_Quantity_kg_extrapolated
        --,   sum(file2_quantity_unit) file2_quantity_unit
        FROM #POM_COMP_arrow
        WHERE file2_Quantity_kg_extrapolated IS NULL
            and (packaging_type = 'Reusable packaging' )
            and isnull(packaging_material,'')<>''
        GROUP BY organisationName, subsidiary_id,packaging_material,packaging_class

    union all
*/
        --both file1 and 2 have data
                     SELECT organisationName, subsidiary_id, packaging_material,packaging_class,
            --   SUM(quantity_kg_extrapolated_diff),

            case  when @Threshold_Type = 'Percentage' and isnull(sum(isnull(file1_Quantity_kg_extrapolated,0)),0) = 0 then 0
when @Threshold_Type = 'Percentage' and isnull(sum(isnull(file2_Quantity_kg_extrapolated,0)),0) = 0 then 0
when @Threshold_Type = 'Percentage' and sum
(isnull(file1_Quantity_kg_extrapolated,0)) < sum
(isnull(file2_Quantity_kg_extrapolated,0)) 
                then
((sum
(isnull(file2_Quantity_kg_extrapolated,0))-sum
(isnull(file1_Quantity_kg_extrapolated,0)))/sum
(isnull(file1_Quantity_kg_extrapolated,0))*100)
                when @Threshold_Type = 'Percentage' and sum
(isnull(file1_Quantity_kg_extrapolated,0)) > sum
(isnull(file2_Quantity_kg_extrapolated,0)) 
              then
((sum
(isnull(file1_Quantity_kg_extrapolated,0))-sum
(isnull(file2_Quantity_kg_extrapolated,0)))/sum
(isnull(file1_Quantity_kg_extrapolated,0))*-100) 
              when @Threshold_Type = 'Value'
              then  SUM
(isnull(quantity_kg_extrapolated_diff,0))
end quantity_kg_extrapolated_diff,
            CAST('' AS VARCHAR(2)) AS UP_DOWN, 'both' filecheck, sum(file1_Quantity_kg_extrapolated) file1_Quantity_kg_extrapolated, sum(file2_Quantity_kg_extrapolated) file2_Quantity_kg_extrapolated
       INTO #all_packaging_material_reusable1
        FROM #POM_COMP_arrow
        WHERE --file1_Quantity_kg_extrapolated IS NOT NULL
           -- AND file2_Quantity_kg_extrapolated IS NOT NULL
             (packaging_type = 'Reusable packaging' )
            and isnull(packaging_material,'')<>''
        GROUP BY organisationName, subsidiary_id,packaging_material,packaging_class



    ---add arrow
    update a
set a.up_down = 'u'
from #all_packaging_material_reusable1 a
where quantity_kg_extrapolated_diff >= @upper_threshold

    update a
set a.up_down = 'd'
from #all_packaging_material_reusable1 a
where quantity_kg_extrapolated_diff <= (@lower_threshold*-1)



    --set ud when both
    update main
set main.UP_DOWN ='ud'
FROM #all_packaging_material_reusable1 main
        JOIN (
    SELECT a.packaging_material, a.packaging_class
        FROM #all_packaging_material_reusable1 a
        WHERE up_down = 'u'
        GROUP BY a.packaging_material, a.packaging_class
) AS a
        INNER JOIN (
    SELECT b.packaging_material, b.packaging_class
        FROM #all_packaging_material_reusable1 b
        WHERE up_down = 'd'
        GROUP BY b.packaging_material,packaging_class
) AS b
        ON  a.packaging_material = b.packaging_material and a.packaging_class = b.packaging_class
        ON  main.packaging_material = a.packaging_material and main.packaging_class = a.packaging_class;


    ---table used for final report
            select packaging_material, packaging_class, file1_quantity_kg_extrapolated, file2_quantity_kg_extrapolated, UP_DOWN , ''file2_quantity_unit
        into #all_packaging_material_reusable2
        from #all_packaging_material_reusable1
    union all
        SELECT packaging_material, packaging_class, '', '', '', ''
        FROM #POM_COMP_arrow
        where packaging_class in('Primary packaging','Non-primary reusable packaging')
        and isnull(packaging_material,'')<>''
        group by packaging_material,packaging_class



    --all packaging total packaging

 /*   --file 1 is null
                SELECT organisationName, subsidiary_id, packaging_material,
            NULL AS quantity_kg_extrapolated_diff,
            cAST('' AS VARCHAR(2)) AS UP_DOWN, 'file1' filecheck, sum(file1_Quantity_kg_extrapolated) file1_Quantity_kg_extrapolated,
            sum(file2_Quantity_kg_extrapolated) file2_Quantity_kg_extrapolated
        -- sum(file2_quantity_unit) file2_quantity_unit
        INTO #all_packaging_material_TP1
        FROM #POM_COMP_arrow
        WHERE file1_Quantity_kg_extrapolated IS NULL
            and (Total_Packaging = 'Total packaging' )
            and isnull(packaging_material,'')<>''
        GROUP BY organisationName, subsidiary_id,packaging_material

    union all
        --file2 is null 
        SELECT organisationName, subsidiary_id, packaging_material,
            NULL,
            CAST('' AS VARCHAR(2)), 'file2', sum(file1_Quantity_kg_extrapolated) file1_Quantity_kg_extrapolated, sum(file2_Quantity_kg_extrapolated) file2_Quantity_kg_extrapolated
        --,   sum(file2_quantity_unit) file2_quantity_unit
        FROM #POM_COMP_arrow
        WHERE file2_Quantity_kg_extrapolated IS NULL
            and (Total_Packaging = 'Total packaging' )
            and isnull(packaging_material,'')<>''
        GROUP BY organisationName, subsidiary_id,packaging_material

    union all
*/
        --both file1 and 2 have data
                          SELECT organisationName, subsidiary_id, packaging_material,
            --   SUM(quantity_kg_extrapolated_diff),

            case  when @Threshold_Type = 'Percentage' and isnull(sum(isnull(file1_Quantity_kg_extrapolated,0)),0) = 0 then 0
when @Threshold_Type = 'Percentage' and isnull(sum(isnull(file2_Quantity_kg_extrapolated,0)),0) = 0 then 0
when @Threshold_Type = 'Percentage' and sum
(isnull(file1_Quantity_kg_extrapolated,0)) < sum
(isnull(file2_Quantity_kg_extrapolated,0)) 
                then
((sum
(isnull(file2_Quantity_kg_extrapolated,0))-sum
(isnull(file1_Quantity_kg_extrapolated,0)))/sum
(isnull(file1_Quantity_kg_extrapolated,0))*100)
                when @Threshold_Type = 'Percentage' and sum
(isnull(file1_Quantity_kg_extrapolated,0)) > sum
(isnull(file2_Quantity_kg_extrapolated,0)) 
              then
((sum
(isnull(file1_Quantity_kg_extrapolated,0))-sum
(isnull(file2_Quantity_kg_extrapolated,0)))/sum
(isnull(file1_Quantity_kg_extrapolated,0))*-100) 
              when @Threshold_Type = 'Value'
              then  SUM
(isnull(quantity_kg_extrapolated_diff,0))
end quantity_kg_extrapolated_diff,
            CAST('' AS VARCHAR(2)) AS UP_DOWN, 'both' filecheck, sum(file1_Quantity_kg_extrapolated) file1_Quantity_kg_extrapolated, sum(file2_Quantity_kg_extrapolated) file2_Quantity_kg_extrapolated
                INTO #all_packaging_material_TP1
        FROM #POM_COMP_arrow
        WHERE --file1_Quantity_kg_extrapolated IS NOT NULL
          --  AND file2_Quantity_kg_extrapolated IS NOT NULL
             (Total_Packaging = 'Total packaging' )
            and isnull(packaging_material,'')<>''
        GROUP BY organisationName, subsidiary_id,packaging_material



    ---add arrow
    update a
set a.up_down = 'u'
from #all_packaging_material_TP1 a
where quantity_kg_extrapolated_diff >= @upper_threshold

    update a
set a.up_down = 'd'
from #all_packaging_material_TP1 a
where quantity_kg_extrapolated_diff <= (@lower_threshold*-1)



    --set ud when both
    update main
set main.UP_DOWN ='ud'
FROM #all_packaging_material_TP1 main
        JOIN (
    SELECT a.packaging_material
        FROM #all_packaging_material_TP1 a
        WHERE up_down = 'u'
        GROUP BY a.packaging_material
) AS a
        INNER JOIN (
    SELECT b.packaging_material
        FROM #all_packaging_material_TP1 b
        WHERE up_down = 'd'
        GROUP BY b.packaging_material
) AS b
        ON  a.packaging_material = b.packaging_material
        ON  main.packaging_material = a.packaging_material;


    ---table used for final report
            select packaging_material, ''packaging_class, file1_quantity_kg_extrapolated, file2_quantity_kg_extrapolated, UP_DOWN , ''file2_quantity_unit
        into #all_packaging_material_TP2
        from #all_packaging_material_TP1
    union all
        SELECT packaging_material, '', '', '', '', ''
        FROM #POM_COMP_arrow
        where isnull(packaging_material,'')<>''
        group by packaging_material


    --------------------------------------------------------------
    --all packaging total household
    --------------------------------------------------------------
    --file 1 is null
    /*            SELECT organisationName, subsidiary_id, packaging_material,
            NULL AS quantity_kg_extrapolated_diff,
            cAST('' AS VARCHAR(2)) AS UP_DOWN, 'file1' filecheck, sum(file1_Quantity_kg_extrapolated) file1_Quantity_kg_extrapolated,
            sum(file2_Quantity_kg_extrapolated) file2_Quantity_kg_extrapolated
        -- sum(file2_quantity_unit) file2_quantity_unit
        INTO #all_packaging_material_Thh1
        FROM #POM_COMP_arrow
        WHERE file1_Quantity_kg_extrapolated IS NULL
            and (packaging_type = 'Total Household packaging' )
            and isnull(packaging_material,'')<>''
        GROUP BY organisationName, subsidiary_id,packaging_material

    union all
        --file2 is null 
        SELECT organisationName, subsidiary_id, packaging_material,
            NULL,
            CAST('' AS VARCHAR(2)), 'file2', sum(file1_Quantity_kg_extrapolated) file1_Quantity_kg_extrapolated, sum(file2_Quantity_kg_extrapolated) file2_Quantity_kg_extrapolated
        --,   sum(file2_quantity_unit) file2_quantity_unit
        FROM #POM_COMP_arrow
        WHERE file2_Quantity_kg_extrapolated IS NULL
            and (packaging_type = 'Total Household packaging' )
            and isnull(packaging_material,'')<>''
        GROUP BY organisationName, subsidiary_id,packaging_material

    union all
*/
        --both file1 and 2 have data
                          SELECT organisationName, subsidiary_id, packaging_material,
            --   SUM(quantity_kg_extrapolated_diff),

            case  when @Threshold_Type = 'Percentage' and isnull(sum(isnull(file1_Quantity_kg_extrapolated,0)),0) = 0 then 0
when @Threshold_Type = 'Percentage' and isnull(sum(isnull(file2_Quantity_kg_extrapolated,0)),0) = 0 then 0
when @Threshold_Type = 'Percentage' and sum
(isnull(file1_Quantity_kg_extrapolated,0)) < sum
(isnull(file2_Quantity_kg_extrapolated,0)) 
                then
((sum
(isnull(file2_Quantity_kg_extrapolated,0))-sum
(isnull(file1_Quantity_kg_extrapolated,0)))/sum
(isnull(file1_Quantity_kg_extrapolated,0))*100)
                when @Threshold_Type = 'Percentage' and sum
(isnull(file1_Quantity_kg_extrapolated,0)) > sum
(isnull(file2_Quantity_kg_extrapolated,0)) 
              then
((sum
(isnull(file1_Quantity_kg_extrapolated,0))-sum
(isnull(file2_Quantity_kg_extrapolated,0)))/sum
(isnull(file1_Quantity_kg_extrapolated,0))*-100) 
              when @Threshold_Type = 'Value'
              then  SUM
(isnull(quantity_kg_extrapolated_diff,0))
end quantity_kg_extrapolated_diff,
            CAST('' AS VARCHAR(2)) AS UP_DOWN, 'both' filecheck, sum(file1_Quantity_kg_extrapolated) file1_Quantity_kg_extrapolated, sum(file2_Quantity_kg_extrapolated) file2_Quantity_kg_extrapolated
               INTO #all_packaging_material_Thh1
        FROM #POM_COMP_arrow
        WHERE-- file1_Quantity_kg_extrapolated IS NOT NULL
           -- AND file2_Quantity_kg_extrapolated IS NOT NULL
             (packaging_type = 'Total Household packaging' )
            and isnull(packaging_material,'')<>''
        GROUP BY organisationName, subsidiary_id,packaging_material



    ---add arrow
    update a
set a.up_down = 'u'
from #all_packaging_material_Thh1 a
where quantity_kg_extrapolated_diff >= @upper_threshold

    update a
set a.up_down = 'd'
from #all_packaging_material_Thh1 a
where quantity_kg_extrapolated_diff <= (@lower_threshold*-1)



    --set ud when both
    update main
set main.UP_DOWN ='ud'
FROM #all_packaging_material_Thh1 main
        JOIN (
    SELECT a.packaging_material
        FROM #all_packaging_material_Thh1 a
        WHERE up_down = 'u'
        GROUP BY a.packaging_material
) AS a
        INNER JOIN (
    SELECT b.packaging_material
        FROM #all_packaging_material_Thh1 b
        WHERE up_down = 'd'
        GROUP BY b.packaging_material
) AS b
        ON  a.packaging_material = b.packaging_material
        ON  main.packaging_material = a.packaging_material;


    ---table used for final report
            select packaging_material, ''packaging_class, file1_quantity_kg_extrapolated, file2_quantity_kg_extrapolated, UP_DOWN , ''file2_quantity_unit
        into #all_packaging_material_Thh2
        from #all_packaging_material_Thh1
    union all
        SELECT packaging_material, '', '', '', '', ''
        FROM #POM_COMP_arrow
        where isnull(packaging_material,'')<>''
        group by packaging_material



    --all packaging total non household

    --file 1 is null
 /*               SELECT organisationName, subsidiary_id, packaging_material,
            NULL AS quantity_kg_extrapolated_diff,
            cAST('' AS VARCHAR(2)) AS UP_DOWN, 'file1' filecheck, sum(file1_Quantity_kg_extrapolated) file1_Quantity_kg_extrapolated,
            sum(file2_Quantity_kg_extrapolated) file2_Quantity_kg_extrapolated
        -- sum(file2_quantity_unit) file2_quantity_unit
        INTO #all_packaging_material_Tnhh1
        FROM #POM_COMP_arrow
        WHERE file1_Quantity_kg_extrapolated IS NULL
            and (packaging_type = 'Total Non-Household packaging' )
            and isnull(packaging_material,'')<>''
        GROUP BY organisationName, subsidiary_id,packaging_material

    union all
        --file2 is null 
        SELECT organisationName, subsidiary_id, packaging_material,
            NULL,
            CAST('' AS VARCHAR(2)), 'file2', sum(file1_Quantity_kg_extrapolated) file1_Quantity_kg_extrapolated, sum(file2_Quantity_kg_extrapolated) file2_Quantity_kg_extrapolated
        --,   sum(file2_quantity_unit) file2_quantity_unit
        FROM #POM_COMP_arrow
        WHERE file2_Quantity_kg_extrapolated IS NULL
            and (packaging_type = 'Total Non-Household packaging' )
            and isnull(packaging_material,'')<>''
        GROUP BY organisationName, subsidiary_id,packaging_material

    union all
*/
        --both file1 and 2 have data
                            SELECT organisationName, subsidiary_id, packaging_material,
            --   SUM(quantity_kg_extrapolated_diff),

            case  when @Threshold_Type = 'Percentage' and isnull(sum(isnull(file1_Quantity_kg_extrapolated,0)),0) = 0 then 0
when @Threshold_Type = 'Percentage' and isnull(sum(isnull(file2_Quantity_kg_extrapolated,0)),0) = 0 then 0
when @Threshold_Type = 'Percentage' and sum
(isnull(file1_Quantity_kg_extrapolated,0)) < sum
(isnull(file2_Quantity_kg_extrapolated,0)) 
                then
((sum
(isnull(file2_Quantity_kg_extrapolated,0))-sum
(isnull(file1_Quantity_kg_extrapolated,0)))/sum
(isnull(file1_Quantity_kg_extrapolated,0))*100)
                when @Threshold_Type = 'Percentage' and sum
(isnull(file1_Quantity_kg_extrapolated,0)) > sum
(isnull(file2_Quantity_kg_extrapolated,0)) 
              then
((sum
(isnull(file1_Quantity_kg_extrapolated,0))-sum
(isnull(file2_Quantity_kg_extrapolated,0)))/sum
(isnull(file1_Quantity_kg_extrapolated,0))*-100) 
              when @Threshold_Type = 'Value'
              then  SUM
(isnull(quantity_kg_extrapolated_diff,0))
end quantity_kg_extrapolated_diff,
            CAST('' AS VARCHAR(2)) AS UP_DOWN, 'both' filecheck, sum(file1_Quantity_kg_extrapolated) file1_Quantity_kg_extrapolated, sum(file2_Quantity_kg_extrapolated) file2_Quantity_kg_extrapolated
              INTO #all_packaging_material_Tnhh1
        FROM #POM_COMP_arrow
        WHERE-- file1_Quantity_kg_extrapolated IS NOT NULL
           -- AND file2_Quantity_kg_extrapolated IS NOT NULL
             (packaging_type = 'Total Non-Household packaging' )
            and isnull(packaging_material,'')<>''
        GROUP BY organisationName, subsidiary_id,packaging_material



    ---add arrow
    update a
set a.up_down = 'u'
from #all_packaging_material_Tnhh1 a
where quantity_kg_extrapolated_diff >= @upper_threshold

    update a
set a.up_down = 'd'
from #all_packaging_material_Tnhh1 a
where quantity_kg_extrapolated_diff <= (@lower_threshold*-1)



    --set ud when both
    update main
set main.UP_DOWN ='ud'
FROM #all_packaging_material_Tnhh1 main
        JOIN (
    SELECT a.packaging_material
        FROM #all_packaging_material_Tnhh1 a
        WHERE up_down = 'u'
        GROUP BY a.packaging_material
) AS a
        INNER JOIN (
    SELECT b.packaging_material
        FROM #all_packaging_material_Tnhh1 b
        WHERE up_down = 'd'
        GROUP BY b.packaging_material
) AS b
        ON  a.packaging_material = b.packaging_material
        ON  main.packaging_material = a.packaging_material;


    ---table used for final report
            select packaging_material, ''packaging_class, file1_quantity_kg_extrapolated, file2_quantity_kg_extrapolated, UP_DOWN , ''file2_quantity_unit
        into #all_packaging_material_Tnhh2
        from #all_packaging_material_Tnhh1
    union all
        SELECT packaging_material, '', '', '', '', ''
        FROM #POM_COMP_arrow
        where isnull(packaging_material,'')<>''
        group by packaging_material



    --all packaging reusable

    --file 1 is null
  /*              SELECT organisationName, subsidiary_id, packaging_material,
            NULL AS quantity_kg_extrapolated_diff,
            cAST('' AS VARCHAR(2)) AS UP_DOWN, 'file1' filecheck, sum(file1_Quantity_kg_extrapolated) file1_Quantity_kg_extrapolated,
            sum(file2_Quantity_kg_extrapolated) file2_Quantity_kg_extrapolated
        -- sum(file2_quantity_unit) file2_quantity_unit
        INTO #all_packaging_material_total_reusable1
        FROM #POM_COMP_arrow
        WHERE file1_Quantity_kg_extrapolated IS NULL
            and (packaging_type = 'Reusable packaging' )
            and isnull(packaging_material,'')<>''
        GROUP BY organisationName, subsidiary_id,packaging_material,packaging_class

    union all
        --file2 is null 
        SELECT organisationName, subsidiary_id, packaging_material,
            NULL,
            CAST('' AS VARCHAR(2)), 'file2', sum(file1_Quantity_kg_extrapolated) file1_Quantity_kg_extrapolated, sum(file2_Quantity_kg_extrapolated) file2_Quantity_kg_extrapolated
        --,   sum(file2_quantity_unit) file2_quantity_unit
        FROM #POM_COMP_arrow
        WHERE file2_Quantity_kg_extrapolated IS NULL
            and (packaging_type = 'Reusable packaging' )
            and isnull(packaging_material,'')<>''
        GROUP BY organisationName, subsidiary_id,packaging_material,packaging_class

    union all
*/
        --both file1 and 2 have data
                                  SELECT organisationName, subsidiary_id, packaging_material,
            --   SUM(quantity_kg_extrapolated_diff),

            case  when @Threshold_Type = 'Percentage' and isnull(sum(isnull(file1_Quantity_kg_extrapolated,0)),0) = 0 then 0
when @Threshold_Type = 'Percentage' and isnull(sum(isnull(file2_Quantity_kg_extrapolated,0)),0) = 0 then 0
when @Threshold_Type = 'Percentage' and sum
(isnull(file1_Quantity_kg_extrapolated,0)) < sum
(isnull(file2_Quantity_kg_extrapolated,0)) 
                then
((sum
(isnull(file2_Quantity_kg_extrapolated,0))-sum
(isnull(file1_Quantity_kg_extrapolated,0)))/sum
(isnull(file1_Quantity_kg_extrapolated,0))*100)
                when @Threshold_Type = 'Percentage' and sum
(isnull(file1_Quantity_kg_extrapolated,0)) > sum
(isnull(file2_Quantity_kg_extrapolated,0)) 
              then
((sum
(isnull(file1_Quantity_kg_extrapolated,0))-sum
(isnull(file2_Quantity_kg_extrapolated,0)))/sum
(isnull(file1_Quantity_kg_extrapolated,0))*-100) 
              when @Threshold_Type = 'Value'
              then  SUM
(isnull(quantity_kg_extrapolated_diff,0))
end quantity_kg_extrapolated_diff,
            CAST('' AS VARCHAR(2)) AS UP_DOWN, 'both' filecheck, sum(file1_Quantity_kg_extrapolated) file1_Quantity_kg_extrapolated, sum(file2_Quantity_kg_extrapolated) file2_Quantity_kg_extrapolated
              INTO #all_packaging_material_total_reusable1
        FROM #POM_COMP_arrow
        WHERE --file1_Quantity_kg_extrapolated IS NOT NULL
          --  AND file2_Quantity_kg_extrapolated IS NOT NULL
             (packaging_type = 'Reusable packaging' )
            and isnull(packaging_material,'')<>''
        GROUP BY organisationName, subsidiary_id,packaging_material



    ---add arrow
    update a
set a.up_down = 'u'
from #all_packaging_material_total_reusable1 a
where quantity_kg_extrapolated_diff >= @upper_threshold

    update a
set a.up_down = 'd'
from #all_packaging_material_total_reusable1 a
where quantity_kg_extrapolated_diff <= (@lower_threshold*-1)



    --set ud when both
    update main
set main.UP_DOWN ='ud'
FROM #all_packaging_material_total_reusable1 main
        JOIN (
    SELECT a.packaging_material
        FROM #all_packaging_material_total_reusable1 a
        WHERE up_down = 'u'
        GROUP BY a.packaging_material
) AS a
        INNER JOIN (
    SELECT b.packaging_material
        FROM #all_packaging_material_total_reusable1 b
        WHERE up_down = 'd'
        GROUP BY b.packaging_material
) AS b
        ON  a.packaging_material = b.packaging_material
        ON  main.packaging_material = a.packaging_material;


    ---table used for final report
            select packaging_material, ''packaging_class, file1_quantity_kg_extrapolated, file2_quantity_kg_extrapolated, UP_DOWN , ''file2_quantity_unit
        into #all_packaging_material_total_reusable2
        from #all_packaging_material_total_reusable1
    union all
        SELECT packaging_material, '', '', '', '', ''
        FROM #POM_COMP_arrow
        where isnull(packaging_material,'')<>''
        group by packaging_material


    ----------------------------------------------------------------- 
    --packaging material Household Pacakaging, packaging_class - [packaging_activity]
    ----------------------------------------------------------------------
    --file 1 is null
    /*
                SELECT organisationName, subsidiary_id, packaging_material, packaging_class,
            NULL AS quantity_kg_extrapolated_diff,
            CAST('' AS VARCHAR(2)) AS UP_DOWN, 'file1' filecheck, sum(file1_Quantity_kg_extrapolated) file1_Quantity_kg_extrapolated, sum(file2_Quantity_kg_extrapolated) file2_Quantity_kg_extrapolated
       , [packaging_activity]
        INTO #all_packaging_household_packaging_material_packaging_activity_1
        FROM #POM_COMP_arrow
        WHERE (file1_Quantity_kg_extrapolated IS NULL or file1_Quantity_kg_extrapolated is null)
            and packaging_type = 'Total Household packaging'
            and packaging_class in ('Primary packaging','Public bin','Shipment packaging')
            and isnull(packaging_material,'')<>''
        GROUP BY organisationName, subsidiary_id,packaging_material, packaging_class,packaging_activity*/

   /* union all
        --file2 is null 
        SELECT organisationName, subsidiary_id, packaging_material, packaging_class,
            NULL, CAST('' AS VARCHAR(2)), 'file2', sum(file1_Quantity_kg_extrapolated) file1_Quantity_kg_extrapolated, sum(file2_Quantity_kg_extrapolated) file2_Quantity_kg_extrapolated
        , packaging_activity
        FROM #POM_COMP_arrow
        WHERE file2_Quantity_kg_extrapolated IS NULL
            and packaging_type = 'Total Household packaging'
            and packaging_class in ('Primary packaging','Public bin','Shipment packaging')
            and isnull(packaging_material,'')<>''
        GROUP BY organisationName, subsidiary_id,packaging_material, packaging_class,packaging_activity
*/
   -- union all

        --both file1 and 2 have data
        SELECT organisationName, subsidiary_id, packaging_material, packaging_class,
            --   SUM(quantity_kg_extrapolated_diff),

            case  when @Threshold_Type = 'Percentage' and isnull(sum(isnull(file1_Quantity_kg_extrapolated,0)),0) = 0 then 0
when @Threshold_Type = 'Percentage' and isnull(sum(isnull(file2_Quantity_kg_extrapolated,0)),0) = 0 then 0
when @Threshold_Type = 'Percentage' and sum
(isnull(file1_Quantity_kg_extrapolated,0)) < sum
(isnull(file2_Quantity_kg_extrapolated,0)) 
                then
((sum
(isnull(file2_Quantity_kg_extrapolated,0))-sum
(isnull(file1_Quantity_kg_extrapolated,0)))/sum
(isnull(file1_Quantity_kg_extrapolated,0))*100)
                when @Threshold_Type = 'Percentage' and sum
(isnull(file1_Quantity_kg_extrapolated,0)) > sum
(isnull(file2_Quantity_kg_extrapolated,0)) 
              then
((sum
(isnull(file1_Quantity_kg_extrapolated,0))-sum
(isnull(file2_Quantity_kg_extrapolated,0)))/sum
(isnull(file1_Quantity_kg_extrapolated,0))*-100) 
              when @Threshold_Type = 'Value'
              then  SUM
(isnull(quantity_kg_extrapolated_diff,0))
end quantity_kg_extrapolated_diff,
            CAST('' AS VARCHAR(2)) AS UP_DOWN, 'both' filecheck, sum(file1_Quantity_kg_extrapolated) file1_Quantity_kg_extrapolated, sum(file2_Quantity_kg_extrapolated) file2_Quantity_kg_extrapolated
            , packaging_activity
              INTO #all_packaging_household_packaging_material_packaging_activity_1
        FROM #POM_COMP_arrow
        WHERE --file1_Quantity_kg_extrapolated IS NOT NULL 
          --  AND file2_Quantity_kg_extrapolated IS NOT NULL
             packaging_type = 'Total Household packaging'
            and packaging_class in ('Primary packaging','Shipment packaging')
            and isnull(packaging_material,'')<>''
        GROUP BY organisationName, subsidiary_id,packaging_material, packaging_class,packaging_activity

--select *into dbo.JC_DELETE_ME1 from #all_packaging_household_packaging_material_packaging_activity_1
--select * into percent1 from #all_packaging_household_packaging_material_packaging_activity_1

    ---add arrow
    update a
set a.up_down = 'u'
from #all_packaging_household_packaging_material_packaging_activity_1 a
where quantity_kg_extrapolated_diff >= @upper_threshold

    update a
set a.up_down = 'd'
from #all_packaging_household_packaging_material_packaging_activity_1 a
where quantity_kg_extrapolated_diff <= (@lower_threshold*-1)
--select *into dbo.JC_DELETE_ME2 from #all_packaging_household_packaging_material_packaging_activity_1
--select * into percent2 from #all_packaging_household_packaging_material_packaging_activity_1

    --set ud when both
    update main
set main.UP_DOWN ='ud'
FROM #all_packaging_household_packaging_material_packaging_activity_1 main
        JOIN (
    SELECT a.packaging_material, a.packaging_class, packaging_activity
        FROM #all_packaging_household_packaging_material_packaging_activity_1 a
        WHERE up_down = 'u'
        GROUP BY a.packaging_material, a.packaging_class, packaging_activity
) AS a
        INNER JOIN (
    SELECT b.packaging_material, b.packaging_class, packaging_activity
        FROM #all_packaging_household_packaging_material_packaging_activity_1 b
        WHERE up_down = 'd'
        GROUP BY b.packaging_material, b.packaging_class, packaging_activity
) AS b
        ON a.packaging_class = b.packaging_class AND a.packaging_material = b.packaging_material and a.packaging_activity = b.packaging_activity
        ON main.packaging_class = a.packaging_class AND main.packaging_material = a.packaging_material and main.packaging_activity = a.packaging_activity;


    ---table used for final report
            select packaging_material, packaging_class, quantity_kg_extrapolated_diff, file1_quantity_kg_extrapolated, file2_quantity_kg_extrapolated, UP_DOWN , packaging_activity
        into #all_packaging_household_packaging_material_packaging_activity_2
        from #all_packaging_household_packaging_material_packaging_activity_1
    union all
        SELECT packaging_material, packaging_class, '', '', '', '', packaging_activity
        FROM #POM_COMP_arrow
        where isnull(packaging_class,'') <> ''
            and packaging_class in ('Primary packaging','Shipment packaging')
            and isnull(packaging_material,'')<>''
        group by packaging_material,packaging_class,packaging_activity
--select *into dbo.JC_DELETE_ME3 from #all_packaging_household_packaging_material_packaging_activity_2
--select * into percent3 from #all_packaging_household_packaging_material_packaging_activity_2

    ----------------------------------------------------------------- 
    --packaging material public bin, packaging_class - [packaging_activity]
    ----------------------------------------------------------------------
    --file 1 is null
   /*             SELECT organisationName, subsidiary_id, packaging_material, packaging_class,
            NULL AS quantity_kg_extrapolated_diff,
            CAST('' AS VARCHAR(2)) AS UP_DOWN, 'file1' filecheck, sum(file1_Quantity_kg_extrapolated) file1_Quantity_kg_extrapolated, sum(file2_Quantity_kg_extrapolated) file2_Quantity_kg_extrapolated
       , [packaging_activity]
        INTO #all_packaging_pb_packaging_material_packaging_activity_1
        FROM #POM_COMP_arrow
        WHERE file1_Quantity_kg_extrapolated IS NULL
            and packaging_type = 'Public bin'
            and packaging_class in ('Public bin')
            and isnull(packaging_material,'')<>''
        GROUP BY organisationName, subsidiary_id,packaging_material, packaging_class,packaging_activity

    union all
        --file2 is null 
        SELECT organisationName, subsidiary_id, packaging_material, packaging_class,
            NULL, CAST('' AS VARCHAR(2)), 'file2', sum(file1_Quantity_kg_extrapolated) file1_Quantity_kg_extrapolated, sum(file2_Quantity_kg_extrapolated) file2_Quantity_kg_extrapolated
        , packaging_activity
        FROM #POM_COMP_arrow
        WHERE file2_Quantity_kg_extrapolated IS NULL
            and packaging_type = 'Public bin'
            and packaging_class in ('Public bin')
            and isnull(packaging_material,'')<>''
        GROUP BY organisationName, subsidiary_id,packaging_material, packaging_class,packaging_activity

    union all
*/
        --both file1 and 2 have data
                                  SELECT organisationName, subsidiary_id, packaging_material,packaging_class,
            --   SUM(quantity_kg_extrapolated_diff),

            case  when @Threshold_Type = 'Percentage' and isnull(sum(isnull(file1_Quantity_kg_extrapolated,0)),0) = 0 then 0
when @Threshold_Type = 'Percentage' and isnull(sum(isnull(file2_Quantity_kg_extrapolated,0)),0) = 0 then 0
when @Threshold_Type = 'Percentage' and sum
(isnull(file1_Quantity_kg_extrapolated,0)) < sum
(isnull(file2_Quantity_kg_extrapolated,0)) 
                then
((sum
(isnull(file2_Quantity_kg_extrapolated,0))-sum
(isnull(file1_Quantity_kg_extrapolated,0)))/sum
(isnull(file1_Quantity_kg_extrapolated,0))*100)
                when @Threshold_Type = 'Percentage' and sum
(isnull(file1_Quantity_kg_extrapolated,0)) > sum
(isnull(file2_Quantity_kg_extrapolated,0)) 
              then
((sum
(isnull(file1_Quantity_kg_extrapolated,0))-sum
(isnull(file2_Quantity_kg_extrapolated,0)))/sum
(isnull(file1_Quantity_kg_extrapolated,0))*-100) 
              when @Threshold_Type = 'Value'
              then  SUM
(isnull(quantity_kg_extrapolated_diff,0))
end quantity_kg_extrapolated_diff,
            CAST('' AS VARCHAR(2)) AS UP_DOWN, 'both' filecheck, sum(file1_Quantity_kg_extrapolated) file1_Quantity_kg_extrapolated, sum(file2_Quantity_kg_extrapolated) file2_Quantity_kg_extrapolated
            , packaging_activity
              INTO #all_packaging_pb_packaging_material_packaging_activity_1
        FROM #POM_COMP_arrow
        WHERE --file1_Quantity_kg_extrapolated IS NOT NULL
            --AND file2_Quantity_kg_extrapolated IS NOT NULL
             packaging_type = 'Public binned'
            and packaging_class in ('Public bin')
            and isnull(packaging_material,'')<>''
        GROUP BY organisationName, subsidiary_id,packaging_material, packaging_class,packaging_activity



    ---add arrow
    update a
set a.up_down = 'u'
from #all_packaging_pb_packaging_material_packaging_activity_1 a
where quantity_kg_extrapolated_diff >= @upper_threshold

    update a
set a.up_down = 'd'
from #all_packaging_pb_packaging_material_packaging_activity_1 a
where quantity_kg_extrapolated_diff <= (@lower_threshold*-1)



    --set ud when both
    update main
set main.UP_DOWN ='ud'
FROM #all_packaging_pb_packaging_material_packaging_activity_1 main
        JOIN (
    SELECT a.packaging_material, a.packaging_class, packaging_activity
        FROM #all_packaging_pb_packaging_material_packaging_activity_1 a
        WHERE up_down = 'u'
        GROUP BY a.packaging_material, a.packaging_class, packaging_activity
) AS a
        INNER JOIN (
    SELECT b.packaging_material, b.packaging_class, packaging_activity
        FROM #all_packaging_pb_packaging_material_packaging_activity_1 b
        WHERE up_down = 'd'
        GROUP BY b.packaging_material, b.packaging_class, packaging_activity
) AS b
        ON a.packaging_class = b.packaging_class AND a.packaging_material = b.packaging_material and a.packaging_activity = b.packaging_activity
        ON main.packaging_class = a.packaging_class AND main.packaging_material = a.packaging_material and a.packaging_activity = main.packaging_activity;


    ---table used for final report
            select packaging_material, packaging_class, quantity_kg_extrapolated_diff, file1_quantity_kg_extrapolated, file2_quantity_kg_extrapolated, UP_DOWN , packaging_activity
        into #all_packaging_pb_packaging_material_packaging_activity_2
        from #all_packaging_pb_packaging_material_packaging_activity_1
    union all
        SELECT packaging_material, packaging_class, '', '', '', '', packaging_activity
        FROM #POM_COMP_arrow
        where isnull(packaging_class,'') <> ''
            and packaging_class in ('Public Bin')
            and isnull(packaging_material,'')<>''
        group by packaging_material,packaging_class,packaging_activity



    ----------------------------------------------------------------- 
    --packaging material Total Non-Household packaging, packaging_class - [packaging_activity]
    ----------------------------------------------------------------------
    --file 1 is null
  /*              SELECT organisationName, subsidiary_id, packaging_material, packaging_class,
            NULL AS quantity_kg_extrapolated_diff,
            CAST('' AS VARCHAR(2)) AS UP_DOWN, 'file1' filecheck, sum(file1_Quantity_kg_extrapolated) file1_Quantity_kg_extrapolated, sum(file2_Quantity_kg_extrapolated) file2_Quantity_kg_extrapolated
       , [packaging_activity]
        INTO #all_packaging_tnh_packaging_material_packaging_activity_1
        FROM #POM_COMP_arrow
        WHERE file1_Quantity_kg_extrapolated IS NULL
            and packaging_type = 'Total Non-Household packaging'
            and isnull(packaging_material,'')<>''
        GROUP BY organisationName, subsidiary_id,packaging_material, packaging_class,packaging_activity

    union all
        --file2 is null 
        SELECT organisationName, subsidiary_id, packaging_material, packaging_class,
            NULL, CAST('' AS VARCHAR(2)), 'file2', sum(file1_Quantity_kg_extrapolated) file1_Quantity_kg_extrapolated, sum(file2_Quantity_kg_extrapolated) file2_Quantity_kg_extrapolated
        , packaging_activity
        FROM #POM_COMP_arrow
        WHERE file2_Quantity_kg_extrapolated IS NULL
            and packaging_type = 'Total Non-Household packaging'
            and isnull(packaging_material,'')<>''
        GROUP BY organisationName, subsidiary_id,packaging_material, packaging_class,packaging_activity

    union all
*/
                                 SELECT organisationName, subsidiary_id, packaging_material,packaging_class,
            --   SUM(quantity_kg_extrapolated_diff),

            case  when @Threshold_Type = 'Percentage' and isnull(sum(isnull(file1_Quantity_kg_extrapolated,0)),0) = 0 then 0
when @Threshold_Type = 'Percentage' and isnull(sum(isnull(file2_Quantity_kg_extrapolated,0)),0) = 0 then 0
when @Threshold_Type = 'Percentage' and sum
(isnull(file1_Quantity_kg_extrapolated,0)) < sum
(isnull(file2_Quantity_kg_extrapolated,0)) 
                then
((sum
(isnull(file2_Quantity_kg_extrapolated,0))-sum
(isnull(file1_Quantity_kg_extrapolated,0)))/sum
(isnull(file1_Quantity_kg_extrapolated,0))*100)
                when @Threshold_Type = 'Percentage' and sum
(isnull(file1_Quantity_kg_extrapolated,0)) > sum
(isnull(file2_Quantity_kg_extrapolated,0)) 
              then
((sum
(isnull(file1_Quantity_kg_extrapolated,0))-sum
(isnull(file2_Quantity_kg_extrapolated,0)))/sum
(isnull(file1_Quantity_kg_extrapolated,0))*-100) 
              when @Threshold_Type = 'Value'
              then  SUM
(isnull(quantity_kg_extrapolated_diff,0))
end quantity_kg_extrapolated_diff,
            CAST('' AS VARCHAR(2)) AS UP_DOWN, 'both' filecheck, sum(file1_Quantity_kg_extrapolated) file1_Quantity_kg_extrapolated, sum(file2_Quantity_kg_extrapolated) file2_Quantity_kg_extrapolated
            , packaging_activity
             INTO #all_packaging_tnh_packaging_material_packaging_activity_1
        FROM #POM_COMP_arrow
        WHERE --file1_Quantity_kg_extrapolated IS NOT NULL
          --  AND file2_Quantity_kg_extrapolated IS NOT NULL
             packaging_type = 'Total Non-Household packaging'
            and isnull(packaging_material,'')<>''
        GROUP BY organisationName, subsidiary_id,packaging_material, packaging_class,packaging_activity



    ---add arrow
    update a
set a.up_down = 'u'
from #all_packaging_tnh_packaging_material_packaging_activity_1 a
where quantity_kg_extrapolated_diff >= @upper_threshold

    update a
set a.up_down = 'd'
from #all_packaging_tnh_packaging_material_packaging_activity_1 a
where quantity_kg_extrapolated_diff <= (@lower_threshold*-1)



    --set ud when both
    update main
set main.UP_DOWN ='ud'
FROM #all_packaging_tnh_packaging_material_packaging_activity_1 main
        JOIN (
    SELECT a.packaging_material, a.packaging_class, packaging_activity
        FROM #all_packaging_tnh_packaging_material_packaging_activity_1 a
        WHERE up_down = 'u'
        GROUP BY a.packaging_material, a.packaging_class, packaging_activity
) AS a
        INNER JOIN (
    SELECT b.packaging_material, b.packaging_class, packaging_activity
        FROM #all_packaging_tnh_packaging_material_packaging_activity_1 b
        WHERE up_down = 'd'
        GROUP BY b.packaging_material, b.packaging_class, packaging_activity
) AS b
        ON a.packaging_class = b.packaging_class AND a.packaging_material = b.packaging_material and a.packaging_activity = b.packaging_activity
        ON main.packaging_class = a.packaging_class AND main.packaging_material = a.packaging_material and a.packaging_activity = main.packaging_activity;


    ---table used for final report
            select packaging_material, packaging_class, quantity_kg_extrapolated_diff, file1_quantity_kg_extrapolated, file2_quantity_kg_extrapolated, UP_DOWN , packaging_activity
        into #all_packaging_tnh_packaging_material_packaging_activity_2
        from #all_packaging_tnh_packaging_material_packaging_activity_1
    union all
        SELECT packaging_material, packaging_class, '', '', '', '', packaging_activity
        FROM #POM_COMP_arrow
        where packaging_class in ('Primary packaging','Secondary packaging','Shipment packaging','Online marketplace total','Tertiary packaging')
        and isnull(packaging_material,'')<>''
        group by packaging_material,packaging_class,packaging_activity



    --packaging material Household drinks - packaging_activity

    --file 1 is null
       /*         SELECT organisationName, subsidiary_id, packaging_material,
            NULL AS quantity_kg_extrapolated_diff,
            CAST('' AS VARCHAR(2)) AS UP_DOWN, 'file1' filecheck, sum(file1_Quantity_kg_extrapolated) file1_Quantity_kg_extrapolated,
            sum(file2_Quantity_kg_extrapolated) file2_Quantity_kg_extrapolated,
            sum(file2_quantity_unit) file2_quantity_unit
            , packaging_activity
        INTO #all_packaging_household_drinks_material_packaging_activity_1
        FROM #POM_COMP_arrow
        WHERE file1_Quantity_kg_extrapolated IS NULL
            and packaging_type = 'Household drinks containers'
            and isnull(packaging_material,'')<>''
        GROUP BY organisationName, subsidiary_id,packaging_material,packaging_activity

    union all
        --file2 is null 
        SELECT organisationName, subsidiary_id, packaging_material,
            NULL, CAST('' AS VARCHAR(2)), 'file2', sum(file1_Quantity_kg_extrapolated) file1_Quantity_kg_extrapolated, sum(file2_Quantity_kg_extrapolated) file2_Quantity_kg_extrapolated
                , sum(file2_quantity_unit) file2_quantity_unit
                , packaging_activity
        FROM #POM_COMP_arrow
        WHERE file2_Quantity_kg_extrapolated IS NULL
            and packaging_type = 'Household drinks containers'
            and isnull(packaging_material,'')<>''
        GROUP BY organisationName, subsidiary_id,packaging_material,packaging_activity

    union all
*/
                                     SELECT organisationName, subsidiary_id, packaging_material,
            --   SUM(quantity_kg_extrapolated_diff),

            case  when @Threshold_Type = 'Percentage' and isnull(sum(isnull(file1_Quantity_kg_extrapolated,0)),0) = 0 then 0
when @Threshold_Type = 'Percentage' and isnull(sum(isnull(file2_Quantity_kg_extrapolated,0)),0) = 0 then 0
when @Threshold_Type = 'Percentage' and sum
(isnull(file1_Quantity_kg_extrapolated,0)) < sum
(isnull(file2_Quantity_kg_extrapolated,0)) 
                then
((sum
(isnull(file2_Quantity_kg_extrapolated,0))-sum
(isnull(file1_Quantity_kg_extrapolated,0)))/sum
(isnull(file1_Quantity_kg_extrapolated,0))*100)
                when @Threshold_Type = 'Percentage' and sum
(isnull(file1_Quantity_kg_extrapolated,0)) > sum
(isnull(file2_Quantity_kg_extrapolated,0)) 
              then
((sum
(isnull(file1_Quantity_kg_extrapolated,0))-sum
(isnull(file2_Quantity_kg_extrapolated,0)))/sum
(isnull(file1_Quantity_kg_extrapolated,0))*-100) 
              when @Threshold_Type = 'Value'
              then  SUM
(isnull(quantity_kg_extrapolated_diff,0))
end quantity_kg_extrapolated_diff,
            CAST('' AS VARCHAR(2)) AS UP_DOWN, 'both' filecheck, sum(file1_Quantity_kg_extrapolated) file1_Quantity_kg_extrapolated, sum(file2_Quantity_kg_extrapolated) file2_Quantity_kg_extrapolated
               , sum(file2_quantity_unit) file2_quantity_unit
               , packaging_activity
                INTO #all_packaging_household_drinks_material_packaging_activity_1
        FROM #POM_COMP_arrow
        WHERE --file1_Quantity_kg_extrapolated IS NOT NULL
          --  AND file2_Quantity_kg_extrapolated IS NOT NULL
             packaging_type = 'Household drinks containers'
            and isnull(packaging_material,'')<>''
        GROUP BY organisationName, subsidiary_id,packaging_material,packaging_activity



    ---add arrow
    update a
set a.up_down = 'u'
from #all_packaging_household_drinks_material_packaging_activity_1 a
where quantity_kg_extrapolated_diff >= @upper_threshold

    update a
set a.up_down = 'd'
from #all_packaging_household_drinks_material_packaging_activity_1 a
where quantity_kg_extrapolated_diff <= (@lower_threshold*-1)



    --set ud when both
    update main
set main.UP_DOWN ='ud'
FROM #all_packaging_household_drinks_material_packaging_activity_1 main
        JOIN (
    SELECT a.packaging_material, packaging_activity
        FROM #all_packaging_household_drinks_material_packaging_activity_1 a
        WHERE up_down = 'u'
        GROUP BY a.packaging_material,packaging_activity
) AS a
        INNER JOIN (
    SELECT b.packaging_material, packaging_activity
        FROM #all_packaging_household_drinks_material_packaging_activity_1 b
        WHERE up_down = 'd'
        GROUP BY b.packaging_material, packaging_activity
) AS b
        ON  a.packaging_material = b.packaging_material and a.packaging_activity = b.packaging_activity
        ON main.packaging_material = a.packaging_material and a.packaging_activity = main.packaging_activity;


    ---table used for final report
            select packaging_material, quantity_kg_extrapolated_diff, file1_quantity_kg_extrapolated, file2_quantity_kg_extrapolated, UP_DOWN , file2_quantity_unit, [packaging_activity]
        into #all_packaging_household_drinks_material_packaging_activity_2
        from #all_packaging_household_drinks_material_packaging_activity_1
    union all
        SELECT packaging_material, '', '', '', '', '', packaging_activity
        FROM #POM_COMP_arrow
        where isnull(packaging_material,'')<>''
        group by packaging_material,packaging_activity

    --packaging material nonHousehold drinks - packaging_activity

    --file 1 is null
  /*              SELECT organisationName, subsidiary_id, packaging_material,
            NULL AS quantity_kg_extrapolated_diff,
            CAST('' AS VARCHAR(2)) AS UP_DOWN, 'file1' filecheck, sum(file1_Quantity_kg_extrapolated) file1_Quantity_kg_extrapolated,
            sum(file2_Quantity_kg_extrapolated) file2_Quantity_kg_extrapolated,
            sum(file2_quantity_unit) file2_quantity_unit
            , packaging_activity
        INTO #all_packaging_nonhousehold_drinks_material_packaging_activity_1
        FROM #POM_COMP_arrow
        WHERE file1_Quantity_kg_extrapolated IS NULL
            and packaging_type = 'Non-household drinks containers'
            and isnull(packaging_material,'')<>''
        GROUP BY organisationName, subsidiary_id,packaging_material,packaging_activity

    union all
        --file2 is null 
        SELECT organisationName, subsidiary_id, packaging_material,
            NULL, CAST('' AS VARCHAR(2)), 'file2', sum(file1_Quantity_kg_extrapolated) file1_Quantity_kg_extrapolated, sum(file2_Quantity_kg_extrapolated) file2_Quantity_kg_extrapolated
                , sum(file2_quantity_unit) file2_quantity_unit
                , packaging_activity
        FROM #POM_COMP_arrow
        WHERE file2_Quantity_kg_extrapolated IS NULL
            and packaging_type = 'Non-household drinks containers'
            and isnull(packaging_material,'')<>''
        GROUP BY organisationName, subsidiary_id,packaging_material,packaging_activity

    union all
*/
        --both file1 and 2 have data
                                 SELECT organisationName, subsidiary_id, packaging_material,
            --   SUM(quantity_kg_extrapolated_diff),

            case  when @Threshold_Type = 'Percentage' and isnull(sum(isnull(file1_Quantity_kg_extrapolated,0)),0) = 0 then 0
when @Threshold_Type = 'Percentage' and isnull(sum(isnull(file2_Quantity_kg_extrapolated,0)),0) = 0 then 0
when @Threshold_Type = 'Percentage' and sum
(isnull(file1_Quantity_kg_extrapolated,0)) < sum
(isnull(file2_Quantity_kg_extrapolated,0)) 
                then
((sum
(isnull(file2_Quantity_kg_extrapolated,0))-sum
(isnull(file1_Quantity_kg_extrapolated,0)))/sum
(isnull(file1_Quantity_kg_extrapolated,0))*100)
                when @Threshold_Type = 'Percentage' and sum
(isnull(file1_Quantity_kg_extrapolated,0)) > sum
(isnull(file2_Quantity_kg_extrapolated,0)) 
              then
((sum
(isnull(file1_Quantity_kg_extrapolated,0))-sum
(isnull(file2_Quantity_kg_extrapolated,0)))/sum
(isnull(file1_Quantity_kg_extrapolated,0))*-100) 
              when @Threshold_Type = 'Value'
              then  SUM
(isnull(quantity_kg_extrapolated_diff,0))
end quantity_kg_extrapolated_diff,
            CAST('' AS VARCHAR(2)) AS UP_DOWN, 'both' filecheck, sum(file1_Quantity_kg_extrapolated) file1_Quantity_kg_extrapolated, sum(file2_Quantity_kg_extrapolated) file2_Quantity_kg_extrapolated
               , sum(file2_quantity_unit) file2_quantity_unit
               , packaging_activity
                    INTO #all_packaging_nonhousehold_drinks_material_packaging_activity_1
        FROM #POM_COMP_arrow
        WHERE --file1_Quantity_kg_extrapolated IS NOT NULL
           -- AND file2_Quantity_kg_extrapolated IS NOT NULL
             packaging_type = 'Non-household drinks containers'
            and isnull(packaging_material,'')<>''
        GROUP BY organisationName, subsidiary_id,packaging_material,packaging_activity



    ---add arrow
    update a
set a.up_down = 'u'
from #all_packaging_nonhousehold_drinks_material_packaging_activity_1 a
where quantity_kg_extrapolated_diff >= @upper_threshold

    update a
set a.up_down = 'd'
from #all_packaging_nonhousehold_drinks_material_packaging_activity_1 a
where quantity_kg_extrapolated_diff <= (@lower_threshold*-1)



    --set ud when both
    update main
set main.UP_DOWN ='ud'
FROM #all_packaging_nonhousehold_drinks_material_packaging_activity_1 main
        JOIN (
    SELECT a.packaging_material, packaging_activity
        FROM #all_packaging_nonhousehold_drinks_material_packaging_activity_1 a
        WHERE up_down = 'u'
        GROUP BY a.packaging_material,packaging_activity
) AS a
        INNER JOIN (
    SELECT b.packaging_material, packaging_activity
        FROM #all_packaging_nonhousehold_drinks_material_packaging_activity_1 b
        WHERE up_down = 'd'
        GROUP BY b.packaging_material, packaging_activity
) AS b
        ON  a.packaging_material = b.packaging_material and a.packaging_activity = b.packaging_activity
        ON main.packaging_material = a.packaging_material and a.packaging_activity = main.packaging_activity;


    ---table used for final report
            select packaging_material, quantity_kg_extrapolated_diff, file1_quantity_kg_extrapolated, file2_quantity_kg_extrapolated, UP_DOWN , file2_quantity_unit, [packaging_activity]
        into #all_packaging_nonhousehold_drinks_material_packaging_activity_2
        from #all_packaging_nonhousehold_drinks_material_packaging_activity_1
    union all
        SELECT packaging_material, '', '', '', '', '', packaging_activity
        FROM #POM_COMP_arrow
        where isnull(packaging_material,'')<>''
        group by packaging_material,packaging_activity

    --packaging material all drinks - packaging_activity

    --file 1 is null
 /*               SELECT organisationName, subsidiary_id, packaging_material,
            NULL AS quantity_kg_extrapolated_diff,
            CAST('' AS VARCHAR(2)) AS UP_DOWN, 'file1' filecheck, sum(file1_Quantity_kg_extrapolated) file1_Quantity_kg_extrapolated,
            sum(file2_Quantity_kg_extrapolated) file2_Quantity_kg_extrapolated,
            sum(file2_quantity_unit) file2_quantity_unit
            , packaging_activity
        INTO #all_packaging_all_drinks_material_packaging_activity_1
        FROM #POM_COMP_arrow
        WHERE file1_Quantity_kg_extrapolated IS NULL
            and (packaging_type = 'Non-household drinks containers' OR packaging_type = 'Household drinks containers')
            and isnull(packaging_material,'')<>''
        GROUP BY organisationName, subsidiary_id,packaging_material,packaging_activity

    union all
        --file2 is null 
        SELECT organisationName, subsidiary_id, packaging_material,
            NULL, CAST('' AS VARCHAR(2)), 'file2', sum(file1_Quantity_kg_extrapolated) file1_Quantity_kg_extrapolated, sum(file2_Quantity_kg_extrapolated) file2_Quantity_kg_extrapolated
                , sum(file2_quantity_unit) file2_quantity_unit
                , packaging_activity
        FROM #POM_COMP_arrow
        WHERE file2_Quantity_kg_extrapolated IS NULL
            and (packaging_type = 'Non-household drinks containers' OR packaging_type = 'Household drinks containers')
            and isnull(packaging_material,'')<>''
        GROUP BY organisationName, subsidiary_id,packaging_material,packaging_activity

    union all
*/
                              SELECT organisationName, subsidiary_id, packaging_material,
            --   SUM(quantity_kg_extrapolated_diff),

            case  when @Threshold_Type = 'Percentage' and isnull(sum(isnull(file1_Quantity_kg_extrapolated,0)),0) = 0 then 0
when @Threshold_Type = 'Percentage' and isnull(sum(isnull(file2_Quantity_kg_extrapolated,0)),0) = 0 then 0
when @Threshold_Type = 'Percentage' and sum
(isnull(file1_Quantity_kg_extrapolated,0)) < sum
(isnull(file2_Quantity_kg_extrapolated,0)) 
                then
((sum
(isnull(file2_Quantity_kg_extrapolated,0))-sum
(isnull(file1_Quantity_kg_extrapolated,0)))/sum
(isnull(file1_Quantity_kg_extrapolated,0))*100)
                when @Threshold_Type = 'Percentage' and sum
(isnull(file1_Quantity_kg_extrapolated,0)) > sum
(isnull(file2_Quantity_kg_extrapolated,0)) 
              then
((sum
(isnull(file1_Quantity_kg_extrapolated,0))-sum
(isnull(file2_Quantity_kg_extrapolated,0)))/sum
(isnull(file1_Quantity_kg_extrapolated,0))*-100) 
              when @Threshold_Type = 'Value'
              then  SUM
(isnull(quantity_kg_extrapolated_diff,0))
end quantity_kg_extrapolated_diff,
            CAST('' AS VARCHAR(2)) AS UP_DOWN, 'both' filecheck, sum(file1_Quantity_kg_extrapolated) file1_Quantity_kg_extrapolated, sum(file2_Quantity_kg_extrapolated) file2_Quantity_kg_extrapolated
               , sum(file2_quantity_unit) file2_quantity_unit
               , packaging_activity
                  INTO #all_packaging_all_drinks_material_packaging_activity_1
        FROM #POM_COMP_arrow
        WHERE --file1_Quantity_kg_extrapolated IS NOT NULL
            --AND file2_Quantity_kg_extrapolated IS NOT NULL
             (packaging_type = 'Non-household drinks containers' OR packaging_type = 'Household drinks containers')
            and isnull(packaging_material,'')<>''
        GROUP BY organisationName, subsidiary_id,packaging_material,packaging_activity



    ---add arrow
    update a
set a.up_down = 'u'
from #all_packaging_all_drinks_material_packaging_activity_1 a
where quantity_kg_extrapolated_diff >= @upper_threshold

    update a
set a.up_down = 'd'
from #all_packaging_all_drinks_material_packaging_activity_1 a
where quantity_kg_extrapolated_diff <= (@lower_threshold*-1)



    --set ud when both
    update main
set main.UP_DOWN ='ud'
FROM #all_packaging_all_drinks_material_packaging_activity_1 main
        JOIN (
    SELECT a.packaging_material, packaging_activity
        FROM #all_packaging_all_drinks_material_packaging_activity_1 a
        WHERE up_down = 'u'
        GROUP BY a.packaging_material,packaging_activity
) AS a
        INNER JOIN (
    SELECT b.packaging_material, packaging_activity
        FROM #all_packaging_all_drinks_material_packaging_activity_1 b
        WHERE up_down = 'd'
        GROUP BY b.packaging_material, packaging_activity
) AS b
        ON  a.packaging_material = b.packaging_material and a.packaging_activity = b.packaging_activity
        ON main.packaging_material = a.packaging_material and a.packaging_activity = main.packaging_activity;


    ---table used for final report
            select packaging_material, quantity_kg_extrapolated_diff, file1_quantity_kg_extrapolated, file2_quantity_kg_extrapolated, UP_DOWN , file2_quantity_unit, [packaging_activity]
        into #all_packaging_all_drinks_material_packaging_activity_2
        from #all_packaging_all_drinks_material_packaging_activity_1
    union all
        SELECT packaging_material, '', '', '', '', '', packaging_activity
        FROM #POM_COMP_arrow
        where isnull(packaging_material,'')<>''
        group by packaging_material,packaging_activity




    ----------------------------------------------------------------- 
    --packaging material reuasable, packaging_class - [packaging_activity]
    ----------------------------------------------------------------------
    --file 1 is null
     /*           SELECT organisationName, subsidiary_id, packaging_material, packaging_class,
            NULL AS quantity_kg_extrapolated_diff,
            CAST('' AS VARCHAR(2)) AS UP_DOWN, 'file1' filecheck, sum(file1_Quantity_kg_extrapolated) file1_Quantity_kg_extrapolated, sum(file2_Quantity_kg_extrapolated) file2_Quantity_kg_extrapolated
       , [packaging_activity]
        INTO #all_packaging_reusable_packaging_material_packaging_activity_1
        FROM #POM_COMP_arrow
        WHERE file1_Quantity_kg_extrapolated IS NULL
            and packaging_type = 'Reusable packaging'
            and isnull(packaging_material,'')<>''
        GROUP BY organisationName, subsidiary_id,packaging_material, packaging_class,packaging_activity

    union all
        --file2 is null 
        SELECT organisationName, subsidiary_id, packaging_material, packaging_class,
            NULL, CAST('' AS VARCHAR(2)), 'file2', sum(file1_Quantity_kg_extrapolated) file1_Quantity_kg_extrapolated, sum(file2_Quantity_kg_extrapolated) file2_Quantity_kg_extrapolated
        , packaging_activity
        FROM #POM_COMP_arrow
        WHERE file2_Quantity_kg_extrapolated IS NULL
            and packaging_type = 'Reusable packaging'
            and isnull(packaging_material,'')<>''
        GROUP BY organisationName, subsidiary_id,packaging_material, packaging_class,packaging_activity

    union all
*/
        --both file1 and 2 have data
                                  SELECT organisationName, subsidiary_id, packaging_material,packaging_class,
            --   SUM(quantity_kg_extrapolated_diff),

            case  when @Threshold_Type = 'Percentage' and isnull(sum(isnull(file1_Quantity_kg_extrapolated,0)),0) = 0 then 0
when @Threshold_Type = 'Percentage' and isnull(sum(isnull(file2_Quantity_kg_extrapolated,0)),0) = 0 then 0
when @Threshold_Type = 'Percentage' and sum
(isnull(file1_Quantity_kg_extrapolated,0)) < sum
(isnull(file2_Quantity_kg_extrapolated,0)) 
                then
((sum
(isnull(file2_Quantity_kg_extrapolated,0))-sum
(isnull(file1_Quantity_kg_extrapolated,0)))/sum
(isnull(file1_Quantity_kg_extrapolated,0))*100)
                when @Threshold_Type = 'Percentage' and sum
(isnull(file1_Quantity_kg_extrapolated,0)) > sum
(isnull(file2_Quantity_kg_extrapolated,0)) 
              then
((sum
(isnull(file1_Quantity_kg_extrapolated,0))-sum
(isnull(file2_Quantity_kg_extrapolated,0)))/sum
(isnull(file1_Quantity_kg_extrapolated,0))*-100) 
              when @Threshold_Type = 'Value'
              then  SUM
(isnull(quantity_kg_extrapolated_diff,0))
end quantity_kg_extrapolated_diff,
            CAST('' AS VARCHAR(2)) AS UP_DOWN, 'both' filecheck, sum(file1_Quantity_kg_extrapolated) file1_Quantity_kg_extrapolated, sum(file2_Quantity_kg_extrapolated) file2_Quantity_kg_extrapolated
            , packaging_activity
               INTO #all_packaging_reusable_packaging_material_packaging_activity_1
        FROM #POM_COMP_arrow
        WHERE --file1_Quantity_kg_extrapolated IS NOT NULL
           -- AND file2_Quantity_kg_extrapolated IS NOT NULL
             packaging_type = 'Reusable packaging'
            and isnull(packaging_material,'')<>''
        GROUP BY organisationName, subsidiary_id,packaging_material, packaging_class,packaging_activity



    ---add arrow
    update a
set a.up_down = 'u'
from #all_packaging_reusable_packaging_material_packaging_activity_1 a
where quantity_kg_extrapolated_diff >= @upper_threshold

    update a
set a.up_down = 'd'
from #all_packaging_reusable_packaging_material_packaging_activity_1 a
where quantity_kg_extrapolated_diff <= (@lower_threshold*-1)



    --set ud when both
    update main
set main.UP_DOWN ='ud'
FROM #all_packaging_reusable_packaging_material_packaging_activity_1 main
        JOIN (
    SELECT a.packaging_material, a.packaging_class, packaging_activity
        FROM #all_packaging_reusable_packaging_material_packaging_activity_1 a
        WHERE up_down = 'u'
        GROUP BY a.packaging_material, a.packaging_class, packaging_activity
) AS a
        INNER JOIN (
    SELECT b.packaging_material, b.packaging_class, packaging_activity
        FROM #all_packaging_reusable_packaging_material_packaging_activity_1 b
        WHERE up_down = 'd'
        GROUP BY b.packaging_material, b.packaging_class, packaging_activity
) AS b
        ON a.packaging_class = b.packaging_class AND a.packaging_material = b.packaging_material and a.packaging_activity = b.packaging_activity
        ON main.packaging_class = a.packaging_class AND main.packaging_material = a.packaging_material and a.packaging_activity = main.packaging_activity;


    ---table used for final report
            select packaging_material, packaging_class, quantity_kg_extrapolated_diff, file1_quantity_kg_extrapolated, file2_quantity_kg_extrapolated, UP_DOWN , packaging_activity
        into #all_packaging_reusable_packaging_material_packaging_activity_2
        from #all_packaging_reusable_packaging_material_packaging_activity_1
    union all
        SELECT packaging_material, packaging_class, '', '', '', '', packaging_activity
        FROM #POM_COMP_arrow
        where packaging_class in ('Primary packaging','Non-primary reusable packaging')
        and isnull(packaging_material,'')<>''
        group by packaging_material,packaging_class,packaging_activity





    ----------------------------------------------------------------- 
    --packaging material TOTAL packaging, packaging_class - [packaging_activity]
    ----------------------------------------------------------------------
    --file 1 is null
    /*            SELECT organisationName, subsidiary_id, packaging_material,
            NULL AS quantity_kg_extrapolated_diff,
            CAST('' AS VARCHAR(2)) AS UP_DOWN, 'file1' filecheck, sum(file1_Quantity_kg_extrapolated) file1_Quantity_kg_extrapolated, sum(file2_Quantity_kg_extrapolated) file2_Quantity_kg_extrapolated
       , [packaging_activity]
        INTO #all_packaging_tp_packaging_material_packaging_activity_1
        FROM #POM_COMP_arrow
        WHERE file1_Quantity_kg_extrapolated IS NULL
            and Total_Packaging = 'Total packaging'
            and isnull(packaging_material,'')<>''
        GROUP BY organisationName, subsidiary_id,packaging_material, packaging_class,packaging_activity

    union all
        --file2 is null 
        SELECT organisationName, subsidiary_id, packaging_material,
            NULL, CAST('' AS VARCHAR(2)), 'file2', sum(file1_Quantity_kg_extrapolated) file1_Quantity_kg_extrapolated, sum(file2_Quantity_kg_extrapolated) file2_Quantity_kg_extrapolated
        , packaging_activity
        FROM #POM_COMP_arrow
        WHERE file2_Quantity_kg_extrapolated IS NULL
            and Total_Packaging = 'Total packaging'
            and isnull(packaging_material,'')<>''
        GROUP BY organisationName, subsidiary_id,packaging_material,packaging_activity

    union all
*/
                                     SELECT organisationName, subsidiary_id, packaging_material,
            --   SUM(quantity_kg_extrapolated_diff),

            case  when @Threshold_Type = 'Percentage' and isnull(sum(isnull(file1_Quantity_kg_extrapolated,0)),0) = 0 then 0
when @Threshold_Type = 'Percentage' and isnull(sum(isnull(file2_Quantity_kg_extrapolated,0)),0) = 0 then 0
when @Threshold_Type = 'Percentage' and sum
(isnull(file1_Quantity_kg_extrapolated,0)) < sum
(isnull(file2_Quantity_kg_extrapolated,0)) 
                then
((sum
(isnull(file2_Quantity_kg_extrapolated,0))-sum
(isnull(file1_Quantity_kg_extrapolated,0)))/sum
(isnull(file1_Quantity_kg_extrapolated,0))*100)
                when @Threshold_Type = 'Percentage' and sum
(isnull(file1_Quantity_kg_extrapolated,0)) > sum
(isnull(file2_Quantity_kg_extrapolated,0)) 
              then
((sum
(isnull(file1_Quantity_kg_extrapolated,0))-sum
(isnull(file2_Quantity_kg_extrapolated,0)))/sum
(isnull(file1_Quantity_kg_extrapolated,0))*-100) 
              when @Threshold_Type = 'Value'
              then  SUM
(isnull(quantity_kg_extrapolated_diff,0))
end quantity_kg_extrapolated_diff,
            CAST('' AS VARCHAR(2)) AS UP_DOWN, 'both' filecheck, sum(file1_Quantity_kg_extrapolated) file1_Quantity_kg_extrapolated, sum(file2_Quantity_kg_extrapolated) file2_Quantity_kg_extrapolated
            , packaging_activity
              INTO #all_packaging_tp_packaging_material_packaging_activity_1
        FROM #POM_COMP_arrow
        WHERE --file1_Quantity_kg_extrapolated IS NOT NULL
           -- AND file2_Quantity_kg_extrapolated IS NOT NULL
             Total_Packaging = 'Total packaging'
            and isnull(packaging_material,'')<>''
        GROUP BY organisationName, subsidiary_id,packaging_material,packaging_activity



    ---add arrow
    update a
set a.up_down = 'u'
from #all_packaging_tp_packaging_material_packaging_activity_1 a
where quantity_kg_extrapolated_diff >= @upper_threshold

    update a
set a.up_down = 'd'
from #all_packaging_tp_packaging_material_packaging_activity_1 a
where quantity_kg_extrapolated_diff <= (@lower_threshold*-1)



    --set ud when both
    update main
set main.UP_DOWN ='ud'
FROM #all_packaging_tp_packaging_material_packaging_activity_1 main
        JOIN (
    SELECT a.packaging_material, packaging_activity
        FROM #all_packaging_tp_packaging_material_packaging_activity_1 a
        WHERE up_down = 'u'
        GROUP BY a.packaging_material, packaging_activity
) AS a
        INNER JOIN (
    SELECT b.packaging_material, packaging_activity
        FROM #all_packaging_tp_packaging_material_packaging_activity_1 b
        WHERE up_down = 'd'
        GROUP BY b.packaging_material,  packaging_activity
) AS b
        ON  a.packaging_material = b.packaging_material and a.packaging_activity = b.packaging_activity
        ON  main.packaging_material = a.packaging_material and a.packaging_activity = main.packaging_activity;


    ---table used for final report
            select packaging_material, '' packaging_class, quantity_kg_extrapolated_diff, file1_quantity_kg_extrapolated, file2_quantity_kg_extrapolated, UP_DOWN , packaging_activity
        into #all_packaging_tp_packaging_material_packaging_activity_2
        from #all_packaging_tp_packaging_material_packaging_activity_1
    union all
        SELECT packaging_material, '', '', '', '', '', packaging_activity
        FROM #POM_COMP_arrow
        where isnull(packaging_material,'')<>''
        --   where packaging_class in ('Primary packaging','Secondary packaging','Shipment packaging','Online marketplace total','Tertiary packaging')
        group by packaging_material,packaging_activity




    ----------------------------------------------------------------- 
    --packaging material  hhpackaging, packaging_class - [packaging_activity]
    ----------------------------------------------------------------------
    --file 1 is null
   /*             SELECT organisationName, subsidiary_id, packaging_material,
            NULL AS quantity_kg_extrapolated_diff,
            CAST('' AS VARCHAR(2)) AS UP_DOWN, 'file1' filecheck, sum(file1_Quantity_kg_extrapolated) file1_Quantity_kg_extrapolated, sum(file2_Quantity_kg_extrapolated) file2_Quantity_kg_extrapolated
       , [packaging_activity]
        INTO #all_packaging_hh_packaging_material_packaging_activity_1
        FROM #POM_COMP_arrow
        WHERE file1_Quantity_kg_extrapolated IS NULL
            and packaging_type = 'Total Household packaging'
            and isnull(packaging_material,'')<>''
        GROUP BY organisationName, subsidiary_id,packaging_material,packaging_activity

    union all
        --file2 is null 
        SELECT organisationName, subsidiary_id, packaging_material,
            NULL, CAST('' AS VARCHAR(2)), 'file2', sum(file1_Quantity_kg_extrapolated) file1_Quantity_kg_extrapolated, sum(file2_Quantity_kg_extrapolated) file2_Quantity_kg_extrapolated
        , packaging_activity
        FROM #POM_COMP_arrow
        WHERE file2_Quantity_kg_extrapolated IS NULL
            and packaging_type = 'Total Household packaging'
            and isnull(packaging_material,'')<>''
        GROUP BY organisationName, subsidiary_id,packaging_material, packaging_activity

    union all
*/
                                SELECT organisationName, subsidiary_id, packaging_material,
            --   SUM(quantity_kg_extrapolated_diff),

            case  when @Threshold_Type = 'Percentage' and isnull(sum(isnull(file1_Quantity_kg_extrapolated,0)),0) = 0 then 0
when @Threshold_Type = 'Percentage' and isnull(sum(isnull(file2_Quantity_kg_extrapolated,0)),0) = 0 then 0
when @Threshold_Type = 'Percentage' and sum
(isnull(file1_Quantity_kg_extrapolated,0)) < sum
(isnull(file2_Quantity_kg_extrapolated,0)) 
                then
((sum
(isnull(file2_Quantity_kg_extrapolated,0))-sum
(isnull(file1_Quantity_kg_extrapolated,0)))/sum
(isnull(file1_Quantity_kg_extrapolated,0))*100)
                when @Threshold_Type = 'Percentage' and sum
(isnull(file1_Quantity_kg_extrapolated,0)) > sum
(isnull(file2_Quantity_kg_extrapolated,0)) 
              then
((sum
(isnull(file1_Quantity_kg_extrapolated,0))-sum
(isnull(file2_Quantity_kg_extrapolated,0)))/sum
(isnull(file1_Quantity_kg_extrapolated,0))*-100) 
              when @Threshold_Type = 'Value'
              then  SUM
(isnull(quantity_kg_extrapolated_diff,0))
end quantity_kg_extrapolated_diff,
            CAST('' AS VARCHAR(2)) AS UP_DOWN, 'both' filecheck, sum(file1_Quantity_kg_extrapolated) file1_Quantity_kg_extrapolated, sum(file2_Quantity_kg_extrapolated) file2_Quantity_kg_extrapolated
            , packaging_activity
              INTO #all_packaging_hh_packaging_material_packaging_activity_1
        FROM #POM_COMP_arrow
        WHERE --file1_Quantity_kg_extrapolated IS NOT NULL
           -- AND file2_Quantity_kg_extrapolated IS NOT NULL
             packaging_type = 'Total Household packaging'
            and isnull(packaging_material,'')<>''
        GROUP BY organisationName, subsidiary_id,packaging_material,packaging_activity



    ---add arrow
    update a
set a.up_down = 'u'
from #all_packaging_hh_packaging_material_packaging_activity_1 a
where quantity_kg_extrapolated_diff >= @upper_threshold

    update a
set a.up_down = 'd'
from #all_packaging_hh_packaging_material_packaging_activity_1 a
where quantity_kg_extrapolated_diff <= (@lower_threshold*-1)



    --set ud when both
    update main
set main.UP_DOWN ='ud'
FROM #all_packaging_hh_packaging_material_packaging_activity_1 main
        JOIN (
    SELECT a.packaging_material, packaging_activity
        FROM #all_packaging_hh_packaging_material_packaging_activity_1 a
        WHERE up_down = 'u'
        GROUP BY a.packaging_material, packaging_activity
) AS a
        INNER JOIN (
    SELECT b.packaging_material, packaging_activity
        FROM #all_packaging_hh_packaging_material_packaging_activity_1 b
        WHERE up_down = 'd'
        GROUP BY b.packaging_material,  packaging_activity
) AS b
        ON  a.packaging_material = b.packaging_material and a.packaging_activity = b.packaging_activity
        ON  main.packaging_material = a.packaging_material and a.packaging_activity = main.packaging_activity;


    ---table used for final report
            select packaging_material, '' packaging_class, quantity_kg_extrapolated_diff, file1_quantity_kg_extrapolated, file2_quantity_kg_extrapolated, UP_DOWN , packaging_activity
        into #all_packaging_hh_packaging_material_packaging_activity_2
        from #all_packaging_hh_packaging_material_packaging_activity_1
    union all
        SELECT packaging_material, '', '', '', '', '', packaging_activity
        FROM #POM_COMP_arrow
        where isnull(packaging_material,'')<>''
        --   where packaging_class in ('Primary packaging','Secondary packaging','Shipment packaging','Online marketplace total','Tertiary packaging')
        group by packaging_material,packaging_activity


    ----------------------------------------------------------------- 
    --packaging material  non hhpackaging, packaging_class - [packaging_activity]
    ----------------------------------------------------------------------
    --file 1 is null
 /*               SELECT organisationName, subsidiary_id, packaging_material,
            NULL AS quantity_kg_extrapolated_diff,
            CAST('' AS VARCHAR(2)) AS UP_DOWN, 'file1' filecheck, sum(file1_Quantity_kg_extrapolated) file1_Quantity_kg_extrapolated, sum(file2_Quantity_kg_extrapolated) file2_Quantity_kg_extrapolated
       , [packaging_activity]
        INTO #all_packaging_nonhh_packaging_material_packaging_activity_1
        FROM #POM_COMP_arrow
        WHERE file1_Quantity_kg_extrapolated IS NULL
            and packaging_type = 'Total Non-Household packaging'
            and isnull(packaging_material,'')<>''
        GROUP BY organisationName, subsidiary_id,packaging_material, packaging_activity

    union all
        --file2 is null 
        SELECT organisationName, subsidiary_id, packaging_material,
            NULL, CAST('' AS VARCHAR(2)), 'file2', sum(file1_Quantity_kg_extrapolated) file1_Quantity_kg_extrapolated, sum(file2_Quantity_kg_extrapolated) file2_Quantity_kg_extrapolated
        , packaging_activity
        FROM #POM_COMP_arrow
        WHERE file2_Quantity_kg_extrapolated IS NULL
            and packaging_type = 'Total Non-Household packaging'
            and isnull(packaging_material,'')<>''
        GROUP BY organisationName, subsidiary_id,packaging_material,packaging_activity

    union all
*/
                                  SELECT organisationName, subsidiary_id, packaging_material,
            --   SUM(quantity_kg_extrapolated_diff),

            case  when @Threshold_Type = 'Percentage' and isnull(sum(isnull(file1_Quantity_kg_extrapolated,0)),0) = 0 then 0
when @Threshold_Type = 'Percentage' and isnull(sum(isnull(file2_Quantity_kg_extrapolated,0)),0) = 0 then 0
when @Threshold_Type = 'Percentage' and sum
(isnull(file1_Quantity_kg_extrapolated,0)) < sum
(isnull(file2_Quantity_kg_extrapolated,0)) 
                then
((sum
(isnull(file2_Quantity_kg_extrapolated,0))-sum
(isnull(file1_Quantity_kg_extrapolated,0)))/sum
(isnull(file1_Quantity_kg_extrapolated,0))*100)
                when @Threshold_Type = 'Percentage' and sum
(isnull(file1_Quantity_kg_extrapolated,0)) > sum
(isnull(file2_Quantity_kg_extrapolated,0)) 
              then
((sum
(isnull(file1_Quantity_kg_extrapolated,0))-sum
(isnull(file2_Quantity_kg_extrapolated,0)))/sum
(isnull(file1_Quantity_kg_extrapolated,0))*-100) 
              when @Threshold_Type = 'Value'
              then  SUM
(isnull(quantity_kg_extrapolated_diff,0))
end quantity_kg_extrapolated_diff,
            CAST('' AS VARCHAR(2)) AS UP_DOWN, 'both' filecheck, sum(file1_Quantity_kg_extrapolated) file1_Quantity_kg_extrapolated, sum(file2_Quantity_kg_extrapolated) file2_Quantity_kg_extrapolated
            , packaging_activity
               INTO #all_packaging_nonhh_packaging_material_packaging_activity_1
        FROM #POM_COMP_arrow
        WHERE-- file1_Quantity_kg_extrapolated IS NOT NULL
           -- AND file2_Quantity_kg_extrapolated IS NOT NULL
             packaging_type = 'Total Non-Household packaging'
            and isnull(packaging_material,'')<>''
        GROUP BY organisationName, subsidiary_id,packaging_material, packaging_activity



    ---add arrow
    update a
set a.up_down = 'u'
from #all_packaging_nonhh_packaging_material_packaging_activity_1 a
where quantity_kg_extrapolated_diff >= @upper_threshold

    update a
set a.up_down = 'd'
from #all_packaging_nonhh_packaging_material_packaging_activity_1 a
where quantity_kg_extrapolated_diff <= (@lower_threshold*-1)



    --set ud when both
    update main
set main.UP_DOWN ='ud'
FROM #all_packaging_nonhh_packaging_material_packaging_activity_1 main
        JOIN (
    SELECT a.packaging_material, packaging_activity
        FROM #all_packaging_nonhh_packaging_material_packaging_activity_1 a
        WHERE up_down = 'u'
        GROUP BY a.packaging_material, packaging_activity
) AS a
        INNER JOIN (
    SELECT b.packaging_material, packaging_activity
        FROM #all_packaging_nonhh_packaging_material_packaging_activity_1 b
        WHERE up_down = 'd'
        GROUP BY b.packaging_material,  packaging_activity
) AS b
        ON  a.packaging_material = b.packaging_material and a.packaging_activity = b.packaging_activity
        ON  main.packaging_material = a.packaging_material and a.packaging_activity = main.packaging_activity;


    ---table used for final report
            select packaging_material, '' packaging_class, quantity_kg_extrapolated_diff, file1_quantity_kg_extrapolated, file2_quantity_kg_extrapolated, UP_DOWN , packaging_activity
        into #all_packaging_nonhh_packaging_material_packaging_activity_2
        from #all_packaging_nonhh_packaging_material_packaging_activity_1
    union all
        SELECT packaging_material, '', '', '', '', '', packaging_activity
        FROM #POM_COMP_arrow
        where isnull(packaging_material,'')<>''
        --   where packaging_class in ('Primary packaging','Secondary packaging','Shipment packaging','Online marketplace total','Tertiary packaging')
        group by packaging_material,packaging_activity




    ----------------------------------------------------------------- 
    --packaging material  reusable, packaging_class - [packaging_activity]
    ----------------------------------------------------------------------
    --file 1 is null
    /*            SELECT organisationName, subsidiary_id, packaging_material,
            NULL AS quantity_kg_extrapolated_diff,
            CAST('' AS VARCHAR(2)) AS UP_DOWN, 'file1' filecheck, sum(file1_Quantity_kg_extrapolated) file1_Quantity_kg_extrapolated, sum(file2_Quantity_kg_extrapolated) file2_Quantity_kg_extrapolated
       , [packaging_activity]
        INTO #all_packaging_totalreusable_packaging_material_packaging_activity_1
        FROM #POM_COMP_arrow
        WHERE file1_Quantity_kg_extrapolated IS NULL
            and packaging_type = 'Reusable packaging'
            and isnull(packaging_material,'')<>''
        GROUP BY organisationName, subsidiary_id,packaging_material, packaging_activity

    union all
        --file2 is null 
        SELECT organisationName, subsidiary_id, packaging_material,
            NULL, CAST('' AS VARCHAR(2)), 'file2', sum(file1_Quantity_kg_extrapolated) file1_Quantity_kg_extrapolated, sum(file2_Quantity_kg_extrapolated) file2_Quantity_kg_extrapolated
        , packaging_activity
        FROM #POM_COMP_arrow
        WHERE file2_Quantity_kg_extrapolated IS NULL
            and packaging_type = 'Reusable packaging'
            and isnull(packaging_material,'')<>''
        GROUP BY organisationName, subsidiary_id,packaging_material,packaging_activity

    union all
*/
        --both file1 and 2 have data
                    SELECT organisationName, subsidiary_id, packaging_material,
            --   SUM(quantity_kg_extrapolated_diff),

            case  when @Threshold_Type = 'Percentage' and isnull(sum(isnull(file1_Quantity_kg_extrapolated,0)),0) = 0 then 0
when @Threshold_Type = 'Percentage' and isnull(sum(isnull(file2_Quantity_kg_extrapolated,0)),0) = 0 then 0
when @Threshold_Type = 'Percentage' and sum
(isnull(file1_Quantity_kg_extrapolated,0)) < sum
(isnull(file2_Quantity_kg_extrapolated,0)) 
                then
((sum
(isnull(file2_Quantity_kg_extrapolated,0))-sum
(isnull(file1_Quantity_kg_extrapolated,0)))/sum
(isnull(file1_Quantity_kg_extrapolated,0))*100)
                when @Threshold_Type = 'Percentage' and sum
(isnull(file1_Quantity_kg_extrapolated,0)) > sum
(isnull(file2_Quantity_kg_extrapolated,0)) 
              then
((sum
(isnull(file1_Quantity_kg_extrapolated,0))-sum
(isnull(file2_Quantity_kg_extrapolated,0)))/sum
(isnull(file1_Quantity_kg_extrapolated,0))*-100) 
              when @Threshold_Type = 'Value'
              then  SUM
(isnull(quantity_kg_extrapolated_diff,0))
end quantity_kg_extrapolated_diff,
            CAST('' AS VARCHAR(2)) AS UP_DOWN, 'both' filecheck, sum(file1_Quantity_kg_extrapolated) file1_Quantity_kg_extrapolated, sum(file2_Quantity_kg_extrapolated) file2_Quantity_kg_extrapolated
            , packaging_activity
              INTO #all_packaging_totalreusable_packaging_material_packaging_activity_1
        FROM #POM_COMP_arrow
        WHERE --file1_Quantity_kg_extrapolated IS NOT NULL
           -- AND file2_Quantity_kg_extrapolated IS NOT NULL
             packaging_type = 'Reusable packaging'
            and isnull(packaging_material,'')<>''
        GROUP BY organisationName, subsidiary_id,packaging_material, packaging_activity



    ---add arrow
    update a
set a.up_down = 'u'
from #all_packaging_totalreusable_packaging_material_packaging_activity_1 a
where quantity_kg_extrapolated_diff >= @upper_threshold

    update a
set a.up_down = 'd'
from #all_packaging_totalreusable_packaging_material_packaging_activity_1 a
where quantity_kg_extrapolated_diff <= (@lower_threshold*-1)



    --set ud when both
    update main
set main.UP_DOWN ='ud'
FROM #all_packaging_totalreusable_packaging_material_packaging_activity_1 main
        JOIN (
    SELECT a.packaging_material, packaging_activity
        FROM #all_packaging_totalreusable_packaging_material_packaging_activity_1 a
        WHERE up_down = 'u'
        GROUP BY a.packaging_material, packaging_activity
) AS a
        INNER JOIN (
    SELECT b.packaging_material, packaging_activity
        FROM #all_packaging_totalreusable_packaging_material_packaging_activity_1 b
        WHERE up_down = 'd'
        GROUP BY b.packaging_material,  packaging_activity
) AS b
        ON  a.packaging_material = b.packaging_material and a.packaging_activity = b.packaging_activity
        ON  main.packaging_material = a.packaging_material and a.packaging_activity = main.packaging_activity;


    ---table used for final report
            select packaging_material, '' packaging_class, quantity_kg_extrapolated_diff, file1_quantity_kg_extrapolated, file2_quantity_kg_extrapolated, UP_DOWN , packaging_activity
        into #all_packaging_totalreusable_packaging_material_packaging_activity_2
        from #all_packaging_totalreusable_packaging_material_packaging_activity_1
    union all
        SELECT packaging_material, '', '', '', '', '', packaging_activity
        FROM #POM_COMP_arrow
        where isnull(packaging_material,'')<>''
        group by packaging_material,packaging_activity


   


    ----------------------------------------------------------------- 
    --packaging material online, online 
    ----------------------------------------------------------------------
    --file 1 is null
    /*            SELECT organisationName, subsidiary_id, packaging_material, packaging_class,
            NULL AS quantity_kg_extrapolated_diff,
            CAST('' AS VARCHAR(2)) AS UP_DOWN, 'file1' filecheck, sum(file1_Quantity_kg_extrapolated) file1_Quantity_kg_extrapolated, sum(file2_Quantity_kg_extrapolated) file2_Quantity_kg_extrapolated

        INTO #all_packaging_online_marketplace_1
        FROM #POM_COMP_arrow
        WHERE file1_Quantity_kg_extrapolated IS NULL
            and packaging_type = 'Total Household packaging'
            and packaging_class = 'Online marketplace total'
            and isnull(packaging_material,'')<>''
        GROUP BY organisationName, subsidiary_id,packaging_material, packaging_class

    union all
        --file2 is null 
        SELECT organisationName, subsidiary_id, packaging_material, packaging_class,
            NULL, CAST('' AS VARCHAR(2)), 'file2', sum(file1_Quantity_kg_extrapolated) file1_Quantity_kg_extrapolated, sum(file2_Quantity_kg_extrapolated) file2_Quantity_kg_extrapolated
        FROM #POM_COMP_arrow
        WHERE file2_Quantity_kg_extrapolated IS NULL
            and packaging_type = 'Total Household packaging'
            and packaging_class = 'Online marketplace total'
            and isnull(packaging_material,'')<>''
        GROUP BY organisationName, subsidiary_id,packaging_material, packaging_class

    union all
*/
        --both file1 and 2 have data
              SELECT organisationName, subsidiary_id, packaging_material,packaging_class,
            --   SUM(quantity_kg_extrapolated_diff),

            case  when @Threshold_Type = 'Percentage' and isnull(sum(isnull(file1_Quantity_kg_extrapolated,0)),0) = 0 then 0
when @Threshold_Type = 'Percentage' and isnull(sum(isnull(file2_Quantity_kg_extrapolated,0)),0) = 0 then 0
when @Threshold_Type = 'Percentage' and sum
(isnull(file1_Quantity_kg_extrapolated,0)) < sum
(isnull(file2_Quantity_kg_extrapolated,0)) 
                then
((sum
(isnull(file2_Quantity_kg_extrapolated,0))-sum
(isnull(file1_Quantity_kg_extrapolated,0)))/sum
(isnull(file1_Quantity_kg_extrapolated,0))*100)
                when @Threshold_Type = 'Percentage' and sum
(isnull(file1_Quantity_kg_extrapolated,0)) > sum
(isnull(file2_Quantity_kg_extrapolated,0)) 
              then
((sum
(isnull(file1_Quantity_kg_extrapolated,0))-sum
(isnull(file2_Quantity_kg_extrapolated,0)))/sum
(isnull(file1_Quantity_kg_extrapolated,0))*-100) 
              when @Threshold_Type = 'Value'
              then  SUM
(isnull(quantity_kg_extrapolated_diff,0))
end quantity_kg_extrapolated_diff,
            CAST('' AS VARCHAR(2)) AS UP_DOWN, 'both' filecheck, sum(file1_Quantity_kg_extrapolated) file1_Quantity_kg_extrapolated, sum(file2_Quantity_kg_extrapolated) file2_Quantity_kg_extrapolated
          into   #all_packaging_online_marketplace_1
        FROM #POM_COMP_arrow
        WHERE --file1_Quantity_kg_extrapolated IS NOT NULL
            -- file2_Quantity_kg_extrapolated IS NOT NULL
             packaging_type = 'Total Household packaging'
            and packaging_class = 'Online Marketplace'
            and isnull(packaging_material,'')<>''
        GROUP BY organisationName, subsidiary_id,packaging_material, packaging_class,packaging_activity



    ---add arrow
    update a
set a.up_down = 'u'
from #all_packaging_online_marketplace_1 a
where quantity_kg_extrapolated_diff >= @upper_threshold

    update a
set a.up_down = 'd'
from #all_packaging_online_marketplace_1 a
where quantity_kg_extrapolated_diff <= (@lower_threshold*-1)



    --set ud when both
    update main
set main.UP_DOWN ='ud'
FROM #all_packaging_online_marketplace_1 main
        JOIN (
    SELECT a.packaging_material, a.packaging_class
        FROM #all_packaging_online_marketplace_1 a
        WHERE up_down = 'u'
        GROUP BY a.packaging_material, a.packaging_class
) AS a
        INNER JOIN (
    SELECT b.packaging_material, b.packaging_class
        FROM #all_packaging_online_marketplace_1 b
        WHERE up_down = 'd'
        GROUP BY b.packaging_material, b.packaging_class
) AS b
        ON a.packaging_class = b.packaging_class AND a.packaging_material = b.packaging_material
        ON main.packaging_class = a.packaging_class AND main.packaging_material = a.packaging_material
    ;


    ---table used for final report
            select packaging_material, packaging_class, quantity_kg_extrapolated_diff, file1_quantity_kg_extrapolated, file2_quantity_kg_extrapolated, UP_DOWN
        into #all_packaging_online_marketplace_2
        from #all_packaging_online_marketplace_1
    union all
        SELECT packaging_material, packaging_class, '', '', '', ''
        FROM #POM_COMP_arrow
        where  packaging_class = 'Online marketplace total'
            and isnull(packaging_material,'')<>''
        group by packaging_material,packaging_class

select packaging_material, from_nation, '' relative_move, ''packaging_class, file1_quantity_kg_extrapolated, file2_quantity_kg_extrapolated, up_down, 'smcw_pm_fn' breakdown_flag, cAST('' AS VARCHAR(2)) AS TOTAL_UP_DOWN, ''file2_quantity_unit, ''packaging_activity
        into #POMCOMP_output
        from #self_management_consumer_waste_packaging_material_from_nation_2
    union all
        select packaging_material, '', relative_move, '', file1_quantity_kg_extrapolated, file2_quantity_kg_extrapolated, up_down, 'smcw_pm_rm', cAST('' AS VARCHAR(2)) AS TOTAL_UP_DOWN, ''file2_quantity_unit, ''packaging_activity
        from #self_management_consumer_waste_packaging_material_relative_move_2
    union all
        select packaging_material, from_nation, '' relative_move, '', file1_quantity_kg_extrapolated, file2_quantity_kg_extrapolated, up_down, 'smow_pm_fn' breakdown_flag, cAST('' AS VARCHAR(2)) AS TOTAL_UP_DOWN, ''file2_quantity_unit, ''packaging_activity
        from #self_management_organisation_waste_packaging_material_from_nation_2
    union all
        select packaging_material, '', relative_move, '', file1_quantity_kg_extrapolated, file2_quantity_kg_extrapolated, up_down, 'smow_pm_rm', cAST('' AS VARCHAR(2)) AS TOTAL_UP_DOWN, ''file2_quantity_unit, ''packaging_activity
        from #self_management_organisation_waste_packaging_material_relative_move_2
    union all
        select packaging_material, '' from_nation, '' relative_move, packaging_class, file1_quantity_kg_extrapolated, file2_quantity_kg_extrapolated, up_down, 'all_pm_hh_pc', cAST('' AS VARCHAR(2)) AS TOTAL_UP_DOWN, ''file2_quantity_unit, ''packaging_activity
        from #all_packaging_household_packaging_material_packaging_class_2
    union all
        select packaging_material, '' from_nation, '' relative_move, packaging_class, file1_quantity_kg_extrapolated, file2_quantity_kg_extrapolated, up_down, 'all_pm_non_hh_pc', cAST('' AS VARCHAR(2)) AS TOTAL_UP_DOWN, ''file2_quantity_unit, ''packaging_activity
        from #all_packaging_Non_household_packaging_material_packaging_class_2
    union all
        select packaging_material, '' from_nation, '' relative_move, ''packaging_class, file1_quantity_kg_extrapolated, file2_quantity_kg_extrapolated, up_down, 'all_pm_hh_drinks', cAST('' AS VARCHAR(2)) AS TOTAL_UP_DOWN, file2_quantity_unit, ''packaging_activity
        from #all_packaging_household_drinks_material_2
    union all
        select packaging_material, '' from_nation, '' relative_move, ''packaging_class, file1_quantity_kg_extrapolated, file2_quantity_kg_extrapolated, up_down, 'all_pm_non_hh_drinks', cAST('' AS VARCHAR(2)) AS TOTAL_UP_DOWN, file2_quantity_unit, ''packaging_activity
        from #all_packaging_non_household_drinks_material_2
    union all
        select packaging_material, '' from_nation, '' relative_move, ''packaging_class, file1_quantity_kg_extrapolated, file2_quantity_kg_extrapolated, up_down, 'all_pm_drinks', cAST('' AS VARCHAR(2)) AS TOTAL_UP_DOWN, file2_quantity_unit, ''packaging_activity
        from #all_packaging_drinks_material_2
    union all
        select packaging_material, '' from_nation, '' relative_move, packaging_class, file1_quantity_kg_extrapolated, file2_quantity_kg_extrapolated, up_down, 'all_pm_reusable', cAST('' AS VARCHAR(2)) AS TOTAL_UP_DOWN, ''file2_quantity_unit, ''packaging_activity
        from #all_packaging_material_reusable2
    union all
        select packaging_material, '' from_nation, '' relative_move, ''packaging_class, file1_quantity_kg_extrapolated, file2_quantity_kg_extrapolated, up_down, 'all_pm_TP', cAST('' AS VARCHAR(2)) AS TOTAL_UP_DOWN, ''file2_quantity_unit, ''packaging_activity
        from #all_packaging_material_TP2
    union all
        select packaging_material, '' from_nation, '' relative_move, ''packaging_class, file1_quantity_kg_extrapolated, file2_quantity_kg_extrapolated, up_down, 'all_pm_Thh', cAST('' AS VARCHAR(2)) AS TOTAL_UP_DOWN, ''file2_quantity_unit, ''packaging_activity
        from #all_packaging_material_Thh2
    union all
        select packaging_material, '' from_nation, '' relative_move, ''packaging_class, file1_quantity_kg_extrapolated, file2_quantity_kg_extrapolated, up_down, 'all_pm_Tnhh', cAST('' AS VARCHAR(2)) AS TOTAL_UP_DOWN, ''file2_quantity_unit, ''packaging_activity
        from #all_packaging_material_Tnhh2
    union all
        select packaging_material, '' from_nation, '' relative_move, ''packaging_class, file1_quantity_kg_extrapolated, file2_quantity_kg_extrapolated, up_down, 'all_pm_TReusable', cAST('' AS VARCHAR(2)) AS TOTAL_UP_DOWN, ''file2_quantity_unit, ''packaging_activity
        from #all_packaging_material_total_reusable2
    union all
        select packaging_material, '' from_nation, '' relative_move, packaging_class, file1_quantity_kg_extrapolated, file2_quantity_kg_extrapolated, up_down, 'all_pm_hh_pa', cAST('' AS VARCHAR(2)) AS TOTAL_UP_DOWN, ''file2_quantity_unit, packaging_activity
        from #all_packaging_household_packaging_material_packaging_activity_2
    union all
        select packaging_material, '' from_nation, '' relative_move, packaging_class, file1_quantity_kg_extrapolated, file2_quantity_kg_extrapolated, up_down, 'all_pm_pb_pa', cAST('' AS VARCHAR(2)) AS TOTAL_UP_DOWN, ''file2_quantity_unit, packaging_activity
        from #all_packaging_pb_packaging_material_packaging_activity_2
    union all
        select packaging_material, '' from_nation, '' relative_move, packaging_class, file1_quantity_kg_extrapolated, file2_quantity_kg_extrapolated, up_down, 'all_pm_tnh_pa', cAST('' AS VARCHAR(2)) AS TOTAL_UP_DOWN, ''file2_quantity_unit, packaging_activity
        from #all_packaging_tnh_packaging_material_packaging_activity_2
    union all
        select packaging_material, '' from_nation, '' relative_move, ''packaging_class, file1_quantity_kg_extrapolated, file2_quantity_kg_extrapolated, up_down, 'all_pm_pa_HH_drinks', cAST('' AS VARCHAR(2)) AS TOTAL_UP_DOWN, file2_quantity_unit, packaging_activity
        from #all_packaging_household_drinks_material_packaging_activity_2
    union all
        select packaging_material, '' from_nation, '' relative_move, ''packaging_class, file1_quantity_kg_extrapolated, file2_quantity_kg_extrapolated, up_down, 'all_pm_pa_nHH_drinks', cAST('' AS VARCHAR(2)) AS TOTAL_UP_DOWN, file2_quantity_unit, packaging_activity
        from #all_packaging_nonhousehold_drinks_material_packaging_activity_2
    union all
        select packaging_material, '' from_nation, '' relative_move, ''packaging_class, file1_quantity_kg_extrapolated, file2_quantity_kg_extrapolated, up_down, 'all_pm_pa_all_drinks', cAST('' AS VARCHAR(2)) AS TOTAL_UP_DOWN, file2_quantity_unit, packaging_activity
        from #all_packaging_all_drinks_material_packaging_activity_2
    union all
        select packaging_material, '' from_nation, '' relative_move, ''packaging_class, file1_quantity_kg_extrapolated, file2_quantity_kg_extrapolated, up_down, 'all_pm_pa_reusable', cAST('' AS VARCHAR(2)) AS TOTAL_UP_DOWN, ''file2_quantity_unit, packaging_activity
        from #all_packaging_reusable_packaging_material_packaging_activity_2
    union all
        select packaging_material, '' from_nation, '' relative_move, ''packaging_class, file1_quantity_kg_extrapolated, file2_quantity_kg_extrapolated, up_down, 'all_pm_pa_tp', cAST('' AS VARCHAR(2)) AS TOTAL_UP_DOWN, ''file2_quantity_unit, packaging_activity
        from #all_packaging_tp_packaging_material_packaging_activity_2
    union all
        select packaging_material, '' from_nation, '' relative_move, ''packaging_class, file1_quantity_kg_extrapolated, file2_quantity_kg_extrapolated, up_down, 'all_pm_pa_total_hh', cAST('' AS VARCHAR(2)) AS TOTAL_UP_DOWN, ''file2_quantity_unit, packaging_activity
        from #all_packaging_hh_packaging_material_packaging_activity_2
    union all
        select packaging_material, '' from_nation, '' relative_move, ''packaging_class, file1_quantity_kg_extrapolated, file2_quantity_kg_extrapolated, up_down, 'all_pm_pa_total_nonhh', cAST('' AS VARCHAR(2)) AS TOTAL_UP_DOWN, ''file2_quantity_unit, packaging_activity
        from #all_packaging_nonhh_packaging_material_packaging_activity_2
    union all
        select packaging_material, '' from_nation, '' relative_move, ''packaging_class, file1_quantity_kg_extrapolated, file2_quantity_kg_extrapolated, up_down, 'all_pm_pa_total_reusable', cAST('' AS VARCHAR(2)) AS TOTAL_UP_DOWN, ''file2_quantity_unit, packaging_activity
        from #all_packaging_totalreusable_packaging_material_packaging_activity_2
    union all
        select packaging_material, '' from_nation, '' relative_move, packaging_class, file1_quantity_kg_extrapolated, file2_quantity_kg_extrapolated, up_down, 'all_pm_online', cAST('' AS VARCHAR(2)) AS TOTAL_UP_DOWN, ''file2_quantity_unit, ''packaging_activity
        from #all_packaging_online_marketplace_2

--TOTAL CALCS


    select packaging_material, from_nation, relative_move, packaging_class, sum(file1_Quantity_kg_extrapolated)file1_Quantity_kg_extrapolated,

        sum(file2_Quantity_kg_extrapolated)file2_Quantity_kg_extrapolated ,

        case when 
       -- @Threshold_Type = 'Percentage' and 
        isnull(sum(file1_Quantity_kg_extrapolated),0) = 0 then 0
when 
--@Threshold_Type = 'Percentage' and
 isnull(sum(file2_Quantity_kg_extrapolated),0) = 0 then 0
 when @Threshold_Type = 'Percentage' and sum
(file1_Quantity_kg_extrapolated) < sum
(file2_Quantity_kg_extrapolated) 
                then
((sum
(file2_Quantity_kg_extrapolated)-sum
(file1_Quantity_kg_extrapolated))/sum
(file1_Quantity_kg_extrapolated)*100)
                when @Threshold_Type = 'Percentage' and sum
(file1_Quantity_kg_extrapolated) > sum
(file2_Quantity_kg_extrapolated) 
              then
((sum
(file1_Quantity_kg_extrapolated)-sum
(file2_Quantity_kg_extrapolated))/sum
(file1_Quantity_kg_extrapolated)*-100) 
              when @Threshold_Type = 'Value'
              then sum(file2_Quantity_kg_extrapolated) - sum(file1_Quantity_kg_extrapolated) end quantity_kg_extrapolated_diff, CAST('' AS VARCHAR(2)) AS UP_DOWN,
        breakdown_flag
    into #totals1
    from #POMCOMP_output
    group by packaging_material,from_nation, relative_move,packaging_class,breakdown_flag



    ---add arrow
    update a
set a.up_down = 'u'
from #totals1 a
where quantity_kg_extrapolated_diff >= @upper_threshold

    update a
set a.up_down = 'd'
from #totals1 a
where quantity_kg_extrapolated_diff <= (@lower_threshold*-1)


    -----------------------------------------

    --set ud when theere is up and down movement over thresholds - 'smcw_pm_fn'
    UPDATE main
SET main.up_down = 'ud'
from #totals1 main
        INNER JOIN (
    SELECT a.packaging_material, a.breakdown_flag
        FROM #totals1 a
        WHERE a.up_down = 'u'
            and a.breakdown_flag = 'smcw_pm_fn'
        GROUP BY a.packaging_material, a.breakdown_flag
) AS a
        ON main.packaging_material = a.packaging_material
            AND main.breakdown_flag = a.breakdown_flag


        INNER JOIN (
    SELECT b.packaging_material, b.breakdown_flag
        FROM #totals1 b
        WHERE b.up_down = 'd'
            and b.breakdown_flag = 'smcw_pm_fn'
        GROUP BY b.packaging_material, b.breakdown_flag
) AS b
        ON main.packaging_material = b.packaging_material
            AND main.breakdown_flag = b.breakdown_flag


    --set ud when both - 'smcw_pm_rm'
    UPDATE main
SET main.up_down = 'ud'
from #totals1 main
        INNER JOIN (
    SELECT a.packaging_material, a.breakdown_flag, left(a.relative_move,6) relative_move
        FROM #totals1 a
        WHERE a.up_down = 'u'
            and a.breakdown_flag = 'smcw_pm_rm'
        GROUP BY a.packaging_material, a.breakdown_flag,left(a.relative_move,6)
) AS a
        ON main.packaging_material = a.packaging_material
            AND main.breakdown_flag = a.breakdown_flag
            and left(main.relative_move,6) = left(a.relative_move,6)

        INNER JOIN (
    SELECT b.packaging_material, b.breakdown_flag, left(b.relative_move,6) relative_move
        FROM #totals1 b
        WHERE b.up_down = 'd'
            and b.breakdown_flag = 'smcw_pm_rm'
        GROUP BY b.packaging_material, b.breakdown_flag, left(b.relative_move,6)
) AS b
        ON main.packaging_material = b.packaging_material
            AND main.breakdown_flag = b.breakdown_flag
            and left(main.relative_move,6) = left(b.relative_move,6)

    ------------------------------------

    --set ud when theere is up and down movement over thresholds - 'smow_pm_fn'
    UPDATE main
SET main.up_down = 'ud'
from #totals1 main
        INNER JOIN (
    SELECT a.packaging_material, a.breakdown_flag
        FROM #totals1 a
        WHERE a.up_down = 'u'
            and a.breakdown_flag = 'smow_pm_fn'
        GROUP BY a.packaging_material, a.breakdown_flag
) AS a
        ON main.packaging_material = a.packaging_material
            AND main.breakdown_flag = a.breakdown_flag


        INNER JOIN (
    SELECT b.packaging_material, b.breakdown_flag
        FROM #totals1 b
        WHERE b.up_down = 'd'
            and b.breakdown_flag = 'smow_pm_fn'
        GROUP BY b.packaging_material, b.breakdown_flag
) AS b
        ON main.packaging_material = b.packaging_material
            AND main.breakdown_flag = b.breakdown_flag


    --set ud when both - 'smow_pm_rm'
    UPDATE main
SET main.up_down = 'ud'
from #totals1 main
        INNER JOIN (
    SELECT a.packaging_material, a.breakdown_flag, left(a.relative_move,6) relative_move
        FROM #totals1 a
        WHERE a.up_down = 'u'
            and a.breakdown_flag = 'smow_pm_rm'
        GROUP BY a.packaging_material, a.breakdown_flag,left(a.relative_move,6)
) AS a
        ON main.packaging_material = a.packaging_material
            AND main.breakdown_flag = a.breakdown_flag
            and left(main.relative_move,6) = left(a.relative_move,6)

        INNER JOIN (
    SELECT b.packaging_material, b.breakdown_flag, left(b.relative_move,6) relative_move
        FROM #totals1 b
        WHERE b.up_down = 'd'
            and b.breakdown_flag = 'smow_pm_rm'
        GROUP BY b.packaging_material, b.breakdown_flag, left(b.relative_move,6)
) AS b
        ON main.packaging_material = b.packaging_material
            AND main.breakdown_flag = b.breakdown_flag
            and left(main.relative_move,6) = left(b.relative_move,6)




    --set ud when there is up and down movement over thresholds - 'all_pm_hh_pc'
    UPDATE main
SET main.up_down = 'ud'
from #totals1 main
        INNER JOIN (
    SELECT a.packaging_material, a.breakdown_flag
        FROM #totals1 a
        WHERE a.up_down = 'u'
            and a.breakdown_flag = 'all_pm_hh_pc'
        GROUP BY a.packaging_material, a.breakdown_flag
) AS a
        ON main.packaging_material = a.packaging_material
            AND main.breakdown_flag = a.breakdown_flag


        INNER JOIN (
    SELECT b.packaging_material, b.breakdown_flag
        FROM #totals1 b
        WHERE b.up_down = 'd'
            and b.breakdown_flag = 'all_pm_hh_pc'
        GROUP BY b.packaging_material, b.breakdown_flag
) AS b
        ON main.packaging_material = b.packaging_material
            AND main.breakdown_flag = b.breakdown_flag


    --set ud when there is up and down movement over thresholds - 'all_pm_hh_pc'
    UPDATE main
SET main.up_down = 'ud'
from #totals1 main
        INNER JOIN (
    SELECT a.packaging_material, a.breakdown_flag
        FROM #totals1 a
        WHERE a.up_down = 'u'
            and a.breakdown_flag = 'all_pm_non_hh_pc'
        GROUP BY a.packaging_material, a.breakdown_flag
) AS a
        ON main.packaging_material = a.packaging_material
            AND main.breakdown_flag = a.breakdown_flag


        INNER JOIN (
    SELECT b.packaging_material, b.breakdown_flag
        FROM #totals1 b
        WHERE b.up_down = 'd'
            and b.breakdown_flag = 'all_pm_non_hh_pc'
        GROUP BY b.packaging_material, b.breakdown_flag
) AS b
        ON main.packaging_material = b.packaging_material
            AND main.breakdown_flag = b.breakdown_flag

    --set ud when there is up and down movement over thresholds - 'all_pm_hh_pc'
    UPDATE main
SET main.up_down = 'ud'
from #totals1 main
        INNER JOIN (
    SELECT a.packaging_material, a.breakdown_flag
        FROM #totals1 a
        WHERE a.up_down = 'u'
            and a.breakdown_flag = 'all_pm_hh_drinks'
        GROUP BY a.packaging_material, a.breakdown_flag
) AS a
        ON main.packaging_material = a.packaging_material
            AND main.breakdown_flag = a.breakdown_flag


        INNER JOIN (
    SELECT b.packaging_material, b.breakdown_flag
        FROM #totals1 b
        WHERE b.up_down = 'd'
            and b.breakdown_flag = 'all_pm_hh_drinks'
        GROUP BY b.packaging_material, b.breakdown_flag
) AS b
        ON main.packaging_material = b.packaging_material
            AND main.breakdown_flag = b.breakdown_flag


    ---TOTALS UPDATE

    update a
set a.TOTAL_UP_DOWN = b.up_down
from #POMCOMP_output a
        join #totals1 b on a.packaging_material = b.packaging_material and a.breakdown_flag = b.breakdown_flag
where b.breakdown_flag = 'smcw_pm_fn'

    update a
set a.TOTAL_UP_DOWN = b.up_down
from #POMCOMP_output a
        join #totals1 b on a.packaging_material = b.packaging_material and a.breakdown_flag = b.breakdown_flag and left(a.relative_move,6) = left(b.relative_move,6)
where b.breakdown_flag = 'smcw_pm_rm'

    update a
set a.TOTAL_UP_DOWN = b.up_down
from #POMCOMP_output a
        join #totals1 b on a.packaging_material = b.packaging_material and a.breakdown_flag = b.breakdown_flag
where b.breakdown_flag = 'smow_pm_fn'

    update a
set a.TOTAL_UP_DOWN = b.up_down
from #POMCOMP_output a
        join #totals1 b on a.packaging_material = b.packaging_material and a.breakdown_flag = b.breakdown_flag and left(a.relative_move,6) = left(b.relative_move,6)
where b.breakdown_flag = 'smow_pm_rm'


    update a
set a.TOTAL_UP_DOWN = b.up_down
from #POMCOMP_output a
        join #totals1 b on a.packaging_material = b.packaging_material and a.breakdown_flag = b.breakdown_flag 
where b.breakdown_flag = 'all_pm_hh_pc'

    update a
set a.TOTAL_UP_DOWN = b.up_down
from #POMCOMP_output a
        join #totals1 b on a.packaging_material = b.packaging_material and a.breakdown_flag = b.breakdown_flag 
where b.breakdown_flag = 'all_pm_non_hh_pc'

	 --remove dupe null lines

	 --delete from #POMCOMP_output where file1_quantity_kg_extrapolated = 0 and file2_quantity_kg_extrapolated =0 and up_down = ''



    -------------------------------------------
    -- OUTPUT TABLE USED FOR PAGINATED REPORT -
    -------------------------------------------
   
    select *, @filename1 filename1, @filename2 filename2, @ProducerCS producerCS, @organisation_id organisation_id, @compliance_scheme compliance_scheme, @securityquery securityquery
    from #POMCOMP_output


END;