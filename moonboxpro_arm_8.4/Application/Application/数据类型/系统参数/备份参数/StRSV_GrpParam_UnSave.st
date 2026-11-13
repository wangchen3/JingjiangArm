(*@CES
Name=StRSV_GrpParam_UnSave
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=99513ea4-3172-421d-89eb-422b57b4e6aa
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
{attribute 'pack_mode' := '1'}
TYPE StRSV_GrpParam_UnSave :
STRUCT
	//2026.03.11.151321 | + | 增加牵引单运行的开关  1000-999
	xSwitch_Inching_If : BIT;
	xSwitch_Inching_Of : BIT;
	
	xInching_If_Roller: BIT;
	xInching_Of_Roller: BIT;
	xSwitch_GrpInkEn:	BIT;

	//xSwitch_Unit_bit4: BIT;
	xSwitch_Unit_bit5: BIT;
	xSwitch_Unit_bit6: BIT;
	xSwitch_Unit_bit7: BIT;
	
	
	//xi.hy
	xFiberMove_DebugMode:BOOL;(*光纤行走调试状态*)
	xFiberMovePosCal_ByUnit:BOOL;(*色组标定按钮*)
	xFiberMovePosCal_ByOnline:BOOL;(*在线标定按钮*)
	xBasePosDoneByOnline:BOOL;(*在线检测基准位置确认完成标志*)
	xFiberMoveDisRunStart_AllUnit:BOOL;(*所有色组同步运动启动使能*)

	rFiberMoveDistance_AllUnit:REAL;(*所有色组同步运动距离*)
	rFiberMoveBasePosByOnline:REAL;(*在线检测发送来的基准位置*)
	
	xFiberMoveConfirm_AllUnit:BOOL;(*色组标定确认目标轴按钮*)
	//(*2026.03.28.111409||wang.xy*)
	xStartAutoFind						:BOOL;(*全自动套印使能*)
	xFlagAutoFindLastPress              :BOOL;(*全自动套印最后一色合压*)
	
//2026.4.6.125924增加一些开关|3字节||983-3=980
	xSwitch_SaveRS2file							: BOOL;//保存粗采样开关
	xSwitch_RFailure									: BOOL;//全自动套印粗采样失败校准按钮
	xSwitch_FFailure									: BOOL;//全自动套印精采样失败校准按钮
	
	//2026.04.10.150036
	dwAxisFlags_Estop:DWORD;//系急停状态
	abyRSV_StGrpParam_UnSave: ARRAY [1..976] OF BYTE;
//dwAxisFlags_Estop 980-4=976
//xSwitch_SaveRS2file->xSwitch_FFailure 983-3=980
// xStartAutoFind -> xFlagAutoFindLastPress 985-2=983	
//2026.03.24.103139 xFiberMoveVel_DebugMode->xFiberMoveConfirm_AllUnit 999-14=985	
END_STRUCT
END_TYPE

{IMPLEMENTATION}
