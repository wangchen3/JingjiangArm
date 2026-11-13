(*@CES
Name=StSysParam_SaveParam
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=c4973be9-8d63-450b-9a12-108a8802e4d7
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
TYPE StSysParam_SaveParam :
STRUCT
	(*保持参数*)
	(*整机参数-----*)
	stStSysParam_Save: StSysParam_Save;
	stStRSV_SysParam_Save: StRSV_SysParam_Save;
	(*系参数-------*)
	astStGrpParam_Save: ARRAY [1..2] OF StGrpParam_Save;
	astStRSV_GrpParam_Save: ARRAY [1..2] OF StRSV_GrpParam_Save;
	(*轴参数-------*)
	astStUnitParam_Save: ARRAY [1..16] OF StUnitParam_Save;
	astStRSV_UnitParam_Save: ARRAY [1..16] OF StRSV_UnitParam_Save;		
END_STRUCT
END_TYPE

{IMPLEMENTATION}
