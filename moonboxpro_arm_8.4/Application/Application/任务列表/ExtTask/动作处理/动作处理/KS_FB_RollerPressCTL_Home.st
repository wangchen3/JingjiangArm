(*@CES
Name=KS_FB_RollerPressCTL_Home
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=ba8a6c67-74a8-49bb-b69a-0a82809f62f7
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_RollerPressCTL_Home
(*2021.10.27.111058 区分联动轴和联动自动合压轴个数*)
(*2022.6.16.134644 增加了放牵延时压辊的参数输入*)
(*2023.2.16.102449兼容张力投入时候收牵合压@牵引手动合压修改了为沿触发了同时收牵离压只处理自动合压的的合压*)
(*2023.07.04.140520 增加接口支持离压到最高点的一些状态处理*)
(*2026.04.10.113911+周期不稳定，延时更换为计时器处理 by liu.yt*)
VAR_INPUT
	i_xEn: BOOL;
	i_iGrpId: INT;
	i_pstStSysParam: POINTER TO StSysParam;
	i_iGrpAxisNum_Pu: INT; (*印刷色组数*)
	i_iAxisId_If: INT; 
	i_iAxisId_Of: INT;
	i_pstStEvtReq: POINTER TO StEvtReq;(*按钮输入操作及边沿触发描述|*)
	i_aiGrpAxisList: ARRAY [1..MAX_UNIT_NUM] OF INT; (*系的轴列表|已经按照升序排列了*)
	i_pastStIOMap_Main_FE	: POINTER TO ARRAY [1..4] OF StIOMap_Main_FE;(*轴io数据区域|*)	
	i_pastStIOMap_Axis_FE	: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF StIOMap_Axis_FE;(*轴io数据区域|`````````````````````````````````````````````*)
	i_xMachineRev: BOOL;(*反向走料*)
	i_iCycle_Time: INT;
	i_xPressRollerDne_Of_WhenTensionIn:BOOL;(*2023.2.16.112443张力投入时候是否合压收牵标志*)

	(*离压方式-三位五通阀@2023.07.04.140511*)
	i_xUnPressTop_EstopBtn:BOOL;(*急停离压方式标志|FALSE=按照延时离压|TRUE=离压到最高处*)
	i_xUnPressTop_AllUnPressBtn:BOOL;(*全体离压按钮按下时候方式标志|FALSE=按照延时离压|TRUE=离压到最高处*)
	i_xClearUnPressSignal_OnTop:BOOL;(*位于最高点清除离压信号*)
	i_iCycleTime_Plc : INT;
	i_byActionCtlWay: BYTE;(*系动作流程*)
	i_pastStInteraction : POINTER TO ARRAY [1..MAX_UNIT_NUM] OF StInteraction;
END_VAR
VAR_OUTPUT
	o_xEno: BOOL;
	o_xRollerPressDone: BOOL;
END_VAR
VAR

	iCurrentIndex: INT := -1;
	iUnitId: INT;

	iLinkageAxisNum: INT := 0;(*联动轴个数*)
	iAutoPressAxisNum: INT := 0;(*自动压辊轴个数*)
	aiLinkageAxisIdList: ARRAY [1..MAX_UNIT_NUM] OF INT := [MAX_UNIT_NUM(-1)];
	iAutoPressCycleNum: INT;(*自动合压周期计数*)
	iAutoPressNum:INT;(*自动合压的个数*)
	//uiDelayPeriod: UINT:=100;(*抬起压辊延迟的周期数*)
	//周期任务35ms 次数减小一些@2026.04.10.173813+
	uiDelayPeriod: UINT:=50;(*抬起压辊延迟的周期数*)
	iN: INT;
	iCount: INT;
	afbRTrig: ARRAY [1..MAX_UNIT_NUM] OF R_TRIG;
	axPrePress: ARRAY [1..MAX_UNIT_NUM] OF BOOL;

	xInFeed_Press_Delay: BOOL;(*放牵压辊延迟标志有效*)
	iInFeed_Press_DelayNum: INT;(*放牵压辊延时计数*)
	auiFastAdj_UnPressCount: ARRAY [1..MAX_UNIT_NUM] OF INT;
	xAllPress: BOOL;
	xAllUnPress: BOOL;
	fbRTrig_stop1: R_TRIG;
	fbRTrig_stop2: R_TRIG;
	axUnPress_Inching: ARRAY [1..MAX_UNIT_NUM] OF BOOL;	(*点动离压中*)
	xPressDone: BOOL;
	iRollerPressDoneDelay: UINT := 60000;
	xPreStart: BOOL;

	axRel_PressBak: ARRAY [1..MAX_UNIT_NUM] OF BOOL;

	xBtnUnPressTrig: BOOL;(*离压*)
	xUnitPressBtn: BOOL;
	xUnitUnPressBtn: BOOL;

	axPressModeAutoBak:ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	(*2022.5.23.140052*)
	xUnPressForFastStopping: BOOL;(*因为快停需要抬起胶辊*)
	xLastFlag_Sts: BOOL;
	xFlag_FastStoping: BOOL;
	xLastFlag_Tension: BOOL;(*2023.2.16.111933*)
	afbTRIG_Press:ARRAY [1..MAX_UNIT_NUM] OF R_TRIG;
	afbTRIG_UnPress:ARRAY [1..MAX_UNIT_NUM] OF R_TRIG;
	(*2023.07.04.140535*)
	uiTimeMs_RollerPressUpKeep: UINT;
	uiTimeMs_RollerPressUpKeep_OnTop:UINT:=8000;(*离压到最高的时间@MS*)
	abyStsUnPress: ARRAY [1..MAX_UNIT_NUM] OF BYTE;(*离压的状态/=0 离压延时 /=1 离压到最高*)
	byTypeUnPress: BYTE;(*/.0 急停离压到最高/.1 全体离压到最高*)
	fbTrig_TypeUnPress: R_TRIG;
	fbStopToInkTrig: R_TRIG;
	
(*部分参数需要输入及输出-放这里处理*)
(*输入变量*)	
	xFlag_EStoping_In: BOOL;
	xFlag_Estop_In: BOOL;
	xFlag_Print_In: BOOL;
	xFlag_Tension_In: BOOL;
	xFilmAccDecDone_In: BOOL;
	iDelayMsec_RollerPress_In: INT;
	byDelayTime_PressDneInPrint_If_In: BYTE;(*单位是s*)
	xFlag_PreStart_In: BOOL;
	xAllPressOneBtn_In: BOOL;
	xUnitPressOneBtn_In: BOOL;
	xWorkMode_RollerPress_In: BOOL;
	axFlag_Linkage_In: ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	axPressMode_Auto_IO_In: ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	axPressMode_Manu_IO_In: ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	xPressMode_Auto_IO_If_In: BOOL;
	xPressMode_Auto_IO_Of_In: BOOL;
	xPressMode_Manu_IO_If_In: BOOL;
	xPressMode_Manu_IO_Of_In: BOOL;
	axPress_IO_In: ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	axUnPress_IO_In: ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	axUnPress_Inching_In: ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	xTapPosition_Printing_In: BOOL;
	xTapPosition_Breaking_In: BOOL;
	xTapPosition_UniformInk_In: BOOL;
	rVel_Cur_In: REAL;
	rVel_Film_In: REAL;
	xFlag_FastStoping_In: BOOL;
	xFlag_Stop_In: BOOL;
	xFlag_Ink_In: BOOL;
(*输出变量*)
	xFlag_AllPress_Out: BOOL;
	xFlag_AllUnPress_Out: BOOL;
	xRel_Press_IO_If_Out: BOOL;
	xRel_Press_IO_Of_Out: BOOL;
	
	axRel_Press_IO_Out: ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	axRel_UnPress_IO_Out: ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	
(*输入输出变量*)
	xFlag_GotoInking_In_Out: BOOL;
	axAxisAutoPressed_In_Out: ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	abyRapidAdjustStep_In_Out: ARRAY [1..MAX_UNIT_NUM] OF BYTE;
//2026.5.14.092403
	abyPrevRapidAdjustStep_Out: ARRAY [1..MAX_UNIT_NUM] OF BYTE;//2026.05.13.204447+ out那里的备份值 by liu.yt

	axRapidAdjust_ing_In_Out: ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	aiRapidAdjust_TimingCnt_In_Out: ARRAY [1..MAX_UNIT_NUM] OF INT;
	auiTimeMs_RollerPressUpKeep_In_Out: ARRAY [1..MAX_UNIT_NUM] OF UINT;
	//2025.9.18.151645+ 手动合压处理初始化@解决旋钮合压按钮再初次上电时压辊合压的问题。
	//必须重新触发才能合压
	xPressBtnDealInit:BOOL;
	
	//2026.04.10.113935+
	afbUnPressTon:ARRAY [1..MAX_UNIT_NUM] OF TON;//小离压计时器	
END_VAR

{IMPLEMENTATION}

(**************************************************************************************
*			压辊控制功能块（色组压辊 以及 收放牵压辊）                                         *
*i_xPressCtrl 为true 时由外部输入压辊信号，false时由输入的按钮控制压辊合压 *
* i_xPositivePress 为 true时从第一色往后压辊，为false时由最后一色色往前压	   *				
***************************************************************************************)  
                        
IF i_xEn AND
	(i_iGrpId=1 OR i_iGrpId=2) AND
	i_pstStSysParam<>0 AND
	i_iGrpAxisNum_Pu>=1 AND
	i_pastStIOMap_Main_FE<>0 AND
	i_pastStIOMap_Axis_FE<>0 THEN

	Action_Input();  
	
	(*2022.6.16.132522 界面增加牵引压辊延时合压参数*)
	IF i_iCycle_Time<=0 THEN
		i_iCycle_Time:=gc_EXT_TSK_CYCLE_TIME;
	END_IF

	(*2019.08.19.100757|niu.j|预启动抬胶辊*)
	IF xFlag_PreStart_In AND
		xFlag_PreStart_In<>xPreStart THEN
		FOR iN:=1 TO i_iGrpAxisNum_Pu BY 1 DO
			iUnitId:= i_aiGrpAxisList[iN];
			IF axRel_Press_IO_Out[iUnitId] THEN
				axRel_Press_IO_Out[iUnitId]:= FALSE;
				axRel_UnPress_IO_Out[iUnitId]:= TRUE;
			END_IF
		END_FOR
	END_IF
	xPreStart:= xFlag_PreStart_In;

	(*2020.9.8.164916 针对全体合压使用一个按钮还是2个按钮控制进行判断|*)
	IF xAllPressOneBtn_In  THEN(*一个按钮控制*)
		xBtnUnPressTrig:=i_pstStEvtReq^.xReqPressAll;
	ELSE(*两个按钮控制*)
		xBtnUnPressTrig:=i_pstStEvtReq^.xReqUnpressAll;
	END_IF

	IF NOT xFlag_AllPress_Out AND i_pstStEvtReq^.xReqPressAll THEN
		xAllPress:=TRUE;
		xAllUnPress:=FALSE;
(*全体离压处理2023.3.27.103437：||niu*)
	ELSIF (*xFlag_AllPress_Out AND*) xBtnUnPressTrig THEN(*全体离压处理|2023.3.17.103503*)
		xAllPress:=FALSE;
		xAllUnPress:=TRUE;
	ELSE
		xAllPress:=FALSE;
		xAllUnPress:=FALSE;
	END_IF


	iAutoPressAxisNum:= 0;
	iLinkageAxisNum:=0;(*2021.10.27.111037*)
	IF NOT xWorkMode_RollerPress_In THEN(*从后往前顺序压辊|*)
		FOR iN:=i_iGrpAxisNum_Pu TO 1 BY -1 DO
			iUnitId:= i_aiGrpAxisList[iN];
			IF iUnitId>=1 AND iUnitId<=MAX_UNIT_NUM THEN
				IF axFlag_Linkage_In[iUnitId] THEN
					iLinkageAxisNum:=iLinkageAxisNum+1;
					IF  axPressMode_Auto_IO_In[iUnitId] THEN(*2021.10.27.111000*)
						iAutoPressAxisNum:= iAutoPressAxisNum+1;
						aiLinkageAxisIdList[iAutoPressAxisNum]:= i_aiGrpAxisList[iN];
					END_IF
				END_IF
			END_IF
		END_FOR
	ELSE (*顺序压辊*)
		FOR iN:=1 TO i_iGrpAxisNum_Pu BY 1 DO
			iUnitId:= i_aiGrpAxisList[iN];
			IF iUnitId>=1 AND iUnitId<=MAX_UNIT_NUM THEN
				IF axFlag_Linkage_In[iUnitId]  THEN
					iLinkageAxisNum:=iLinkageAxisNum+1;
					IF axPressMode_Auto_IO_In[iUnitId]  THEN
						iAutoPressAxisNum:= iAutoPressAxisNum+1;
						aiLinkageAxisIdList[iAutoPressAxisNum]:= i_aiGrpAxisList[iN];
					END_IF
				END_IF
			END_IF
		END_FOR
	END_IF




(*自动压辊*)


	IF xFlag_Print_In  THEN (*印刷状态才能进行自动压辊*)
		xFlag_GotoInking_In_Out:=TRUE;
		IF NOT  xFlag_AllPress_Out THEN
			IF xAllPress AND xFilmAccDecDone_In  THEN (*自动合压*)
				xFlag_AllPress_Out:=TRUE;
				iAutoPressCycleNum:=0;
			END_IF
		ELSE(*全体合压状态*)
			iAutoPressNum:=0;
			FOR iN:=1 TO iAutoPressAxisNum BY 1 DO
				iUnitId:= aiLinkageAxisIdList[iN];
				IF iUnitId>=1 AND iUnitId<=MAX_UNIT_NUM THEN
					IF NOT axAxisAutoPressed_In_Out[iUnitId] THEN (*自动未合压过*)
						IF NOT axRel_Press_IO_Out[iUnitId] THEN (*未合压*)
							IF iAutoPressNum =0 THEN
								axRel_Press_IO_Out[iUnitId]:=TRUE;
								axRel_UnPress_IO_Out[iUnitId]:=FALSE;
								axAxisAutoPressed_In_Out[iUnitId]:=TRUE;
								iAutoPressNum:=1;
							ELSE
								(*IF iAutoPressCycleNum*i_iCycleTime_Plc>=pstStGrpParam^.iMillisecondsDelay_RollerPress THEN*)
								IF iAutoPressCycleNum*i_iCycleTime_Plc>=iDelayMsec_RollerPress_In THEN
									axRel_Press_IO_Out[iUnitId]:=TRUE;
									axRel_UnPress_IO_Out[iUnitId]:=FALSE;
									axAxisAutoPressed_In_Out[iUnitId]:=TRUE;
									iAutoPressNum:=iAutoPressNum+1;
									iAutoPressCycleNum:=0;
								ELSE
									iAutoPressCycleNum:=iAutoPressCycleNum+1;
									EXIT;
								END_IF
							END_IF
						ELSE(*合压了*)
							axAxisAutoPressed_In_Out[iUnitId]:=TRUE;
							iAutoPressNum:=iAutoPressNum+1;
						END_IF
					ELSE
						(*2020.10.10.111710 取消这段代码|Liu.yt*)
						(*IF NOT  axRel_Press_IO_Out[iUnitId] THEN
							axRel_Press_IO_Out[iUnitId]:=TRUE;
							axRel_UnPress_IO_Out[iUnitId]:=FALSE;
						END_IF*)
						IF NOT axPressModeAutoBak[iUnitId] AND
							axPressMode_Auto_IO_In[iUnitId] THEN(*自动合压完成以后如果
																		手自动旋钮由手动切换到自动时我们合压*)
							axRel_Press_IO_Out[iUnitId]:=TRUE;
							axRel_UnPress_IO_Out[iUnitId]:=FALSE;
						END_IF
						iAutoPressNum:=iAutoPressNum+1;
					END_IF
				END_IF
			END_FOR
		END_IF

		(*更新保存的自动按钮状态变量2020.10.10.112410*)
		FOR iN:=1 TO i_iGrpAxisNum_Pu BY 1 DO
			iUnitId:=i_aiGrpAxisList[iN];
			axPressModeAutoBak[iUnitId]:=axPressMode_Auto_IO_In[iUnitId];(*自动按钮上个周期变量*)
		END_FOR
		
		
		(*放牵*)
		IF i_iAxisId_If>=1 AND i_iAxisId_If<=MAX_UNIT_NUM THEN
			IF NOT xRel_Press_IO_If_Out AND(*放牵未合压*)
					xPressMode_Auto_IO_If_In THEN(*放牵在自动状态*)
				IF NOT xInFeed_Press_Delay THEN(*压辊延迟无效*)
					(*2026.06.02.211129 计数单位错误*)
					IF iInFeed_Press_DelayNum * i_iCycle_Time >=byDelayTime_PressDneInPrint_If_In * 1000 THEN
						iInFeed_Press_DelayNum:=0;
						xInFeed_Press_Delay:=TRUE;
					ELSE
						iInFeed_Press_DelayNum:=iInFeed_Press_DelayNum+1;
					END_IF
				END_IF
			END_IF
			IF xInFeed_Press_Delay THEN (*放牵压辊延迟标志有效*)
				xRel_Press_IO_If_Out:= xPressMode_Auto_IO_If_In;
			END_IF
		END_IF
	ELSE(*非印刷状态*)
		xFlag_AllPress_Out:=FALSE;
	END_IF

	(*2023.2.16.112143调整*)
	(*收放牵压辊控制*)
	(*收牵*)
	IF xFlag_Print_In OR
		(xFlag_Tension_In AND i_xPressRollerDne_Of_WhenTensionIn)THEN(*张力投入时收牵压辊*)
		IF i_iAxisId_Of>=1 AND i_iAxisId_Of<=MAX_UNIT_NUM THEN
			xRel_Press_IO_Of_Out:=xPressMode_Auto_IO_Of_In;
		END_IF
	END_IF


(*快速调整时压辊控制*)
	FOR iN:=1 TO i_iGrpAxisNum_Pu BY 1 DO
		iUnitId:= i_aiGrpAxisList[iN];
		IF iUnitId>=1 AND iUnitId<=MAX_UNIT_NUM THEN
  			IF abyRapidAdjustStep_In_Out[iUnitId]=0 THEN
				IF axRapidAdjust_ing_In_Out[iUnitId] THEN (*处于快速调整中状态，说明调整已经结束了*)
					(*取压辊快速对版之前的状态*)
					axRel_Press_IO_Out[iUnitId]:= axRel_PressBak[iUnitId];
					axRel_UnPress_IO_Out[iUnitId]:= NOT axRel_PressBak[iUnitId];
					axRapidAdjust_ing_In_Out[iUnitId]:= FALSE;
					aiRapidAdjust_TimingCnt_In_Out[iUnitId]:=0;
					
					//2025.12.31.152043 | +
					i_pastStInteraction^[iUnitId].o_xCoarseAdjStart := FALSE;
					i_pastStInteraction^[iUnitId].o_xCoarseAdjEnd := TRUE;
				END_IF
				axRel_PressBak[iUnitId]:=axRel_Press_IO_Out[iUnitId];(*保存调整前的压辊状态*)
			ELSIF abyRapidAdjustStep_In_Out[iUnitId]=1 OR abyRapidAdjustStep_In_Out[iUnitId]=2 THEN
				(*准备进入快速调整状态，等待压辊离压，延迟后进入快速调整状态*)
				IF i_pstStSysParam^.stStSysParam_Save.iCustomerId = CUSTOMERNAME_QINHUA THEN
					axRapidAdjust_ing_In_Out[iUnitId]:= TRUE;
					axRel_UnPress_IO_Out[iUnitId]:= TRUE;
					axRel_Press_IO_Out[iUnitId]:= FALSE;
					IF abyRapidAdjustStep_In_Out[iUnitId]=1 THEN
						
						//2025.12.31.152043 | +
						i_pastStInteraction^[iUnitId].o_xCoarseAdjStart := TRUE;
						i_pastStInteraction^[iUnitId].o_xCoarseAdjEnd := FALSE;
						IF i_pastStInteraction^[iUnitId].i_xPressRetractionPositionSignal THEN
							abyRapidAdjustStep_In_Out[iUnitId]:=2;
						ELSE
							//2026.1.15.120614 | + | 如果没有信号就超时
							IF aiRapidAdjust_TimingCnt_In_Out[iUnitId]>=uiDelayPeriod THEN
								aiRapidAdjust_TimingCnt_In_Out[iUnitId]:=0;
								abyRapidAdjustStep_In_Out[iUnitId]:=2;
							ELSE
								aiRapidAdjust_TimingCnt_In_Out[iUnitId]:=aiRapidAdjust_TimingCnt_In_Out[iUnitId]+1;
							END_IF
						END_IF
					END_IF
				ELSE
					axRapidAdjust_ing_In_Out[iUnitId]:= TRUE;
					axRel_UnPress_IO_Out[iUnitId]:= TRUE;
					axRel_Press_IO_Out[iUnitId]:= FALSE;
					IF abyRapidAdjustStep_In_Out[iUnitId]=1 THEN
						IF aiRapidAdjust_TimingCnt_In_Out[iUnitId]>=uiDelayPeriod THEN
							aiRapidAdjust_TimingCnt_In_Out[iUnitId]:=0;
							abyRapidAdjustStep_In_Out[iUnitId]:=2;
						ELSE
							aiRapidAdjust_TimingCnt_In_Out[iUnitId]:=aiRapidAdjust_TimingCnt_In_Out[iUnitId]+1;
						END_IF
					END_IF
				END_IF
			ELSE
				abyRapidAdjustStep_In_Out[iUnitId]:=0;
				axRapidAdjust_ing_In_Out[iUnitId]:= FALSE;
				aiRapidAdjust_TimingCnt_In_Out[iUnitId]:=0;
			END_IF
		END_IF
	END_FOR

(*色组压辊手动*)
//2025.9.18.151806+ 手动合压沿处理变量初始化 
	IF NOT xPressBtnDealInit THEN
		xPressBtnDealInit:=TRUE;
		FOR iN:=1 TO i_iGrpAxisNum_Pu BY 1 DO
			iUnitId:= i_aiGrpAxisList[iN];
			IF iUnitId>=1 AND iUnitId<=MAX_UNIT_NUM THEN
				//2025.9.18.152157 只处理两个按钮控制形式,应该问题不大！
				afbTRIG_Press[iUnitId](CLK:= axPress_IO_In[iUnitId]);
				afbTRIG_UnPress[iUnitId](CLK:= axUnPress_IO_In[iUnitId]);
			END_IF
		END_FOR
	END_IF
	//end
	IF NOT xFlag_Estop_In THEN (*急停状态不能压辊*)
		FOR iN:=1 TO i_iGrpAxisNum_Pu BY 1 DO
			iUnitId:= i_aiGrpAxisList[iN];
			IF iUnitId>=1 AND iUnitId<=MAX_UNIT_NUM THEN
				(*2020.9.8.170013 色组合压离压按钮单个多个控制选择逻辑|Liu.yt*)
				xUnitPressBtn:=FALSE;
				xUnitUnPressBtn:=FALSE;
				IF xUnitPressOneBtn_In THEN(*单个按钮控制*)
					IF axPress_IO_In[iUnitId] AND
						NOT axPrePress[iUnitId] THEN(*合压按下沿*)
						xUnitPressBtn:=NOT axRel_Press_IO_Out[iUnitId];
						xUnitUnPressBtn:= axRel_Press_IO_Out[iUnitId];
					END_IF
				ELSE(*多个按钮控制*)
					xUnitPressBtn:= axPress_IO_In[iUnitId];
					xUnitUnPressBtn:= axUnPress_IO_In[iUnitId];
				END_IF
				axPrePress[iUnitId]:= axPress_IO_In[iUnitId];
		(*修改为沿触发-2023.3.30.133052适应三档开关*)
				afbTRIG_Press[iUnitId](CLK:= xUnitPressBtn);
				afbTRIG_UnPress[iUnitId](CLK:= xUnitUnPressBtn);
				afbRTrig[iN](CLK:=axPressMode_Manu_IO_In[iUnitId]);(*手动按钮上升沿*)
			(*手动按钮删除手动条件|2020.10.10.110559|Liu.yt*)
			(*	IF  pstStIOMap_AxisBasic^.i_xPressMode_Manu THEN(*手动*)*)
					IF (*xUnitPressBtn*) afbTRIG_Press[iUnitId].Q AND NOT axRel_Press_IO_Out[iUnitId] THEN (*合压*)
						axRel_Press_IO_Out[iUnitId]:= TRUE;
						axRel_UnPress_IO_Out[iUnitId]:= FALSE;
					ELSIF (*xUnitUnPressBtn *) afbTRIG_UnPress[iUnitId].Q AND NOT axRel_UnPress_IO_Out[iUnitId] THEN (*离压*)
						axRel_Press_IO_Out[iUnitId]:= FALSE;
						axRel_UnPress_IO_Out[iUnitId]:= TRUE;
					ELSIF axAxisAutoPressed_In_Out[iUnitId] AND afbRTrig[iN].Q  THEN (*自动合压过*)
						axRel_Press_IO_Out[iUnitId]:= FALSE;
						axRel_UnPress_IO_Out[iUnitId]:= TRUE;
					END_IF
(*					END_IF*)

				(*2018.8.1.104126 |  niu.j | 点动离压*)

				IF  axRel_Press_IO_Out[iUnitId]  THEN
					axRel_UnPress_IO_Out[iUnitId]:= FALSE;
				END_IF
				IF axUnPress_Inching_In[iUnitId] THEN
					(*手动点动离压按钮删除手动条件|2020.10.10.110559|Liu.yt*)
					axUnPress_Inching[iN]:=TRUE;
					(*IF  pstStIOMap_AxisBasic^.i_xPressMode_Manu THEN (*手动状态*)*)
						axRel_UnPress_IO_Out[iUnitId]:= TRUE;
						axRel_Press_IO_Out[iUnitId]:= FALSE;
				(*	ELSIF pstStIOMap_AxisBasic^.i_xPressMode_Auto THEN
						IF NOT pstStGrpParam^.xFlag_AllPress THEN
							pstStIOMap_AxisBasic^.o_xRel_UnPress:= TRUE;
							pstStIOMap_AxisBasic^.o_xRel_Press:= FALSE;
						END_IF
					END_IF*)
				ELSIF axUnPress_Inching[iN] AND NOT axUnPress_Inching_In[iUnitId] THEN
					//axRel_Press_IO_Out[iUnitId]:= FALSE;
					//2026.04.08.165318 变量写错了
					axRel_UnPress_IO_Out[iUnitId]:= FALSE;
					axUnPress_Inching[iN]:=FALSE;
				END_IF

				IF axRel_Press_IO_Out[iUnitId] THEN
					;
				END_IF

			END_IF

		END_FOR
	ELSE;
	END_IF

	IF xPressMode_Manu_IO_If_In THEN
		xRel_Press_IO_If_Out:= TRUE;
	ELSIF xPressMode_Auto_IO_If_In THEN
		;
	ELSE
		xRel_Press_IO_If_Out:= FALSE;
	END_IF
	IF xPressMode_Manu_IO_Of_In THEN
		xRel_Press_IO_Of_Out:= TRUE;
	ELSIF xPressMode_Auto_IO_Of_In THEN
		;
	ELSE
		xRel_Press_IO_Of_Out:= FALSE;
	END_IF
	(*2023.07.04.141713 重新处理了离压方式*)
	(*2023.07.04.140920 移动到此处*)

	byTypeUnPress:=0;
	IF i_xUnPressTop_EstopBtn THEN(*急停离压到最高处*)
		IF	i_pstStEvtReq^.xEvt_Estop OR
			i_pstStEvtReq^.xReqEstop OR
			xFlag_Estop_In OR
			xFlag_EStoping_In THEN
			byTypeUnPress.0:=TRUE;
		END_IF
	END_IF
	IF i_xUnPressTop_AllUnPressBtn THEN(*全体离压按钮离压到最高处@*)
		IF xFlag_AllPress_Out AND xAllUnPress THEN(*按钮按下之后在下面才清除标志呢|放置的位置很重要*)
			byTypeUnPress.1:=TRUE;
		END_IF
	END_IF

	fbTrig_TypeUnPress(CLK:=byTypeUnPress<>0);(*检查是否要离压到最高处沿*)
	FOR iN:=1 TO i_iGrpAxisNum_PU BY 1 DO
		iUnitId:= i_aiGrpAxisList[iN];
		IF iUnitId>=1 AND iUnitId<=MAX_UNIT_NUM THEN
			uiTimeMs_RollerPressUpKeep:= auiTimeMs_RollerPressUpKeep_In_Out[iUnitId];

			(*状态处理*)
			IF axRel_Press_IO_Out[iUnitId] THEN(*合压了就复位成延时离压方式*)
				abyStsUnPress[iUnitId]:=0;
			END_IF
			IF fbTrig_TypeUnPress.Q THEN(*离压到最高点*)
				IF axRel_Press_IO_Out[iUnitId] THEN(*合压的状态切换下*)
					abyStsUnPress[iUnitId]:=1;
				END_IF
			END_IF

			(*延时处理*)
			IF abyStsUnPress[iUnitId]=1 THEN(*离压到最高*)
				IF i_xClearUnPressSignal_OnTop THEN(*在最高点需要清除*)
					uiTimeMs_RollerPressUpKeep:=uiTimeMs_RollerPressUpKeep_OnTop;
				ELSE(*在最高点不需要清除*)
					uiTimeMs_RollerPressUpKeep:=0;
				END_IF
			ELSE(*延时离压*);
(*				uiTimeMs_RollerPressUpKeep;*)
			END_IF
			IF axRel_UnPress_IO_Out[iUnitId] AND NOT axUnPress_Inching_In[iUnitid] THEN
// 				IF uiTimeMs_RollerPressUpKeep<>0 THEN
// 					IF uiTimeMs_RollerPressUpKeep<= i_iCycleTime_Plc*auiFastAdj_UnPressCount[iUnitId] THEN
// 						axRel_UnPress_IO_Out[iUnitId]:= FALSE;
// 					ELSE
// 						auiFastAdj_UnPressCount[iUnitId]:= auiFastAdj_UnPressCount[iUnitId]+1;
// 					END_IF
// 				ELSE
// 					auiFastAdj_UnPressCount[iUnitId]:= 0;
// 				END_IF
				//2026.04.10.114225 重写
				afbUnPressTon[iUnitId](IN:=uiTimeMs_RollerPressUpKeep<>0,PT:=UINT_TO_TIME(uiTimeMs_RollerPressUpKeep));//2026.04.10.114050+
				IF afbUnPressTon[iUnitId].Q THEN//时间到
					axRel_UnPress_IO_Out[iUnitId]:= FALSE;
				END_IF
			ELSE
				auiFastAdj_UnPressCount[iUnitId]:= 0;
				afbUnPressTon[iUnitId](IN:=FALSE);
			END_IF
		END_IF
	END_FOR

	(*条件优化下2023.2.16.112340*)
	IF i_byActionCtlWay=1 THEN(*华丰类似流程@2023.2.16.105907*)
		IF xTapPosition_Printing_In THEN
			fbRTrig_stop1(CLK:=i_pstStEvtReq^.xReqStop AND rVel_Cur_In=0);
			fbRTrig_stop2(CLK:=FALSE);
		ELSIF xTapPosition_Breaking_In OR
			xTapPosition_UniformInk_In THEN
			fbRTrig_stop1(CLK:=FALSE);
			fbRTrig_stop2(CLK:=i_pstStEvtReq^.xReqStop);
		END_IF
	ELSE(*常规流程*);
		fbRTrig_stop1(CLK:=FALSE);
		fbRTrig_stop2(CLK:=FALSE);
	END_IF

	(*2022.5.23.140104*)
	IF xFlag_FastStoping_In THEN
		xFlag_FastStoping:=TRUE;
	END_IF
	xUnPressForFastStopping:=FALSE;
	IF xFlag_FastStoping THEN
		IF xFlag_Stop_In AND
			NOT xLastFlag_Sts THEN(*进入停止状态*)
			xUnPressForFastStopping:=TRUE;
		END_IF

		IF xFlag_Stop_In THEN(*清除标志*)
			xFlag_FastStoping:=FALSE;
		END_IF
	END_IF
	xLastFlag_Sts:= xFlag_Stop_In OR xFlag_EStop_In;
	(*2023.07.04.193801*)
	fbStopToInkTrig(CLK:=xFlag_GotoInking_In_Out  AND xFlag_Ink_In);

(*全体离压处理2023.3.27.103624|niu.*)
	IF ((*pstStGrpParam^.xFlag_AllPress AND*) xAllUnPress) OR(*全体合压状态下 按下了全体离压清除所有压辊输出*)
		fbRTrig_stop1.Q OR
		fbRTrig_stop2.Q OR
		xUnPressForFastStopping OR(*2022.5.23.140354*)
		(*(pstStGrpParam^.xFlag_GotoInking  AND pstStGrpParam^.xFlag_Ink)*)
		fbStopToInkTrig.Q OR (*从印刷状态退出到空转状态@2023.07.04.193731 改成沿触发*)
		xFlag_Estop_In THEN(*急停状态清除压辊输出*)
		FOR iN:=1 TO i_iGrpAxisNum_PU BY 1 DO
			iUnitId:= i_aiGrpAxisList[iN];
			IF iUnitId>=1 AND iUnitId<=MAX_UNIT_NUM THEN
				axRel_Press_IO_Out[iUnitId]:=FALSE;
				axRel_UnPress_IO_Out[iUnitId]:=TRUE;
				axAxisAutoPressed_In_Out[iUnitId]:=FALSE;
(*全体离压处理2023.3.27.103735|niu.*)
				IF NOT ((*pstStGrpParam^.xFlag_AllPress AND*) xAllUnPress) THEN(*全体离压的时候不清除快速对版相关变量*)
					abyRapidAdjustStep_In_Out[iUnitId]:=0;(*清除快速对版相关变量*)
					axRapidAdjust_ing_In_Out[iUnitId]:=FALSE;
					aiRapidAdjust_TimingCnt_In_Out[iUnitId]:=0;

				END_IF
			END_IF
		END_FOR
		(*pstStGrpParam^.xFlag_GotoInking:=FALSE;*)
		xFlag_AllPress_Out:=FALSE;
	END_IF


(*清除收放牵压辊信号*)
	IF (* pstStGrpParam^.lrVel_Film=0 (*AND pstStGrpParam^.iIdGSE<>GSE_PRINT_PRESTART OR
		pstStGrpParam^.xFlag_Stop*) OR*)(*料膜速度=0,并且是从印刷状态停到空转状态*)
		fbRTrig_stop1.Q OR
		fbRTrig_stop2.Q OR
(*2023.2.16.105134屏蔽预启动清除压辊*)
(*		pstStGrpParam^.xFlag_PreStart OR(*预启动时候清除压辊输出*)*)
		(i_xPressRollerDne_Of_WhenTensionIn AND (xLastFlag_Tension AND NOT xFlag_Tension_In))OR(*退出张力投入取消收牵压辊*)
		(xFlag_GotoInking_In_Out AND xFlag_Ink_In(* (rVel_Film_In=0 AND i_byActionCtlWay=0)*)) OR (*从印刷状态退出到空转状态*)
																			(*g_abyActionCtlWay[i_iGrpId]<>2修改为=0|2019.11.28.104528_*)
		xFlag_Estop_In THEN(*急停状态清除压辊输出*)

		IF NOT xPressMode_Manu_IO_If_In THEN(*非手动时清除@2023.2.16.111739*)
			xRel_Press_IO_If_Out:=FALSE;(*清除放牵压辊*)
			xInFeed_Press_Delay:=FALSE;
			iInFeed_Press_DelayNum:=0;
		END_IF

		IF NOT xPressMode_Manu_IO_Of_In THEN(*非手动时清除@2023.2.16.111739*)
			xRel_Press_IO_Of_Out:=FALSE;(*清除收牵压辊*)
		END_IF


		xFlag_GotoInking_In_Out:= FALSE;
	END_IF
	(*2023.2.16.105207*)
	xLastFlag_Tension:= xFlag_Tension_In;

	(*反向走料禁止压辊*)
	FOR iN:=1 TO i_iGrpAxisNum_Pu BY 1 DO
		iUnitId:= i_aiGrpAxisList[iN];
		IF iUnitId>=1 AND iUnitId<=MAX_UNIT_NUM THEN
			IF i_xMachineRev THEN
				IF axRel_Press_IO_Out[iUnitId] THEN
					axRel_Press_IO_Out[iUnitId]:=FALSE;
					axRel_UnPress_IO_Out[iUnitId]:=TRUE;
				END_IF
			END_IF
		END_IF
	END_FOR


	FOR iN:=1 TO i_iGrpAxisNum_Pu BY 1 DO (*判断至少合压一色*)
		iUnitId:= i_aiGrpAxisList[iN];
		IF iUnitId>=1 AND iUnitId<=MAX_UNIT_NUM THEN
			IF axFlag_Linkage_In[iUnitId] THEN
				IF NOT axRel_Press_IO_Out[iUnitId] THEN
					xPressDone:=FALSE;(*至少一色合压*)
				ELSE
					xPressDone:=TRUE;
					EXIT;
				END_IF
			END_IF
		END_IF
	END_FOR

	FOR iN:=1 TO i_iGrpAxisNum_Pu BY 1 DO (*判断全体色组合压完成*)
		iUnitId:= i_aiGrpAxisList[iN];
		IF iUnitId>=1 AND iUnitId<=MAX_UNIT_NUM THEN
			IF axFlag_Linkage_In[iUnitId] THEN
				IF axRel_Press_IO_Out[iUnitId] THEN
					o_xRollerPressDone:=TRUE;
				ELSE
					o_xRollerPressDone:=FALSE;
					EXIT;
				END_IF
			END_IF
		END_IF
	END_FOR
	(*2021.10.27.111121 修改为联动轴个数计时*)
	iRollerPressDoneDelay:= INT_TO_UINT((iLinkageAxisNum+2)*iDelayMsec_RollerPress_In);
	IF NOT o_xRollerPressDone AND xPressDone THEN (*2018.10.6.090512|niu.j*)
		IF iCount< UINT_TO_INT(iRollerPressDoneDelay)/i_iCycle_Time THEN
			iCount:=iCount+1;
		ELSE
			o_xRollerPressDone:= TRUE;
		END_IF
	ELSIF NOT xPressDone THEN
		iCount:=0;
	END_IF


ELSE
	iCurrentIndex:= -1;
END_IF

Action_Output(); 