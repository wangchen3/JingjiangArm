(*@CES
Name=Action_ActCtl
Type=Action
TypeGuid=8ac092e5-3128-4e26-9e7e-11016c6684f2
Guid=5e20cc05-66d9-4924-a1a5-ae306729f923
HasDeclaration=False
HasImplementation=True
*)
{DECLARATION}

{IMPLEMENTATION}

 IF g_xPrestart THEN
	iButtonCntPrestart:=iButtonCntPrestart+1;
	IF iButtonCntPrestart>=2 THEN	
		g_xPrestart:= FALSE;
		iButtonCntPrestart:= 0;
	END_IF
END_IF

IF g_xInk THEN
	g_xInk:= FALSE;
END_IF

IF g_xTension THEN
	iButtonCntTension:=iButtonCntTension+1;
	IF iButtonCntTension>=2 THEN	
		g_xTension:= FALSE;
		iButtonCntTension:= 0;
	END_IF
END_IF


IF g_xPrint THEN
	iButtonCntPrint:=iButtonCntPrint+1;
	IF iButtonCntPrint>=2 THEN
		g_xPrint:= FALSE;
		iButtonCntPrint:= 0;
	END_IF
END_IF

IF g_xStop THEN
	iButtonCntStop:=iButtonCntStop+1;
	IF iButtonCntStop>=2 THEN	
		g_xStop:= FALSE;
		iButtonCntStop:= 0;
	END_IF
END_IF


(*张力算法处理*)
(*放料张力控制*)
FOR iGrp:=1 TO 2 BY 1 DO(*A/B系操作*)
	(*处理一下收放料的IO索引*)

(*2025.8.11.171610处理一下系IO索引/收放料收放牵*)
	
	IF g_stStSysParam.stStSysParam_Save.dwEquipmentProf.20 THEN
	(* 双收双放 *)
	
		IF g_stStSysParam.stStSysParam_Save.dwEquipmentProf.21 THEN
			(* A放B收 *)
			iId_Uw_IO:= 1;
			iId_Rw_IO:= 2;
			IF g_stStSysParam.stStSysParam_UnSave.stStSysCfgStruct.stStAxisCfgStruct_IF_I.dwAxisProf.0 THEN
				iId_If_IO:= 1;
			END_IF
			IF g_stStSysParam.stStSysParam_UnSave.stStSysCfgStruct.stStAxisCfgStruct_OF_II.dwAxisProf.0 THEN
				iId_Of_IO:= 4;
			END_IF			
		ELSE
			(* A/B系各自用各自的 *)
			IF iGrp=1 THEN
				iId_Uw_IO:= 1;
				iId_Rw_IO:= 1;
				IF g_stStSysParam.stStSysParam_UnSave.stStSysCfgStruct.stStAxisCfgStruct_IF_I.dwAxisProf.0 THEN
					iId_If_IO:= 1;
				END_IF
				IF g_stStSysParam.stStSysParam_UnSave.stStSysCfgStruct.stStAxisCfgStruct_OF_I.dwAxisProf.0 THEN
					iId_Of_IO:= 2;
				END_IF					
			ELSE
				iId_Uw_IO:= 2;
				iId_Rw_IO:= 2;
				IF g_stStSysParam.stStSysParam_UnSave.stStSysCfgStruct.stStAxisCfgStruct_IF_II.dwAxisProf.0 THEN
					iId_If_IO:= 3;
				END_IF
				IF g_stStSysParam.stStSysParam_UnSave.stStSysCfgStruct.stStAxisCfgStruct_OF_II.dwAxisProf.0 THEN
					iId_Of_IO:= 4;
				END_IF					
			END_IF
		END_IF
	ELSE(* 普通机型\只看A系 *)
		iId_Uw_IO:= 1;
		iId_Rw_IO:= 1;
		IF g_stStSysParam.stStSysParam_UnSave.stStSysCfgStruct.stStAxisCfgStruct_IF_I.dwAxisProf.0 THEN
			iId_If_IO:= 1;
		END_IF
		IF g_stStSysParam.stStSysParam_UnSave.stStSysCfgStruct.stStAxisCfgStruct_OF_I.dwAxisProf.0 THEN
			iId_Of_IO:= 2;
		END_IF			
		IF iGrp=2 THEN
			EXIT;(*B系就不执行了吧*)
		END_IF
	END_IF
