﻿CREATE TABLE [dbo].[t_pom_codes] (
    [Code] VARCHAR (7)  NOT NULL,
    [Type] VARCHAR (22) NOT NULL,
    [Text] VARCHAR (34) NOT NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = ROUND_ROBIN);



