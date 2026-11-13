(*@CES
Name=KS_FB_AxisInchCtl
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=962c4a2d-5100-4818-8083-96730c4559b1
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_AxisInchCtl
VAR_INPUT
	i_xEn: BOOL;(*使能|*)
	i_iGrpId: INT;(*系id|*)
	i_iGrpAxisNum_Pu: INT;(*色组轴的数量|*)
	i_aiGrpAxisList: ARRAY [1..MAX_UNIT_NUM] OF INT;(*系内所有轴的id列表,色组部分已经按照从小到大的顺序排序了，之后的是牵引|*)
	i_pstStSysParam: POINTER TO StSysParam;(*参数结构|*)
//	i_pastStPTSts: POINTER TO ARRAY [1..MAX_STATION_NUM] OF StPTSts;(*PT运动轴的状态|*)
	i_pastStIOMap_Main_FE						: POINTER TO ARRAY [1..4] OF StIOMap_Main_FE;(*轴io数据区域|AB系*)
	i_pastStIOMap_Axis_FE					: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF StIOMap_Axis_FE;(*轴io数据区域|`````````````````````````````````````````````*)
	i_pstStEvtReq: POINTER TO StEvtReq;(*输入动作|*)
	i_xAllLinkageAxis_Inch:BOOL;(*2022.5.21.103459 所有联动轴单运行功能使能标志*)
END_VAR
VAR_OUTPUT
	o_xEno: BOOL;(*Same with i_xEn|*)
	o_iErNo: INT;(*-1参数错误\|*)
	o_xHasAxisOnInchRunningSts: BOOL;(*True标识有轴还在单运行|*)
	o_diVel_Virtual_Tar_Inch: DINT;(*虚拟主轴规划速度*)
	o_lrMax_a_S_pos_Inch: LREAL;(*虚拟主轴最大减速度*)
	o_arInchTarVel : ARRAY [1..MAX_UNIT_NUM] OF REAL;
END_VAR
VAR
	iN: INT;
	iUnitId: INT;
	pstStGrpParam_Save: POINTER TO StGrpParam_Save;
	pstStGrpParam_UnSave: POINTER TO StGrpParam_UnSave;
	pstStUnitParam_Save: POINTER TO StUnitParam_Save;
	pstStUnitParam_UnSave: POINTER TO StUnitParam_UnSave;
	axAxisInching_Temp:ARRAY [1..MAX_UNIT_NUM] OF BOOL;(*轴单运行中@无效的时候不一定是真正的0速*)	
	axInchPressReq: ARRAY [1..MAX_UNIT_NUM] OF BOOL := [MAX_UNIT_NUM(FALSE)];	
	pstStIOMap_Axis_FE					: POINTER TO StIOMap_Axis_FE;(*轴io数据区域|`````````````````````````````````````````````*)
	abyAxisMoveSts:ARRAY [1..MAX_UNIT_NUM] OF BYTE;(*轴运动状态@=1 单运行状态|=2 jog运动状态|=3 等待状态*)	
	axInchAxisRev:ARRAY [1..MAX_UNIT_NUM] OF BOOL;(*反转标志处理@默认是正转*)	
	axFlag_Inched : ARRAY [1..MAX_UNIT_NUM] OF BOOL := [MAX_UNIT_NUM(FALSE)];	
	axAxisInchAutoAccing:ARRAY [1..MAX_STATION_NUM] OF BOOL;(*轴单运行自动加速中*)
	arInchTarVel: ARRAY [1..MAX_STATION_NUM] OF REAL;
	iInchMaxVel:INT:=50;(*单运行最大速度*)
	xAccBtn: BOOL;
	xDecBtn: BOOL;	
	lrTmp:LREAL;
	
	//2025.10.28.140624 | bai.zy | 单运行的轴速度先单独拿出来
	adiVel_Virtual_Tar_Inch : ARRAY [1..MAX_UNIT_NUM] OF DINT;
END_VAR

{IMPLEMENTATION}
(*////////////////////////////////////////*)
(*2019.6.14.092753|单运行增加整机单运行|联动色组按下单运行后所有联动色进入单运行*)
(*////////////////////////////////////////*)
o_xEno:= i_xEn;
o_iErNo:= 0;(*初始化错误代码|*)
o_xHasAxisOnInchRunningSts:= FALSE;
IF i_xEn THEN
	IF (i_iGrpId=1 OR i_iGrpId=2) AND
		(i_iGrpAxisNum_Pu>=1 AND i_iGrpAxisNum_Pu<=MAX_STATION_NUM) AND
		i_pstStSysParam<>0 AND

		i_pastStIOMap_Main_FE<>0 AND
		i_pastStIOMap_Axis_FE<>0 AND
		i_pstStEvtReq<>0 THEN(*2019.6.13.191036|*)
		(*the parameters are valid|*)
		pstStGrpParam_Save:= ADR(i_pstStSysParam^.astStGrpParam_Save[i_iGrpId]);
		pstStGrpParam_UnSave:= ADR(i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId]);
		(*2022.5.21.103542*)
		IF i_xAllLinkageAxis_Inch THEN;
		ELSE(*不允许整机单运行|*)
			i_pstStEvtReq^.xReqAllInchRun:=FALSE;(*屏蔽按钮*)
		END_IF

		IF i_pstStSysParam^.stStSysParam_Save.xWorkMode_Inch THEN(*单运行方式true一次走一次停*)
			(*先识别动作|*)
			(*整机|*)
			IF i_pstStEvtReq^.xReqAllInchRun THEN(*按了整机单运行|联动色组的单运行也是作为整机单运行处理||*)
				pstStGrpParam_UnSave^.xFlag_AllInchRun:= NOT pstStGrpParam_UnSave^.xFlag_AllInchRun;(*切换单运行状态|*)
			END_IF
			(*2023.6.18.231611 条件优化*)
(*			FOR iN:=1 TO i_iGrpAxisNum_Pu BY 1 DO*)
			FOR iN:=1 TO i_iGrpAxisNum_Pu BY 1 DO(*条件优化@2023.6.16.132433*)
				iUnitId:= i_aiGrpAxisList[iN];(*轴id|*)
				pstStUnitParam_Save:= ADR(i_pstStSysParam^.astStUnitParam_Save[iUnitId]);
				pstStUnitParam_UnSave:= ADR(i_pstStSysParam^.astStUnitParam_UnSave[iUnitId]);
				IF pstStUnitParam_Save^.xLinkage AND
(*						pstStAxisParam^.xAxisInching<>pstStGrpParam^.xFlag_AllInchRun*)
					axAxisInching_Temp[iUnitId]<>pstStGrpParam_UnSave^.xFlag_AllInchRun THEN
(*						pstStAxisParam^.xAxisInching:= pstStGrpParam^.xFlag_AllInchRun;*)
					(*2023.6.18.232053 替换为了临时变量*)
					axAxisInching_Temp[iUnitId]:= pstStGrpParam_UnSave^.xFlag_AllInchRun;
				END_IF

			END_FOR

			(*单动轴|*)
			FOR iN:=1 TO i_iGrpAxisNum_Pu BY 1 DO
				iUnitId:= i_aiGrpAxisList[iN];(*轴id|*)
				pstStUnitParam_Save:= ADR(i_pstStSysParam^.astStUnitParam_Save[iUnitId]);
				pstStUnitParam_UnSave:= ADR(i_pstStSysParam^.astStUnitParam_UnSave[iUnitId]);
				IF (NOT pstStUnitParam_Save^.xLinkage) AND
					(NOT axInchPressReq[iUnitId]) AND
					axInchPressReq[iUnitId]<>i_pastStIOMap_Axis_FE^[iUnitId].i_xInch THEN
	(*					pstStAxisParam^.xAxisInching:= NOT pstStAxisParam^.xAxisInching;*)
					(*2023.6.18.232053 替换为了临时变量*)
					axAxisInching_Temp[iUnitId]:= NOT axAxisInching_Temp[iUnitId];
				END_IF
			END_FOR		
		ELSE(*按住走松开停*)
		(*整机|*)
			pstStGrpParam_UnSave^.xFlag_AllInchRun:=i_pstStEvtReq^.xEvt_AllInchRun;(*切换当运行状态*)
			(*条件优化@2023.6.18.231700*)
(*			FOR iN:=1 TO i_iGrpAxisNum_Pu BY 1 DO*)
			FOR iN:=1 TO i_iGrpAxisNum_Pu BY 1 DO
				iUnitId:= i_aiGrpAxisList[iN];(*轴id|*)
				pstStUnitParam_Save:= ADR(i_pstStSysParam^.astStUnitParam_Save[iUnitId]);
				pstStUnitParam_UnSave:= ADR(i_pstStSysParam^.astStUnitParam_UnSave[iUnitId]);
(*					pstStAxisParam^.xAxisInching:= pstStGrpParam^.xFlag_AllInchRun
													AND pstStAxisParam^.xLinkage;(*2019.12.6.110501|增加了联动条件|Liu.yt*)*)
					(*2023.6.18.232053 替换为了临时变量*)
				axAxisInching_Temp[iUnitId]:= pstStGrpParam_UnSave^.xFlag_AllInchRun
													AND pstStUnitParam_Save^.xLinkage;(*2019.12.6.110501|增加了联动条件|Liu.yt*)

			END_FOR

			(*单动轴|*)
			FOR iN:=1 TO i_iGrpAxisNum_Pu BY 1 DO
				iUnitId:= i_aiGrpAxisList[iN];(*轴id|*)
				pstStUnitParam_Save:= ADR(i_pstStSysParam^.astStUnitParam_Save[iUnitId]);
				pstStUnitParam_UnSave:= ADR(i_pstStSysParam^.astStUnitParam_UnSave[iUnitId]);
				IF (NOT pstStUnitParam_Save^.xLinkage) THEN
(*					pstStAxisParam^.xAxisInching:= axInchPressReq[iAxisId];*)
					(*2023.6.18.232053 替换为了临时变量*)
					axAxisInching_Temp[iUnitId]:=axInchPressReq[iUnitId];
				END_IF
			END_FOR			
		END_IF

(*2025.10.23.160344这里先放着后面细看处理start*)
		(*兼容单运行和jog模式*)
		FOR iN:=1 TO i_iGrpAxisNum_Pu BY 1 DO
			iUnitId:= i_aiGrpAxisList[iN];(*轴id|*)
			pstStUnitParam_Save:= ADR(i_pstStSysParam^.astStUnitParam_Save[iUnitId]);
			pstStUnitParam_UnSave:= ADR(i_pstStSysParam^.astStUnitParam_UnSave[iUnitId]);
			pstStIOMap_Axis_FE:=ADR(i_pastStIOMap_Axis_FE^[iUnitId]);
			CASE abyAxisMoveSts[iUnitId] OF
				1:(*单运行状态*)
					pstStUnitParam_UnSave^.xAxisInching:= axAxisInching_Temp[iUnitId];
					axInchAxisRev[iUnitId]:= FALSE;//i_pstStShmGlobalParam^.astStGrpParam[i_iGrpId].xUnitRev;(*方向控制*)
					IF NOT pstStUnitParam_UnSave^.xAxisInching AND(*退出了单运行*)
						NOT g_axAxisInching[iUnitId] (*AND(*完全退出了单运行*)		//2025.10.28.114601 | bai.zy | 屏蔽状态机
						pstStAxisParam^.iAxisInchingCaseId=MOTION_STEP_Nothing*) THEN(*退出到初始状态了*)
						abyAxisMoveSts[iUnitId]:=0;
					END_IF
				2:(*JOG状态*)
					IF (NOT pstStUnitParam_Save^.xLinkage) THEN
						pstStUnitParam_UnSave^.xAxisInching:=axAxisInching_Temp[iUnitId];
								(*pstStIOMap_AxisBasic^.i_xServoJog_For OR		//2025.10.28.114601 | bai.zy | 屏蔽方向
								pstStIOMap_AxisBasic^.i_xServoJog_Rev;
						IF pstStIOMap_AxisBasic^.i_xServoJog_Rev THEN
							axInchAxisRev[iUnitId]:=TRUE;(*方向控制*)
						ELSIF pstStIOMap_AxisBasic^.i_xServoJog_For THEN
							axInchAxisRev[iUnitId]:=FALSE;(*方向控制*)
						ELSE(*完全停止了*)
							abyAxisMoveSts[iUnitId]:=3;
						END_IF
						*)
						IF NOT pstStUnitParam_UnSave^.xAxisInching THEN
							abyAxisMoveSts[iUnitId]:=3;
						END_IF
					ELSE(*联动了@清除标志退出case*)
						pstStUnitParam_UnSave^.xAxisInching:=FALSE;
						abyAxisMoveSts[iUnitId]:=3;
					END_IF

				3:(*等待状态*)
					IF NOT pstStUnitParam_UnSave^.xAxisInching AND(*退出了单运行*)
						NOT g_axAxisInching[iUnitId] (*AND(*完全退出了单运行*)		//2025.10.28.114601 | bai.zy | 屏蔽状态机
						pstStAxisParam^.iAxisInchingCaseId=MOTION_STEP_Nothing*) THEN(*退出到初始状态了*)
						abyAxisMoveSts[iUnitId]:=0;
					END_IF

			ELSE
				(*单运行控制@这里只需要赋值就好*)
				pstStUnitParam_UnSave^.xAxisInching:= axAxisInching_Temp[iUnitId];
				abyAxisMoveSts[iUnitId]:=BOOL_TO_BYTE(pstStUnitParam_UnSave^.xAxisInching);(*2023.6.16.132359*)

				IF (NOT pstStUnitParam_Save^.xLinkage) THEN
					(*jog控制@优先单运行*)
					IF NOT pstStUnitParam_UnSave^.xAxisInching THEN
						pstStUnitParam_UnSave^.xAxisInching:=axAxisInching_Temp[iUnitId];
								(*pstStIOMap_AxisBasic^.i_xServoJog_For OR		//2025.10.28.114601 | bai.zy | 屏蔽方向
								pstStIOMap_AxisBasic^.i_xServoJog_Rev;*)
						IF pstStUnitParam_UnSave^.xAxisInching THEN
							abyAxisMoveSts[iUnitId]:=2;
						END_IF
					END_IF
				END_IF
			END_CASE
		END_FOR
(*2025.10.23.160344这里先放着后面细看处理end*)

		IF NOT pstStGrpParam_UnSave^.xFlag_Stop OR (*非停机状态下,禁止各种形式的单运行*)
			(i_pstStEvtReq^.xReqStop AND pstStGrpParam_UnSave^.xFlag_Stop) THEN(*2021.10.15.094231 增加按下停止按钮时候清除单运行*)
			FOR iN:=1 TO i_iGrpAxisNum_Pu BY 1 DO
				iUnitId:= i_aiGrpAxisList[iN];(*轴id|*)
				pstStUnitParam_Save:= ADR(i_pstStSysParam^.astStUnitParam_Save[iUnitId]);
				pstStUnitParam_UnSave:= ADR(i_pstStSysParam^.astStUnitParam_UnSave[iUnitId]);
				pstStUnitParam_UnSave^.xAxisInching:=FALSE;
				axAxisInching_Temp[iUnitId]:=FALSE;(*2023.6.18.232805@无效的时候不一定是真正的0速*)
				abyAxisMoveSts[iUnitId]:=0;(*2023.6.18.231830*)
			END_FOR
			(*非停机的时候清除全体运行标志|2019.12.6.110407*)
			pstStGrpParam_UnSave^.xFlag_AllInchRun:=FALSE;
		END_IF

		(*2025.1.13.182252+*)
		IF pstStGrpParam_UnSave^.xFlag_Home OR
			pstStGrpParam_UnSave^.xFlag_PreRegister OR
			pstStGrpParam_UnSave^.xFlag_PhaseRestore OR
			pstStGrpParam_UnSave^.xFlag_PhaseRead THEN
			pstStGrpParam_UnSave^.xFlag_AllInchRun:=FALSE;
		END_IF
		(*移位到aaaa处|2020.10.12.161828*)
		
	
	ELSE
		o_iErNo:= -1;(*参数非法|*)	
	END_IF	
ELSE
	IF (i_iGrpId=1 OR i_iGrpId=2) AND
		(i_iGrpAxisNum_Pu>=1 AND i_iGrpAxisNum_Pu<=MAX_STATION_NUM) AND
		i_pstStSysParam<>0 AND

		i_pastStIOMap_Main_FE<>0 AND
		i_pastStIOMap_Axis_FE<>0 AND
		i_pstStEvtReq<>0 THEN(*2019.6.13.191036|*)
		(*the parameters are valid|*)

		pstStGrpParam_Save:= ADR(i_pstStSysParam^.astStGrpParam_Save[i_iGrpId]);
		pstStGrpParam_UnSave:= ADR(i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId]);
		FOR iN:=1 TO i_iGrpAxisNum_Pu BY 1 DO
			iUnitId:= i_aiGrpAxisList[iN];(*轴id|*)
			pstStUnitParam_Save:= ADR(i_pstStSysParam^.astStUnitParam_Save[iUnitId]);
			pstStUnitParam_UnSave:= ADR(i_pstStSysParam^.astStUnitParam_UnSave[iUnitId]);
//			iStationId:= pstStAxisParam^.iStationId;(*站id|*)
			axFlag_Inched[iUnitId]:=FALSE;
			i_pastStIOMap_Axis_FE^[iUnitId].o_xLamp_Inch:= FALSE;
			pstStUnitParam_UnSave^.xAxisInching:=FALSE;
			axAxisInching_Temp[iUnitId]:=FALSE;(*2023.6.18.232805*)
			abyAxisMoveSts[iUnitId]:=0;(*2023.6.18.231830*)
(*
			g_axAxisInchDecing[iAxisId]:=FALSE;
			g_axAxisInching[iAxisId]:=FALSE;*)
		END_FOR
		o_xHasAxisOnInchRunningSts:= FALSE;

		pstStGrpParam_UnSave^.xFlag_AllInchRun:= FALSE; (* 2020.10.12.114752|将整机单运行标志清除掉 *)
	END_IF	
END_IF

IF i_pstStSysParam<>0 AND

	i_pastStIOMap_Main_FE<>0 AND
	i_pastStIOMap_Axis_FE<>0 AND
	i_pstStEvtReq<>0 THEN(*2019.6.13.191036|*)
	pstStGrpParam_Save:= ADR(i_pstStSysParam^.astStGrpParam_Save[i_iGrpId]);
	pstStGrpParam_UnSave:= ADR(i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId]);
	(*aaaa*)
	FOR iN:=1 TO i_iGrpAxisNum_Pu  BY 1 DO
		iUnitId:= i_aiGrpAxisList[iN];(*轴id|*)
		pstStUnitParam_Save:= ADR(i_pstStSysParam^.astStUnitParam_Save[iUnitId]);
		pstStUnitParam_UnSave:= ADR(i_pstStSysParam^.astStUnitParam_UnSave[iUnitId]);
		pstStIOMap_Axis_FE:=ADR(i_pastStIOMap_Axis_FE^[iUnitId]);
	//	iStationId:= pstStAxisParam^.iStationId;(*站id|*)
	//	pstAxisStPTSts:= ADR(i_pastStPTSts^[iAxisId]);(*PTSts|*)
	
		(*2022.2.15.141220*)
		xAccBtn:=pstStIOMap_Axis_FE^.i_xAcc;
		xDecBtn:=pstStIOMap_Axis_FE^.i_xDec;
		IF pstStGrpParam_UnSave^.xFlag_AllInchRun THEN(*如果是整机点运行|加减速使用整机加减速按钮*)
			xAccBtn:=i_pstStEvtReq^.xEvt_ManuSpdUp;
			xDecBtn:=i_pstStEvtReq^.xEvt_ManuSpdDn;
		END_IF
	
		(*2019.10.23.155917 对单运行停止做规划,不再像以前一样直接下伺服|Liu.yt---START*)
		IF pstStUnitParam_UnSave^.xAxisInching THEN
			IF NOT g_axAxisInching[iUnitId] THEN(*先自动加速到单运行速度*)
				g_axAxisInching[iUnitId]:=TRUE;
				g_axAxisInchAccing[iUnitId]:=TRUE;
				g_axAxisInchDecing[iUnitId]:=FALSE;
				axAxisInchAutoAccing[iUnitId]:=TRUE;
				arInchTarVel[iUnitId]:= pstStGrpParam_Save^.rVel_Inch;
			END_IF
	
			IF axAxisInchAutoAccing[iUnitId] THEN
				IF pstStUnitParam_UnSave^.rAxisVel_PrnRoller= pstStGrpParam_Save^.rVel_Inch THEN(*到达目标速度*)
					axAxisInchAutoAccing[iUnitId]:=FALSE;
				END_IF
	
				IF xAccBtn OR
					xDecBtn THEN
					axAxisInchAutoAccing[iUnitId]:=FALSE;
				END_IF
			ELSE
				g_axAxisInchAccing[iUnitId]:=FALSE;
				g_axAxisInchDecing[iUnitId]:=FALSE;
				IF xAccBtn THEN
					g_axAxisInchAccing[iUnitId]:=TRUE;
					g_axAxisInchDecing[iUnitId]:=FALSE;
					arInchTarVel[iUnitId]:=INT_TO_REAL(iInchMaxVel);(**)
				ELSIF xDecBtn THEN
					g_axAxisInchAccing[iUnitId]:=FALSE;
					g_axAxisInchDecing[iUnitId]:=TRUE;
				END_IF
			END_IF
		ELSIF g_axAxisInching[iUnitId] THEN
			axAxisInchAutoAccing[iUnitId]:=FALSE;
			g_axAxisInchAccing[iUnitId]:=FALSE;
			g_axAxisInchDecing[iUnitId]:=TRUE;
			IF pstStUnitParam_UnSave^.rAxisVel_PrnRoller = 0 THEN
				g_axAxisInchDecing[iUnitId]:=FALSE;
				g_axAxisInching[iUnitId]:=FALSE;
			END_IF
		END_IF
		(*2019.10.23.155917 对单运行停止做规划,不再像以前一样直接下伺服|Liu.yt---END*)
	(*放速度规划吧2025.10.23.164518*)
		IF 	pstStUnitParam_UnSave^.xAxisInching OR g_axAxisInchDecing[iUnitId] THEN
