(*@CES
Name=StMechanicalParamBuf
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=fd3f6fab-ce8b-4859-9675-c32c92772a95
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
{attribute 'pack_mode' := '1'}
TYPE StMechanicalParamBuf :
STRUCT
	abyBuf	: ARRAY [1..200] OF BYTE;	
END_STRUCT
END_TYPE

{IMPLEMENTATION}
