(*@CES
Name=KS_FB_GrpInkRollerCtrl
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=5acdf1c6-de7a-4d7b-8aad-025a95c20a50
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_GrpInkRollerCtrl
(*按照频率计算输出*)
(*2021.7.20.170258 修改递墨辊速度输出逻辑|最小速度-最小频率|最大速度-最大频率，线性规划！*)
(*2022.3.22.151509 增加了频率通讯变量的赋值
系数修改轴系数
2022.3.26.100939  增加了递墨辊的报警处理*)
(*2022.5.19.131509功能块递墨辊运动条件增加速度限制*)
(*2022.8.19.165203 处理递墨辊的整机手动自动输出*)
(*2024.9.24.105532 屏蔽pstStAxisParam^.rAxisRoller_Frq参数的赋值*)
VAR_INPUT
	i_xEn: BOOL;
	i_iGrpId: INT;
	i_iGrpAxisNum_Pu: INT;(*色组轴的数量|*)
	i_aiGrpAxisList: ARRAY [1..MAX_UNIT_NUM] OF INT;(*系内所有轴的id列表,色组部分已经按照从小到大的顺序排序了，之后的是牵引|*)
	i_iAxisId_If: INT; 
	i_iAxisId_Of: INT;
	i_pstStSysParam: POINTER TO StSysParam;(*参数地址|*)
	i_pastStIOMap_Main_FE	: POINTER TO ARRAY [1..4] OF StIOMap_Main_FE;(*轴io数据区域|*)	
	i_pastStIOMap_AxisExtra: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF StIOMap_Axis_Extra_FE;(*色组io|*)
END_VAR
VAR_OUTPUT
	o_xEno: BOOL;
	o_iErNo: INT;(*0成功/-1参数失败|*)
END_VAR
VAR
	iN: INT;
	iUnitId: INT;
	iHzMin,iHzMax: INT;
	iVelMin,iVelMax: INT;
	lrFinalVolt: LREAL;
	iMaxHz: INT := 50;
	xInit:BOOL;
	axButtonDown: ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	xLinkage: BOOL;
	(*2021.7.20.170927*)
	rK: REAL;
	rFinalFrq: REAL;
	rVel_Judge: REAL;
	(*2024.9.24.105017*)
	(*递墨辊的频率临时变量@原来使用的轴参数变量rAxisRoller_Frq存在双向通讯逻辑，一直变化会引起从站修改不能同步到主站*)
	rUnitInkRoller_Frq:REAL;
	
(*输入参数*)
	iVel_InkRollerMax_In: INT;
	iVel_InkRollerMin_In: INT;
	iFrq_InkRollerMax_In: INT;
	iFrq_InkRollerMin_In: INT;
	rCoeff_InkRoller_In: REAL;
	rVel_Cur_In: REAL;
	xSwitch_InkRollerAuto_In: BOOL;
	axSwitch_InkRollerAuto_In: ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	rHz_UnitInkRoller_ManuallySet_In: REAL;
	arHz_UnitInkRoller_ManuallySet_In: ARRAY [1..MAX_UNIT_NUM] OF REAL;
	iUpperFreq_InkRoller_In: INT;
	arAxisVel_In: ARRAY [1..MAX_UNIT_NUM] OF REAL;
	xInkRollerInveterError_In: BOOL;
	axInkRollerInveterError_In: ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	xFlag_Estop_In: BOOL;
	iVelSa_InkRollerRun_In: INT;
	xInkRoller_CW_In: BOOL;
 	xInkRoller_CCW_In: BOOL;
	axInkRoller_CW_In: ARRAY [1..MAX_UNIT_NUM] OF BOOL;
 	axInkRoller_CCW_In: ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	arCoeff_UnitInkRoller_Auto_In: ARRAY [1..MAX_UNIT_NUM] OF REAL;
	axFlag_Linkage_In: ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	xInkRollerSolenoid_Use3Switch_In: BOOL;
	axInkRoller_Up_In: ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	axInkRoller_Dn_In: ARRAY [1..MAX_UNIT_NUM] OF BOOL;
(*输出参数*)
	xRel_InkRoller_CW_Out: BOOL;
	axRel_InkRoller_CW_Out: ARRAY [1..MAX_UNIT_NUM] OF BOOL;	
	xRel_InkRoller_CCW_Out: BOOL;
	axRel_InkRoller_CCW_Out: ARRAY [1..MAX_UNIT_NUM] OF BOOL;	
	xInkRollerOn_Out: BOOL;
	axInkRollerOn_Out: ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	wAO_InkRoller_Out: WORD;
	awAO_InkRoller_Out: ARRAY [1..MAX_UNIT_NUM] OF WORD;
	rHz_UnitInkRoller_CurrWR_Out: REAL;
	arHz_UnitInkRoller_CurrWR_Out: ARRAY [1..MAX_UNIT_NUM] OF REAL;
	axRel_InkRoller_Up_Out: ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	axRel_InkRoller_Dn_Out: ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	
(*输入输出参数*)	
	axFlag_InkRollerRisen_In_Out: ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	//反转后输出负电压 ±10V@2026.05.25.133733
	awAO_InkRoller_Out_DIR: ARRAY [1..MAX_UNIT_NUM] OF WORD;
	
END_VAR
{IMPLEMENTATION}
(*2019.03.20.141125|检查*)
o_xEno:= i_xEn;
o_iErNo:= 0;
IF i_xEn THEN
	IF (i_iGrpAxisNum_Pu>=1 AND i_iGrpAxisNum_Pu<=MAX_UNIT_NUM) AND(*色组数量有效|*)
		i_pstStSysParam<>0 AND(*参数地址有效|*)
		i_pastStIOMap_Main_FE<>0 AND(*系参数地址有效|*)
		i_pastStIOMap_AxisExtra<>0 THEN(*轴IO表有效|*)
		(*计算递墨辊控制斜率*)
		Action_Input();
		
		rK:=INT_TO_REAL(iVel_InkRollerMax_In-iVel_InkRollerMin_In);
		IF rK<>0 THEN
			rK:=INT_TO_REAL(iFrq_InkRollerMax_In-iFrq_InkRollerMin_In)/rK;
		ELSE
			rK:=1;
		END_IF
		
(*2025.8.13.114503先处理递墨辊牵引逻辑-一控多*)		
		rFinalFrq:= rCoeff_InkRoller_In*
					(rVel_Cur_In-iVel_InkRollerMin_In)*rK+
					iFrq_InkRollerMin_In;
					
		(*限值输出*)
		
		IF rFinalFrq>iFrq_InkRollerMax_In THEN
			rFinalFrq:=iFrq_InkRollerMax_In;
		ELSIF rFinalFrq<iFrq_InkRollerMin_In THEN
			rFinalFrq:=iFrq_InkRollerMin_In;
		END_IF
		IF NOT xSwitch_InkRollerAuto_In THEN(*递墨辊手动输出频率|默认是手动*)

(*				rFinalFrq:=pstStAxisParam^.rHz_AxisInkRoller_ManuallySet;*)
			rFinalFrq:= rHz_UnitInkRoller_ManuallySet_In;(*2022.3.22.150151 替换变量*)

		END_IF

		IF rFinalFrq>iUpperFreq_InkRoller_In THEN
			rFinalFrq:= iUpperFreq_InkRoller_In;
		END_IF

		xRel_InkRoller_CW_Out:= FALSE;
		xRel_InkRoller_CCW_Out:= FALSE;
		xInkRollerOn_Out:= FALSE;
		rVel_Judge:= rVel_Cur_In;
		
		IF NOT xInkRollerInveterError_In AND(*递墨辊报警未报警|*)
			NOT xFlag_Estop_In AND
			rVel_Judge>= iVelSa_InkRollerRun_In THEN(*2022.5.19.131321  增加了速度限制*)
			xRel_InkRoller_CW_Out:= xInkRoller_CW_In;
			xRel_InkRoller_CCW_Out:= xInkRoller_CCW_In;
			//2026.03.20.180324
		IF iUpperFreq_InkRoller_In=0 THEN
			iUpperFreq_InkRoller_In:= 50;
		END_IF
			lrFinalVolt:=rFinalFrq/iUpperFreq_InkRoller_In*10;(*最终输出的电压值*)
		

			IF xRel_InkRoller_CW_Out OR  xRel_InkRoller_CCW_Out  THEN
					(*2024.9.24.105345 屏蔽*)
(*						pstStAxisParam^.rAxisRoller_Frq:=rFinalFrq;(*频率值输出*)*)
					rUnitInkRoller_Frq:=rFinalFrq;(*频率值输出*)
					wAO_InkRoller_Out:=
				DINT_TO_WORD(KSIO_AD(lrFinalVolt, 0, 10, 0, 32767)); (*递墨辊变频速度|2017-08-13 13:28:28*)
			ELSE
				(*2024.9.24.105345 屏蔽*)
(*					pstStAxisParam^.rAxisRoller_Frq:=0;*)
				rUnitInkRoller_Frq:=0;
				wAO_InkRoller_Out:=0;
			END_IF
		ELSE
			wAO_InkRoller_Out:=0;
			(*2024.9.24.105345 屏蔽*)
(*				pstStAxisParam^.rAxisRoller_Frq:=0;*)
			rUnitInkRoller_Frq:=0;
		END_IF

		(*2024.9.24.105345 屏蔽*)
(*			pstStAxisParam^.rHz_UnitInkRoller_CurrWR:=pstStAxisParam^.rAxisRoller_Frq;(*2022.3.22.150904 需要通讯的频率赋值*)*)
		rHz_UnitInkRoller_CurrWR_Out:=rUnitInkRoller_Frq;(*2024.9.24.105451 需要通讯的频率赋值*)
		xInkRollerOn_Out:= xRel_InkRoller_CW_Out OR xRel_InkRoller_CCW_Out;

					
		FOR iN:=1 TO i_iGrpAxisNum_Pu BY 1 DO
			iUnitId:= i_aiGrpAxisList[iN];


			rFinalFrq:= arCoeff_UnitInkRoller_Auto_In[iUnitId]*
							(rVel_Cur_In-iVel_InkRollerMin_In)*rK+
							iFrq_InkRollerMin_In;
			

(*			IF NOT pstStAxisParam^.dwControlBits.30 THEN(*递墨辊手动输出频率|默认是手动*)*)
(*2022.3.22.150120 替换变量*)
			IF NOT axSwitch_InkRollerAuto_In[iUnitId] THEN(*递墨辊手动输出频率|默认是手动*)

(*				rFinalFrq:=pstStAxisParam^.rHz_AxisInkRoller_ManuallySet;*)
				rFinalFrq:= arHz_UnitInkRoller_ManuallySet_In[iUnitId];(*2022.3.22.150151 替换变量*)
			END_IF

			IF rFinalFrq>iUpperFreq_InkRoller_In THEN
				rFinalFrq:= iUpperFreq_InkRoller_In;
			END_IF

			xLinkage:= axFlag_Linkage_In[iUnitId];
			IF iN>i_iGrpAxisNum_Pu THEN
				xLinkage:=TRUE;
			END_IF

			axRel_InkRoller_CW_Out[iUnitId]:= FALSE;
			axRel_InkRoller_CCW_Out[iUnitId]:= FALSE;
			axInkRollerOn_Out[iUnitId]:= FALSE;

			(*2022.5.19.131246  修改为色组使用轴速度|牵引使用主机速度方式*)
			rVel_Judge:=ABS(arAxisVel_In[iUnitId]);

			IF xLinkage AND
				NOT axInkRollerInveterError_In[iUnitId] AND(*递墨辊报警未报警|*)
				NOT xFlag_Estop_In AND
				rVel_Judge>= iVelSa_InkRollerRun_In THEN(*2022.5.19.131321  增加了速度限制*)
				axRel_InkRoller_CW_Out[iUnitId]:= axInkRoller_CW_In[iUnitId];
				axRel_InkRoller_CCW_Out[iUnitId]:= axInkRoller_CCW_In[iUnitId];
				lrFinalVolt:=rFinalFrq/iUpperFreq_InkRoller_In*10;(*最终输出的电压值*)

				IF axRel_InkRoller_CW_Out[iUnitId] OR  axRel_InkRoller_CCW_Out[iUnitId]  THEN
						(*2024.9.24.105345 屏蔽*)
(*						pstStAxisParam^.rAxisRoller_Frq:=rFinalFrq;(*频率值输出*)*)
						rUnitInkRoller_Frq:=rFinalFrq;(*频率值输出*)
						awAO_InkRoller_Out[iUnitId]:=
					DINT_TO_WORD(KSIO_AD(lrFinalVolt, 0, 10, 0, 32767)); (*递墨辊变频速度|2017-08-13 13:28:28*)		
				ELSE
					(*2024.9.24.105345 屏蔽*)
(*					pstStAxisParam^.rAxisRoller_Frq:=0;*)
					rUnitInkRoller_Frq:=0;
					awAO_InkRoller_Out[iUnitId]:=0;
				END_IF
			ELSE
				awAO_InkRoller_Out[iUnitId]:=0;
				(*2024.9.24.105345 屏蔽*)
(*				pstStAxisParam^.rAxisRoller_Frq:=0;*)
				rUnitInkRoller_Frq:=0;
			END_IF
			
			(*2024.9.24.105345 屏蔽*)
(*			pstStAxisParam^.rHz_UnitInkRoller_CurrWR:=pstStAxisParam^.rAxisRoller_Frq;(*2022.3.22.150904 需要通讯的频率赋值*)*)
			arHz_UnitInkRoller_CurrWR_Out[iUnitId]:=rUnitInkRoller_Frq;(*2024.9.24.105451 需要通讯的频率赋值*)
			axInkRollerOn_Out[iUnitId] := axRel_InkRoller_CW_Out[iUnitId] OR
												 axRel_InkRoller_CCW_Out[iUnitId];
												 
			awAO_InkRoller_Out_DIR[iUnitId]:=awAO_InkRoller_Out[iUnitId];
			IF axRel_InkRoller_CCW_Out[iUnitId]	THEN(*反转后输出负电压@2026.05.25.132841+*)						 
				awAO_InkRoller_Out_DIR[iUnitId]:=INT_TO_WORD(-WORD_TO_INT(awAO_InkRoller_Out[iUnitId]));
			END_IF
		END_FOR

	(*控制递墨辊电磁阀动作*)

		IF xInkRollerSolenoid_Use3Switch_In THEN(*使用开关*)
			FOR iN:=1 TO i_iGrpAxisNum_Pu BY 1 DO
				iUnitId:= i_aiGrpAxisList[iN];

				axRel_InkRoller_Up_Out[iUnitId]:= axInkRoller_Up_In[iUnitId];
				axRel_InkRoller_Dn_Out[iUnitId]:= axInkRoller_Dn_In[iUnitId];
			END_FOR
		ELSE
			FOR iN:=1 TO i_iGrpAxisNum_Pu BY 1 DO(*使用按钮,暂未保存上升状态*)
				iUnitId:= i_aiGrpAxisList[iN];
				IF NOT xInit THEN
					IF iN=i_iGrpAxisNum_Pu THEN
						xInit:=TRUE;
					END_IF
				ELSE
					IF NOT axButtonDown[in] THEN
						IF  axInkRoller_Up_In[iUnitId]  THEN
							IF  axFlag_InkRollerRisen_In_Out[iUnitId] THEN
								axFlag_InkRollerRisen_In_Out[iUnitId]:=FALSE;
							ELSE
								axFlag_InkRollerRisen_In_Out[iUnitId]:=TRUE;
							END_IF
							axButtonDown[iN]:=TRUE;
						END_IF
					ELSIF NOT axInkRoller_Up_In[iUnitId] THEN
						axButtonDown[iN]:=FALSE;
					END_IF
				END_IF
					(*2019.5.10.084458|niu.j|递墨辊电磁阀上升*)
					axRel_InkRoller_Up_Out[iUnitId]:= axFlag_InkRollerRisen_In_Out[iUnitId];
			END_FOR
		END_IF
		Action_Output();
	ELSE
		o_iErNo:= -1;
	END_IF
END_IF
