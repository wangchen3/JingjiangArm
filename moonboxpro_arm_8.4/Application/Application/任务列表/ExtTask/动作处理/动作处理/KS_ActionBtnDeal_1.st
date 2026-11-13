(*@CES
Name=KS_ActionBtnDeal_1
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=29481889-dd1f-4142-86a2-c727a801bd3a
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_ActionBtnDeal_1 : BOOL
VAR_INPUT
	i_iGrpId								: INT;
	i_pstStEvtReq							: POINTER TO StEvtReq;(*按钮输入操作及边沿触发描述|*)
	i_pbyActionCtlWay						: POINTER TO BYTE;(*动作流程选择
													|0:预启动--空转--张力投入--印刷--空转--停机
													|1:预启动--空转--停机;预启动--张力投入--印刷(速度为0)--停机*)
	i_pxBtnInk								: POINTER TO BOOL;(*空转按钮-包含了预启动响铃状态*)
	i_pxBtnPrint							: POINTER TO BOOL;(*印刷按钮*)
	i_pxBtnTension							: POINTER TO BOOL;(*张力投入按钮*)
	i_pxBtnManuAcc							: POINTER TO BOOL;(*手动加速*)
	i_pxBtnManuDec							: POINTER TO BOOL;(*手动减速*)
	i_pxBtnAutoAccOrDec						: POINTER TO BOOL;(*自动加速减速*)
	i_pxBtnStop								: POINTER TO BOOL;(*停止按钮*)
	i_pxBtnFastStop							: POINTER TO BOOL;(*快速停止按钮|2022.4.9.235931*)
	i_pxBtnEstop							: POINTER TO BOOL;(*急停按钮*)
	i_plrVel_Tar							: POINTER TO LREAL;(*自动加减速目标速度*)

(*2019.09.10.101800|niu.j|*)
	i_xInverterAlarm						: BOOL;(*变频器报警*)
	i_xBrakeFilm							: BOOL;(*断料*)
	(*2022.4.3.165550|*)
	i_xLostPressure							: BOOL;(*气压低报警|不允许开机*)
	i_xPrnRollerLoose_AtLeast1				: BOOL;(*至少一色夹板松报警|不允许开机*)
	i_xNeedEstop_BrakeAlarm					: BOOL;(*制动电阻报警急停|2022.5.11.112758*)
	i_paxCommVel_Sure: POINTER TO ARRAY [1..2,1..3] OF BOOL;
	(*2021.8.27.164750  同步*)
	i_paxNeedRstTrig_AutoAccOrDec:POINTER TO ARRAY [1..3] OF BOOL;(*复位自动加减速按钮沿*)
	i_pxLastFlag_Stop: POINTER TO BOOL;
	i_pxLastFlag_Ink: POINTER TO BOOL;
	i_pxLastFlag_TensionUnFinished:POINTER TO BOOL;(*张力投入未完成标志*)
	i_xFalg_ExhaustEn:BOOL;(*排风启动使能标志|*)
	i_pxFastStopBtnDn:POINTER TO BOOL;(*快停被按下了*)
	i_pxTips_ExhausLimitStart: POINTER TO BOOL;
	i_pbySpecialProcess:POINTER TO BYTE;(*在基础的开机流程上增加了特殊开机方式切换标志|0:按照基础的|
																		 			  |1:北人的*)
	i_ptmHold_PreStart				: POINTER TO TIME; (* 开机预启动持续时间| 2022.5.27.143829*)
	i_tmHold_PreStart_BeiRen		: TIME := T#6s; (* 北人开机预启动持续时间|和响铃时间是分开的| 2022.5.27.143829*)
	i_tmAlarmHold_PreStart			: TIME := t#3s; (* 开机预启动报警持续时间*)
	(*2023.09.21.143646*)
	i_pbyStates						: POINTER TO BYTE;(*状态机@可以在不同厂家独立使用*)
	i_pfbTon						: POINTER TO TON;(*计时器-用于某些流程使用@2023.12.16.151632*)	
	i_iCustomerName					: INT;
	i_pxLinkage_IfOf_Ink			: POINTER TO BOOL;
	i_prVel_Tar_HMI					: POINTER TO REAL;(*设定的目标速度值*)
	i_pxTapPosition_Breaking		: POINTER TO BOOL;
	i_pxTapPosition_Printing		: POINTER TO BOOL;
	i_pxTapPosition_UniformInk		: POINTER TO BOOL;	
	i_pxAutoAccDec_Hmi				: POINTER TO BOOL;
	i_arVel_CommonlyUsed			: ARRAY [1..3] OF REAL;	
	i_xFalg_ExhaustLimitStart		: BOOL;
	i_rVel_Ink						: REAL;
	i_xFlag_Stop					: BOOL;
	i_xFlag_Estop					: BOOL;
	i_xFlag_Ink						: BOOL;
	i_xFlag_Print					: BOOL;	
	i_xFlag_InkAccing				: BOOL;
	i_xFlag_Stoping					: BOOL;
	i_xFlag_EStoping				: BOOL;
	i_xFlag_Tension					: BOOL;
	i_xFlag_TensionDone				: BOOL;
	i_xFlag_TensionUnfinished		: BOOL;	
	i_xFlag_LinkageAxisAlarm		: BOOL;
	i_rVel_Cur						: REAL;
	i_xFlag_AutoDec					: BOOL;
	i_xFlag_AutoAcc					: BOOL;	
	i_xFlag_Accing					: BOOL;
	i_xFlag_Decing					: BOOL;	
	i_xMotionEnabled				: BOOL;
END_VAR
VAR
	iCustomerName: INT;
	iN: INT;
	xInkMove: BOOL;(*空转运动*)
	xNotAllowMachineRun: BOOL;
	xTips_ExhausLimitStart: BOOL;
	xNeedEstopByPrnRollerLoose: BOOL;(*版辊松需要急停*)
	bySpecialProcess:BYTE;(*在基础的开机流程上增加了特殊开机方式切换标志|0:按照基础的|
																		|1:北人的*)
	tmHold_PreStart						: TIME := T#3s; (* 开机预启动持续时间| 2022.5.27.143829*)
	wNotAllowMachineRun:WORD;
	byStates: BYTE;	
END_VAR

{IMPLEMENTATION}
KS_ActionBtnDeal:=FALSE;
(*2023.06.24.193214*)
IF i_pbyStates<>0 THEN
	byStates:=i_pbyStates^;
END_IF
IF	i_pstStEvtReq<>0 AND
	i_pbyActionCtlWay<>0 AND
	i_pxBtnInk<>0 AND
	i_pxBtnPrint<>0 AND
	i_pxBtnTension<>0 AND
	i_pxBtnManuAcc<>0 AND
	i_pxBtnManuDec<>0 AND
	i_pxBtnAutoAccOrDec<>0 AND
	i_pxBtnStop<>0 AND
	i_pxBtnFastStop<>0 AND
	i_pxBtnEstop<>0 AND
	i_plrVel_Tar<>0 AND
	i_paxNeedRstTrig_AutoAccOrDec<>0 AND
	i_paxCommVel_Sure<>0 AND
	i_pxFastStopBtnDn<>0 THEN

	iCustomerName:=i_iCustomerName;(*用户名称*)

	(* 2022.1.11.162754增加牵引联动使能处理*)
	i_pxLinkage_IfOf_Ink^:= TRUE;
	bySpecialProcess:=0;(*默认写0*)
	tmHold_PreStart:=i_tmAlarmHold_PreStart;(*默认赋值*)


	(*2019.10.08.091031|niu.j|按钮复位*)
	i_pxBtnInk^:=FALSE;
	i_pxBtnPrint^:=FALSE;
	i_pxBtnTension^:=FALSE;
	i_pxBtnManuAcc^:=FALSE;
	i_pxBtnManuDec^:=FALSE;
	i_pxBtnAutoAccOrDec^:=FALSE;
	i_pxBtnStop^:=FALSE;
	i_pxBtnFastStop^:=FALSE;
	i_pxBtnEstop^:=FALSE;

	(*2022.4.3.165822  夹板报警|停机 并不允许开机*)
	xNotAllowMachineRun:=FALSE;
	xNeedEstopByPrnRollerLoose:=FALSE;
	wNotAllowMachineRun:= 0;
	IF i_xPrnRollerLoose_AtLeast1 OR
		i_xLostPressure OR
		(NOT i_xFalg_ExhaustEn AND i_xFalg_ExhaustLimitStart) THEN(*排风未启动，限制开机标志使能*)

		IF NOT i_xFlag_Stop AND
			NOT i_xFlag_Estop THEN

			IF i_xPrnRollerLoose_AtLeast1 (*OR(*版辊松就急停*)
				i_xLostPressure*) THEN
				xNeedEstopByPrnRollerLoose:=TRUE;
			END_IF
		ELSE
			IF i_xPrnRollerLoose_AtLeast1 OR(*版辊松*)
				(NOT i_xFalg_ExhaustEn AND i_xFalg_ExhaustLimitStart) OR(*排风限制了不能允许开机*)
				i_xLostPressure THEN(*气压低了也不允许开机@2024.8.17.134512*)
				xNotAllowMachineRun:=TRUE;
				wNotAllowMachineRun.0:= i_xPrnRollerLoose_AtLeast1;(*2022.7.26.102036*)
				wNotAllowMachineRun.1:= (NOT i_xFalg_ExhaustEn AND i_xFalg_ExhaustLimitStart) ;

			END_IF
		END_IF

	END_IF

	(*根据用户名选择开机方式|后期可根据情况将按钮也进行分类2019.9.6.100946*)
	IF i_pbyActionCtlWay<>0 THEN
		CASE iCustomerName OF(*判断用户名称使用不同的开机流程逻辑*)
(*			CUSTOMERNAME_DADONG:
					i_pbyActionCtlWay^:=0;
					(*空转按钮|沿有效*)
					i_pxBtnInk^:=i_pstStEvtReq^.xReqPrestart;
					(*印刷按钮|沿有效*)
					i_pxBtnPrint^:=i_pstStEvtReq^.xReqPrint;
					(*张力投入按钮|沿有效*)
					i_pxBtnTension^:=i_pstStEvtReq^.xReqTension;
					IF i_xFlag_Ink THEN
						(*停止按钮|沿有效*)
						i_pxBtnStop^:=i_pstStEvtReq^.xReqPrestart;
					END_IF
					IF i_xFlag_Print THEN
						(*停止按钮|沿有效*)
						i_pxBtnStop^:=i_pstStEvtReq^.xReqPrint;
					END_IF
					(*无手动加减速*)
					i_pxBtnAutoAccOrDec^:=i_pstStEvtReq^.xReqManuSpdUp OR i_pstStEvtReq^.xReqManuSpdDn;

					IF i_pstStEvtReq^.xReqManuSpdUp THEN(*自动加速了*)
						i_plrVel_Tar^:=i_prVel_Tar_HMI^;
					ELSIF i_pstStEvtReq^.xReqManuSpdDn THEN(*自动减速了|减速到10m/min*)
						i_plrVel_Tar^:= i_rVel_Ink;
					END_IF
					*)
			CUSTOMERNAME_ZHEJIANGOUNUO,(*2023.3.29.114520||增加欧诺*)
			CUSTOMERNAME_SHUNDEDELI,(*2023.10.05.151542*)
			CUSTOMERNAME_BEIREN_NOLOGO,
			CUSTOMERNAME_BEIREN:(*2022.3.24.182915  北人流程*)
					i_pbyActionCtlWay^:=0;
					bySpecialProcess:=1;
					tmHold_PreStart:=i_tmHold_PreStart_BeiRen;
					i_pxBtnFastStop^:=i_pstStEvtReq^.xReqFastStop;(*2022.4.10.000027快停*)
					(*空转按钮|沿有效*)
					(*印刷后空转按钮作为退出印刷状态的按钮*)
					IF i_xFlag_Print THEN
						i_pxBtnStop^:=i_pstStEvtReq^.xReqStop OR i_pstStEvtReq^.xReqInk;
					ELSE
						i_pxBtnStop^:=i_pstStEvtReq^.xReqStop;
						i_pxBtnInk^:=i_pstStEvtReq^.xReqPrestart;
					END_IF

					IF i_pstStEvtReq^.xEvt_FastStop THEN(*快停被按下了*)
						IF i_pxBtnInk^ AND(*开机启动的时候检查下快停按钮输出提示标志*)
							i_xFlag_Stop THEN
							i_pxFastStopBtnDn^:=TRUE;(*快停被按下了*)
							i_pxBtnInk^:=FALSE;(*快停被按下了 就不要开机了*)
						END_IF
					ELSE
						i_pxFastStopBtnDn^:=FALSE;(*快停被按下了*)
					END_IF



					(*印刷按钮|沿有效*)
					i_pxBtnPrint^:=i_pstStEvtReq^.xReqPrint;
					(*张力投入按钮|沿有效*)
					i_pxBtnTension^:=i_pstStEvtReq^.xReqTension;
					(*手动加速|按钮长有效*)
					i_pxBtnManuAcc^:=i_pstStEvtReq^.xEvt_ManuSpdUp;
					(*手动减速|按钮长有效*)
					i_pxBtnManuDec^:=i_pstStEvtReq^.xEvt_ManuSpdDn;
					(*自动加加速|*)
					i_pxBtnAutoAccOrDec^:=i_pstStEvtReq^.xReqPrestart;


					i_plrVel_Tar^:=i_prVel_Tar_HMI^;

					(*2023.09.21.143539 同步*)
					(*2023.3.6.210630 在空转状态下使用空转按键停止到空转速度@我们使用自动减速*)
					IF i_xFlag_Ink AND(*空转状态下*)
						NOT i_xFlag_InkAccing AND(*空转加速完成*)
						NOT (i_xFlag_Stoping OR
						i_xFlag_EStoping) THEN
						IF i_pstStEvtReq^.xReqInk THEN(*空转被按下了*)
							IF i_rVel_Cur>i_rVel_Ink AND
								byStates=0 THEN(*状态为初始值*)
								IF (i_xFlag_AutoAcc OR
									i_xFlag_AutoDec) THEN
									byStates:=2;(*先停止自动加减速再进行自动减速*)
								ELSE(*不在自动加减速中*)
									IF NOT (i_xFlag_Accing OR
										i_xFlag_Decing) THEN(*也不再手动加减速中*)
										byStates:=1;(*自动减速到空转速度*)
									END_IF
								END_IF
							END_IF
						END_IF
					ELSE
						byStates:=0;
					END_IF

					CASE byStates OF
						0:;(*初始值*)
						1:(*自动减速到空转速度*)
							i_pxBtnAutoAccOrDec^:=TRUE;
							i_plrVel_Tar^:=i_rVel_Ink;
							(*忘记了自动加减速按钮按下后几个周期会进入自动加减速状态
							@这里强制等待3个周期认为一定会进入自动加减速状态*)
							byStates:=100;
						2:(*停止自动加减速*)
							i_pxBtnAutoAccOrDec^:=TRUE;
							byStates:=3;(*进入等待一个周期*)
						3:(*等待停止了自动加减速*)
							IF NOT (i_xFlag_Accing OR
								i_xFlag_Decing) THEN(*已经没有加减速了*)
								byStates:=1;(*进入自动减速*)
							END_IF
						100,101:
								byStates:=byStates+1;
								IF byStates=102 THEN
									byStates:=110;(*进入等待步*)
								END_IF
						110:(*等待执行完成@按照逻辑此时应该是会进入自动加减速中*)
							IF i_xFlag_AutoAcc OR
								i_xFlag_AutoDec THEN;
							ELSE(*退出加减速状态的时候复位步*)
								byStates:=0;
							END_IF
					ELSE
						byStates:=0;
					END_CASE

			CUSTOMERNAME_CHENGBAO,
			CUSTOMERNAME_HUAFENG,
			CUSTOMERNAME_SHOUXIN,
			CUSTOMERNAME_RUNXIN,
			CUSTOMERNAME_NBXINDA,
			CUSTOMERNAME_FOSHANCHONGYUAN:
					i_pbyActionCtlWay^:=1;
					IF i_xFlag_Stop THEN
						(*记录下当前的印刷机档位|*)
						i_pxTapPosition_Breaking^:= i_pstStEvtReq^.xEvt_TapPosition_Breaking;
						i_pxTapPosition_Printing^:= i_pstStEvtReq^.xEvt_TapPosition_Printing;
						i_pxTapPosition_UniformInk^:= i_pstStEvtReq^.xEvt_TapPosition_UniformInk;
					END_IF

					IF i_pxTapPosition_Breaking^ THEN(*断料档位*)
						i_pxBtnInk^:=i_pstStEvtReq^.xReqPrestart;(*断料档位只空转*)
					ELSIF i_pxTapPosition_UniformInk^ THEN(*匀墨档位*)
						i_pxBtnInk^:=i_pstStEvtReq^.xReqPrestart;(*匀墨档位-空转+张力投入*)
						IF NOT i_xFlag_Tension THEN
							i_pxBtnTension^:=i_pstStEvtReq^.xReqPrestart;
						END_IF
						i_pxLinkage_IfOf_Ink^:= FALSE;
					ELSIF i_pxTapPosition_Printing^ THEN(*印刷档位*)
						(*印刷档位|在拉料时候有可能会存在牵引电机运动的问题；
						在这里修改启动按钮的时机为拉料完成后|2021.11.3.112006*)

						(*重新优化为先启动电机运动逻辑,再进行拉料@2023.12.16.132911*)
						i_pxBtnPrint^:=i_pstStEvtReq^.xReqPrestart;(*印刷档位-空转+张力投入+印刷0速*)
						IF i_xMotionEnabled THEN
							IF NOT i_xFlag_Tension THEN(*启动拉料*)
								i_pxBtnTension^:=TRUE;
							END_IF
						END_IF
					END_IF

					IF i_pxLastFlag_Stop<>0 THEN
						IF i_xFlag_Tension THEN
							IF (NOT i_xFlag_Estop AND
								i_xFlag_Stop AND
								NOT i_pxLastFlag_Stop^) OR (*非停止到停止*)
								(i_pstStEvtReq^.xReqStop AND
								i_xFlag_Stop) THEN(*停止状态下按下停机按键*)
								i_pxBtnTension^:=TRUE;
								i_pxBtnPrint^:=FALSE;(*和上面逻辑存在状态重叠*)
							END_IF
						END_IF
						i_pxLastFlag_Stop^:=i_xFlag_Stop;

					END_IF

					(*停止按钮|沿有效*)
					i_pxBtnStop^:=i_pstStEvtReq^.xReqStop;
					(*手动加速|按钮长有效*)
					i_pxBtnManuAcc^:=i_pstStEvtReq^.xEvt_ManuSpdUp;
					(*手动减速|按钮长有效*)
					i_pxBtnManuDec^:=i_pstStEvtReq^.xEvt_ManuSpdDn;
					(*自动加加速|*)
					i_pxBtnAutoAccOrDec^:=i_pstStEvtReq^.xReqPrestart;

					i_plrVel_Tar^:=i_prVel_Tar_HMI^;
			CUSTOMERNAME_JIANGYINHUITELI:(*处理江阴汇特力的流程@2023.12.16.133942*)
					i_pbyActionCtlWay^:=1;

					i_pxBtnInk^:=i_pstStEvtReq^.xReqPrestart;(*匀墨档位-空转+张力投入*)
					i_pxBtnPrint^:=i_pstStEvtReq^.xReqPrint;(*印刷按钮*)
					i_pxBtnTension^:=i_pstStEvtReq^.xReqTension;
					(*停止按钮|沿有效*)
					i_pxBtnStop^:=i_pstStEvtReq^.xReqStop;
					(*空转和印刷的时候自动拉张力*)
					IF i_pxLastFlag_Stop<>0 AND i_pbyStates<>0 THEN
						IF (NOT i_xFlag_Estop AND
							NOT i_xFlag_Stop AND
							i_pxLastFlag_Stop^) THEN (*停止到非停止*)
							byStates:=1;(*开机拉张力状态*)
						END_IF
						i_pxLastFlag_Stop^:=i_xFlag_Stop;

						CASE byStates OF
							1:(*开机拉张力*)
								IF NOT i_xFlag_Tension THEN						
									i_pxBtnTension^:=TRUE;(*张力投入@等使能都有效了再张力投入*)									
								ELSE
									byStates:=2;
								END_IF
							2:(*张力已经启动了*)
								IF i_xFlag_Stop OR
									i_xFlag_EStop THEN
									byStates:=3;
								END_IF
							3:(*取消张力*)
								IF i_xFlag_Tension THEN
									i_pxBtnTension^:=TRUE;
								ELSE(*已经取消了*)
									byStates:=0;
								END_IF
						ELSE
							byStates:=0;
						END_CASE

					END_IF


					(*手动加减速作为自动加减速按钮|按下长达3s就不退出自动加减速-否则退出加减速*)
					IF i_pstStEvtReq^.xEvt_ManuSpdUp AND(*自动加速*)
						i_rVel_Cur<i_prVel_Tar_HMI^ THEN
						i_pxBtnAutoAccOrDec^:=TRUE;
						i_plrVel_Tar^:=i_prVel_Tar_HMI^;
					ELSIF i_pstStEvtReq^.xEvt_ManuSpdDn AND(*自动减速*)
						i_rVel_Cur>0 THEN
						i_pxBtnAutoAccOrDec^:=TRUE;
						i_plrVel_Tar^:=0;
					ELSE
						i_pxBtnAutoAccOrDec^:=FALSE;
						i_plrVel_Tar^:=i_prVel_Tar_HMI^;
					END_IF
					(*自动加减速的时候按下加减速按钮都可以停止@2023.12.17.145038*)
					IF NOT i_pxBtnAutoAccOrDec^ THEN
						IF i_xFlag_AutoAcc OR
							i_xFlag_AutoDec THEN
							i_pxBtnAutoAccOrDec^:=i_pstStEvtReq^.xEvt_ManuSpdUp OR i_pstStEvtReq^.xEvt_ManuSpdDn;
						END_IF
					END_IF


					(*使用计时器计时加减速按钮按下时间决定加速方式@按下3s进入自动加速-否则取消自动加速*)
					IF i_pfbTon<>0 THEN
						IF i_pxBtnAutoAccOrDec^ THEN(*自动加减速按下了*)
							i_pfbTon^(IN:=TRUE,PT:=T#3S);(*启动计时器*)
						ELSE
							IF i_pfbTon^.Q THEN(*时间到了@不处理计时器*)
								IF	NOT(i_xFlag_AutoAcc OR
										i_xFlag_AutoDec) THEN(*退出了自动加减速@复位计时器*)
									i_pfbTon^(IN:=FALSE);(*复位计时器*)
								END_IF
							ELSE(*时间没到|而且按钮取消了,取消自动加减速并复位计时器*)
								IF i_xFlag_AutoAcc OR
									i_xFlag_AutoDec THEN
									IF NOT i_pfbTon^.IN THEN(*用于处理时序@在取消加减速的时候,先复位加减速按钮再置位*)
										i_pxBtnAutoAccOrDec^:=TRUE;
									END_IF
								END_IF
								i_pfbTon^(IN:=FALSE);(*复位计时器*)
							END_IF
						END_IF
					END_IF



			CUSTOMERNAME_ALTMA:
					i_pbyActionCtlWay^:=0;
					(*空转按钮|沿有效*)
					i_pxBtnInk^:=i_pstStEvtReq^.xReqPrestart;
					(*印刷按钮|沿有效*)
					i_pxBtnPrint^:=i_pstStEvtReq^.xReqPrint;
					(*张力投入按钮|沿有效*)
					i_pxBtnTension^:=i_pstStEvtReq^.xReqTension;
					(*停止按钮|沿有效*)
					i_pxBtnStop^:=i_pstStEvtReq^.xReqStop;
					(*手动加速|按钮长有效*)
					i_pxBtnManuAcc^:=i_pstStEvtReq^.xEvt_ManuSpdUp;
					(*手动减速|按钮长有效*)
					i_pxBtnManuDec^:=i_pstStEvtReq^.xEvt_ManuSpdDn;
					(*自动加加速|*)
					i_pxBtnAutoAccOrDec^:=i_pstStEvtReq^.xReqPrestart;
					IF i_xFlag_Ink THEN(*空转时候|空转按键作为自动加速按键*)
						i_pxBtnAutoAccOrDec^:=i_pstStEvtReq^.xReqInk;
					ELSIF i_xFlag_Print THEN(*印刷时候|印刷按键作为自动加速按键*)
						i_pxBtnAutoAccOrDec^:=i_pstStEvtReq^.xReqPrint;
					END_IF

					i_plrVel_Tar^:=i_prVel_Tar_HMI^;


			CUSTOMERNAME_JIANGYINLIDA:(*江阴力达流程修改|2021.12.21.140138*)
					i_pbyActionCtlWay^:=0;
					(*张力投入按钮|沿有效*)
					xInkMove:=i_xFlag_Ink AND
								i_rVel_Cur>0;

					IF i_pxLastFlag_Ink<>0 THEN
						IF  xInkMove AND NOT i_pxLastFlag_Ink^ THEN(*空转以后保证上伺服才能拉料*)
							IF  NOT i_xFlag_Tension THEN
								i_pxBtnTension^:=TRUE;
							END_IF
						END_IF
						i_pxLastFlag_Ink^:=xInkMove;
					END_IF

					IF i_pxLastFlag_Stop<>0 THEN
						IF i_xFlag_Tension THEN
							IF I_xFlag_Stop AND(*停止状态下再按停机|取消张力*)
								i_pstStEvtReq^.xReqStop THEN
								i_pxBtnTension^:=TRUE;
							END_IF
						END_IF
						i_pxLastFlag_Stop^:=i_xFlag_Stop;
					END_IF

					(*空转按钮|沿有效*)
					i_pxBtnInk^:=i_pstStEvtReq^.xReqPrestart;
					(*印刷按钮|沿有效*)
					i_pxBtnPrint^:=i_pstStEvtReq^.xReqPrint;
					(*停止按钮|沿有效*)
					i_pxBtnStop^:=i_pstStEvtReq^.xReqStop;
					(*手动加速|按钮长有效*)
					i_pxBtnManuAcc^:=i_pstStEvtReq^.xEvt_ManuSpdUp;
					(*手动减速|按钮长有效*)
					i_pxBtnManuDec^:=i_pstStEvtReq^.xEvt_ManuSpdDn;
					(*自动加加速|*)
					i_pxBtnAutoAccOrDec^:=i_pstStEvtReq^.xReqPrestart;

					(*张力投入按钮|沿有效*)
					IF NOT i_pxBtnTension^ THEN(* 2021.12.22.144134张力投入按钮*)
						i_pxBtnTension^:=i_pstStEvtReq^.xReqTension;
					END_IF
(* 2021.12.22.145033目标速度赋值*)
					i_plrVel_Tar^:=i_prVel_Tar_HMI^;
			CUSTOMERNAME_JIANGYINHUITONG:(*2022.7.7.102221华丰-流程-类似*)
					i_pbyActionCtlWay^:=0;
					(*空转按钮|沿有效*)
					i_pxBtnInk^:=i_pstStEvtReq^.xReqPrestart;
					(*印刷按钮|沿有效*)
					i_pxBtnPrint^:=i_pstStEvtReq^.xReqPrint;
					(*张力投入按钮|沿有效*)
					i_pxBtnTension^:=i_pstStEvtReq^.xReqTension;
					(*停止按钮|沿有效*)
					i_pxBtnStop^:=i_pstStEvtReq^.xReqStop;
					(*手动加速|按钮长有效*)

					IF i_xFlag_Print THEN(*印刷状态下加速按钮为自动加减速按钮-加减速到目标速度，无手动加速
																，减速为自动减速到空转速度|2022.7.30.093338*)
						i_pxBtnAutoAccOrDec^:= i_pstStEvtReq^.xReqManuSpdUp;(*自动加速*)
						i_plrVel_Tar^:=i_prVel_Tar_HMI^;
						i_pxBtnManuAcc^:=FALSE;(*手动加速无效*)

						IF NOT i_pxBtnAutoAccOrDec^ THEN
							IF i_pstStEvtReq^.xReqManuSpdDn THEN (*手动减速按钮按下-如果速度大于空转速度=自动减速*)
								IF i_rVel_Cur>i_rVel_Ink THEN(*空转速度小于当前速度-自动减速到空转速度*)
									i_pxBtnAutoAccOrDec^:= i_pstStEvtReq^.xReqManuSpdDn;
									i_plrVel_Tar^:=i_rVel_Ink;
								END_IF
							END_IF
						END_IF
					END_IF

					IF i_xFlag_Ink THEN
						IF i_rVel_Cur<i_prVel_Tar_HMI^ THEN(*当前速度小于目标速度-自动加减速生效-手动加减速无效*)
							i_pxBtnAutoAccOrDec^:= i_pstStEvtReq^.xReqManuSpdUp;(*自动加速*)
							i_plrVel_Tar^:=i_prVel_Tar_HMI^;
							i_pxBtnManuAcc^:=FALSE;(*手动加速无效*)
						ELSE
							IF i_xFlag_Ink THEN(*空转有手动加速*)
								i_pxBtnManuAcc^:=i_pstStEvtReq^.xEvt_ManuSpdUp;(*手动加速按钮有效*)
								i_plrVel_Tar^:=i_prVel_Tar_HMI^;
							END_IF
						END_IF
	
						IF i_pstStEvtReq^.xReqManuSpdDn THEN (*手动减速按钮按下-如果速度大于空转速度=自动减速*)
							IF i_rVel_Cur>i_rVel_Ink THEN(*空转速度小于当前速度-自动减速到空转速度*)
								i_pxBtnAutoAccOrDec^:= i_pstStEvtReq^.xReqManuSpdDn;
								i_plrVel_Tar^:=i_rVel_Ink;
							END_IF
						END_IF
						i_pxBtnManuDec^:=FALSE;(*无手动减速*)
					END_IF
			CUSTOMERNAME_QINHUA:		
					i_pbyActionCtlWay^:=1;
					
					IF i_xFlag_Stop THEN
						(*记录下当前的印刷机档位|*)
						i_pxTapPosition_Breaking^:= i_pstStEvtReq^.xEvt_TapPosition_Breaking;
						i_pxTapPosition_Printing^:= i_pstStEvtReq^.xEvt_TapPosition_Printing;
						i_pxTapPosition_UniformInk^:= i_pstStEvtReq^.xEvt_TapPosition_UniformInk;
						
						//2026.1.6.160707 | + 
						//i_pstStEvtReq^.xReqPrestart := FALSE;
					END_IF

					IF i_pxTapPosition_Breaking^ THEN(*断料档位*)
						i_pxBtnInk^:=i_pstStEvtReq^.xReqPrestart;(*断料档位只空转*)
					ELSIF i_pxTapPosition_UniformInk^ THEN(*匀墨档位*)
						i_pxBtnInk^:=i_pstStEvtReq^.xReqPrestart;(*匀墨档位-空转+张力投入*)
						IF NOT i_xFlag_Tension THEN
							i_pxBtnTension^:=i_pstStEvtReq^.xReqPrestart;
						END_IF
						i_pxLinkage_IfOf_Ink^:= FALSE;
					ELSIF i_pxTapPosition_Printing^ THEN(*印刷档位*)			
						(*印刷档位|在拉料时候有可能会存在牵引电机运动的问题；
						在这里修改启动按钮的时机为拉料完成后|2021.11.3.112006*)
(*						i_pxBtnPrint^:=i_pstStEvtReq^.xReqPrestart;(*印刷档位-空转+张力投入+印刷0速*)*)
						IF  NOT i_xFlag_Tension THEN
							i_pxBtnTension^:=i_pstStEvtReq^.xReqPrestart;
						ELSE
							IF  i_xFlag_TensionDone AND (*拉料完成才能进入开机逻辑*)
								i_xFlag_Stop THEN(*停机的时候输出印刷按钮*)
								i_pxBtnPrint^:=TRUE;(*印刷档位-空转+张力投入+印刷0速*)
							END_IF
						END_IF
					END_IF

					IF i_pxLastFlag_Stop<>0 THEN
						IF i_xFlag_Tension THEN
							IF (NOT i_xFlag_Estop AND
								i_xFlag_Stop AND
								NOT i_pxLastFlag_Stop^) OR (*非停止到停止*)
								(i_pstStEvtReq^.xReqStop AND
								i_xFlag_Stop) THEN(*停止状态下按下停机按键*)
								i_pxBtnTension^:=TRUE;
								i_pxBtnPrint^:=FALSE;(*和上面逻辑存在状态重叠*)
							END_IF
						END_IF
						i_pxLastFlag_Stop^:=i_xFlag_Stop;
					END_IF
					(*停止按钮|沿有效*)
					i_pxBtnStop^:=i_pstStEvtReq^.xReqStop;
					(*手动加速|按钮长有效*)
					i_pxBtnManuAcc^:=i_pstStEvtReq^.xEvt_ManuSpdUp;
					(*手动减速|按钮长有效*)
					i_pxBtnManuDec^:=i_pstStEvtReq^.xEvt_ManuSpdDn;
					(*自动加加速|*)
					i_pxBtnAutoAccOrDec^:=i_pstStEvtReq^.xReqPrestart;
					i_plrVel_Tar^:=i_prVel_Tar_HMI^;
			CUSTOMERNAME_CHAOXU:
					i_pbyActionCtlWay^:=1;
					
					IF i_xFlag_Stop THEN
						(*记录下当前的印刷机档位|*)
						i_pxTapPosition_Breaking^:= i_pstStEvtReq^.xEvt_TapPosition_Breaking;
						i_pxTapPosition_Printing^:= i_pstStEvtReq^.xEvt_TapPosition_Printing;
						i_pxTapPosition_UniformInk^:= i_pstStEvtReq^.xEvt_TapPosition_UniformInk;
					END_IF

					IF i_pxTapPosition_Breaking^ THEN(*断料档位*)
						i_pxBtnInk^:=i_pstStEvtReq^.xReqPrestart;(*断料档位只空转*)
					ELSIF i_pxTapPosition_UniformInk^ THEN(*匀墨档位*)
						i_pxBtnInk^:=i_pstStEvtReq^.xReqPrestart;(*匀墨档位-空转+张力投入*)
						IF NOT i_xFlag_Tension THEN
							i_pxBtnTension^:=i_pstStEvtReq^.xReqPrestart;
						END_IF
						i_pxLinkage_IfOf_Ink^:= FALSE;
					ELSIF i_pxTapPosition_Printing^ THEN(*印刷档位*)			
						(*印刷档位|在拉料时候有可能会存在牵引电机运动的问题；
						在这里修改启动按钮的时机为拉料完成后|2021.11.3.112006*)
(*						i_pxBtnPrint^:=i_pstStEvtReq^.xReqPrestart;(*印刷档位-空转+张力投入+印刷0速*)*)
						IF  NOT i_xFlag_Tension THEN
							i_pxBtnTension^:=i_pstStEvtReq^.xReqPrestart;
						ELSE
							IF  i_xFlag_TensionDone AND (*拉料完成才能进入开机逻辑*)
								i_xFlag_Stop THEN(*停机的时候输出印刷按钮*)
								i_pxBtnPrint^:=TRUE;(*印刷档位-空转+张力投入+印刷0速*)
							END_IF
						END_IF
					END_IF

					IF i_pxLastFlag_Stop<>0 THEN
						IF i_xFlag_Tension THEN
							IF (NOT i_xFlag_Estop AND
								i_xFlag_Stop AND
								NOT i_pxLastFlag_Stop^) OR (*非停止到停止*)
								(i_pstStEvtReq^.xReqStop AND
								i_xFlag_Stop) THEN(*停止状态下按下停机按键*)
								i_pxBtnTension^:=TRUE;
								i_pxBtnPrint^:=FALSE;(*和上面逻辑存在状态重叠*)
							END_IF
						END_IF
						i_pxLastFlag_Stop^:=i_xFlag_Stop;
					END_IF
					

					(*停止按钮|沿有效*)
					i_pxBtnStop^:=i_pstStEvtReq^.xReqStop;
					(*手动加速|按钮长有效*)
					i_pxBtnManuAcc^:=i_pstStEvtReq^.xEvt_ManuSpdUp;
					(*手动减速|按钮长有效*)
					i_pxBtnManuDec^:=i_pstStEvtReq^.xEvt_ManuSpdDn;
					(*自动加加速|*)
					i_pxBtnAutoAccOrDec^:=i_pstStEvtReq^.xReqPrestart;
// 					IF i_xFlag_Print THEN
// 						i_pxBtnAutoAccOrDec^:=i_pstStEvtReq^.xReqPrint;
// 					END_IF
					i_plrVel_Tar^:=i_prVel_Tar_HMI^;					
		ELSE
			i_pbyActionCtlWay^:=0;
			(*2023.10.05.152335 将标准开机流程作为默认*)
			(*空转按钮|沿有效*)
			i_pxBtnInk^:=i_pstStEvtReq^.xReqPrestart;
			(*印刷按钮|沿有效*)
			i_pxBtnPrint^:=i_pstStEvtReq^.xReqPrint;
			(*张力投入按钮|沿有效*)
			i_pxBtnTension^:=i_pstStEvtReq^.xReqTension;
			(*停止按钮|沿有效*)
			i_pxBtnStop^:=i_pstStEvtReq^.xReqStop;
			(*手动加速|按钮长有效*)
			i_pxBtnManuAcc^:=i_pstStEvtReq^.xEvt_ManuSpdUp;
			(*手动减速|按钮长有效*)
			i_pxBtnManuDec^:=i_pstStEvtReq^.xEvt_ManuSpdDn;
			(*自动加加速|*)
			i_pxBtnAutoAccOrDec^:=i_pstStEvtReq^.xReqPrestart;


			i_plrVel_Tar^:=i_prVel_Tar_HMI^;

		END_CASE

		IF iCustomerName<> CUSTOMERNAME_BEIREN AND iCustomerName<> CUSTOMERNAME_BEIREN_NOLOGO  AND(*不是北人的流程  清除一些标志*)
			 iCustomerName<> CUSTOMERNAME_ZHEJIANGOUNUO THEN
			i_pxFastStopBtnDn^:=FALSE;
		END_IF

		(*界面自动加减速按钮|2021.7.26.174154*)
		i_pxBtnAutoAccOrDec^:=i_pxBtnAutoAccOrDec^ OR i_pxAutoAccDec_Hmi^;
		i_pxAutoAccDec_Hmi^:=FALSE;

		(*2021.7.17.135538 替换|*)
		FOR iN:=1 TO 3 BY 1 DO
			IF i_paxCommVel_Sure^[i_iGrpId,iN] THEN
(*				i_paxCommVel_Sure^[i_iGrpId,iN]:=FALSE;*)
				i_prVel_Tar_HMI^:=i_arVel_CommonlyUsed[iN];
				IF (NOT i_xFlag_Accing) AND (NOT i_xFlag_Decing) THEN
					IF NOT i_paxNeedRstTrig_AutoAccOrDec^[iN] THEN
						i_paxCommVel_Sure^[i_iGrpId,iN]:=FALSE;
						i_pxBtnAutoAccOrDec^:=TRUE;
					ELSE
						i_paxNeedRstTrig_AutoAccOrDec^[iN]:=FALSE;
						i_pxBtnAutoAccOrDec^:=FALSE;(*2023.12.17.155229@复位处理*)
					END_IF
					i_plrVel_Tar^:=i_prVel_Tar_HMI^;
				ELSE (*自动加速中，停止当前加速启动新加速*)
					IF i_xFlag_AutoAcc  OR i_xFlag_AutoDec THEN
						IF NOT i_pxBtnAutoAccOrDec^ OR i_paxNeedRstTrig_AutoAccOrDec^[iN] THEN(*停止自动加减速*)
							i_pxBtnAutoAccOrDec^:=TRUE;
							i_paxNeedRstTrig_AutoAccOrDec^[iN]:=TRUE;(*还需要再复位一次*)
						ELSIF i_pxBtnAutoAccOrDec^ THEN
							i_paxNeedRstTrig_AutoAccOrDec^[iN]:=TRUE;(*复位沿*)
							i_pxBtnAutoAccOrDec^:=FALSE;(*2023.12.17.155229@复位处理*)
						END_IF
					ELSE
						i_paxCommVel_Sure^[i_iGrpId,iN]:=FALSE;
					END_IF
				END_IF
				EXIT;(*只处理一个有效的*)
			END_IF
		END_FOR

		(*|2022.11.30.093008*)
		(*拉料未完成报警被触发的时候|我们等待拉料完成并再次执行输出印刷按钮启动印刷
		用户不用再按印刷按钮了*)
		IF i_pxLastFlag_TensionUnFinished<>0 THEN
			IF i_xFlag_Tension AND(*处于张力投入中*)
				NOT i_xFlag_Print THEN(*非印刷情况下*)
				IF i_xFlag_TensionUnfinished THEN(*投入未完成|说明按下过印刷*)
					i_pxLastFlag_TensionUnFinished^:=TRUE;
				ELSIF i_pxLastFlag_TensionUnFinished^ AND
					i_xFlag_TensionDone THEN(*张力投入未完成进入到张力投入完成*)
					i_pxBtnPrint^:=TRUE;
					i_pxLastFlag_TensionUnFinished^:=FALSE;
				ELSE(*再按下停止或者急停的时候清除*)
					IF i_pxBtnStop^ OR i_pstStEvtReq^.xEvt_Estop THEN
						i_pxLastFlag_TensionUnFinished^:=FALSE;
					END_IF
				END_IF
			ELSE
				i_pxLastFlag_TensionUnFinished^:=FALSE;
			END_IF
		END_IF
	END_IF

(*
	(*加密处理|2021.12.6.140713*)
	IF g_stEncrytion.Locked THEN
		i_pxBtnPrint^:=FALSE;
	END_IF
*)
	(*急停按钮|沿有效*)
	i_pxBtnEStop^:=	i_pstStEvtReq^.xEvt_Estop OR
						i_xFlag_LinkageAxisAlarm OR
						(i_xInverterAlarm AND (i_xFlag_Print OR i_xFlag_Tension)) OR (* 2021.7.7.171131/ *)
						i_xBrakeFilm (*AND*) OR
(*2022.11.30.092111*)
(*						i_xNeedEstop_BrakeAlarm OR(*2022.5.11.112859*)*)
						xNeedEstopByPrnRollerLoose;(*2022.5.26.165456*)
		
	(*2022.4.3.170117*)
	IF xNotAllowMachineRun THEN (*不允许开机|*)
		IF i_pxBtnPrint^ OR i_pxBtnInk^ THEN(*2022.5.21.101813|增加排风限制启动提示信息*)
			xTips_ExhausLimitStart:= wNotAllowMachineRun.1;(*TRUE*)(*排风限制启动提示*)
		END_IF
		i_pxBtnInk^:=FALSE;
		i_pxBtnPrint^:=FALSE;
(*		i_pxBtnTension^:=FALSE;*)(*2022.5.21.101039 可以开张力*)
	END_IF


END_IF
(*2022.5.21.102302*)
IF i_pxTips_ExhausLimitStart<>0 THEN
	IF NOT i_pxTips_ExhausLimitStart^ THEN
		IF xTips_ExhausLimitStart THEN(*只置位|*)
			i_pxTips_ExhausLimitStart^:=xTips_ExhausLimitStart;
		END_IF
	ELSE
		IF NOT xNotAllowMachineRun THEN(*机器可以启动了*)
			 i_pxTips_ExhausLimitStart^:=FALSE;
		END_IF
	END_IF
END_IF

(*2022.5.29.001053*)
IF i_pbySpecialProcess<>0 THEN
	i_pbySpecialProcess^:=bySpecialProcess;
END_IF
(*2022.5.29.001053*)
IF i_ptmHold_PreStart<>0 THEN
	i_ptmHold_PreStart^:=tmHold_PreStart;
END_IF

(*2023.06.24.193237*)
IF i_pbyStates<>0 THEN
	i_pbyStates^:=byStates;
END_IF