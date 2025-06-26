CREATE VIEW [dbo].[v_POM_Ram_Rag_Order]
AS SELECT distinct
 
p.ram_rag_rating as ram_rag_rating_code
 
,case 
    when p.ram_rag_rating = 'R' then 1
    when p.ram_rag_rating = 'R-M' then 2
    when p.ram_rag_rating = 'A' then 3
    when p.ram_rag_rating = 'A-M' then 4
    when p.ram_rag_rating = 'G' then 5
    when p.ram_rag_rating = 'G-M' then 6
end ram_rag_rating_order
from rpd.Pom p
where ram_rag_rating in (
    'R','R-M','A','A-M','G','G-M'
);