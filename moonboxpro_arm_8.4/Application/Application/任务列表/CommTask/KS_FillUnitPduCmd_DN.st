(*@CES
Name=KS_FillUnitPduCmd_DN
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=77974849-7491-458e-a676-23f819d30e72
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_FillUnitPduCmd_DN : INT
VAR_INPUT
	i_iUnitId: INT; (* 色组id *)
	i_iGrpId_Comm: INT;(*系ID*)
	i_iCmdId: INT; (* 目前收纳61,62 *)
	i_wAxis_RollerDn: WORD;
	i_wAxis_Alarm_Prn: WORD;
	i_wComplexFlag_AxisInching: WORD;
	i_wComplexFlag_Linkage: WORD;
	i_pstStSysParam: POINTER TO StSysParam;	
	i_pstStParam_PDU_Dn: POINTER TO StParam_PDU_Dn;
END_VAR
VAR
	iResult: INT;
	dwSum_Tmp: DWORD;
	pstStCMD_91: POINTER TO StPdu_Dn_91;
	pstStCMD_92: POINTER TO StPdu_Dn_92;
	pstStCMD_93: POINTER TO StPdu_Dn_93;
	pstStCMD_94: POINTER TO StPdu_Dn_94;
	pstStCMD_95: POINTER TO StPdu_Dn_95;
	pstStUnitParam_Save: POINTER TO StUnitParam_Save;
	pstStUnitParam_UnSave: POINTER TO StUnitParam_UnSave;
	uiCtl_Sample: UINT;
	iN: INT;
	iM:INT;	
	byTemp: BYTE;
	dwTemp: DWORD;
	byGrpId: BYTE;
	uiTempCtl: UINT;
	
	dwControlComplexBits : DWORD;
	//xi.hy2026.5.9.105658
	pstStRSVUnitParam_UnSave:POINTER TO StRSV_UnitParam_UnSave;
	pstStRSVUnitParam_Save:POINTER TO StRSV_UnitParam_Save;	
END_VAR
{IMPLEMENTATION}
iResult:= 0;
IF KS_IsValidUnitNR(i_iUnitId) AND(*判断轴号有效的函数*)
	(i_iGrpId_Comm=1 OR i_iGrpId_Comm=2) AND
	i_pstStSysParam<>0 AND
	i_pstStParam_PDU_Dn<>0 THEN(* 入口参数ok *)

	pstStUnitParam_Save:= ADR(i_pstStSysParam^.astStUnitParam_Save[i_iUnitId]);
	pstStUnitParam_UnSave:= ADR(i_pstStSysParam^.astStUnitParam_UnSave[i_iUnitId]);
	//xi.hy2026.5.9.102547
	pstStRSVUnitParam_UnSave:=ADR(i_pstStSysParam^.astStRSV_UnitParam_UnSave[i_iUnitId]);
	pstStRSVUnitParam_Save:=ADR(i_pstStSysParam^.astStRSV_UnitParam_Save[i_iUnitId]);
	//xi.hy	
	IF pstStUnitParam_Save<>0 AND pstStUnitParam_UnSave<>0 AND pstStRSVUnitParam_UnSave<>0 AND pstStRSVUnitParam_Save<>0 THEN
		CASE i_iCmdId OF
		91:
			pstStCMD_91:= ADR(i_pstStParam_PDU_Dn^.abyPayload);
			IF pstStCMD_91<>0 THEN
				i_pstStParam_PDU_Dn^.byPkgId:= INT_TO_BYTE(i_iCmdId);
	
				pstStCMD_91^.byUnitId				    	:= (INT_TO_BYTE(i_iUnitId))+shl(INT_TO_byte(i_iGrpId_Comm),7);    
				pstStCMD_91^.rGirth_Sam				        := pstStUnitParam_Save^.rGirth_Sam;
				pstStCMD_91^.uiNum_Sam				        := pstStUnitParam_Save^.uiNum_Sam;
				pstStCMD_91^.uiDen_Sam				        := pstStUnitParam_Save^.uiDen_Sam;
				pstStCMD_91^.byCurrUsrLevel			        := i_pstStSysParam^.stStSysParam_UnSave.byCurrUsrLevel;
				pstStCMD_91^.iCompanyId				        := i_pstStSysParam^.stStSysParam_Save.iCustomerId;
				pstStCMD_91^.byLanguageId			        := i_pstStSysParam^.stStSysParam_Save.byLanguageId;
				pstStCMD_91^.byMinutes_ScrAutoSleep	        := i_pstStSysParam^.stStSysParam_Save.byMinutes_ScrSaver;
				pstStCMD_91^.wUnit_input_I			        := pstStUnitParam_UnSave^.wUnit_input_I;
				pstStCMD_91^.wUnit_input_II                 := pstStUnitParam_UnSave^.wUnit_input_II;
				pstStCMD_91^.wUnit_input_III                := pstStUnitParam_UnSave^.wUnit_input_III;
				pstStCMD_91^.wVelocity				        := REAL_TO_WORD(i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId_Comm].rVel_Cur*10.0);
				pstStCMD_91^.wVel_Axis                      := REAL_TO_WORD(pstStUnitParam_UnSave^.rAxisVel_PrnRoller*10.0);
				pstStCMD_91^.wAxis_RollerDn                 := i_wAxis_RollerDn;
				pstStCMD_91^.wAxis_Alarm_Prn                := i_wAxis_Alarm_Prn;
				pstStCMD_91^.dwAlarmCode				    := 0;
				pstStCMD_91^.wComplexFlag_AxisInching       := i_wComplexFlag_AxisInching;
				pstStCMD_91^.wComplexFlag_Linkage      		:= i_wComplexFlag_Linkage;
				//2026.04.10.151219 修改 dwAxisFlags_Estop
				//pstStCMD_91^.wComplexFlag_Estop	       		:= 0;
				pstStCMD_91^.wComplexFlag_Estop	       		:= i_pstStSysParam^.astStRSV_GrpParam_UnSave[i_iGrpId_Comm].dwAxisFlags_Estop;
				pstStCMD_91^.wHMI_SwitchSts		          	:= 0;
				pstStCMD_91^.wSts_HorzManuPreReg	      	:= pstStUnitParam_UnSave^.wSts_HorzManuPreReg;
				pstStCMD_91^.iPos_HorzManuPreReg	    	:= pstStUnitParam_UnSave^.iPos_HorzManuPreReg;
				
				byGrpId:= pstStUnitParam_Save^.byGrpId;
				pstStCMD_91^.bySts_Machine.0				:= i_pstStSysParam^.astStGrpParam_UnSave[byGrpId].xFlag_Print;
				pstStCMD_91^.bySts_Machine.1			:= 0;  //设备类型 0：凹印 暂时没找到合适的判断条件 先写0
				pstStCMD_91^.byErrSts_V	:= 0;//从站暂时只用纵向状态
				pstStCMD_91^.byErrSts_V.0:= pstStUnitParam_UnSave^.xArcErrIsAlarm_V;
				pstStCMD_91^.byErrSts_V.1:= pstStUnitParam_UnSave^.xArcErrIsLost_V;
				pstStCMD_91^.byErrSts_V.2:= pstStUnitParam_UnSave^.xArcErrIsFake_V;