// 			IF pstStUnitParam_UnSave^.iAxisPrnRunCaseId=MOTION_STEP_Nothing THEN(*这里做速度规划-让主轴先动起来*)
// 				//2025.10.28.113117 | bai.zy | 在此处转换成脉冲每毫秒
// 				//o_diVel_Virtual_Tar_Inch:= LREAL_TO_DINT(arInchTarVel[iUnitId]);
// 				o_diVel_Virtual_Tar_Inch:= LREAL_TO_DINT(arInchTarVel[iUnitId]*GC_LRMOTORPPR/pstStUnitParam_Save^.rGirth_PrnRoller/60.0);
// 				o_lrMax_a_S_pos_Inch:= 0.2;
// 			ELSE(*这里规划单运行轴的轴速度*)
				//2025.10.28.113117 | bai.zy | 在此处转换成脉冲每毫秒
				//o_diVel_Virtual_Tar_Inch:= LREAL_TO_DINT(arInchTarVel[iUnitId]);
				//o_diVel_Virtual_Tar_Inch:= LREAL_TO_DINT(arInchTarVel[iUnitId]*GC_LRMOTORPPR/pstStUnitParam_Save^.rGirth_PrnRoller/60.0);
				adiVel_Virtual_Tar_Inch[iUnitId] := LREAL_TO_DINT(arInchTarVel[iUnitId]*GC_LRMOTORPPR/
																gc_rGirth_Master/60.0/1000);
				o_lrMax_a_S_pos_Inch:= 0.2;
				IF g_axAxisInchAccing[iUnitId] THEN
					(*单运行的加速做点处理@在开始的时候加速慢一点,到达一定速度后再加快,方便预套准对mark线*)
					IF ABS(pstStUnitParam_UnSave^.rAxisVel_PrnRoller)>3 THEN
						lrTmp:=0.2;
					ELSE
						lrTmp:=0.04;
					END_IF

					pstStUnitParam_UnSave^.rAxisVel_PrnRoller:= pstStUnitParam_UnSave^.rAxisVel_PrnRoller+lrTmp;(*2025.1.15.150454 调整*)
					IF pstStUnitParam_UnSave^.rAxisVel_PrnRoller>=arInchTarVel[iUnitId] THEN
						pstStUnitParam_UnSave^.rAxisVel_PrnRoller:= arInchTarVel[iUnitId];
					END_IF
				ELSIF g_axAxisInchDecing[iUnitId] THEN(*单运行减速中*)
					pstStUnitParam_UnSave^.rAxisVel_PrnRoller:= pstStUnitParam_UnSave^.rAxisVel_PrnRoller-0.4;(*减速快一点*)
					IF pstStUnitParam_UnSave^.rAxisVel_PrnRoller<=0 THEN
						pstStUnitParam_UnSave^.rAxisVel_PrnRoller:= 0;
					END_IF
				END_IF
				IF NOT o_xHasAxisOnInchRunningSts THEN
					o_xHasAxisOnInchRunningSts:= TRUE;
				END_IF
			//END_IF
		ELSE
			o_xHasAxisOnInchRunningSts:= FALSE;	
			//o_diVel_Virtual_Tar_Inch:= 0;
			adiVel_Virtual_Tar_Inch[iUnitId] := 0;
			o_lrMax_a_S_pos_Inch:= 0.2;			
		END_IF
	
	END_FOR
	
	//2025.10.28.140948 | bai.zy | 输出速度
	FOR iN := 1 TO i_iGrpAxisNum_Pu BY 1 DO
		pstStUnitParam_Save:= ADR(i_pstStSysParam^.astStUnitParam_Save[iN]);
		pstStUnitParam_UnSave:= ADR(i_pstStSysParam^.astStUnitParam_UnSave[iN]);
		IF (pstStUnitParam_UnSave^.xAxisInching OR pstStGrpParam_UnSave^.xFlag_AllInchRun) AND adiVel_Virtual_Tar_Inch[iN] <> 0 THEN
			o_diVel_Virtual_Tar_Inch :=  adiVel_Virtual_Tar_Inch[iN];
			EXIT;
		END_IF
	END_FOR
END_IF

IF i_pastStIOMap_Axis_FE<>0 THEN
	FOR iN:=1 TO MAX_UNIT_NUM BY 1 DO
		axInchPressReq[iN]:= i_pastStIOMap_Axis_FE^[iN].i_xInch;
		o_arInchTarVel[iN] := i_pstStSysParam^.astStUnitParam_UnSave[iN].rAxisVel_PrnRoller;
	END_FOR
END_IF