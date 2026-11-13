(*@CES
Name=KS_FB_GetPressDneFlag
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=5ae664dd-3e73-4120-84fc-3415a767721f
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_GetPressDneFlag(*获得压辊实际压刀版辊的标志|放在系流程中*)
VAR_INPUT
	i_xEn: BOOL;
	i_iGrpId: INT;
	i_pstStSysParam: POINTER TO StSysParam;
	i_iGrpAxisNum_Pu: INT; (*印刷色组数*)
	i_aiGrpAxisList: ARRAY [1..MAX_UNIT_NUM] OF INT; (*系的轴列表|已经按照升序排列了*)
	i_pastStIOMap_Main_FE	: POINTER TO ARRAY [1..4] OF StIOMap_Main_FE;(*轴io数据区域|*)	
	i_pastStIOMap_Axis_FE	: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF StIOMap_Axis_FE;(*轴io数据区域|`````````````````````````````````````````````*)
	i_paxFlag_PressDne:POINTER TO ARRAY [1..MAX_UNIT_NUM] OF BOOL;(*实际压辊完成标志*)
	i_pxFlag_PressDne_If: POINTER TO BOOL;
	i_pxFlag_PressDne_Of: POINTER TO BOOL;
	i_iAxisId_If: INT;
	i_iAxisId_Of: INT;
	i_iCycleTime_Plc:INT;(*2024.01.22.142644+*)
END_VAR
VAR_OUTPUT
	o_xEn:BOOL;
	o_xRollerStsDn_AtLeast1: BOOL;(*至少一个联动色组合压*)
END_VAR
VAR
	iN: INT;
	iUnitId: INT;
	aiCnt: ARRAY [1..MAX_UNIT_NUM] OF INT;
	iCnt_If: INT;
	iCnt_Of: INT;
	uiTimeMs_RollerPressUpKeep: UINT;
	uiTimeMs_RollerPressUpKeep_If: UINT:= 3000;
	uiTimeMs_RollerPressUpKeep_Of: UINT:= 3000;
	
	xPressDne: BOOL;
	
	auiTimeMs_RollerPressUpKeep_In: ARRAY [1..MAX_UNIT_NUM] OF UINT;
	axRel_Press_In: ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	iAxisId_If_In: INT;
	iAxisId_Of_In: INT;
	xRel_Press_If_In: BOOL;
	xRel_Press_Of_In: BOOL;
	axFlag_Linkage_In: ARRAY [1..MAX_UNIT_NUM] OF BOOL;
END_VAR
{IMPLEMENTATION}
o_xEn:=i_xEn;
o_xRollerStsDn_AtLeast1:= FALSE;
IF i_pstStSysParam<>0 AND
	i_pastStIOMap_Main_FE<>0 AND
	i_pastStIOMap_Axis_FE<>0 AND
	i_paxFlag_PressDne<>0 AND
	i_pxFlag_PressDne_If<>0 AND
	i_pxFlag_PressDne_Of<>0 AND
	(i_iGrpId=1 OR i_iGrpId=2) THEN
	(*输入处理一下*)
	iAxisId_If_In:= i_iAxisId_If;
	iAxisId_Of_In:= i_iAxisId_Of;
	
	IF iAxisId_If_In>0 AND iAxisId_Of_In>0 THEN
		xRel_Press_If_In:= i_pastStIOMap_Main_FE^[iAxisId_If_In].o_xRel_Press_IF;
		xRel_Press_Of_In:= i_pastStIOMap_Main_FE^[iAxisId_Of_In].o_xRel_Press_OF;
	END_IF
	FOR iN:=1 TO MAX_UNIT_NUM BY 1 DO
		auiTimeMs_RollerPressUpKeep_In[iN]:= i_pstStSysParam^.astStUnitParam_Save[iN].uiTimeMs_RollerPressUpKeep;
		axRel_Press_In[iN]:= i_pastStIOMap_Axis_FE^[iN].o_xRel_Press;
		axFlag_Linkage_In[iN]:= i_pstStSysParam^.astStUnitParam_Save[iN].xLinkage;
	END_FOR
	
	FOR iN:=1 TO MAX_UNIT_NUM BY 1 DO
		IF i_iGrpId=1 THEN(*A系执行在前|我们清除所有输出*)
			i_paxFlag_PressDne^[iN]:=FALSE;
		END_IF
	END_FOR
	i_pxFlag_PressDne_If^:= FALSE;
	i_pxFlag_PressDne_Of^:= FALSE;
	
	IF i_iCycleTime_Plc<=0 THEN
		i_iCycleTime_Plc:=gc_EXT_TSK_CYCLE_TIME;
	END_IF


	FOR iN:=1 TO i_iGrpAxisNum_Pu BY 1 DO
		iUnitId:=i_aiGrpAxisList[iN];
		IF iUnitId>0 AND iUnitId<=MAX_UNIT_NUM THEN
			uiTimeMs_RollerPressUpKeep:=auiTimeMs_RollerPressUpKeep_In[iUnitId];
			(*最少延时2s判定色组合压完成状态|2020.8.20.203521*)
			(*2022.6.28.145501 调整到3s*)
			IF uiTimeMs_RollerPressUpKeep<=3000 THEN
				uiTimeMs_RollerPressUpKeep:=3000;
			END_IF
			xPressDne:=FALSE;
			IF axRel_Press_In[iUnitId] THEN(*轴合压了*)
				IF aiCnt[iUnitId]*i_iCycleTime_Plc>=uiTimeMs_RollerPressUpKeep THEN
					xPressDne:=TRUE;
				ELSE
					aiCnt[iUnitId]:=aiCnt[iUnitId]+1;
				END_IF
			ELSE
				aiCnt[iUnitId]:=0;
			END_IF

			i_paxFlag_PressDne^[iUnitId]:=xPressDne;
		ELSE;
		END_IF
	END_FOR
	xPressDne:= FALSE;
	IF xRel_Press_If_In THEN
		IF iCnt_If*i_iCycleTime_Plc>=uiTimeMs_RollerPressUpKeep_If THEN
			xPressDne:= TRUE;
		ELSE
			iCnt_If:= iCnt_If+1;
		END_IF
	ELSE
		iCnt_If:= 0;
	END_IF
	i_pxFlag_PressDne_If^:= xPressDne;
	xPressDne:= FALSE;
	IF xRel_Press_Of_In THEN
		IF iCnt_Of*i_iCycleTime_Plc>=uiTimeMs_RollerPressUpKeep_Of THEN
			xPressDne:= TRUE;
		ELSE
			iCnt_Of:= iCnt_Of+1;
		END_IF
	ELSE
		iCnt_Of:= 0;
	END_IF
	i_pxFlag_PressDne_Of^:= xPressDne;
	
	FOR iN:=1 TO i_iGrpAxisNum_Pu BY 1 DO
		iUnitId:= i_aiGrpAxisList[iN];
		IF axFlag_Linkage_In[iUnitId] AND i_paxFlag_PressDne^[iUnitId] THEN
			IF NOT o_xRollerStsDn_AtLeast1 THEN
				o_xRollerStsDn_AtLeast1:= TRUE;
			END_IF
		END_IF 
	END_FOR
END_IF