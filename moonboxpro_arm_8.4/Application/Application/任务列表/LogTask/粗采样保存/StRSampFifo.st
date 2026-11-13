(*@CES
Name=StRSampFifo
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=e00882fe-97d1-4528-b28a-72dc94cf0559
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
TYPE StRSampFifo :
STRUCT
	byIDX_Wr: BYTE;(* 取低3bits/正常操作一直累加就ok *)
	byIDX_Rd: BYTE;(* 取低3bits/正常操作一直累加就ok *)
	astStRSampData: ARRAY [0..7] OF StRSampData;
END_STRUCT
END_TYPE
{IMPLEMENTATION}
