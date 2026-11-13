(*@CES
Name=Action_Output
Type=Action
TypeGuid=8ac092e5-3128-4e26-9e7e-11016c6684f2
Guid=f75f2c36-32e4-41da-b497-f773851815bc
HasDeclaration=False
HasImplementation=True
*)
{DECLARATION}

{IMPLEMENTATION}
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_AllPress:= xFlag_AllPress_Out;
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_AllUnpress:= xFlag_AllUnPress_Out;


i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_GotoInking:= xFlag_GotoInking_In_Out;
i_pastStIOMap_Main_FE^[i_iAxisId_If].o_xRel_Press_IF:= xRel_Press_IO_If_Out;
i_pastStIOMap_Main_FE^[i_iAxisId_Of].o_xRel_Press_OF:= xRel_Press_IO_Of_Out;
i_pastStIOMap_Main_FE^[i_iAxisId_If].o_xLamp_Press_IF:= xRel_Press_IO_If_Out;
i_pastStIOMap_Main_FE^[i_iAxisId_Of].o_xLamp_Press_OF:= xRel_Press_IO_Of_Out;

FOR iN:=1 TO MAX_UNIT_NUM BY 1 DO
	IF i_pstStSysParam^.stStSysParam_Save.iCustomerId = CUSTOMERNAME_QINHUA THEN
		;
	ELSE
		i_pastStIOMap_Axis_FE^[iN].o_xRel_Press:= axRel_Press_IO_Out[iN];
		i_pastStIOMap_Axis_FE^[iN].o_xRel_UnPress:= axRel_UnPress_IO_Out[iN];
		i_pastStIOMap_Axis_FE^[iN].o_xLamp_Press:= axRel_Press_IO_Out[iN];
	END_IF

	i_pstStSysParam^.astStUnitParam_UnSave[iN].xAxisAutoPressed:= axAxisAutoPressed_In_Out[iN];
//	i_pstStSysParam^.astStUnitParam_UnSave[iN].byRapidAdjustStep:= abyRapidAdjustStep_In_Out[iN];
	//由于byRapidAdjustStep变量存在多个任务操作，防止因为执行顺序问题导致在套色那里获取到启动信号后在这里被清
	//增加条件在变量从0->1时不执行该代码@2026.05.13.204337+ by liu.yt
	IF NOT (i_pstStSysParam^.astStUnitParam_UnSave[iN].byRapidAdjustStep = 1 AND
		abyPrevRapidAdjustStep_Out[iN] = 0) THEN
		i_pstStSysParam^.astStUnitParam_UnSave[iN].byRapidAdjustStep:= abyRapidAdjustStep_In_Out[iN];
	END_IF
	abyPrevRapidAdjustStep_Out[iN] := i_pstStSysParam^.astStUnitParam_UnSave[iN].byRapidAdjustStep;
	

	i_pstStSysParam^.astStUnitParam_UnSave[iN].xRapidAdjust_ing:= axRapidAdjust_ing_In_Out[iN];
	i_pstStSysParam^.astStUnitParam_UnSave[iN].iRapidAdjust_TimingCnt:= aiRapidAdjust_TimingCnt_In_Out[iN];
	
END_FOR