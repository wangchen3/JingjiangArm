(*@CES
Name=KS_FUN_StartUp
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=0a4dbab5-cbac-4a4c-8a1e-d4e9ccc76a04
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_FUN_StartUp : BOOL
VAR_INPUT
END_VAR
VAR
	xWatch_xInitialized: BOOL := FALSE;
	iN: INT;	
	iM: INT;	
END_VAR

{IMPLEMENTATION}
IF NOT xWatch_xInitialized THEN
	g_pastAllAxisErrorTransfer:= ADR(g_astAllAxisErrorTransfer);
	FOR iN:= 1 TO MAX_UNIT_NUM BY 1 DO
		g_astStRegAdjMana[iN].iIdxWr:= 1;
		g_astStRegAdjMana[iN].iIdxRd:= 1;
		FOR iM:=1 TO GC_PU_MAX_NUM BY 1 DO
			g_astStRegAdjMana[iN].aiAdj_V[iM]:= 0;
			g_astStRegAdjMana[iN].aiAdj_H[iM]:= 0;	
		END_FOR
	END_FOR
	(*2024.7.10.165843 申请一些占用比较大的变量内存*)
	IF g_pstStGlobalVarByAllocMem=0 THEN
		g_pstStGlobalVarByAllocMem:=SysMemAlloc(SIZEOF(g_pstStGlobalVarByAllocMem^));
		IF g_pstStGlobalVarByAllocMem=0 THEN(*申请失败*);
			;
		ELSE
			SysMemSet(g_pstStGlobalVarByAllocMem,0,SIZEOF(g_pstStGlobalVarByAllocMem^));
		END_IF
	END_IF
	(* 2022.4.8.203241/hdp/(*2026.03.23.163304||wang.xy*)装载保存粗采样的内存区域申请 *)
	KS_InstallMem_RS(ADR(g_pstStRSampFifo));

	IF g_pstStGlobalVarByAllocMem<>0 THEN(**初始化*)
		FOR iN:=3 TO 16 BY 1 DO
			g_pstStGlobalVarByAllocMem^.stStDeCoupleCoeff.arCoeffU2[iN]:=1;
		END_FOR
		FOR iN:=4 TO 16 BY 1 DO
			g_pstStGlobalVarByAllocMem^.stStDeCoupleCoeff.arCoeffU3[iN]:=1;
		END_FOR
		FOR iN:=5 TO 16 BY 1 DO
			g_pstStGlobalVarByAllocMem^.stStDeCoupleCoeff.arCoeffU4[iN]:=1;
		END_FOR
		FOR iN:=6 TO 16 BY 1 DO
			g_pstStGlobalVarByAllocMem^.stStDeCoupleCoeff.arCoeffU5[iN]:=1;
		END_FOR
		FOR iN:=7 TO 16 BY 1 DO
			g_pstStGlobalVarByAllocMem^.stStDeCoupleCoeff.arCoeffU6[iN]:=1;
		END_FOR
		FOR iN:=8 TO 16 BY 1 DO
			g_pstStGlobalVarByAllocMem^.stStDeCoupleCoeff.arCoeffU7[iN]:=1;
		END_FOR
		FOR iN:=9 TO 16 BY 1 DO
			g_pstStGlobalVarByAllocMem^.stStDeCoupleCoeff.arCoeffU8[iN]:=1;
		END_FOR
		FOR iN:=10 TO 16 BY 1 DO
			g_pstStGlobalVarByAllocMem^.stStDeCoupleCoeff.arCoeffU9[iN]:=1;
		END_FOR
		FOR iN:=11 TO 16 BY 1 DO
			g_pstStGlobalVarByAllocMem^.stStDeCoupleCoeff.arCoeffU10[iN]:=1;
		END_FOR
		FOR iN:=12 TO 16 BY 1 DO
			g_pstStGlobalVarByAllocMem^.stStDeCoupleCoeff.arCoeffU11[iN]:=1;
		END_FOR
		FOR iN:=13 TO 16 BY 1 DO
			g_pstStGlobalVarByAllocMem^.stStDeCoupleCoeff.arCoeffU12[iN]:=1;
		END_FOR
		FOR iN:=14 TO 16 BY 1 DO
			g_pstStGlobalVarByAllocMem^.stStDeCoupleCoeff.arCoeffU13[iN]:=1;
		END_FOR
		FOR iN:=15 TO 16 BY 1 DO
			g_pstStGlobalVarByAllocMem^.stStDeCoupleCoeff.arCoeffU14[iN]:=1;
		END_FOR
	END_IF

	g_pstStTravelDataRec:= ADR(g_stStTravelDataRec);
	IF g_pstStTravelDataRec<>0 THEN
		g_pstStTravelDataRec^.uiRD:= 1;
		g_pstStTravelDataRec^.uiWR:= 1;
	END_IF
	
(*deprecated@2025.8.27.165125/han.dp
	g_pstStTravelLogRec:= ADR(g_stStTravelLogRec);(* 2023.11.23.141436/han.dp/这个内存在CoDeSys内部申请 *)
	IF g_pstStTravelLogRec<>0 THEN
		g_pstStTravelLogRec^.xOverwrite:= FALSE;
		g_pstStTravelLogRec^.uiIndex_Wr:= 1;
		g_pstStTravelLogRec^.uiIndex_Rd:= 1;
	END_IF	
*)

(* 2020.7.8.115737|申请大量全局内存 *)
	(* 申请并初始化套色实时数据的fifo *)
	g_pstStDatasetARC:= SysMemAlloc(SIZEOF(g_pstStDatasetARC^));
	IF g_pstStDatasetARC<>0 THEN
		g_pstStDatasetARC^.byIdxWr:= 0;
		g_pstStDatasetARC^.byIdxRd:= 0;
	END_IF	
	
//2026.5.28.144943这里针对机械参数进行初始化2026.5.28.144959
	g_pstStMechanicalParam_01:= ADR(g_stStSysParam.stStSysParam_Save.astStMechanicalParamBuf[1]);
	g_pstStMechanicalParam_02:= ADR(g_stStSysParam.stStSysParam_Save.astStMechanicalParamBuf[2]);
	g_pstStMechanicalParam_03:= ADR(g_stStSysParam.stStSysParam_Save.astStMechanicalParamBuf[3]);
	g_pstStMechanicalParam_05:= ADR(g_stStSysParam.stStSysParam_Save.astStMechanicalParamBuf[5]);
//	
	
	xWatch_xInitialized:= TRUE;
END_IF
KS_FUN_StartUp:= xWatch_xInitialized;