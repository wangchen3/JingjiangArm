(*@CES
Name=StLatch
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=0ec4384d-bee9-4b71-9a9b-7dc85f6810a1
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
TYPE StLatch :
STRUCT
	iTriggerCnt : INT;
	udiTriggerEncErr : UDINT;
	udiTriggerTimeErr : UDINT;
END_STRUCT
END_TYPE

{IMPLEMENTATION}
