(*@CES
Name=KS_FB_AdjOutCtl
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=10a69c96-c7b4-470c-9fd3-436c86473f4b
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_AdjOutCtl
VAR_INPUT
	i_xEn: BOOL;
	i_iGrpId:INT;
	i_pstStSysParam: POINTER TO StSysParam;
	i_iGrpUnitNum: INT;
	i_aiGrpAxisList: ARRAY [1..MAX_UNIT_NUM] OF INT; (*系的轴列表*)
	i_paiStepAdj: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF INT;
	i_iAxisNumAll : INT;
	i_pstStSysStationInf			:POINTER TO StSysStationInf;
	i_pastStInteraction : POINTER TO ARRAY [1..MAX_UNIT_NUM] OF StInteraction;	
END_VAR
VAR_OUTPUT
	o_xEn: BOOL;
	o_iErNo: INT;
END_VAR
VAR
	iN: INT;
	iM: INT;
	iK: INT;
	iRtn : INT;
	iUnitId: INT;
	iAxisId: INT;
	iGrp: INT;
	iType:INT;
	lrTemp: LREAL;

	axFlag_Adjing : ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	axFlag_PreReging: ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	axFlag_Inching: ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	fbTRIG_PreReg: R_TRIG;
	afbTRIG_Inch: ARRAY [1..MAX_UNIT_NUM] OF R_TRIG;
	rMaxAdjust: REAL;(*按设置的加速度先计算最大调整量，如果输入的调整量超过最大调整量，就需要重新设置加速度*)
	rTmp: REAL;
	arAcc_Out: ARRAY [1..MAX_UNIT_NUM] OF REAL;
	arAcc_Out_Pre: ARRAY [1..MAX_UNIT_NUM] OF REAL;
	aliPrfPos_Start: ARRAY [1..MAX_UNIT_NUM] OF LINT;(*启动运行时的规划位置*)
	
	rVel_Cur_In: REAL;(*当前速度-用于计算调整时间*)
	rVel_AutoAdj_In: REAL;(*自动调整速度*)
	rVel_ManuAdj_Corse_In: REAL;(*手动粗调速度*)
	rVel_ManuAdj_Fine_In: REAL;(*手动细调速度*)
	rVel_RapidAdj_In: REAL;(*快速调整速度*)
	arGirth_Adj_In: ARRAY [1..MAX_UNIT_NUM] OF REAL;(*调整的辊周长-*)
	auiNum_Adj_In: ARRAY [1..MAX_UNIT_NUM] OF UINT;(*调整的辊减速比分子-*)
	auiDen_Adj_In: ARRAY [1..MAX_UNIT_NUM] OF UINT;(*调整的辊减速比分母-*)
	axInching_In: ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	aliPrfPos_Target_In: ARRAY [1..MAX_UNIT_NUM] OF LINT;(*输入的规划位置*)
	arVel_Pre_In: ARRAY [1..MAX_UNIT_NUM] OF REAL;(*输入的规划速度*)
	adwAxisSts_Pre_In: ARRAY [1..MAX_UNIT_NUM] OF DWORD;(*输入的规划速度*)
	xFlag_Stop_In: BOOL;
	xFlag_EStop_In: BOOL;
	
	arTargetPos_Out: ARRAY [1..MAX_UNIT_NUM] OF REAL;(*计算的调整量pul*)
	arTargetVel_Out: ARRAY [1..MAX_UNIT_NUM] OF REAL;(*计算的调整速度pul/ms*)
	arTime_Cycle: ARRAY [1..MAX_UNIT_NUM] OF REAL;(*转一圈的时间ms*)
	
	arTime_Adj: ARRAY [1..MAX_UNIT_NUM] OF REAL;(*转一圈的时间ms*)
	alrExecutedAdjVal_Compensate_vh_In_Out: ARRAY [1..MAX_UNIT_NUM,1..2] OF LREAL;
	alrExecutedAdjVal_Coupling_vh_In_Out: ARRAY [1..MAX_UNIT_NUM,1..2] OF LREAL;
	alrExecutedAdjVal_ManuFine_vh_In_Out: ARRAY [1..MAX_UNIT_NUM,1..2] OF LREAL;
	alrExecutedAdjVal_ManuCoarse_vh_In_Out: ARRAY [1..MAX_UNIT_NUM,1..2] OF LREAL;
	alrExecutedAdjVal_Rapid_vh_In_Out: ARRAY [1..MAX_UNIT_NUM,1..2] OF LREAL;
	alrExecutedAdjVal_Auto_vh_In_Out: ARRAY [1..MAX_UNIT_NUM,1..2] OF LREAL;
	abyRapidAdjustStep_In_Out: ARRAY [1..MAX_UNIT_NUM] OF BYTE;
	
	
	//arAcc_TargetAxis_In_Out: ARRAY [1..MAX_UNIT_NUM] OF REAL;(*调整轴的加速度*)
	xFlag_Home_In_Out: BOOL;
	xFlag_PreRegister_In_Out: BOOL;
	xFlag_PhaseRestore_In_Out: BOOL;	
	alrTotalAdjustVal_Auto_vh_In_Out : ARRAY [1..MAX_UNIT_NUM,1..2] OF LREAL;(*自动调整量仓库*)
	alrTotalAdjustVal_Rapid_vh_In_Out: ARRAY [1..MAX_UNIT_NUM,1..2] OF LREAL;(*快速调整量仓库*)
	alrTotalAdjustVal_ManuCoarse_vh_In_Out: ARRAY [1..MAX_UNIT_NUM,1..2] OF LREAL;(*手动粗调调整量仓库*)
	alrTotalAdjustVal_ManuFine_vh_In_Out: ARRAY [1..MAX_UNIT_NUM,1..2] OF LREAL;(*手动细调调整量仓库*)
	alrTotalAdjustVal_Coupling_vh_In_Out: ARRAY [1..MAX_UNIT_NUM,1..2] OF LREAL;(*耦合量仓库*)
	alrTotalAdjustVal_Compensate_vh_In_Out: ARRAY [1..MAX_UNIT_NUM,1..2] OF LREAL;(*补偿量仓库*)
	adiPreRegisterPos_In_Out: ARRAY [1..MAX_UNIT_NUM] OF DINT;(*预套准/回原点/恢复相位需要执行的量*)
	
	astStSetPrm				: ARRAY [1..MAX_UNIT_NUM] OF TSetMultiMcFunctionPrm;
	astStSetPrm_Pre				: ARRAY [1..MAX_UNIT_NUM] OF TSetMultiMcFunctionPrm;
	
	stStGetPrm				: TMultiMcFunctionReadPrm;
	//g_alrVarValue				: ARRAY [1..200] OF LREAL;
	astMotionSts 				: ARRAY[1..MAX_UNIT_NUM] OF MotionSts;
	
	aliTarPos : ARRAY [1..MAX_UNIT_NUM] OF LINT;
	xInit : BOOL;
	lrTmp: LREAL;
	lrTmp1: LREAL;
	arCur_Adjust_Bak: ARRAY [1..MAX_UNIT_NUM] OF REAL;
	aiRtnSetMode : ARRAY [1..MAX_UNIT_NUM] OF INT;
	
	astTTrapPrm : ARRAY [1..MAX_UNIT_NUM] OF TTrapPrm;
	xTemp : BOOL;
	
	rAcc_TargetAxis_In_Out : REAL;
	rTime_Acc : REAL;
	axFlag_AdjStart: ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	
	axFlag_WriteData: ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	(*增加电机方向反向后调整量输出取反2025.9.17.095134*)
	axFlag_MoveRev_In: ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	dwNum: DWORD;
	dwRtn: DWORD;
	
	//2025.11.13.085146 | +
	astTrapPrm : ARRAY [1..MAX_UNIT_NUM] OF TTrapPrm;
	
	alTime : ARRAY [1..10] OF LTIME;
	
	(*2025-12-10 by sjw 非阻塞大指令*)
	FB_Set_StartMcMUltiFunction: GTMC_StartMcMultiFunction;
	bDoneSet: BOOL := TRUE;
	bBusySet: BOOL;
	bErrorSet: BOOL;
	iErrorIdSet: INT;
	
		
	iTypeId: INT;
	iCoreId: INT;
	iGroupId : INT;
	iAdjAxisId : INT;
END_VAR


{IMPLEMENTATION}
o_xEn:= i_xEn;
o_iErNo:= 0;
rAcc_TargetAxis_In_Out:= 20;
IF i_xEn THEN
	IF i_paiStepAdj<>0 AND i_pstStSysParam<>0 AND i_pstStSysStationInf <>0 AND i_pastStInteraction <> 0 
		AND (i_iGrpId=1 OR i_iGrpId=2) THEN
		Action_Input();
		fbTRIG_PreReg(CLK:= xFlag_Home_In_Out OR xFlag_PreRegister_In_Out OR xFlag_PhaseRestore_In_Out);
	
		FOR iN:=1 TO i_iGrpUnitNum BY 1 DO
			KS_GetAxisIdForMotByStation_V2(
				i_iStationId:= i_pstStSysParam^.astStUnitParam_Save[iN].iStationId,
				i_piAxisId:= ADR(iAxisId), 
				i_piTypeId:= ADR(iTypeId), 
				i_piUnitId:= ADR(iUnitId), 
				i_piCoreId:= ADR(iCoreId), 
				i_piGroupId:= ADR(iGroupId), 
				i_piAdjAxisId:= ADR(iAdjAxisId), 
				i_pstStSysStationInf:= i_pstStSysStationInf);
				
			afbTRIG_Inch[iUnitId](CLK:= axInching_In[iUnitId]);

			IF alrTotalAdjustVal_Auto_vh_In_Out[iUnitId,1]<>0 OR 
				alrTotalAdjustVal_Compensate_vh_In_Out[iUnitId,1]<>0 OR
				alrTotalAdjustVal_Coupling_vh_In_Out[iUnitId,1]<>0 THEN
				IF i_paiStepAdj^[iUnitId]<>STEP_IDIE THEN(*没有在空闲-调整中*)
					;(*考虑先按照原调整速度执行-不改变速度只增加调整量*)
				ELSE
					i_paiStepAdj^[iUnitId]:= STEP_AUTO;(*进入自动调整状态*)
				END_IF
				
			ELSIF alrTotalAdjustVal_Rapid_vh_In_Out[iUnitId,1]<>0 OR
					alrTotalAdjustVal_ManuCoarse_vh_In_Out[iUnitId,1]<>0 OR 
					alrTotalAdjustVal_ManuFine_vh_In_Out[iUnitId,1]<>0 THEN(*有调整量了*)
				(*手动调整量来了就不管什么状态了，单运行和预套准都是停机状态下的操作，不打架*)
				i_paiStepAdj^[iUnitId]:= STEP_MANU;(*进入手动调整状态*)
			END_IF 
			
			IF i_paiStepAdj^[iUnitId]=STEP_IDIE THEN(*到这里如果还在空闲可以考虑处理一下单运行和预套准*)
				IF fbTRIG_PreReg.Q THEN (*预套准等动作2025.8.18.135038*)
					i_paiStepAdj^[iUnitId]:= STEP_PREG;

				ELSIF afbTRIG_Inch[iUnitId].Q THEN	(*单运行要放这里吗？2025.8.18.135130*)
					i_paiStepAdj^[iUnitId]:= STEP_INCH;		
				END_IF					
			END_IF
			
			CASE i_paiStepAdj^[iUnitId] OF
				STEP_IDIE:
					;
					IF abyRapidAdjustStep_In_Out[iUnitId]=2 THEN
						abyRapidAdjustStep_In_Out[iUnitId]:= 0;
					END_IF			
				STEP_AUTO:
					IF alrTotalAdjustVal_Auto_vh_In_Out[iUnitId,1]<>0 OR 
						alrTotalAdjustVal_Coupling_vh_In_Out[iUnitId,1]<>0 OR
						alrTotalAdjustVal_Compensate_vh_In_Out[iUnitId,1]<>0 THEN(*细调*)
						lrTemp:= (alrTotalAdjustVal_Auto_vh_In_Out[iUnitId,1]+			
							alrTotalAdjustVal_Coupling_vh_In_Out[iUnitId,1]+
							alrTotalAdjustVal_Compensate_vh_In_Out[iUnitId,1])/1000.0/1000.0;(*单位m*)
							
						
						alrExecutedAdjVal_Compensate_vh_In_Out[iUnitId,1]:=alrTotalAdjustVal_Compensate_vh_In_Out[iUnitId,1];
						alrExecutedAdjVal_Coupling_vh_In_Out[iUnitId,1]:=alrTotalAdjustVal_Coupling_vh_In_Out[iUnitId,1];
						alrExecutedAdjVal_Auto_vh_In_Out[iUnitId,1]:=alrTotalAdjustVal_Auto_vh_In_Out[iUnitId,1];
	
		
						alrTotalAdjustVal_Auto_vh_In_Out[iUnitId,1]:= 0;
						alrTotalAdjustVal_Coupling_vh_In_Out[iUnitId,1]:= 0;
						alrTotalAdjustVal_Compensate_vh_In_Out[iUnitId,1]:= 0;	
						arTargetPos_Out[iUnitId]:= LREAL_TO_REAL(lrTemp*auiNum_Adj_In[iUnitId]*GC_LRMOTORPPR/arGirth_Adj_In[iUnitId]/auiDen_Adj_In[iUnitId]);(*单位脉冲*)
						(*计算调整速度-自动调整量需要一圈调整完成*)	
						IF rVel_Cur_In>1 THEN
							arTime_Cycle[iUnitId]:= 60.0*1000.0* arGirth_Adj_In[iUnitId]/rVel_Cur_In;
						END_IF
						IF rVel_Cur_In=0 THEN
							dwNum:= dwNum+1;
						END_IF
						IF arTime_Cycle[iUnitId]> 10 THEN
							arTime_Cycle[iUnitId]:= arTime_Cycle[iUnitId]-10;
						END_IF
						rMaxAdjust:= 0.5*0.5*rAcc_TargetAxis_In_Out*arTime_Cycle[iUnitId]*arTime_Cycle[iUnitId];
						IF ABS(arTargetPos_Out[iUnitId])>rMaxAdjust THEN
							IF 	arTargetPos_Out[iUnitId]>0 THEN
								arTargetPos_Out[iUnitId]:= rMaxAdjust;
							ELSE
								arTargetPos_Out[iUnitId]:= -rMaxAdjust;
							END_IF
							rTime_Acc:= arTime_Cycle[iUnitId]*0.5;
							arTargetVel_Out[iUnitId]:=rAcc_TargetAxis_In_Out*rTime_Acc+0.5;
	
							(*计算出了调整速度和调整量-就可以启动点位了*)
	//						i_paiStepAdj^[iUnitId]:= STEP_RUN;
							aliPrfPos_Start[iUnitId]:= aliPrfPos_Target_In[iUnitId];
							arCur_Adjust_Bak[iUnitId]:= arTargetPos_Out[iUnitId];
							axFlag_WriteData[iUnitId]:= FALSE;
						ELSE
	(*
							//知道调整量和调整时间，计算调整速度和加速度
							//S = a*t*t/4;
							//a = s*4/t/t;
							//v = at;
							arAcc_Out[iUnitId] := arTargetPos_Out[iUnitId]*4/arTime_Cycle[iUnitId]/arTime_Cycle[iUnitId];
							arTargetVel_Out[iUnitId] := arAcc_Out[iUnitId] * arTime_Cycle[iUnitId]*0.5 + 0.5;
	*)						
						(*计算最大速度*)
						(*一元二次方程x=(-b+SQRT(b²-4ac))/2a*)	
						(*调整量计算公式
						arTargetPos_Out=(arTime_Cycle+arTime_Cycle-2*rTime_Acc)*rAcc_TargetAxis_In_Out*rTime_Acc*0.5*)
							lrTmp1:= ABS(arTargetPos_Out[iUnitId]);
							lrTmp:= (REAL_TO_LREAL(rAcc_TargetAxis_In_Out)*REAL_TO_LREAL(rAcc_TargetAxis_In_Out)*
								REAL_TO_LREAL(arTime_Cycle[iUnitId]*arTime_Cycle[iUnitId]));
							lrTmp:= lrTmp-	REAL_TO_LREAL(4*(rAcc_TargetAxis_In_Out)*lrTmp1);
							lrTmp:= SQRT(lrTmp);
							lrTmp:= -1*rAcc_TargetAxis_In_Out*arTime_Cycle[iUnitId]+lrTmp;
							rTime_Acc:= lrTmp/(-2*rAcc_TargetAxis_In_Out);
							arTargetVel_Out[iUnitId]:=rAcc_TargetAxis_In_Out*rTime_Acc+0.5;
	
							(*计算出了调整速度和调整量-就可以启动点位了*)
	//						i_paiStepAdj^[iUnitId]:= STEP_RUN;
							aliPrfPos_Start[iUnitId]:= aliPrfPos_Target_In[iUnitId];
							arCur_Adjust_Bak[iUnitId]:= arTargetPos_Out[iUnitId];
							axFlag_WriteData[iUnitId]:= FALSE;
						END_IF
					END_IF				
				STEP_MANU:
					IF alrTotalAdjustVal_ManuFine_vh_In_Out[iUnitId,1]<>0 OR
						alrTotalAdjustVal_Rapid_vh_In_Out[iUnitId,1]<>0 OR
						alrTotalAdjustVal_ManuCoarse_vh_In_Out[iUnitId,1]<>0 THEN
						lrTemp:= (alrTotalAdjustVal_ManuFine_vh_In_Out[iUnitId,1]+
								alrTotalAdjustVal_Rapid_vh_In_Out[iUnitId,1]+
								alrTotalAdjustVal_ManuCoarse_vh_In_Out[iUnitId,1])/1000.0/1000.0;		
						
						alrExecutedAdjVal_ManuFine_vh_In_Out[iUnitId,1]:=alrTotalAdjustVal_ManuFine_vh_In_Out[iUnitId,1];
						alrExecutedAdjVal_Rapid_vh_In_Out[iUnitId,1]:=alrTotalAdjustVal_Rapid_vh_In_Out[iUnitId,1];
						alrExecutedAdjVal_ManuCoarse_vh_In_Out[iUnitId,1]:=alrTotalAdjustVal_ManuCoarse_vh_In_Out[iUnitId,1];
	
						alrTotalAdjustVal_ManuCoarse_vh_In_Out[iUnitId,1]:= 0;
						alrTotalAdjustVal_Rapid_vh_In_Out[iUnitId,1]:= 0;	
						alrTotalAdjustVal_ManuFine_vh_In_Out[iUnitId,1]:= 0;
						IF auiDen_Adj_In[iUnitId]<>0 AND arGirth_Adj_In[iUnitId]<>0 THEN
							arTargetPos_Out[iUnitId]:= lrTemp*auiNum_Adj_In[iUnitId]*GC_LRMOTORPPR/arGirth_Adj_In[iUnitId]/auiDen_Adj_In[iUnitId];(*单位脉冲*)

					(*固定调整速度2025.8.19.162530*)				
							arTargetVel_Out[iUnitId]:= rVel_RapidAdj_In*GC_LRMOTORPPR*auiNum_Adj_In[iUnitId]/auiDen_Adj_In[iUnitId]/
														(arGirth_Adj_In[iUnitId]*60*1000) + 0.5;
						ELSE
							dwNum:= dwNum+1;
						END_IF														
						//arAcc_Out[iUnitId] := 1;
						(*计算出了调整速度和调整量-就可以启动点位了*)
	//					i_paiStepAdj^[iUnitId]:= STEP_RUN;
						aliPrfPos_Start[iUnitId]:= aliPrfPos_Target_In[iUnitId];
						arCur_Adjust_Bak[iUnitId]:= arTargetPos_Out[iUnitId];
						axFlag_WriteData[iUnitId]:= FALSE;
// IF iUnitId=2 THEN						
// 	KS_HY_AddMsgToLog(g_pstStHYLogFifo, LOG_LEVEL_INFO, 'STEP_MANU!', BOOL_TO_STRING(axFlag_WriteData[iUnitId]));		
// END_IF			
					END_IF	
					(*手动调整过程中收到自动调整量就只计算调整量，不改变速度*)
					IF alrTotalAdjustVal_Auto_vh_In_Out[iUnitId,1]<>0 OR 
						alrTotalAdjustVal_Coupling_vh_In_Out[iUnitId,1]<>0 OR
						alrTotalAdjustVal_Compensate_vh_In_Out[iUnitId,1]<>0 THEN(*细调*)
						lrTemp:= (alrTotalAdjustVal_Auto_vh_In_Out[iUnitId,1]+			
							alrTotalAdjustVal_Coupling_vh_In_Out[iUnitId,1]+
							alrTotalAdjustVal_Compensate_vh_In_Out[iUnitId,1])/1000.0/1000.0;(*单位m*)
							
						
						alrExecutedAdjVal_Compensate_vh_In_Out[iUnitId,1]:=alrTotalAdjustVal_Compensate_vh_In_Out[iUnitId,1];
						alrExecutedAdjVal_Coupling_vh_In_Out[iUnitId,1]:=alrTotalAdjustVal_Coupling_vh_In_Out[iUnitId,1];
						alrExecutedAdjVal_Auto_vh_In_Out[iUnitId,1]:=alrTotalAdjustVal_Auto_vh_In_Out[iUnitId,1];
	
		
						alrTotalAdjustVal_Auto_vh_In_Out[iUnitId,1]:= 0;
						alrTotalAdjustVal_Coupling_vh_In_Out[iUnitId,1]:= 0;
						alrTotalAdjustVal_Compensate_vh_In_Out[iUnitId,1]:= 0;	
						IF auiDen_Adj_In[iUnitId]<>0 AND arGirth_Adj_In[iUnitId]<>0 THEN
							arTargetPos_Out[iUnitId]:= LREAL_TO_REAL(lrTemp*auiNum_Adj_In[iUnitId]*GC_LRMOTORPPR/arGirth_Adj_In[iUnitId]/auiDen_Adj_In[iUnitId]);(*单位脉冲*)
						ELSE
							dwNum:= dwNum+1;
						END_IF	
						(*计算调整速度-自动调整量需要一圈调整完成*)	
						axFlag_WriteData[iUnitId]:= FALSE;
					END_IF			
				STEP_PREG:
					;
				STEP_INCH:;
			ELSE
				i_paiStepAdj^[iUnitId]:= STEP_IDIE;
			END_CASE
	
			(*TRAP指令或者大指令？*)				
			//大指令
			(*先获取当前规划位置-用于判断到位标志*)
			IF i_paiStepAdj^[iUnitId]<>STEP_IDIE THEN
				IF NOT axFlag_WriteData[iUnitId] THEN
					IF arTargetVel_Out[iUnitId]<1 THEN(*点位运动最大速度设置不能小于1-
														而且输入是整型数据2025.9.12.113708*)
						arTargetVel_Out[iUnitId]:=1;
					END_IF			
				
					astStSetPrm[iUnitId].profileMode := 1;               
					astStSetPrm[iUnitId].prm.trapPrm.axis_id:=INT_TO_UINT(iAdjAxisId);            
					astStSetPrm[iUnitId].prm.trapPrm.axis_mode:=1;          
					astStSetPrm[iUnitId].prm.trapPrm.axis_ctrl:=3;   
					astStSetPrm[iUnitId].prm.trapPrm.reserve:=0;            
					astStSetPrm[iUnitId].prm.trapPrm.reserve2[1]:=0;        
					astStSetPrm[iUnitId].prm.trapPrm.reserve2[2]:=0;    
					(*2025.9.17.095241*)
					IF axFlag_MoveRev_In[iUnitId] THEN
						arTargetPos_Out[iUnitId]:= -arTargetPos_Out[iUnitId];
					END_IF
					aliTarPos[iUnitId] := aliTarPos[iUnitId] + REAL_TO_LINT(arTargetPos_Out[iUnitId]);
					IF arTargetVel_Out[iUnitId] <> 0 THEN
						arTime_Adj[iUnitId] := arTargetPos_Out[iUnitId] /arTargetVel_Out[iUnitId];
					END_IF
					
					arTargetPos_Out[iUnitId] := 0;
					
					astStSetPrm[iUnitId].prm.trapPrm.target_pos:=aliTarPos[iUnitId];
					astStSetPrm[iUnitId].prm.trapPrm.max_vel:=REAL_TO_UDINT(arTargetVel_Out[iUnitId]);
					
					axFlag_WriteData[iUnitId]:= TRUE;
// IF iUnitId=2 THEN						
// 	KS_HY_AddMsgToLog(g_pstStHYLogFifo, LOG_LEVEL_INFO, 'STEP_MANU!', LINT_TO_STRING(aliTarPos[iUnitId]));		
// END_IF					
				END_IF
				IF (arVel_Pre_In[iUnitId]<>0 AND (NOT axFlag_AdjStart[iUnitId])(*AND adwAxisSts_Pre_In[iUnitId].10*)) THEN
					axFlag_AdjStart[iUnitId]:= TRUE;
					//i_paiStepAdj^[iUnitId]:= STEP_RUN;	
// IF iUnitId=2 THEN						
// 	KS_HY_AddMsgToLog(g_pstStHYLogFifo, LOG_LEVEL_INFO, 'STEP_MANU!', BOOL_TO_STRING(axFlag_AdjStart[iUnitId]));		
// END_IF					
				END_IF		
	
				
				IF  ((arVel_Pre_In[iUnitId]=0) AND axFlag_AdjStart[iUnitId]) OR arTime_Adj[iUnitId] < 20.0(*AND (NOT adwAxisSts_Pre_In[iUnitId].10)*) THEN(*这里先换个方式把2025.9.1.201545再保存一下试试*)
// IF iUnitId=2 THEN						
// 	KS_HY_AddMsgToLog(g_pstStHYLogFifo, LOG_LEVEL_INFO, 'STEP_IDIE!', BOOL_TO_STRING(axFlag_AdjStart[iUnitId]));		
// END_IF
					i_paiStepAdj^[iUnitId]:= STEP_IDIE;
					arCur_Adjust_Bak[iUnitId]:= 0;
					(*用大指令把速度和位置清零|切换回空闲状态*)
					i_paiStepAdj^[iUnitId]:= STEP_IDIE; //直接切到空闲状态
					arTargetPos_Out[iUnitId]:= 0;
					arTargetVel_Out[iUnitId]:= 2;
					axFlag_AdjStart[iUnitId]:= FALSE;
					axFlag_WriteData[iUnitId]:= FALSE;	

				END_IF
			END_IF	
		END_FOR
		
		IF i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Print OR i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Ink THEN
			stStGetPrm.readCommandVarTableIndex := 5;
			stStGetPrm.readCount := 80;
			stStGetPrm.pVarValue := ADR(astMotionSts);
			dwRtn:= SysMemCmp(ADR(astStSetPrm),ADR(astStSetPrm_Pre),SIZEOF(astStSetPrm_Pre));
			//IF dwRtn<>0 THEN
			//修改非阻塞方式 2025-12-10 by sjw
			iRtn:=GTN_StartMcMultiFunction(1,INT_TO_UINT(i_iGrpUnitNum),1,ADR(astStSetPrm),ADR(stStGetPrm));
			(*
			IF bDoneSet  = TRUE AND bBusySet = FALSE THEN
				FB_Set_StartMcMUltiFunction(
				Execute:= TRUE, 
				Block:= TRUE, 
				core:= 1, 
				axisCount:= INT_TO_UINT(i_iGrpUnitNum), 
				writeEnable:= 1, 
				pSetPrm:= ADR(astStSetPrm), 
				pGetPrm:= ADR(stStGetPrm), 
				Done=> bDoneSet, 
				Busy=> bBusySet, 	
				Error=> bErrorSet, 
				ErrorID=> iErrorIdSet);
			END_IF
			*)
			//2025.11.13.085146 | + 
			IF iRtn <> 0 THEN
				KS_HY_AddMsgToLog(g_pstStHYLogFifo, LOG_LEVEL_INFO, 'GTN_StartMcMultiFunction Error!', INT_TO_STRING(iRtn));		
			END_IF
			//END_IF
			SysMemCpy(ADR(astStSetPrm_Pre),ADR(astStSetPrm),SIZEOF(astStSetPrm));
// 			alTime[1] := LTIME();
// 			iRtn:=GTN_StartMcMultiFunction(1,INT_TO_UINT(i_iGrpUnitNum),0,ADR(astStSetPrm),ADR(stStGetPrm));
// 			alTime[2] := LTIME();
		END_IF
		Action_Output();
	ELSE;
		
	END_IF
// 	IF (NOT xInit) AND (i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Print OR i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Ink) THEN
// 		//设置调整轴模式，参数初始化
// 		FOR iN := 1 TO MAX_UNIT_NUM BY 1 DO
// 			KS_GetAxisIdForMotByStation_V2(
// 				i_iStationId:= i_pstStSysParam^.astStUnitParam_Save[iN].iStationId,
// 				i_piAxisId:= ADR(iAxisId), 
// 				i_piTypeId:= ADR(iTypeId), 
// 				i_piUnitId:= ADR(iUnitId), 
// 				i_piCoreId:= ADR(iCoreId), 
// 				i_piGroupId:= ADR(iGroupId), 
// 				i_piAdjAxisId:= ADR(iAdjAxisId), 
// 				i_pstStSysStationInf:= i_pstStSysStationInf);	
// 		
// 			aliTarPos[iN] := 0;
// 			astStSetPrm[iN].profileMode := 1;               
// 			astStSetPrm[iN].prm.trapPrm.axis_id:=INT_TO_UINT(iAdjAxisId);            
// 			astStSetPrm[iN].prm.trapPrm.axis_mode:=1;          
// 			astStSetPrm[iN].prm.trapPrm.axis_ctrl:=3;   
// 			astStSetPrm[iN].prm.trapPrm.reserve:=0;            
// 			astStSetPrm[iN].prm.trapPrm.reserve2[1]:=0;        
// 			astStSetPrm[iN].prm.trapPrm.reserve2[2]:=0;        
// 			astStSetPrm[iN].prm.trapPrm.target_pos:=0;
// 			astStSetPrm[iN].prm.trapPrm.max_vel:=10;
// 			
// 			iRtn:= GTN_ClrSts(1,iAdjAxisId,1);
// 			iRtn:= GTN_ZeroPos(1,iAdjAxisId,1);
// 			iRtn := SetPrfTrapModePrm(
// 				i_iCoreId:= 1, 
// 				i_iAxisId:= iAdjAxisId, 
// 				i_lrVel:= 100,//i_pastTStTrapParamUser^[iCnt_TrapAxis].lrVel, 
// 				i_lrAcc:= 20.0,//i_pastTStTrapParamUser^[iCnt_TrapAxis].lrAcc, 
// 				i_lrDec:= 20.0,//i_pastTStTrapParamUser^[iCnt_TrapAxis].lrDec, 
// 				i_iSmoothTime:= 0);//i_pastTStTrapParamUser^[iCnt_TrapAxis].iSmoothTime)
// 		END_FOR
// 		xInit := TRUE;	
// 	END_IF
// 	 	
// 	IF xFlag_Stop_In OR xFlag_EStop_In THEN
// 		xInit := FALSE;		//2026.1.19.162953某个版本开始停机清主轴规划会把叠加轴规划也清除，需要清FIFO；		
// 		FOR iN := 1 TO MAX_UNIT_NUM BY 1 DO
// 			i_paiStepAdj^[iN]:= STEP_IDIE;	
// 			axFlag_Adjing[iN]:= FALSE;
// 			axFlag_PreReging[iN]:= FALSE;
// 			axFlag_Inching[iN]:= FALSE;
// 			axFlag_AdjStart[iN]:= FALSE;
// 		END_FOR		
// 	END_IF

	IF (NOT xInit) AND (i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Print OR i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Ink) THEN
		//设置调整轴模式，参数初始化
		FOR iN := 1 TO i_iGrpUnitNum BY 1 DO
			KS_GetAxisIdForMotByStation_V2(
				i_iStationId:= i_pstStSysParam^.astStUnitParam_Save[iN].iStationId,
				i_piAxisId:= ADR(iAxisId), 
				i_piTypeId:= ADR(iTypeId), 
				i_piUnitId:= ADR(iUnitId), 
				i_piCoreId:= ADR(iCoreId), 
				i_piGroupId:= ADR(iGroupId), 
				i_piAdjAxisId:= ADR(iAdjAxisId), 
				i_pstStSysStationInf:= i_pstStSysStationInf);	
		
			aliTarPos[iN] := 0;
			astStSetPrm[iN].profileMode := 1;               
			astStSetPrm[iN].prm.trapPrm.axis_id:=INT_TO_UINT(iAdjAxisId);            
			astStSetPrm[iN].prm.trapPrm.axis_mode:=1;          
			astStSetPrm[iN].prm.trapPrm.axis_ctrl:=2;   
			astStSetPrm[iN].prm.trapPrm.reserve:=0;            
			astStSetPrm[iN].prm.trapPrm.reserve2[1]:=0;        
			astStSetPrm[iN].prm.trapPrm.reserve2[2]:=0;        
			astStSetPrm[iN].prm.trapPrm.target_pos:=0;
			astStSetPrm[iN].prm.trapPrm.max_vel:=10;
			
			iRtn:= GTN_ClrSts(1,iAdjAxisId,1);
			iRtn:= GTN_ZeroPos(1,iAdjAxisId,1);
			iRtn := SetPrfTrapModePrm(
				i_iCoreId:= 1, 
				i_iAxisId:= iAdjAxisId, 
				i_lrVel:= 100,//i_pastTStTrapParamUser^[iCnt_TrapAxis].lrVel, 
				i_lrAcc:= 20.0,//i_pastTStTrapParamUser^[iCnt_TrapAxis].lrAcc, 
				i_lrDec:= 20.0,//i_pastTStTrapParamUser^[iCnt_TrapAxis].lrDec, 
				i_iSmoothTime:= 0);//i_pastTStTrapParamUser^[iCnt_TrapAxis].iSmoothTime)
		END_FOR
		
		stStGetPrm.readCommandVarTableIndex := 5;
		stStGetPrm.readCount := 0;
		stStGetPrm.pVarValue := ADR(astMotionSts);
		iRtn:=GTN_StartMcMultiFunction(1,INT_TO_UINT(i_iGrpUnitNum),1,ADR(astStSetPrm),ADR(stStGetPrm));
	
		xInit := TRUE;	
	END_IF
	 	
	IF (xFlag_Stop_In OR xFlag_EStop_In) AND xInit THEN
		xInit := FALSE;		//2026.1.19.162953某个版本开始停机清主轴规划会把叠加轴规划也清除，需要清FIFO；		
		FOR iN := 1 TO i_iGrpUnitNum BY 1 DO
			i_paiStepAdj^[iN]:= STEP_IDIE;	
			axFlag_Adjing[iN]:= FALSE;
			axFlag_PreReging[iN]:= FALSE;
			axFlag_Inching[iN]:= FALSE;
			axFlag_AdjStart[iN]:= FALSE;
			
			KS_GetAxisIdForMotByStation_V2(
				i_iStationId:= i_pstStSysParam^.astStUnitParam_Save[iN].iStationId,
				i_piAxisId:= ADR(iAxisId), 
				i_piTypeId:= ADR(iTypeId), 
				i_piUnitId:= ADR(iUnitId), 
				i_piCoreId:= ADR(iCoreId), 
				i_piGroupId:= ADR(iGroupId), 
				i_piAdjAxisId:= ADR(iAdjAxisId), 
				i_pstStSysStationInf:= i_pstStSysStationInf);	
		
			aliTarPos[iN] := 0;
			astStSetPrm[iN].profileMode := 1;               
			astStSetPrm[iN].prm.trapPrm.axis_id:=INT_TO_UINT(iAdjAxisId);            
			astStSetPrm[iN].prm.trapPrm.axis_mode:=1;          
			astStSetPrm[iN].prm.trapPrm.axis_ctrl:=2;   
			astStSetPrm[iN].prm.trapPrm.reserve:=0;            
			astStSetPrm[iN].prm.trapPrm.reserve2[1]:=0;        
			astStSetPrm[iN].prm.trapPrm.reserve2[2]:=0;        
			astStSetPrm[iN].prm.trapPrm.target_pos:=0;
			astStSetPrm[iN].prm.trapPrm.max_vel:=10;
			
			stStGetPrm.readCommandVarTableIndex := 5;
			stStGetPrm.readCount := 0;
			stStGetPrm.pVarValue := ADR(astMotionSts);
			iRtn:=GTN_StartMcMultiFunction(1,1,1,ADR(astStSetPrm[iN]),ADR(stStGetPrm));	
		END_FOR	
		iRtn:=GTN_StartMcMultiFunction(1,INT_TO_UINT(i_iGrpUnitNum),1,ADR(astStSetPrm),ADR(stStGetPrm));
	END_IF
ELSE;
END_IF

alTime[10] := alTime[2] - alTime[1] ;