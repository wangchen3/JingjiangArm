(*@CES
Name=KS_FB_GetError_Arc
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=34f07fc4-d98c-4616-a827-05a7c8017d66
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_GetError_Arc
VAR_INPUT
	i_xEn: BOOL;
	i_iUnitMax: INT;
	i_byGetErrMode: BYTE;(*获取误差方式，
	1：读取金刚来的误差
	2：读取月光宝盒/月光宝盒PRO来的误差
	*)
	i_aiAlarm_V: ARRAY [1..MAX_UNIT_NUM] OF INT;(*后续换成全局输入的变量*)
	i_aiAlarm_H: ARRAY [1..MAX_UNIT_NUM] OF INT;(*后续换成全局输入的变量*)
	i_aiAdjust_V: ARRAY [1..MAX_UNIT_NUM] OF INT;(*修正量*)
	i_aiAdjust_H: ARRAY [1..MAX_UNIT_NUM] OF INT;(*修正量*)
	
	i_abyAverageNum_V: ARRAY [1..MAX_UNIT_NUM] OF BYTE;(*误差平均次数*)
	i_abyAverageNum_H: ARRAY [1..MAX_UNIT_NUM] OF BYTE;(*误差平均次数*)
	//2026.4.11.150236 误差显示平均
	i_abyAverageNum_V_Display: ARRAY [1..MAX_UNIT_NUM] OF BYTE;(*误差显示平均次数*)
	i_abyAverageNum_H_Display: ARRAY [1..MAX_UNIT_NUM] OF BYTE;(*误差显示平均次数*)
	i_pstStSysParam								: POINTER TO StSysParam;	
END_VAR
VAR_OUTPUT
	o_xEn: BOOL;
	o_iNoEr: INT;
	o_astStErrParam_Use: ARRAY [1..MAX_UNIT_NUM] OF StErrParam_Use;
END_VAR
VAR
	iN: INT;
	aiError_and_Sts_V: ARRAY [1..MAX_UNIT_NUM] OF INT;(*读取的来自金刚/月光宝盒PRO的误差及状态*)
	aiError_and_Sts_H: ARRAY [1..MAX_UNIT_NUM] OF INT;(*读取的来自金刚/月光宝盒PRO的误差及状态*)
	iTemp: WORD;
	aiError_V: ARRAY [1..MAX_UNIT_NUM] OF INT;(*处理完成后的纵向误差列表*)
	aiError_H: ARRAY [1..MAX_UNIT_NUM] OF INT;(*处理完成后的横向误差列表*)
	abyErrSts: ARRAY [1..MAX_UNIT_NUM] OF BYTE;(*处理完成后的纵横向误差状态*)
	abyIndex_V: ARRAY [1..MAX_UNIT_NUM] OF BYTE;(*处理完成后的索引*)
	abyIndex_H: ARRAY [1..MAX_UNIT_NUM] OF BYTE;(*处理完成后的索引*)
	axValid_V: ARRAY [1..MAX_UNIT_NUM] OF BOOL;(*误差有效性*)
	axValid_H: ARRAY [1..MAX_UNIT_NUM] OF BOOL;(*误差有效性*)
	axFlag_Refresh_V: ARRAY [1..MAX_UNIT_NUM] OF BOOL;(*误差刷新标志*)
	axFlag_Refresh_H: ARRAY [1..MAX_UNIT_NUM] OF BOOL;(*误差刷新标志*)
	axFlag_Check_V: ARRAY [1..MAX_UNIT_NUM] OF BOOL;(*误差校验位*)
	axFlag_Check_H: ARRAY [1..MAX_UNIT_NUM] OF BOOL;(*误差校验位*)
	axFlag_PreRefresh_V: ARRAY [1..MAX_UNIT_NUM] OF BOOL;(*误差有效性*)
	axFlag_PreRefresh_H: ARRAY [1..MAX_UNIT_NUM] OF BOOL;(*误差有效性*)
	afbKS_FB_PickOutFakePoint_V: ARRAY [1..MAX_UNIT_NUM] OF KS_FB_PickOutFakePoint;(*误差飞点处理*)
	afbKS_FB_PickOutFakePoint_H: ARRAY [1..MAX_UNIT_NUM] OF KS_FB_PickOutFakePoint;	
	afbKS_FB_AverageErr_Arc_V: ARRAY [1..MAX_UNIT_NUM] OF KS_FB_AverageErr_Arc;(*误差平均处理*)
	afbKS_FB_AverageErr_Arc_H: ARRAY [1..MAX_UNIT_NUM] OF KS_FB_AverageErr_Arc;	
	//2026.4.11.150050+
	afbKS_FB_AverageErr_Arc_V_Display: ARRAY [1..MAX_UNIT_NUM] OF KS_FB_AverageErr_Arc;(*误差平均处理@界面显示*)
	afbKS_FB_AverageErr_Arc_H_Display: ARRAY [1..MAX_UNIT_NUM] OF KS_FB_AverageErr_Arc;	
	
	aiError_V_Res_Display: ARRAY [1..MAX_UNIT_NUM] OF INT;(*处理完成后的纵向显示误差列表*)
	aiError_H_Res_Display: ARRAY [1..MAX_UNIT_NUM] OF INT;(*处理完成后的横向显示误差列表*)
	//2026.5.9.110955
	axFakePoint_V: ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	axFakePoint_H: ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	
	aiError_V_Res: ARRAY [1..MAX_UNIT_NUM] OF INT;(*处理完成后的纵向误差列表*)
	aiError_H_Res: ARRAY [1..MAX_UNIT_NUM] OF INT;(*处理完成后的横向误差列表*)
	abyIndex_V_Pre: ARRAY [1..MAX_UNIT_NUM] OF BYTE;(*处理完成后的索引*)
	abyIndex_H_Pre: ARRAY [1..MAX_UNIT_NUM] OF BYTE;(*处理完成后的索引*)
	iUnitNR: INT;
	iStationId: INT;
	dwOFST2: DWORD;
	iRtn: INT;
	stStProtocol_PDU_Up_Rd: StParam_PDU_Up;
	pstStCMD_F05_: POINTER TO StPdu_Up_05;
	pbyTemp: POINTER TO BYTE;
	wCHK_Up_Calc: WORD;
	dwCheckSumVal: DWORD;
	abyBuf_PduCmd_rcv: ARRAY [1..MAX_PDU_CMD_BYTES_UP] OF BYTE; (* 2021.12.4.163129/hdp/读取 *)
	xtest: BOOL;
	aiResult_VFollowpre_1stDerivate: ARRAY [1..MAX_UNIT_NUM] OF INT;
	
	//alTime: ARRAY [1..10] OF LTIME;
	abyBuf_PduCmd_rcv_All: ARRAY [1..1000] OF BYTE;
	
	//新飞点剔除:每色组纵横各一个独立实例(总开关gc_xUseNewFlyRemove在GCL)|Yang.zj+用于新飞点检测 2026.10.24.191149
	afbKS_FlyRemove_V: ARRAY [1..MAX_UNIT_NUM] OF KS_FlyRemove;
	afbKS_FlyRemove_H: ARRAY [1..MAX_UNIT_NUM] OF KS_FlyRemove;
	aiError_V_Fly: ARRAY [1..MAX_UNIT_NUM] OF INT;(*剔除后送平均的纵向误差*)
	aiError_H_Fly: ARRAY [1..MAX_UNIT_NUM] OF INT;(*剔除后送平均的横向误差*)
	xFlyNewFrame: BOOL;(*本周期该色组是否来了新帧*)
	xFlyReset: BOOL;(*该色组剔除器复位请求*)
	aiFlyMarkModePre: ARRAY [1..MAX_UNIT_NUM] OF INT;(*上次色标排列模式*)
	abyFlySignalPre: ARRAY [1..MAX_UNIT_NUM] OF BYTE;(*上次RGB信号通道*)
	axFlyHorEnPre: ARRAY [1..MAX_UNIT_NUM] OF BOOL;(*上次横向开关*)
END_VAR

{IMPLEMENTATION}
o_xEn:= i_xEn;
o_iNoEr:= 0;
IF i_xEn THEN
	IF i_iUnitMax>0 THEN
	CASE i_byGetErrMode OF
			1:
				FOR iN:=1 TO i_iUnitMax BY 1 DO
					iTemp:= aiError_and_Sts_V[iN];
					axValid_V[iN]:= INT_TO_BOOL(iTemp AND 16#04);(*bit2:有效位*)
					axFlag_Refresh_V[iN]:= INT_TO_BOOL(iTemp AND 16#02);(*bit1:刷新位*)
					axFlag_Check_V[iN]:= INT_TO_BOOL(iTemp AND 16#01);(*bit0:校验位*)	
					IF axFlag_PreRefresh_V[iN]<>axFlag_Refresh_V[iN] THEN	 	(*误差已刷新*)
						IF axValid_V[iN] THEN
							aiError_V[iN]:= SHR(iTemp,3);(*误差*)
						ELSE
							aiError_V[iN]:= gc_iValueReferToLost;
							abyErrSts[iN].1:= TRUE;(*纵向丢失*)
						END_IF
						abyIndex_V[iN]:= abyIndex_V[iN]+1;
					END_IF
					axFlag_PreRefresh_V[iN]:= axFlag_Refresh_V[iN];
					(*纵向误差处理完成*)					
					iTemp:= aiError_and_Sts_H[iN];
					axValid_H[iN]:= INT_TO_BOOL(iTemp AND 16#04);(*bit2:有效位*)
					axFlag_Refresh_H[iN]:= INT_TO_BOOL(iTemp AND 16#02);(*bit1:刷新位*)
					axFlag_Check_H[iN]:= INT_TO_BOOL(iTemp AND 16#01);(*bit0:校验位*)	
					IF axFlag_PreRefresh_H[iN]<>axFlag_Refresh_H[iN] THEN	 	(*误差已刷新*)
						IF axValid_H[iN] THEN
							aiError_H[iN]:= SHR(iTemp,3);(*误差*)
						ELSE
							aiError_H[iN]:= gc_iValueReferToLost;
							abyErrSts[iN].5:= TRUE;(*横向丢失*)
						END_IF
						abyIndex_H[iN]:= abyIndex_H[iN]+1;
					END_IF
					axFlag_PreRefresh_H[iN]:= axFlag_Refresh_H[iN];
					(*横向误差处理完成*)	
				END_FOR												
			2:
				//alTime[4] := LTIME();
				dwOFST2:= 0;
				iRtn := GTN_RN_UserPCRdLocalFPGA(
							1,1,
							0,//0,
							ADR(abyBuf_PduCmd_rcv_All),									 								
							DWORD_TO_WORD(dwOFST2), 
							KS_GetNumOfDwordUsed(INT_TO_DWORD(i_iUnitMax)*MAX_PDU_CMD_BYTES_DN));
				FOR iN:=1 TO i_iUnitMax BY 1 DO
					iUnitNR:= iN;(*通讯轴号也需要根据后续系统配置处理*)
					iStationId:= g_stStSysParam.stStSysParam_UnSave.aiStationList_UnitController[iN];(*2024.1.3.200541/+ *)
					IF KS_IsValidStationNR(iStationId) THEN
					(*读取从站即时上报的数据|每次32Bytes|*)
//2025.11.20.172237 
//						dwOFST2 := MAX_PDU_CMD_BYTES_DN*(iUnitNR-1);
// 						dwOFST2.14:= TRUE;(* 绝对地址访问 *)
(*						iRtn := GTN_RN_UserPCRdLocalFPGA(1,1,
									0,//INT_TO_BYTE(iStationId), 
									ADR(stStProtocol_PDU_Up_Rd), 								
									DWORD_TO_WORD(dwOFST2), 
									15);//16448
									*)
// 						iRtn := GTN_RN_UserPCRdLocalFPGA(
// 									ADR(stStProtocol_PDU_Up_Rd),
// 									0,//INT_TO_BYTE(iStationId), 									 								
// 									DWORD_TO_WORD(dwOFST2), 
// 									15);//16448
						
//2025.11.20.172246 
//						iRtn := GTN_RN_UserPCRdLocalFPGA(
// 									1,1,
// 									0,//0,
// 									ADR(abyBuf_PduCmd_rcv),									 								
// 									DWORD_TO_WORD(dwOFST2), 
// 									15);//16448
					dwOFST2 := MAX_PDU_CMD_BYTES_DN*(iUnitNR-1);
					
					SysMemCpy(ADR(stStProtocol_PDU_Up_Rd),ADR(abyBuf_PduCmd_rcv_All)+dwOFST2,SIZEOF(stStProtocol_PDU_Up_Rd));
					(*检查命令|*)
						pstStCMD_F05_:=0;
						
						pbyTemp:= ADR(stStProtocol_PDU_Up_Rd.byPkgId);
						wCHK_Up_Calc:= KS_CRC(pbyTemp, 46, ADR(dwCheckSumVal));(*51是wCHK之前的数据长度*)
						IF wCHK_Up_Calc=stStProtocol_PDU_Up_Rd.wCHK THEN (*CRC校验通过*)
							CASE stStProtocol_PDU_Up_Rd.byPkgId OF
								5:
								pstStCMD_F05_:= ADR(stStProtocol_PDU_Up_Rd.abyPayload);
								IF pstStCMD_F05_<>0 THEN
									aiError_V[iN]:= stStProtocol_PDU_Up_Rd.iErr_V_Raw;
									aiError_H[iN]:= stStProtocol_PDU_Up_Rd.iErr_H_Raw;
									abyIndex_V[iN]:= stStProtocol_PDU_Up_Rd.byIDX_V;
									abyIndex_H[iN]:= stStProtocol_PDU_Up_Rd.byIDX_H;
									IF aiError_V[iN]=gc_iValueReferToLost THEN
										abyErrSts[iN].1:= TRUE;(*纵向丢失*)
									ELSE
										axValid_V[iN]:= TRUE;
									END_IF
									IF aiError_H[iN]=gc_iValueReferToLost THEN
										abyErrSts[iN].5:= TRUE;(*横向丢失*)	
									ELSE
										axValid_H[iN]:= TRUE;
									END_IF
									o_astStErrParam_Use[iN].iResult_VFollowpre_1stDerivate:=
											pstStCMD_F05_^.iResult_VFollowpre_1stDerivate;
									aiResult_VFollowpre_1stDerivate[iN]:=	
											pstStCMD_F05_^.iResult_VFollowpre_1stDerivate;
									//2025.11.13.110235上传基线和峰值
									o_astStErrParam_Use[iN].uiBaseUse_t1:= pstStCMD_F05_^.uiBaseUse_t1;
									o_astStErrParam_Use[iN].uiBaseUse_t2:= pstStCMD_F05_^.uiBaseUse_t2;
									o_astStErrParam_Use[iN].uiPeakValue_t1:= pstStCMD_F05_^.uiPeakValue_t1;
									o_astStErrParam_Use[iN].uiPeakValue_t2:= pstStCMD_F05_^.uiPeakValue_t2;
								//2026.5.9.110642	
									i_pstStSysParam^.astStRSV_UnitParam_UnSave[iN].iCurLabelPos:= pstStCMD_F05_^.iCurLabelPos;(*本色三角标位置，点数*)
									i_pstStSysParam^.astStRSV_UnitParam_UnSave[iN].iPreLabelPos:= pstStCMD_F05_^.iPreLabelPos;(*前色三角标位置，点数*)
									i_pstStSysParam^.astStRSV_UnitParam_UnSave[iN].byFlag_CommFromSlave:= pstStCMD_F05_^.byFlag_CommFromSlave;(*bit0 xFlag_FindFirstSuccess;bit1 xFlag_FindPreSuccess*)
									i_pstStSysParam^.astStRSV_UnitParam_UnSave[iN].xFlag_FindFirstSuccess:= i_pstStSysParam^.astStRSV_UnitParam_UnSave[iN].byFlag_CommFromSlave.0;
									i_pstStSysParam^.astStRSV_UnitParam_UnSave[iN].xFlag_FindPreSuccess:= i_pstStSysParam^.astStRSV_UnitParam_UnSave[iN].byFlag_CommFromSlave.1;
									i_pstStSysParam^.astStRSV_UnitParam_UnSave[iN].byDetectedSignalCount:= pstStCMD_F05_^.byDetectedSignalCount;(*当前检测到色标个数*)
									i_pstStSysParam^.astStRSV_UnitParam_UnSave[iN].byMarkStep:= pstStCMD_F05_^.byMarkStep;(*当前全自动套印步骤*)
									i_pstStSysParam^.astStRSV_UnitParam_UnSave[iN].rGateSignalWidth_R:= BYTE_TO_REAL (pstStCMD_F05_^.byWidthRS) /10.0;(*粗采样计算波形宽度*)	
												
								END_IF
							END_CASE
						END_IF
					END_IF
				END_FOR			
				
			ELSE
			(*其他状态时，就先按丢失处理*)
				FOR iN:=1 TO MAX_UNIT_NUM BY 1 DO
					aiError_V[iN]:= gc_iValueReferToLost;
					aiError_H[iN]:= gc_iValueReferToLost;
					abyErrSts[iN].1:= TRUE;(*纵向丢失*)
					abyErrSts[iN].5:= TRUE;(*横向丢失*)
				END_FOR
		END_CASE
		
		(*从这里开始进行误差处理-飞点和平均*)
		(*飞点处理*)
	
		(*FOR iN:=1 TO MAX_UNIT_NUM BY 1 DO
			IF abyIndex_V_Pre[iN]<>abyIndex_V[iN] AND abyIndex_H_Pre[iN]<>abyIndex_H[iN] THEN				
				abyErrSts[iN]:= 0;
				axValid_V[iN]:= FALSE;
				axValid_H[iN]:= FALSE;
				IF aiError_V[iN]=gc_iValueReferToLost THEN
					abyErrSts[iN].1:= TRUE;(*纵向丢失*)
				ELSE
					axValid_V[iN]:= TRUE;
				END_IF
				IF aiError_H[iN]=gc_iValueReferToLost THEN
					abyErrSts[iN].5:= TRUE;(*横向丢失*)	
				ELSE
					axValid_H[iN]:= TRUE;
				END_IF
				o_astStErrParam_Use[iN].iResult_VFollowpre_1stDerivate:=
						aiResult_VFollowpre_1stDerivate[iN];			
			
			
				o_astStErrParam_Use[iN].byIDX_V:= abyIndex_V[iN];
				o_astStErrParam_Use[iN].byIDX_H:= abyIndex_H[iN];			
	//2026.02.08.195855			
				(*平均处理*)
				afbKS_FB_AverageErr_Arc_V[iN](
					i_xEn:= TRUE,
					i_iErr:= aiError_V[iN],
					i_xErrValid:= axValid_V[iN],(*2025.01.03.110017*)
					i_byAverageNum:= i_abyAverageNum_V[iN],
					o_iErrResult=>aiError_V_Res[iN]);
				axFakePoint_V[iN]:= FALSE;
				
				afbKS_FB_PickOutFakePoint_V[iN](
					i_xIsValidError:= axValid_V[iN],
					i_iError_0_01mm:= aiError_V_Res[iN],
					i_iVariationBaseValue:= 50,(*2025.01.03.110017*)
					i_iBoundaryError_0_01mm:= 20,
					i_iErrorLevel_0_01mm:= 25,
					i_iVariationVariationMin:= 5,
					i_iVariationVariationMax:= 50,
					o_xFakeIsConfirmed=> axFakePoint_V[iN]);
	//2026.02.08.195945						
				afbKS_FB_AverageErr_Arc_H[iN](
					i_xEn:= TRUE,
					i_iErr:= aiError_H[iN],
					i_xErrValid:= axValid_H[iN],(*2025.01.03.110017*)
					i_byAverageNum:= i_abyAverageNum_H[iN],
					o_iErrResult=>aiError_H_Res[iN]);			
				axFakePoint_H[iN]:= FALSE;

				afbKS_FB_PickOutFakePoint_H[iN](
					i_xIsValidError:= axValid_H[iN],
					i_iError_0_01mm:= aiError_H_Res[iN],
					i_iVariationBaseValue:= 50,
					i_iBoundaryError_0_01mm:= 20,
					i_iErrorLevel_0_01mm:= 25,
					i_iVariationVariationMin:= 5,
					i_iVariationVariationMax:= 50,
					o_xFakeIsConfirmed=> axFakePoint_H[iN]);	
			
		
				//显示平均@2026.4.11.150119+	
				afbKS_FB_AverageErr_Arc_V_Display[iN](
					i_xEn:= TRUE,
					i_iErr:= aiError_V[iN],
					i_xErrValid:= axValid_V[iN],(*2025.01.03.110017*)
					i_byAverageNum:= i_abyAverageNum_V_Display[iN],
					o_iErrResult=>aiError_V_Res_Display[iN]);
		
				afbKS_FB_AverageErr_Arc_H_Display[iN](
					i_xEn:= TRUE,
					i_iErr:= aiError_H[iN],
					i_xErrValid:= axValid_H[iN],(*2025.01.03.110017*)
					i_byAverageNum:= i_abyAverageNum_H_Display[iN],
					o_iErrResult=>aiError_H_Res_Display[iN]);	
					
						
			END_IF*)
		FOR iN:=1 TO MAX_UNIT_NUM BY 1 DO
			(*新飞点剔除:误差平均之前对原始逐帧误差剔除,成熟账本时为外推 P 并刷锁存，否则锁存,必须先剔除再平均,否则飞点被N幅平均稀释后可能低于门限漏掉*)
			(*总开关gc_xUseNewFlyRemove在GCL,置FALSE并重编译即回退旧逻辑;飞点/暂缓帧置axFakePoint_V/H(byErrSts.2/6),阶跃(真实变化)不置位|Yang.zj+用于新飞点检测 2026.10.24.191149*)
			IF gc_xUseNewFlyRemove THEN
				xFlyNewFrame:= (abyIndex_V_Pre[iN]<>abyIndex_V[iN]) AND (abyIndex_H_Pre[iN]<>abyIndex_H[iN]);
				(*工况切换检测:色标排列模式/RGB信号通道/横向开关任一变化,该色组剔除器可信历史不可信,复位重新暖机*)
				xFlyReset:= FALSE;
				IF i_pstStSysParam<>0 THEN
					IF (aiFlyMarkModePre[iN]<>i_pstStSysParam^.astStUnitParam_Save[iN].iMarkArrangeMode)
						OR (abyFlySignalPre[iN]<>i_pstStSysParam^.astStUnitParam_Save[iN].bySignalSelect)
						OR (axFlyHorEnPre[iN]<>i_pstStSysParam^.astStUnitParam_Save[iN].dwFlag_Ctl.0) THEN
						aiFlyMarkModePre[iN]:= i_pstStSysParam^.astStUnitParam_Save[iN].iMarkArrangeMode;
						abyFlySignalPre[iN]:= i_pstStSysParam^.astStUnitParam_Save[iN].bySignalSelect;
						axFlyHorEnPre[iN]:= i_pstStSysParam^.astStUnitParam_Save[iN].dwFlag_Ctl.0;
						xFlyReset:= TRUE;
					END_IF
				END_IF
				afbKS_FlyRemove_V[iN](
					i_iErr:= aiError_V[iN],
					i_xErrValid:= xFlyNewFrame AND (aiError_V[iN]<>gc_iValueReferToLost),
					i_xLost:= xFlyNewFrame AND (aiError_V[iN]=gc_iValueReferToLost),
					i_xReset:= xFlyReset,
					o_iErrResult=> aiError_V_Fly[iN],
					o_xFake=> axFakePoint_V[iN]);
				afbKS_FlyRemove_H[iN](
					i_iErr:= aiError_H[iN],
					i_xErrValid:= xFlyNewFrame AND (aiError_H[iN]<>gc_iValueReferToLost),
					i_xLost:= xFlyNewFrame AND (aiError_H[iN]=gc_iValueReferToLost),
					i_xReset:= xFlyReset,
					o_iErrResult=> aiError_H_Fly[iN],
					o_xFake=> axFakePoint_H[iN]);
			ELSE
				aiError_V_Fly[iN]:= aiError_V[iN];(*旧路径:不剔除,原值送平均*)
				aiError_H_Fly[iN]:= aiError_H[iN];
			END_IF
			IF abyIndex_V_Pre[iN]<>abyIndex_V[iN] AND abyIndex_H_Pre[iN]<>abyIndex_H[iN] THEN				
				abyErrSts[iN]:= 0;
				axValid_V[iN]:= FALSE;
				axValid_H[iN]:= FALSE;
				IF aiError_V[iN]=gc_iValueReferToLost THEN
					abyErrSts[iN].1:= TRUE;(*纵向丢失*)
				ELSE
					axValid_V[iN]:= TRUE;
				END_IF
				IF aiError_H[iN]=gc_iValueReferToLost THEN
					abyErrSts[iN].5:= TRUE;(*横向丢失*)	
				ELSE
					axValid_H[iN]:= TRUE;
				END_IF
				o_astStErrParam_Use[iN].iResult_VFollowpre_1stDerivate:=
						aiResult_VFollowpre_1stDerivate[iN];			
			
			
				o_astStErrParam_Use[iN].byIDX_V:= abyIndex_V[iN];
				o_astStErrParam_Use[iN].byIDX_H:= abyIndex_H[iN];			
//2026.02.08.195855			
				(*平均处理*)
				afbKS_FB_AverageErr_Arc_V[iN](
					i_xEn:= TRUE,
					i_iErr:= aiError_V_Fly[iN],(*新飞点:喂剔除后的值|Yang.zj+用于新飞点检测 2026.10.24.191149*)
					i_xErrValid:= axValid_V[iN],(*2025.01.03.110017*)
					i_byAverageNum:= i_abyAverageNum_V[iN],
					o_iErrResult=>aiError_V_Res[iN]);
				IF NOT gc_xUseNewFlyRemove THEN(*旧飞点判断:新算法启用时整块跳过|Yang.zj+用于新飞点检测 2026.10.24.191149*)
				axFakePoint_V[iN]:= FALSE;
				
				afbKS_FB_PickOutFakePoint_V[iN](
					i_xIsValidError:= axValid_V[iN],
					i_iError_0_01mm:= aiError_V_Res[iN],
					i_iVariationBaseValue:= 50,(*2025.01.03.110017*)
					i_iBoundaryError_0_01mm:= 20,
					i_iErrorLevel_0_01mm:= 25,
					i_iVariationVariationMin:= 5,
					i_iVariationVariationMax:= 50,
					o_xFakeIsConfirmed=> axFakePoint_V[iN]);
				END_IF
//2026.02.08.195945						
				afbKS_FB_AverageErr_Arc_H[iN](
					i_xEn:= TRUE,
					i_iErr:= aiError_H_Fly[iN],(*新飞点:喂剔除后的值|Yang.zj+用于新飞点检测 2026.10.24.191149*)
					i_xErrValid:= axValid_H[iN],(*2025.01.03.110017*)
					i_byAverageNum:= i_abyAverageNum_H[iN],
					o_iErrResult=>aiError_H_Res[iN]);			
				IF NOT gc_xUseNewFlyRemove THEN(*旧飞点判断:新算法启用时整块跳过|Yang.zj+用于新飞点检测 2026.10.24.191149*)
				axFakePoint_H[iN]:= FALSE;

				afbKS_FB_PickOutFakePoint_H[iN](
					i_xIsValidError:= axValid_H[iN],
					i_iError_0_01mm:= aiError_H_Res[iN],
					i_iVariationBaseValue:= 50,
					i_iBoundaryError_0_01mm:= 20,
					i_iErrorLevel_0_01mm:= 25,
					i_iVariationVariationMin:= 5,
					i_iVariationVariationMax:= 50,
					o_xFakeIsConfirmed=> axFakePoint_H[iN]);	
				END_IF
		
				//显示平均@2026.4.11.150119+	
				afbKS_FB_AverageErr_Arc_V_Display[iN](
					i_xEn:= TRUE,
					i_iErr:= aiError_V_Fly[iN],(*新飞点:喂剔除后的值|Yang.zj+用于新飞点检测 2026.10.24.191149*)
					i_xErrValid:= axValid_V[iN],(*2025.01.03.110017*)
					i_byAverageNum:= i_abyAverageNum_V_Display[iN],
					o_iErrResult=>aiError_V_Res_Display[iN]);
		
				afbKS_FB_AverageErr_Arc_H_Display[iN](
					i_xEn:= TRUE,
					i_iErr:= aiError_H_Fly[iN],(*新飞点:喂剔除后的值|Yang.zj+用于新飞点检测 2026.10.24.191149*)
					i_xErrValid:= axValid_H[iN],(*2025.01.03.110017*)
					i_byAverageNum:= i_abyAverageNum_H_Display[iN],
					o_iErrResult=>aiError_H_Res_Display[iN]);				
			END_IF
			(*到这里误差的飞点和平均都处理完了，该处理其他东西了*)
			o_astStErrParam_Use[iN].iErr_V_Unprocessed:= aiError_V[iN];(*原始误差*)
			o_astStErrParam_Use[iN].iErr_H_Unprocessed:= aiError_H[iN];
			o_astStErrParam_Use[iN].byErrSts:= 0;
			o_astStErrParam_Use[iN].byErrSts:= abyErrSts[iN];(*现在的状态*)
			
//2026.5.9.110835处理一下显示平均相关			
			IF NOT o_astStErrParam_Use[iN].byErrSts.1 THEN(*纵向未丢失*)
				o_astStErrParam_Use[iN].iErr_V:= aiError_V_Res[iN]-i_aiAdjust_V[iN];
				//2026.4.11.150603+
				o_astStErrParam_Use[iN].iErr_V_Display:= aiError_V_Res_Display[iN]-i_aiAdjust_V[iN];
				IF axFakePoint_V[iN] THEN(*飞点*)
					o_astStErrParam_Use[iN].byErrSts.2:= TRUE;
				END_IF
				(*报警标志检查*)
				//IF ABS(o_astStErrParam_Use[iN].iErr_V)>ABS(i_aiAlarm_V[iN]) THEN
				IF ABS(o_astStErrParam_Use[iN].iErr_V_Display)>ABS(i_aiAlarm_V[iN]) THEN
					o_astStErrParam_Use[iN].byErrSts.0:= TRUE;
				END_IF
			ELSE
				o_astStErrParam_Use[iN].iErr_V:= gc_iValueReferToLost;
				o_astStErrParam_Use[iN].iErr_V_Display:= gc_iValueReferToLost;					
			END_IF
			IF NOT o_astStErrParam_Use[iN].byErrSts.5 THEN(*横向未丢失*)
				o_astStErrParam_Use[iN].iErr_H:= aiError_H_Res[iN]-i_aiAdjust_H[iN];(*处理完的误差-修正量*)	
				//2026.4.11.150603+
				o_astStErrParam_Use[iN].iErr_H_Display:= aiError_H_Res_Display[iN]-i_aiAdjust_H[iN];		
				IF axFakePoint_H[iN] THEN(*飞点*)
					o_astStErrParam_Use[iN].byErrSts.6:= TRUE;
				END_IF
				(*报警标志检查*)
				//IF ABS(o_astStErrParam_Use[iN].iErr_H)>ABS(i_aiAlarm_H[iN]) THEN
				IF ABS(o_astStErrParam_Use[iN].iErr_H_Display)>ABS(i_aiAlarm_H[iN]) THEN
					o_astStErrParam_Use[iN].byErrSts.4:= TRUE;
				END_IF		
			ELSE
				o_astStErrParam_Use[iN].iErr_H:= gc_iValueReferToLost;	
				//2026.4.11.150603+
				o_astStErrParam_Use[iN].iErr_H_Display:= gc_iValueReferToLost;			
			END_IF				
			abyIndex_V_Pre[iN]:= abyIndex_V[iN];
			abyIndex_H_Pre[iN]:= abyIndex_H[iN];
		END_FOR	
	END_IF	
END_IF
