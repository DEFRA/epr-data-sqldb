CREATE PROC [dbo].[POM_Comparison_ARROW_LOGIC] @filename1 [nvarchar](4000),@filename2 [nvarchar](4000),@ProducerCS [nvarchar](100),@OrganisationID [int],@compliance_scheme [nvarchar](200),@securityquery [nvarchar](200),@Upper_Threshold [int],@Lower_Threshold [int],@Threshold_Type [nvarchar](100) AS


BEGIN


   SELECT 
 [OrganisationID],
 [subsidiary_id],
 [organisation_size],
 [submission_period],
 [packaging_activity],
 [packaging_type],
 [packaging_class],
 [packaging_material],
 [packaging_sub_material],
 [from_nation],
 [to_nation],
 [quantity_kg],
 [quantity_unit],
 [FileName],
 [Quantity_kg_extrapolated],
 [Quantity_units_extrapolated],
 [relative_move],
 submission_date,
 org_sub_type,
 org_name,
 compliance_scheme,
 registration_type_code
 into #file1
    FROM [dbo].[t_POM_Submissions_POM_Comparison]
    WHERE nation = @securityquery
        AND FileName = @filename1
        AND (
            (@producerCS = 'Producer' AND [OrganisationID] = @OrganisationID)
            OR
            (@producerCS = 'Compliance Scheme' AND compliance_scheme = @compliance_scheme AND data_type = 'Member')
        )

SELECT 
	[OrganisationID],
	[subsidiary_id],
	[organisation_size],
	[submission_period],
	[packaging_activity],
	[packaging_type],
	[packaging_class],
	[packaging_material],
	[packaging_sub_material],
	[from_nation],
	[to_nation],
	[quantity_kg],
	[quantity_unit],
	[FileName],
	[Quantity_kg_extrapolated],
	[Quantity_units_extrapolated],
	[relative_move],
	submission_date,
	org_sub_type,
	org_name,
	compliance_scheme,
	registration_type_code
	into #file2