(*2025.8.23.090942*)
	FOR iN:=1 TO g_aiGrpUnitNum[iGrp] BY 1 DO
		aiGrpAxisList_Pu[iN]:= g_aiGrpAxisList[iGrp,iN];
	END_FOR
	
	(*伪随机序列实现放这里吧*)
	KS_PseudoRandom(
		g_stStSysParam.stStSysParam_Save.xPseudoRandomEn ,//i_xEn:= , 
		g_stStSysParam.stStSysParam_Save.xPseudoRandomStart, //i_xStart:= 
		g_byPseudoRandomSeries,//i_iSeries:= ,
		g_stStSysParam.stStSysParam_Save.rPseudoRandomAmplitude,//i_rAmplitude:= , 
		g_stStSysParam.stStSysParam_Save.byPseudoRandomRoundTimes,// i_byRoundTimes:= , 
		ADR(g_stStSysParam.astStGrpParam_UnSave[iGrp].xPseudoRandomTsting),// i_pxTesting:= , 
		ADR(g_stStSysParam.astStGrpParam_UnSave[iGrp].rPseudoRandomRoundAmplitude_Cur),// i_prCurAmplitude:= , 
		ADR(iPseudoRandomCurIndex),//i_piCurIndex:= , 
		ADR(g_stStSysParam.astStGrpParam_UnSave[iGrp].byPseudoRandomRoundTimes_Cur),
		g_stStSysParam.astStGrpParam_UnSave[iGrp].byPseudoRandomId,
		FALSE//pstStGrpParam^.xFlag_PTfifofull
		
	);// i_pbyCurTimes:= )
	g_stStSysParam.stStSysParam_Save.xPseudoRandomStart := FALSE;
	g_stStSysParam.astStGrpParam_UnSave[1].xPseudoRandomTsting;
	g_stStSysParam.astStGrpParam_UnSave[1].rPseudoRandomRoundAmplitude_Cur;
	g_stStSysParam.astStGrpParam_UnSave[1].byPseudoRandomRoundTimes_Cur;
	afbKS_FB_Func_UwRw[iGrp](
		i_xEn:= TRUE, 
		i_iGrpId:= iGrp, 
		i_pstStSysParam:= ADR(g_stStSysParam), 
		i_pstStEvtReq := ADR(g_astStEvtReq[iGrp]),
		i_iId_Uw_IO:= iId_Uw_IO, 
		i_iId_Rw_IO:= iId_Rw_IO,
		i_iGrpAxisNum_Pu:= g_aiGrpUnitNum[iGrp],
		i_aiGrpAxisList:= aiGrpAxisList_Pu,	
		i_pstStIOMap_Uw:=  ADR(g_astStIOMap_UwRw_FE_Uw[iId_Uw_IO]), 
		i_pstStIOMap_Rw:=  ADR(g_astStIOMap_UwRw_FE_Rw[iId_Rw_IO]) );
	afbKS_FB_Func_IfOf[iGrp](
		i_xEn:= TRUE, 
		i_iGrpId:= iGrp, 
		i_iIndex_MainIO_If:= iId_If_IO,
		i_iIndex_MainIO_Of:= iId_Of_IO,
		i_pastStIOMap_Main_FE:= ADR(g_astStIOMap_Main_FE),		
		i_pstStSysParam:= ADR(g_stStSysParam));

//2026.08.21.091102
(*2025.10.16.163427增加涂布功能处理|niu.j*)
	afbKS_FB_CoatingCTL[iGrp](
		i_xEn:= TRUE, 
		i_iGrpId:= iGrp,
		i_iGrpAxisNum_Pu:= g_aiGrpUnitNum[iGrp], 
		i_aiGrpAxisList:= aiGrpAxisList_Pu, 
		i_pastStIOMap_AxisBasic:= ADR(g_astStIOMap_Axis_FE), 
		i_pastStIOMap_AxisExtra:= ADR(g_astStIOMap_Axis_Extra_FE), 
		i_pstStCoatingAxisInf:= ADR(g_stStCoatingAxisInf), 
		i_pstStSysParam:= ADR(g_stStSysParam), 
		i_paxFlag_PressDne:= ADR(g_axFlag_PressDne), 
		i_palrGirth_CoatingPrn:= ADR(g_alrGirth_CoatingPrn), 
		i_palrAI_CoatingHMI:= ADR(g_alrAI_CoatingHMI)
	);	
		
	afbKS_FB_BandLen_Local[iGrp](
		i_xEn:= g_stStSysParam.stStSysParam_Save.iCustomerId = CUSTOMERNAME_QINHUA, 
		i_iGrpId:= iGrp, 
		i_iUnitNum:=g_stStSysParam.astStGrpParam_UnSave[iGrp].byGrpAxisNum_Pu , 
		i_pstStSysParam:= ADR(g_stStSysParam), 
		i_pastLatch:= ADR(g_astStLatch),
// 		i_pabyCurPos_Prn_M:= , 
// 		i_pabyCurPos_Prn_G:= , 
// 		i_paxArcMoveUp:= ADR(g_axArcMoveUp), 
// 		i_paxArcMoveDn:= ADR(g_axArcMoveDn), 
// 		i_palrEnc_Pos_Prn_M:= , 
// 		i_palrEnc_Pos_Prn_G:= , 
// 		i_xSrcDirectionMotRev:= ,
		i_pastStInteraction := ADR(g_astStInteraction),
		o_xEn=> , 
		o_iErrNo=> );
		
