(*@CES
Name=PRG_OTHER
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=e1db0700-f403-46d4-96bb-1521e027fd26
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
PROGRAM PRG_OTHER
VAR
	iRtn : INT;
	iGrp : INT;
	iK : INT;
	iN : INT;
	iAxisId:INT;
	byColorId:BYTE;
	abyColorId_Bak:ARRAY [1..MAX_UNIT_NUM] OF BYTE;(*色序id备份值@2024.02.27.151112*)
	axInitValue_ClorId_Bak:ARRAY [1..2] OF BOOL;(*初始化色组id备份值@2024.02.27.151956*)
	abyGrpAxisNum_Pu: ARRAY [1..2] OF BYTE;
	
	pstStUnitParam_Save : POINTER TO StUnitParam_Save;
	pstStUnitParam_UnSave : POINTER TO StUnitParam_UnSave;
	
	pstStGrpParam_Save : POINTER TO StGrpParam_Save;
	pstStGrpParam_UnSave : POINTER TO StGrpParam_UnSave;
	
	abyNeedFollow_1U: ARRAY [1..2] OF BYTE;(*.0 纵向打开双波门
						    .1 横向打开双波门*)
	(*按系分*)
	axInitValue_FlagFollow_Bak: ARRAY [1..2] OF BOOL;(*初始化跟踪方式备份值@2024.02.27.151956*)
	abyLastNeedFollow_1U: ARRAY [1..2] OF BYTE;(*.0 纵向打开双波门
											 .1 横向打开双波门*)
	axInitValue_HorOpen_Bak: ARRAY [1..2] OF BOOL;(*横向打开备份值初始化@2024.02.27.154613*)
	axHorOpen_Bak:ARRAY [1..MAX_UNIT_NUM] OF BOOL;(*横向开关备份变量@2024.02.27.154642*)
	pbyTmp: POINTER TO BYTE;
	
	axAtLeastOneUnitOpenHor: ARRAY [1..2] OF BOOL;(*至少一色打开横向了*)
	
	(*2024.02.21.125231 优化跟踪第一色实现为任意色*)
	byFollowArcId: BYTE;
	
	(*2023.12.05.135403 跟踪第一色标志处理需要变量*)
	aiArcErr: ARRAY [1..16] OF INT;
	abyCycleCnt: ARRAY [1..16] OF BYTE;
	axArcReachRangeFlag: ARRAY [1..16] OF BOOL;
	axArcFollow1UFlag_WaitFilmLenth:  ARRAY [1..16] OF BOOL;(*等料长置位的跟一色标志*)
	axArcFollow1UFlag_ErrReachRange:  ARRAY [1..16] OF BOOL;(*误差到达一定范围以后才输出的置位标志*)
	
//	fbGT_GetSystemInfo : GT_GetSystemInfo;
	udiRemain_M : UDINT;
	iCount_1_Second : INT;
	xChangeSignal : BOOL;
	
	fbKS_FB_GetLatchValue : KS_FB_GetLatchValue;
	
	//2025.11.16.090955 | 获取CPU以及内存信息
	test_info:SystemInfo;
    plc_info:POINTER TO TSysInfo;
	
	uliRemain_M : ULINT;
	sPath : STRING;
	iCount_GetPlcInfo : INT;	
//	iCount_GetPlcInfo : INT;
	iCount_DeleteDir : INT;
	byArcIntensity_Pre: BYTE;
	xChange_ArcIntensity: BOOL;	
END_VAR

{IMPLEMENTATION}
IF g_iRunStepId=RUNSTEP_NormalWork THEN
	;
ELSE
	RETURN;
END_IF
g_stStSysParam.stStSysParam_Save.byTypeFollow1UEn:=1;

FOR iN:=1 TO MAX_UNIT_NUM BY 1 DO 
	IF g_stStSysParam.astStUnitParam_Save[iN].rGirth_Sam <> 0 THEN
		g_stStSysParam.astStUnitParam_Save[iN].iGateWidthRoundPoints:= 
				REAL_TO_INT(20.0/g_stStSysParam.astStUnitParam_Save[iN].rGirth_Sam*4000.0);
	ELSE
		g_stStSysParam.astStUnitParam_Save[iN].rGirth_Sam := g_stStSysParam.astStUnitParam_Save[iN].rGirth_PrnRoller;
	END_IF
END_FOR

(*2023.09.10.122156 优化*)
(*2024.02.21.125747 优化为跟踪任意色而不是单单跟踪第一色@变量名有点混淆.eg xFlag_Follow_1U_V 现在的意义是跟踪任意色*)
FOR iGrp:=1 TO 2 BY 1 DO
	pstStGrpParam_Save:=ADR(g_stStSysParam.astStGrpParam_Save[iGrp]);
	pstStGrpParam_UnSave:=ADR(g_stStSysParam.astStGrpParam_UnSave[iGrp]);
	abyGrpAxisNum_Pu[iGrp]:=pstStGrpParam_UnSave^.byGrpAxisNum_Pu;(*2023.09.21.135454 缺失了一段代码*)
	(*2023.11.27.102831 xFlag_Follow_1U_V的内存区域和之前使用的有点冲突，
	会引起xFlag_Follow_1U_V高位字节非零在这里强制清零处理只保留最低位*)
	pbyTmp:=ADR(pstStGrpParam_Save^.xFlag_Follow_1U_V);
	IF pbyTmp^>1 THEN(*非0 非1*)
		pbyTmp^:=pbyTmp^ AND 16#01;(*保留最低位*)
	END_IF
	(*检查至少一色横向打开了*)
	axAtLeastOneUnitOpenHor[iGrp]:=FALSE;
	FOR iK:=1 TO abyGrpAxisNum_Pu[iGrp] BY 1 DO
		iAxisId:=pstStGrpParam_UnSave^.abyGrpAxisList[iK];
		IF iAxisId>0 AND iAxisId<=MAX_UNIT_NUM THEN
			pstStUnitParam_Save:=ADR(g_stStSysParam.astStUnitParam_Save[iAxisId]);(*取轴参数*)
			pstStUnitParam_UnSave:=ADR(g_stStSysParam.astStUnitParam_UnSave[iAxisId]);(*取轴参数*)
			byColorId:=pstStUnitParam_UnSave^.byColorIdCurrent;(*取色序id*)
			IF byColorId>1 THEN(*色序大于1@只检测套印轴*)
				IF pstStUnitParam_Save^.dwFlag_Ctl.0 THEN(*至少打开了一个颜色的横向*)
					axAtLeastOneUnitOpenHor[iGrp]:=TRUE;
					EXIT;
				END_IF
			END_IF
		END_IF
	END_FOR

	abyNeedFollow_1U[iGrp]:=0;
	abyNeedFollow_1U[iGrp].0:=pstStGrpParam_Save^.xFlag_Follow_1U_V;(*打开纵向跟1色开关*)
	abyNeedFollow_1U[iGrp].1:=pstStGrpParam_Save^.xFlag_Follow_1U_H (*AND xAtLeastOneUnitOpenHor*);(*至少一色横向打开并且横向跟1色*)

	IF NOT axInitValue_FlagFollow_Bak[iGrp] THEN
		abyLastNeedFollow_1U[iGrp]:= abyNeedFollow_1U[iGrp];
		axInitValue_FlagFollow_Bak[iGrp]:=TRUE;
		
	END_IF

	FOR iK:=1 TO abyGrpAxisNum_Pu[iGrp] BY 1 DO
		iAxisId:=pstStGrpParam_UnSave^.abyGrpAxisList[iK];
		IF iAxisId>0 AND iAxisId<=MAX_UNIT_NUM THEN
			pstStUnitParam_Save:=ADR(g_stStSysParam.astStUnitParam_Save[iAxisId]);(*取轴参数*)
			pstStUnitParam_UnSave:=ADR(g_stStSysParam.astStUnitParam_UnSave[iAxisId]);(*取轴参数*)
			byColorId:=pstStUnitParam_UnSave^.byColorIdCurrent;(*取色序id*)

			(*跟踪的色序id进行处理@2024.02.27.152243*)
			IF NOT axInitValue_ClorId_Bak[iGrp] THEN
				abyColorId_Bak[iAxisId]:=byColorId;
				IF iK=abyGrpAxisNum_Pu[iGrp] THEN
					axInitValue_ClorId_Bak[iGrp]:=TRUE;(*循环完成了*)
				END_IF
			END_IF

			IF NOT axInitValue_HorOpen_Bak[iGrp] THEN
				axHorOpen_Bak[iAxisId]:=pstStUnitParam_Save^.dwFlag_Ctl.0;
				IF iK= abyGrpAxisNum_Pu[iGrp] THEN
					axInitValue_HorOpen_Bak[iGrp]:=TRUE;(*循环完成了*)
				END_IF
			END_IF

			(*横向跟任意色打开了|跟踪色未分配则写成1*)
			IF (abyLastNeedFollow_1U[iGrp] <> abyNeedFollow_1U[iGrp] AND abyNeedFollow_1U[iGrp].1) OR
				(*色序id从0变未非0,并且横向跟任意色打开,初始化跟踪色序*)
				(abyColorId_Bak[iAxisId]<>byColorId AND abyColorId_Bak[iAxisId]=0 AND abyNeedFollow_1U[iGrp].1) OR
				(*横向打开的时候并且横向跟任意色打开,初始化跟踪色序*)
				(NOT axHorOpen_Bak[iAxisId] AND pstStUnitParam_Save^.dwFlag_Ctl.0 AND abyNeedFollow_1U[iGrp].1) THEN
				IF pstStUnitParam_Save^.byFollowColorId=0 AND pstStUnitParam_Save^.dwFlag_Ctl.0 THEN(*=0 以及横向打开的轴强制写1*)
					pstStUnitParam_Save^.byFollowColorId:=1;
				END_IF
			END_IF

			(*2024.02.21.130709 关闭跟踪任意一色@强制将色组修改为跟踪前一色-双眼*)
			IF (abyLastNeedFollow_1U[iGrp] <> abyNeedFollow_1U[iGrp] AND abyNeedFollow_1U[iGrp]=0) OR
				byColorId<=1 OR(*色序id*)
				(*在纵向跟任意色未打开,横向跟踪任意色打开而横向开关打开时-强制followid=0*)
				(NOT abyNeedFollow_1U[iGrp].0 AND abyNeedFollow_1U[iGrp].1 AND NOT pstStUnitParam_Save^.dwFlag_Ctl.0) THEN
				pstStUnitParam_Save^.byFollowColorId:=0;
			END_IF

			(*检查当前色序id是否非法@超过当前色序则写0*)
			IF pstStUnitParam_Save^.byFollowColorId >= byColorId THEN
				pstStUnitParam_Save^.byFollowColorId:=0;(*强制写0*)
			END_IF

			IF g_stStSysParam.stStSysParam_Save.xArcFollowAnyAxis THEN;(*跟踪任意色|则由上面逻辑调整跟踪轴id*)
			ELSE(*只能跟踪第一色*)
				pstStUnitParam_Save^.byFollowColorId:=1;(*强制跟踪第一色@如果要跟踪任意色-屏蔽这行代码@2024.02.27.160908*)
			END_IF
			(*--END*)

			byFollowArcId:=pstStUnitParam_Save^.byFollowColorId;(*取跟踪的色id*)



			IF abyNeedFollow_1U[iGrp]<>0 THEN(*需要跟踪第一色*)
				IF byColorId>1 THEN(*色序大于1*)
					(*位状态处理@2023.09.10.214936*)
					IF abyNeedFollow_1U[iGrp].0 THEN(*纵向跟踪第一色*)
						IF byFollowArcId<>0 THEN(*跟踪的色序id非0则打开*)
							pstStUnitParam_Save^.dwFlag_Sts.8:= TRUE;
						ELSE(*跟踪色序为0的时候关闭*)
							pstStUnitParam_Save^.dwFlag_Sts.8:= FALSE;
						END_IF
					ELSE
						IF abyLastNeedFollow_1U[iGrp].0 THEN(*之前跟踪第一色按钮打开过*)
							pstStUnitParam_Save^.dwFlag_Sts.8:= FALSE;
						END_IF
					END_IF
					IF abyNeedFollow_1U[iGrp].1 THEN(*横向跟踪第一色*)
						IF byFollowArcId<>0 THEN(*跟踪的色序id非0则打开*)
							pstStUnitParam_Save^.dwFlag_Sts.9:= pstStUnitParam_Save^.dwFlag_Ctl.0;(*打开横向才置位*)
						ELSE(*跟踪色序为0的时候关闭*)
							pstStUnitParam_Save^.dwFlag_Sts.9:= FALSE;
						END_IF
					ELSE
						IF abyLastNeedFollow_1U[iGrp].1 THEN(*之前跟踪第一色按钮打开过*)
							pstStUnitParam_Save^.dwFlag_Sts.9:= FALSE;
						END_IF
					END_IF

					(*计算第二个波门位置@纵横向有一个打开跟踪第一色，第二波门自动计算*)
					pstStUnitParam_Save^.iGateSaEx:=
						KS_CalcGatePos_Follow(
							byFollowArcId(*i_byUnitId_Follow*),
							byColorId(*i_byUnitId_Cur*),
							pstStUnitParam_Save^.iGateSa(*i_iGateSa*),
							pstStUnitParam_Save^.iGateWidthRoundPoints(*i_iGateWidthRondPt*)+1,(*不要挨得太近+1个点*)
							4000(*i_iGatePoint_Max*),
							(*2024.03.06.171730 将整机的标记形式修改为了轴的标记形式*)
							pstStUnitParam_Save^.iMarkArrangeMode,(*pstStGrpParam^.iMarkArrangeId*)(*i_iMarkArrangeId*)
							pstStUnitParam_Save^.rGirth_PrnRoller(*i_rGirth*));
				ELSE(*色序为1就取消吧*)
					pstStUnitParam_Save^.dwFlag_Sts.8:= FALSE;
					pstStUnitParam_Save^.dwFlag_Sts.9:= FALSE;
					pstStUnitParam_Save^.iGateSaEx:=0;
				END_IF
			ELSE(*不需要跟踪第一色|根据界面选择控制*)
				IF abyLastNeedFollow_1U[iGrp].0 THEN(*之前跟踪第一色按钮打开过*)
					pstStUnitParam_Save^.dwFlag_Sts.8:= FALSE;
				END_IF
				IF abyLastNeedFollow_1U[iGrp].1 THEN(*之前跟踪第一色按钮打开过*)
					pstStUnitParam_Save^.dwFlag_Sts.9:= FALSE;
				END_IF
			END_IF

			(*纵横向都没有打开全跟踪第一色开关，第二波门手动指定*)
			IF pstStUnitParam_Save^.dwFlag_Sts.8 OR(*纵向跟踪任意一色*)
				pstStUnitParam_Save^.dwFlag_Sts.9 THEN(*横向跟踪任意一色*)
				(*打开双波门开关*)
				IF pstStUnitParam_Save^.iMarkArrangeMode=MARK_ARRANGE_OMK OR(*单标记*)
					pstStUnitParam_Save^.iMarkArrangeMode=MARK_ARRANGE_HFOR OR(*横顺*)
					pstStUnitParam_Save^.iMarkArrangeMode=MARK_ARRANGE_HREV THEN(*横逆*)
					pstStUnitParam_Save^.dwFlag_Ctl.6:=FALSE;(*不能打开双波门*)
				ELSE
					pstStUnitParam_Save^.dwFlag_Ctl.6:=TRUE;(*双波门标志有效*)
				END_IF
			ELSE
				pstStUnitParam_Save^.dwFlag_Ctl.6:= FALSE;(*双波门取消使能|强制关闭吧，反正界面打开计算误差哪里也没处理*)
			END_IF


			(*2023.09.14.103752 处理纵向使用哪一个误差进行计算调整量@处理开机时候pe裁切拉伸引起的找不到第一色问题
			在开机时候先使用跟踪前一色-随后切换未跟踪第一色*)

(*2023.12.05.135650  重新实现*)
(*
			IF pstStAxisParam^.wStatusRef.8 THEN(*跟第一色打开了*)
				IF pstStAxisParam^.xWaitFilmLenth_Follow1U THEN(*第一色没来的时候|先用跟踪前一色@xWaitFilmLenth_Follow1U=true正在等一色*)
					pstStAxisParam^.wStatusRef.12:=FALSE;(*使用跟踪前一色的误差计算调整量*)
				ELSE(*xWaitFilmLenth_Follow1U等完后会变成false*)
					pstStAxisParam^.wStatusRef.12:=TRUE;(*使用跟踪第一色的误差计算调整量*)
				END_IF
			ELSE
				pstStAxisParam^.wStatusRef.12:=FALSE;(*使用跟踪前一色的误差计算调整量*)
			END_IF
*)
			(*2023.12.05.135707 使能位更换为了局部变量*)
			IF iAxisId>=1 AND iAxisId<=16 THEN(*只处理前16个轴*)
				IF pstStUnitParam_Save^.dwFlag_Sts.8 THEN(*跟第一色打开了*)
					IF pstStUnitParam_Save^.xWaitFilmLenth_Follow1U THEN(*第一色没来的时候|先用跟踪前一色@xWaitFilmLenth_Follow1U=true正在等一色*)
						axArcFollow1UFlag_WaitFilmLenth[iAxisId]:=FALSE;(*使用跟踪前一色的误差计算调整量*)
					ELSE(*xWaitFilmLenth_Follow1U等完后会变成false*)
						axArcFollow1UFlag_WaitFilmLenth[iAxisId]:=TRUE;(*使用跟踪第一色的误差计算调整量*)
					END_IF
				ELSE
					axArcFollow1UFlag_WaitFilmLenth[iAxisId]:=FALSE;(*使用跟踪前一色的误差计算调整量*)
				END_IF
			END_IF
		END_IF
		abyColorId_Bak[iAxisId]:=byColorId;(*2024.02.27.151208 +*)
		axHorOpen_Bak[iAxisId]:=pstStUnitParam_Save^.dwFlag_Ctl.0;
	END_FOR
	abyLastNeedFollow_1U[iGrp]:=abyNeedFollow_1U[iGrp];(*打开过跟一色*)


	(*按照系循环*)
	(*2023.12.05.135016 跟踪第一色标志处理@前面色组误差到达一定阈值后输出标志*)
	SysMemCpy(ADR(aiArcErr),ADR(g_aiArcErr_V),SIZEOF(aiArcErr));(*误差拷贝*)
	KS_ArcFollow1UFlag_Deal(
		pstStGrpParam_UnSave^.xFlag_Print AND(*印刷状态|速度大于10*)
		pstStGrpParam_UnSave^.rVel_Film>=10 (*AND(*印刷状态|速度大于10*)
		pstStGrpParam^.xFlag_Follow_1U_V*)(*i_xEn*),(*打开了跟踪第一色*)(*2025.1.9.150129 有效了就使能*)
		16(*i_byArcNum_Max*),
		pstStGrpParam_UnSave^.byGrpAxisNum_Pu(*i_byGrpAxisNum_Pu*),
		ADR(pstStGrpParam_UnSave^.abyGrpAxisList)(*i_pabyGrpAxisList*),
		pstStGrpParam_UnSave^.byGrpArcAxisNum(*i_byArcNum*),
		ADR(pstStGrpParam_UnSave^.abyGrpArcAxisList)(*i_pabyArcAxisList*),
		ADR(pstStGrpParam_UnSave^.abyGrpArcIdList)(*i_pabyArcIdList*),
		(*2025.1.10.122923 判断误差稳定的阈值修改到1mm*)
		100(*i_byArcErr_Threshold*),
		10(*i_byContinuousCycleCnt*),
		ADR(g_axArcErrValid)(*i_paxArcErrValid*),(*等料长完成后一圈会置位一次@只处理了前16个id索引*)
		aiArcErr(*i_aiArcErr*),
		ADR(abyCycleCnt)(*i_pabyCycleCnt*),
		ADR(axArcReachRangeFlag)(*i_paxArcReachRangeFlag*),
		ADR(axArcFollow1UFlag_ErrReachRange)(*i_paxArcFollow1UFlag*),
		ADR(pstStGrpParam_UnSave^.abyGrpFollowArcIdList)(*i_pabyFollowArcId*),
		ADR(pstStGrpParam_UnSave^.xArcErrInRange)(*i_pxArcErrInRange*));

	FOR iK:=1 TO abyGrpAxisNum_Pu[iGrp] BY 1 DO
		iAxisId:=pstStGrpParam_UnSave^.abyGrpAxisList[iK];
		IF iAxisId>0 AND iAxisId<=16 THEN(*只处理前16个轴*)
			pstStUnitParam_Save:=ADR(g_stStSysParam.astStUnitParam_Save[iAxisId]);(*取轴参数*)
			pstStUnitParam_UnSave:=ADR(g_stStSysParam.astStUnitParam_UnSave[iAxisId]);(*取轴参数*)
			(*安全起见 and pstStAxisParam^.wStatusRef.8*)
			CASE g_stStSysParam.stStSysParam_Save.byTypeFollow1UEn OF
				1:(*等料长结束了就切换*)
					pstStUnitParam_Save^.dwFlag_Sts.12:=axArcFollow1UFlag_WaitFilmLenth[iAxisId] AND pstStUnitParam_Save^.dwFlag_Sts.8;
				2:(*直接使能@2024.03.21.102817*)
					pstStUnitParam_Save^.dwFlag_Sts.12:=pstStUnitParam_Save^.dwFlag_Sts.8;
			ELSE(*等料长结束后-等待前色误差进入阈值范围内切换*)
					(*2024.9.3.092214 优化为了1色料长到了强制转换*)
(*					pstStAxisParam^.wStatusRef.12:=pstStAxisParam^.wStatusRef.8 AND
							(axArcFollow1UFlag_ErrReachRange[iAxisId] OR axArcFollow1UFlag_WaitFilmLenth[iAxisId]);*)
					pstStUnitParam_Save^.dwFlag_Sts.12:=pstStUnitParam_Save^.dwFlag_Sts.8 AND
							(axArcFollow1UFlag_ErrReachRange[iAxisId]);
			END_CASE

			IF (pstStGrpParam_UnSave^.xFlag_Ink AND pstStGrpParam_UnSave^.xEnaTestARC_Ink) THEN(*空转单眼调试*)
				pstStUnitParam_Save^.dwFlag_Sts.12:=pstStUnitParam_Save^.dwFlag_Sts.8;(*如果选择跟踪第一色，就直接赋值*)
			END_IF

			(*2024.01.02.113642 同步*)
			(*2023.12.25.212750+持续一定时间后结束*)
			IF pstStGrpParam_UnSave^.xFlag_Follow_1U_V_UwCut OR
				pstStGrpParam_UnSave^.xFlagFollow1U_AccDecing THEN(*2024.04.14.114538+*)
				pstStUnitParam_Save^.dwFlag_Sts.12:=TRUE;(*接料时候跟踪第一色计算误差*)
				IF pstStUnitParam_Save^.iMarkArrangeMode=MARK_ARRANGE_OMK OR(*单标记*)
					pstStUnitParam_Save^.iMarkArrangeMode=MARK_ARRANGE_HFOR OR(*横顺*)
					pstStUnitParam_Save^.iMarkArrangeMode=MARK_ARRANGE_HREV THEN(*横逆*);
				ELSE;
					pstStUnitParam_Save^.dwFlag_Ctl.6:=TRUE;(*打开双波门*)
				END_IF
			END_IF
		END_IF
	END_FOR

	(*2024.8.30.102618增加全控双眼/单眼跟1色开关*)
	FOR iK:=1 TO abyGrpAxisNum_Pu[iGrp] BY 1 DO
		iAxisId:=pstStGrpParam_UnSave^.abyGrpAxisList[iK];
		IF iAxisId>0 AND iAxisId<=16 THEN(*只处理前16个轴*)
			pstStUnitParam_Save:=ADR(g_stStSysParam.astStUnitParam_Save[iAxisId]);(*取轴参数*)
			pstStUnitParam_UnSave:=ADR(g_stStSysParam.astStUnitParam_UnSave[iAxisId]);(*取轴参数*)
			pstStUnitParam_Save^.dwFlag_Sts.14:= g_stStSysParam.stStSysParam_Save.xFlag_Follow_1U_Double_V;
			pstStUnitParam_Save^.dwFlag_Sts.15:= g_stStSysParam.stStSysParam_Save.xFlag_Follow_1U_Double_H;
		END_IF
	END_FOR
END_FOR

//2025.11.6.140503保存系统配置按钮|niuj
IF g_xBtn_UpdateSysCfg THEN
	g_xBtn_UpdateSysCfg:= FALSE;
	g_xInit_TrapPoint:= FALSE;
	IF g_stStSysParam.astStGrpParam_UnSave[1].xFlag_Stop OR 
		g_stStSysParam.astStGrpParam_UnSave[2].xFlag_Stop OR
		g_stStSysParam.astStGrpParam_UnSave[1].xFlag_EStop OR
		g_stStSysParam.astStGrpParam_UnSave[2].xFlag_EStop THEN
		
// 		SysMemCpy(
// 				ADR(g_stStSysParam.stStSysParam_UnSave.stStSysCfgStruct),
// 				ADR(g_stStSysCfgStruct),
// 				SIZEOF(g_stStSysCfgStruct));
		g_iRunStepId:= RUNSTEP_UpdateSysCfg;
		g_xInit_StationList := FALSE;
	END_IF
	
END_IF

//2025.11.16.090955 | 获取CPU以及内存信息
iCount_GetPlcInfo := iCount_GetPlcInfo + 1;
IF iCount_GetPlcInfo > 9 THEN
	iCount_GetPlcInfo := 0;
	test_info(PLC_SYS_INFO => plc_info);
	uliRemain_M := plc_info^.space_info[5].remain/1024/1024;
	FOR iN := 0 TO 3 BY 1 DO
		g_abyCpu_Load[iN] := REAL_TO_BYTE(plc_info^.CPU_Load[iN]);
	END_FOR
	
	IF uliRemain_M < 1000 THEN
		iCount_DeleteDir := iCount_DeleteDir + 1;
		IF iCount_DeleteDir > 19 THEN
			iCount_DeleteDir := 0;
			sPath :=  '/data/kesai/data';
			GTN_KSDirDelete(file:= ADR(sPath));
		END_IF
	ELSE
		iCount_DeleteDir := 0;
	END_IF
END_IF




iCount_1_Second := iCount_1_Second+1;
IF iCount_1_Second >= 10 THEN
	IF NOT xChangeSignal THEN
		xChangeSignal := TRUE;
		g_sHandConnectedSignal := '#';
	ELSE
		xChangeSignal := FALSE;
		g_sHandConnectedSignal := ' ';
	END_IF
END_IF

//2025.12.26.112513 | 获取锁存的内容，临时先放在这个任务当中，因为目前的MailBox获取方法耗时比较长
fbKS_FB_GetLatchValue(
	i_xEn:= FALSE, 
	i_iGrpUnitNum:= g_stStSysParam.astStGrpParam_UnSave[1].byGrpAxisNum_Pu, 
	i_pstStSysParam:= ADR(g_stStSysParam), 
	i_pastStLatch:= ADR(g_astStLatch)
	);

	

(*2026.4.25.145102处理界面调整强度切换*)
IF g_stStSysParam.stStSysParam_Save.byArcIntensity_W= 0 THEN
	g_stStSysParam.stStSysParam_Save.byArcIntensity_W:= 25;
END_IF

IF g_stStSysParam.stStSysParam_Save.byArcIntensity_M= 0 THEN
	g_stStSysParam.stStSysParam_Save.byArcIntensity_M:= 20;
END_IF

IF g_stStSysParam.stStSysParam_Save.byArcIntensity_S= 0 THEN
	g_stStSysParam.stStSysParam_Save.byArcIntensity_S:= 15;
END_IF

//新增套色强度切换逻辑2026.4.25.150042||
IF g_stStSysParam.stStSysParam_Save.byArcIntensity<>byArcIntensity_Pre THEN
	xChange_ArcIntensity:= TRUE;
END_IF
byArcIntensity_Pre:= g_stStSysParam.stStSysParam_Save.byArcIntensity;
IF xChange_ArcIntensity THEN
	xChange_ArcIntensity:= FALSE;
	FOR iN:=1 TO MAX_UNIT_NUM BY 1 DO
		IF g_stStSysParam.stStSysParam_Save.byArcIntensity=0 THEN
			g_stStSysParam.astStUnitParam_Save[iN].rMargin_Mag_Arc:= g_stStSysParam.stStSysParam_Save.byArcIntensity_W;
			g_stStSysParam.astStUnitParam_Save[iN].stStArc_Mol_Param.rMargin_Mag_Arc:= g_stStSysParam.stStSysParam_Save.byArcIntensity_W;
		ELSIF g_stStSysParam.stStSysParam_Save.byArcIntensity=1 THEN
			g_stStSysParam.astStUnitParam_Save[iN].rMargin_Mag_Arc:= g_stStSysParam.stStSysParam_Save.byArcIntensity_M;
			g_stStSysParam.astStUnitParam_Save[iN].stStArc_Mol_Param.rMargin_Mag_Arc:= g_stStSysParam.stStSysParam_Save.byArcIntensity_M;
		ELSIF g_stStSysParam.stStSysParam_Save.byArcIntensity=2 THEN
			g_stStSysParam.astStUnitParam_Save[iN].rMargin_Mag_Arc:= g_stStSysParam.stStSysParam_Save.byArcIntensity_S;
			g_stStSysParam.astStUnitParam_Save[iN].stStArc_Mol_Param.rMargin_Mag_Arc:= g_stStSysParam.stStSysParam_Save.byArcIntensity_S;
		ELSE
			g_stStSysParam.astStUnitParam_Save[iN].rMargin_Mag_Arc:= g_stStSysParam.stStSysParam_Save.byArcIntensity_M;
			g_stStSysParam.astStUnitParam_Save[iN].stStArc_Mol_Param.rMargin_Mag_Arc:= g_stStSysParam.stStSysParam_Save.byArcIntensity_M;			

		END_IF
	END_FOR
END_IF