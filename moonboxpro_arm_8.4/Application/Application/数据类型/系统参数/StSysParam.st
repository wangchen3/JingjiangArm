(*@CES
Name=StSysParam
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=7f2db5c7-12a0-45f5-95ad-ea3592943880
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
{attribute 'pack_mode' := '1'}
TYPE StSysParam :
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
	(*非保持参数*)
	(*整机参数-----*)
	stStSysParam_UnSave: StSysParam_UnSave;
	stStRSV_SysParam_UnSave: StRSV_SysParam_UnSave;
	(*系参数-------*)
	astStGrpParam_UnSave: ARRAY [1..2] OF StGrpParam_UnSave;
	astStRSV_GrpParam_UnSave: ARRAY [1..2] OF StRSV_GrpParam_UnSave;
	(*轴参数-------*)
	astStUnitParam_UnSave: ARRAY [1..16] OF StUnitParam_UnSave;
	astStRSV_UnitParam_UnSave: ARRAY [1..16] OF StRSV_UnitParam_UnSave;	
END_STRUCT
END_TYPE

{IMPLEMENTATION}
