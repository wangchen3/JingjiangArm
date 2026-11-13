(*@CES
Name=KS_FB_GrpIndicatorLampCtrl
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=046cf0cb-05a3-4565-9599-869039b6c2cc
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_GrpIndicatorLampCtrl
VAR_INPUT
	i_xEn: BOOL;
	i_iGrpId:INT;
	i_iCustomerNameId:INT;
	i_iGrpAxisNum_PU: INT;
	i_aiGrpAxisList: ARRAY [1..MAX_UNIT_NUM] OF INT;
	i_pstStSysParam: POINTER TO StSysParam;
	i_pastStIOMap_AxisBasic: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF StIOMap_Axis_FE;
	i_pastStIOMap_Main: POINTER TO ARRAY [1..4] OF StIOMap_Main_FE;(*基础io|*)
	i_iAxisId_If: INT;
	i_iAxisId_Of: INT;
END_VAR
VAR_OUTPUT
	o_xEno: BOOL;
	o_iErNo: INT;
END_VAR
VAR
	iN: INT;
	iAxisId: INT;
	pstStIOMap_AxisBasic: POINTER TO StIOMap_Axis_FE;
	pstStIOMap_Main: POINTER TO StIOMap_Main_FE;
	pstStIOMap_Main_If: POINTER TO StIOMap_Main_FE;
	pstStIOMap_Main_Of: POINTER TO StIOMap_Main_FE;
	tmNow: TIME;
	tmLastStateChanged_print: TIME;
	tmLastStateChanged_prestart: TIME; (* 2021.3.3.113856/上次状态改变的时间 *)
	tmLastStateChanged_Stop: TIME; (* 2022.4.10.001512/上次状态改变的时间 *)
	xLamp_Stop: BOOL;(*停止灯指示*)
END_VAR

{IMPLEMENTATION}
o_xEno:= i_xEn;
o_iErNo:= 0;
IF i_xEn THEN
	IF (i_iGrpAxisNum_PU>=0 AND i_iGrpAxisNum_PU<=MAX_UNIT_NUM) AND(*色组有效|*)
		i_pastStIOMap_AxisBasic<>0 THEN(*轴IO有效|*)

		tmNow:= TIME(); (* 2021.3.3.114019/ *)

		(*2022.4.9.225300 增加了停止时候停止指示灯的闪烁指示*)
		IF i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Stoping  (*OR (*停止中|*)
			 i_pstStGrpParam^.xFlag_FastStoping*) THEN(*快速停止中*)
			IF tmNow-tmLastStateChanged_Stop>=T#200MS THEN
				xLamp_Stop:=NOT xLamp_Stop;(**)
				tmLastStateChanged_Stop:= tmNow; (* 2021.3.3.114723/ *)
			END_IF
		ELSE
			xLamp_Stop:=i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Stop;
			tmLastStateChanged_Stop:= tmNow; (* 2021.3.3.114723/ *)
		END_IF

		FOR iN:=1 TO i_iGrpAxisNum_PU BY 1 DO
			iAxisId:= i_aiGrpAxisList[iN];
			IF iAxisId>=1 AND iAxisId<=MAX_UNIT_NUM THEN
				pstStIOMap_AxisBasic:=ADR(i_pastStIOMap_AxisBasic^[iAxisId]);(*读取轴IO|*)
				//pstStIOMap_Main_If:=ADR(i_pastStIOMap_Main^[i_iAxisId_If]);(*读取牵引轴IO|*)
				//pstStIOMap_Main_Of:=ADR(i_pastStIOMap_Main^[i_iAxisId_Of]);(*读取牵引轴IO|*)
				pstStIOMap_AxisBasic^.o_xLamp_Estop:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Estop AND pstStIOMap_AxisBasic^.i_xEstop;(*急停灯输出|*)
				pstStIOMap_AxisBasic^.o_xLamp_Stop:= xLamp_Stop OR
												(NOT i_pstStSysParam^.astStUnitParam_Save[iAxisId].xLinkage AND NOT i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Estop);(*停止灯输出|*)
				pstStIOMap_AxisBasic^.o_xLamp_Inch:= (i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Ink OR i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Print) AND (i_pstStSysParam^.astStUnitParam_Save[iAxisId].xLinkage);(*联动状态下空转或印刷|*)
				pstStIOMap_AxisBasic^.o_xLamp_AxisError:= (i_pstStSysParam^.astStUnitParam_UnSave[iAxisId].xNetOffline_PrnRoller OR i_pstStSysParam^.astStUnitParam_UnSave[iAxisId].xAxisAlarm_PrnRoller OR i_pstStSysParam^.astStUnitParam_UnSave[iAxisId].xPosDeviationAlarm_PrnRoller);(*轴报警|*)
				pstStIOMap_AxisBasic^.o_xLamp_Inch:= i_pstStSysParam^.astStUnitParam_UnSave[iAxisId].xAxisInching OR g_axAxisInchDecing[iAxisId];(*单运行|*)

 			END_IF
		END_FOR
		
		//2026.03.26.105424 | + | 挪出来
		//2026.05.20.185157 指针未挪出来 wxy
		pstStIOMap_Main_If:=ADR(i_pastStIOMap_Main^[i_iAxisId_If]);(*读取牵引轴IO|*)
		pstStIOMap_Main_Of:=ADR(i_pastStIOMap_Main^[i_iAxisId_Of]);(*读取牵引轴IO|*)
		IF (i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Print AND NOT i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_FilmAccDecDone) OR
			(i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_TensionUnfinished) THEN(*张力投入未完成的时候印刷灯闪烁指示@2022.11.30.093228*)
			IF (tmNow-tmLastStateChanged_print)>=T#500ms THEN (* 2021.3.3.114446/改为time()计时方法 *)
				pstStIOMap_Main_If^.o_xLamp_Print:= NOT pstStIOMap_Main_If^.o_xLamp_Print;
				pstStIOMap_Main_Of^.o_xLamp_Print:= NOT pstStIOMap_Main_Of^.o_xLamp_Print;
				//IF iN=1(*i_iGrpAxisNum_PU*) THEN(*检查到最后一个轴更新时间*)
					tmLastStateChanged_print:= tmNow; (* 2021.3.3.114723/ *)
				//END_IF
			END_IF

		ELSE
			pstStIOMap_Main_If^.o_xLamp_Print:=i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Print;
			pstStIOMap_Main_Of^.o_xLamp_Print:=i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Print;
			tmLastStateChanged_print:= tmNow; (* 2021.3.3.114723/ *)
		END_IF

		IF (i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Accing OR i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Decing) OR (* 速度在变化中 *)
			i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_KeepAlarming THEN(*开机响铃的时候闪烁|2022.5.27.123851*)
// 			IF ((i_pstStSysParam^.astStUnitParam_Save[iAxisId].xLinkage AND iN<=i_iGrpAxisNum_PU) OR (* 联动 |只检查色组轴*)
// 				(iN>i_iGrpAxisNum_PU)) THEN(*牵引轴直接处理*)
				IF (tmNow-tmLastStateChanged_prestart)>=T#500ms THEN (* 2021.3.3.114446/改为time()计时方法 *)
					pstStIOMap_Main_If^.o_xLamp_Prestart:= NOT pstStIOMap_Main_If^.o_xLamp_Prestart; (* 2021.3.3.114238/翻转状态 *)
					pstStIOMap_Main_Of^.o_xLamp_Prestart:= NOT pstStIOMap_Main_Of^.o_xLamp_Prestart;
					//IF iN=1(*i_iGrpAxisNum_PU*) THEN(*检查到最后一个轴更新时间*)
						tmLastStateChanged_prestart:= tmNow; (* 记录下这次状态变化的时间 *)
					//END_IF
				END_IF

				(*2021.7.23.144216 altma处理在空转时候闪烁空转灯|印刷时候闪烁印刷灯*)
				IF i_iCustomerNameId=CUSTOMERNAME_ALTMA THEN
					pstStIOMap_Main_If^.o_xLamp_Ink:=pstStIOMap_Main_If^.o_xLamp_Prestart AND i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Ink;
					pstStIOMap_Main_If^.o_xLamp_Print:=pstStIOMap_Main_If^.o_xLamp_Prestart AND i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Print;
					pstStIOMap_Main_Of^.o_xLamp_Ink:=pstStIOMap_Main_Of^.o_xLamp_Prestart AND i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Ink;
					pstStIOMap_Main_Of^.o_xLamp_Print:=pstStIOMap_Main_Of^.o_xLamp_Prestart AND i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Print;
				END_IF
			//END_IF
		ELSE
			pstStIOMap_Main_If^.o_xLamp_Prestart:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_PreStart OR i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Ink OR i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Print;
			pstStIOMap_Main_Of^.o_xLamp_Prestart:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_PreStart OR i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Ink OR i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Print;
			tmLastStateChanged_prestart:= tmNow; (* 2021.3.3.113954/ *)
		END_IF
		
		
		(*收牵指示灯处理|*)
		IF i_iAxisId_Of>=1 AND i_iAxisId_Of<=MAX_UNIT_NUM THEN
			pstStIOMap_Main:= ADR(i_pastStIOMap_Main^[i_iAxisId_Of]);
					pstStIOMap_Main^.o_xLamp_Estop:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Estop;
					pstStIOMap_Main^.o_xLamp_Stop:= xLamp_Stop;
					pstStIOMap_Main^.o_xLamp_Ink:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Ink;
					pstStIOMap_Main^.o_xLamp_Tension:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Tension;
					pstStIOMap_Main^.o_xLamp_AllPress:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_AllPress;(*全体合压灯*)

		END_IF
		(*放牵指示灯处理|*)
		IF i_iAxisId_If>=1 AND i_iAxisId_If<=MAX_UNIT_NUM THEN
			pstStIOMap_Main:= ADR(i_pastStIOMap_Main^[i_iAxisId_If]);
					pstStIOMap_Main^.o_xLamp_Estop:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Estop;
					pstStIOMap_Main^.o_xLamp_Stop:= xLamp_Stop;
					pstStIOMap_Main^.o_xLamp_Ink:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Ink;
					pstStIOMap_Main^.o_xLamp_Tension:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Tension;
					pstStIOMap_Main^.o_xLamp_AllPress:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_AllPress;(*全体合压灯*)

		END_IF

	ELSE
		o_iErNo:= -1;
	END_IF
END_IF