// 	afbKS_FB_CoatingCtl_OF[iGrp](
// 		i_xEn:= g_stStSysParam.stStSysParam_Save.iCustomerId = CUSTOMERNAME_QINHUA, 
// 		i_iGrpId:= iGrp, 
// 		i_xSwitchOn:= g_stStSysParam.stStSysParam_Save.dwCtlSwitchRef.3, 
// 		i_plrUsingGirth:= ADR(g_stStSysParam.astStGrpParam_Save[iGrp].rGirth_Of), 
// 		i_pastStIOMap_Main_FE:= ADR(g_astStIOMap_Main_FE),
// 		i_pastStIOMap_Axis_FE:= ADR(g_astStIOMap_Axis_FE), 
// 		i_pstStSysParam:= ADR(g_stStSysParam), 
// 		i_rPressure_Input:= g_lrTempOF_PrintingOut, 
// 		i_iKp:= g_iTensionAdjust_Kp, 
// 		i_iKi:= g_iTensionAdjust_Ki, 
// 		o_lrCur_PressureValue=> g_lrCur_PressureValue);

//2026.05.07.165005 | + | 新的数据保存
//数据保存-II
afbKS_FB_FillUpStruct_II[iGrp](
	i_xEn:= TRUE, 
	i_iGrpId:= iGrp, 
	i_pstStSysParam:= ADR(g_stStSysParam),
	i_pastStGetMotionSts:= ADR(g_astStGetMotionSts),  
	i_pastStSetPrm_Gear:= ADR(g_astStSetPrm),
	i_pastStSetPrm_GantryTrap:= ADR(g_astStSetPrm_GantryTrap), 
	i_pastStSetPrm_Trap:= ADR(g_astStSetPrm_Trap),
	i_pastStMotorParam_Vel:= ADR(astStMotorParam_Vel),  
	i_pastStMotorParam_GantryTrap:= ADR(astStMotorParam_GantryTrap),  
	i_pastStMotorParam_Trap:= ADR(astStMotorParam_Trap),  
	i_pstStSysStationInf:= ADR(g_stStSysStationInf),  
	i_pstStSysGantryAxisInf:= ADR(g_stStSysGantryAxisInf), 
	i_iGrpGearMotion_Num:= g_iAxisNum_Gear, 
	i_aiGrpGearMotion_StdList:= g_aiStationList_Gear, 
	i_iGrpGantryTrapMotion_Num:= g_iAxisNum_GantrayTrap, 
	i_aiGrpGantryTrapMotion_StdList:= g_aiStationList_GantrayTrap, 
	i_iGrpTrapMotion_Num:= g_iAxisNum_Trap, 
	i_aiGrpTrapMotion_StdList:= g_aiStationList_Trap, 
	i_pastStAxis_Sts_Display_Gear:= ADR(g_astStAxis_Sts_Display_Gear), 
	i_pastStAxis_Sts_Save_Gear:= ADR(g_astStAxis_Sts_Save_Gear), 
	i_pastStAxis_Sts_Display_GantryTrap:= ADR(g_astStAxis_Sts_Display_GantryTrap), 
	i_pastStAxis_Sts_Save_GantryTrap:= ADR(g_astStAxis_Sts_Save_GantryTrap), 
	i_pastStAxis_Sts_Display_Trap:= ADR(g_astStAxis_Sts_Display_Trap), 
	i_pastStAxis_Sts_Save_Trap:= ADR(g_astStAxis_Sts_Save_Trap));
	