// 				pstStCMD_91^.byErrSts_V.4:= pstStUnitParam_UnSave^.xArcErrIsAlarm_H;
// 				pstStCMD_91^.byErrSts_V.5:= pstStUnitParam_UnSave^.xArcErrIsLost_H;
// 				pstStCMD_91^.byErrSts_V.6:= pstStUnitParam_UnSave^.xArcErrIsFake_H;
// 				
				//2025.11.15.132421|增加低通滤波频率下发
				pstStCMD_91^.uilowpasscutoff_hz:= pstStUnitParam_Save^.uilowpasscutoff_hz;
				i_pstStParam_PDU_Dn^.wCHK:=
					KS_CRC(
						ADR(i_pstStParam_PDU_Dn^),
						SIZEOF(i_pstStParam_PDU_Dn^)-SIZEOF(i_pstStParam_PDU_Dn^.wCHK),
						ADR(dwSum_Tmp));
			ELSE
				iResult:= -i_iCmdId;
			END_IF
		92:
			pstStCMD_92:= ADR(i_pstStParam_PDU_Dn^.abyPayload);
			IF pstStCMD_92<>0 THEN
				i_pstStParam_PDU_Dn^.byPkgId:= INT_TO_BYTE(i_iCmdId);
				pstStCMD_92^.iCurveViewMaxRange		  		:= i_pstStSysParam^.stStSysParam_Save.iCurveViewMaxRange;
				pstStCMD_92^.bySignalGain                   := pstStUnitParam_Save^.bySignalGain;
				pstStCMD_92^.byMarkTypeId                   := INT_TO_BYTE(pstStUnitParam_Save^.iMarkTypeId);
				pstStCMD_92^.byMarkArrangeModalId           := INT_TO_BYTE(pstStUnitParam_Save^.iMarkArrangeMode);
				pstStCMD_92^.byFakeThreshold_V              := pstStUnitParam_Save^.byFakeThreshold_V;
				pstStCMD_92^.byFakeThreshold_H              := pstStUnitParam_Save^.byFakeThreshold_H; 
				pstStCMD_92^.rAlarm_V                       := pstStUnitParam_Save^.rAlr_V;
				pstStCMD_92^.rAlarm_H                       := pstStUnitParam_Save^.rAlr_H;
				//2026.4.11.151525 变量替换
				//pstStCMD_92^.byAve_v_extra_V                := pstStUnitParam_Save^.byAvg_V;
				pstStCMD_92^.byAve_v_extra_V                := pstStUnitParam_Save^.byAve_v_extra;
				pstStCMD_92^.byAve_v_extra_H                := pstStUnitParam_Save^.byAvg_H;
				pstStCMD_92^.iGateWidthPhy                  := pstStUnitParam_Save^.iGateWidthPhy;
				pstStCMD_92^.byTriangleMark_SideC           := i_pstStSysParam^.astStGrpParam_Save[i_iGrpId_Comm].byTriMark_SideC;
				pstStCMD_92^.byTriangleMark_SideB           := i_pstStSysParam^.astStGrpParam_Save[i_iGrpId_Comm].byTriMark_SideB;
				pstStCMD_92^.bySysSamplePrecision           := i_pstStSysParam^.astStGrpParam_Save[i_iGrpId_Comm].bySysSamplePrecision;
				pstStCMD_92^.byArcFineSampleType            := i_pstStSysParam^.astStGrpParam_Save[i_iGrpId_Comm].byArcFineSampleType;
				uiTempCtl:= 0;
				uiTempCtl.0:= TRUE;
				
				IF g_iMachineryType	= MACHINERYTYPE_FELXO_INLINE_ONEBOTOMROLLER THEN
					IF pstStUnitParam_UnSave^.xSamRev_BottomRoller THEN(*采样反转*)
						uiTempCtl.1:= TRUE;
					END_IF
				ELSE
					IF pstStUnitParam_UnSave^.xSamRev_PrnRoller THEN(*采样反转*)
						uiTempCtl.1:= TRUE;
					END_IF
				END_IF
				
				IF pstStUnitParam_Save^.uiNum_Sam= pstStUnitParam_Save^.uiDen_Sam THEN(*直驱*)
					uiTempCtl.2:= TRUE;
				END_IF
				IF pstStUnitParam_Save^.dwFlag_Ctl.9 THEN(*±10V*)
					uiTempCtl.15:= TRUE;					
				END_IF
				pstStUnitParam_UnSave^.iSampleCfgParam_ctl:= UINT_TO_INT(uiTempCtl);

				pstStCMD_92^.iSampleCfgParam_ctl            := pstStUnitParam_UnSave^.iSampleCfgParam_ctl;
				pstStCMD_92^.byColorIdCurrent               := pstStUnitParam_UnSave^.byColorIdCurrent;
				pstStCMD_92^.byColorIdFollow                := pstStUnitParam_Save^.byFollowColorId;
				pstStCMD_92^.abyColorIdList[i_iUnitId]	    := 0;
				//pstStCMD_92^.bySignalSelect                 := pstStUnitParam_Save^.bySignalSelect;
				pstStCMD_92^.xEnable_Arc                    := pstStUnitParam_Save^.xEnable_arc;
				//xi.hy2026.5.9.103716
				pstStCMD_92^.wDirAndMode_FiberMove                    := SHL(BYTE_TO_WORD(pstStRSVUnitParam_UnSave^.byFiberMoveMode),8) OR pstStRSVUnitParam_UnSave^.byFiberMoveDir;
				pstStCMD_92^.uiVel_FiberMove						:=REAL_TO_UINT(pstStRSVUnitParam_UnSave^.rFiberMoveVel*10);
				pstStCMD_92^.uiDistanceOut_FiberMove						:=REAL_TO_UINT(pstStRSVUnitParam_UnSave^.rFiberMoveDistanceOut*10);
				pstStCMD_92^.uiPulsePerCycle_FiberMove						:=pstStRSVUnitParam_Save^.uiFiberMovePulsePerCycle;
				
				i_pstStParam_PDU_Dn^.wCHK:=
				KS_CRC(
					ADR(i_pstStParam_PDU_Dn^),
					SIZEOF(i_pstStParam_PDU_Dn^)-SIZEOF(i_pstStParam_PDU_Dn^.wCHK),
					ADR(dwSum_Tmp));
			ELSE
				iResult:= -i_iCmdId;
			END_IF
	
		93:
			pstStCMD_93:= ADR(i_pstStParam_PDU_Dn^.abyPayload);
			IF pstStCMD_93<>0 THEN
				i_pstStParam_PDU_Dn^.byPkgId:= INT_TO_BYTE(i_iCmdId);
