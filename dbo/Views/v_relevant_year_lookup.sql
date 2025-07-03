CREATE VIEW [dbo].[v_relevant_year_lookup] AS SELECT 1 ID, 'L' Producer_Type, 'Registration' Submission_Type, CONVERT(DATE, '01-JAN-2025') Start_Date, CONVERT(DATE, '31-DEC-2025') End_Date, CONVERT(DATE, '01-APR-2025') Deadline_Date, 2025 Relevant_Year UNION ALL
SELECT 2 ID, 'C' Producer_Type, 'Registration' Submission_Type, CONVERT(DATE, '01-JAN-2025') Start_Date, CONVERT(DATE, '31-DEC-2025') End_Date, CONVERT(DATE, '01-APR-2025') Deadline_Date, 2025 Relevant_Year UNION ALL
SELECT 3 ID, 'L' Producer_Type, 'Registration' Submission_Type, CONVERT(DATE, '01-JAN-2026') Start_Date, CONVERT(DATE, '31-DEC-2026') End_Date, CONVERT(DATE, '01-OCT-2025') Deadline_Date, 2026 Relevant_Year UNION ALL
SELECT 4 ID, 'C' Producer_Type, 'Registration' Submission_Type, CONVERT(DATE, '01-JAN-2026') Start_Date, CONVERT(DATE, '31-DEC-2026') End_Date, CONVERT(DATE, '01-OCT-2025') Deadline_Date, 2026 Relevant_Year UNION ALL

-- AC5
SELECT 5 ID, 'S' Producer_Type, 'Registration' Submission_Type, CONVERT(DATE, '01-JAN-2025') Start_Date, CONVERT(DATE, '31-DEC-2025') End_Date, CONVERT(DATE, '01-APR-2025') Deadline_Date, 2025 Relevant_Year UNION ALL
SELECT 6 ID, 'S' Producer_Type, 'Registration' Submission_Type, CONVERT(DATE, '01-JAN-2026') Start_Date, CONVERT(DATE, '31-DEC-2026') End_Date, CONVERT(DATE, '01-APR-2026') Deadline_Date, 2026 Relevant_Year UNION ALL

-- AC7
SELECT 7 ID, 'S' Producer_Type, 'Packaging' Submission_Type, CONVERT(DATE, '01-JAN-2024') Start_Date, CONVERT(DATE, '31-DEC-2024') End_Date, CONVERT(DATE, '01-APR-2025') Deadline_Date, 2025 Relevant_Year UNION ALL
SELECT 8 ID, 'S' Producer_Type, 'Packaging' Submission_Type, CONVERT(DATE, '01-JAN-2025') Start_Date, CONVERT(DATE, '31-DEC-2025') End_Date, CONVERT(DATE, '01-APR-2026') Deadline_Date, 2026 Relevant_Year UNION ALL

-- AC3
SELECT 9 ID, 'L' Producer_Type, 'Packaging' Submission_Type, CONVERT(DATE, '01-JAN-2024') Start_Date, CONVERT(DATE, '30-JUN-2024') End_Date, CONVERT(DATE, '01-OCT-2024') Deadline_Date, 2025 Relevant_Year UNION ALL
SELECT 10 ID, 'L' Producer_Type, 'Packaging' Submission_Type, CONVERT(DATE, '01-JUL-2024') Start_Date, CONVERT(DATE, '31-DEC-2024') End_Date, CONVERT(DATE, '01-APR-2025') Deadline_Date, 2025 Relevant_Year UNION ALL
SELECT 11 ID, 'L' Producer_Type, 'Packaging' Submission_Type, CONVERT(DATE, '01-JAN-2025') Start_Date, CONVERT(DATE, '30-JUN-2025') End_Date, CONVERT(DATE, '01-OCT-2025') Deadline_Date, 2026 Relevant_Year UNION ALL
SELECT 12 ID, 'L' Producer_Type, 'Packaging' Submission_Type, CONVERT(DATE, '01-JUL-2025') Start_Date, CONVERT(DATE, '31-DEC-2025') End_Date, CONVERT(DATE, '01-APR-2026') Deadline_Date, 2026 Relevant_Year UNION ALL

-- AC4
SELECT 13 ID, 'CL' Producer_Type, 'Packaging' Submission_Type, CONVERT(DATE, '01-JAN-2024') Start_Date, CONVERT(DATE, '30-JUN-2024') End_Date, CONVERT(DATE, '01-OCT-2024') Deadline_Date, 2025 Relevant_Year UNION ALL
SELECT 14 ID, 'CL' Producer_Type, 'Packaging' Submission_Type, CONVERT(DATE, '01-JUL-2024') Start_Date, CONVERT(DATE, '31-DEC-2024') End_Date, CONVERT(DATE, '01-APR-2025') Deadline_Date, 2025 Relevant_Year UNION ALL
SELECT 15 ID, 'CL' Producer_Type, 'Packaging' Submission_Type, CONVERT(DATE, '01-JAN-2025') Start_Date, CONVERT(DATE, '30-JUN-2025') End_Date, CONVERT(DATE, '01-OCT-2025') Deadline_Date, 2026 Relevant_Year UNION ALL
SELECT 16 ID, 'CL' Producer_Type, 'Packaging' Submission_Type, CONVERT(DATE, '01-JUL-2025') Start_Date, CONVERT(DATE, '31-DEC-2025') End_Date, CONVERT(DATE, '01-APR-2026') Deadline_Date, 2026 Relevant_Year UNION ALL

-- AC6
SELECT 17 ID, 'CS' Producer_Type, 'Registration' Submission_Type, CONVERT(DATE, '01-JAN-2025') Start_Date, CONVERT(DATE, '31-DEC-2025') End_Date, CONVERT(DATE, '01-APR-2025') Deadline_Date, 2025 Relevant_Year UNION ALL
SELECT 18 ID, 'CS' Producer_Type, 'Registration' Submission_Type, CONVERT(DATE, '01-JAN-2026') Start_Date, CONVERT(DATE, '31-DEC-2026') End_Date, CONVERT(DATE, '01-APR-2026') Deadline_Date, 2026 Relevant_Year UNION ALL

-- AC8
SELECT 19 ID, 'CS' Producer_Type, 'Packaging' Submission_Type, CONVERT(DATE, '01-JAN-2024') Start_Date, CONVERT(DATE, '31-DEC-2024') End_Date, CONVERT(DATE, '01-APR-2025') Deadline_Date, 2025 Relevant_Year UNION ALL
SELECT 20 ID, 'CS' Producer_Type, 'Packaging' Submission_Type, CONVERT(DATE, '01-JAN-2025') Start_Date, CONVERT(DATE, '31-DEC-2025') End_Date, CONVERT(DATE, '01-APR-2026') Deadline_Date, 2026 Relevant_Year;