afbKS_FB_StRecord_T_New_II[iGrp](
	i_xEn:= TRUE, 
	i_iGrpId:= iGrp, 
	i_pstStTravelDataRec:= g_pstStTravelDataRec, 
	i_pstStSysParam:= ADR(g_stStSysParam), 
	i_pstStIOMap_Uw:=ADR(g_astStIOMap_UwRw_FE_Uw[iId_Uw_IO] ), 
	i_pstStIOMap_Rw:=ADR(g_astStIOMap_UwRw_FE_Rw[iId_Rw_IO]) , 
	i_iIOGrpIdx_Uw := iId_Uw_IO, (* 放料组id *)
	i_iIOGrpIdx_Rw:= iId_Rw_IO,(* 收料组id *)
	i_xReflectionSensorValid:= g_stStSysParam.astStGrpParam_UnSave[iGrp].xReflectionSensorValid_Uw, 
	i_xUseAntiNotch_If:= g_stStSysParam.astStGrpParam_Save[iGrp].xUseAntiNotch_If, 
	i_lrStep_Uw:= g_stStSysParam.astStGrpParam_UnSave[iGrp].rForwardStep_Uw, 
	i_lrStep_Rw:= g_stStSysParam.astStGrpParam_UnSave[iGrp].rForwardStep_Rw, 
	i_lrStep_If:= g_stStSysParam.astStGrpParam_UnSave[iGrp].rForwardStep_If, 
	i_lrStep_Of:= g_stStSysParam.astStGrpParam_UnSave[iGrp].rForwardStep_Of, 
	i_wPreHotRollerFrq:= , 
	i_wWaterCoolRollerFrq:= , 
	i_lrKp_If:= g_stStSysParam.astStGrpParam_Save[iGrp].arKpid_If[1], 
	i_lrKi_If:= g_stStSysParam.astStGrpParam_Save[iGrp].arKpid_If[2], 
	i_lrKd_If:= g_stStSysParam.astStGrpParam_Save[iGrp].arKpid_If[3], 
	i_lrKp_Of:= g_stStSysParam.astStGrpParam_Save[iGrp].arKpid_Of[1], 
	i_lrKi_Of:= g_stStSysParam.astStGrpParam_Save[iGrp].arKpid_Of[2], 
	i_lrKd_Of:= g_stStSysParam.astStGrpParam_Save[iGrp].arKpid_Of[3], 
	i_rMainVel_Uw:= g_stStSysParam.astStGrpParam_UnSave[iGrp].rMainVel_Uw,
	i_rMainVel_Rw:= g_stStSysParam.astStGrpParam_UnSave[iGrp].rMainVel_Rw, 
	i_rDiamWuCompensate_Uw:= g_arDiamWuCompensate_Uw[iGrp],//g_stStSysParam.astStGrpParam_UnSave[iGrp].rWuCompensate_Act_Uw,// g_arDiamWuCompensate_Uw[iGrp], 
	i_rDiamWuCompensate_Rw:= g_arDiamWuCompensate_Rw[iGrp],//g_stStSysParam.astStGrpParam_UnSave[iGrp].rWuCompensate_Act_Rw,//g_arDiamWuCompensate_Rw[iGrp], 
	i_rEstiDia_LowPass_Uw:= g_arEstiDia_LowPass_Uw[iGrp], 
	i_rEstiDia_LowPass_Rw:= g_arEstiDia_LowPass_Rw[iGrp], 
	i_rAntiNotch_Out_If:= g_arAntiNotch_Out_If[iGrp], 
	i_rAntiNotch_Out_Uw:= g_arAntiNotch_Out_Uw[iGrp], 
	i_wAO_If_I:= g_astStIOMap_Main_FE[1].o_wAO_If, 
	i_wAO_Of_I:= g_astStIOMap_Main_FE[1].o_wAO_Of, 
	i_iPromptMsgId:= g_stStSysParam.astStGrpParam_UnSave[iGrp].iPromptMsg, 
	i_iMotionStepId:= , 
	i_iGrpGearMotion_Num:= g_iAxisNum_Gear, 
	i_aiGrpGearMotion_StdList:= g_aiStationList_Gear, 
	i_iGrpGantryTrapMotion_Num:= g_iAxisNum_GantrayTrap, 
	i_aiGrpGantryTrapMotion_StdList:= g_aiStationList_GantrayTrap, 
	i_iGrpTrapMotion_Num:= g_iAxisNum_Trap, 
	i_aiGrpTrapMotion_StdList:= g_aiStationList_Trap, 
	i_pastStAxis_Sts_Gear:= ADR(g_astStAxis_Sts_Save_Gear), 
	i_pastStAxis_Sts_GantryTrap:= ADR(g_astStAxis_Sts_Save_GantryTrap), 
	i_pastStAxis_Sts_Trap:= ADR(g_astStAxis_Sts_Save_Trap), 
	o_xEno=> , 
	o_iErNo=> );