//2025.11.12.132025 | 赋值错误	
				//pstStCMD_93^.dwControlComplexBits	   		:= pstStUnitParam_Save^.dwCtlBits_UnitBaseCraft;
				pstStCMD_93^.dwControlComplexBits	   		:= dwControlComplexBits;
				pstStCMD_93^.wHz_UnitInkRoller_CurrWR       := REAL_TO_WORD(pstStUnitParam_UnSave^.rHz_UnitInkRoller_CurrWR*100.0);
				pstStCMD_93^.wHz_UnitScraper_CurrWR         := REAL_TO_WORD(pstStUnitParam_UnSave^.rHz_UnitScraper_CurrWR*100.0);
				pstStCMD_93^.wHz_UnitHotWind_CurrWR         := REAL_TO_WORD(pstStUnitParam_UnSave^.rHz_UnitHotWind_CurrWR*100.0);
				pstStCMD_93^.wHz_UnitHotWind2_CurrWR        := REAL_TO_WORD(pstStUnitParam_UnSave^.rHz_UnitHotWind2_CurrWR*100.0);
				pstStCMD_93^.rPV_UnitTemCtl                 := pstStUnitParam_UnSave^.rPV_UnitTemCtl;
				pstStCMD_93^.wSTS_UnitTemCtl                := pstStUnitParam_UnSave^.wSTS_UnitTemCtl;
