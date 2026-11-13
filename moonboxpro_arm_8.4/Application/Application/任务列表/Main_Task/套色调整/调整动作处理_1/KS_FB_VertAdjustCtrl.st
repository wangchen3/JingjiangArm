(*@CES
Name=KS_FB_VertAdjustCtrl
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=fc5eaf36-4560-4ac2-859d-f15f0685439f
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_VertAdjustCtrl(* 2020.7.31.144133/纵向调整功能函数运行匀墨状态进入进行快速对版/实现空转版辊相位调整空转状态下只能进行快速对版功能 *)
(*2021.10.18.104821 处理在非印刷或者印刷状态下未开套色或者手动情况下作为色组联动指示逻辑*)
(*2022.7.6.112935 三色灯的报警灯作为按下急停后的指示*)
(*2022.12.6.112200 联动时候输出lost指示灯*)
(*2023.6.1.134525 纵横向跟踪第一色或者跟踪前一色等待料长的方式是不一样的，这里进行优化处理
@跟踪色标是有可能跟踪任意色的，先按照等待第一色料长到达处理
@全自动套印屏蔽除了快速对版意外的调整处理*)
(*2023.07.07.160631 增加i_byLinkage_Lamp_3_Color 接口控制联动时显示的指示灯*)
(*2023.08.16.085201 增加了分段耦合测试@有误差传递就需要先补偿一部分再清除补偿的这部分
阶跃响应是有调整量传递的*)
(*2023.09.19.170846 阶跃启动条件优化|并增加了清除实现*)
(*2024.01.02.113738 增加了第10中耦合方法@小黄+*)
(*2024.7.24.083408 阶跃输出等待一圈的条件优化
11种方式耦合计算也取消累计
*)
(*2024.9.4.101635 阶跃增加过解耦和不过解耦的程序切换实现,未做到界面上*)
(*2025.3.21.000830 纵向等料长取消调整的处理屏蔽@因为新的耦合算法调整量和耦合量都在一个变量里,需要在计算调整量的时候处理等料长*)
(*2025.5.16.002058 i_pabyVerManuTrigButton+ vc实现纵向手动上下(波形右左)|使用补偿仓库@存在阶跃时候可能会显示值,先不管了*)
(*2025.7.1.124507  增加三色灯的收放牵输出处理|急停红色@停机、空转绿色@印刷根据色组三色指示输出(至少一个报警、丢失|全部正常输出绿灯)*)
VAR_INPUT
	i_xEn: BOOL; (* 使能 *)
	i_iGrpId: INT; (* 系id *)
	i_iGrpAxisNum_Pu: INT; (* 系的色组轴数 *)
	i_iGrpAxisTotalNum: INT; (* 系的轴数量 *)
	i_abyGrpAxisList: ARRAY [1..MAX_UNIT_NUM] OF BYTE; (* 系属轴列表 *)
	i_pstStSysParam: POINTER TO StSysParam; (* 参数结构 *)
	i_pastStIOMap_Axis_FE: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF StIOMap_Axis_FE; (* 基础io *)
	i_pastStRegAdjMana: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF StRegAdjMana; (* 单元调整量 *)
	i_pastStAxisRapidAdjProf_V: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF StAxisRapidAdjProf_V; (* 纵向快速对版/2019.11.18.145302_ *)
	i_iCycleTime_Motion: INT; (* 运动规划周期 *)
	i_iCycleTime_PlcTask: INT; (* Plc任务周期 *)
(*	(*2022.4.9.153456*)
	i_xLamp_3_Mode:BOOL;(*三色灯显示模式|默认在非印刷的时候按照联动指示用，
										 否则在非印刷的时候不显示三色灯*)
*)
	i_byLamp_3_Mode:BYTE;(*三色灯显示模式2025.2.17.214902
												    @0 默认在非印刷的时候按照联动指示用，红色作为急停！
										 			@1 在非印刷的时候不显示三色灯,
													@2 欧诺专用*)
	(*2023.07.07.155633 增加三色灯接口*)
	i_byLinkage_Lamp_3_Color:BYTE;(*联动时三色灯颜色|默认=Normal|1=Lost|2=warning*)
	i_xAutoAdjustbyRapidAdjust:BOOL;(*2023.6.2.145251 全自动套印@通过快速对版方式*)
	(*2023.08.19.104727*)
	i_byCouplingType:BYTE;(*耦合方式@=0原来的直接传递的逻辑@不输出耦合量
									@=1新修改的按照比例定位传递。总量100%@从o_aiCouplingValue_A输出
									@=2新修改的按照比例定位传递。总量根据输入的耦合值@从o_aiCouplingValue_A输出
					测试的			@=3调整量传递按照立刻传递70%。等待机组料长后反向传递40%@从o_aiCouplingValue_A输出
									@=4调整量传递按照立刻传递一定比例-没有第二段传递@从o_aiCouplingValue_A输出
									@=5调整引起张力变化需要直接传递一定比例-等到达下一色取消这部分传递o_aiCouplingValue_T输出、
									   等待固定料长传递之前调整的量o_aiCouplingValue_A输出*)
	(*支持数负值@超过一个色组料长*)
	i_iRemaindPartCouplingPos	: INT;(*剩余部分的耦合位置@距离总幅数
														   @=1 到达下一色前第一幅
														   @=2 到达下一色前第二幅*)
	(*2023.09.04.131935*)
	i_iGrpArcAxisNum_Pu: INT; (* 系的联动轴套色打开数量|色组按照从小到大排序了 *)
	i_abyGrpArcAxisList: ARRAY [1..MAX_UNIT_NUM] OF BYTE; (* 系的联动轴套色打开列表 *)
	i_awVirtualCnt: ARRAY [1..MAX_UNIT_NUM] OF WORD;
	(*参数扩展到横向(横向阶跃只取i_iMicron_StepTest1_V)@2023.09.04.231241*)
	i_iAxisId_StepTest_V: INT; (* 纵向阶跃测试的轴id *)
	i_iMicron_StepTest1_V: INT; (* 纵向阶跃量,单位:微米 *)
	i_iMicron_StepTest2_V: INT; (* 纵向阶跃量,单位:微米 *)
	i_iInterval_StepTest12:INT;
	i_byType_StepTest:BYTE;(*阶跃类型|=1 横向|反之 纵向*)
	i_pstStDeCoupleCoeff:POINTER TO StDeCoupleCoeff;(*2024.9.10.134022  耦合系数*)
	i_pabyVerManuTrigButton:POINTER TO ARRAY [1..MAX_UNIT_NUM] OF BYTE;(*纵向vc界面手动上下按钮*)
END_VAR
VAR_OUTPUT
	o_xEno: BOOL;
	o_iErNo: INT; (* 错误代码 *)
END_VAR
VAR_IN_OUT
	io_xStepTest_V: BOOL; (* 纵向阶跃测试 @扩展为了纵横向阶跃按钮*)
END_VAR
VAR
	iN: INT;
	iK: INT;
	iRtn: INT;
	iUnitId: INT;
	dwN: DWORD;
	iTempAdjVal_V: INT;
	iTempAdjVal_H: INT;

	diRapidAdjustment: DINT;
	lrAdjustVal_CurCycle_Auto: LREAL := 0;
	lrAdjustVal_CurCycle_Manu: LREAL := 0;
	lrAdjustVal_CurCycle_Rapid: LREAL := 0;
	(*2025.5.16.111235+*)
	lrAdjustVal_CurCycle_Compensate: LREAL := 0;(*2025.5.16.110830+补偿量单位周期的调整量*)
	lrVel_CompensateAdjust:LREAL:=0.1(*0.06*);(*m/min|1mm/s*)(*操作时界面感觉有点慢，故加大到0.1*)
	lrAxisCouplingVal: LREAL; (* 轴耦合量 *)
	afbR_TRIG_UpAdj: ARRAY [1..MAX_UNIT_NUM] OF R_TRIG;
	afbR_TRIG_DnAdj: ARRAY [1..MAX_UNIT_NUM] OF R_TRIG;
	pstStUnitParam_Save: POINTER TO StUnitParam_Save;
	pstStUnitParam_UnSave: POINTER TO StUnitParam_UnSave;
	pstStGrpParam_Save: POINTER TO StGrpParam_Save;
	pstStGrpParam_UnSave: POINTER TO StGrpParam_UnSave;
	iAxisId_Tmp: INT; (* 2018.8.20.093328 *)
	pstStUnitParam_Save_Tmp: POINTER TO StUnitParam_Save;
	pstStUnitParam_UnSave_Tmp: POINTER TO StUnitParam_UnSave;
	(*2023.6.1.135511*)
	xWaitFilmLenth_V: BOOL;(*纵向等料长*)
	xWaitFilmLenth_H: BOOL;(*横向等料长*)


	(*2023.08.19.104636*)
// 	fbKS_FB_GetCouplingValue_V: KS_FB_GetCouplingValue_V;
// 	arCouplingValue:ARRAY [1..MAX_UNIT_NUM] OF REAL;(*张力耦合@+-耦合*)
// 	byCouplingType: BYTE;
// 	byLastCouplingType: BYTE;

	(*阶跃方波实现*)
	byStepTestIndex: BYTE;(*=1 更新幅数初始数据 |
							=2 等待下一个精采样更新开始处理第一段阶跃 |
							=3 处理第一段阶跃 |
							=4 等待固定幅长|	
							=5 等待下一个精采样更新
							=6 处理第二段阶跃

							=10 横向阶跃*)

	wLastvirtualCnt: WORD;
	byLapNum: BYTE;
	iAxisIdStepTest: INT;
	byAxisLapNumStepTest:BYTE;
	uiFSampleCounter_Init: UINT;(*统计精采样圈数*)
	rTimeCycle:REAL;(*转一圈的时间-ms@2024.7.30.115215*)
	rAdjustVal_CurCycle_Auto_Max:REAL;(*用于自动调整的当量@2024.8.2.191432*)
	arAdjustValTmp_CurCycle_Auto: ARRAY [1..MAX_UNIT_NUM] OF REAL;(*自动调整当量@按照一圈时间调完方式*)
	(*2025.2.22.092149 默认阶跃是过解耦的*)
	xCompensate_DeCouple: BOOL:=TRUE;		(*补偿值进行解耦@2024.9.4.091559+*)
	by3LampDisByMode: BYTE;(*按照模式显示(./0 非印刷即空转 ./1印刷非首色轴套色非自动 ./2 首色或者未联动)@2025.2.18.161612*)
	(*2025.5.16.003914+*)
	iManuAdjust_V: INT:=1;(*纵向手动调整量@mm|*)
	(*2025.7.1.110613+ 至少一色报警了*)
	byArcStsTotal: BYTE;(*总的套色状态|.0 Alarm(至少一色) |.1 Lost(至少一色)|.2 套色都正常*)
	xFlag_Estop: BOOL;(*急停标志*)
	pstStIOMap_Axis_FE: POINTER TO StIOMap_Axis_FE; (* 基础io *)
	
END_VAR

{IMPLEMENTATION}
o_xEno:= i_xEn;
o_iErNo:= 0;
(*2023.09.27.092543*)
(*i_xEn:=TRUE;*)
//byCouplingType:=i_byCouplingType;
(*扩展到牵引轴@控制牵引轴的三色等输出|2025.7.1.113942+*)
byArcStsTotal := 0;
byArcStsTotal.2 := TRUE;(*默认正常*)

(*一直获取@2025.7.1.124325+*)
IF i_iGrpId = 1 OR i_iGrpId = 2 THEN
	pstStGrpParam_Save:= ADR(i_pstStSysParam^.astStGrpParam_Save[i_iGrpId]);
	pstStGrpParam_UnSave:= ADR(i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId]);
