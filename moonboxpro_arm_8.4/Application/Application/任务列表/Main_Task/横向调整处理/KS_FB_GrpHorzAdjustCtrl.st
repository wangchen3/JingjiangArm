(*@CES
Name=KS_FB_GrpHorzAdjustCtrl
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=d9626d7c-8ffe-4608-b3df-e1f14e3ddbf7
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_GrpHorzAdjustCtrl
(*2023.3.8.222916
将KS_FB_AxisHorAdj屏蔽移动到KS_FB_GrpHorAdj中执行*)
(*处理了常规横向控制方式的方向控制逻辑@尝试统一方向|
@所有操作用户只关心站在套印面的左右*)
(*2025.2.7.163457 横向重复值支持整机输入*)
(*2025.2.7.170536 横向报警实现代码调整位置*)
VAR_INPUT
	i_xEn									: BOOL;(*使能*)
	i_iGrpId: INT;
	i_iGrpAxisNum_Pu						: INT; (*色组轴数*)
	i_abyGrpAxisList							: ARRAY [1..MAX_UNIT_NUM] OF BYTE; (*系的轴列表*)
	i_pastStIOMap_AxisBasic					: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF StIOMap_Axis_FE; (*基础io|*)
	i_pastStIOMap_AxisExtra					: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF StIOMap_Axis_Extra_FE; (* 扩展io|*)
	i_pstStSysParam: POINTER TO StSysParam;
	i_xDebugTestRun							: BOOL;
	i_xDebugTestResult_Wr					: BOOL;
	i_iDebugNum								: INT;
	i_diDebugPulse							: DINT;
	i_lrDebugPulse_PosAct					: LREAL;
	i_pastStDigitalMicroStepDrive			: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF StDigitalMicroStepDrive;
	i_lrVel_HorzAdjust						: LREAL;(*mm/s; um/ms; 横向调整速度|*)
	i_lrVel_HorzPreRegister					: LREAL;(*mm/s;横向预套准速度|*)
	i_pastStAxisRapidAdjProf_H				: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF StAxisRapidAdjProf_H;(*纵向快速对版|*)
	i_diPreReg_RepeatVal_H					: DINT;(*横向预套准的重复值@2025.2.7.163231*)
	i_diPreReg_SetupVal_H					: DINT;(*横向预套准的重复值@2025.2.7.163231*)
	i_xHorSyncMotorCtrl: BOOL;(*横向同步电机控制*)
	i_xHorStepDriveCtrl: BOOL;(*横向采样步进电机控制*)
	i_iStepDrivePulsePRev					: INT;(*步进电机|每一圈对应的脉冲数|default.6000||*)
	i_rStepDrivePosPPulse					: REAL;(*步进电机|每个脉冲对应的位置值 mm|default.0.0002||*)
	i_xIsDebugMode:BOOL;(*调试模式*)
	i_iStepDriveSa_Vel						: INT;(*步进电机启动速度*)
	i_iStepDrivePreReg_Vel					: INT;(*z步进电机预套速度R/MIN*)
	i_iStepDriveManu_Vel					: INT;(*z步进电机手动速度R/MIN*)
	i_iStepDriveManu_Vel_Fast				: INT;(*z步进电机手动高速速度R/MIN*)
	i_iStepDriveAuto_Vel					: INT;(*步进电机自动速度R/MIN*)
	i_iStepDriveAccTime						: INT;(*步进电机加速时间*)
	i_xHor_Goal_Flag						: BOOL;(*TRUE:目标值调整标志,走到左限位以目标值+当前修正量的值;FALSE :修正量调整标志,当前修正量-前次修正量的值*)
	i_xHor_PreRegist_Flag					: BOOL;(*横向预套准标志*)
	i_xEnaTestARC_Ink:BOOL;(*空转测试使能*)
	i_xHorLimit:BOOL;(*横向限位定义修改为左右|默认是纤维定义为正反方向*)
	i_xHorManuCtrl:BOOL;(*界面横向手动修正功能*)
END_VAR
VAR_IN_OUT
	(*2025.2.7.165301+*)
	io_byBtn_HorzPreRegister_Repeat			: BYTE;(*重复值的横向按钮@界面使用|=0 不运动|=1 按照轴距离运动|=2 整机按照单个值运动*)
	io_byBtn_HorzPreRegister_Setup			: BYTE;(*目标值的横向按钮@界面使用|=0 不运动|=1 按照轴距离运动|=2 整机按照单个值运动*)
	io_abyHorzManuTrigButton: ARRAY [1..MAX_UNIT_NUM] OF BYTE; (* 横向手动按钮|转发vs可视化界面操作| *)
	
END_VAR
VAR_OUTPUT
	o_xEno									: BOOL;
	o_iErNo									: INT;(*0成功\-1参数失败|*)
	o_xStepDriveDebugDne					: BOOL;
	o_xHorxPreRegister_Finish				: BOOL;
	o_xHorzMotorAlarmAtLeastOne				: BOOL;(*至少一色联动轴横向报警了*)
END_VAR
VAR
	fbKS_FB_GrpHorAdj						: KS_FB_GrpHorAdj;(*传统横向电机调整*)
	fbKS_FB_Debug_Get_mmPpul				: KS_FB_Debug_Get_mmPpul;(*测量单位脉冲对应的距离功能块mm/pul*)
	lrStepDrivePosPPulse					: LREAL;
	fbKS_FB_StepDrive_H						: KS_FB_StepDrive_H;
	iN										: INT;
	iUnitId									: INT;
	//iGrp									: INT;
	aiCommAdjustMentH						: ARRAY [1..MAX_UNIT_NUM] OF INT;
	aiCommAdjustMentH_HMI					: ARRAY [1..MAX_UNIT_NUM] OF DINT;
	iRtn									: INT;(*返回的调整量值*)
	xPreFlag_Stop							: BOOL;
	diPreReg_RepeatVal_H					: DINT;(*2025.2.7.163638+*)
	
// 	xFlag_Stop_In:ARRAY[1..2] OF BOOL;(*停机标志*)
// 	xFlag_Estop_In:ARRAY[1..2] OF BOOL;(*急停标志*)
// 	xFlag_Print_In:ARRAY[1..2] OF BOOL;(*印刷标志*)
// 	xLinkage_In:ARRAY[1..MAX_UNIT_NUM] OF BOOL;(*联动*)
// 	xSts_HorzPreRegister_In:ARRAY[1..2] OF BOOL;(*横向预套准状态*)
// 	xMode_HorzPreRegister_In:ARRAY[1..2] OF BOOL;(*横向预套准方式|false为设定值；true为重复值*)
// 	xBtn_HorzPreRegister_Repeat_In:ARRAY[1..2] OF BOOL;(*横向重复值按钮*)
// 	xBtn_HorzPreRegister_Setup_In:ARRAY[1..2] OF BOOL;(*横向设置值按钮*)
// 	diPreReg_RepeatVal_H_In:ARRAY[1..MAX_UNIT_NUM] OF DINT;(*横向重复值-预套准*)
// 	xFlag_HorzPreRegister_All_end_In:ARRAY[1..2] OF BOOL;(*横向预套准完成*)
// 	xHorzMotor_Alarm_In:ARRAY[1..MAX_UNIT_NUM] OF BOOL;(*横向报警*)

	xFlag_Stop_In: BOOL;(*停机标志*)
	xFlag_Estop_In: BOOL;(*急停标志*)
	xFlag_Print_In: BOOL;(*印刷标志*)
	xLinkage_In:ARRAY[1..MAX_UNIT_NUM] OF BOOL;(*联动*)
	xSts_HorzPreRegister_In:  BOOL;(*横向预套准状态*)
	xMode_HorzPreRegister_In: BOOL;(*横向预套准方式|false为设定值；true为重复值*)
	xBtn_HorzPreRegister_Repeat_In: BOOL;(*横向重复值按钮*)
	xBtn_HorzPreRegister_Setup_In: BOOL;(*横向设置值按钮*)
	diPreReg_RepeatVal_H_In:ARRAY[1..MAX_UNIT_NUM] OF DINT;(*横向重复值-预套准*)
	xFlag_HorzPreRegister_All_end_In:BOOL;(*横向预套准完成*)
	xHorzMotor_Alarm_In:ARRAY[1..MAX_UNIT_NUM] OF BOOL;(*横向报警*)
	
END_VAR

{IMPLEMENTATION}
Action_Input();
Action_Act();
Action_Output();