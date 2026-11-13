(*@CES
Name=StAxisIdListInf
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=2e898926-372a-4322-a5eb-b0bb4f9f030f
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
TYPE StAxisIdListInf :
STRUCT
	iAxisId: INT;(*轴号*)(*规划器*)
	iCoreId: int;(*核*)
	iTypeId: INT;(*类型*)
	iUnitId: INT;(*色组号*)
	iStdId: INT;(*站号*)
	iGroupId : INT;(*龙门组号*)
	iAdjAxisId : INT;(*调整轴号*)(*规划器*)
END_STRUCT
END_TYPE

{IMPLEMENTATION}
