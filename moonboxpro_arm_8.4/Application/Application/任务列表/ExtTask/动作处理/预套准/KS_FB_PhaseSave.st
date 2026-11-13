(*@CES
Name=KS_FB_PhaseSave
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=d61b799b-f06c-4921-af68-2abc80af0788
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_PhaseSave
(*运城制版单独保存相位方式@2024.12.25.113018+注释*)
(*2025.1.3.165653 增加了每个轴的原点信号是否获取到的检查*)
(*2025.1.13.191447 增加了可以保存和可以读取标志,对输入重新做了处理*)
VAR_INPUT
	i_xEn:BOOL;
	i_xCanSave:BOOL;(*可以保存*)
	i_xBtnSave:BOOL;(*保存按钮*)
	i_xCanRead:BOOL;(*可以读取标志*)
	i_xBtnRead:BOOL;(*读取按钮*)
	(*轴的一些参数*)
	i_iGrpAxisNum_Pu: INT;(*色组轴的数量|*)
	i_aiGrpAxisList: ARRAY [1..MAX_UNIT_NUM] OF INT;(*系内所有轴的id列表,色组部分已经按照从小到大的顺序排序了，之后的是牵引|*)
	i_pstStSysParam: POINTER TO StSysParam;
//	i_pastStPTSts: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF StPTSts;(*PT运动轴的状态|*)
END_VAR
VAR_OUTPUT
	o_xEn:BOOL;
END_VAR
VAR_IN_OUT
	io_xFlag_Save:BOOL;(*2024.12.25.110101 替换为了输入输出变量@作为系统保持变量了*)
	io_xFlag_Read:BOOL;(*2024.12.25.110101 替换为了输入输出变量@作为系统保持变量了*)
END_VAR
VAR
	xFlag_Save:BOOL;
	xFlag_Read:BOOL;
	iN: INT;
	iUnitId: INT;
//	pstStPTSts: POINTER TO StPTSts;(*PT运动轴的状态|*)
	fbTrig_Save:R_TRIG;
	fbTrig_Read:R_TRIG;
END_VAR
{IMPLEMENTATION}
IF i_xEn AND
	i_pstStSysParam<>0 THEN
	(*保存相位*)
	(*保存按钮操作*)
	IF i_xCanSave THEN
		fbTrig_Save(CLK:=i_xBtnSave);
		IF fbTrig_Save.Q THEN
			xFlag_Save:=TRUE;
		END_IF
	ELSE
		fbTrig_Save(CLK:=FALSE);
		xFlag_Save:=FALSE;
	END_IF

	IF xFlag_Save THEN
		FOR iN:=1 TO i_iGrpAxisNum_Pu BY 1DO
			iUnitId:=i_aiGrpAxisList[iN];
			IF i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].wVirTual_Sts.12=1 THEN(*获取到了原点位置*)
				i_pstStSysParam^.astStUnitParam_Save[iUnitId].iPhase_Locating:=KS_GetPhaseValue(i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].wVirTual_Cnt,gc_iVirEncPPR);
				IF iN=i_iGrpAxisNum_Pu THEN(*所有轴都没问题了*)
					xFlag_Save:=FALSE;(*复位标志*)
					io_xFlag_Save:=TRUE;(*保存成功*)
				END_IF
			ELSE(*有一个没获取到就退出*)
				xFlag_Save:=FALSE;
				io_xFlag_Save:=FALSE;
				EXIT;
			END_IF
		END_FOR
	END_IF

	(*读取相位*)
	(*读取按钮操作*)
	IF i_xCanRead THEN
		fbTrig_Read(CLK:=i_xBtnRead);
		IF fbTrig_Read.Q THEN
			io_xFlag_Read:=TRUE(*io_xFlag_Save*);(*保存成功了,就可以输出读取标志了|该变量由KS_FB_PreRegisterEtc清除*)
		END_IF
	ELSE(*不能读取就退出*)
		io_xFlag_Read:=FALSE;
		fbTrig_Read(CLK:=FALSE);
	END_IF
ELSE
	fbTrig_Save(CLK:=FALSE);
	fbTrig_Read(CLK:=FALSE);
	io_xFlag_Read:=FALSE;
	io_xFlag_Save:=FALSE;
	xFlag_Read:=FALSE;
	xFlag_Save:=FALSE;
END_IF