(*@CES
Name=KS_FB_AxisModeCtl
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=88b2c618-b0a1-49ee-8cb5-d949cd68b5c9
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_AxisModeCtl
VAR_INPUT
	i_xEn: BOOL;
	i_iGrpId: INT;
	i_iGrpUnitNum_Pu : INT;
	i_aiGrpUnitList: ARRAY [1..MAX_UNIT_NUM] OF INT;
	i_iGrpGearMotion_Num: INT;
	i_aiGrpGearMotion_StdList: ARRAY [1..MAX_STATION_NUM] OF INT;
	i_pstStSysParam: POINTER TO StSysParam;
	i_pastStAxisIdListInf :POINTER TO ARRAY [1..128] OF StAxisIdListInf;
	i_pastStMotorParam_Vel: POINTER TO ARRAY [1..MAX_STATION_NUM] OF StMotorParam_Vel;
	i_pstStSysStationInf			:POINTER TO StSysStationInf;
END_VAR
VAR_OUTPUT
END_VAR
VAR
	iN: INT;
	iAxisId: INT;
	iTypeId: INT;
	iUnitId: INT;
	iCoreId: INT;
	iGroupId : INT;
	iAdjAxisId : INT;
	pstStGrpParam_Save: POINTER TO StGrpParam_Save;
	pstStGrpParam_UnSave: POINTER TO StGrpParam_UnSave;
	
END_VAR

{IMPLEMENTATION}
IF i_xEn THEN
	IF (i_iGrpId=1 OR i_iGrpId=2) AND
		i_iGrpUnitNum_Pu>=1 AND i_iGrpUnitNum_Pu<=MAX_UNIT_NUM AND
		i_iGrpGearMotion_Num>=1 AND i_iGrpGearMotion_Num<= MAX_STATION_NUM AND
		i_pstStSysParam<>0 AND
		i_pastStAxisIdListInf<>0 AND
		i_pastStMotorParam_Vel<>0 AND
		i_pstStSysStationInf <> 0 THEN
		pstStGrpParam_Save:= ADR(i_pstStSysParam^.astStGrpParam_Save[i_iGrpId]);
		pstStGrpParam_UnSave:= ADR(i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId]);
		
		FOR iN:=1 TO i_iGrpGearMotion_Num BY 1 DO
// 			KS_HY_GetAxisIdForMotByStation(
// 				i_aiGrpGearMotion_StdList[iN],
// 				ADR(iAxisId),
// 				ADR(iTypeId),
// 				ADR(iUnitId),
// 				ADR(iCoreId),
// 				ADR(iGroupId),
// 				ADR(iAdjAxisId),
// 				i_pastStAxisIdListInf);	
			KS_GetAxisIdForMotByStation_V2(
					i_iStationId:= i_aiGrpGearMotion_StdList[iN],
					i_piAxisId:= ADR(iAxisId), 
					i_piTypeId:= ADR(iTypeId), 
					i_piUnitId:= ADR(iUnitId), 
					i_piCoreId:= ADR(iCoreId), 
					i_piGroupId:= ADR(iGroupId), 
					i_piAdjAxisId:= ADR(iAdjAxisId), 
					i_pstStSysStationInf:= i_pstStSysStationInf);	
			CASE iTypeId OF
			TYPE_MASTER_I,TYPE_MASTER_II:
				i_pastStMotorParam_Vel^[iN].iMotionMode:= 1;(*虚拟主轴JOG*)
			TYPE_CENTRAL_I,TYPE_CENTRAL_II:
				i_pastStMotorParam_Vel^[iN].iMotionMode:= 0;(*电子齿轮*)
			TYPE_UNWIND_A_I,TYPE_UNWIND_A_II,
			TYPE_UNWIND_B_I,TYPE_UNWIND_B_II,
			TYPE_REWIND_A_I,TYPE_REWIND_A_II,
			TYPE_REWIND_B_I,TYPE_REWIND_B_II:
				i_pastStMotorParam_Vel^[iN].iMotionMode:= 3;(*jog*)
