(*@CES
Name=StUnitCfg
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=7ee9ace1-2ace-4dfd-ae7f-638a47057af9
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
{attribute 'pack_mode' := '1'}
TYPE StUnitCfg :
STRUCT
	iUnitId : INT;
	iStationId : INT;
	iCoreId : INT;
	iAxisId : INT;
	iProfileId : INT;
	iAdjProfileId : INT;
	
END_STRUCT
END_TYPE

(*
TYPE StAxisCfg :
STRUCT
	iUnitId : INT;
	iStationId : INT;
	iCoreId : INT;
	iAxisId : INT;
	iProfileId : INT;
	iAdjProfileId : INT;
	
END_STRUCT
END_TYPE

*)
{IMPLEMENTATION}