FROM [dbo].[t_POM_Submissions_POM_Comparison]
WHERE nation = @securityquery
        AND FileName = @filename2
        AND (
            (@producerCS = 'Producer' AND [OrganisationID] = @OrganisationID)
            OR
            (@producerCS = 'Compliance Scheme' AND compliance_scheme = @compliance_scheme AND data_type = 'Member')
        )


	



    SELECT a.OrganisationID
	into #matching_orgs
    FROM #file1 a
    INNER JOIN #file2 b ON a.OrganisationID = b.OrganisationID
    WHERE a.organisation_size = b.organisation_size;

    SELECT 
        COALESCE(a.[OrganisationID], b.[OrganisationID]) AS OrganisationName,
		COALESCE(a.[subsidiary_id], b.[subsidiary_id]) AS [subsidiary_id],
        COALESCE(a.packaging_material, b.packaging_material) AS packaging_material,
        COALESCE(a.[from_nation], b.[from_nation]) AS [from_nation],
        COALESCE(a.packaging_activity, b.packaging_activity) AS packaging_activity,
        COALESCE(a.packaging_class, b.packaging_class) AS packaging_class,
        COALESCE(a.packaging_sub_material, b.packaging_sub_material) AS packaging_sub_material,
        COALESCE(a.to_nation, b.to_nation) AS to_nation,
        COALESCE(a.relative_move, b.relative_move) AS relative_move,
        COALESCE(a.packaging_type, b.packaging_type) AS packaging_type,
        a.quantity_kg AS file1_quantity_kg,
        b.quantity_kg AS file2_quantity_kg,
        a.quantity_unit AS file1_quantity_unit,
        b.quantity_unit AS file2_quantity_unit,
        a.Quantity_kg_extrapolated AS file1_Quantity_kg_extrapolated,
        b.Quantity_kg_extrapolated AS file2_Quantity_kg_extrapolated,
        ISNULL(b.quantity_kg, '0') - ISNULL(a.quantity_kg, '0') AS quantity_kg_diff,
        ISNULL(b.quantity_unit, '0') - ISNULL(a.quantity_unit, '0') AS quantity_unit_diff,
        ISNULL(b.Quantity_kg_extrapolated, '0') - ISNULL(a.Quantity_kg_extrapolated, 0) AS Quantity_kg_extrapolated_diff,
        ISNULL(b.Quantity_units_extrapolated, '0') - ISNULL(a.Quantity_units_extrapolated, '0') AS Quantity_units_extrapolated_diff,
        a.filename AS filename1,
        b.filename AS filename2,
        a.submission_date AS file1_submission_date,
        b.submission_date AS file2_submission_date,
        COALESCE(a.org_sub_type, b.org_sub_type) AS org_sub_type,
		COALESCE(a.org_name, b.org_name) AS org_name,
        COALESCE(a.organisation_size, b.organisation_size) AS organisation_size,
        COALESCE(a.compliance_scheme, b.compliance_scheme) AS compliance_scheme,
        COALESCE(a.registration_type_code, b.registration_type_code) AS registration_type_code
		into #file_joined
    FROM #file1 a
    FULL OUTER JOIN #file2 b ON ISNULL(a.[OrganisationID], '') = ISNULL(b.[OrganisationID], '')
							AND a.[OrganisationID] IN (SELECT OrganisationID FROM #matching_orgs)
							AND ISNULL(a.[subsidiary_id], '') = ISNULL(b.[subsidiary_id], '') 
							AND ISNULL(a.[packaging_activity], '') = ISNULL(b.packaging_activity, '')
							AND ISNULL(a.[packaging_type],'') = isnull(b.packaging_type,'')
							AND ISNULL(a.[packaging_class],'') =isnull(b.packaging_class,'')
							AND ISNULL(a.[packaging_material],'') = isnull(b.packaging_material,'')
							AND ISNULL(a.[packaging_sub_material],'') = isnull(b.packaging_sub_material,'')
							AND ISNULL(a.[from_nation],'') = isnull(b.from_nation,'')
							AND ISNULL(a.[to_nation],'') = isnull(b.to_nation,'')


			SELECT 
			    *,
			    CASE 
			        WHEN packaging_type IN 
											(
												'Total Non-Household packaging',
												'Total Household packaging',
												'Public binned',
												'Reusable packaging',
												'Household drinks containers',
												'Non-household drinks containers'
											) THEN 'Total Packaging' 
				ELSE NULL END AS Total_Packaging
				
			INTO #POM_COMP_arrow
			FROM #file_joined
			
			
			UNION ALL
			
			SELECT distinct
				''orgname,
				''subid,
				d.[packaging_material],
				f.[from_nation],
				''[packaging_activity],
				''[packaging_class],
				''[packaging_sub_material],
				''[to_nation],
				h.[relative_move],
				'Self-managed consumer waste' [packaging_type],
				'' file1kg,
				'' file2kg,
				'' file1q,
				'' file2q,
				'' file1kge,
				'' file2kge,
				'' quanitykgdiff,
				'' quantitykgediff,
				'' qu,
				'' wudiff,
				'' fname1,
				'' fname2,
				'' fsubd,
				'' f2subd,
				'' org_sub_type,
				'' org_name,
				'' orgsize,
				'' cs,
				'' rt,
				'' tp
				
			FROM 
				(SELECT [packaging_material] FROM [dbo].[t_POM] GROUP BY [packaging_material]) d
			CROSS JOIN
			   (SELECT [from_nation] FROM [dbo].[t_POM] GROUP BY [from_nation]) f
			CROSS JOIN 
				(SELECT [relative_move] FROM [dbo].[t_POM] GROUP BY [relative_move]) h
			UNION ALL
			SELECT distinct
				''orgname,
				''subid,
				d.[packaging_material],
				f.[from_nation],
				''[packaging_activity],
				''[packaging_class],
				''[packaging_sub_material],
				''[to_nation],
				h.[relative_move],
				'Self-managed organisation waste' [packaging_type],
				'' file1kg,
				''file2kg,
				''file1q,
				''file2q,
				''file1kge,
				''file2kge,
				''quanitykgdiff,
				''quantitykgediff,
				''qu,
				''wudiff,
				''fname1,
				''fname2,
				''fsubd,
				''f2subd,
				''org_sub_type,
				''org_name,
				''orgsize,
				''cs,
				''rt,
				''tp
				
			FROM 
				(SELECT [packaging_material] FROM [dbo].[t_POM] GROUP BY [packaging_material]) d
			CROSS JOIN
			   (SELECT [from_nation] FROM [dbo].[t_POM] GROUP BY [from_nation]) f
			CROSS JOIN 
				(SELECT [relative_move] FROM [dbo].[t_POM] GROUP BY [relative_move]) h
			UNION ALL
			SELECT distinct
				''orgname,
				''subid,
				d.[packaging_material],
				'' [from_nation],
				''[packaging_activity],
				f.[packaging_class],
				''[packaging_sub_material],
				''[to_nation],
				'' [relative_move],
				'Total Household packaging' [packaging_type],
				'' file1kg,
				''file2kg,
				''file1q,
				''file2q,
				''file1kge,
				''file2kge,
				''quanitykgdiff,
				''quantitykgediff,
				''qu,
				''wudiff,
				''fname1,
				''fname2,
				''fsubd,
				''f2subd,
				''org_sub_type,
				''org_name,
				''orgsize,
				''cs,
				''rt,
				''tp
				
			FROM
				(SELECT [packaging_material] FROM [dbo].[t_POM] GROUP BY [packaging_material]) d
			CROSS JOIN
			   (SELECT [packaging_class] FROM [dbo].[t_POM]
			            where packaging_class in ('Primary packaging',
												'Shipment Packaging',
												'Online marketplace total',
												'Public bin')
			            GROUP BY [packaging_class]) f
			UNION ALL
			SELECT distinct
				''orgname,
				''subid,
				d.[packaging_material],
				''[from_nation],
				pa.[packaging_activity],
				f.[packaging_class],
				''[packaging_sub_material],
				''[to_nation],
				''[relative_move],
				'Total Non-Household packaging' [packaging_type],
				'' file1kg,
				''file2kg,
				''file1q,
				''file2q,
				''file1kge,
				''file2kge,
				''quanitykgdiff,
				''quantitykgediff,
				''qu,
				''wudiff,
				''fname1,
				''fname2,
				''fsubd,
				''f2subd,
				''org_sub_type,
				''org_name,
				''orgsize,
				''cs,
				''rt,
				''tp
				
			FROM 
				(SELECT [packaging_material] FROM [dbo].[t_POM] GROUP BY [packaging_material]) d
			CROSS JOIN
			   (SELECT [packaging_class] FROM [dbo].[t_POM]
			            where packaging_class in('Primary packaging',
												'Shipment Packaging',
												'Online marketplace total',
												'secondary packaging',
												'Tertiary packaging')
			            GROUP BY [packaging_class]) f
			CROSS JOIN
			   (SELECT [packaging_activity] FROM [dbo].[t_POM] GROUP BY [packaging_activity]) pa
			
			UNION ALL
			
			SELECT distinct
				''orgname,
				''subid,
				d.[packaging_material],
				''[from_nation],
				''[packaging_activity],
				f.[packaging_class],
				''[packaging_sub_material],
				''[to_nation],
				''[relative_move],
				'Household drinks containers' [packaging_type],
				''file1kg,
				''file2kg,
				''file1q,
				''file2q,
				''file1kge,
				''file2kge,
				''quanitykgdiff,
				''quantitykgediff,
				''qu,
				''wudiff,
				''fname1,
				''fname2,
				''fsubd,
				''f2subd,
				''org_sub_type,
				''org_name,
				''orgsize,
				''cs,
				''rt,
				''tp
				
			FROM 
				(SELECT [packaging_material] FROM [dbo].[t_POM] GROUP BY [packaging_material]) d
			CROSS JOIN
			   (SELECT [packaging_class] FROM [dbo].[t_POM] GROUP BY [packaging_class])f
			UNION ALL
			SELECT distinct
				''orgname,
				''subid,
				d.[packaging_material],
				''[from_nation],
				''[packaging_activity],
				f.[packaging_class],
				''[packaging_sub_material],
				''[to_nation],
				''[relative_move],
				'Non-Household drinks containers' [packaging_type],
				'' file1kg,
				''file2kg,
				''file1q,
				''file2q,
				''file1kge,
				''file2kge,
				''quanitykgdiff,
				''quantitykgediff,
				''qu,
				''wudiff,
				''fname1,
				''fname2,
				''fsubd,
				''f2subd,
				''org_sub_type,
				''org_name,
				''orgsize,
				''cs,
				''rt,
				''tp
				
			FROM 
				(SELECT [packaging_material] FROM [dbo].[t_POM] GROUP BY [packaging_material]) d
			CROSS JOIN
			   (SELECT [packaging_class] FROM [dbo].[t_POM] GROUP BY [packaging_class])f
			
			UNION ALL
			
			SELECT distinct
				''orgname,
				''subid,
				d.[packaging_material],
				''[from_nation],
				''[packaging_activity],
				f.[packaging_class],
				''[packaging_sub_material],
				''[to_nation],
				''[relative_move],
				'reusable packaging' [packaging_type],
				'' file1kg,
				''file2kg,
				''file1q,
				''file2q,
				''file1kge,
				''file2kge,
				''quanitykgdiff,
				''quantitykgediff,
				''qu,
				''wudiff,
				''fname1,
				''fname2,
				''fsubd,
				''f2subd,
				''org_sub_type,
				''org_name,
				''orgsize,
				''cs,
				''rt,
				''tp
				
			FROM 
				(SELECT [packaging_material] FROM [dbo].[t_POM] GROUP BY [packaging_material]) d
			CROSS JOIN
			   (SELECT [packaging_class] FROM [dbo].[t_POM]
			            where packaging_class in('Primary packaging',
												'Non-primary reusable packaging')
			            GROUP BY [packaging_class])f
			
			UNION ALL
			SELECT distinct
				''orgname,
				''subid,
				d.[packaging_material],
				''[from_nation],
				''[packaging_activity],
				''[packaging_class],
				''[packaging_sub_material],
				''[to_nation],
				''[relative_move],
				''[packaging_type],
				''file1kg,
				''file2kg,
				''file1q,
				''file2q,
				''file1kge,
				''file2kge,
				''quanitykgdiff,
				''quantitykgediff,
				''qu,
				''wudiff,
				''fname1,
				''fname2,
				''fsubd,
				''f2subd,
				''org_sub_type,
				''org_name,
				''orgsize,
				''cs,
				''rt,
				'Total Packaging' tp
				
			FROM
				(SELECT [packaging_material] FROM [dbo].[t_POM] GROUP BY [packaging_material]) d
			
			
			UNION ALL
			
			SELECT distinct
				''orgname,
				''subid,
				d.[packaging_material],
				''[from_nation],
				pa.[packaging_activity],
				f.[packaging_class],
				''[packaging_sub_material],
				''[to_nation],
				''[relative_move],
				'Total Household Packaging' [packaging_type],
				'' file1kg,
				''file2kg,
				''file1q,
				''file2q,
				''file1kge,
				''file2kge,
				''quanitykgdiff,
				''quantitykgediff,
				''qu,
				''wudiff,
				''fname1,
				''fname2,
				''fsubd,
				''f2subd,
				''org_sub_type,
				''org_name,
				''orgsize,
				''cs,
				''rt,
				''tp
				
			FROM
				(SELECT [packaging_material] FROM [dbo].[t_POM] GROUP BY [packaging_material]) d
			CROSS JOIN
			   (SELECT [packaging_class] FROM [dbo].[t_POM]
			            where packaging_class in('Primary packaging',
												'Shipment packaging')
			            GROUP BY [packaging_class])f
			CROSS JOIN
			   (SELECT [packaging_activity] FROM [dbo].[t_POM] GROUP BY [packaging_activity]) pa
			
			UNION ALL
			
			SELECT distinct
				''orgname,
				''subid,
				d.[packaging_material],
				''[from_nation],
				pa.[packaging_activity],
				f.[packaging_class],
				''[packaging_sub_material],
				''[to_nation],
				''[relative_move],
				'Public Binned' [packaging_type],
				'' file1kg,
				''file2kg,
				''file1q,
				''file2q,
				''file1kge,
				''file2kge,
				''quanitykgdiff,
				''quantitykgediff,
				''qu,
				''wudiff,
				''fname1,
				''fname2,
				''fsubd,
				''f2subd,
				''org_sub_type,
				''org_name,
				''orgsize,
				''cs,
				''rt,
				''tp
				
			 FROM
				(SELECT [packaging_material] FROM [dbo].[t_POM] GROUP BY [packaging_material]) d
			CROSS JOIN
			   (SELECT [packaging_class] FROM [dbo].[t_POM]
			            where packaging_class in ('Public bin')
			            GROUP BY [packaging_class])f
			   CROSS JOIN
			   (SELECT [packaging_activity] FROM [dbo].[t_POM] GROUP BY [packaging_activity]) pa
			
			UNION ALL
			
			SELECT distinct
				''orgname,
				''subid,
				d.[packaging_material],
				''[from_nation],
				'Online Marketplace'[packaging_activity],
				f.[packaging_class],
				''[packaging_sub_material],
				''[to_nation],
				''[relative_move],
				'Total Household Packaging' [packaging_type],
				'' file1kg,
				''file2kg,
				''file1q,
				''file2q,
				''file1kge,
				''file2kge,
				''quanitykgdiff,
				''quantitykgediff,
				''qu,
				''wudiff,
				''fname1,
				''fname2,
				''fsubd,
				''f2subd,
				''org_sub_type,
				''org_name,
				''orgsize,
				''cs,
				''rt,
				''tp
				
			FROM
			    (SELECT [packaging_material] FROM [dbo].[t_POM] GROUP BY [packaging_material]) d
			CROSS JOIN
			   (SELECT [packaging_class] FROM [dbo].[t_POM]
			            where packaging_class ='Online Marketplace total'
			            GROUP BY [packaging_class]) f
			
			UNION ALL
			
			SELECT distinct
				''orgname,
				''subid,
				d.[packaging_material],
				''[from_nation],
				pa.[packaging_activity],
				f.[packaging_class],
				''[packaging_sub_material],
				''[to_nation],
				''[relative_move],
				'Total Non-Household Packaging' [packaging_type],
				'' file1kg,
				''file2kg,
				''file1q,
				''file2q,
				''file1kge,
				''file2kge,
				''quanitykgdiff,
				''quantitykgediff,
				''qu,
				''wudiff,
				''fname1,
				''fname2,
				''fsubd,
				''f2subd,
				''org_sub_type,
				''org_name,
				''orgsize,
				''cs,
				''rt,
				''tp
				
			FROM
				(SELECT [packaging_material] FROM [dbo].[t_POM] GROUP BY [packaging_material]) d
			CROSS JOIN
				(SELECT [packaging_class] FROM [dbo].[t_POM]
			           where packaging_class in('Primary packaging',
												'Shipment packaging',
												'Secondary packaging')
			           GROUP BY [packaging_class])f
			CROSS JOIN
				 (SELECT [packaging_activity] FROM [dbo].[t_POM]
			           GROUP BY [packaging_activity]) pa
			UNION ALL
			SELECT distinct
				''orgname,
				''subid,
				d.[packaging_material],
				''[from_nation],
				pa.[packaging_activity],
				''[packaging_class],
				''[packaging_sub_material],
				''[to_nation],
				''[relative_move],
				'Household drinks containers' [packaging_type],
				''file1kg,
				''file2kg,
				''file1q,
				''file2q,
				''file1kge,
				''file2kge,
				''quanitykgdiff,
				''quantitykgediff,
				''qu,
				''wudiff,
				''fname1,
				''fname2,
				''fsubd,
				''f2subd,
				''org_sub_type,
				''org_name,
				''orgsize,
				''cs,
				''rt,
				''tp
				
			FROM
				(SELECT [packaging_material] FROM [dbo].[t_POM] GROUP BY [packaging_material]) d
			CROSS JOIN
			   (SELECT [packaging_activity] FROM [dbo].[t_POM]
			            GROUP BY [packaging_activity]) pa
			UNION ALL
			SELECT distinct
				''orgname,
				''subid,
				d.[packaging_material],
				''[from_nation],
				pa.[packaging_activity],
				''[packaging_class],
				''[packaging_sub_material],
				''[to_nation],
				''[relative_move],
				'Non-Household drinks containers' [packaging_type],
				'' file1kg,
				''file2kg,
				''file1q,
				''file2q,
				''file1kge,
				''file2kge,
				''quanitykgdiff,
				''quantitykgediff,
				''qu,
				''wudiff,
				''fname1,
				''fname2,
				''fsubd,
				''f2subd,
				''org_sub_type,
				''org_name,
				''orgsize,
				''cs,
				''rt,
				''tp
				
			FROM
				(SELECT [packaging_material] FROM [dbo].[t_POM] GROUP BY [packaging_material]) d
				CROSS JOIN
			   (SELECT [packaging_activity]  FROM [dbo].[t_POM]
			            GROUP BY [packaging_activity]) pa
			
			UNION ALL
			
			SELECT distinct
				''orgname,
				''subid,
				d.[packaging_material],
				''[from_nation],
				pa.[packaging_activity],
				f.[packaging_class],
				 ''[packaging_sub_material],
				 ''[to_nation],
				''[relative_move],
				'reusable packaging' [packaging_type],
				 '' file1kg,
				 ''file2kg,
				 ''file1q,
				 ''file2q,
				 ''file1kge,
				 ''file2kge,
				 ''quanitykgdiff,
				 ''quantitykgediff,
				 ''qu,
				 ''wudiff,
				 ''fname1,
				 ''fname2,
				 ''fsubd,
				 ''f2subd,
				 ''org_sub_type,
				 ''org_name,
				 ''orgsize,
				 ''cs,
				 ''rt,
				 ''tp
				 
			FROM
				(SELECT [packaging_material] FROM [dbo].[t_POM] GROUP BY [packaging_material]) d
			CROSS JOIN
			   (SELECT [packaging_class] FROM [dbo].[t_POM]
			            where packaging_class in('Primary packaging',
												'Non-primary reusable packaging')
			            GROUP BY [packaging_class]) f
			   CROSS JOIN (SELECT [packaging_activity] FROM [dbo].[t_POM] GROUP BY [packaging_activity]) pa
			UNION ALL
			SELECT distinct
				''orgname,
				''subid,
				d.[packaging_material],
				''[from_nation],
				pa.[packaging_activity],
				''[packaging_class],
				''[packaging_sub_material],
				''[to_nation],
				''[relative_move],
				'' [packaging_type],
				'' file1kg,
				''file2kg,
				''file1q,
				''file2q,
				''file1kge,
				''file2kge,
				''quanitykgdiff,
				''quantitykgediff,
				''qu,
				''wudiff,
				''fname1,
				''fname2,
				''fsubd,
				''f2subd,
				''org_sub_type,
				''org_name,
				''orgsize,
				''cs,
				''rt,
				'Total Packaging'tp
				
			FROM
				(SELECT [packaging_material] FROM [dbo].[t_POM] GROUP BY [packaging_material]) d
			CROSS JOIN
			   (SELECT [packaging_activity]
			            FROM [dbo].[t_POM]
			            GROUP BY [packaging_activity]) pa;


 -- Calculations Starts 

 with self_management_consumer_waste_packaging_material_from_nation_1 AS (
			SELECT organisationName
				,subsidiary_id
				,packaging_material
				,from_nation
				,
				--   SUM(quantity_kg_extrapolated_diff),
				CASE 
					WHEN @Threshold_Type = 'Percentage'
						AND isnull(sum(isnull(file1_Quantity_kg_extrapolated, 0)), 0) = 0
						THEN 0
					WHEN @Threshold_Type = 'Percentage'
						AND isnull(sum(isnull(file2_Quantity_kg_extrapolated, 0)), 0) = 0
						THEN 0
					WHEN @Threshold_Type = 'Percentage'
						AND sum(isnull(file1_Quantity_kg_extrapolated, 0)) < sum(isnull(file2_Quantity_kg_extrapolated, 0))
						THEN ((sum(isnull(file2_Quantity_kg_extrapolated, 0)) - sum(isnull(file1_Quantity_kg_extrapolated, 0))) / sum(isnull(file1_Quantity_kg_extrapolated, 0)) * 100)
					WHEN @Threshold_Type = 'Percentage'
						AND sum(isnull(file1_Quantity_kg_extrapolated, 0)) > sum(isnull(file2_Quantity_kg_extrapolated, 0))
						THEN ((sum(isnull(file1_Quantity_kg_extrapolated, 0)) - sum(isnull(file2_Quantity_kg_extrapolated, 0))) / sum(isnull(file1_Quantity_kg_extrapolated, 0)) * - 100)
					WHEN @Threshold_Type = 'Value'
						THEN SUM(isnull(quantity_kg_extrapolated_diff, 0))
					END quantity_kg_extrapolated_diff
				--,CAST('' AS VARCHAR(2)) AS UP_DOWN
				--,'both' filecheck
				,sum(file1_Quantity_kg_extrapolated) file1_Quantity_kg_extrapolated
				,sum(file2_Quantity_kg_extrapolated) file2_Quantity_kg_extrapolated
			--    , packaging_activity
			--INTO #self_management_consumer_waste_packaging_material_from_nation_1
			FROM #POM_COMP_arrow
			WHERE -- file1_Quantity_kg_extrapolated IS NOT NULL
				-- AND file2_Quantity_kg_extrapolated IS NOT NULL
				packaging_type = 'Self-managed consumer waste'
				AND isnull(from_nation, '') <> ''
				AND isnull(to_nation, '') = ''
			GROUP BY organisationName
				,subsidiary_id
				,packaging_material
				,from_nation
			)
			
			
			
			--select * from self_management_consumer_waste_packaging_material_from_nation_1 
			,

self_management_consumer_waste_packaging_material_from_nation_2 as (
				SELECT packaging_material
					,from_nation
					,quantity_kg_extrapolated_diff
					,file1_quantity_kg_extrapolated
					,file2_quantity_kg_extrapolated
					
				--INTO #self_management_consumer_waste_packaging_material_from_nation_2
				FROM self_management_consumer_waste_packaging_material_from_nation_1
				
				UNION ALL
				
				SELECT packaging_material
					,from_nation
					,''
					,''
					,''
					
				FROM #POM_COMP_arrow
				WHERE isnull(from_nation, '') <> ''
					AND isnull(packaging_material, '') <> ''
				GROUP BY packaging_material, from_nation
			),

--relative move
--self management consumer waste
--packaging material relative_move
--both file1 and 2 have data

self_management_consumer_waste_packaging_material_relative_move_1 AS (
			
			SELECT organisationName
				,subsidiary_id
				,packaging_material
				,relative_move
				,
				--   SUM(quantity_kg_extrapolated_diff),
				CASE 
					WHEN @Threshold_Type = 'Percentage'
						AND isnull(sum(isnull(file1_Quantity_kg_extrapolated, 0)), 0) = 0
						THEN 0
					WHEN @Threshold_Type = 'Percentage'
						AND isnull(sum(isnull(file2_Quantity_kg_extrapolated, 0)), 0) = 0
						THEN 0
					WHEN @Threshold_Type = 'Percentage'
						AND sum(isnull(file1_Quantity_kg_extrapolated, 0)) < sum(isnull(file2_Quantity_kg_extrapolated, 0))
						THEN ((sum(isnull(file2_Quantity_kg_extrapolated, 0)) - sum(isnull(file1_Quantity_kg_extrapolated, 0))) / sum(isnull(file1_Quantity_kg_extrapolated, 0)) * 100)
					WHEN @Threshold_Type = 'Percentage'
						AND sum(isnull(file1_Quantity_kg_extrapolated, 0)) > sum(isnull(file2_Quantity_kg_extrapolated, 0))
						THEN ((sum(isnull(file1_Quantity_kg_extrapolated, 0)) - sum(isnull(file2_Quantity_kg_extrapolated, 0))) / sum(isnull(file1_Quantity_kg_extrapolated, 0)) * - 100)
					WHEN @Threshold_Type = 'Value'
						THEN SUM(isnull(quantity_kg_extrapolated_diff, 0))
					END quantity_kg_extrapolated_diff
				--,CAST('' AS VARCHAR(2)) AS UP_DOWN
				--,'both' filecheck
				,sum(file1_Quantity_kg_extrapolated) file1_Quantity_kg_extrapolated
				,sum(file2_Quantity_kg_extrapolated) file2_Quantity_kg_extrapolated
			--INTO #self_management_consumer_waste_packaging_material_relative_move_1
			FROM #POM_COMP_arrow
			WHERE --file1_Quantity_kg_extrapolated IS NOT NULL
				-- AND file2_Quantity_kg_extrapolated IS NOT NULL
				packaging_type = 'Self-managed consumer waste'
				AND isnull(relative_move, '') <> ''
				AND isnull(packaging_material, '') <> ''
			GROUP BY organisationName
				,subsidiary_id
				,packaging_material
				,relative_move
			),

self_management_consumer_waste_packaging_material_relative_move_2 AS (
			SELECT packaging_material
				,relative_move
				,quantity_kg_extrapolated_diff
				,file1_quantity_kg_extrapolated
				,file2_quantity_kg_extrapolated
				
			--INTO #self_management_consumer_waste_packaging_material_relative_move_2
			FROM self_management_consumer_waste_packaging_material_relative_move_1
			
			UNION ALL
			
			SELECT packaging_material
				,relative_move
				,''
				,''
				,''
				
			FROM #POM_COMP_arrow
			WHERE isnull(relative_move, '') <> ''
				AND isnull(packaging_material, '') <> ''
			GROUP BY packaging_material
				,relative_move
		),

self_management_organisation_waste_packaging_material_from_nation_1 AS (
			SELECT organisationName
				,subsidiary_id
				,packaging_material
				,from_nation
				,
				--   SUM(quantity_kg_extrapolated_diff),
				CASE 
					WHEN @Threshold_Type = 'Percentage'
						AND isnull(sum(isnull(file1_Quantity_kg_extrapolated, 0)), 0) = 0
						THEN 0
					WHEN @Threshold_Type = 'Percentage'
						AND isnull(sum(isnull(file2_Quantity_kg_extrapolated, 0)), 0) = 0
						THEN 0
					WHEN @Threshold_Type = 'Percentage'
						AND sum(isnull(file1_Quantity_kg_extrapolated, 0)) < sum(isnull(file2_Quantity_kg_extrapolated, 0))
						THEN ((sum(isnull(file2_Quantity_kg_extrapolated, 0)) - sum(isnull(file1_Quantity_kg_extrapolated, 0))) / sum(isnull(file1_Quantity_kg_extrapolated, 0)) * 100)
					WHEN @Threshold_Type = 'Percentage'
						AND sum(isnull(file1_Quantity_kg_extrapolated, 0)) > sum(isnull(file2_Quantity_kg_extrapolated, 0))
						THEN ((sum(isnull(file1_Quantity_kg_extrapolated, 0)) - sum(isnull(file2_Quantity_kg_extrapolated, 0))) / sum(isnull(file1_Quantity_kg_extrapolated, 0)) * - 100)
					WHEN @Threshold_Type = 'Value'
						THEN SUM(isnull(quantity_kg_extrapolated_diff, 0))
					END quantity_kg_extrapolated_diff
				--,CAST('' AS VARCHAR(2)) AS UP_DOWN
				--,'both' filecheck
				,sum(file1_Quantity_kg_extrapolated) file1_Quantity_kg_extrapolated
				,sum(file2_Quantity_kg_extrapolated) file2_Quantity_kg_extrapolated
			--INTO #self_management_organisation_waste_packaging_material_from_nation_1
			FROM #POM_COMP_arrow
			WHERE --file1_Quantity_kg_extrapolated IS NOT NULL
				-- file2_Quantity_kg_extrapolated IS NOT NULL
				packaging_type = 'Self-managed organisation waste'
				AND isnull(from_nation, '') <> ''
				AND isnull(to_nation, '') = ''
				AND isnull(packaging_material, '') <> ''
			GROUP BY organisationName
				,subsidiary_id
				,packaging_material
				,from_nation
		),
			
self_management_organisation_waste_packaging_material_from_nation_2 AS (
			---table used for final report
			SELECT packaging_material
				,from_nation
				,quantity_kg_extrapolated_diff
				,file1_quantity_kg_extrapolated
				,file2_quantity_kg_extrapolated
				
			--INTO self_management_organisation_waste_packaging_material_from_nation_2
			FROM self_management_organisation_waste_packaging_material_from_nation_1
			
			UNION ALL
			
			SELECT packaging_material
				,from_nation
				,''
				,''
				,''
				
			FROM #POM_COMP_arrow
			WHERE isnull(from_nation, '') <> ''
				AND isnull(packaging_material, '') <> ''
			GROUP BY packaging_material
				,from_nation
		),

--self management organisation waste
--packaging material relative_move
--both file1 and 2 have data

self_management_organisation_waste_packaging_material_relative_move_1 AS (
			SELECT organisationName
				,subsidiary_id
				,packaging_material
				,relative_move
				,
				--   SUM(quantity_kg_extrapolated_diff),
				CASE 
					WHEN @Threshold_Type = 'Percentage'
						AND isnull(sum(isnull(file1_Quantity_kg_extrapolated, 0)), 0) = 0
						THEN 0
					WHEN @Threshold_Type = 'Percentage'
						AND isnull(sum(isnull(file2_Quantity_kg_extrapolated, 0)), 0) = 0
						THEN 0
					WHEN @Threshold_Type = 'Percentage'
						AND sum(isnull(file1_Quantity_kg_extrapolated, 0)) < sum(isnull(file2_Quantity_kg_extrapolated, 0))
						THEN ((sum(isnull(file2_Quantity_kg_extrapolated, 0)) - sum(isnull(file1_Quantity_kg_extrapolated, 0))) / sum(isnull(file1_Quantity_kg_extrapolated, 0)) * 100)
					WHEN @Threshold_Type = 'Percentage'
						AND sum(isnull(file1_Quantity_kg_extrapolated, 0)) > sum(isnull(file2_Quantity_kg_extrapolated, 0))
						THEN ((sum(isnull(file1_Quantity_kg_extrapolated, 0)) - sum(isnull(file2_Quantity_kg_extrapolated, 0))) / sum(isnull(file1_Quantity_kg_extrapolated, 0)) * - 100)
					WHEN @Threshold_Type = 'Value'
						THEN SUM(isnull(quantity_kg_extrapolated_diff, 0))
					END quantity_kg_extrapolated_diff
				--,CAST('' AS VARCHAR(2)) AS UP_DOWN
				--,'both' filecheck
				,sum(file1_Quantity_kg_extrapolated) file1_Quantity_kg_extrapolated
				,sum(file2_Quantity_kg_extrapolated) file2_Quantity_kg_extrapolated
			--INTO #self_management_organisation_waste_packaging_material_relative_move_1
			FROM #POM_COMP_arrow
			WHERE --file1_Quantity_kg_extrapolated IS NOT NULL
				-- AND file2_Quantity_kg_extrapolated IS NOT NULL
				packaging_type = 'Self-managed organisation waste'
				AND isnull(to_nation, '') <> ''
				AND isnull(packaging_material, '') <> ''
			GROUP BY organisationName
				,subsidiary_id
				,packaging_material
				,relative_move
		),

			
			
self_management_organisation_waste_packaging_material_relative_move_2 AS (		
			---table used for final report
			SELECT packaging_material
				,relative_move
				,quantity_kg_extrapolated_diff
				,file1_quantity_kg_extrapolated
				,file2_quantity_kg_extrapolated
				
			--INTO #self_management_organisation_waste_packaging_material_relative_move_2
			FROM self_management_organisation_waste_packaging_material_relative_move_1
			
			UNION ALL
			
			SELECT packaging_material
				,relative_move
				,''
				,''
				,''
				
			FROM #POM_COMP_arrow
			WHERE isnull(relative_move, '') <> ''
				AND isnull(packaging_material, '') <> ''
			GROUP BY packaging_material
				,relative_move
	),


--packaging material Household Pacakaging, packaging_class
--both file1 and 2 have data
all_packaging_household_packaging_material_packaging_class_1 AS (
SELECT organisationName
	,subsidiary_id
	,packaging_material
	,packaging_class
	,
	--   SUM(quantity_kg_extrapolated_diff),
	CASE 
		WHEN @Threshold_Type = 'Percentage'
			AND isnull(sum(isnull(file1_Quantity_kg_extrapolated, 0)), 0) = 0
			THEN 0
		WHEN @Threshold_Type = 'Percentage'
			AND isnull(sum(isnull(file2_Quantity_kg_extrapolated, 0)), 0) = 0
			THEN 0
		WHEN @Threshold_Type = 'Percentage'
			AND sum(isnull(file1_Quantity_kg_extrapolated, 0)) < sum(isnull(file2_Quantity_kg_extrapolated, 0))
			THEN ((sum(isnull(file2_Quantity_kg_extrapolated, 0)) - sum(isnull(file1_Quantity_kg_extrapolated, 0))) / sum(isnull(file1_Quantity_kg_extrapolated, 0)) * 100)
		WHEN @Threshold_Type = 'Percentage'
			AND sum(isnull(file1_Quantity_kg_extrapolated, 0)) > sum(isnull(file2_Quantity_kg_extrapolated, 0))
			THEN ((sum(isnull(file1_Quantity_kg_extrapolated, 0)) - sum(isnull(file2_Quantity_kg_extrapolated, 0))) / sum(isnull(file1_Quantity_kg_extrapolated, 0)) * - 100)
		WHEN @Threshold_Type = 'Value'
			THEN SUM(isnull(quantity_kg_extrapolated_diff, 0))
		END quantity_kg_extrapolated_diff
	--,CAST('' AS VARCHAR(2)) AS UP_DOWN
	--,'both' filecheck
	,sum(file1_Quantity_kg_extrapolated) file1_Quantity_kg_extrapolated
	,sum(file2_Quantity_kg_extrapolated) file2_Quantity_kg_extrapolated
--INTO #all_packaging_household_packaging_material_packaging_class_1
FROM #POM_COMP_arrow
WHERE -- file1_Quantity_kg_extrapolated IS NOT NULL
	--  AND file2_Quantity_kg_extrapolated IS NOT NULL
	packaging_type = 'Total Household packaging'
	AND packaging_class IN (
		'Primary packaging'
		,'Public bin'
		,'Shipment packaging'
		,'Online marketplace total'
		)
	AND isnull(packaging_material, '') <> ''
GROUP BY organisationName
	,subsidiary_id
	,packaging_material
	,packaging_class
),

all_packaging_household_packaging_material_packaging_class_2 AS (

---table used for final report
SELECT packaging_material
	,packaging_class
	,quantity_kg_extrapolated_diff
	,file1_quantity_kg_extrapolated
	,file2_quantity_kg_extrapolated
	
--INTO #all_packaging_household_packaging_material_packaging_class_2
FROM all_packaging_household_packaging_material_packaging_class_1

UNION ALL

SELECT packaging_material
	,packaging_class
	,''
	,''
	,''
	
FROM #POM_COMP_arrow
WHERE packaging_class IN (
		'Primary packaging'
		,'Public bin'
		,'Shipment packaging'
		)
	AND isnull(packaging_material, '') <> ''
GROUP BY packaging_material
	,packaging_class
),

 --packaging material Non-Household Pacakaging, packaging_clas
--both file1 and 2 have data
all_packaging_Non_household_packaging_material_packaging_class_1 AS (
SELECT organisationName
	,subsidiary_id
	,packaging_material
	,packaging_class
	,
	--   SUM(quantity_kg_extrapolated_diff),
	CASE 
		WHEN @Threshold_Type = 'Percentage'
			AND isnull(sum(isnull(file1_Quantity_kg_extrapolated, 0)), 0) = 0
			THEN 0
		WHEN @Threshold_Type = 'Percentage'
			AND isnull(sum(isnull(file2_Quantity_kg_extrapolated, 0)), 0) = 0
			THEN 0
		WHEN @Threshold_Type = 'Percentage'
			AND sum(isnull(file1_Quantity_kg_extrapolated, 0)) < sum(isnull(file2_Quantity_kg_extrapolated, 0))
			THEN ((sum(isnull(file2_Quantity_kg_extrapolated, 0)) - sum(isnull(file1_Quantity_kg_extrapolated, 0))) / sum(isnull(file1_Quantity_kg_extrapolated, 0)) * 100)
		WHEN @Threshold_Type = 'Percentage'
			AND sum(isnull(file1_Quantity_kg_extrapolated, 0)) > sum(isnull(file2_Quantity_kg_extrapolated, 0))
			THEN ((sum(isnull(file1_Quantity_kg_extrapolated, 0)) - sum(isnull(file2_Quantity_kg_extrapolated, 0))) / sum(isnull(file1_Quantity_kg_extrapolated, 0)) * - 100)
		WHEN @Threshold_Type = 'Value'
			THEN SUM(isnull(quantity_kg_extrapolated_diff, 0))
		END quantity_kg_extrapolated_diff
	--,CAST('' AS VARCHAR(2)) AS UP_DOWN
	--,'both' filecheck
	,sum(file1_Quantity_kg_extrapolated) file1_Quantity_kg_extrapolated
	,sum(file2_Quantity_kg_extrapolated) file2_Quantity_kg_extrapolated
--INTO #all_packaging_Non_household_packaging_material_packaging_class_1
FROM #POM_COMP_arrow
WHERE --file1_Quantity_kg_extrapolated IS NOT NULL
	-- AND file2_Quantity_kg_extrapolated IS NOT NULL
	packaging_type = 'Total Non-Household packaging'
	AND packaging_class IN (
		'Online marketplace total'
		,'Primary packaging'
		,'Secondary packaging'
		,'Shipment packaging'
		,'Tertiary packaging'
		)
	AND isnull(packaging_material, '') <> ''
GROUP BY organisationName
	,subsidiary_id
	,packaging_material
	,packaging_class
),

all_packaging_Non_household_packaging_material_packaging_class_2 AS (
---table used for final report
SELECT packaging_material
	,packaging_class
	,quantity_kg_extrapolated_diff
	,file1_quantity_kg_extrapolated
	,file2_quantity_kg_extrapolated
	
--INTO #all_packaging_Non_household_packaging_material_packaging_class_2
FROM all_packaging_Non_household_packaging_material_packaging_class_1

UNION ALL

SELECT packaging_material
	,packaging_class
	,''
	,''
	,''
	
FROM #POM_COMP_arrow
WHERE packaging_class IN (
		'Online marketplace total'
		,'Primary packaging'
		,'Secondary packaging'
		,'Shipment packaging'
		,'Tertiary packaging'
		)
	AND isnull(packaging_material, '') <> ''
GROUP BY packaging_material
	,packaging_class
),


--packaging material Household drinks
--both file1 and 2 have data
all_packaging_household_drinks_material_1 AS (
SELECT organisationName
	,subsidiary_id
	,packaging_material
	,
	--   SUM(quantity_kg_extrapolated_diff),
	CASE 
		WHEN @Threshold_Type = 'Percentage'
			AND isnull(sum(isnull(file1_Quantity_kg_extrapolated, 0)), 0) = 0
			THEN 0
		WHEN @Threshold_Type = 'Percentage'
			AND isnull(sum(isnull(file2_Quantity_kg_extrapolated, 0)), 0) = 0
			THEN 0
		WHEN @Threshold_Type = 'Percentage'
			AND sum(isnull(file1_Quantity_kg_extrapolated, 0)) < sum(isnull(file2_Quantity_kg_extrapolated, 0))
			THEN ((sum(isnull(file2_Quantity_kg_extrapolated, 0)) - sum(isnull(file1_Quantity_kg_extrapolated, 0))) / sum(isnull(file1_Quantity_kg_extrapolated, 0)) * 100)
		WHEN @Threshold_Type = 'Percentage'
			AND sum(isnull(file1_Quantity_kg_extrapolated, 0)) > sum(isnull(file2_Quantity_kg_extrapolated, 0))
			THEN ((sum(isnull(file1_Quantity_kg_extrapolated, 0)) - sum(isnull(file2_Quantity_kg_extrapolated, 0))) / sum(isnull(file1_Quantity_kg_extrapolated, 0)) * - 100)
		WHEN @Threshold_Type = 'Value'
			THEN SUM(isnull(quantity_kg_extrapolated_diff, 0))
		END quantity_kg_extrapolated_diff
	--,CAST('' AS VARCHAR(2)) AS UP_DOWN
	--,'both' filecheck
	,sum(file1_Quantity_kg_extrapolated) file1_Quantity_kg_extrapolated
	,sum(file2_Quantity_kg_extrapolated) file2_Quantity_kg_extrapolated
	,sum(file2_quantity_unit) file2_quantity_unit
--INTO #all_packaging_household_drinks_material_1
FROM #POM_COMP_arrow
WHERE --file1_Quantity_kg_extrapolated IS NOT NULL
	-- AND file2_Quantity_kg_extrapolated IS NOT NULL
	packaging_type = 'Household drinks containers'
	AND isnull(packaging_material, '') <> ''
GROUP BY organisationName
	,subsidiary_id
	,packaging_material
),

all_packaging_household_drinks_material_2 AS (

---table used for final report
SELECT packaging_material
	,quantity_kg_extrapolated_diff
	,file1_quantity_kg_extrapolated
	,file2_quantity_kg_extrapolated
	
	,file2_quantity_unit
--INTO #all_packaging_household_drinks_material_2
FROM all_packaging_household_drinks_material_1

UNION ALL

SELECT packaging_material
	,''
	,''
	,''
	,''
	
FROM #POM_COMP_arrow
WHERE isnull(packaging_material, '') <> ''
GROUP BY packaging_material
),

all_packaging_non_household_drinks_material_1 AS (

--packaging material non-Household drinks
SELECT organisationName
	,subsidiary_id
	,packaging_material
	,
	--   SUM(quantity_kg_extrapolated_diff),
	CASE 
		WHEN @Threshold_Type = 'Percentage'
			AND isnull(sum(isnull(file1_Quantity_kg_extrapolated, 0)), 0) = 0
			THEN 0
		WHEN @Threshold_Type = 'Percentage'
			AND isnull(sum(isnull(file2_Quantity_kg_extrapolated, 0)), 0) = 0
			THEN 0
		WHEN @Threshold_Type = 'Percentage'
			AND sum(isnull(file1_Quantity_kg_extrapolated, 0)) < sum(isnull(file2_Quantity_kg_extrapolated, 0))
			THEN ((sum(isnull(file2_Quantity_kg_extrapolated, 0)) - sum(isnull(file1_Quantity_kg_extrapolated, 0))) / sum(isnull(file1_Quantity_kg_extrapolated, 0)) * 100)
		WHEN @Threshold_Type = 'Percentage'
			AND sum(isnull(file1_Quantity_kg_extrapolated, 0)) > sum(isnull(file2_Quantity_kg_extrapolated, 0))
			THEN ((sum(isnull(file1_Quantity_kg_extrapolated, 0)) - sum(isnull(file2_Quantity_kg_extrapolated, 0))) / sum(isnull(file1_Quantity_kg_extrapolated, 0)) * - 100)
		WHEN @Threshold_Type = 'Value'
			THEN SUM(isnull(quantity_kg_extrapolated_diff, 0))
		END quantity_kg_extrapolated_diff
	--,CAST('' AS VARCHAR(2)) AS UP_DOWN
	--,'both' filecheck
	,sum(file1_Quantity_kg_extrapolated) file1_Quantity_kg_extrapolated
	,sum(file2_Quantity_kg_extrapolated) file2_Quantity_kg_extrapolated
	,sum(file2_quantity_unit) file2_quantity_unit
--INTO #all_packaging_non_household_drinks_material_1
FROM #POM_COMP_arrow
WHERE --file1_Quantity_kg_extrapolated IS NOT NULL
	--AND file2_Quantity_kg_extrapolated IS NOT NULL
	packaging_type = 'Non-household drinks containers'
	AND isnull(packaging_material, '') <> ''
GROUP BY organisationName
	,subsidiary_id
	,packaging_material
),

all_packaging_non_household_drinks_material_2 AS (
---table used for final report
SELECT packaging_material
	,quantity_kg_extrapolated_diff
	,file1_quantity_kg_extrapolated
	,file2_quantity_kg_extrapolated
	
	,file2_quantity_unit
--INTO #all_packaging_non_household_drinks_material_2
FROM all_packaging_non_household_drinks_material_1

UNION ALL

SELECT packaging_material
	,''
	,''
	,''
	,''
	
FROM #POM_COMP_arrow
WHERE isnull(packaging_material, '') <> ''
GROUP BY packaging_material
),

all_packaging_drinks_material_1 AS (
--all drinks
--both file1 and 2 have data
SELECT organisationName
	,subsidiary_id
	,packaging_material
	,
	--   SUM(quantity_kg_extrapolated_diff),
	CASE 
		WHEN @Threshold_Type = 'Percentage'
			AND isnull(sum(isnull(file1_Quantity_kg_extrapolated, 0)), 0) = 0
			THEN 0
		WHEN @Threshold_Type = 'Percentage'
			AND isnull(sum(isnull(file2_Quantity_kg_extrapolated, 0)), 0) = 0
			THEN 0
		WHEN @Threshold_Type = 'Percentage'
			AND sum(isnull(file1_Quantity_kg_extrapolated, 0)) < sum(isnull(file2_Quantity_kg_extrapolated, 0))
			THEN ((sum(isnull(file2_Quantity_kg_extrapolated, 0)) - sum(isnull(file1_Quantity_kg_extrapolated, 0))) / sum(isnull(file1_Quantity_kg_extrapolated, 0)) * 100)
		WHEN @Threshold_Type = 'Percentage'
			AND sum(isnull(file1_Quantity_kg_extrapolated, 0)) > sum(isnull(file2_Quantity_kg_extrapolated, 0))
			THEN ((sum(isnull(file1_Quantity_kg_extrapolated, 0)) - sum(isnull(file2_Quantity_kg_extrapolated, 0))) / sum(isnull(file1_Quantity_kg_extrapolated, 0)) * - 100)
		WHEN @Threshold_Type = 'Value'
			THEN SUM(isnull(quantity_kg_extrapolated_diff, 0))
		END quantity_kg_extrapolated_diff
	--,CAST('' AS VARCHAR(2)) AS UP_DOWN
	--,'both' filecheck
	,sum(file1_Quantity_kg_extrapolated) file1_Quantity_kg_extrapolated
	,sum(file2_Quantity_kg_extrapolated) file2_Quantity_kg_extrapolated
	,sum(file2_quantity_unit) file2_quantity_unit
--INTO #all_packaging_drinks_material_1
FROM #POM_COMP_arrow
WHERE --file1_Quantity_kg_extrapolated IS NOT NULL
	-- AND file2_Quantity_kg_extrapolated IS NOT NULL
	(
		packaging_type = 'Non-household drinks containers'
		OR packaging_type = 'household drinks containers'
		)
	AND isnull(packaging_material, '') <> ''
GROUP BY organisationName
	,subsidiary_id
	,packaging_material
),

all_packaging_drinks_material_2 AS (
---table used for final report
SELECT packaging_material
	,quantity_kg_extrapolated_diff
	,file1_quantity_kg_extrapolated
	,file2_quantity_kg_extrapolated
	
	,file2_quantity_unit
--INTO #all_packaging_drinks_material_2
FROM all_packaging_drinks_material_1

UNION ALL

SELECT packaging_material
	,''
	,''
	,''
	,''
	
FROM #POM_COMP_arrow
WHERE isnull(packaging_material, '') <> ''
GROUP BY packaging_material
),


  --all packaging reusable packaging
--both file1 and 2 have data
all_packaging_material_reusable1 AS (
SELECT organisationName
	,subsidiary_id
	,packaging_material
	,packaging_class
	,
	--   SUM(quantity_kg_extrapolated_diff),
	CASE 
		WHEN @Threshold_Type = 'Percentage'
			AND isnull(sum(isnull(file1_Quantity_kg_extrapolated, 0)), 0) = 0
			THEN 0
		WHEN @Threshold_Type = 'Percentage'
			AND isnull(sum(isnull(file2_Quantity_kg_extrapolated, 0)), 0) = 0
			THEN 0
		WHEN @Threshold_Type = 'Percentage'
			AND sum(isnull(file1_Quantity_kg_extrapolated, 0)) < sum(isnull(file2_Quantity_kg_extrapolated, 0))
			THEN ((sum(isnull(file2_Quantity_kg_extrapolated, 0)) - sum(isnull(file1_Quantity_kg_extrapolated, 0))) / sum(isnull(file1_Quantity_kg_extrapolated, 0)) * 100)
		WHEN @Threshold_Type = 'Percentage'
			AND sum(isnull(file1_Quantity_kg_extrapolated, 0)) > sum(isnull(file2_Quantity_kg_extrapolated, 0))
			THEN ((sum(isnull(file1_Quantity_kg_extrapolated, 0)) - sum(isnull(file2_Quantity_kg_extrapolated, 0))) / sum(isnull(file1_Quantity_kg_extrapolated, 0)) * - 100)
		WHEN @Threshold_Type = 'Value'
			THEN SUM(isnull(quantity_kg_extrapolated_diff, 0))
		END quantity_kg_extrapolated_diff
	--,CAST('' AS VARCHAR(2)) AS UP_DOWN
	--,'both' filecheck
	,sum(file1_Quantity_kg_extrapolated) file1_Quantity_kg_extrapolated
	,sum(file2_Quantity_kg_extrapolated) file2_Quantity_kg_extrapolated
--INTO #all_packaging_material_reusable1
FROM #POM_COMP_arrow
WHERE 
	packaging_type = 'Reusable packaging'
	AND isnull(packaging_material, '') <> ''
GROUP BY organisationName
	,subsidiary_id
	,packaging_material
	,packaging_class
),
---table used for final report
all_packaging_material_reusable2 AS (
SELECT packaging_material
	,packaging_class
	,file1_quantity_kg_extrapolated
	,file2_quantity_kg_extrapolated
	
	,'' file2_quantity_unit
--INTO #all_packaging_material_reusable2
FROM all_packaging_material_reusable1

UNION ALL

SELECT packaging_material
	,packaging_class
	,''
	,''
	,''
	
FROM #POM_COMP_arrow
WHERE packaging_class IN (
		'Primary packaging'
		,'Non-primary reusable packaging'
		)
	AND isnull(packaging_material, '') <> ''
GROUP BY packaging_material
	,packaging_class
),

--all packaging total packaging
--both file1 and 2 have data
all_packaging_material_TP1 AS (
SELECT organisationName
	,subsidiary_id
	,packaging_material
	,
	--   SUM(quantity_kg_extrapolated_diff),
	CASE 
		WHEN @Threshold_Type = 'Percentage'
			AND isnull(sum(isnull(file1_Quantity_kg_extrapolated, 0)), 0) = 0
			THEN 0
		WHEN @Threshold_Type = 'Percentage'
			AND isnull(sum(isnull(file2_Quantity_kg_extrapolated, 0)), 0) = 0
			THEN 0
		WHEN @Threshold_Type = 'Percentage'
			AND sum(isnull(file1_Quantity_kg_extrapolated, 0)) < sum(isnull(file2_Quantity_kg_extrapolated, 0))
			THEN ((sum(isnull(file2_Quantity_kg_extrapolated, 0)) - sum(isnull(file1_Quantity_kg_extrapolated, 0))) / sum(isnull(file1_Quantity_kg_extrapolated, 0)) * 100)
		WHEN @Threshold_Type = 'Percentage'
			AND sum(isnull(file1_Quantity_kg_extrapolated, 0)) > sum(isnull(file2_Quantity_kg_extrapolated, 0))
			THEN ((sum(isnull(file1_Quantity_kg_extrapolated, 0)) - sum(isnull(file2_Quantity_kg_extrapolated, 0))) / sum(isnull(file1_Quantity_kg_extrapolated, 0)) * - 100)
		WHEN @Threshold_Type = 'Value'
			THEN SUM(isnull(quantity_kg_extrapolated_diff, 0))
		END quantity_kg_extrapolated_diff
	--,CAST('' AS VARCHAR(2)) AS UP_DOWN
	--,'both' filecheck
	,sum(file1_Quantity_kg_extrapolated) file1_Quantity_kg_extrapolated
	,sum(file2_Quantity_kg_extrapolated) file2_Quantity_kg_extrapolated
--INTO #all_packaging_material_TP1
FROM #POM_COMP_arrow
WHERE Total_Packaging = 'Total packaging'
	AND isnull(packaging_material, '') <> ''
GROUP BY organisationName
	,subsidiary_id
	,packaging_material
),
---table used for final report
all_packaging_material_TP2 AS (
SELECT packaging_material
	,'' packaging_class
	,file1_quantity_kg_extrapolated
	,file2_quantity_kg_extrapolated
	
	,'' file2_quantity_unit
--INTO #all_packaging_material_TP2
FROM all_packaging_material_TP1

UNION ALL

SELECT packaging_material
	,''
	,''
	,''
	,''
	
FROM #POM_COMP_arrow
WHERE isnull(packaging_material, '') <> ''
GROUP BY packaging_material
),
--------------------------------------------------------------
--all packaging total household
--------------------------------------------------------------
--both file1 and 2 have data
all_packaging_material_Thh1 AS (
SELECT organisationName
	,subsidiary_id
	,packaging_material
	,CASE 
		WHEN @Threshold_Type = 'Percentage'
			AND isnull(sum(isnull(file1_Quantity_kg_extrapolated, 0)), 0) = 0
			THEN 0
		WHEN @Threshold_Type = 'Percentage'
			AND isnull(sum(isnull(file2_Quantity_kg_extrapolated, 0)), 0) = 0
			THEN 0
		WHEN @Threshold_Type = 'Percentage'
			AND sum(isnull(file1_Quantity_kg_extrapolated, 0)) < sum(isnull(file2_Quantity_kg_extrapolated, 0))
			THEN ((sum(isnull(file2_Quantity_kg_extrapolated, 0)) - sum(isnull(file1_Quantity_kg_extrapolated, 0))) / sum(isnull(file1_Quantity_kg_extrapolated, 0)) * 100)
		WHEN @Threshold_Type = 'Percentage'
			AND sum(isnull(file1_Quantity_kg_extrapolated, 0)) > sum(isnull(file2_Quantity_kg_extrapolated, 0))
			THEN ((sum(isnull(file1_Quantity_kg_extrapolated, 0)) - sum(isnull(file2_Quantity_kg_extrapolated, 0))) / sum(isnull(file1_Quantity_kg_extrapolated, 0)) * - 100)
		WHEN @Threshold_Type = 'Value'
			THEN SUM(isnull(quantity_kg_extrapolated_diff, 0))
		END quantity_kg_extrapolated_diff
	--,CAST('' AS VARCHAR(2)) AS UP_DOWN
	--,'both' filecheck
	,sum(file1_Quantity_kg_extrapolated) file1_Quantity_kg_extrapolated
	,sum(file2_Quantity_kg_extrapolated) file2_Quantity_kg_extrapolated
--INTO #all_packaging_material_Thh1
FROM #POM_COMP_arrow
WHERE packaging_type = 'Total Household packaging'
	AND isnull(packaging_material, '') <> ''
GROUP BY organisationName
	,subsidiary_id
	,packaging_material
),
---table used for final report
all_packaging_material_Thh2 AS (
SELECT packaging_material
	,'' packaging_class
	,file1_quantity_kg_extrapolated
	,file2_quantity_kg_extrapolated
	
	,'' file2_quantity_unit
--INTO #all_packaging_material_Thh2
FROM all_packaging_material_Thh1

UNION ALL

SELECT packaging_material
	,''
	,''
	,''
	,''
	
FROM #POM_COMP_arrow
WHERE isnull(packaging_material, '') <> ''
GROUP BY packaging_material
),

--all packaging total non household
--both file1 and 2 have data
all_packaging_material_Tnhh1 AS (
SELECT organisationName
	,subsidiary_id
	,packaging_material
	,CASE 
		WHEN @Threshold_Type = 'Percentage'
			AND isnull(sum(isnull(file1_Quantity_kg_extrapolated, 0)), 0) = 0
			THEN 0
		WHEN @Threshold_Type = 'Percentage'
			AND isnull(sum(isnull(file2_Quantity_kg_extrapolated, 0)), 0) = 0
			THEN 0
		WHEN @Threshold_Type = 'Percentage'
			AND sum(isnull(file1_Quantity_kg_extrapolated, 0)) < sum(isnull(file2_Quantity_kg_extrapolated, 0))
			THEN ((sum(isnull(file2_Quantity_kg_extrapolated, 0)) - sum(isnull(file1_Quantity_kg_extrapolated, 0))) / sum(isnull(file1_Quantity_kg_extrapolated, 0)) * 100)
		WHEN @Threshold_Type = 'Percentage'
			AND sum(isnull(file1_Quantity_kg_extrapolated, 0)) > sum(isnull(file2_Quantity_kg_extrapolated, 0))
			THEN ((sum(isnull(file1_Quantity_kg_extrapolated, 0)) - sum(isnull(file2_Quantity_kg_extrapolated, 0))) / sum(isnull(file1_Quantity_kg_extrapolated, 0)) * - 100)
		WHEN @Threshold_Type = 'Value'
			THEN SUM(isnull(quantity_kg_extrapolated_diff, 0))
		END quantity_kg_extrapolated_diff
	--,CAST('' AS VARCHAR(2)) AS UP_DOWN
	--,'both' filecheck
	,sum(file1_Quantity_kg_extrapolated) file1_Quantity_kg_extrapolated
	,sum(file2_Quantity_kg_extrapolated) file2_Quantity_kg_extrapolated
--INTO #all_packaging_material_Tnhh1
FROM #POM_COMP_arrow
WHERE packaging_type = 'Total Non-Household packaging'
	AND isnull(packaging_material, '') <> ''
GROUP BY organisationName
	,subsidiary_id
	,packaging_material
),
---table used for final report
all_packaging_material_Tnhh2 AS (
SELECT packaging_material
	,'' packaging_class
	,file1_quantity_kg_extrapolated
	,file2_quantity_kg_extrapolated
	
	,'' file2_quantity_unit
--INTO #all_packaging_material_Tnhh2
FROM all_packaging_material_Tnhh1

UNION ALL

SELECT packaging_material
	,''
	,''
	,''
	,''
	
FROM #POM_COMP_arrow
WHERE isnull(packaging_material, '') <> ''
GROUP BY packaging_material
),


--all packaging reusable
--both file1 and 2 have data
all_packaging_material_total_reusable1 AS (
SELECT organisationName
	,subsidiary_id
	,packaging_material
	,CASE 
		WHEN @Threshold_Type = 'Percentage'
			AND isnull(sum(isnull(file1_Quantity_kg_extrapolated, 0)), 0) = 0
			THEN 0
		WHEN @Threshold_Type = 'Percentage'
			AND isnull(sum(isnull(file2_Quantity_kg_extrapolated, 0)), 0) = 0
			THEN 0
		WHEN @Threshold_Type = 'Percentage'
			AND sum(isnull(file1_Quantity_kg_extrapolated, 0)) < sum(isnull(file2_Quantity_kg_extrapolated, 0))
			THEN ((sum(isnull(file2_Quantity_kg_extrapolated, 0)) - sum(isnull(file1_Quantity_kg_extrapolated, 0))) / sum(isnull(file1_Quantity_kg_extrapolated, 0)) * 100)
		WHEN @Threshold_Type = 'Percentage'
			AND sum(isnull(file1_Quantity_kg_extrapolated, 0)) > sum(isnull(file2_Quantity_kg_extrapolated, 0))
			THEN ((sum(isnull(file1_Quantity_kg_extrapolated, 0)) - sum(isnull(file2_Quantity_kg_extrapolated, 0))) / sum(isnull(file1_Quantity_kg_extrapolated, 0)) * - 100)
		WHEN @Threshold_Type = 'Value'
			THEN SUM(isnull(quantity_kg_extrapolated_diff, 0))
		END quantity_kg_extrapolated_diff
	--,CAST('' AS VARCHAR(2)) AS UP_DOWN
	--,'both' filecheck
	,sum(file1_Quantity_kg_extrapolated) file1_Quantity_kg_extrapolated
	,sum(file2_Quantity_kg_extrapolated) file2_Quantity_kg_extrapolated
--INTO #all_packaging_material_total_reusable1
FROM #POM_COMP_arrow
WHERE --file1_Quantity_kg_extrapolated IS NOT NULL
	--  AND file2_Quantity_kg_extrapolated IS NOT NULL
	(packaging_type = 'Reusable packaging')
	AND isnull(packaging_material, '') <> ''
GROUP BY organisationName
	,subsidiary_id
	,packaging_material
),
---table used for final report
all_packaging_material_total_reusable2 AS (
SELECT packaging_material
	,'' packaging_class
	,file1_quantity_kg_extrapolated
	,file2_quantity_kg_extrapolated
	
	,'' file2_quantity_unit
--INTO #all_packaging_material_total_reusable2
FROM all_packaging_material_total_reusable1

UNION ALL

SELECT packaging_material
	,''
	,''
	,''
	,''
	
FROM #POM_COMP_arrow
WHERE isnull(packaging_material, '') <> ''
GROUP BY packaging_material
),

  ----------------------------------------------------------------- 
--packaging material Household Pacakaging, packaging_class - [packaging_activity]
----------------------------------------------------------------------
--both file1 and 2 have data
all_packaging_household_packaging_material_packaging_activity_1 AS (
SELECT organisationName
	,subsidiary_id
	,packaging_material
	,packaging_class
	,CASE 
		WHEN @Threshold_Type = 'Percentage'
			AND isnull(sum(isnull(file1_Quantity_kg_extrapolated, 0)), 0) = 0
			THEN 0
		WHEN @Threshold_Type = 'Percentage'
			AND isnull(sum(isnull(file2_Quantity_kg_extrapolated, 0)), 0) = 0
			THEN 0
		WHEN @Threshold_Type = 'Percentage'
			AND sum(isnull(file1_Quantity_kg_extrapolated, 0)) < sum(isnull(file2_Quantity_kg_extrapolated, 0))
			THEN ((sum(isnull(file2_Quantity_kg_extrapolated, 0)) - sum(isnull(file1_Quantity_kg_extrapolated, 0))) / sum(isnull(file1_Quantity_kg_extrapolated, 0)) * 100)
		WHEN @Threshold_Type = 'Percentage'
			AND sum(isnull(file1_Quantity_kg_extrapolated, 0)) > sum(isnull(file2_Quantity_kg_extrapolated, 0))
			THEN ((sum(isnull(file1_Quantity_kg_extrapolated, 0)) - sum(isnull(file2_Quantity_kg_extrapolated, 0))) / sum(isnull(file1_Quantity_kg_extrapolated, 0)) * - 100)
		WHEN @Threshold_Type = 'Value'
			THEN SUM(isnull(quantity_kg_extrapolated_diff, 0))
		END quantity_kg_extrapolated_diff
	--,CAST('' AS VARCHAR(2)) AS UP_DOWN
	--,'both' filecheck
	,sum(file1_Quantity_kg_extrapolated) file1_Quantity_kg_extrapolated
	,sum(file2_Quantity_kg_extrapolated) file2_Quantity_kg_extrapolated
	,packaging_activity
--INTO #all_packaging_household_packaging_material_packaging_activity_1
FROM #POM_COMP_arrow
WHERE 
	packaging_type = 'Total Household packaging'
	AND packaging_class IN (
		'Primary packaging'
		,'Shipment packaging'
		)
	AND isnull(packaging_material, '') <> ''  -- packaging_material is not null
GROUP BY organisationName
	,subsidiary_id
	,packaging_material
	,packaging_class
	,packaging_activity
),
---table used for final report
all_packaging_household_packaging_material_packaging_activity_2 AS (
SELECT packaging_material
	,packaging_class
	,quantity_kg_extrapolated_diff
	,file1_quantity_kg_extrapolated
	,file2_quantity_kg_extrapolated
	
	,packaging_activity
--INTO #all_packaging_household_packaging_material_packaging_activity_2
FROM all_packaging_household_packaging_material_packaging_activity_1

UNION ALL

SELECT packaging_material
	,packaging_class
	,''
	,''
	,''
	
	,packaging_activity
FROM #POM_COMP_arrow
WHERE isnull(packaging_class, '') <> ''
	AND packaging_class IN (
		'Primary packaging'
		,'Shipment packaging'
		)
	AND isnull(packaging_material, '') <> ''
GROUP BY packaging_material
	,packaging_class
	,packaging_activity
),
	
----------------------------------------------------------------- 
--packaging material public bin, packaging_class - [packaging_activity]
----------------------------------------------------------------------
--both file1 and 2 have data
all_packaging_pb_packaging_material_packaging_activity_1 AS (

SELECT organisationName
	,subsidiary_id
	,packaging_material
	,packaging_class
	,
	--   SUM(quantity_kg_extrapolated_diff),
	CASE 
		WHEN @Threshold_Type = 'Percentage'
			AND isnull(sum(isnull(file1_Quantity_kg_extrapolated, 0)), 0) = 0
			THEN 0
		WHEN @Threshold_Type = 'Percentage'
			AND isnull(sum(isnull(file2_Quantity_kg_extrapolated, 0)), 0) = 0
			THEN 0
		WHEN @Threshold_Type = 'Percentage'
			AND sum(isnull(file1_Quantity_kg_extrapolated, 0)) < sum(isnull(file2_Quantity_kg_extrapolated, 0))
			THEN ((sum(isnull(file2_Quantity_kg_extrapolated, 0)) - sum(isnull(file1_Quantity_kg_extrapolated, 0))) / sum(isnull(file1_Quantity_kg_extrapolated, 0)) * 100)
		WHEN @Threshold_Type = 'Percentage'
			AND sum(isnull(file1_Quantity_kg_extrapolated, 0)) > sum(isnull(file2_Quantity_kg_extrapolated, 0))
			THEN ((sum(isnull(file1_Quantity_kg_extrapolated, 0)) - sum(isnull(file2_Quantity_kg_extrapolated, 0))) / sum(isnull(file1_Quantity_kg_extrapolated, 0)) * - 100)
		WHEN @Threshold_Type = 'Value'
			THEN SUM(isnull(quantity_kg_extrapolated_diff, 0))
		END quantity_kg_extrapolated_diff
	--,CAST('' AS VARCHAR(2)) AS UP_DOWN
	--,'both' filecheck
	,sum(file1_Quantity_kg_extrapolated) file1_Quantity_kg_extrapolated
	,sum(file2_Quantity_kg_extrapolated) file2_Quantity_kg_extrapolated
	,packaging_activity
--INTO #all_packaging_pb_packaging_material_packaging_activity_1
FROM #POM_COMP_arrow
WHERE --file1_Quantity_kg_extrapolated IS NOT NULL
	--AND file2_Quantity_kg_extrapolated IS NOT NULL
	packaging_type = 'Public binned'
	AND packaging_class IN ('Public bin')
	AND isnull(packaging_material, '') <> ''
GROUP BY organisationName
	,subsidiary_id
	,packaging_material
	,packaging_class
	,packaging_activity
),
---table used for final report
all_packaging_pb_packaging_material_packaging_activity_2 AS (
SELECT packaging_material
	,packaging_class
	,quantity_kg_extrapolated_diff
	,file1_quantity_kg_extrapolated
	,file2_quantity_kg_extrapolated
	
	,packaging_activity
--INTO #all_packaging_pb_packaging_material_packaging_activity_2
FROM all_packaging_pb_packaging_material_packaging_activity_1

UNION ALL

SELECT packaging_material
	,packaging_class
	,''
	,''
	,''
	
	,packaging_activity
FROM #POM_COMP_arrow
WHERE isnull(packaging_class, '') <> ''
	AND packaging_class IN ('Public Bin')
	AND isnull(packaging_material, '') <> ''
GROUP BY packaging_material
	,packaging_class
	,packaging_activity
),

/*NEW*/
all_packaging_pb_packaging_material_1 AS (
SELECT organisationName
	,subsidiary_id
	,packaging_material
	,packaging_class
	,CASE 
		WHEN @Threshold_Type = 'Percentage'
			AND isnull(sum(isnull(file1_Quantity_kg_extrapolated, 0)), 0) = 0
			THEN 0
		WHEN @Threshold_Type = 'Percentage'
			AND isnull(sum(isnull(file2_Quantity_kg_extrapolated, 0)), 0) = 0
			THEN 0
		WHEN @Threshold_Type = 'Percentage'
			AND sum(isnull(file1_Quantity_kg_extrapolated, 0)) < sum(isnull(file2_Quantity_kg_extrapolated, 0))
			THEN ((sum(isnull(file2_Quantity_kg_extrapolated, 0)) - sum(isnull(file1_Quantity_kg_extrapolated, 0))) / sum(isnull(file1_Quantity_kg_extrapolated, 0)) * 100)
		WHEN @Threshold_Type = 'Percentage'
			AND sum(isnull(file1_Quantity_kg_extrapolated, 0)) > sum(isnull(file2_Quantity_kg_extrapolated, 0))
			THEN ((sum(isnull(file1_Quantity_kg_extrapolated, 0)) - sum(isnull(file2_Quantity_kg_extrapolated, 0))) / sum(isnull(file1_Quantity_kg_extrapolated, 0)) * - 100)
		WHEN @Threshold_Type = 'Value'
			THEN SUM(isnull(quantity_kg_extrapolated_diff, 0))
		END quantity_kg_extrapolated_diff
	--,CAST('' AS VARCHAR(2)) AS UP_DOWN
	--,'both' filecheck
	,sum(file1_Quantity_kg_extrapolated) file1_Quantity_kg_extrapolated
	,sum(file2_Quantity_kg_extrapolated) file2_Quantity_kg_extrapolated
--INTO #all_packaging_pb_packaging_material_1
FROM #POM_COMP_arrow
WHERE --file1_Quantity_kg_extrapolated IS NOT NULL
	--AND file2_Quantity_kg_extrapolated IS NOT NULL
	packaging_type = 'Public binned'
	AND packaging_class IN ('Public bin')
	AND isnull(packaging_material, '') <> ''
GROUP BY organisationName
	,subsidiary_id
	,packaging_material
	,packaging_class
),
---table used for final report
all_packaging_pb_packaging_material_2 AS (
SELECT packaging_material
	,packaging_class
	,quantity_kg_extrapolated_diff
	,file1_quantity_kg_extrapolated
	,file2_quantity_kg_extrapolated
	
--INTO #all_packaging_pb_packaging_material_2
FROM all_packaging_pb_packaging_material_1

UNION ALL

SELECT packaging_material
	,packaging_class
	,''
	,''
	,''
	
FROM #POM_COMP_arrow
WHERE isnull(packaging_class, '') <> ''
	AND packaging_class IN ('Public Bin')
	AND isnull(packaging_material, '') <> ''
GROUP BY packaging_material
	,packaging_class
),

----------------------------------------------------------------- 
--packaging material Total Non-Household packaging, packaging_class - [packaging_activity]
----------------------------------------------------------------------
all_packaging_tnh_packaging_material_packaging_activity_1 AS (
SELECT organisationName
	,subsidiary_id
	,packaging_material
	,packaging_class
	,CASE 
		WHEN @Threshold_Type = 'Percentage'
			AND isnull(sum(isnull(file1_Quantity_kg_extrapolated, 0)), 0) = 0
			THEN 0
		WHEN @Threshold_Type = 'Percentage'
			AND isnull(sum(isnull(file2_Quantity_kg_extrapolated, 0)), 0) = 0
			THEN 0
		WHEN @Threshold_Type = 'Percentage'
			AND sum(isnull(file1_Quantity_kg_extrapolated, 0)) < sum(isnull(file2_Quantity_kg_extrapolated, 0))
			THEN ((sum(isnull(file2_Quantity_kg_extrapolated, 0)) - sum(isnull(file1_Quantity_kg_extrapolated, 0))) / sum(isnull(file1_Quantity_kg_extrapolated, 0)) * 100)
		WHEN @Threshold_Type = 'Percentage'
			AND sum(isnull(file1_Quantity_kg_extrapolated, 0)) > sum(isnull(file2_Quantity_kg_extrapolated, 0))
			THEN ((sum(isnull(file1_Quantity_kg_extrapolated, 0)) - sum(isnull(file2_Quantity_kg_extrapolated, 0))) / sum(isnull(file1_Quantity_kg_extrapolated, 0)) * - 100)
		WHEN @Threshold_Type = 'Value'
			THEN SUM(isnull(quantity_kg_extrapolated_diff, 0))
		END quantity_kg_extrapolated_diff
	--,CAST('' AS VARCHAR(2)) AS UP_DOWN
	--,'both' filecheck
	,sum(file1_Quantity_kg_extrapolated) file1_Quantity_kg_extrapolated
	,sum(file2_Quantity_kg_extrapolated) file2_Quantity_kg_extrapolated
	,packaging_activity
--INTO #all_packaging_tnh_packaging_material_packaging_activity_1
FROM #POM_COMP_arrow
WHERE --file1_Quantity_kg_extrapolated IS NOT NULL
	--  AND file2_Quantity_kg_extrapolated IS NOT NULL
	packaging_type = 'Total Non-Household packaging'
	AND isnull(packaging_material, '') <> ''
GROUP BY organisationName
	,subsidiary_id
	,packaging_material
	,packaging_class
	,packaging_activity
),
---table used for final report
all_packaging_tnh_packaging_material_packaging_activity_2 AS (
SELECT packaging_material
	,packaging_class
	,quantity_kg_extrapolated_diff
	,file1_quantity_kg_extrapolated
	,file2_quantity_kg_extrapolated
	
	,packaging_activity
--INTO #all_packaging_tnh_packaging_material_packaging_activity_2
FROM all_packaging_tnh_packaging_material_packaging_activity_1

UNION ALL

SELECT packaging_material
	,packaging_class
	,''
	,''
	,''
	
	,packaging_activity
FROM #POM_COMP_arrow
WHERE packaging_class IN (
		'Primary packaging'
		,'Secondary packaging'
		,'Shipment packaging'
		,'Online marketplace total'
		,'Tertiary packaging'
		)
	AND isnull(packaging_material, '') <> ''
GROUP BY packaging_material
	,packaging_class
	,packaging_activity
),


--packaging material Household drinks - packaging_activity
all_packaging_household_drinks_material_packaging_activity_1 AS (
SELECT organisationName
	,subsidiary_id
	,packaging_material
	,CASE 
		WHEN @Threshold_Type = 'Percentage'
			AND isnull(sum(isnull(file1_Quantity_kg_extrapolated, 0)), 0) = 0
			THEN 0
		WHEN @Threshold_Type = 'Percentage'
			AND isnull(sum(isnull(file2_Quantity_kg_extrapolated, 0)), 0) = 0
			THEN 0
		WHEN @Threshold_Type = 'Percentage'
			AND sum(isnull(file1_Quantity_kg_extrapolated, 0)) < sum(isnull(file2_Quantity_kg_extrapolated, 0))
			THEN ((sum(isnull(file2_Quantity_kg_extrapolated, 0)) - sum(isnull(file1_Quantity_kg_extrapolated, 0))) / sum(isnull(file1_Quantity_kg_extrapolated, 0)) * 100)
		WHEN @Threshold_Type = 'Percentage'
			AND sum(isnull(file1_Quantity_kg_extrapolated, 0)) > sum(isnull(file2_Quantity_kg_extrapolated, 0))
			THEN ((sum(isnull(file1_Quantity_kg_extrapolated, 0)) - sum(isnull(file2_Quantity_kg_extrapolated, 0))) / sum(isnull(file1_Quantity_kg_extrapolated, 0)) * - 100)
		WHEN @Threshold_Type = 'Value'
			THEN SUM(isnull(quantity_kg_extrapolated_diff, 0))
		END quantity_kg_extrapolated_diff
	--,CAST('' AS VARCHAR(2)) AS UP_DOWN
	--,'both' filecheck
	,sum(file1_Quantity_kg_extrapolated) file1_Quantity_kg_extrapolated
	,sum(file2_Quantity_kg_extrapolated) file2_Quantity_kg_extrapolated
	,sum(file2_quantity_unit) file2_quantity_unit
	,packaging_activity
--INTO #all_packaging_household_drinks_material_packaging_activity_1
FROM #POM_COMP_arrow
WHERE --file1_Quantity_kg_extrapolated IS NOT NULL
	--  AND file2_Quantity_kg_extrapolated IS NOT NULL
	packaging_type = 'Household drinks containers'
	AND isnull(packaging_material, '') <> ''
GROUP BY organisationName
	,subsidiary_id
	,packaging_material
	,packaging_activity
),
---table used for final report
all_packaging_household_drinks_material_packaging_activity_2 AS (
SELECT packaging_material
	,quantity_kg_extrapolated_diff
	,file1_quantity_kg_extrapolated
	,file2_quantity_kg_extrapolated
	
	,file2_quantity_unit
	,[packaging_activity]
--INTO #all_packaging_household_drinks_material_packaging_activity_2
FROM all_packaging_household_drinks_material_packaging_activity_1

UNION ALL

SELECT packaging_material
	,''
	,''
	,''
	,''
	
	,packaging_activity
FROM #POM_COMP_arrow
WHERE isnull(packaging_material, '') <> ''
GROUP BY packaging_material
	,packaging_activity
),

 --packaging material nonHousehold drinks - packaging_activity
--both file1 and 2 have data
all_packaging_nonhousehold_drinks_material_packaging_activity_1 AS (
SELECT organisationName
	,subsidiary_id
	,packaging_material
	,CASE 
		WHEN @Threshold_Type = 'Percentage'
			AND isnull(sum(isnull(file1_Quantity_kg_extrapolated, 0)), 0) = 0
			THEN 0
		WHEN @Threshold_Type = 'Percentage'
			AND isnull(sum(isnull(file2_Quantity_kg_extrapolated, 0)), 0) = 0
			THEN 0
		WHEN @Threshold_Type = 'Percentage'
			AND sum(isnull(file1_Quantity_kg_extrapolated, 0)) < sum(isnull(file2_Quantity_kg_extrapolated, 0))
			THEN ((sum(isnull(file2_Quantity_kg_extrapolated, 0)) - sum(isnull(file1_Quantity_kg_extrapolated, 0))) / sum(isnull(file1_Quantity_kg_extrapolated, 0)) * 100)
		WHEN @Threshold_Type = 'Percentage'
			AND sum(isnull(file1_Quantity_kg_extrapolated, 0)) > sum(isnull(file2_Quantity_kg_extrapolated, 0))
			THEN ((sum(isnull(file1_Quantity_kg_extrapolated, 0)) - sum(isnull(file2_Quantity_kg_extrapolated, 0))) / sum(isnull(file1_Quantity_kg_extrapolated, 0)) * - 100)
		WHEN @Threshold_Type = 'Value'
			THEN SUM(isnull(quantity_kg_extrapolated_diff, 0))
		END quantity_kg_extrapolated_diff
	--,CAST('' AS VARCHAR(2)) AS UP_DOWN
	--,'both' filecheck
	,sum(file1_Quantity_kg_extrapolated) file1_Quantity_kg_extrapolated
	,sum(file2_Quantity_kg_extrapolated) file2_Quantity_kg_extrapolated
	,sum(file2_quantity_unit) file2_quantity_unit
	,packaging_activity
--INTO #all_packaging_nonhousehold_drinks_material_packaging_activity_1
FROM #POM_COMP_arrow
WHERE --file1_Quantity_kg_extrapolated IS NOT NULL
	-- AND file2_Quantity_kg_extrapolated IS NOT NULL
	packaging_type = 'Non-household drinks containers'
	AND isnull(packaging_material, '') <> ''
GROUP BY organisationName
	,subsidiary_id
	,packaging_material
	,packaging_activity
),
---table used for final report
all_packaging_nonhousehold_drinks_material_packaging_activity_2 AS (
SELECT packaging_material
	,quantity_kg_extrapolated_diff
	,file1_quantity_kg_extrapolated
	,file2_quantity_kg_extrapolated
	
	,file2_quantity_unit
	,[packaging_activity]
--INTO #all_packaging_nonhousehold_drinks_material_packaging_activity_2
FROM all_packaging_nonhousehold_drinks_material_packaging_activity_1

UNION ALL

SELECT packaging_material
	,''
	,''
	,''
	,''
	
	,packaging_activity
FROM #POM_COMP_arrow
WHERE isnull(packaging_material, '') <> ''
GROUP BY packaging_material
	,packaging_activity
),

 --packaging material all drinks - packaging_activity
all_packaging_all_drinks_material_packaging_activity_1 AS (
SELECT organisationName
	,subsidiary_id
	,packaging_material
	,CASE 
		WHEN @Threshold_Type = 'Percentage'
			AND isnull(sum(isnull(file1_Quantity_kg_extrapolated, 0)), 0) = 0
			THEN 0
		WHEN @Threshold_Type = 'Percentage'
			AND isnull(sum(isnull(file2_Quantity_kg_extrapolated, 0)), 0) = 0
			THEN 0
		WHEN @Threshold_Type = 'Percentage'
			AND sum(isnull(file1_Quantity_kg_extrapolated, 0)) < sum(isnull(file2_Quantity_kg_extrapolated, 0))
			THEN ((sum(isnull(file2_Quantity_kg_extrapolated, 0)) - sum(isnull(file1_Quantity_kg_extrapolated, 0))) / sum(isnull(file1_Quantity_kg_extrapolated, 0)) * 100)
		WHEN @Threshold_Type = 'Percentage'
			AND sum(isnull(file1_Quantity_kg_extrapolated, 0)) > sum(isnull(file2_Quantity_kg_extrapolated, 0))
			THEN ((sum(isnull(file1_Quantity_kg_extrapolated, 0)) - sum(isnull(file2_Quantity_kg_extrapolated, 0))) / sum(isnull(file1_Quantity_kg_extrapolated, 0)) * - 100)
		WHEN @Threshold_Type = 'Value'
			THEN SUM(isnull(quantity_kg_extrapolated_diff, 0))
		END quantity_kg_extrapolated_diff
	--,CAST('' AS VARCHAR(2)) AS UP_DOWN
	--,'both' filecheck
	,sum(file1_Quantity_kg_extrapolated) file1_Quantity_kg_extrapolated
	,sum(file2_Quantity_kg_extrapolated) file2_Quantity_kg_extrapolated
	,sum(file2_quantity_unit) file2_quantity_unit
	,packaging_activity
--INTO #all_packaging_all_drinks_material_packaging_activity_1
FROM #POM_COMP_arrow
WHERE --file1_Quantity_kg_extrapolated IS NOT NULL
	--AND file2_Quantity_kg_extrapolated IS NOT NULL
	(
		packaging_type = 'Non-household drinks containers'
		OR packaging_type = 'Household drinks containers'
		)
	AND isnull(packaging_material, '') <> ''
GROUP BY organisationName
	,subsidiary_id
	,packaging_material
	,packaging_activity
),
---table used for final report
all_packaging_all_drinks_material_packaging_activity_2 AS (
SELECT packaging_material
	,quantity_kg_extrapolated_diff
	,file1_quantity_kg_extrapolated
	,file2_quantity_kg_extrapolated
	
	,file2_quantity_unit
	,[packaging_activity]
--INTO #all_packaging_all_drinks_material_packaging_activity_2
FROM all_packaging_all_drinks_material_packaging_activity_1

UNION ALL

SELECT packaging_material
	,''
	,''
	,''
	,''
	
	,packaging_activity
FROM #POM_COMP_arrow
WHERE isnull(packaging_material, '') <> ''
GROUP BY packaging_material
	,packaging_activity
),

----------------------------------------------------------------- 
--packaging material reuasable, packaging_class - [packaging_activity]
----------------------------------------------------------------------
--both file1 and 2 have data
all_packaging_reusable_packaging_material_packaging_activity_1 AS (
SELECT organisationName
	,subsidiary_id
	,packaging_material
	,packaging_class
	,CASE 
		WHEN @Threshold_Type = 'Percentage'
			AND isnull(sum(isnull(file1_Quantity_kg_extrapolated, 0)), 0) = 0
			THEN 0
		WHEN @Threshold_Type = 'Percentage'
			AND isnull(sum(isnull(file2_Quantity_kg_extrapolated, 0)), 0) = 0
			THEN 0
		WHEN @Threshold_Type = 'Percentage'
			AND sum(isnull(file1_Quantity_kg_extrapolated, 0)) < sum(isnull(file2_Quantity_kg_extrapolated, 0))
			THEN ((sum(isnull(file2_Quantity_kg_extrapolated, 0)) - sum(isnull(file1_Quantity_kg_extrapolated, 0))) / sum(isnull(file1_Quantity_kg_extrapolated, 0)) * 100)
		WHEN @Threshold_Type = 'Percentage'
			AND sum(isnull(file1_Quantity_kg_extrapolated, 0)) > sum(isnull(file2_Quantity_kg_extrapolated, 0))
			THEN ((sum(isnull(file1_Quantity_kg_extrapolated, 0)) - sum(isnull(file2_Quantity_kg_extrapolated, 0))) / sum(isnull(file1_Quantity_kg_extrapolated, 0)) * - 100)
		WHEN @Threshold_Type = 'Value'
			THEN SUM(isnull(quantity_kg_extrapolated_diff, 0))
		END quantity_kg_extrapolated_diff
	--,CAST('' AS VARCHAR(2)) AS UP_DOWN
	--,'both' filecheck
	,sum(file1_Quantity_kg_extrapolated) file1_Quantity_kg_extrapolated
	,sum(file2_Quantity_kg_extrapolated) file2_Quantity_kg_extrapolated
	,packaging_activity
--INTO #all_packaging_reusable_packaging_material_packaging_activity_1
FROM #POM_COMP_arrow
WHERE --file1_Quantity_kg_extrapolated IS NOT NULL
	-- AND file2_Quantity_kg_extrapolated IS NOT NULL
	packaging_type = 'Reusable packaging'
	AND isnull(packaging_material, '') <> ''
GROUP BY organisationName
	,subsidiary_id
	,packaging_material
	,packaging_class
	,packaging_activity
),

---table used for final report
all_packaging_reusable_packaging_material_packaging_activity_2 AS (
SELECT packaging_material
	,packaging_class
	,quantity_kg_extrapolated_diff
	,file1_quantity_kg_extrapolated
	,file2_quantity_kg_extrapolated
	
	,packaging_activity
--INTO #all_packaging_reusable_packaging_material_packaging_activity_2
FROM all_packaging_reusable_packaging_material_packaging_activity_1

UNION ALL

SELECT packaging_material
	,packaging_class
	,''
	,''
	,''
	
	,packaging_activity
FROM t_pom
WHERE (packaging_type = 'Reusable packaging')
	AND isnull(packaging_material, '') <> ''
GROUP BY packaging_material
	,packaging_class
	,packaging_activity
),

----------------------------------------------------------------- 
--packaging material TOTAL packaging, packaging_class - [packaging_activity]
----------------------------------------------------------------------
all_packaging_tp_packaging_material_packaging_activity_1 AS (
SELECT organisationName
	,subsidiary_id
	,packaging_material
	,CASE 
		WHEN @Threshold_Type = 'Percentage'
			AND isnull(sum(isnull(file1_Quantity_kg_extrapolated, 0)), 0) = 0
			THEN 0
		WHEN @Threshold_Type = 'Percentage'
			AND isnull(sum(isnull(file2_Quantity_kg_extrapolated, 0)), 0) = 0
			THEN 0
		WHEN @Threshold_Type = 'Percentage'
			AND sum(isnull(file1_Quantity_kg_extrapolated, 0)) < sum(isnull(file2_Quantity_kg_extrapolated, 0))
			THEN ((sum(isnull(file2_Quantity_kg_extrapolated, 0)) - sum(isnull(file1_Quantity_kg_extrapolated, 0))) / sum(isnull(file1_Quantity_kg_extrapolated, 0)) * 100)
		WHEN @Threshold_Type = 'Percentage'
			AND sum(isnull(file1_Quantity_kg_extrapolated, 0)) > sum(isnull(file2_Quantity_kg_extrapolated, 0))
			THEN ((sum(isnull(file1_Quantity_kg_extrapolated, 0)) - sum(isnull(file2_Quantity_kg_extrapolated, 0))) / sum(isnull(file1_Quantity_kg_extrapolated, 0)) * - 100)
		WHEN @Threshold_Type = 'Value'
			THEN SUM(isnull(quantity_kg_extrapolated_diff, 0))
		END quantity_kg_extrapolated_diff
	--,CAST('' AS VARCHAR(2)) AS UP_DOWN
	--,'both' filecheck
	,sum(file1_Quantity_kg_extrapolated) file1_Quantity_kg_extrapolated
	,sum(file2_Quantity_kg_extrapolated) file2_Quantity_kg_extrapolated
	,packaging_activity
--INTO #all_packaging_tp_packaging_material_packaging_activity_1
FROM #POM_COMP_arrow
WHERE --file1_Quantity_kg_extrapolated IS NOT NULL
	-- AND file2_Quantity_kg_extrapolated IS NOT NULL
	Total_Packaging = 'Total packaging'
	AND isnull(packaging_material, '') <> ''
GROUP BY organisationName
	,subsidiary_id
	,packaging_material
	,packaging_activity
),


---table used for final report
all_packaging_tp_packaging_material_packaging_activity_2 AS (
SELECT packaging_material
	,'' packaging_class
	,quantity_kg_extrapolated_diff
	,file1_quantity_kg_extrapolated
	,file2_quantity_kg_extrapolated
	
	,packaging_activity
--INTO #all_packaging_tp_packaging_material_packaging_activity_2
FROM all_packaging_tp_packaging_material_packaging_activity_1

UNION ALL

SELECT packaging_material
	,''
	,''
	,''
	,''
	
	,packaging_activity
FROM #POM_COMP_arrow
WHERE isnull(packaging_material, '') <> ''
--   where packaging_class in ('Primary packaging','Secondary packaging','Shipment packaging','Online marketplace total','Tertiary packaging')
GROUP BY packaging_material
	,packaging_activity
),

  ----------------------------------------------------------------- 
--packaging material  hhpackaging, packaging_class - [packaging_activity]
----------------------------------------------------------------------
all_packaging_hh_packaging_material_packaging_activity_1 AS (
SELECT organisationName
	,subsidiary_id
	,packaging_material
	,CASE 
		WHEN @Threshold_Type = 'Percentage'
			AND isnull(sum(isnull(file1_Quantity_kg_extrapolated, 0)), 0) = 0
			THEN 0
		WHEN @Threshold_Type = 'Percentage'
			AND isnull(sum(isnull(file2_Quantity_kg_extrapolated, 0)), 0) = 0
			THEN 0
		WHEN @Threshold_Type = 'Percentage'
			AND sum(isnull(file1_Quantity_kg_extrapolated, 0)) < sum(isnull(file2_Quantity_kg_extrapolated, 0))
			THEN ((sum(isnull(file2_Quantity_kg_extrapolated, 0)) - sum(isnull(file1_Quantity_kg_extrapolated, 0))) / sum(isnull(file1_Quantity_kg_extrapolated, 0)) * 100)
		WHEN @Threshold_Type = 'Percentage'
			AND sum(isnull(file1_Quantity_kg_extrapolated, 0)) > sum(isnull(file2_Quantity_kg_extrapolated, 0))
			THEN ((sum(isnull(file1_Quantity_kg_extrapolated, 0)) - sum(isnull(file2_Quantity_kg_extrapolated, 0))) / sum(isnull(file1_Quantity_kg_extrapolated, 0)) * - 100)
		WHEN @Threshold_Type = 'Value'
			THEN SUM(isnull(quantity_kg_extrapolated_diff, 0))
		END quantity_kg_extrapolated_diff
	--,CAST('' AS VARCHAR(2)) AS UP_DOWN
	--,'both' filecheck
	,sum(file1_Quantity_kg_extrapolated) file1_Quantity_kg_extrapolated
	,sum(file2_Quantity_kg_extrapolated) file2_Quantity_kg_extrapolated
	,packaging_activity
--INTO #all_packaging_hh_packaging_material_packaging_activity_1
FROM #POM_COMP_arrow
WHERE --file1_Quantity_kg_extrapolated IS NOT NULL
	-- AND file2_Quantity_kg_extrapolated IS NOT NULL
	packaging_type = 'Total Household packaging'
	AND isnull(packaging_material, '') <> ''
GROUP BY organisationName
	,subsidiary_id
	,packaging_material
	,packaging_activity
),

---table used for final report
all_packaging_hh_packaging_material_packaging_activity_2 AS (
SELECT packaging_material
	,'' packaging_class
	,quantity_kg_extrapolated_diff
	,file1_quantity_kg_extrapolated
	,file2_quantity_kg_extrapolated
	
	,packaging_activity
--INTO #all_packaging_hh_packaging_material_packaging_activity_2
FROM all_packaging_hh_packaging_material_packaging_activity_1

UNION ALL

SELECT packaging_material
	,''
	,''
	,''
	,''
	
	,packaging_activity
FROM #POM_COMP_arrow
WHERE isnull(packaging_material, '') <> ''
--   where packaging_class in ('Primary packaging','Secondary packaging','Shipment packaging','Online marketplace total','Tertiary packaging')
GROUP BY packaging_material
	,packaging_activity
),
----------------------------------------------------------------- 
--packaging material  non hhpackaging, packaging_class - [packaging_activity]
----------------------------------------------------------------------
all_packaging_nonhh_packaging_material_packaging_activity_1 AS (
SELECT organisationName
	,subsidiary_id
	,packaging_material
	,CASE 
		WHEN @Threshold_Type = 'Percentage'
			AND isnull(sum(isnull(file1_Quantity_kg_extrapolated, 0)), 0) = 0
			THEN 0
		WHEN @Threshold_Type = 'Percentage'
			AND isnull(sum(isnull(file2_Quantity_kg_extrapolated, 0)), 0) = 0
			THEN 0
		WHEN @Threshold_Type = 'Percentage'
			AND sum(isnull(file1_Quantity_kg_extrapolated, 0)) < sum(isnull(file2_Quantity_kg_extrapolated, 0))
			THEN ((sum(isnull(file2_Quantity_kg_extrapolated, 0)) - sum(isnull(file1_Quantity_kg_extrapolated, 0))) / sum(isnull(file1_Quantity_kg_extrapolated, 0)) * 100)
		WHEN @Threshold_Type = 'Percentage'
			AND sum(isnull(file1_Quantity_kg_extrapolated, 0)) > sum(isnull(file2_Quantity_kg_extrapolated, 0))
			THEN ((sum(isnull(file1_Quantity_kg_extrapolated, 0)) - sum(isnull(file2_Quantity_kg_extrapolated, 0))) / sum(isnull(file1_Quantity_kg_extrapolated, 0)) * - 100)
		WHEN @Threshold_Type = 'Value'
			THEN SUM(isnull(quantity_kg_extrapolated_diff, 0))
		END quantity_kg_extrapolated_diff
	--,CAST('' AS VARCHAR(2)) AS UP_DOWN
	--,'both' filecheck
	,sum(file1_Quantity_kg_extrapolated) file1_Quantity_kg_extrapolated
	,sum(file2_Quantity_kg_extrapolated) file2_Quantity_kg_extrapolated
	,packaging_activity
--INTO #all_packaging_nonhh_packaging_material_packaging_activity_1
FROM #POM_COMP_arrow
WHERE -- file1_Quantity_kg_extrapolated IS NOT NULL
	-- AND file2_Quantity_kg_extrapolated IS NOT NULL
	packaging_type = 'Total Non-Household packaging'
	AND isnull(packaging_material, '') <> ''
GROUP BY organisationName
	,subsidiary_id
	,packaging_material
	,packaging_activity
),

---table used for final report
all_packaging_nonhh_packaging_material_packaging_activity_2 AS (
SELECT packaging_material
	,'' packaging_class
	,quantity_kg_extrapolated_diff
	,file1_quantity_kg_extrapolated
	,file2_quantity_kg_extrapolated
	
	,packaging_activity
--INTO #all_packaging_nonhh_packaging_material_packaging_activity_2
FROM all_packaging_nonhh_packaging_material_packaging_activity_1

UNION ALL

SELECT packaging_material
	,''
	,''
	,''
	,''
	
	,packaging_activity
FROM #POM_COMP_arrow
WHERE isnull(packaging_material, '') <> ''
--   where packaging_class in ('Primary packaging','Secondary packaging','Shipment packaging','Online marketplace total','Tertiary packaging')
GROUP BY packaging_material
	,packaging_activity
),

 ----------------------------------------------------------------- 
--packaging material  reusable, packaging_class - [packaging_activity]
----------------------------------------------------------------------
--both file1 and 2 have data
all_packaging_totalreusable_packaging_material_packaging_activity_1 AS (
SELECT organisationName
	,subsidiary_id
	,packaging_material
	,CASE 
		WHEN @Threshold_Type = 'Percentage'
			AND isnull(sum(isnull(file1_Quantity_kg_extrapolated, 0)), 0) = 0
			THEN 0
		WHEN @Threshold_Type = 'Percentage'
			AND isnull(sum(isnull(file2_Quantity_kg_extrapolated, 0)), 0) = 0
			THEN 0
		WHEN @Threshold_Type = 'Percentage'
			AND sum(isnull(file1_Quantity_kg_extrapolated, 0)) < sum(isnull(file2_Quantity_kg_extrapolated, 0))
			THEN ((sum(isnull(file2_Quantity_kg_extrapolated, 0)) - sum(isnull(file1_Quantity_kg_extrapolated, 0))) / sum(isnull(file1_Quantity_kg_extrapolated, 0)) * 100)
		WHEN @Threshold_Type = 'Percentage'
			AND sum(isnull(file1_Quantity_kg_extrapolated, 0)) > sum(isnull(file2_Quantity_kg_extrapolated, 0))
			THEN ((sum(isnull(file1_Quantity_kg_extrapolated, 0)) - sum(isnull(file2_Quantity_kg_extrapolated, 0))) / sum(isnull(file1_Quantity_kg_extrapolated, 0)) * - 100)
		WHEN @Threshold_Type = 'Value'
			THEN SUM(isnull(quantity_kg_extrapolated_diff, 0))
		END quantity_kg_extrapolated_diff
	--,CAST('' AS VARCHAR(2)) AS UP_DOWN
	--,'both' filecheck
	,sum(file1_Quantity_kg_extrapolated) file1_Quantity_kg_extrapolated
	,sum(file2_Quantity_kg_extrapolated) file2_Quantity_kg_extrapolated
	,packaging_activity
--INTO #all_packaging_totalreusable_packaging_material_packaging_activity_1
FROM #POM_COMP_arrow
WHERE --file1_Quantity_kg_extrapolated IS NOT NULL
	-- AND file2_Quantity_kg_extrapolated IS NOT NULL
	packaging_type = 'Reusable packaging'
	AND isnull(packaging_material, '') <> ''
GROUP BY organisationName
	,subsidiary_id
	,packaging_material
	,packaging_activity
),


---table used for final report
all_packaging_totalreusable_packaging_material_packaging_activity_2 AS (
SELECT packaging_material
	,'' packaging_class
	,quantity_kg_extrapolated_diff
	,file1_quantity_kg_extrapolated
	,file2_quantity_kg_extrapolated
	
	,packaging_activity
--INTO #all_packaging_totalreusable_packaging_material_packaging_activity_2
FROM all_packaging_totalreusable_packaging_material_packaging_activity_1

UNION ALL

SELECT packaging_material
	,''
	,''
	,''
	,''
	
	,packaging_activity
FROM #POM_COMP_arrow
WHERE isnull(packaging_material, '') <> ''
GROUP BY packaging_material
	,packaging_activity
	),

----------------------------------------------------------------- 
--packaging material online, online 
----------------------------------------------------------------------
--both file1 and 2 have data
all_packaging_online_marketplace_1 AS (
SELECT organisationName
	,subsidiary_id
	,packaging_material
	,packaging_class
	,CASE 
		WHEN @Threshold_Type = 'Percentage'
			AND isnull(sum(isnull(file1_Quantity_kg_extrapolated, 0)), 0) = 0
			THEN 0
		WHEN @Threshold_Type = 'Percentage'
			AND isnull(sum(isnull(file2_Quantity_kg_extrapolated, 0)), 0) = 0
			THEN 0
		WHEN @Threshold_Type = 'Percentage'
			AND sum(isnull(file1_Quantity_kg_extrapolated, 0)) < sum(isnull(file2_Quantity_kg_extrapolated, 0))
			THEN ((sum(isnull(file2_Quantity_kg_extrapolated, 0)) - sum(isnull(file1_Quantity_kg_extrapolated, 0))) / sum(isnull(file1_Quantity_kg_extrapolated, 0)) * 100)
		WHEN @Threshold_Type = 'Percentage'
			AND sum(isnull(file1_Quantity_kg_extrapolated, 0)) > sum(isnull(file2_Quantity_kg_extrapolated, 0))
			THEN ((sum(isnull(file1_Quantity_kg_extrapolated, 0)) - sum(isnull(file2_Quantity_kg_extrapolated, 0))) / sum(isnull(file1_Quantity_kg_extrapolated, 0)) * - 100)
		WHEN @Threshold_Type = 'Value'
			THEN SUM(isnull(quantity_kg_extrapolated_diff, 0))
		END quantity_kg_extrapolated_diff
	--,CAST('' AS VARCHAR(2)) AS UP_DOWN
	--,'both' filecheck
	,sum(file1_Quantity_kg_extrapolated) file1_Quantity_kg_extrapolated
	,sum(file2_Quantity_kg_extrapolated) file2_Quantity_kg_extrapolated
--INTO #all_packaging_online_marketplace_1
FROM #POM_COMP_arrow
WHERE packaging_type = 'Total Household packaging'
	AND packaging_class = 'Online marketplace total'
	AND isnull(packaging_material, '') <> ''
GROUP BY organisationName
	,subsidiary_id
	,packaging_material
	,packaging_class --,packaging_activity

),

---table used for final report
all_packaging_online_marketplace_2 AS (
SELECT packaging_material
	,packaging_class
	,quantity_kg_extrapolated_diff
	,file1_quantity_kg_extrapolated
	,file2_quantity_kg_extrapolated
	
--INTO #all_packaging_online_marketplace_2
FROM all_packaging_online_marketplace_1

UNION ALL

SELECT packaging_material
	,packaging_class
	,''
	,''
	,''
	
FROM #POM_COMP_arrow
WHERE packaging_class = 'Online marketplace total'
	AND isnull(packaging_material, '') <> ''
GROUP BY packaging_material
	,packaging_class
),

all_packaging_online_marketplace_non_HH_1 AS (
SELECT organisationName
	,subsidiary_id
	,packaging_material
	,packaging_class
	,
	--   SUM(quantity_kg_extrapolated_diff),
	CASE 
		WHEN @Threshold_Type = 'Percentage'
			AND isnull(sum(isnull(file1_Quantity_kg_extrapolated, 0)), 0) = 0
			THEN 0
		WHEN @Threshold_Type = 'Percentage'
			AND isnull(sum(isnull(file2_Quantity_kg_extrapolated, 0)), 0) = 0
			THEN 0
		WHEN @Threshold_Type = 'Percentage'
			AND sum(isnull(file1_Quantity_kg_extrapolated, 0)) < sum(isnull(file2_Quantity_kg_extrapolated, 0))
			THEN ((sum(isnull(file2_Quantity_kg_extrapolated, 0)) - sum(isnull(file1_Quantity_kg_extrapolated, 0))) / sum(isnull(file1_Quantity_kg_extrapolated, 0)) * 100)
		WHEN @Threshold_Type = 'Percentage'
			AND sum(isnull(file1_Quantity_kg_extrapolated, 0)) > sum(isnull(file2_Quantity_kg_extrapolated, 0))
			THEN ((sum(isnull(file1_Quantity_kg_extrapolated, 0)) - sum(isnull(file2_Quantity_kg_extrapolated, 0))) / sum(isnull(file1_Quantity_kg_extrapolated, 0)) * - 100)
		WHEN @Threshold_Type = 'Value'
			THEN SUM(isnull(quantity_kg_extrapolated_diff, 0))
		END quantity_kg_extrapolated_diff
	--,CAST('' AS VARCHAR(2)) AS UP_DOWN
	--,'both' filecheck
	,sum(file1_Quantity_kg_extrapolated) file1_Quantity_kg_extrapolated
	,sum(file2_Quantity_kg_extrapolated) file2_Quantity_kg_extrapolated
--INTO #all_packaging_online_marketplace_non_HH_1
FROM #POM_COMP_arrow
WHERE --file1_Quantity_kg_extrapolated IS NOT NULL
	-- file2_Quantity_kg_extrapolated IS NOT NULL
	packaging_type = 'Total Non-Household packaging'
	AND packaging_class = 'Online marketplace total'
	AND isnull(packaging_material, '') <> ''
GROUP BY organisationName
	,subsidiary_id
	,packaging_material
	,packaging_class --,packaging_activity
),

---table used for final report
all_packaging_online_marketplace_non_HH_2 AS (
SELECT packaging_material
	,packaging_class
	,quantity_kg_extrapolated_diff
	,file1_quantity_kg_extrapolated
	,file2_quantity_kg_extrapolated
	
--INTO #all_packaging_online_marketplace_non_HH_2
FROM all_packaging_online_marketplace_non_HH_1

UNION ALL

SELECT packaging_material
	,packaging_class
	,''
	,''
	,''
	
FROM #POM_COMP_arrow
WHERE packaging_class = 'Online marketplace total'
	AND isnull(packaging_material, '') <> ''
GROUP BY packaging_material
	,packaging_class
)


--- LAST here

SELECT packaging_material
	,from_nation
	,'' relative_move
	,'' packaging_class
	,file1_quantity_kg_extrapolated
	,file2_quantity_kg_extrapolated
	
	,'smcw_pm_fn' breakdown_flag
	--,cAST('' AS VARCHAR(2)) AS TOTAL_UP_DOWN
	,'' file2_quantity_unit
	,'' packaging_activity
INTO #POMCOMP_output
FROM self_management_consumer_waste_packaging_material_from_nation_2

UNION ALL

SELECT packaging_material
	,''
	,relative_move
	,''
	,file1_quantity_kg_extrapolated
	,file2_quantity_kg_extrapolated
	
	,'smcw_pm_rm'
	--,cAST('' AS VARCHAR(2)) AS TOTAL_UP_DOWN
	,'' file2_quantity_unit
	,'' packaging_activity
FROM self_management_consumer_waste_packaging_material_relative_move_2

UNION ALL

SELECT packaging_material
	,from_nation
	,'' relative_move
	,''
	,file1_quantity_kg_extrapolated
	,file2_quantity_kg_extrapolated
	
	,'smow_pm_fn' breakdown_flag
	--,cAST('' AS VARCHAR(2)) AS TOTAL_UP_DOWN
	,'' file2_quantity_unit
	,'' packaging_activity
FROM self_management_organisation_waste_packaging_material_from_nation_2

UNION ALL

SELECT packaging_material
	,''
	,relative_move
	,''
	,file1_quantity_kg_extrapolated
	,file2_quantity_kg_extrapolated
	
	,'smow_pm_rm'
	--,cAST('' AS VARCHAR(2)) AS TOTAL_UP_DOWN
	,'' file2_quantity_unit
	,'' packaging_activity
FROM self_management_organisation_waste_packaging_material_relative_move_2

UNION ALL

SELECT packaging_material
	,'' from_nation
	,'' relative_move
	,packaging_class
	,file1_quantity_kg_extrapolated
	,file2_quantity_kg_extrapolated
	
	,'all_pm_hh_pc'
	--,cAST('' AS VARCHAR(2)) AS TOTAL_UP_DOWN
	,'' file2_quantity_unit
	,'' packaging_activity
FROM all_packaging_household_packaging_material_packaging_class_2

UNION ALL

SELECT packaging_material
	,'' from_nation
	,'' relative_move
	,packaging_class
	,file1_quantity_kg_extrapolated
	,file2_quantity_kg_extrapolated
	
	,'all_pm_non_hh_pc'
	--,cAST('' AS VARCHAR(2)) AS TOTAL_UP_DOWN
	,'' file2_quantity_unit
	,'' packaging_activity
FROM all_packaging_Non_household_packaging_material_packaging_class_2

UNION ALL

SELECT packaging_material
	,'' from_nation
	,'' relative_move
	,'' packaging_class
	,file1_quantity_kg_extrapolated
	,file2_quantity_kg_extrapolated
	
	,'all_pm_hh_drinks'
	--,cAST('' AS VARCHAR(2)) AS TOTAL_UP_DOWN
	,file2_quantity_unit
	,'' packaging_activity
FROM all_packaging_household_drinks_material_2

UNION ALL

SELECT packaging_material
	,'' from_nation
	,'' relative_move
	,'' packaging_class
	,file1_quantity_kg_extrapolated
	,file2_quantity_kg_extrapolated
	
	,'all_pm_non_hh_drinks'
	--,cAST('' AS VARCHAR(2)) AS TOTAL_UP_DOWN
	,file2_quantity_unit
	,'' packaging_activity
FROM all_packaging_non_household_drinks_material_2

UNION ALL

SELECT packaging_material
	,'' from_nation
	,'' relative_move
	,'' packaging_class
	,file1_quantity_kg_extrapolated
	,file2_quantity_kg_extrapolated
	
	,'all_pm_drinks'
	--,cAST('' AS VARCHAR(2)) AS TOTAL_UP_DOWN
	,file2_quantity_unit
	,'' packaging_activity
FROM all_packaging_drinks_material_2

UNION ALL

SELECT packaging_material
	,'' from_nation
	,'' relative_move
	,packaging_class
	,file1_quantity_kg_extrapolated
	,file2_quantity_kg_extrapolated
	
	,'all_pm_reusable'
	--,cAST('' AS VARCHAR(2)) AS TOTAL_UP_DOWN
	,'' file2_quantity_unit
	,'' packaging_activity
FROM all_packaging_material_reusable2

UNION ALL

SELECT packaging_material
	,'' from_nation
	,'' relative_move
	,'' packaging_class
	,file1_quantity_kg_extrapolated
	,file2_quantity_kg_extrapolated
	
	,'all_pm_TP'
	--,cAST('' AS VARCHAR(2)) AS TOTAL_UP_DOWN
	,'' file2_quantity_unit
	,'' packaging_activity
FROM all_packaging_material_TP2

UNION ALL

SELECT packaging_material
	,'' from_nation
	,'' relative_move
	,'' packaging_class
	,file1_quantity_kg_extrapolated
	,file2_quantity_kg_extrapolated
	
	,'all_pm_Thh'
	--,cAST('' AS VARCHAR(2)) AS TOTAL_UP_DOWN
	,'' file2_quantity_unit
	,'' packaging_activity
FROM all_packaging_material_Thh2

UNION ALL

SELECT packaging_material
	,'' from_nation
	,'' relative_move
	,'' packaging_class
	,file1_quantity_kg_extrapolated
	,file2_quantity_kg_extrapolated
	
	,'all_pm_Tnhh'
	--,cAST('' AS VARCHAR(2)) AS TOTAL_UP_DOWN
	,'' file2_quantity_unit
	,'' packaging_activity
FROM all_packaging_material_Tnhh2

UNION ALL

SELECT packaging_material
	,'' from_nation
	,'' relative_move
	,'' packaging_class
	,file1_quantity_kg_extrapolated
	,file2_quantity_kg_extrapolated
	
	,'all_pm_TReusable'
	--,cAST('' AS VARCHAR(2)) AS TOTAL_UP_DOWN
	,'' file2_quantity_unit
	,'' packaging_activity
FROM all_packaging_material_total_reusable2

UNION ALL

SELECT packaging_material
	,'' from_nation
	,'' relative_move
	,packaging_class
	,file1_quantity_kg_extrapolated
	,file2_quantity_kg_extrapolated
	
	,'all_pm_hh_pa'
	--,cAST('' AS VARCHAR(2)) AS TOTAL_UP_DOWN
	,'' file2_quantity_unit
	,packaging_activity
FROM all_packaging_household_packaging_material_packaging_activity_2

UNION ALL

SELECT packaging_material
	,'' from_nation
	,'' relative_move
	,packaging_class
	,file1_quantity_kg_extrapolated
	,file2_quantity_kg_extrapolated
	
	,'all_pm_pb_pa'
	--,cAST('' AS VARCHAR(2)) AS TOTAL_UP_DOWN
	,'' file2_quantity_unit
	,packaging_activity
FROM all_packaging_pb_packaging_material_packaging_activity_2

UNION ALL

SELECT packaging_material
	,'' from_nation
	,'' relative_move
	,packaging_class
	,file1_quantity_kg_extrapolated
	,file2_quantity_kg_extrapolated
	
	,'all_pm_tnh_pa'
	--,cAST('' AS VARCHAR(2)) AS TOTAL_UP_DOWN
	,'' file2_quantity_unit
	,packaging_activity
FROM all_packaging_tnh_packaging_material_packaging_activity_2

UNION ALL

SELECT packaging_material
	,'' from_nation
	,'' relative_move
	,'' packaging_class
	,file1_quantity_kg_extrapolated
	,file2_quantity_kg_extrapolated
	
	,'all_pm_pa_HH_drinks'
	--,cAST('' AS VARCHAR(2)) AS TOTAL_UP_DOWN
	,file2_quantity_unit
	,packaging_activity
FROM all_packaging_household_drinks_material_packaging_activity_2

UNION ALL

SELECT packaging_material
	,'' from_nation
	,'' relative_move
	,'' packaging_class
	,file1_quantity_kg_extrapolated
	,file2_quantity_kg_extrapolated
	
	,'all_pm_pa_nHH_drinks'
	--,cAST('' AS VARCHAR(2)) AS TOTAL_UP_DOWN
	,file2_quantity_unit
	,packaging_activity
FROM all_packaging_nonhousehold_drinks_material_packaging_activity_2

UNION ALL

SELECT packaging_material
	,'' from_nation
	,'' relative_move
	,'' packaging_class
	,file1_quantity_kg_extrapolated
	,file2_quantity_kg_extrapolated
	
	,'all_pm_pa_all_drinks'
	--,cAST('' AS VARCHAR(2)) AS TOTAL_UP_DOWN
	,file2_quantity_unit
	,packaging_activity
FROM all_packaging_all_drinks_material_packaging_activity_2

UNION ALL

SELECT packaging_material
	,'' from_nation
	,'' relative_move
	,packaging_class
	,file1_quantity_kg_extrapolated
	,file2_quantity_kg_extrapolated
	
	,'all_pm_pa_reusable'
	--,cAST('' AS VARCHAR(2)) AS TOTAL_UP_DOWN
	,'' file2_quantity_unit
	,packaging_activity
FROM all_packaging_reusable_packaging_material_packaging_activity_2

UNION ALL

SELECT packaging_material
	,'' from_nation
	,'' relative_move
	,'' packaging_class
	,file1_quantity_kg_extrapolated
	,file2_quantity_kg_extrapolated
	
	,'all_pm_pa_tp'
	--,cAST('' AS VARCHAR(2)) AS TOTAL_UP_DOWN
	,'' file2_quantity_unit
	,packaging_activity
FROM all_packaging_tp_packaging_material_packaging_activity_2

UNION ALL

SELECT packaging_material
	,'' from_nation
	,'' relative_move
	,'' packaging_class
	,file1_quantity_kg_extrapolated
	,file2_quantity_kg_extrapolated
	
	,'all_pm_pa_total_hh'
	--,cAST('' AS VARCHAR(2)) AS TOTAL_UP_DOWN
	,'' file2_quantity_unit
	,packaging_activity
FROM all_packaging_hh_packaging_material_packaging_activity_2

UNION ALL

SELECT packaging_material
	,'' from_nation
	,'' relative_move
	,'' packaging_class
	,file1_quantity_kg_extrapolated
	,file2_quantity_kg_extrapolated
	
	,'all_pm_pa_total_nonhh'
	--,cAST('' AS VARCHAR(2)) AS TOTAL_UP_DOWN
	,'' file2_quantity_unit
	,packaging_activity
FROM all_packaging_nonhh_packaging_material_packaging_activity_2

UNION ALL

SELECT packaging_material
	,'' from_nation
	,'' relative_move
	,'' packaging_class
	,file1_quantity_kg_extrapolated
	,file2_quantity_kg_extrapolated
	
	,'all_pm_pa_total_reusable'
	--,cAST('' AS VARCHAR(2)) AS TOTAL_UP_DOWN
	,'' file2_quantity_unit
	,packaging_activity
FROM all_packaging_totalreusable_packaging_material_packaging_activity_2

UNION ALL

SELECT packaging_material
	,'' from_nation
	,'' relative_move
	,packaging_class
	,file1_quantity_kg_extrapolated
	,file2_quantity_kg_extrapolated
	
	,'all_pm_online'
	--,cAST('' AS VARCHAR(2)) AS TOTAL_UP_DOWN
	,'' file2_quantity_unit
	,'' packaging_activity
FROM all_packaging_online_marketplace_2

UNION ALL

SELECT packaging_material
	,'' from_nation
	,'' relative_move
	,packaging_class
	,file1_quantity_kg_extrapolated
	,file2_quantity_kg_extrapolated
	
	,'all_public_binned'
	--,cAST('' AS VARCHAR(2)) AS TOTAL_UP_DOWN
	,'' file2_quantity_unit
	,'' packaging_activity
FROM all_packaging_pb_packaging_material_2

UNION ALL

SELECT packaging_material
	,'' from_nation
	,'' relative_move
	,packaging_class
	,file1_quantity_kg_extrapolated
	,file2_quantity_kg_extrapolated
	
	,'all_pm_online_non'
	--,cAST('' AS VARCHAR(2)) AS TOTAL_UP_DOWN
	,'' file2_quantity_unit
	,'' packaging_activity
FROM all_packaging_online_marketplace_non_HH_2



--TOTAL CALCS
SELECT packaging_material
	,from_nation
	,relative_move
	,packaging_class
	,sum(file1_Quantity_kg_extrapolated) file1_Quantity_kg_extrapolated
	,sum(file2_Quantity_kg_extrapolated) file2_Quantity_kg_extrapolated
	,CASE 
		WHEN
			-- @Threshold_Type = 'Percentage' and 
			isnull(sum(file1_Quantity_kg_extrapolated), 0) = 0
			THEN 0
		WHEN
			--@Threshold_Type = 'Percentage' and
			isnull(sum(file2_Quantity_kg_extrapolated), 0) = 0
			THEN 0
		WHEN @Threshold_Type = 'Percentage'
			AND sum(file1_Quantity_kg_extrapolated) < sum(file2_Quantity_kg_extrapolated)
			THEN ((sum(file2_Quantity_kg_extrapolated) - sum(file1_Quantity_kg_extrapolated)) / sum(file1_Quantity_kg_extrapolated) * 100)
		WHEN @Threshold_Type = 'Percentage'
			AND sum(file1_Quantity_kg_extrapolated) > sum(file2_Quantity_kg_extrapolated)
			THEN ((sum(file1_Quantity_kg_extrapolated) - sum(file2_Quantity_kg_extrapolated)) / sum(file1_Quantity_kg_extrapolated) * - 100)
		WHEN @Threshold_Type = 'Value'
			THEN sum(file2_Quantity_kg_extrapolated) - sum(file1_Quantity_kg_extrapolated)
		END quantity_kg_extrapolated_diff
	--,CAST('' AS VARCHAR(2)) AS UP_DOWN
	,breakdown_flag
INTO #totals1
FROM #POMCOMP_output
GROUP BY packaging_material
	,from_nation
	,relative_move
	,packaging_class
	,breakdown_flag

 
   -------------------------------------------
-- OUTPUT TABLE USED FOR PAGINATED REPORT -
-------------------------------------------
SELECT *
	,@filename1 filename1
	,@filename2 filename2
	,@ProducerCS producerCS
	,@OrganisationID OrganisationID
	,@compliance_scheme compliance_scheme
	,@securityquery securityquery
FROM #POMCOMP_output

end;