ELSE
	pstStGrpParam_Save := 0;
	pstStGrpParam_UnSave := 0;	
END_IF

IF pstStGrpParam_Save<>0 AND pstStGrpParam_UnSave<>0 THEN
	xFlag_Estop:=pstStGrpParam_UnSave^.xFlag_Estop;
ELSE
	xFlag_Estop:=FALSE;
END_IF



(*阶跃测试增加方波测试@间隔一定幅数后继续输出*)
IF io_xStepTest_V THEN
	io_xStepTest_V:=FALSE;
	IF i_iAxisId_StepTest_V>0 AND i_iAxisId_StepTest_V<=MAX_UNIT_NUM THEN
		IF i_xEn THEN
			IF byStepTestIndex=0 AND
				i_pstStSysParam^.astStUnitParam_Save[i_iAxisId_StepTest_V].xLinkage THEN(*需要联动@2023.09.19.17073*)
				byStepTestIndex:=1;
				byAxisLapNumStepTest:=0;
				iAxisIdStepTest:=i_iAxisId_StepTest_V;
			END_IF
		END_IF
	ELSE
		byStepTestIndex:=0;
	END_IF
ELSE
	(*2023.09.19.171042 增加了清除逻辑*)
	IF NOT i_xEn THEN
		byStepTestIndex:=0;
	END_IF

	IF byStepTestIndex=6 OR byStepTestIndex=10 THEN
		byStepTestIndex:=0;
	ELSIF byStepTestIndex=1 OR byStepTestIndex=2 OR
			byStepTestIndex=3 OR byStepTestIndex=4 OR byStepTestIndex=5 THEN
		pstStUnitParam_Save:= ADR(i_pstStSysParam^.astStUnitParam_Save[i_iAxisId_StepTest_V]);
		pstStUnitParam_UnSave:= ADR(i_pstStSysParam^.astStUnitParam_UnSave[i_iAxisId_StepTest_V]);
		(*计圈处理*)
		KS_GetRollerLapNum(
			gc_iVirEncPPR(*i_iVirEncPPR*),
			i_awVirtualCnt[iAxisIdStepTest](*i_wvirtualCnt*),
			ADR(wLastvirtualCnt)(*i_pwLastvirtualCnt*),
			ADR(byLapNum)(*i_pbyLapNum*));



		IF byStepTestIndex=1  THEN(*第一步 更新测试幅数索引*)
			byAxisLapNumStepTest:=byLapNum;
			uiFSampleCounter_Init:=pstStUnitParam_UnSave^.uiFSampleCounter;(*保存当前精采样计数*)
			byStepTestIndex:=2;
		ELSIF byStepTestIndex=2 THEN(*等待下一圈开始*)
(*			IF uiFSampleCounter_Init<>pstStAxisParam^.uiFSampleCounter THEN(*精采样计算变化了*)*)
			(*精采样计算变化了@多等一圈|记录的时候可能已经当前圈快结束了@2024.7.24.083330*)
			IF pstStUnitParam_UnSave^.uiFSampleCounter-uiFSampleCounter_Init>=2 THEN
				IF i_byType_StepTest=1 THEN(*横向阶跃*)
					byStepTestIndex:=10;
				ELSE(*纵向阶跃*)
					byStepTestIndex:=3;(*处理第一段阶跃*)
				END_IF
			END_IF
		ELSIF byStepTestIndex=3 THEN
			byAxisLapNumStepTest:=byLapNum;(*更新测试幅数索引*)
			byStepTestIndex:=4;(*等待固定的幅长*)
		ELSIF byStepTestIndex=4 THEN(*等待固定幅长处理第二段*)
			IF i_iInterval_StepTest12<>0 OR
				i_iMicron_StepTest2_V<>0 THEN(*第二段没调整量*)
				IF BYTE_TO_SINT(byLapNum-byAxisLapNumStepTest)>=i_iInterval_StepTest12 THEN
					byStepTestIndex:=5;
					uiFSampleCounter_Init:=pstStUnitParam_UnSave^.uiFSampleCounter;(*保存当前精采样计数*)
				END_IF
			ELSE
				byStepTestIndex:=0;
			END_IF
		ELSIF byStepTestIndex=5 THEN
			IF uiFSampleCounter_Init<>pstStUnitParam_UnSave^.uiFSampleCounter THEN(*精采样计算变化了*)
				byStepTestIndex:=6;(*处理第二段阶跃*)
			END_IF
		ELSE
			byStepTestIndex:=0;
		END_IF
	ELSE
		byStepTestIndex:=0;
	END_IF
END_IF