(*		
//2025.11.28.101016 | 临时添加测试 | 
//2026.04.08.225402 | + | 增加牵引的数据保存	
aiGrpServoAxisList_IfOf[1] := 45;
aiGrpServoAxisList_IfOf[2] := 50;

(*张力数据保存*)
	afbKS_FB_StRecord_T[iGrp](
		i_xEn:= TRUE, 
		i_iGrpId:= 1, 
		i_pstStTravelDataRec:= g_pstStTravelDataRec, 
		i_pstStSysParam:= ADR(g_stStSysParam), 
		i_pstStIOMap_Uw:=ADR(g_astStIOMap_UwRw_FE_Uw[iId_Uw_IO] ), 
		i_pstStIOMap_Rw:=ADR(g_astStIOMap_UwRw_FE_Rw[iId_Rw_IO]) , 
		i_iGrpAxisTotalNum:= g_aiGrpUnitNum[iGrp], 
		i_aiGrpAxisList:= aiGrpAxisList_Pu, 
		i_iGrpServoAxisNum_Uw:= 2, 
		i_aiGrpServoAxisList_Uw:= , 
		i_iGrpServoAxisNum_Rw:= 2, 
		i_aiGrpServoAxisList_Rw:= , 
		i_iGrpServoAxisNum_IfOf := 2,
		i_aiGrpServoAxisList_IfOf := aiGrpServoAxisList_IfOf,
		i_iIOGrpIdx_Uw := iId_Uw_IO, (* 放料组id *)
		i_iIOGrpIdx_Rw:= iId_Rw_IO,(* 收料组id *)
		i_xReflectionSensorValid:= g_stStSysParam.astStGrpParam_UnSave[iGrp].xReflectionSensorValid_Uw, 
		i_xUseAntiNotch_If:= g_stStSysParam.astStGrpParam_Save[iGrp].xUseAntiNotch_If, 
		i_lrStep_Uw:= g_stStSysParam.astStGrpParam_UnSave[iGrp].rForwardStep_Uw, 
		i_lrStep_Rw:= g_stStSysParam.astStGrpParam_UnSave[iGrp].rForwardStep_Rw, 
		i_lrStep_If:= g_stStSysParam.astStGrpParam_UnSave[iGrp].rForwardStep_If, 
		i_lrStep_Of:= g_stStSysParam.astStGrpParam_UnSave[iGrp].rForwardStep_Of, 
		i_wPreHotRollerFrq:= , 
		i_wWaterCoolRollerFrq:= , 
		i_lrKp_If:= g_stStSysParam.astStGrpParam_Save[iGrp].arKpid_If[1], 
		i_lrKi_If:= g_stStSysParam.astStGrpParam_Save[iGrp].arKpid_If[2], 
		i_lrKd_If:= g_stStSysParam.astStGrpParam_Save[iGrp].arKpid_If[3], 
		i_lrKp_Of:= g_stStSysParam.astStGrpParam_Save[iGrp].arKpid_Of[1], 
		i_lrKi_Of:= g_stStSysParam.astStGrpParam_Save[iGrp].arKpid_Of[2], 
		i_lrKd_Of:= g_stStSysParam.astStGrpParam_Save[iGrp].arKpid_Of[3], 
		i_rMainVel_Uw:= g_stStSysParam.astStGrpParam_UnSave[iGrp].rMainVel_Uw,
		i_rMainVel_Rw:= g_stStSysParam.astStGrpParam_UnSave[iGrp].rMainVel_Rw, 
		i_rDiamWuCompensate_Uw:= g_arDiamWuCompensate_Uw[iGrp],//g_stStSysParam.astStGrpParam_UnSave[iGrp].rWuCompensate_Act_Uw,// g_arDiamWuCompensate_Uw[iGrp], 
		i_rDiamWuCompensate_Rw:= g_arDiamWuCompensate_Rw[iGrp],//g_stStSysParam.astStGrpParam_UnSave[iGrp].rWuCompensate_Act_Rw,//g_arDiamWuCompensate_Rw[iGrp], 
		i_rEstiDia_LowPass_Uw:= g_arEstiDia_LowPass_Uw[iGrp], 
	
		i_rEstiDia_LowPass_Rw:= g_arEstiDia_LowPass_Rw[iGrp], 
		
		i_rAntiNotch_Out_If:= g_arAntiNotch_Out_If[iGrp], 
		i_rAntiNotch_Out_Uw:= g_arAntiNotch_Out_Uw[iGrp], 
		i_wAO_If_I:= g_astStIOMap_Main_FE[1].o_wAO_If, 
		i_wAO_Of_I:= g_astStIOMap_Main_FE[1].o_wAO_Of, 
		i_iPromptMsgId:= g_stStSysParam.astStGrpParam_UnSave[iGrp].iPromptMsg, 
		i_iMotionStepId:= , 
		i_pastStGetMotionSts:= ADR(g_astStGetMotionSts), 
		i_pastStSetPrm:= ADR(g_astStSetPrm),
		i_pstStSysStationInf:=ADR(g_stStSysStationInf),
		i_aiGrpGearMotion_StdList:= g_aiStationList_Gear,
		o_xEno=> , 
		o_iErNo=> );
*)
	afbKS_FB_MotionCtl_New[iGrp](
		i_xEn:= TRUE, 
		i_iGrpId:= iGrp, 
		i_iGrpUnitNum_Pu:= g_stStSysParam.astStGrpParam_UnSave[iGrp].byGrpAxisNum_Pu, 
		i_aiGrpUnitList:= aiGrpAxisList_Pu, 
		i_iGrpGearMotion_Num:= INT_TO_BYTE(g_iAxisNum_Gear), 
		i_aiGrpGearMotion_StdList:= g_aiStationList_Gear, 
		i_pstStSysParam:= ADR(g_stStSysParam), 
		i_pastStAxisIdListInf:= ADR(g_astStAxisIdListInf), 
		i_rVel_VirtualMotion:= g_alrVel_VirtualAxis[iGrp], 
//		i_piMotionStep:= , 
		i_pastStSetPrm:= ADR(g_astStSetPrm),
		i_pstStGetPrm:= ADR(g_stStGetPrm), 
		i_pastStGetMotionSts:= ADR(g_astStGetMotionSts), 
		i_pastStMotorParam_Vel:= ADR(astStMotorParam_Vel), 
		i_pstStHYLogFifo:= g_pstStHYLogFifo, 
		i_diVel_Virtual_Tar:= g_adiVel_Virtual_Tar[iGrp], 
		i_lrMax_a_S_pos:= g_alrMax_a_S_pos[iGrp],
		i_pastStIOMap_Main_FE:= ADR(g_astStIOMap_Main_FE),
		i_pastStIOMap_Axis_FE:= ADR(g_astStIOMap_Axis_FE),
		i_pstStEvtReq := ADR(g_astStEvtReq[iGrp]),
		i_pawAxisVirtualCnt := ADR(g_awAxisVirtualCnt),
		i_pawAxisVirtualSts := ADR(g_awAxisVirtualSts),
		i_padiPreRegisterPos :=ADR(g_adiPreRegisterPos),
		i_palrMaxVel_PreReg := ADR(g_alrMaxVel_PreReg),
		i_pstStSysStationInf:=ADR(g_stStSysStationInf),
//2026.04.11.200400
		i_paxFlag_PressDne:= ADR(g_axFlag_PressDne),
		i_rVel_A:= g_arCur_A[1],
		i_rVel_Jerk:= g_arCur_Jerk[1],		
		
		o_iAxisId_Master=>iAxisId_Master,
		o_lrVel_VirtualAxis=>g_alrVel_VirtualAxis[iGrp],
		o_iErrAxisId=> g_iErrAxisId, 
		o_iErrTypeId=> g_iErrTypeId, 
		o_iErrUnitId=> g_iErrUnitId, 
		o_iErrCoreId=> g_iErrCoreId,
		o_iMoveErrCode=>g_stStSysParam.astStGrpParam_Save[iGrp].iMotionCtlErrCode, 		
		io_xMotionEnabled := g_axMotionEnabled[iGrp]);
		
	afbKS_FB_MotionCtl_GantryTrap[iGrp](
		i_xEn:= TRUE, 
		i_iGrpId:= iGrp, 
		i_iGrpUnitNum_Pu:= g_stStSysParam.astStGrpParam_UnSave[iGrp].byGrpAxisNum_Pu, 
		i_aiGrpUnitList:= aiGrpAxisList_Pu, 
		i_iGrpGantryTrapGroup_Num:= g_iAxisNum_GantrayTrap/2, 
		i_iGrpGantryTrapMotion_Num:= g_iAxisNum_GantrayTrap, 
		i_aiGrpGantryTrapMotion_StdList:= g_aiStationList_GantrayTrap, 
		i_pstStSysParam:= ADR(g_stStSysParam), 
		i_pastStAxisIdListInf:= ADR(g_astStAxisIdListInf), 
		i_pastStSetPrm:= ADR(g_astStSetPrm_GantryTrap), 
		i_pastStGetMotionSts:= ADR(g_astStGetMotionSts), 
		i_pastStMotorParam_GantryTrap:= ADR(astStMotorParam_GantryTrap), 
		i_pstStHYLogFifo:= g_pstStHYLogFifo, 
		i_pastStIOMap_Main_FE:= ADR(g_astStIOMap_Main_FE),
		i_pastStIOMap_Axis_FE:= ADR(g_astStIOMap_Axis_FE),
		i_pastStTrapAxisParam_Gantray:=ADR(g_astStTrapAxisParam_Gantray),
		i_pastStHandWheel := ADR(g_astStHandWheel),
		i_pastStHandWheel_BtnCtl := ADR(g_astStHandWheel_BtnCtl),
		i_pstStSysStationInf:=ADR(g_stStSysStationInf),
		i_pstStSysGantryAxisInf := ADR(g_stStSysGantryAxisInf),
		i_pstStEvtReq := ADR(g_astStEvtReq[iGrp])
);
		
		
	//2026.01.29.090831 | + | 增加点位控制	
	afbKS_FB_MotionCtl_Trap[iGrp](
		i_xEn:= TRUE, 
		i_iGrpId:= iGrp, 
		i_iGrpUnitNum_Pu:= g_stStSysParam.astStGrpParam_UnSave[iGrp].byGrpAxisNum_Pu, 
		i_aiGrpUnitList:= aiGrpAxisList_Pu, 
		i_iGrpTrapMotion_Num:= g_iAxisNum_Trap, 
		i_aiGrpTrapMotion_StdList:= g_aiStationList_Trap, 
		i_pstStSysParam:= ADR(g_stStSysParam),  
		i_pastStSetPrm:= ADR(g_astStSetPrm_Trap),  
		i_pastStGetMotionSts:= ADR(g_astStGetMotionSts), 
		i_pastStMotorParam_Trap:= ADR(astStMotorParam_Trap),  
		i_pstStHYLogFifo:= g_pstStHYLogFifo, 
		i_pastStIOMap_Main_FE:= ADR(g_astStIOMap_Main_FE),
		i_pastStIOMap_Axis_FE:= ADR(g_astStIOMap_Axis_FE), 
		i_pstStSysStationInf:= ADR(g_stStSysStationInf), 
		i_pstStSysGantryAxisInf:= ADR(g_stStSysGantryAxisInf), 
		i_xHorManuCtrl:= g_stStSysParam.astStGrpParam_Save[iGrp].xHorManuCtrl, (*界面横向手动修正功能*) 
		i_pastStAxisRapidAdjProf_H:=  ADR(g_astStAxisRapidAdjProf_H),
		i_paxLimit_Left_Wr	:= ADR(g_axLimit_Left_Wr),// 						: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF BOOL;
		i_paxLimit_Right_Wr	:= ADR(g_axLimit_Right_Wr),// 					: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF BOOL;
		i_paxLimit_Left_WrClr	:= ADR(g_axLimit_Left_WrClr),// 						: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF BOOL;
		i_paxLimit_Right_WrClr	:= ADR(g_axLimit_Right_WrClr),// 					: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF BOOL;
		i_pastStAxisIdListInf:= ADR(g_astStAxisIdListInf));
		
		
	//2026.03.14.113537 | + | 增加虚拟码盘异站功能
	iRtn := KS_VirtualEnc(
		i_xWrEn:= TRUE, 
		i_pxReSetEncCfg:= ADR(g_axReSetEncCfg[iGrp]), 
		i_byGrpId:= iGrp, 
		i_xIsDualUwRw:= g_stStSysParam.stStSysParam_Save.dwEquipmentProf.20, 
		i_xAsOneMachine:= g_stStSysParam.stStSysParam_Save.dwEquipmentProf.21, 
		i_iAxisIdManu:= g_stStSysParam.astStGrpParam_Save[iGrp].byStationIdDst_VirEnc, 
		i_iGrpAxisNum_Pu:= g_stStSysParam.astStGrpParam_UnSave[iGrp].byGrpAxisNum_Pu, 
		i_paiGrpAxisList:= ADR(aiGrpAxisList_Pu), 
		i_pstStSysParam:= ADR(g_stStSysParam), 
		i_pstStVirtualParamBak:= ADR(g_StVirtualParam), 
		i_piAxisId_Src:= ADR(g_aiVirtualEnc_AxisId_Src[iGrp]), 
		i_piAxisId_Des:= ADR(g_aiVirtualEnc_AxisId_Des[iGrp]), 
		i_puiSetEncCfgCnt:= ADR(g_auiSetVirtualEncCfgCnt[iGrp]), 
		i_piSetEncCfgRtn:= ADR(g_aiSetVirtualEncCfgRtn[iGrp]));		
