(*@CES
Name=StSysStationInf
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=ff62fd15-378a-4887-af92-0b6cfd3f9fba
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
TYPE StSysStationInf :(*系统的站信息@最大128个站*)
STRUCT
	byStationNum:BYTE;
	astStationInf:ARRAY [1..128] OF StStationInf;
END_STRUCT
END_TYPE

{IMPLEMENTATION}
