(*@CES
Name=StGetMotionSts
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=76a34838-b972-4ac5-910f-8233101ca817
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
TYPE StGetMotionSts :
STRUCT
	(*通过指令GT_RN_Getstaionsts获取*)
	uiVirtual_Cnt					: UINT;//虚拟码盘基数	
	wVirtual_Sts: WORD;
	wNet_Status: WORD;
	wErr_a_Count: WORD;
	wErr_b_Count: WORD;
	wBreakCnt: WORD;
	wMotor_Temperature: WORD;
	wDriver_Temperature: WORD;
	wBus_Vol: WORD;
	(*通过指令GTN_GetDriverSts获取*)
	dwDriverSts: DWORD;
	(*通过指令GTN_GetServoAlarmInfo获取*)
	dwAlarmDetail: DWORD;
	(*通过大指令获取*)
	dwMotionSts: DWORD;
	lrPos_Prf: LREAL;
	lrPos_Enc: LREAL;
	lrVel_Prf: LREAL;
	lrVel_Enc: LREAL;
	lrPrfAcc: LREAL;//2026.5.8.112931新增
	
END_STRUCT
END_TYPE

{IMPLEMENTATION}
