(*@CES
Name=StCoatingAxisInf
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=2e9ecafb-d2f1-4b6b-83e3-f47895db637f
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
TYPE StCoatingAxisInf :
STRUCT
(*涂布轴信息@2024.01.18.095207*)	
	byCoatingAxisNum			: BYTE;(*涂布轴个数*)
	aiAxisIdList				: ARRAY [1..gc_byCoatingMaxSum_New]OF INT;(*轴idlist*)
	astStCoatingAxisParam		: ARRAY [1..gc_byCoatingMaxSum_New] OF StCoatingAxisParam;
END_STRUCT
END_TYPE

{IMPLEMENTATION}
