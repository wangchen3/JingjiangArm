(*@CES
Name=StPTSts
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=280ed72c-8fcd-4475-a4e8-3c9693214690
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
TYPE StPTSts :
STRUCT
	rtnSts:				INT;
	space:				INT;
	temperature:		INT;
	pfr:				DWORD;
	enc:				DWORD;
	vel:				INT;
	driverSts:			INT;
	driverErr:			INT;
	netPortSts:			INT;
	netRunSts:			INT;
	netPortErr_a:		INT;
	netPortErr_b:		INT;
	motionSts:			DWORD;
	modal:				WORD;
	virtualCnt:			WORD;
	virtualSts:			WORD;

	trigTime:			DWORD;
	trigCnt:			BYTE;
	brakeCnt:			WORD;
	driverCurrent:		WORD;
	driverTemp:			WORD;

	ai1_temp:			INT;
	ai2_temp:			INT;
	vdc:				INT;
	driverErr_high:		INT;
	sys_lock: 			DWORD;
	enc_lock:			DWORD;
	di:				WORD;

	rvsData_0:			WORD;
	encTemp:			WORD;
	rvsData_1:			WORD;
	rvsData_2:			DWORD;
	rvsData_3:			DWORD;
END_STRUCT
END_TYPE

{IMPLEMENTATION}
