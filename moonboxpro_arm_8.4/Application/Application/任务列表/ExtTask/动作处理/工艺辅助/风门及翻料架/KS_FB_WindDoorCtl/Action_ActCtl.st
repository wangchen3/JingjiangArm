(*@CES
Name=Action_ActCtl
Type=Action
TypeGuid=8ac092e5-3128-4e26-9e7e-11016c6684f2
Guid=616b89fc-6aba-43bf-b4ec-4f4296237d56
HasDeclaration=False
HasImplementation=True
*)
{DECLARATION}

{IMPLEMENTATION}

IF i_xEn AND 
  i_pstStSysParam <> 0 AND
	i_PastStIOMap_Axis_Extra_FE<> 0 THEN
	(*风门控制@先只处理色组的*)
	FOR iN:=1 TO i_iGrpAxisNum_Pu BY 1 DO
		iUnitId:=i_aiGrpAxisList[iN];
		(************************************新风*******************************)
		(*计算反馈值*)
		iTmp:=ABS(WORD_TO_INT(awInputAI_AirInletMotor[iUnitId]));
		abyAirInletWindDoorValue_FeedBack_Out[iUnitId]:=LREAL_TO_BYTE(iTmp/32767.0*100);
		(*计算输出值*)
		rTmp:=BYTE_TO_REAL(abyAirInletWindDoorValue_In[iUnitId])/100.0*32767;
		IF rTmp>32767 THEN rTmp:=32767;END_IF
		awOutputAO_AirInletMotor[iUnitId]:=REAL_TO_WORD(rTmp);
	END_FOR
	o_xEn:=TRUE;
ELSE
	IF o_xEn THEN
		o_xEn:=FALSE;
	END_IF
END_IF