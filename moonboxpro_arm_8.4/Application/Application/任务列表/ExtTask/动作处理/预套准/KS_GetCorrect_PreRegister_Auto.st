(*@CES
Name=KS_GetCorrect_PreRegister_Auto
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=3dff30e1-2ce5-4884-8d32-0e4848e202b7
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_GetCorrect_PreRegister_Auto : BOOL(*自动获取预套准修正量|
											    根据套色调整量获得*)
VAR_INPUT
	i_xAutoGetCorr:BOOL;(*自动获取预套准修正量标志|做完预套准后第一次印刷执行*)
	i_pxWrPreRegisterCorr:POINTER TO BOOL;(*写入到预套准修正值中标志*)
	i_iGrpAxisNum_Pu: INT; (*色组轴数量*)
	i_paiGrpAxisList: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF INT; (*系内所有轴的列表*)
	i_pstStSysParam: POINTER TO StSysParam;
	i_iGrpId:int;(*系号*)
	i_palrTotalCorrectVal:POINTER TO ARRAY [1..MAX_UNIT_NUM] OF LREAL;(*总的修正量|mm*)
	i_palrTotalAdjustVal_V:POINTER TO ARRAY [1..MAX_UNIT_NUM] OF LREAL;(*套色总的调整量|mm*)
END_VAR
VAR
	iN:INT;
	iAxisId:INT;
	lrTotalAdjustVal: LREAL;(*总的调整量|单位都是um*)
	lrTotalAdjustValLastAxis: LREAL;(*上个轴的调整量*)
END_VAR
{IMPLEMENTATION}
IF i_paiGrpAxisList<>0 AND
	i_pstStSysParam<>0 AND
	i_palrTotalCorrectVal<>0 AND
	i_pxWrPreRegisterCorr<>0 AND
	i_palrTotalAdjustVal_V<>0 THEN
	IF i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Print AND (*印刷时候我们才进行统计*)
		i_xAutoGetCorr THEN
		FOR iN:=1 TO MAX_UNIT_NUM BY 1 DO
			i_palrTotalCorrectVal^[iN]:=0;
		END_FOR

		lrTotalAdjustValLastAxis:=0;
		FOR iN:=1 TO i_iGrpAxisNum_Pu BY 1 DO
			iAxisId:=i_paiGrpAxisList^[iN];
		(*将以下部分总和起来就应该是总的调整量*)
			IF i_pstStSysParam^.astStUnitParam_Save[iAxisId].xLinkage THEN(*只统计联动轴*)
				lrTotalAdjustVal:=i_palrTotalAdjustVal_V^[iAxisId]-lrTotalAdjustValLastAxis;
				(*2021.6.16.084129 记录上个轴的调整量|计算需要的修正量*)
				lrTotalAdjustValLastAxis:=i_palrTotalAdjustVal_V^[iAxisId];
				i_palrTotalCorrectVal^[iAxisId]:=lrTotalAdjustVal/1000;
			END_IF
		END_FOR
	END_IF

	(*写入到预套准修正量中*)
	IF i_pxWrPreRegisterCorr^ THEN
		FOR iN:=1 TO i_iGrpAxisNum_Pu BY 1 DO
			iAxisId:=i_paiGrpAxisList^[iN];
			i_pstStSysParam^.astStUnitParam_Save[iAxisId].lrPreReg_Adjust:=i_pstStSysParam^.astStUnitParam_Save[iAxisId].lrPreReg_Adjust+
												i_palrTotalCorrectVal^[iAxisId];
		END_FOR
	END_IF
	i_pxWrPreRegisterCorr^:=FALSE;
END_IF