IF i_xEn THEN
	IF (i_iGrpId=1 OR i_iGrpId=2) AND(*系id有效|*)
		(i_iGrpAxisNum_Pu>=1 AND i_iGrpAxisNum_Pu<=MAX_UNIT_NUM) AND
		(i_iGrpAxisTotalNum>=i_iGrpAxisNum_Pu AND i_iGrpAxisTotalNum<=MAX_UNIT_NUM) AND
		i_pstStSysParam<>0 AND(*参数有效|*)
		i_pastStIOMap_Axis_FE<>0 AND(*轴IO有效|*)
		i_pastStRegAdjMana<>0 AND(*套色调整列表有效|*)
		i_pastStAxisRapidAdjProf_V<>0 AND(*2019.11.18.145347_*)
		i_pabyVerManuTrigButton<>0 THEN(*2025.5.16.002048+*)

		pstStGrpParam_Save:= ADR(i_pstStSysParam^.astStGrpParam_Save[i_iGrpId]);
		pstStGrpParam_UnSave:= ADR(i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId]);
		(*本周期能规划的位移量<单位:um>|*)
		
		lrAdjustVal_CurCycle_Auto:= pstStGrpParam_Save^.rVel_AutoAdj*i_iCycleTime_Motion*1000.0/60.0;(*自动调整|*)
		lrAdjustVal_CurCycle_Manu:= pstStGrpParam_Save^.rVel_ManuAdj_Fine*i_iCycleTime_Motion*1000.0/60.0;(*手动调整|*)
		lrAdjustVal_CurCycle_Rapid:= pstStGrpParam_Save^.rVel_RapidAdj*i_iCycleTime_Motion*1000.0/60.0;(*快速调整|*)
		(*2025.5.16.111107+不常量的调整当量*)
		lrAdjustVal_CurCycle_Compensate:=lrVel_CompensateAdjust*i_iCycleTime_Motion*1000.0/60.0;

		(*纵向阶跃测试|*)
		FOR iN:=1 TO i_iGrpAxisNum_Pu BY 1 DO
			iUnitId:= i_abyGrpAxisList[iN];
			pstStUnitParam_Save:= ADR(i_pstStSysParam^.astStUnitParam_Save[iUnitId]);
			pstStUnitParam_UnSave:= ADR(i_pstStSysParam^.astStUnitParam_UnSave[iUnitId]);

			pstStUnitParam_UnSave^.iAdjValue_V:=0;(*2023.08.16.084238*)
			IF (byStepTestIndex=3 OR byStepTestIndex=6) AND i_iAxisId_StepTest_V=iUnitId THEN
				(*2023.09.07.093705 取消传递*)
				IF byStepTestIndex=3 THEN
					IF xCompensate_DeCouple THEN(*过解耦*)
						pstStUnitParam_UnSave^.alrTotalAdjustVal_Auto_vh[1]:=pstStUnitParam_UnSave^.alrTotalAdjustVal_Auto_vh[1]+
								i_iMicron_StepTest1_V;
					ELSE(*不过解耦*)
						pstStUnitParam_UnSave^.alrTotalAdjustVal_Compensate_vh[1]:=pstStUnitParam_UnSave^.alrTotalAdjustVal_Compensate_vh[1]+
								i_iMicron_StepTest1_V;
					END_IF
				ELSE
					IF xCompensate_DeCouple THEN(*过解耦*)
						pstStUnitParam_UnSave^.alrTotalAdjustVal_Auto_vh[1]:=pstStUnitParam_UnSave^.alrTotalAdjustVal_Auto_vh[1]+
								i_iMicron_StepTest2_V;
					ELSE(*不过解耦*)
						pstStUnitParam_UnSave^.alrTotalAdjustVal_Compensate_vh[1]:=pstStUnitParam_UnSave^.alrTotalAdjustVal_Compensate_vh[1]+
								i_iMicron_StepTest2_V;
					END_IF
				END_IF
				EXIT;
			END_IF
		END_FOR

		(*--------------------------------------------------|2019.11.18.145727_*)
		(*提取纵向快速对版调整量|*)
		FOR iN:=1 TO i_iGrpAxisNum_Pu BY 1 DO
			iUnitId:= i_abyGrpAxisList[iN];
			pstStUnitParam_Save:= ADR(i_pstStSysParam^.astStUnitParam_Save[iUnitId]);
			pstStUnitParam_UnSave:= ADR(i_pstStSysParam^.astStUnitParam_UnSave[iUnitId]);
			
			iRtn:= KS_FetchRapidAdjValue_V(i_pastStAxisRapidAdjProf_V, iUnitId, ADR(diRapidAdjustment));(*更换接口|2019.11.18.145634_*)
			IF iRtn=0 THEN
				pstStUnitParam_UnSave^.alrTotalAdjustVal_Rapid_vh[1]:= pstStUnitParam_UnSave^.alrTotalAdjustVal_Rapid_vh[1]+diRapidAdjustment;
				pstStUnitParam_UnSave^.byRapidAdjustStep:= 1;
			END_IF
		END_FOR

		(*2018.8.20.093027\
		/*重整理注释: 根据上周期的调整情况先处理各类型调整量库存信息|
		*)
		FOR iN:=1 TO i_iGrpAxisNum_Pu BY 1 DO
			iUnitId:= i_abyGrpAxisList[iN];
			pstStUnitParam_Save:= ADR(i_pstStSysParam^.astStUnitParam_Save[iUnitId]);
			pstStUnitParam_UnSave:= ADR(i_pstStSysParam^.astStUnitParam_UnSave[iUnitId]);
(*
(*2025.8.19.202402套色调整量不再按周期处理----------先屏蔽这些*)
			(*套色调整量|*)
			IF pstStAxisParam^.axCurCycleAdjustVal_Auto_done_vh[1] THEN(*上次调整周期如果自动调整量被消耗掉\就要从库存中减掉|*)
				pstStAxisParam^.axCurCycleAdjustVal_Auto_done_vh[1]:= FALSE;
				pstStAxisParam^.alrTotalAdjustVal_Auto_vh[1]:= pstStAxisParam^.alrTotalAdjustVal_Auto_vh[1]-pstStAxisParam^.alrCurCycleAdjustVal_Auto_vh[1];

				pstStAxisParam^.alrCurCycleAdjustVal_Auto_vh[1]:= 0;(*本周期的自动调整量置于预填充状态|*)
			END_IF


			(*快速调版量|*)
		 	IF pstStAxisParam^.axCurCycleAdjustVal_Rapid_done_vh[1] THEN(*上次调整周期如果快速调整量被消耗掉\就要从库存中减掉|*)
				pstStAxisParam^.axCurCycleAdjustVal_Rapid_done_vh[1]:= FALSE;
				pstStAxisParam^.alrTotalAdjustVal_Rapid_vh[1]:= pstStAxisParam^.alrTotalAdjustVal_Rapid_vh[1]-pstStAxisParam^.alrCurCycleAdjustVal_Rapid_vh[1];
				IF (NOT (pstStAxisParam^.alrTotalAdjustVal_Rapid_vh[1]<>0)) AND pstStAxisParam^.byRapidAdjustStep<>0 THEN
					pstStAxisParam^.byRapidAdjustStep:= 0;(*快速对版完|*)(*放在其他地方处理了2025.8.19.202545*)
				END_IF
				pstStAxisParam^.alrCurCycleAdjustVal_Rapid_vh[1]:= 0;(*本周期的快速调版量置于预填充状态|*)
			END_IF

			(*手动粗调量|*)
			IF pstStAxisParam^.axCurCycleAdjustVal_ManuCoarse_done_vh[1] THEN(*上次调整周期如果手动粗调量被消耗掉\就要从库存中减掉|*)
				pstStAxisParam^.axCurCycleAdjustVal_ManuCoarse_done_vh[1]:= FALSE;
				pstStAxisParam^.alrTotalAdjustVal_ManuCoarse_vh[1]:= pstStAxisParam^.alrTotalAdjustVal_ManuCoarse_vh[1]-pstStAxisParam^.alrCurCycleAdjustVal_ManuCoarse_vh[1];
				pstStAxisParam^.alrCurCycleAdjustVal_ManuCoarse_vh[1]:= 0;
			END_IF

			(*手动细调量|*)
			IF pstStAxisParam^.axCurCycleAdjustVal_ManuFine_done_vh[1] THEN(*上次调整周期如果手动细调量被消耗掉\就要从库存中减掉|*)
				pstStAxisParam^.axCurCycleAdjustVal_ManuFine_done_vh[1]:= FALSE;
				pstStAxisParam^.alrTotalAdjustVal_ManuFine_vh[1]:= pstStAxisParam^.alrTotalAdjustVal_ManuFine_vh[1]-pstStAxisParam^.alrCurCycleAdjustVal_ManuFine_vh[1];
				pstStAxisParam^.alrCurCycleAdjustVal_ManuFine_vh[1]:= 0;
			END_IF

			(*耦合量|*)
			IF pstStAxisParam^.axCurCycleAdjustVal_Coupling_done_vh[1] THEN(*上次调整周期如果耦合量被消耗掉\就要从库存中减掉|*)
				pstStAxisParam^.axCurCycleAdjustVal_Coupling_done_vh[1]:= FALSE;
				pstStAxisParam^.alrTotalAdjustVal_Coupling_vh[1]:= pstStAxisParam^.alrTotalAdjustVal_Coupling_vh[1]-pstStAxisParam^.alrCurCycleAdjustVal_Coupling_vh[1];
				pstStAxisParam^.alrCurCycleAdjustVal_Coupling_vh[1]:= 0;
			END_IF

			(*补偿量|*)
			IF pstStAxisParam^.axCurCycleAdjustVal_Compensate_done_vh[1] THEN(*上次调整周期如果补偿量被消耗掉\就要从库存中减掉|*)
				pstStAxisParam^.axCurCycleAdjustVal_Compensate_done_vh[1]:= FALSE;
				pstStAxisParam^.alrTotalAdjustVal_Compensate_vh[1]:= pstStAxisParam^.alrTotalAdjustVal_Compensate_vh[1]-pstStAxisParam^.alrCurCycleAdjustVal_Compensate_vh[1];
				pstStAxisParam^.alrCurCycleAdjustVal_Compensate_vh[1]:= 0;
			END_IF
*)
			(*2023.6.1.135919 等料长纵横向分开处理*)
(*			IF pstStAxisParam^.wStatusRef.8 THEN(*纵向跟踪任意色开关打开了@等待第一色料长*)*)
			(*2023.09.14.102936 .8只作为开关使用，使用.12作为实际使用那种色标计算误差标志*)
			IF pstStUnitParam_Save^.dwFlag_sts.10 THEN(*纵向跟踪第一色色标计算误差*)
				xWaitFilmLenth_V:=pstStUnitParam_Save^.xWaitFilmLenth_Follow1U;
			ELSE(*跟踪前一色色标计算误差*)
				xWaitFilmLenth_V:=pstStUnitParam_Save^.xWaitFilmLength;(*和以前一样*)
			END_IF
			(*横向先不用处理*)
			IF pstStUnitParam_Save^.dwFlag_sts.9 THEN(*横向跟踪任意色开关打开了@等待第一色料长*)
				xWaitFilmLenth_H:=pstStUnitParam_Save^.xWaitFilmLenth_Follow1U;
			ELSE(*跟踪前一色@*)
				xWaitFilmLenth_H:=pstStUnitParam_Save^.xWaitFilmLength;(*和以前一样*)
			END_IF



			(*2018.8.20.094232\检查一下有没有继续补充的套色调整量|*)
			(*套色调整量|*)
			iRtn:= KS_FetchRegAdjValue(i_pastStRegAdjMana, iUnitId, ADR(iTempAdjVal_V), ADR(iTempAdjVal_H));

			IF iRtn=0 THEN(*操作没有错误|*)
(*2025.3.21.000948  屏蔽*)
(*
				(*2023.6.1.143320|*)
				IF xWaitFilmLenth_V THEN
					iTempAdjVal_V:= 0;
				END_IF
*)
				(*2023.6.1.143320|*)
				IF xWaitFilmLenth_H THEN
					iTempAdjVal_H:= 0;
				END_IF

				IF (NOT pstStUnitParam_Save^.xLinkage) OR(*未联动|*)
					pstStUnitParam_UnSave^.byRapidAdjustStep<>0 OR(*快速对版状态|*)
(*2023.6.1.141703 等料长纵横向分开*)
(*
					pstStAxisParam^.xWaitFilmLength OR(*等料长*)
*)				
(*让料头的时候不输出调整量了,这里再限制会影响解耦的输出@2024.7.31.102542*)
(*					pstStAxisParam^.xSkipHeader OR(*让料头|*)*)
					(pstStGrpParam_UnSave^.xFlag_Ink AND NOT pstStGrpParam_UnSave^.xEnaTestARC_Ink)OR(*2020.7.31.144451 空转时不是套色测试时不进行自动套色*)
					i_xAutoAdjustbyRapidAdjust THEN(*2023.6.2.145405 全自动套印不允许自动调整量*)

					(*以上的情况都放弃调整|*)
					iTempAdjVal_V:= 0;
					iTempAdjVal_H:= 0;
				ELSE
(*

					pstStAxisParam^.alrTotalAdjustVal_Auto_vh[1]:= pstStAxisParam^.alrTotalAdjustVal_Auto_vh[1] + iTempAdjVal_V;(*纵向|*)
*)
					IF byStepTestIndex<>0 THEN(*有阶跃@用累计*)
						pstStUnitParam_UnSave^.alrTotalAdjustVal_Auto_vh[1]:= pstStUnitParam_UnSave^.alrTotalAdjustVal_Auto_vh[1] + iTempAdjVal_V;(*纵向|*)
					ELSE
						pstStUnitParam_UnSave^.alrTotalAdjustVal_Auto_vh[1]:= iTempAdjVal_V;(*纵向|*)
					END_IF
(*					pstStAxisParam^.alrTotalAdjustVal_Auto_vh[2]:= pstStAxisParam^.alrTotalAdjustVal_Auto_vh[2] + iTempAdjVal_H;(*横向|*)*)
					pstStUnitParam_UnSave^.alrTotalAdjustVal_Auto_vh[2]:= iTempAdjVal_H;(*横向|*)
				END_IF

				(*前面有可能会有阶跃的@没有的话初值就是0*)
				pstStUnitParam_UnSave^.iAdjValue_V:=pstStUnitParam_UnSave^.iAdjValue_V+iTempAdjVal_V;(*2023.08.16.091706*)
			END_IF


(*2025.5.16.004441*********************************************************************start(纵向手动)***)
			(*.21控制主站采样波形设置页面的手动纵向修版控件的显示隐藏/TRUE:显示（默认 FALSE 隐藏）*)
(***2025.8.19.204844先不要这段
			IF i_pstStShmGlobalParam^.stStSystemExtInfo.dwControlComplexBits.21 THEN
				(*2025.5.16.000126 增加纵向主界面波形选择界面纵向移动实现@使用补偿仓库*)
				IF i_pabyVerManuTrigButton^[iAxisId]=1 THEN(*纵向向上(波形向右)*)
					pstStAxisParam^.alrTotalAdjustVal_Compensate_vh[1]:=
								pstStAxisParam^.alrTotalAdjustVal_Compensate_vh[1] + iManuAdjust_V*1000;
				ELSIF i_pabyVerManuTrigButton^[iAxisId]=2 THEN(*纵向向下(波形向右)*)
					pstStAxisParam^.alrTotalAdjustVal_Compensate_vh[1]:=
								pstStAxisParam^.alrTotalAdjustVal_Compensate_vh[1] - iManuAdjust_V*1000;
				END_IF
				i_pabyVerManuTrigButton^[iAxisId]:=0;
				(*显示出来@mm*)
				pstStAxisParam^.iManualPlateAdjustment_disp:=LREAL_TO_INT(pstStAxisParam^.alrTotalAdjustVal_Compensate_vh[1]/1000);
			ELSE
				pstStAxisParam^.iManualPlateAdjustment_disp:=0;
				i_pabyVerManuTrigButton^[iAxisId]:=0;
			END_IF
*)			
(*2025.5.16.004441*********************************************************************end(纵向手动)***)




(******************************************************START*)
			(*2024.7.30.114900@重新计算单个周期调整量@使用剩余的调整量计算*)
			IF iRtn=0 THEN(*拿到有效误差了更新调整当量*)
				IF pstStGrpParam_UnSave^.rVel_Film<>0 THEN
					rTimeCycle:=pstStUnitParam_Save^.rGirth_PrnRoller (*pstStGrpParam^.lrGirth_Pu*)/pstStGrpParam_UnSave^.rVel_Film*60;(*电机转一圈的时间*)
					IF rTimeCycle<>0 AND pstStUnitParam_UnSave^.alrTotalAdjustVal_Auto_vh[1]<>0 THEN
						arAdjustValTmp_CurCycle_Auto[iUnitId]:=
							LREAL_TO_REAL((ABS(pstStUnitParam_UnSave^.alrTotalAdjustVal_Auto_vh[1])/rTimeCycle*i_iCycleTime_Motion));(*单位周期调整的量*)

						(*因为有fifo延时以及精度的问题比计算值略快一些@保证能执行完*)
						arAdjustValTmp_CurCycle_Auto[iUnitId]:=arAdjustValTmp_CurCycle_Auto[iUnitId]*1.5;
						IF arAdjustValTmp_CurCycle_Auto[iUnitId]>=lrAdjustVal_CurCycle_Auto THEN(*不能超过界面输入的最大*)
							arAdjustValTmp_CurCycle_Auto[iUnitId]:= LREAL_TO_REAL(lrAdjustVal_CurCycle_Auto);
						END_IF
					ELSE
						arAdjustValTmp_CurCycle_Auto[iUnitId]:= LREAL_TO_REAL(lrAdjustVal_CurCycle_Auto);
					END_IF
				ELSE
					arAdjustValTmp_CurCycle_Auto[iUnitId]:= LREAL_TO_REAL(lrAdjustVal_CurCycle_Auto);
				END_IF
			ELSE
				IF arAdjustValTmp_CurCycle_Auto[iUnitId]<=0.0001 THEN
					arAdjustValTmp_CurCycle_Auto[iUnitId]:= LREAL_TO_REAL(lrAdjustVal_CurCycle_Auto);
				END_IF
			END_IF

			(*rAdjustVal_CurCycle_Auto_Max 用于自动调整的当量@2024.8.2.191432*)
			IF i_pstStSysParam^.stStSysParam_Save.byArcAdjValueDealType=1 THEN(*按照一圈调整完成的节奏*)
				rAdjustVal_CurCycle_Auto_Max:=arAdjustValTmp_CurCycle_Auto[iUnitId];
			ELSE;(*还是原来的方式*)
				rAdjustVal_CurCycle_Auto_Max:= LREAL_TO_REAL(lrAdjustVal_CurCycle_Auto);
			END_IF
(******************************************************END*)


			(*横向阶跃@2023.09.04.232008*)
			IF byStepTestIndex=10 AND i_iAxisId_StepTest_V=iUnitId THEN
				(*写入到自动调整量中去@步进电机可以直接实现|普通电机的逻辑可能需要调整下*)
				(*华丰测试机就先不修改普通电机的逻辑了*)
				pstStUnitParam_UnSave^.alrTotalAdjustVal_Auto_vh[2]:= pstStUnitParam_UnSave^.alrTotalAdjustVal_Auto_vh[2] + i_iMicron_StepTest1_V;
			END_IF

			(*手动调整|*)
			IF pstStUnitParam_Save^.xLinkage AND(*联动轴才可以调整*)
				(NOT pstStGrpParam_UnSave^.xFlag_Ink OR(*空转状态不支持手动调整|2020.7.31.144653 增加*)
				pstStGrpParam_UnSave^.xEnaTestARC_Ink) OR(*支持测试模式的手动调整*)
				NOT i_xAutoAdjustbyRapidAdjust THEN(*全自动套印不允许手动调整@2023.6.2.145455*)
				IF pstStGrpParam_Save^.xWorkMode_ManuAdj THEN(*随机器运转速度调整|*)
					IF (i_pastStIOMap_Axis_FE^[iUnitId].i_xBigAdj AND (NOT i_pastStIOMap_Axis_FE^[iUnitId].i_xLittleAdj)) OR(*粗调|*)
						((NOT i_pastStIOMap_Axis_FE^[iUnitId].i_xLittleAdj) AND (NOT i_pastStIOMap_Axis_FE^[iUnitId].i_xBigAdj)) THEN(*或未接粗细调*)
						IF i_pastStIOMap_Axis_FE^[iUnitId].o_xRel_Press(*2018.7.16.095344*)(*o_xPressRoller*) THEN(*合压状态是细调|*)
							IF i_pastStIOMap_Axis_FE^[iUnitId].i_xMove_Up AND (NOT i_pastStIOMap_Axis_FE^[iUnitId].i_xMove_Down) THEN(*上|*)
								pstStUnitParam_UnSave^.alrTotalAdjustVal_ManuFine_vh[1]:= lrAdjustVal_CurCycle_Auto;
							ELSIF i_pastStIOMap_Axis_FE^[iUnitId].i_xMove_Down AND (NOT i_pastStIOMap_Axis_FE^[iUnitId].i_xMove_Up) THEN(*下|*)
								pstStUnitParam_UnSave^.alrTotalAdjustVal_ManuFine_vh[1]:= -lrAdjustVal_CurCycle_Auto;
							END_IF
						ELSE(*离压状态是粗调|*)
							IF i_pastStIOMap_Axis_FE^[iUnitId].i_xMove_Up AND (NOT i_pastStIOMap_Axis_FE^[iUnitId].i_xMove_Down) THEN(*上|*)
								pstStUnitParam_UnSave^.alrTotalAdjustVal_ManuCoarse_vh[1]:= lrAdjustVal_CurCycle_Manu;
							ELSIF i_pastStIOMap_Axis_FE^[iUnitId].i_xMove_Down AND (NOT i_pastStIOMap_Axis_FE^[iUnitId].i_xMove_Up) THEN(*下|*)
								pstStUnitParam_UnSave^.alrTotalAdjustVal_ManuCoarse_vh[1]:= -lrAdjustVal_CurCycle_Manu;
							END_IF
						END_IF
					ELSIF (i_pastStIOMap_Axis_FE^[iUnitId].i_xLittleAdj AND (NOT i_pastStIOMap_Axis_FE^[iUnitId].i_xBigAdj)) THEN (*细调*)
						IF i_pastStIOMap_Axis_FE^[iUnitId].i_xMove_Up AND (NOT i_pastStIOMap_Axis_FE^[iUnitId].i_xMove_Down) THEN(*上|*)
							pstStUnitParam_UnSave^.alrTotalAdjustVal_ManuFine_vh[1]:= lrAdjustVal_CurCycle_Auto;
						ELSIF i_pastStIOMap_Axis_FE^[iUnitId].i_xMove_Down AND (NOT i_pastStIOMap_Axis_FE^[iUnitId].i_xMove_Up) THEN(*下|*)
							pstStUnitParam_UnSave^.alrTotalAdjustVal_ManuFine_vh[1]:= -lrAdjustVal_CurCycle_Auto;
						END_IF
					END_IF
				ELSE(*按单次固定量来调整|*)
					afbR_TRIG_UpAdj[iUnitId](CLK:= i_pastStIOMap_Axis_FE^[iUnitId].i_xMove_Up);
					afbR_TRIG_DnAdj[iUnitId](CLK:= i_pastStIOMap_Axis_FE^[iUnitId].i_xMove_Down);

					IF (i_pastStIOMap_Axis_FE^[iUnitId].i_xBigAdj AND (NOT i_pastStIOMap_Axis_FE^[iUnitId].i_xLittleAdj)) OR(*粗调|*)
						((NOT i_pastStIOMap_Axis_FE^[iUnitId].i_xLittleAdj) AND (NOT i_pastStIOMap_Axis_FE^[iUnitId].i_xBigAdj)) THEN(*或未接粗细调|*)
						IF i_pastStIOMap_Axis_FE^[iUnitId].o_xRel_Press(*2018.7.16.095305*)(*o_xPressRoller*) THEN(*合压状态都是细调|*)
							IF afbR_TRIG_UpAdj[iUnitId].Q AND (NOT afbR_TRIG_DnAdj[iUnitId].Q) THEN(*上|*)
								pstStUnitParam_UnSave^.alrTotalAdjustVal_ManuFine_vh[1]:=
									pstStUnitParam_UnSave^.alrTotalAdjustVal_ManuFine_vh[1] + pstStGrpParam_Save^.rAdjVal_PerTime_Fine*1000.0;
							ELSIF afbR_TRIG_DnAdj[iUnitId].Q AND (NOT afbR_TRIG_UpAdj[iUnitId].Q) THEN(*下|*)
								pstStUnitParam_UnSave^.alrTotalAdjustVal_ManuFine_vh[1]:=
									pstStUnitParam_UnSave^.alrTotalAdjustVal_ManuFine_vh[1] - pstStGrpParam_Save^.rAdjVal_PerTime_Fine*1000.0;
							END_IF
						ELSE(*离压状态都是粗调*)
							IF afbR_TRIG_UpAdj[iUnitId].Q AND (NOT afbR_TRIG_DnAdj[iUnitId].Q) THEN(*上|*)
								pstStUnitParam_UnSave^.alrTotalAdjustVal_ManuCoarse_vh[1]:=
									pstStUnitParam_UnSave^.alrTotalAdjustVal_ManuCoarse_vh[1] + pstStGrpParam_Save^.rAdjVal_PerTime_Coarse*1000.0;
							ELSIF afbR_TRIG_DnAdj[iUnitId].Q AND (NOT afbR_TRIG_UpAdj[iUnitId].Q) THEN(*下|*)
								pstStUnitParam_UnSave^.alrTotalAdjustVal_ManuCoarse_vh[1]:=
									pstStUnitParam_UnSave^.alrTotalAdjustVal_ManuCoarse_vh[1] - pstStGrpParam_Save^.rAdjVal_PerTime_Coarse*1000.0;
							END_IF
						END_IF
					ELSIF (i_pastStIOMap_Axis_FE^[iUnitId].i_xLittleAdj AND (NOT i_pastStIOMap_Axis_FE^[iUnitId].i_xBigAdj)) THEN(*细调|*)
						IF afbR_TRIG_UpAdj[iUnitId].Q AND (NOT afbR_TRIG_DnAdj[iUnitId].Q) THEN(*上|*)
							pstStUnitParam_UnSave^.alrTotalAdjustVal_ManuFine_vh[1]:=
								pstStUnitParam_UnSave^.alrTotalAdjustVal_ManuFine_vh[1] + pstStGrpParam_Save^.rAdjVal_PerTime_Fine*1000.0;
						ELSIF afbR_TRIG_DnAdj[iUnitId].Q AND (NOT afbR_TRIG_UpAdj[iUnitId].Q) THEN(*下|*)
							pstStUnitParam_UnSave^.alrTotalAdjustVal_ManuFine_vh[1]:=
								pstStUnitParam_UnSave^.alrTotalAdjustVal_ManuFine_vh[1] - pstStGrpParam_Save^.rAdjVal_PerTime_Fine*1000.0;
						END_IF
					END_IF
				END_IF
			END_IF

			(*2018.8.20.095404\如果调整量耦合开关处于关闭状态|
			/*那么在这里就把前色耦合的量清除掉|*)
			IF NOT pstStUnitParam_Save^.byCouplingMask.0 THEN(*2018.7.30.182637\未耦合使能|*)
				FOR iK:=1 TO 2 BY 1 DO
					pstStUnitParam_UnSave^.alrTotalAdjustVal_Coupling_vh[iK]:= 0;(*累计调整量清零|*)
				END_FOR
			END_IF


			IF pstStUnitParam_UnSave^.byRapidAdjustStep<>2 THEN(*快速对版|*)
				pstStUnitParam_UnSave^.alrCurCycleAdjustVal_Rapid_vh[1]:= 0;
			END_IF

		END_FOR
// 2025.11.16.102038 屏蔽@已经没有20ms的调整量了
// (*2024.7.24.141129----------------------------------------*)
// 		(*2024.7.24.140709 移动到此处*)
// 		fbKS_FB_GetCouplingValue_V(
// 			i_xEn:= i_xEn,
// 			i_iGrpId:= i_iGrpId,
// 			i_byCouplingType:= byCouplingType,
// 			i_iRemaindPartCouplingPos:= i_iRemaindPartCouplingPos,
// 			i_xFlag_Follow1U:= i_pstStSysParam^.stStSysParam_Save.byTypeFollow_Arc=1,(*误差传递方式跟踪第一色*)
// 			i_iGrpArcAxisNum_Pu:= i_iGrpArcAxisNum_Pu,
// 			i_abyGrpArcAxisList:= i_abyGrpArcAxisList,
// 			i_pstStSysParam:= i_pstStSysParam,
// 			i_pastStIOMap_Axis_FE:= i_pastStIOMap_Axis_FE,
// 			//i_pastStPTSts:= i_pastStPTSts,
// 			i_pstStDeCoupleCoeff:= ,
// 			i_axUseErrTransfer:= ,
// 			o_xEno=> ,
// 			o_arCouplingValue=> arCouplingValue);

//		(*耦合仓库从零开始@2024.7.24.142749*)
// 		FOR iN:=1 TO i_iGrpAxisNum_Pu BY 1 DO
// 			iUnitId:= i_abyGrpAxisList[iN];
// 			pstStUnitParam_Save:= ADR(i_pstStSysParam^.astStUnitParam_Save[iUnitId]);
// 			pstStUnitParam_UnSave:= ADR(i_pstStSysParam^.astStUnitParam_UnSave[iUnitId]);
// 			pstStUnitParam_UnSave^.alrTotalAdjustVal_Coupling_vh[1]:=0;
// 		END_FOR
// 
// 		FOR iN:=1 TO i_iGrpAxisNum_Pu BY 1 DO
// 			iUnitId:= i_abyGrpAxisList[iN];
// 			pstStUnitParam_Save:= ADR(i_pstStSysParam^.astStUnitParam_Save[iUnitId]);
// 			pstStUnitParam_UnSave:= ADR(i_pstStSysParam^.astStUnitParam_UnSave[iUnitId]);
// 
// 			(*2024.7.24.134737 移动*)
// 			IF byCouplingType=0 THEN(*原来的耦合方式@2023.3.11.103908*)
// 				IF pstStUnitParam_Save^.byCouplingMask.0 THEN(*2018.7.30.182510\调整量耦合开关|*)
// 					(*将这个周期的耦合量传递给后续的所有轴|*)
// 					lrAxisCouplingVal:= pstStUnitParam_UnSave^.alrTotalAdjustVal_Auto_vh[1]*pstStUnitParam_Save^.iCoefOfCoupling_V/100.0;(*当前轴要调整量的%*)
// 					FOR iK:=iN+1 TO i_iGrpAxisNum_Pu BY 1 DO
// 						iAxisId_Tmp:= i_abyGrpAxisList[iK];
// 						pstStUnitParam_Save_Tmp:= ADR(i_pstStSysParam^.astStUnitParam_Save[iAxisId_Tmp]);
// 						pstStUnitParam_UnSave_Tmp:= ADR(i_pstStSysParam^.astStUnitParam_UnSave[iAxisId_Tmp]);
// 					
// 						pstStUnitParam_UnSave_Tmp^.alrTotalAdjustVal_Coupling_vh[1]:= pstStUnitParam_UnSave_Tmp^.alrTotalAdjustVal_Coupling_vh[1]+lrAxisCouplingVal;
// 					END_FOR
// 				END_IF
// 			ELSIF  byCouplingType=11 OR(*20MS的耦合@清除当前自动调整量-全用耦合输出*)
// 					byCouplingType=12 THEN(*隔色*)
// 				(*2024.7.24.140631 移动位置*)
// 				(*将耦合量写入到仓库中@2023.08.19.105036*)
// 				lrAxisCouplingVal:= arCouplingValue[iUnitId];(*当前自动耦合量*)
// 				IF pstStUnitParam_Save^.byCouplingMask.0 THEN(*\调整量耦合开关|*)
// 					(*最终按照lrAxisCouplingVal输出|将当前自动调整量减去,在电机执行会自动加进去的*)
// 					pstStUnitParam_UnSave^.alrTotalAdjustVal_Coupling_vh[1]:=
// 							lrAxisCouplingVal-pstStUnitParam_UnSave^.alrTotalAdjustVal_Auto_vh[1];
// (*					pstStAxisParam^.alrCurCycleAdjustVal_Auto_vh[1]:=0;*)(*如果取0则从仓库减不下去*)
// 				ELSE;(*不耦合则输出当前自动调整量*)
// 				END_IF
// 			ELSE;(*其他耦合方式*)
// 			END_IF
// 		END_FOR
(*2024.7.24.141129----------------------------------------*)



		(*2018.8.20.100608\色组的套色3色灯|*)
		(*只在印刷时候三色灯才根据印刷状态显示|
		其他时间和色组联动关联|2021.10.18.104755*)
		FOR iN:=1 TO i_iGrpAxisNum_Pu BY 1 DO
			iUnitId:= i_abyGrpAxisList[iN];(*轴id|*)
			pstStUnitParam_Save:= ADR(i_pstStSysParam^.astStUnitParam_Save[iUnitId]);
			pstStUnitParam_UnSave:= ADR(i_pstStSysParam^.astStUnitParam_UnSave[iUnitId]);
			pstStIOMap_Axis_FE:= ADR(i_pastStIOMap_Axis_FE^[iUnitId]);(*轴io地址|*)
			by3LampDisByMode:=0;(*按照模式显示@2025.2.18.161440+*)
			IF pstStGrpParam_UnSave^.xFlag_Print THEN
				IF pstStUnitParam_UnSave^.byColorIdCurrent<=1 THEN(*首色或者未联动的轴按模式显示@2025.2.18.163435*)
					by3LampDisByMode.2:=TRUE;
				ELSE	
					IF pstStUnitParam_Save^.xEnable_arc AND pstStUnitParam_Save^.dwFlag_Sts.0 THEN(*套色使能\纵向自动|*)
						IF pstStUnitParam_UnSave^.byArcSts.1 THEN(*丢失|*)
							pstStIOMap_Axis_FE^.o_xLamp_Normal:= FALSE;
							pstStIOMap_Axis_FE^.o_xLamp_Lost:= TRUE;
							pstStIOMap_Axis_FE^.o_xLamp_Warning:= FALSE;
							byArcStsTotal.1 := TRUE;(*2025.7.1.110658+*)
						ELSIF pstStUnitParam_UnSave^.byArcSts.0 THEN(*报警|*)
							pstStIOMap_Axis_FE^.o_xLamp_Normal:= FALSE;
							pstStIOMap_Axis_FE^.o_xLamp_Lost:= FALSE;
							pstStIOMap_Axis_FE^.o_xLamp_Warning:= TRUE;
							byArcStsTotal.0 := TRUE;(*2025.7.1.110658+*)
						ELSE(*正常|*)
							pstStIOMap_Axis_FE^.o_xLamp_Normal:= TRUE;
							pstStIOMap_Axis_FE^.o_xLamp_Lost:= FALSE;
							pstStIOMap_Axis_FE^.o_xLamp_Warning:= FALSE;
						END_IF
						(*有一色不正常就复位正常标志@2025.7.1.111545+*)
						IF byArcStsTotal.0 OR byArcStsTotal.1 THEN
							byArcStsTotal.2 :=FALSE;
						END_IF
					ELSE(*按照模式显示@2025.2.18.161507*)
						by3LampDisByMode.1:=TRUE;
					END_IF
				END_IF
			ELSE(*非印刷用于联动指示|2021.10.18.104750*)
				(*按照模式显示@2025.2.18.161507*)
				by3LampDisByMode.0:=TRUE;
			END_IF


			(*非印刷或者印刷未自动按照模式显示@2025.2.18.161507*)
			IF by3LampDisByMode<>0 THEN
				CASE i_byLamp_3_Mode OF
				1:(*2025.2.18.163014 不显示三色灯*)
					pstStIOMap_Axis_FE^.o_xLamp_Lost:= FALSE;
					pstStIOMap_Axis_FE^.o_xLamp_Normal:= FALSE;
					pstStIOMap_Axis_FE^.o_xLamp_Warning:= FALSE;
				2:(*欧诺专用*)
					//2026.04.03.085929 | + | 把凹印欧诺的三色灯挪过来用
					//2026.04.08.202259 取消屏蔽
					IF by3LampDisByMode.2 THEN(*首色或者未联动@按照绿灯*)
						pstStIOMap_Axis_FE^.o_xLamp_Normal:=TRUE;
						pstStIOMap_Axis_FE^.o_xLamp_Lost:= FALSE;
						pstStIOMap_Axis_FE^.o_xLamp_Warning:= FALSE;
					ELSIF by3LampDisByMode.1 THEN(*印刷非首色轴套色非自动|亮黄灯*)
						pstStIOMap_Axis_FE^.o_xLamp_Normal:=FALSE;
						pstStIOMap_Axis_FE^.o_xLamp_Lost:= TRUE;
						pstStIOMap_Axis_FE^.o_xLamp_Warning:= FALSE;
					ELSIF by3LampDisByMode.0 THEN(*非印刷即空转@显示绿灯*)
						pstStIOMap_Axis_FE^.o_xLamp_Normal:=TRUE;
						pstStIOMap_Axis_FE^.o_xLamp_Lost:= FALSE;
						pstStIOMap_Axis_FE^.o_xLamp_Warning:= FALSE;
					ELSE(*2025.7.1.112702+*)
						pstStIOMap_Axis_FE^.o_xLamp_Normal:=FALSE;
						pstStIOMap_Axis_FE^.o_xLamp_Lost:= FALSE;
						pstStIOMap_Axis_FE^.o_xLamp_Warning:= FALSE;
					END_IF
					//2026.04.08.202308 屏蔽
					(*
					IF pstStIOMap_Axis_FE^.o_xLamp_Estop THEN
						pstStIOMap_Axis_FE^.o_xLamp_Warning:=TRUE;
					ELSE
						(*三色灯输入切换@2023.07.07.155723*)
						IF i_byLinkage_Lamp_3_Color=1 THEN(*lost灯*)
							pstStIOMap_Axis_FE^.o_xLamp_Lost:=TRUE;
						ELSIF i_byLinkage_Lamp_3_Color=2 THEN(*warning灯*)
							pstStIOMap_Axis_FE^.o_xLamp_Warning:=TRUE;
						ELSE(*默认是normal灯*)
							pstStIOMap_Axis_FE^.o_xLamp_Normal:=TRUE;
						END_IF
					END_IF
					*)
				ELSE(*默认当作联动指示*)
					(*三色灯输入切换@2023.07.07.155723*)
					IF i_byLinkage_Lamp_3_Color=1 THEN(*lost灯*)
						pstStIOMap_Axis_FE^.o_xLamp_Lost:=pstStUnitParam_Save^.xLinkage;
						pstStIOMap_Axis_FE^.o_xLamp_Normal:= FALSE;
						pstStIOMap_Axis_FE^.o_xLamp_Warning:= FALSE;
					ELSIF i_byLinkage_Lamp_3_Color=2 THEN(*warning灯*)
						pstStIOMap_Axis_FE^.o_xLamp_Warning:=pstStUnitParam_Save^.xLinkage;
						pstStIOMap_Axis_FE^.o_xLamp_Lost:= FALSE;
						pstStIOMap_Axis_FE^.o_xLamp_Normal:= FALSE;
					ELSE(*默认是normal灯*)
						pstStIOMap_Axis_FE^.o_xLamp_Normal:=pstStUnitParam_Save^.xLinkage;
						pstStIOMap_Axis_FE^.o_xLamp_Lost:= FALSE;
						pstStIOMap_Axis_FE^.o_xLamp_Warning:= FALSE;
					END_IF
				END_CASE
			END_IF
		END_FOR
	ELSE
		o_iErNo:= -1;
	END_IF
ELSE
	IF (i_iGrpAxisNum_Pu>=1 AND i_iGrpAxisNum_Pu<=MAX_UNIT_NUM) AND
		(i_iGrpAxisTotalNum>=i_iGrpAxisNum_Pu AND i_iGrpAxisTotalNum<=MAX_UNIT_NUM) AND
		i_pstStSysParam<>0 AND
		i_pastStIOMap_Axis_FE<>0 THEN

		FOR iN:=1 TO i_iGrpAxisNum_Pu BY 1 DO
			iUnitId:= i_abyGrpAxisList[iN];
			pstStUnitParam_Save:= ADR(i_pstStSysParam^.astStUnitParam_Save[iUnitId]);
			pstStUnitParam_UnSave:= ADR(i_pstStSysParam^.astStUnitParam_UnSave[iUnitId]);
//2026.5.18.213142增加清理调整量队列
KS_ClearRapidAdjValue_V(i_pastStAxisRapidAdjProf_V,iUnitId);
KS_ClearRegAdjValue(i_pastStRegAdjMana,iUnitId);

			(*清除当前轴的让料头标志|*)
			dwN:= NOT (SHL(DWORD#1, iUnitId-1));
			i_pstStSysParam^.stStSysParam_UnSave.dwAxis_SkipTheHeader:= i_pstStSysParam^.stStSysParam_UnSave.dwAxis_SkipTheHeader AND dwN;

			pstStUnitParam_UnSave^.byRapidAdjustStep:= 0;(*快速对版状态清除|*)
			pstStUnitParam_UnSave^.iAdjValue_V:=0;(*2023.08.19.134807*)
			(*2025.5.16.003952+*)
			i_pabyVerManuTrigButton^[iUnitId]:=0;
			pstStUnitParam_UnSave^.iManualPlateAdjustment_disp:=0;

			FOR iK:=1 TO 2 BY 1 DO
				(*调整标志复位*)

				(*当前调整量清零|*)
				(*以下判断清除的只有纵向调整量|*)
				IF iK<>2 THEN(*2018.10.7.100058\横向不清除|*)

					(*2019.3.30.171407|niu.j|由于影响了预套准|暂时从if外部移动进来||*)
					(*>>begin_mark|*)
					pstStUnitParam_UnSave^.alrTotalAdjustVal_Auto_vh[iK]:= 0;
					(*<<end_mark||*)

					(*累计调整量清零*)
					pstStUnitParam_UnSave^.alrTotalAdjustVal_Rapid_vh[iK]:= 0;
					pstStUnitParam_UnSave^.alrTotalAdjustVal_ManuCoarse_vh[iK]:= 0;
					pstStUnitParam_UnSave^.alrTotalAdjustVal_ManuFine_vh[iK]:= 0;
					pstStUnitParam_UnSave^.alrTotalAdjustVal_Coupling_vh[iK]:= 0;
					pstStUnitParam_UnSave^.alrTotalAdjustVal_Compensate_vh[iK]:= 0;

				END_IF
			END_FOR

			(*套色3色灯*)
			(*2021.10.18.104309 非印刷模式正常指示灯用于联动指示*)
			(*2022.4.9.152703 北人机三色灯只再印刷时候有效三色灯*)
			i_pastStIOMap_Axis_FE^[iUnitId].o_xLamp_Normal:= FALSE;
			i_pastStIOMap_Axis_FE^[iUnitId].o_xLamp_Warning:= FALSE;
			i_pastStIOMap_Axis_FE^[iUnitId].o_xLamp_Lost:= FALSE;
			CASE i_byLamp_3_Mode OF
			1:(*不亮灯*);
			2:(*欧诺的*)
				IF i_pastStIOMap_Axis_FE^[iUnitId].o_xLamp_Estop THEN
					i_pastStIOMap_Axis_FE^[iUnitId].o_xLamp_Warning:=TRUE;
				ELSE
					(*三色灯输入切换@2023.07.07.155723*)
					IF i_byLinkage_Lamp_3_Color=1 THEN(*lost灯*)
						i_pastStIOMap_Axis_FE^[iUnitId].o_xLamp_Lost:=TRUE;
					ELSIF i_byLinkage_Lamp_3_Color=2 THEN(*warning灯*)
						i_pastStIOMap_Axis_FE^[iUnitId].o_xLamp_Warning:=TRUE;
					ELSE(*默认是normal灯*)
						i_pastStIOMap_Axis_FE^[iUnitId].o_xLamp_Normal:=TRUE;
					END_IF
				END_IF
			ELSE(*默认当联动使用|红灯当急停使用*)
				IF i_pastStIOMap_Axis_FE^[iUnitId].o_xLamp_Estop THEN
					i_pastStIOMap_Axis_FE^[iUnitId].o_xLamp_Warning:=TRUE;
				ELSIF pstStUnitParam_Save^.xLinkage THEN
					(*三色灯输入切换@2023.07.07.155723*)
					IF i_byLinkage_Lamp_3_Color=1 THEN(*lost灯*)
						i_pastStIOMap_Axis_FE^[iUnitId].o_xLamp_Lost:=TRUE;
					ELSIF i_byLinkage_Lamp_3_Color=2 THEN(*warning灯*)
						i_pastStIOMap_Axis_FE^[iUnitId].o_xLamp_Warning:=TRUE;
					ELSE(*默认是normal灯*)
						i_pastStIOMap_Axis_FE^[iUnitId].o_xLamp_Normal:=TRUE;
					END_IF
				END_IF
			END_CASE
		END_FOR
// 2025.11.16.102310 屏蔽 没有20ms的调整量用于运算了
// 		fbKS_FB_GetCouplingValue_V(
// 			i_xEn:= FALSE,
// 			i_iGrpId:= i_iGrpId,
// 			i_byCouplingType:= byCouplingType,
// 			i_iRemaindPartCouplingPos:= i_iRemaindPartCouplingPos,
// 			i_xFlag_Follow1U:= i_pstStSysParam^.stStSysParam_Save.byTypeFollow_Arc=1,(*误差传递方式跟踪第一色*)
// 			i_iGrpArcAxisNum_Pu:= i_iGrpArcAxisNum_Pu,
// 			i_abyGrpArcAxisList:= i_abyGrpArcAxisList,
// 			i_pstStSysParam:= i_pstStSysParam,
// 			i_pastStIOMap_Axis_FE:= i_pastStIOMap_Axis_FE,
// 			//i_pastStPTSts:= i_pastStPTSts,
// 			i_pstStDeCoupleCoeff:= ,
// 			i_axUseErrTransfer:= ,
// 			o_xEno=> ,
// 			o_arCouplingValue=> arCouplingValue);

	END_IF
	o_xEno:= FALSE;
END_IF

(*牵引的三色灯先不管了2025.8.19.213612*)
(*
(*牵引轴的三色灯处理@2025.7.1.114128+*)
FOR iN:=i_iGrpAxisNum_Pu+1 TO i_iGrpAxisTotalNum  BY 1 DO
	iAxisId:= i_aiGrpAxisList[iN];
	pstStAxisParam:= ADR(i_pstStShmGlobalParam^.astStAxisParam[iAxisId]);
	pstStIOMap_AxisBasic:= ADR(i_pastStIOMap_AxisBasic^[iAxisId]);(*轴io地址|*)
	IF xFlag_Estop THEN(*急停了就按照红灯显示*)
		byArcStsTotal := 0 ;
		byArcStsTotal.0 := TRUE;
	END_IF
	IF byArcStsTotal.0 THEN(*报警至少一色*)
		pstStIOMap_AxisBasic^.o_xLamp_Normal:= FALSE;
		pstStIOMap_AxisBasic^.o_xLamp_Lost:= FALSE;
		pstStIOMap_AxisBasic^.o_xLamp_Warning:= TRUE;
	ELSIF byArcStsTotal.1 THEN(*丢失至少一色*)
		pstStIOMap_AxisBasic^.o_xLamp_Normal:= FALSE;
		pstStIOMap_AxisBasic^.o_xLamp_Lost:= TRUE;
		pstStIOMap_AxisBasic^.o_xLamp_Warning:= FALSE;
	ELSIF byArcStsTotal.2 THEN(*都正常*)
		pstStIOMap_AxisBasic^.o_xLamp_Normal:= TRUE;
		pstStIOMap_AxisBasic^.o_xLamp_Lost:= FALSE;
		pstStIOMap_AxisBasic^.o_xLamp_Warning:= FALSE;
	ELSE
		pstStIOMap_AxisBasic^.o_xLamp_Normal:= FALSE;
		pstStIOMap_AxisBasic^.o_xLamp_Lost:= FALSE;
		pstStIOMap_AxisBasic^.o_xLamp_Warning:= FALSE;
	END_IF
END_FOR
*)