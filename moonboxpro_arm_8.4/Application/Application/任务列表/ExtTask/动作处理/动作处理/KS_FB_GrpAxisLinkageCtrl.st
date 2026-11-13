(*@CES
Name=KS_FB_GrpAxisLinkageCtrl
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=b8bcbe9f-324f-4681-8ae1-7356112ae7c5
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_GrpAxisLinkageCtrl
(*2021.10.18.101258  处理界面联动按钮输入|或者从站通讯获得*)
(*2023.10.17.085358 增加至少联动一色标志*)
(*2023.11.27.164625 印刷时候可以切换单联动按钮接口*)
VAR_INPUT
	i_xEn: BOOL;
	i_iGrpId: INT;
	i_iGrpAxisNum_Pu: INT;(*色组轴数|*)
	i_aiGrpAxisList: ARRAY [1..MAX_UNIT_NUM] OF INT;(*轴-站映射表|*)
	i_pstStSysParam: POINTER TO StSysParam;(*整机参数|*)
	i_pastStIOMap_Axis_FE	: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF StIOMap_Axis_FE;(*轴io数据区域|`````````````````````````````````````````````*)
	i_iMaxVel_StsSwitch:INT;(*单联动状态切换的最大速度|2022.7.21.180903*)
	i_xChangLinkageStsWhenPrint:BOOL;(*印刷时候可以切换单联动@2023.11.27.164606*)
END_VAR
VAR_OUTPUT
	o_xEno: BOOL;
	o_iErNo: INT;
	o_xFlag_LinkageAtleast1:BOOL;(*至少联动一色@2023.10.17.085309*)
END_VAR
VAR
	iN: INT;
	pstStUnitParam_Save: POINTER TO StUnitParam_Save;
	pstStUnitParam_UnSave: POINTER TO StUnitParam_UnSave;
	pstStIOMap_Axis_FE: POINTER TO StIOMap_Axis_FE;
	afbR_TRIG: ARRAY [1..MAX_UNIT_NUM] OF R_TRIG;
	axReqLinkage: ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	xTmpResetHomeEnd: BOOL;
	(*2021.10.18.101249  联动按钮界面输入*)
	xLinkageBtn_Hmi: BOOL;
	xLinkageChangeEn: BOOL;(*联动切换使能*)
	
	iUnitId 	: INT;
(*部分参数需要输入及输出-放这里处理*)
(*输入变量*)	
	xAllowLinkageChangeInRunning_In: BOOL;(*在运动过程中允许单联动切换*)
	xFlag_Stop_In: BOOL;
	xFlag_Estop_In: BOOL;
	xFlag_Stoping_In	: BOOL;	
	xFlag_FastStoping_In	: BOOL;
	xFlag_EStoping_In		: BOOL;
	xFlag_AllInchRun_In		: BOOL;
	xFlag_Home_In			: BOOL;
	xFlag_PreRegister_In	: BOOL;
	xFlag_PhaseRestore_In	: BOOL;
	xFlag_Print_In			: BOOL;
	rVel_Cur_In				: REAL;
	xUseBtn_Linkage_In			: BOOL;
	axLinkage_IO_In: ARRAY [1..MAX_UNIT_NUM] OF BOOL;(*色组IO联动按钮*)
	axFlag_Alarm_Unit_In: ARRAY [1..MAX_UNIT_NUM] OF BOOL;(*色组报警/离线等标志*)
	xFlag_Alarm_If_In: BOOL;
	xFlag_Alarm_Of_In: BOOL;
	xLinkage_IfOf_Ink_In: BOOL;
	
(*输出变量*)
	xMoveEnable_Motor_If_Out: BOOL;
	xMoveEnable_Motor_Of_Out: BOOL;
	axLamp_Linkage_IO_Out: ARRAY [1..MAX_UNIT_NUM] OF BOOL;(*色组IO联动指示灯*)
	axMoveEnable_Motor_Out: ARRAY [1..MAX_UNIT_NUM] OF BOOL;(*色组运动使能标志*)
(*输入输出变量*)
	axBtnLinkage_HMI_In_Out: ARRAY [1..MAX_UNIT_NUM] OF BOOL;(*界面联动按钮*)
	axFlag_Linkage_In_Out: ARRAY [1..MAX_UNIT_NUM] OF BOOL;(*色组联动标志*)
	xFlag_Home_end_In_Out: BOOL;
	xFlag_Linkage_If_Out: BOOL;
	xFlag_Linkage_Of_Out: BOOL;
	
END_VAR
{IMPLEMENTATION}
o_xEno:= i_xEn;
o_iErNo:= 0;
IF i_xEn THEN
	IF i_iGrpAxisNum_Pu>0 AND
		i_pstStSysParam<>0 AND
		i_pastStIOMap_Axis_FE<>0  THEN
		Action_Input();
		(*the parameters are valid|*)
		(*2022.7.8.192719 增加了 单联动切换支持开机逻辑*)
		xLinkageChangeEn:=(xFlag_Stop_In OR xFlag_Estop_In) AND
						(NOT xFlag_Stoping_In) AND
						(NOT xFlag_FastStoping_In) AND(*2022.4.10.000603 快速停止中*)
						(NOT xFlag_EStoping_In) AND
						(NOT xFlag_AllInchRun_In) AND
						(NOT xFlag_Home_In) AND
						(NOT xFlag_PreRegister_In) AND
						(NOT xFlag_PhaseRestore_In);

		IF xAllowLinkageChangeInRunning_In THEN(*支持开机切换单联动*)
			xLinkageChangeEn:=(NOT  xFlag_AllInchRun_In) AND
						(NOT  xFlag_Home_In) AND
						(NOT  xFlag_PreRegister_In) AND
						(NOT  xFlag_PhaseRestore_In)AND
						(*2023.11.27.164834  印刷时候能不能切换增加选择标志*)
						((NOT  xFlag_Print_In AND NOT i_xChangLinkageStsWhenPrint) OR
						i_xChangLinkageStsWhenPrint) AND (*2022.7.21.170040 印刷时候不能切*)
						(rVel_Cur_In<=i_iMaxVel_StsSwitch);(*2022.7.21.180956小于等于切换速度才可以切换*)
		END_IF


(*		IF (i_pstStGrpParam^.xFlag_Stop OR i_pstStGrpParam^.xFlag_Estop) AND
			(NOT i_pstStGrpParam^.xFlag_Stoping) AND
			(NOT i_pstStGrpParam^.xFlag_FastStoping) AND(*2022.4.10.000603 快速停止中*)
			(NOT i_pstStGrpParam^.xFlag_EStoping) AND
			(NOT i_pstStGrpParam^.xFlag_AllInchRun) AND
			(NOT i_pstStGrpParam^.xFlag_Home) AND
			(NOT i_pstStGrpParam^.xFlag_PreRegister) AND
			(NOT i_pstStGrpParam^.xFlag_PhaseRestore) THEN*)
			(*只能在停机的时候转换色组的单联动|*)
		IF  xLinkageChangeEn THEN
			o_xFlag_LinkageAtleast1:=FALSE;(*2023.10.17.085450*)
			FOR iN:=1 TO i_iGrpAxisNum_Pu BY 1 DO
				iUnitId:= i_aiGrpAxisList[iN];(*轴id|*)

				(*2021.10.18.101136 取界面或者从站通讯过来的联动按钮输入|*)
				xLinkageBtn_Hmi:= axBtnLinkage_HMI_In_Out[iUnitId];(*只在按钮控制中起作用*)
				axBtnLinkage_HMI_In_Out[iUnitId]:=FALSE;(*获得之后就清除掉*)
				xTmpResetHomeEnd:= FALSE;

				afbR_TRIG[iN](CLK:=axLinkage_IO_In[iUnitId] OR xLinkageBtn_Hmi, Q=>axReqLinkage[iN]);
				IF xUseBtn_Linkage_In THEN(*非两档开关|*)
					IF axReqLinkage[iN] THEN
						axFlag_Linkage_In_Out[iUnitId]:= NOT axFlag_Linkage_In_Out[iUnitId];
						xTmpResetHomeEnd:= TRUE;
					END_IF
				ELSE
					IF axFlag_Linkage_In_Out[iUnitId]<>axLinkage_IO_In[iUnitId] THEN
						axFlag_Linkage_In_Out[iUnitId]:= axLinkage_IO_In[iUnitId];
						xTmpResetHomeEnd:= TRUE;
					END_IF
				END_IF
				IF xTmpResetHomeEnd AND xFlag_Home_end_In_Out THEN
					xFlag_Home_end_In_Out:= FALSE;
				END_IF
				axLamp_Linkage_IO_Out[iUnitId]:= axFlag_Linkage_In_Out[iUnitId];(*联动指示灯|*)

				axMoveEnable_Motor_Out[iUnitId]:= axFlag_Linkage_In_Out[iUnitId];
				IF xAllowLinkageChangeInRunning_In THEN(*支持开机切换单联动|2022.7.8.193520*)
					IF axFlag_Alarm_Unit_In[iUnitId] THEN(*电机报警了*)
						axMoveEnable_Motor_Out[iUnitId]:=FALSE;
					ELSE
						axMoveEnable_Motor_Out[iUnitId]:=TRUE;(*电机运动使能标志有效|否则根据单联动控制*)
					END_IF
				END_IF

				(*2023.10.17.085232 输出至少联动一色标志*)
				IF axFlag_Linkage_In_Out[iUnitId] THEN
					IF NOT o_xFlag_LinkageAtleast1 THEN
						o_xFlag_LinkageAtleast1:=TRUE;
					END_IF
				END_IF
			END_FOR
		ELSE
			FOR iN:=1 TO MAX_UNIT_NUM BY 1 DO
				iUnitId:= i_aiGrpAxisList[iN];(*轴id|*)
				axBtnLinkage_HMI_In_Out[iUnitId]:=FALSE;(*不能需改的时候单联动状态的时候就清除掉从站发送过来的*)
				afbR_TRIG[iUnitId](CLK:= FALSE);
			END_FOR
		END_IF

		(*牵引|*)
		IF xFlag_Stop_In OR xFlag_Estop_In THEN(*停机或急停都按不联动算|*)
			xFlag_Linkage_If_Out:= FALSE;
			xFlag_Linkage_Of_Out:= FALSE;
		ELSE
			(* 2021.1.14.111720 *)
			IF xFlag_Alarm_If_In THEN
				IF xFlag_Print_In THEN
					xFlag_Linkage_If_Out:= TRUE;
				END_IF
			ELSE
				(* 2022.1.11.162926增加牵引空转使能*)
				IF xLinkage_IfOf_Ink_In THEN
					xFlag_Linkage_If_Out:= xLinkage_IfOf_Ink_In;
					(*pstStAxisParam^.xLinkage:= TRUE;*)
				END_IF
			END_IF
			(* 2021.1.14.111720 *)
			IF xFlag_Alarm_Of_In THEN
				IF xFlag_Print_In THEN
					xFlag_Linkage_Of_Out:= TRUE;
				END_IF
			ELSE
				(* 2022.1.11.162926增加牵引空转使能*)
				IF xLinkage_IfOf_Ink_In THEN
					xFlag_Linkage_Of_Out:= xLinkage_IfOf_Ink_In;
					(*pstStAxisParam^.xLinkage:= TRUE;*)
				END_IF
			END_IF			
		END_IF
		xMoveEnable_Motor_If_Out:=xFlag_Linkage_If_Out;(*少了这行代码*)
		xMoveEnable_Motor_Of_Out:=xFlag_Linkage_Of_Out;(*少了这行代码*)
		Action_Output();
		
	ELSE
		o_iErNo:= -1;
		o_xFlag_LinkageAtleast1:=FALSE;(*2023.10.17.085450*)
	END_IF
ELSE
	o_xFlag_LinkageAtleast1:=FALSE;(*2023.10.17.085450*)
END_IF