END_FOR
//2026.5.8.111805调整逻辑放这里了
FOR iGrp:=1 TO 2 BY 1 DO
	IF iGrp=2 THEN EXIT; END_IF
	FOR iN:=1 TO MAX_UNIT_NUM BY 1 DO
		aiGrpAxisList[iN]:= g_aiGrpAxisList[iGrp,iN];
		aiStepAdj[iN]:= g_aiStepAdj[iGrp,iN];
	END_FOR
	afbKS_FB_AdjOutCtl[iGrp](
		i_xEn:= TRUE, 
		i_iGrpId:= iGrp, 
		i_pstStSysParam:= ADR(g_stStSysParam), 
		i_iGrpUnitNum:= g_aiGrpUnitNum[iGrp], 
		i_aiGrpAxisList:= aiGrpAxisList, 
		i_paiStepAdj:= ADR(aiStepAdj), 
		i_pstStSysStationInf := ADR(g_stStSysStationInf),
		i_pastStInteraction := ADR(g_astStInteraction),		
		o_xEn=> , 
		o_iErNo=> 
	);
	FOR iN:=1 TO MAX_UNIT_NUM BY 1 DO
		g_aiStepAdj[iGrp,iN]:= aiStepAdj[iN];
	END_FOR	
END_FOR

KS_ExportDatasetARC2TravelData(g_pstStDatasetARC, g_pstStTravelDataRec);

