(*@CES
Name=KS_FB_GrpFailureProc
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=09d385a5-873d-4de4-8b5b-a35479951d22
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_GrpFailureProc
VAR_INPUT
	i_xEn: BOOL;
	i_iGrpId: INT;
	i_iCycle_Time: INT;
	i_byGrpUnitNum: INT;
	i_abyAxisList: ARRAY [1..MAX_UNIT_NUM] OF BYTE;
	i_iGrpAllStationNum: INT;
	i_aiStationList: ARRAY [1..MAX_STATION_NUM] OF INT;
	i_pstStSysParam: POINTER TO StSysParam;
	i_pastStGetMotionSts: POINTER TO ARRAY [1..MAX_STATION_NUM] OF StGetMotionSts;
	i_pastStAxisIdListInf :POINTER TO ARRAY [1..128] OF StAxisIdListInf;
	i_pastStIOMap_Main_FE	: POINTER TO ARRAY [1..4] OF StIOMap_Main_FE;(*轴io数据区域|*)	
	i_pastStIOMap_AxisExtra: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF StIOMap_Axis_Extra_FE;(*色组io|*)
	i_xLostPressure							: BOOL;(*气压低报警|不允许开机*)
	i_xPrnRollerLoose_AtLeast1				: BOOL;(*至少一色夹板松报警|不允许开机*)
	i_xbrakeResistanceTempHigh_AtLeast1		: BOOL;(*至少一色制动电阻温度高*)
	i_xHorzMotorAlarmAtLeastOne:BOOL;(*2022.6.28.000617*)	
	i_xEstopBtnDne:BOOL;(*急停按下了|2022.6.28.150049*)
	i_xFlag_FastStopBtnDn: BOOL;
	i_xTowerInvAlarm_Uw:BOOL;(*2022.6.28.161545|来自altma特殊处理*)
	i_xTowerInvAlarm_Rw: BOOL;	(*  *)	
	i_xInverterAlarmCurAxis_Uw				: BOOL;(*放料变频器当前轴报警*)
	i_xInverterAlarmCurAxis_Rw				: BOOL;(*收料变频器当前轴报警*)
	i_xInverterAlarmPreAxis_Uw				: BOOL;(*放料变频器预驱轴报警*)
	i_xInverterAlarmPreAxis_Rw				: BOOL;(*收料变频器预驱轴报警*)
	i_xInverterAlarm_If				: BOOL;(*放牵变频器报警*)
	i_xInverterAlarm_Of				: BOOL;(*收牵变频器报警*)
	
	i_xReflectSensorLoss					: BOOL;	
	i_iMoveErrCode							: INT;(*初始化错误代码
												0-正常
												1-使能异常
												2-模态0设置异常
												3-模态1设置异常
												4-规划器启动异常
												5-PT模式设置异常
												6-伺服打开超时
												7-PT规划异常*)	
	i_xAlarmHeating		: BOOL;		
	i_xFlag_Alarm_LD:BOOL;
	i_pxFlag_Alarm_Rev_ErrorEnc:POINTER TO BOOL;(*编码器反转提示2022.9.16.135026*)
	i_iAxisId_Alarm_Rev:INT;(*编码器反转轴号*)
	i_xUwVolDiamMeasurementFailed: BOOL;
	i_dwAvailPhys_kB				: DWORD;(*有效的物理内存@小于一定阈值报警提示*)
	i_wAvailPhysAlarm_Kb			: WORD;(*物理内存报警值@小于这个值报警提示*)
	i_xCompensate_Phase_Stop		: BOOL;(*停机恢复相位提示*)	
	i_xMemAllocFailed				: BOOL;(*内存申请失败*)
	i_xNeedRestartPlc				: BOOL;
	i_pstStGetPrm					:POINTER TO TMultiMcFunctionReadPrm;
	i_pstStSysStationInf			:POINTER TO StSysStationInf;
END_VAR
VAR_OUTPUT
	o_xEn: BOOL;
	o_iErNo									: INT;(*错误代码\-1:输入参数有误\|*)
	o_xInverterErrReset_Uw					: BOOL;
	o_xInverterErrReset_Rw					: BOOL;
	o_xAlarmStillOnline						: BOOL;(* 2022.3.15.125119/h/报警依然在线 |只有在列表中打印信息置位*)	
	o_xClrAlarmSts							: BOOL;(*清除报警状态|用于外部变量的手动清除*)	

END_VAR
VAR_IN_OUT
	io_byAutoBackUpSts:BYTE;(*SDCTL自动备份状态@=1 提示|=2 显示备份弹窗 *)
END_VAR
VAR
	iN: INT;
	iMsgId: INT;(*提示信息代码*)
	iAlarm_TypeId : INT;
	iAlarm_UnitId : INT;
	iAxisId: INT;
	iUnitId: INT;
	iTypeId: INT;
	iCoreId: INT;
	iGroupId : INT;
	axAlarmFlag: ARRAY [1..MAX_STATION_NUM] OF BOOL;
	xFaultInLinkageAxises: BOOL := FALSE;(*联动的轴里有错误|*)	
	xFaultInIf: BOOL;
	abyAxisFailedCnt_ServoAlarm: ARRAY [1..MAX_STATION_NUM] OF BYTE := [MAX_STATION_NUM(0)];(*伺服报警|*)	
	pstStUnitParam_Save: POINTER TO StUnitParam_Save;
	pstStUnitParam_UnSave: POINTER TO StUnitParam_UnSave;
	iTemp: INT;
	iBit: INT;
	fbTrigWillAutoPreCut_Uw:R_TRIG;
	fbTrigWillAutoPreCut_Rw:R_TRIG;
	xWillAutoMaticPreCut_Uw: BOOL;
	xWillAutoMaticPreCut_Rw: BOOL;
	iLinkageAxisNum: INT;
	iPromptMsg: INT;
	fbToF_UwVolDiamMeasurement: TON;
	alrBuff_Read: ARRAY [1..MAX_UNIT_NUM] OF LREAL;
	diReadCount: DINT;
	
	iRtn : INT;
	astStStationSts : ARRAY [1..MAX_STATION_NUM] OF StStationSts;
	abyStationList: ARRAY [1..MAX_STATION_NUM] OF BYTE;
	adiClock : ARRAY [1..MAX_STATION_NUM] OF DINT;
	stStSetPrm : TSetMultiMcFunctionPrm;	
	alTime_Test: ARRAY [1..10] OF LTIME;
	
	iAdjAxisId : INT;
	iRead_UnitId : INT;
	
	iReadSts_Page : INT := 1;
	
	iReadDriverSts_Page : INT;
	
	adwDriverSts : ARRAY [1..MAX_STATION_NUM] OF DWORD;
	
	(*2025-12-10 by sjw 非阻塞大指令*)
	aFB_Get_StartMcMUltiFunction: ARRAY[1..2] OF GTMC_StartMcMultiFunction;
	axExecute: ARRAY [1..2] OF BOOL;
	axDoneGet: ARRAY[1..2] OF BOOL := [TRUE, TRUE];
	axBusyGet: ARRAY[1..2] OF BOOL;
	axErrorGet: ARRAY[1..2] OF BOOL;
	aiErrorIdGet: ARRAY[1..2] OF INT;
	
	
	//2025.11.03.103620 | bai.zy | TEST_1103
	apData : ARRAY [1..MAX_UNIT_NUM] OF UINT;	
	
	atiTimeReadWatch : ARRAY [1..MAX_UNIT_NUM] OF LTIME;	
	
	iReadVirtualSts_UnitId : INT;
	
	alrBuff_Read2: ARRAY [1..MAX_UNIT_NUM,1..50] OF LREAL;

	adiReadCount: ARRAY [1..MAX_UNIT_NUM] OF DINT;	
	iK : INT;
	
	//altime : ARRAY [1..20] OF LTIME;
	
	iCountRes : INT;
	iCurrentNum_Start : INT;
	iCurrentNum_End : INT;
	
	//2026.02.04.170811 | + | 这里需要把方向处理一下，只有主从轴的方向不一致才需要把从轴方向改了
	axGantryAxisIsRev : ARRAY [1..20,1..2] OF BOOL;//最大20组龙门，每组龙门两个轴 
	iGantryAxisCount : INT;
	
	iUpdateEncPosStart : INT;
	iUpdateEncPosEnd : INT;
	
	iGetDriverStsAxis : INT;
	iGetStsCnt : INT;
END_VAR

{IMPLEMENTATION}
o_xEn:= i_xEn;
o_iErNo:= 0;
o_xAlarmStillOnline:= FALSE;(* 2022.3.15.125148/h/+ *)
o_xAlarmStillOnline:= FALSE;(* 2022.3.15.125148/h/+ *)
IF i_xEn THEN
	IF (i_iGrpId=1 OR i_iGrpId=2) AND
		i_byGrpUnitNum>=1 AND i_byGrpUnitNum<=MAX_UNIT_NUM AND
		i_pstStSysParam<>0 THEN
		IF i_iCycle_Time=0 THEN
			i_iCycle_Time:= gc_EXT_TSK_CYCLE_TIME;
		END_IF
		FOR iN:=1 TO i_iGrpAllStationNum BY 1 DO
// 			KS_HY_GetAxisIdForMotByStation(
// 				i_aiStationList[iN],
// 				ADR(iAxisId),
// 				ADR(iTypeId),
// 				ADR(iUnitId),
// 				ADR(iCoreId),
// 				ADR(iGroupId),
// 				ADR(iAdjAxisId),
// 				i_pastStAxisIdListInf
//				);
			KS_GetAxisIdForMotByStation_V2(
					i_iStationId:= i_aiStationList[iN],
					i_piAxisId:= ADR(iAxisId), 
					i_piTypeId:= ADR(iTypeId), 
					i_piUnitId:= ADR(iUnitId), 
					i_piCoreId:= ADR(iCoreId), 
					i_piGroupId:= ADR(iGroupId), 
					i_piAdjAxisId:= ADR(iAdjAxisId), 
					i_pstStSysStationInf:= i_pstStSysStationInf);
			(*报警处理*)
			IF NOT o_xClrAlarmSts THEN
				IF i_pastStGetMotionSts^[(iCoreId-1)* gc_ResCount_Profile +iAxisId].dwMotionSts.1 THEN(*bit1:报警*)
					IF abyAxisFailedCnt_ServoAlarm[iN]>5 THEN(*超过5个周期确定报警*)
//处理报警标志位		
						axAlarmFlag[iN]:= TRUE;
					ELSE
						abyAxisFailedCnt_ServoAlarm[iN]:= abyAxisFailedCnt_ServoAlarm[iN]+1;						
					END_IF
				ELSE
					abyAxisFailedCnt_ServoAlarm[iN]:= 0;
					IF axAlarmFlag[iN] THEN
						axAlarmFlag[iN]:= FALSE;
					END_IF
				END_IF
			END_IF
			Action_SysAlarmFlag();//报警标志赋值到全局变量
			o_xAlarmStillOnline:= o_xAlarmStillOnline OR axAlarmFlag[iN];
		END_FOR	
		xFaultInLinkageAxises:= FALSE;
		FOR iN:=1 TO i_byGrpUnitNum BY 1 DO
			iUnitId:= i_abyAxisList[iN];
			pstStUnitParam_Save:= ADR(i_pstStSysParam^.astStUnitParam_Save[iUnitId]);
			pstStUnitParam_UnSave:= ADR(i_pstStSysParam^.astStUnitParam_UnSave[iUnitId]);
			IF NOT pstStUnitParam_Save^.xLinkage THEN
				;
			ELSE
				IF pstStUnitParam_UnSave^.xAxisAlarm_PrnRoller OR 
					pstStUnitParam_UnSave^.xAxisAlarm_NetRoller OR 
					pstStUnitParam_UnSave^.xAxisAlarm_BottomRoller OR
					pstStUnitParam_UnSave^.xAxisAlarm_Horz OR 
					pstStUnitParam_UnSave^.xAxisAlarm_Prn_Pressure_M OR
					pstStUnitParam_UnSave^.xAxisAlarm_Prn_Pressure_G OR
					pstStUnitParam_UnSave^.xAxisAlarm_Net_Pressure_M OR 
					pstStUnitParam_UnSave^.xAxisAlarm_Net_Pressure_G OR
					pstStUnitParam_UnSave^.xAxisAlarm_Str_Pressure_M OR 
					pstStUnitParam_UnSave^.xAxisAlarm_Str_Pressure_G THEN
					(*色组内任意部位报警都当作急停处理吧*)
					(*but:压力电机报警可能不能急停？柔印时候再考虑一下*)
					IF NOT xFaultInLinkageAxises THEN
						xFaultInLinkageAxises:= TRUE;
					END_IF						
				END_IF
			END_IF
		END_FOR
		(*上面处理了色组报警-同时收放料收放牵也要处理*)
		IF i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xAxisAlarm_CENTRAL OR
			i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xAxisAlarm_If OR
			i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xAxisAlarm_Of OR
			i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xAxisAlarm_Uw_A OR
			i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xAxisAlarm_Uw_B OR
			i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xAxisAlarm_Rw_A OR
			i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xAxisAlarm_Rw_B THEN
			IF NOT xFaultInLinkageAxises THEN
				xFaultInLinkageAxises:= TRUE;
			END_IF	
		END_IF
		i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_LinkageAxisAlarm:= xFaultInLinkageAxises;
		(*到这里报警先处理完成了-下面处理提示信息*)
		(*是否出现报警再执行读取报警信息小指令？？先按每个周期都读吧*)
		iMsgId:= 0;
		iAlarm_TypeId := 0;
		iAlarm_UnitId := 0;
		Action_Msg_Alarm();
		Action_Msg_Tip();
		i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].iPromptMsg:= iMsgId;
		i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].iAlarm_TypeId:= iAlarm_TypeId;
		i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].iAlarm_UnitId:= iAlarm_UnitId;
(*到这里就结束了-下面需要增加复位逻辑和读取状态逻辑*)		
		Action_Alarm_ClearAndReset();
		Action_GrpGetMotionSts();
	END_IF
ELSE;
END_IF