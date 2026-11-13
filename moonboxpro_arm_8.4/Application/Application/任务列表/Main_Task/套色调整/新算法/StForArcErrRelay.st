(*@CES
Name=StForArcErrRelay
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=64f768e8-c7ea-45be-a7ca-b6ce53453813
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
TYPE StForArcErrRelay :(*2018.8.17.111110\专为误差传递定义的结构体\存储进期的误差量|*)
STRUCT
	aiErrDataList: ARRAY [1..gc_iMaxErrDataItemInList] OF INT;
END_STRUCT
END_TYPE

{IMPLEMENTATION}