(*
(*获取张力部分的输入及电机运动流程的输入*)
fbKS_FB_MotionCtl(
	i_xEn:= TRUE, 
	//i_iGrpId := iGrp,
	i_iUnitMaxNum := g_stStSysParam.stStSysParam_Save.iUnitMaxNum,
	i_iAxisNumAll:= g_iAxisNum_All, 
	i_aiStationIdList:= g_aiStationList_All, 
	i_iAxisNum_Trap:= g_iAxisNum_Trap, 
	i_aiStationList_Trap:= g_aiStationList_Trap, 
	i_aiIndexList_All_Trap:= g_aiIndexList_All_Trap, 
	i_iAxisNum_Gear:= g_iAxisNum_Gear, 
	i_aiStationList_Gear:= g_aiStationList_Gear, 
	i_aiIndexList_All_Gear:= g_aiIndexList_All_Gear, 
	i_iAxisNum_GantrayTrap:= g_iAxisNum_GantrayTrap, 
	i_aiStationList_GantrayTrap:= g_aiStationList_GantrayTrap, 
	i_aiIndexList_All_Gantray:= g_aiIndexList_All_Gantray, 
	i_iAxisNum_Jog:= g_iAxisNum_Jog, 
	i_aiStationList_Jog:= g_aiStationList_Jog, 
	i_aiIndexList_All_Jog:= g_aiIndexList_All_Jog, 
	i_pstStSysParam:= ADR(g_stStSysParam), 
	i_pastStSetPrm:= ADR(g_astStSetPrm), 
	i_pstStGetPrm:= ADR(g_stStGetPrm), 
	i_pastTStTrapParamUser:=ADR(g_astTStTrapParamUser),
	i_pastTStJogParamUser:=ADR(g_astTStJogParamUser),
	i_pastTStGearParamUser:=ADR(g_astTStGearParamUser),	
	i_pastTStGantrayTrapParamUser:=ADR(g_astTStGantrayTrapParamUser),
	i_pastMcMultiFunction_UP:=ADR(g_astMotionSts),
	i_xFlag_Stop_En_Servo := g_xFlag_Stop_En_Servo,
	i_diVel_Virtual_Tar:=g_adiVel_Virtual_Tar[iGrp],//: INT;
	i_lrMax_a_S_pos:=g_alrMax_a_S_pos[iGrp],//: LREAL;
	i_lrTime_S:=g_alrTime_S[iGrp],// : LREAL;
	i_rGirth_Master := gc_rGirth_Master,
	o_xEn=> , 
	o_iErNo=> ,
	io_xMotionEnabled := g_axMotionEnabled[iGrp]);
*)
fbKS_FB_TravelFileService(
	i_xEn:= TRUE, 
	i_xLog_need:= TRUE, 
	i_xDat_need:= TRUE,
	i_xReq_safeclose:= xFlagEmergencyForFile_tmp (*OR g_xFlagEmergencyForFile_tmp*),(* 触发文件关闭的条件 *) 
	i_pxRst_protect:= ADR(g_xRst_fileProtect), 
	i_pstStSysParam:=ADR(g_stStSysParam),
(*deprecated@2025.8.27.164539/han.dp
	i_pstStTravelLogRec:= g_pstStTravelLogRec,
*) 
	i_pstStTravelDataRec:= g_pstStTravelDataRec, 
	o_xEno=> , 
	o_sFilename_datfile=> g_sFilename_datfile,
	o_sFilename_logfile=> g_sFilename_logfile,
	o_iErNo_datfile=> g_iErNo_datfile, 
	o_iErNo_logfile=> g_iErNo_logfile,
	o_xFileClosed_BecauseEmergency=> g_xFileClosed_BecauseEmergency );