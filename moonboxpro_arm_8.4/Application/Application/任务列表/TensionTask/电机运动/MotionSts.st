(*@CES
Name=MotionSts
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=68a6a4b2-1fc3-48f5-a182-0781e2089d35
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
{attribute 'pack_mode' := '1'}
TYPE MotionSts :
STRUCT
	lrMotionsts					: LREAL;
	lrPos_Prf					: LREAL;
	lrPos_Enc					: LREAL;
	lrVel_Prf					: LREAL;
	lrVel_Enc					: LREAL;	
//扩展后，总共8个变量一张表	
	lrAcc_Prf					: LREAL;	
	lrTorque					: LREAL;	
	lrData3						: LREAL;			
END_STRUCT
END_TYPE

{IMPLEMENTATION}
