﻿CREATE VIEW [dbo].[v_FromOrganisation_Name] AS select distinct FromOrganisation_Name
,FromOrganisation_ReferenceNumber
from dbo.t_rpd_data_SECURITY_FIX
where FromOrganisation_Name is not null;