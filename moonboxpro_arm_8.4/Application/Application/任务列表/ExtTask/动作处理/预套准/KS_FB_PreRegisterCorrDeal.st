(*@CES
Name=KS_FB_PreRegisterCorrDeal
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=d37d2e52-5732-4406-aa4d-f154e1ea1a79
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_PreRegisterCorrDeal
(*2024.01.15.151146 将总的调整量修改为接口*)
VAR_INPUT
	i_xEn:BOOL;(*功能块使能*)
	i_iGrpId:int;(*系号*)
	i_iGrpAxisNum_Pu: INT; (*色组轴数量*)
	i_paiGrpAxisList: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF INT; (*系内所有轴的列表*)
	i_pstStSysParam: POINTER TO StSysParam;
	i_palrTotalAdjustVal_V:POINTER TO ARRAY [1..MAX_UNIT_NUM] OF LREAL;(*套色总的调整量|mm*)
END_VAR
VAR_OUTPUT
	o_xEn:BOOL;(**)
END_VAR
VAR
	alrTotalCorrectVal: ARRAY [1..MAX_UNIT_NUM] OF LREAL;
	fbTrig_PreRegister_end: R_TRIG;
	xFlag_AutoGetCorr: BOOL;
	xFlag_PringBak: BOOL;(*上个周期的印刷标志*)
END_VAR
{IMPLEMENTATION}
IF (i_iGrpId=1 OR i_iGrpId=2) AND
	i_pstStSysParam<>0 AND
	i_paiGrpAxisList<>0 AND
	i_palrTotalAdjustVal_V<>0 THEN(*2024.01.15.151230*)
	IF i_xEn THEN
		
		fbTrig_PreRegister_end(CLK:=i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_PreRegister_end);
		IF fbTrig_PreRegister_end.Q THEN(*预套准完成，置位自动获取修正量标志|*)
			xFlag_AutoGetCorr:=TRUE;
		END_IF

		IF xFlag_AutoGetCorr THEN
			IF xFlag_PringBak AND NOT i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Print THEN(*退出印刷状态*)
				(*复位自动获取标志*)
				xFlag_AutoGetCorr:=FALSE;
				(*置位确认标志|用于界面显示*)
				g_axCorrectConfirmBtnDisplay[i_iGrpId]:=TRUE;
			END_IF
		END_IF
		xFlag_PringBak:=i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Print;

		IF g_axPreRegisterCorrConfirm[i_iGrpId] THEN(*修正量确认按钮按下*)
			g_axCorrectConfirmBtnDisplay[i_iGrpId]:=FALSE;
		END_IF

		KS_GetCorrect_PreRegister_Auto(
			xFlag_AutoGetCorr(*i_xAutoGetCorr*),
			ADR(g_axPreRegisterCorrConfirm[i_iGrpId])(*i_pxWrPreRegisterCorr*),
			i_iGrpAxisNum_Pu(*i_iGrpAxisNum_Pu*),
			i_paiGrpAxisList(*i_paiGrpAxisList*),
			i_pstStSysParam,
			i_iGrpId,
			ADR(alrTotalCorrectVal)(*i_palrTotalCorrectVal*),
			i_palrTotalAdjustVal_V(*i_palrTotalAdjustVal_V*));
	ELSE
		xFlag_AutoGetCorr:=FALSE;
		g_axCorrectConfirmBtnDisplay[i_iGrpId]:=FALSE;
		g_axPreRegisterCorrConfirm[i_iGrpId]:=FALSE;
	END_IF
END_IF
o_xEn:=i_xEn;