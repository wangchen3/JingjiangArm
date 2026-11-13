(*@CES
Name=StRSV_UnitParam_Save
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=46255314-c989-4115-9e38-e176aae2c1a6
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
{attribute 'pack_mode' := '1'}
TYPE StRSV_UnitParam_Save :
STRUCT
	//先取个变量作为开关使用2026.02.06.194137
	//bit0作为联动开关
	//bit1作为匀墨开关
	xSwitch_Linkage: BIT;//联动
//	xSwitch_Ink: BIT;//匀墨
//	xSwitch_Unit_bit0: BIT;
	xSwitch_Unit_bit1: BIT;
	xSwitch_Unit_bit2: BIT;
	xSwitch_Unit_bit3: BIT;
	xSwitch_Unit_bit4: BIT;
	xSwitch_Unit_bit5: BIT;
	xSwitch_Unit_bit6: BIT;
	xSwitch_Unit_bit7: BIT;
	//xi.hy|2026.5.9.104945
	rFiberMoveAdjust:REAL;(*光纤行走位置修正量*)
	uiFiberMovePulsePerCycle:UINT;(*光纤行走每圈的脉冲数*)
	rFiberMoveDistancePerCycle: REAL;(*光纤行走每圈的距离*)
	rFiberMoveAdjust_ByOnlie:REAL;(*光纤行走位置修正量/来自在线*)

//2026.5.7.161608增加波形美化标志|985-1=984	
	xRsMorphFilter 								: BOOL;//美化标志
	
	//2026.05.08.201434 | + | 增加点位轴的标定零位位置  8字节
	liABSPos_Trap : LINT;
//2026.5.9.181548增加横向限位	
	lrLimit_Left : LREAL;
	lrLimit_Right : LREAL;
	//2026.5.29.172149增加金刚火眼误差/月光宝盒误差获取与调整选择||960-1=959
	byGetErrMode									: BYTE;
	
	abyRSV_UnitParam_Save: ARRAY [1..959] OF BYTE;
	//2026.05.08.201434 | + | 增加点位轴的标定零位位置  8字节	999-991
END_STRUCT
END_TYPE

{IMPLEMENTATION}