(*2026.4.27.215845|收放料改用速度模式
			TYPE_UNWIND_A_I,TYPE_UNWIND_A_II:
				i_pastStMotorParam_Vel^[iN].iMotionMode:= 0;(*电子齿轮*)
				IF pstStGrpParam_UnSave^.xInching_Uw THEN
					i_pastStMotorParam_Vel^[iN].iMotionMode:= 1;(*收放料单运行就先按JOG走吧*)
				END_IF
			TYPE_UNWIND_B_I,TYPE_UNWIND_B_II:
				i_pastStMotorParam_Vel^[iN].iMotionMode:= 0;(*电子齿轮*)
				IF pstStGrpParam_UnSave^.xInching_Uw THEN
					i_pastStMotorParam_Vel^[iN].iMotionMode:= 1;(*收放料单运行就先按JOG走吧*)
				END_IF
			TYPE_REWIND_A_I,TYPE_REWIND_A_II:
				i_pastStMotorParam_Vel^[iN].iMotionMode:= 0;(*电子齿轮*)
				IF pstStGrpParam_UnSave^.xInching_Rw THEN
					i_pastStMotorParam_Vel^[iN].iMotionMode:= 1;(*收放料单运行就先按JOG走吧*)
				END_IF
			TYPE_REWIND_B_I,TYPE_REWIND_B_II:
				i_pastStMotorParam_Vel^[iN].iMotionMode:= 0;(*电子齿轮*)
				IF pstStGrpParam_UnSave^.xInching_Rw THEN
					i_pastStMotorParam_Vel^[iN].iMotionMode:= 1;(*收放料单运行就先按JOG走吧*)
				END_IF
*)	
			TYPE_INFEED_I,TYPE_INFEED_II:
				i_pastStMotorParam_Vel^[iN].iMotionMode:= 0;(*电子齿轮*)
				IF pstStGrpParam_UnSave^.xInching_If THEN
					i_pastStMotorParam_Vel^[iN].iMotionMode:= 1;(*单运行就先按JOG走吧*)
				END_IF
			TYPE_OUTFEED_I,TYPE_OUTFEED_II:
				i_pastStMotorParam_Vel^[iN].iMotionMode:= 0;(*电子齿轮*)
				IF pstStGrpParam_UnSave^.xInching_Of THEN
					i_pastStMotorParam_Vel^[iN].iMotionMode:= 1;(*单运行就先按JOG走吧*)
				END_IF
			TYPE_UNIT_PRN:
				i_pastStMotorParam_Vel^[iN].iMotionMode:= 0;(*电子齿轮*)
				
				IF pstStGrpParam_UnSave^.xFlag_Home OR pstStGrpParam_UnSave^.xFlag_PreRegister OR pstStGrpParam_UnSave^.xFlag_PhaseRead OR pstStGrpParam_UnSave^.xFlag_PhaseRestore THEN
					i_pastStMotorParam_Vel^[iN].iMotionMode:= 2;(*回原点等用点位*)
				END_IF
				(*版辊单运行还是按照电子齿轮走|方便执行印刷切换单联动标志*)
				//2025.10.28.104901 | bai.zy | 增加单运行
				IF pstStGrpParam_UnSave^.xFlag_AllInchRun OR i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].xAxisInching THEN
					i_pastStMotorParam_Vel^[iN].iMotionMode:= 1;(*电子齿轮*)
				END_IF
				
			TYPE_UNIT_BOTTOM:
				i_pastStMotorParam_Vel^[iN].iMotionMode:= 0;(*电子齿轮*)
				
				//柔印单伺服底辊
				IF g_iMachineryType	= MACHINERYTYPE_FELXO_INLINE_ONEBOTOMROLLER THEN
					IF pstStGrpParam_UnSave^.xFlag_Home OR pstStGrpParam_UnSave^.xFlag_PreRegister OR pstStGrpParam_UnSave^.xFlag_PhaseRead OR pstStGrpParam_UnSave^.xFlag_PhaseRestore THEN
						i_pastStMotorParam_Vel^[iN].iMotionMode:= 2;(*回原点等用点位*)
					END_IF
					(*版辊单运行还是按照电子齿轮走|方便执行印刷切换单联动标志*)
					//2025.10.28.104901 | bai.zy | 增加单运行
					IF pstStGrpParam_UnSave^.xFlag_AllInchRun OR i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].xAxisInching THEN
						i_pastStMotorParam_Vel^[iN].iMotionMode:= 1;(*电子齿轮*)
					END_IF
				END_IF
			TYPE_UNIT_NET:
				i_pastStMotorParam_Vel^[iN].iMotionMode:= 0;(*电子齿轮*)
				IF i_pstStSysParam^.astStRSV_UnitParam_UnSave[iUnitId].xInching_NetRoller THEN
					i_pastStMotorParam_Vel^[iN].iMotionMode:= 1;(*电子齿轮*)
				END_IF
			END_CASE
		END_FOR
	END_IF
ELSE
	;
END_IF