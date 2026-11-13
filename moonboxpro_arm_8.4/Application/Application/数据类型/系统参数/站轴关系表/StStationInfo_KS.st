(*@CES
Name=StStationInfo_KS
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=6f2c3f0d-cedf-4320-89f1-935f04814eef
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
TYPE StStationInfo_KS :
STRUCT
	iSid_Device: INT;
	iStationNum: INT;
	aiStationId_List: ARRAY [1..128] OF INT;(*设备站号*)
	awStation_Type: ARRAY [1..128] OF WORD;(*站类型*)	
END_STRUCT
END_TYPE

{IMPLEMENTATION}