//2026.02.07.141335增加扭矩和转速
				pstStCMD_93^.iTorque_NetRoller				:= i_pstStSysParam^.astStRSV_UnitParam_UnSave[i_iUnitId].iTorque_NetRoller;
				pstStCMD_93^.iTorque_PrnRoller				:= i_pstStSysParam^.astStRSV_UnitParam_UnSave[i_iUnitId].iTorque_PrnRoller;
				pstStCMD_93^.iTorque_BottomRoller				:= i_pstStSysParam^.astStRSV_UnitParam_UnSave[i_iUnitId].iTorque_BottomRoller;
				pstStCMD_93^.iTorque_Prn_PressRoller_M				:= i_pstStSysParam^.astStRSV_UnitParam_UnSave[i_iUnitId].iTorque_Prn_Press_M;
				pstStCMD_93^.iTorque_Prn_PressRoller_G				:= i_pstStSysParam^.astStRSV_UnitParam_UnSave[i_iUnitId].iTorque_Prn_Press_G;
				pstStCMD_93^.iTorque_Net_PressRoller_M				:= i_pstStSysParam^.astStRSV_UnitParam_UnSave[i_iUnitId].iTorque_Net_Press_M;
				pstStCMD_93^.iTorque_Net_PressRoller_G				:= i_pstStSysParam^.astStRSV_UnitParam_UnSave[i_iUnitId].iTorque_Net_Press_G;
				
				pstStCMD_93^.iVel_PrnRoller	:= i_pstStSysParam^.astStRSV_UnitParam_UnSave[i_iUnitId].iRpm_PrnRoller;
				pstStCMD_93^.iVel_NetRoller	:= i_pstStSysParam^.astStRSV_UnitParam_UnSave[i_iUnitId].iRpm_NetRoller;
				pstStCMD_93^.iVel_BottomRoller	:= i_pstStSysParam^.astStRSV_UnitParam_UnSave[i_iUnitId].iRpm_BottomRoller;
				//xi.hy2026.5.9.104711
				pstStCMD_93^.uiDistancePerCycle_FiberMove:=REAL_TO_UINT(pstStRSVUnitParam_Save^.rFiberMoveDistancePerCycle*100);
				
				
				i_pstStParam_PDU_Dn^.wCHK:=
				KS_CRC(
					ADR(i_pstStParam_PDU_Dn^),
					SIZEOF(i_pstStParam_PDU_Dn^)-SIZEOF(i_pstStParam_PDU_Dn^.wCHK),
					ADR(dwSum_Tmp));
			ELSE
				iResult:= -i_iCmdId;
			END_IF
	
		94:
			pstStCMD_94:= ADR(i_pstStParam_PDU_Dn^.abyPayload);
			IF pstStCMD_94<>0 THEN
				i_pstStParam_PDU_Dn^.byPkgId:= INT_TO_BYTE(i_iCmdId);
	
				pstStCMD_94^.rPos_M_Prn_HandWheelCtl		 := 0;
				pstStCMD_94^.rPos_G_Prn_HandWheelCtl         := 0;
				pstStCMD_94^.rPos_M_Net_HandWheelCtl         := 0;
				pstStCMD_94^.rPos_G_Net_HandWheelCtl         := 0;
				pstStCMD_94^.rPos_PrnRoller_Pressure_M       := pstStUnitParam_UnSave^.rPos_PrnRoller_Pressure_M;
				pstStCMD_94^.rPos_PrnRoller_Pressure_G       := pstStUnitParam_UnSave^.rPos_PrnRoller_Pressure_G;
				pstStCMD_94^.rPos_NetRoller_Pressure_M       := pstStUnitParam_UnSave^.rPos_NetRoller_Pressure_M;
				pstStCMD_94^.rPos_NetRoller_Pressure_G       := pstStUnitParam_UnSave^.rPos_NetRoller_Pressure_G;
				pstStCMD_94^.byCtlId_HandWheel               := 0;
				pstStCMD_94^.byCtlSts_HandWheel              := 0;
				pstStCMD_94^.wAxis_Alarm_Net                 := 0;
				pstStCMD_94^.wAxis_Alarm_Bottom              := 0;
				pstStCMD_94^.wAxis_Alarm_Prn_M               := 0;
				pstStCMD_94^.wAxis_Alarm_Prn_G               := 0;
				pstStCMD_94^.wAxis_Alarm_Net_M               := 0;
				pstStCMD_94^.wAxis_Alarm_Net_G               := 0;
				pstStCMD_94^.wAxis_Alarm_Other               := 0;
				
				
				i_pstStParam_PDU_Dn^.wCHK:=
				KS_CRC(
					ADR(i_pstStParam_PDU_Dn^),
					SIZEOF(i_pstStParam_PDU_Dn^)-SIZEOF(i_pstStParam_PDU_Dn^.wCHK),
					ADR(dwSum_Tmp));
			ELSE
				iResult:= -i_iCmdId;
			END_IF
			
		95:
			pstStCMD_95:= ADR(i_pstStParam_PDU_Dn^.abyPayload);
			IF pstStCMD_95<>0 THEN
				i_pstStParam_PDU_Dn^.byPkgId:= INT_TO_BYTE(i_iCmdId);
				(*2026.03.17.134758全自动套印*)
				pstStCMD_95^.byWidth_Mark_Max:= i_pstStSysParam^.astStRSV_UnitParam_UnSave[i_iUnitId].byWidth_Mark_Max;
				pstStCMD_95^.byWidth_Mark_Min:= i_pstStSysParam^.astStRSV_UnitParam_UnSave[i_iUnitId].byWidth_Mark_Min;
				pstStCMD_95^.byMaxGap:= i_pstStSysParam^.astStRSV_UnitParam_UnSave[i_iUnitId].byMaxGap;
				pstStCMD_95^.bySimilarityThreshold:= i_pstStSysParam^.astStRSV_UnitParam_UnSave[i_iUnitId].bySimilarityThreshold;
				pstStCMD_95^.bySpotWidth:=i_pstStSysParam^.astStRSV_UnitParam_UnSave[i_iUnitId].bySpotWidth;
				//pstStCMD_95^.bySignalType:= i_pstStSysParam^.astStRSV_UnitParam_UnSave[i_iUnitId].bySignalType;

				(*	bit0: xFlag_FindFirstMark; bit1: xFlag_FindPreMark; bit2: xFlag_AutoAdjust_Start*)
				pstStCMD_95^.byFlag_CommFromMaster:= i_pstStSysParam^.astStRSV_UnitParam_UnSave[i_iUnitId].byFlag_CommFromMaster;
				(*2026.05.20.192958||wang.xy添加内外滑窗系数通讯*)
				pstStCMD_95^.byInnerCoff:=  i_pstStSysParam^.astStRSV_UnitParam_UnSave[i_iUnitId].byInnerCoff;
				pstStCMD_95^.byOuterCoff:=  i_pstStSysParam^.astStRSV_UnitParam_UnSave[i_iUnitId].byOuterCoff;

				pstStCMD_95^.byMeanOffset:= i_pstStSysParam^.astStRSV_UnitParam_UnSave[i_iUnitId].byMeanOffset;
				FOR  iM:= 1 TO 4 BY 1 DO
					pstStCMD_95^.aiCurModeMidPoint[iM]:=i_pstStSysParam^.astStRSV_UnitParam_UnSave[i_iUnitId].aiCurModeMidPoint[iM];
					pstStCMD_95^.abyCurModeRadius[iM]:=i_pstStSysParam^.astStRSV_UnitParam_UnSave[i_iUnitId].abyCurModeRadius[iM];
					pstStCMD_95^.aiPreModeMidPoint[iM]:=i_pstStSysParam^.astStRSV_UnitParam_UnSave[i_iUnitId].aiPreModeMidPoint[iM];
					pstStCMD_95^.abyPreModeRadius[iM]:=i_pstStSysParam^.astStRSV_UnitParam_UnSave[i_iUnitId].abyPreModeRadius[iM];
				END_FOR	
				//pstStCMD_95^.abyRsv_95[1] := 0;
//2026.5.7.161737增加波形美化
				pstStCMD_95^.xRsMorphFilter:= i_pstStSysParam^.astStRSV_UnitParam_Save[i_iUnitId].xRsMorphFilter;
				i_pstStParam_PDU_Dn^.wCHK:=
				KS_CRC(
					ADR(i_pstStParam_PDU_Dn^),
					SIZEOF(i_pstStParam_PDU_Dn^)-SIZEOF(i_pstStParam_PDU_Dn^.wCHK),
					ADR(dwSum_Tmp));
			ELSE
				iResult:= -i_iCmdId;
			END_IF	ELSE
			iResult:= -2;
		END_CASE
	END_IF
ELSE
	iResult:= -1;
END_IF
KS_FillUnitPduCmd_DN:= iResult;
