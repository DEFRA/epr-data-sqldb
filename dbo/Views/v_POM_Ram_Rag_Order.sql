CREATE VIEW [dbo].[v_POM_Ram_Rag_Order]
AS SELECT 'R' ram_rag_rating_code, 1 ram_rag_rating_order
UNION ALL
SELECT 'R-M' ram_rag_rating_code, 2 ram_rag_rating_order
UNION ALL
SELECT 'A' ram_rag_rating_code, 3 ram_rag_rating_order
UNION ALL
SELECT 'A-M' ram_rag_rating_code, 4 ram_rag_rating_order
UNION ALL
SELECT 'G' ram_rag_rating_code, 5 ram_rag_rating_order
UNION ALL
SELECT 'G-M' ram_rag_rating_code, 6 ram_rag_rating_order;