(*@CES
Name=KS_FB_StdActionCtl
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=676088f8-efac-4f69-8723-859df14a73f6
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_StdActionCtl
(*2022.5.28.223230  修改流程增加快停处理
分开自动加减速和手动加减速变量
i_byActionCtlWay=0开机方式兼容预备直接到开机和预备后响铃完成按下空转进入*)
(*2023.3.2.211619 空转在速度过高状态下按下印刷 自动减速到空转速度的时间由30s修改未手动减速时间*)
(*2023.3.10.141728 空转速度过高进入印刷时候使用的时间用错了*)
(*2025.2.8.162545 急停时间按照输入时间执行,反算需要设置的急停时间实现*)
(*2025.2.10.112944 增加o_iTimeSec_AccDec_AllTheWay_0_1s输出单位修改为0.1s@解决急停快速停止*)
VAR_INPUT
	i_xEn									: BOOL;(*功能块使能*)
	i_byActionCtlWay						: BYTE;(*动作流程选择
													|0:预启动--空转--张力投入--印刷--空转--停机
													|1:预启动--空转--停机;预启动--张力投入--印刷(速度为0)--停机*)
	i_xBtnInk								: BOOL;(*空转按钮-包含了预启动响铃状态*)
	i_xBtnPrint								: BOOL;(*印刷按钮*)
	i_xBtnTension							: BOOL;(*张力投入按钮*)
	i_xBtnManuAcc							: BOOL;(*手动加速*)
	i_xBtnManuDec							: BOOL;(*手动减速*)
	i_xBtnAutoAccOrDec						: BOOL;(*自动加速减速*)
	i_xBtnStop								: BOOL;(*停止按钮*)
	i_xBtnFastStop							: BOOL;(*快速停止按钮|2022.4.9.233605*)
	i_xBtnEstop								: BOOL;(*急停按钮*)
	i_xTensionDne							: BOOL;(*张力投入完成了*)
	i_lrVel_Cur								: LREAL;(*当前速度*)
	i_lrVel_Max								: LREAL;(*允许的最大速度*)
	i_lrVel_Tar								: LREAL;(*自动目标速度*)
	i_lrVel_Ink								: LREAL;(*匀墨速度|*)
	i_iTime_Ink								: INT;(*空转时间|单位:s|*)
	i_iTime_Stop							: INT;(*停机时间|单位:s|*)
	i_iTime_FastStop						: INT;(*快速停机时间|单位:s|*)
	i_iTime_Estop							: INT;(*急停时间|单位:s|*)
(*2022.5.27.145223 加减速时间分开*)
(*
	i_iTime_AutoAccDec						: INT;(*自动加减速时间|单位:s|*)
	i_iTime_ManuAccDec						: INT;(*手动加减速时间|单位:s|*)
*)
	i_iTime_AutoAcc							: INT;(*自动加减速时间|单位:s|*)
	i_iTime_AutoDec							: INT;(*自动加减速时间|单位:s|*)
	i_iTime_ManuAcc							: INT;(*手动加减速时间|单位:s|*)
	i_iTime_ManuDec							: INT;(*手动加减速时间|单位:s|*)
	i_pxFlag_ArrivedToTargetVel				: POINTER TO BOOL;(*到达目标速度|在速度功能块中会修改该值。故在此使用指针2019.8.29.113741*)
	i_pxFlag_KeepAlarming					: POINTER TO BOOL;(*响铃|外部功能块会有操作*)
	i_xFilmAccFinish						: BOOL;(*料膜加速完成标志*)
	i_tmHold_PreStart						: TIME := T#3s; (* 开机预启动持续时间| 2022.5.27.143829*)
	i_bySpecialProcess						: BYTE;(*在基础的开机流程上增加了特殊开机方式切换标志|0:按照基础的|
																								 |1:北人的*)
	i_xBtnInk_BeiRen						: BOOL;(*空转按钮-专为北人使用|和基础流程的空转按钮定义不同|2022.5.28.234758*)
	(*2025.2.8.163015+*)
	i_xEstopTimeIsActTime					: BOOL;(*急停时间是实际时间标志@需要反算写入到速度功能块的时间*)
	i_uiMaxVel_UseCalcAcc					: UINT;(*计算加速度的最大速度值*)
	(*2025.2.13.131016+默认是这种方式*)
	i_xEstopTimeIsToMaxVel					: BOOL;(*急停时间是到达最大速度的时间标志@需要反算写入到速度功能块的时间*)
END_VAR
VAR_OUTPUT
	o_xEn									: BOOL;
	o_iIdGSE								: INT;(*状态!*)
	o_xFlag_Stop							: BOOL;(*停机标志*)
	o_xFlag_PreStart						: BOOL;(*预启动标志|从停机状态按(预)启动置位标志 色组速度达到空转速度清o_xFlag_PreStart标志,置位o_xFlag_Ink标志;当o_xFlag_Print标志有效后,*)
	o_xFlag_PreStart_Print					: BOOL;(*印刷预启动标志|用于华丰逻辑变量*)
	o_xFlag_Ink								: BOOL;(*匀墨标志|>20m/min不能联动*)
	o_xFlag_InkAccing						: BOOL;(*匀墨加速中<指0~10m/min那个加速过程>*)
	o_xFlag_Tension							: BOOL;(*张力投入标志|张力投入有效时收放料变频开始起作用|收放料就位后按印刷按钮,牵引压辊合压|o_xFlag_Print有效时张力投入不处理*)
	o_xFlag_Print							: BOOL;(*张力拉料标志有效时，按联动或印刷按钮 先压收牵(延时2s)再压放牵 印刷标志|印刷色组根据联动标志按用户指定的压辊顺序逐一延时压胶辊|胶辊压合完毕后才可置该标志有效|*)
	o_xFlag_Estop							: BOOL;(*急停标志|和停机一样要减速到0，只不过减速时间是急停时间*)
	o_xFlag_AutoAcc							: BOOL;(*自动加速*)
	o_xFlag_AutoDec							: BOOL;(*自动减速*)
	o_xFlag_ManuAcc							: BOOL;(*手动加速*)
	o_xFlag_ManuDec							: BOOL;(*手动减速*)
	o_xFlag_Accing							: BOOL;(*加速中*)
	o_xFlag_Decing							: BOOL;(*减速中*)
	o_xFlag_EStoping						: BOOL;(*正在急停中*)
	o_xFlag_Stoping							: BOOL;(*停机中*)
	o_xFlag_FastStoping						: BOOL;(*快速停机中*)
	(*o_xFlag_GotoInking						: BOOL;(*转到匀墨*)*)
	o_xTensionNotFinish						: BOOL;(*按下印刷按钮张力投入未完成输出*)
	o_xReCalc_Target						: BOOL;(*重新计算加减速动作参数,针对在切换变速过程逻辑*)
	o_xToPrintVelTooHigh					: BOOL;(*进入印刷状态时速度太高了*)
	o_rFinalVelocity						: REAL;(*目标速度*)
	o_iTimeSec_AccDec_AllTheWay				: INT;(*全程加减速所需要的秒|*)
	(*2025.2.10.110905+ 单位修改了0.1s@急停的时候需要更短*)
	o_iTimeSec_AccDec_AllTheWay_0_1s		: INT;(*输出时间单位为0.1s*)
	o_xVel_Tar_OverRange					: BOOL;(*目标速度超限值|2019.10.28.102337*)
END_VAR
VAR
	aR_TrigBtn								: ARRAY [1..10] OF R_TRIG;
	xTrigInk								: BOOL;(*空转按钮-包含了预启动响铃状态*)
	xTrigPrint								: BOOL;(*印刷按钮*)
	xTrigTension							: BOOL;(*张力投入按钮*)
	xTrigManuAcc							: BOOL;(*手动加速*)
	xTrigManuDec							: BOOL;(*手动减速*)
	xTrigAutoAccOrDec						: BOOL;(*自动加速减速*)
	xTrigStop								: BOOL;(*停止按钮*)
	xTrigFastStop							: BOOL;(*快速停止按钮|2022.4.9.233520*)
	xTrigEstop								: BOOL;(*急停按钮*)
	xInitialization							: BOOL;(*上电初始化*)
	byChangVelSts							: BYTE;(*变速时的状态	1 预启动--空转加速
																	2 手动加速
																    3 手动减速
																    4 自动加速
																    5 自动减速
																	6 印刷停机减速到空转
																	7 空转停机到0速
																	8 印刷停机减速到0速
																	9 印刷0速停机
																	10 急停减速
																	110 停止加减速
																	11 快速停止|2022.4.9.233449 增加*)
	byPreChangVelSts						: BYTE;
	xFlag_ArrivedToTarVel					: BOOL;
	xFlag_KeepAlarming						: BOOL;
	iToPrintMaxVel							: INT:=20;(*进入印刷的最大速度值*)
	lrFinalVelocity							: LREAL;(*保存目标速度值|只有在非加减速状态下才能将该值赋值给输出*)
	xFlag_InkToPrintAutoDec: BOOL;
	xAutoInkToPrint: BOOL;
	(*2022.5.28.233518 增加*)
	fbTon_PreStart							: TON;(*预启动计时器|2022.5.27.143640-*)
	xIamRdy: BOOL;

	(*2025.2.8.162509 设置的急停时间@100m/min的时间*)
	iTime_Estop_Set_0_1s: INT:=50;(*赋一个初值@单位0.1s*)
END_VAR
{IMPLEMENTATION}
(*处理按钮上升沿*)
aR_TrigBtn[1](CLK:=i_xBtnInk,Q=>xTrigInk);
aR_TrigBtn[2](CLK:=i_xBtnPrint,Q=>xTrigPrint);
aR_TrigBtn[3](CLK:=i_xBtnTension,Q=>xTrigTension);
aR_TrigBtn[4](CLK:=i_xBtnManuAcc,Q=>xTrigManuAcc);
aR_TrigBtn[5](CLK:=i_xBtnManuDec,Q=>xTrigManuDec);
aR_TrigBtn[6](CLK:=i_xBtnAutoAccOrDec,Q=>xTrigAutoAccOrDec);
aR_TrigBtn[7](CLK:=i_xBtnStop,Q=>xTrigStop);
aR_TrigBtn[8](CLK:=i_xBtnEstop,Q=>xTrigEstop);
aR_TrigBtn[9](CLK:=i_xBtnFastStop,Q=>xTrigFaststop);

IF i_xEstopTimeIsToMaxVel THEN
	(*2025.2.13.131116+ 急停时间是到达最大速度的时间标志@需要反算写入到速度功能块的时间*)
	IF xTrigEstop THEN(*有急停了@计算设置值*)
		IF i_uiMaxVel_UseCalcAcc<>0 AND i_lrVel_Max<>0 THEN
			iTime_Estop_Set_0_1s:=LREAL_TO_INT((UINT_TO_LREAL(i_uiMaxVel_UseCalcAcc)/i_lrVel_Max*i_iTime_Estop)*10);
			iTime_Estop_Set_0_1s:=ABS(iTime_Estop_Set_0_1s);
			IF iTime_Estop_Set_0_1s=0 THEN(*最小1s*)
				iTime_Estop_Set_0_1s:=10;
			END_IF
		ELSE
			iTime_Estop_Set_0_1s:=i_iTime_Estop*10;
		END_IF
	END_IF
ELSIF i_xEstopTimeIsActTime THEN
	(*2025.2.8.162401 急停的时间输入按照实际执行@这样就需要根据实际的时间反算设置时间*)
	IF xTrigEstop THEN(*有急停了@计算设置值*)
		IF i_uiMaxVel_UseCalcAcc<>0 AND i_lrVel_Cur<>0 THEN
			iTime_Estop_Set_0_1s:=LREAL_TO_INT((UINT_TO_REAL(i_uiMaxVel_UseCalcAcc)/i_lrVel_Cur*i_iTime_Estop)*10);
			iTime_Estop_Set_0_1s:=ABS(iTime_Estop_Set_0_1s);
			IF iTime_Estop_Set_0_1s=0 THEN(*最小1s*)
				iTime_Estop_Set_0_1s:=10;
			END_IF
		ELSE
			iTime_Estop_Set_0_1s:=i_iTime_Estop*10;
		END_IF
	END_IF
ELSE(*原来形式*)
	(*下面不用*)
	iTime_Estop_Set_0_1s:=i_iTime_Estop*10;
END_IF




IF i_pxFlag_KeepAlarming<>0 AND i_pxFlag_ArrivedToTargetVel<>0 THEN  ;ELSE RETURN;END_IF

xFlag_ArrivedToTarVel:=i_pxFlag_ArrivedToTargetVel^;
xFlag_KeepAlarming:=i_pxFlag_KeepAlarming^;
o_xReCalc_Target:=FALSE;
o_xEn:=i_xEn;

o_xVel_Tar_OverRange:=FALSE;
IF i_lrVel_Tar>i_lrVel_Max THEN(*2019.10.28.102110 对目标速度进行限值,并输出限速标志*)
	i_lrVel_Tar:=i_lrVel_Max;
	IF byChangVelSts=4 THEN(*自动加速时输出超限标志*)
		o_xVel_Tar_OverRange:=TRUE;
	END_IF
END_IF


(*预启动计时器|2022.5.27.145521*)
fbTon_PreStart(IN:=o_xFlag_PreStart OR o_xFlag_PreStart_Print,PT:=i_tmHold_PreStart);

IF  i_xEn THEN
	IF NOT xInitialization THEN(*上电默认停机状态*)
		xInitialization:=TRUE;
		o_xFlag_Stop:=TRUE;
	END_IF

	(*输入值是否合法|时间不能为0*)
	(*	KS_SetVarValue_NQ0(i_dwVarAdr, i_iSetValue, i_EmVarType)*)
	KS_SetVarValue_NQ0(ADR(i_iTime_Ink),100,TYPE_INT);
	KS_SetVarValue_NQ0(ADR(i_iTime_AutoAcc),100,TYPE_INT);
	KS_SetVarValue_NQ0(ADR(i_iTime_AutoDec),100,TYPE_INT);
	KS_SetVarValue_NQ0(ADR(i_iTime_ManuAcc),100,TYPE_INT);
	KS_SetVarValue_NQ0(ADR(i_iTime_ManuDec),100,TYPE_INT);
	KS_SetVarValue_NQ0(ADR(i_iTime_Stop),20,TYPE_INT);
	KS_SetVarValue_NQ0(ADR(i_iTime_Estop),2,TYPE_INT);
	(*修改为了0.1s单位@2025.2.10.113812+*)
	KS_SetVarValue_NQ0(ADR(iTime_Estop_Set_0_1s),20,TYPE_INT);
	KS_SetVarValue_NQ0(ADR(i_iTime_FastStop),20,TYPE_INT);

	(*2022.6.3.113642  在张力投入取消的时候清除标志|*)
	IF (i_xTensionDne OR NOT o_xFlag_Tension OR i_xBtnStop OR i_xBtnEstop) (*2022.11.21.151741 增加了按下停止和急停清除*)
		AND o_xTensionNotFinish THEN
		o_xTensionNotFinish:=FALSE ;
	END_IF


	IF NOT o_xFlag_Estop THEN(*非急停状态*)
		IF xTrigTension AND NOT o_xFlag_Print THEN(*张力投入|非印刷的时候才可以操作*)
			o_xFlag_Tension:=NOT o_xFlag_Tension;
		END_IF

		IF o_xFlag_Stop THEN(*停止状态*)
			o_xFlag_Estop:=i_xBtnEstop;(*急停处理*)
			IF o_xFlag_Estop THEN RETURN;END_IF(*急停直接返回*)

			IF xTrigInk THEN(*空转按钮*)
				xFlag_KeepAlarming:=TRUE;(*启动响铃信号*)
				o_xFlag_PreStart:=TRUE;(*进入预启动状态*)
			END_IF

			IF i_byActionCtlWay=1 THEN(*华丰流程*)
				IF xTrigPrint THEN(*印刷按钮*)
					IF NOT o_xFlag_PreStart THEN(*没有按下空转按钮 直接按的印刷按钮*)
						xFlag_KeepAlarming:=TRUE;(*启动响铃信号*)
						o_xFlag_PreStart_Print:=TRUE;(*进入印刷预启动状态*)
					END_IF
				END_IF
			ELSE(*都按标准流程走*)
				;
			END_IF
			o_xFlag_Stop:=NOT o_xFlag_PreStart AND NOT o_xFlag_PreStart_Print;
		ELSE(*处于非停止状态*)
			(*判断速度是否到位了,处理状态*)
			IF o_xFlag_Ink OR o_xFlag_Print THEN
				IF (xFlag_ArrivedToTarVel (*OR i_lrVel_Cur=0*))  AND byChangVelSts<>0 THEN
					CASE byChangVelSts OF
					6:(*印刷停机减速到空转*)
						o_xFlag_Print:=FALSE;
						o_xFlag_Ink:=TRUE;
					7:(*空转停机到0速*)
						o_xFlag_Stop:=TRUE;
					8:(*印刷停机减速到0速*);
					9:(*印刷0速停机*)
						o_xFlag_Stop:=TRUE;
					10:(*急停减速*)
						o_xFlag_EStop:=TRUE;
					11:(*快速停止|2022.4.9.235115*)
						o_xFlag_Stop:=TRUE;
					ELSE ;
					END_CASE
					byChangVelSts:=0;
					o_xReCalc_Target:=TRUE;(*在速度控制到位的时候使用该变量复位速度功能块的更新参数变量|防止在下面逻辑中清除
											xFlag_ArrivedToTarVel到位标志,导致参数不能更新直接进入下个变速逻辑*)

				END_IF
			END_IF

			(*2022.5.28.235413*)
			IF i_byActionCtlWay=1 THEN(*类华丰流程|还是使用原来的切换状态方式-即在响铃完成后进入下个状态*)
				xIamRdy:=NOT xFlag_KeepAlarming;(*响铃结束了|该条件有些瑕疵，但是可以用*)
			ELSE(*默认流程|*)
				IF i_bySpecialProcess=1 THEN(*北人需要在预启动响铃结束过程中按下空转*)
					IF o_xFlag_PreStart AND NOT xIamRdy THEN(*预启动|没有准备好的时候*)
						IF i_xBtnInk_BeiRen AND NOT xFlag_KeepAlarming THEN(*响铃结束了|检查北人空转按键*)
							xIamRdy:=TRUE;
						END_IF
						IF NOT xIamRdy THEN(*预备没准备好*)
							IF fbTon_PreStart.Q THEN(*预启动时间到|还么有按下|退出到停止*)
								o_xFlag_PreStart:=FALSE;
								o_xFlag_EStop:=i_xBtnEStop;
								IF NOT o_xFlag_EStop THEN o_xFlag_Stop:=TRUE; END_IF
							END_IF
						END_IF
					END_IF
				ELSE(*基础流程|预启动时间到了就可以进入下个状态了*)
					IF fbTon_PreStart.Q THEN(*预启动时间到*)
						xIamRdy:=TRUE;
					END_IF
				END_IF
			END_IF

(*			IF NOT xFlag_KeepAlarming THEN(*响铃完成了*)*)
			IF xIamRdy THEN(*可以进入下个开机状态了*)
				(*预启动状态*)
				IF o_xFlag_PreStart THEN(*预启动了，我们进入空转状态*)
					o_xFlag_PreStart:=FALSE;
					o_xFlag_Ink:=TRUE;
					xIamRdy:=FALSE;
					byChangVelSts:=1;(*进入空转加速逻辑*)
					(*2022.5.27.090554 增加*)
					o_xFlag_EStop:=i_xBtnEStop;
					IF NOT o_xFlag_EStop THEN o_xFlag_Stop:=i_xBtnStop; END_IF

					IF o_xFlag_EStop OR o_xFlag_Stop THEN
						byChangVelSts:=0;
					END_IF
				ELSIF o_xFlag_PreStart_Print THEN(*印刷预启动了*)
					IF i_xTensionDne THEN(*拉料完成*)
						o_xFlag_PreStart_Print:=FALSE;
						o_xFlag_Print:=TRUE;
						xIamRdy:=FALSE;
					ELSE
						o_xTensionNotFinish:=TRUE;
					END_IF
					(*2022.5.27.090540  移动位置*)
					o_xFlag_EStop:=i_xBtnEStop;
					IF NOT o_xFlag_EStop THEN o_xFlag_Stop:=i_xBtnStop; END_IF
				END_IF
			END_IF

			IF o_xFlag_PreStart OR o_xFlag_PreStart_Print THEN(*预启动中*)
				o_xFlag_EStop:=i_xBtnEStop;
				IF NOT o_xFlag_EStop THEN o_xFlag_Stop:=i_xBtnStop; END_IF
			END_IF

			(*启动状态*)
			IF o_xFlag_Ink THEN(*空转状态*)
				IF o_xFlag_InkAccing THEN;
				ELSE(*空转加速完成了*)
					IF i_byActionCtlWay=0 THEN(*常规流程*)
						IF (xTrigPrint OR xAutoInkToPrint) AND byChangVelSts=0 THEN(*并且按下了印刷键进入印刷状态*)
							IF i_xTensionDne THEN(*张力投入完成了 *)
								IF i_lrVel_Cur<=iToPrintMaxVel  THEN
									o_xFlag_Print:=TRUE;
									o_xFlag_Ink:=FALSE;
								ELSE(*速度太高不能进入印刷状态*)
									o_xToPrintVelTooHigh:=TRUE;
								END_IF
							ELSE
								o_xTensionNotFinish:=TRUE;
							END_IF
						END_IF
					END_IF
				END_IF
			ELSIF o_xFlag_Print THEN;
			END_IF

			(*清除进入印刷速度太高标志*)
			IF i_lrVel_Cur<=iToPrintMaxVel AND o_xToPrintVelTooHigh THEN
				o_xToPrintVelTooHigh:=FALSE;
			END_IF

			(*2019.10.9.112347增加了进入印刷状态时速度太高自动减速的逻辑|该状态可以被加速减速或者按下自动加速键取消掉*)
			IF NOT xFlag_InkToPrintAutoDec  THEN
				IF o_xToPrintVelTooHigh THEN
					IF byChangVelSts=0 THEN(*未有加减速的状态*)
						xTrigAutoAccOrDec:=TRUE;
						i_lrVel_Tar:=i_lrVel_Ink;(*减速到匀墨速度后进入印刷状态*)
						(*2023.3.10.141719*)
						(*使用自动减速时间变量i_iTime_AutoDec@之前使用成了i_iTime_AutoAcc变量*)
						i_iTime_AutoDec:=i_iTime_ManuDec(*30*);(*2023.3.2.211607 修改为了手动减速时间*)
						xFlag_InkToPrintAutoDec:=TRUE;
					END_IF
				END_IF
			ELSE
				IF NOT o_xToPrintVelTooHigh AND xFlag_ArrivedToTarVel THEN
					xFlag_InkToPrintAutoDec:=FALSE;
					xAutoInkToPrint:=TRUE;
				END_IF

				IF o_xToPrintVelTooHigh AND byChangVelSts=0 THEN(*未有加减速的状态|说明被打断了复位标志*)
					xFlag_InkToPrintAutoDec:=FALSE;
					o_xToPrintVelTooHigh:=FALSE;
				END_IF
			END_IF

			IF o_xFlag_Print THEN
				xAutoInkToPrint:=FALSE;
			END_IF

			(*加减速 停机 急停动作*)
			IF o_xFlag_Ink OR o_xFlag_Print THEN
				IF xTrigEstop THEN(*急停了*)
					IF NOT o_xFlag_EStoping THEN
						byChangVelSts:=10;
					END_IF
				ELSIF xTrigFaststop THEN(*快速停止*)
					IF NOT o_xFlag_FastStoping AND NOT  o_xFlag_EStoping THEN
						byChangVelSts:=11;(*快速停止*)
					END_IF
				ELSIF xTrigstop THEN(*停机*)
					IF NOT o_xFlag_FastStoping AND NOT o_xFlag_Stoping AND NOT  o_xFlag_EStoping THEN
						IF o_xFlag_Print THEN
							IF i_byActionCtlWay=1 THEN(*华丰流程*)
								IF i_lrVel_Cur=0 THEN
									byChangVelSts:=9;
								ELSE
									byChangVelSts:=8;
								END_IF
							ELSE
								byChangVelSts:=6;
							END_IF
						ELSE(*空转*)
							byChangVelSts:=7;
						END_IF
					END_IF
				ELSIF i_xBtnManuAcc THEN(*手动加速*)
					IF NOT o_xFlag_FastStoping AND NOT o_xFlag_Stoping AND NOT  o_xFlag_EStoping AND
(*2019.10.09.150026|niu.j|加减速多加限制料膜加速完成和空转加速完成*)
						((o_xFlag_Print AND i_xFilmAccFinish) OR (NOT o_xFlag_InkAccing AND o_xFlag_Ink)) THEN
						byChangVelSts:=2;
					END_IF
				ELSIF i_xBtnManuDec THEN(*手动减速*)
					IF NOT o_xFlag_FastStoping AND NOT o_xFlag_Stoping AND NOT  o_xFlag_EStoping AND
(*2019.10.09.150026|niu.j|加减速多加限制料膜加速完成和空转加速完成*)
						((o_xFlag_Print AND i_xFilmAccFinish) OR (NOT o_xFlag_InkAccing AND o_xFlag_Ink)) THEN

						byChangVelSts:=3;
					END_IF
				ELSIF xTrigAutoAccOrDec THEN(*自动加减速*)
					IF NOT o_xFlag_FastStoping AND NOT o_xFlag_Stoping AND NOT  o_xFlag_EStoping AND
(*2019.10.09.150026|niu.j|加减速多加限制料膜加速完成和空转加速完成*)
						((o_xFlag_Print AND i_xFilmAccFinish) OR (NOT o_xFlag_InkAccing AND o_xFlag_Ink)) THEN

						IF byChangVelSts<>4 AND byChangVelSts<>5 THEN
							IF i_lrVel_Cur<i_lrVel_Tar THEN
								byChangVelSts:=4;
							ELSIF i_lrVel_Cur>i_lrVel_Tar THEN
								byChangVelSts:=5;
							END_IF
						ELSE
							byChangVelSts:=110;(*停止自动加减速*)
						END_IF
					END_IF
				END_IF

				IF (byChangVelSts=2 AND NOT i_xBtnManuAcc) OR
					(byChangVelSts=3 AND NOT i_xBtnManuDec) THEN
					byChangVelSts:=110;
				END_IF

				(*复位标志*)
				o_xFlag_InkAccing:=FALSE;
			(*	o_xFlag_GotoInking:=FALSE;*)
				o_xFlag_EStoping:=FALSE;
				o_xFlag_Stoping:=FALSE;
				o_xFlag_FastStoping:=FALSE;(*2022.4.9.233906*)
				o_xFlag_AutoAcc:=FALSE;
				o_xFlag_AutoDec:=FALSE;
				o_xFlag_ManuAcc:=FALSE;
				o_xFlag_ManuDec:=FALSE;

				CASE byChangVelSts OF
					1:(*预启动--空转加速*);
						xFlag_ArrivedToTarVel:=FALSE;(*进入空转加减速逻辑*)
						o_xFlag_InkAccing:=TRUE;
						o_iTimeSec_AccDec_AllTheWay:=i_iTime_Ink;
						lrFinalVelocity:=i_lrVel_Ink;
					2:(*手动加速*)
						IF NOT xFlag_ArrivedToTarVel THEN
							IF byChangVelSts<>byPreChangVelSts AND byPreChangVelSts<>0 THEN(*状态发生了切换*)
								o_xReCalc_Target:=TRUE;
							END_IF
						ELSE
							xFlag_ArrivedToTarVel:=FALSE;(*进入手动加速逻辑*)
						END_IF
						o_xFlag_ManuAcc:=TRUE;
						o_iTimeSec_AccDec_AllTheWay:=i_iTime_ManuAcc;
						lrFinalVelocity:=i_lrVel_Max;
					3:(*手动减速*)
						IF NOT xFlag_ArrivedToTarVel THEN
							IF byChangVelSts<>byPreChangVelSts AND byPreChangVelSts<>0 THEN(*状态发生了切换*)
								o_xReCalc_Target:=TRUE;
							END_IF
						ELSE
							xFlag_ArrivedToTarVel:=FALSE;(*进入手动减速逻辑*)
						END_IF

						o_xFlag_ManuDec:=TRUE;
						o_iTimeSec_AccDec_AllTheWay:=i_iTime_ManuDec;
						lrFinalVelocity:=0;
					4:(*自动加速*)
						IF NOT xFlag_ArrivedToTarVel THEN
							IF byChangVelSts<>byPreChangVelSts AND byPreChangVelSts<>0 THEN(*状态发生了切换*)
								o_xReCalc_Target:=TRUE;
							END_IF
						ELSE
							xFlag_ArrivedToTarVel:=FALSE;(*进入自动加速逻辑*)
						END_IF
						o_xFlag_AutoAcc:=TRUE;
						o_iTimeSec_AccDec_AllTheWay:=i_iTime_AutoAcc;
						lrFinalVelocity:=i_lrVel_Tar;
					5:(*自动减速*)
						IF NOT xFlag_ArrivedToTarVel THEN
							IF byChangVelSts<>byPreChangVelSts AND byPreChangVelSts<>0 THEN(*状态发生了切换*)
								o_xReCalc_Target:=TRUE;
							END_IF
						ELSE
							xFlag_ArrivedToTarVel:=FALSE;(*进入自动减速逻辑*)
						END_IF
						o_xFlag_AutoDec:=TRUE;
						o_iTimeSec_AccDec_AllTheWay:=i_iTime_AutoDec;
						lrFinalVelocity:=i_lrVel_Tar;
					6:(*印刷停机减速到空转*)
						IF NOT xFlag_ArrivedToTarVel THEN
							IF byChangVelSts<>byPreChangVelSts AND byPreChangVelSts<>0 THEN(*状态发生了切换*)
								o_xReCalc_Target:=TRUE;
							END_IF
						ELSE
							xFlag_ArrivedToTarVel:=FALSE;(*进入停止减速逻辑*)
						END_IF
						(*o_xFlag_GotoInking:=TRUE;*)

(*						o_xFlag_AutoDec:=TRUE;*)
						o_xFlag_Stoping:=TRUE;(*2022.4.10.002820 修改为停止中*)
						o_iTimeSec_AccDec_AllTheWay:=i_iTime_Stop;
						(*2022.1.26.101627 在当前速度小于空转速度的时候保持当前速度*)
						lrFinalVelocity:=i_lrVel_Ink;
						IF i_lrVel_Cur<=i_lrVel_Ink THEN
							lrFinalVelocity:=i_lrVel_Cur;
						END_IF
					7:(*空转停机到0速*)
						IF NOT xFlag_ArrivedToTarVel THEN
							IF byChangVelSts<>byPreChangVelSts AND byPreChangVelSts<>0 THEN(*状态发生了切换*)
								o_xReCalc_Target:=TRUE;
							END_IF
						ELSE
							xFlag_ArrivedToTarVel:=FALSE;(*进入停止减速逻辑*)
						END_IF
						o_xFlag_Stoping:=TRUE;
						o_iTimeSec_AccDec_AllTheWay:=i_iTime_Stop;
						lrFinalVelocity:=0;
						IF i_lrVel_Cur=0 THEN
							xFlag_ArrivedToTarVel:=TRUE;
						END_IF
					8:(*印刷停机减速到0速*)
						IF NOT xFlag_ArrivedToTarVel THEN
							IF byChangVelSts<>byPreChangVelSts AND byPreChangVelSts<>0 THEN(*状态发生了切换*)
								o_xReCalc_Target:=TRUE;
							END_IF
						ELSE
							xFlag_ArrivedToTarVel:=FALSE;(*进入停止减速逻辑*)
						END_IF
						o_xFlag_Stoping:=TRUE;
						o_iTimeSec_AccDec_AllTheWay:=i_iTime_Stop;
						lrFinalVelocity:=0;
					9:;(*印刷0速停机*)
						IF i_lrVel_Cur=0 THEN
							xFlag_ArrivedToTarVel:=TRUE;
						END_IF
					10:(*急停减速*)
						IF NOT xFlag_ArrivedToTarVel THEN
							IF byChangVelSts<>byPreChangVelSts AND byPreChangVelSts<>0 THEN(*状态发生了切换*)
								o_xReCalc_Target:=TRUE;
							END_IF
						ELSE
							xFlag_ArrivedToTarVel:=FALSE;(*进入急停减速逻辑*)
						END_IF
						o_xFlag_EStoping:=TRUE;
						o_iTimeSec_AccDec_AllTheWay:=i_iTime_Estop;
						lrFinalVelocity:=0;
						IF i_lrVel_Cur=0 THEN
							xFlag_ArrivedToTarVel:=TRUE;
						END_IF
					11:(*2022.4.9.234241  快速停止|*)
						IF NOT xFlag_ArrivedToTarVel THEN
							IF byChangVelSts<>byPreChangVelSts AND byPreChangVelSts<>0 THEN(*状态发生了切换*)
								o_xReCalc_Target:=TRUE;
							END_IF
						ELSE
							xFlag_ArrivedToTarVel:=FALSE;(*进入停止减速逻辑*)
						END_IF
						o_xFlag_FastStoping:=TRUE;
						o_iTimeSec_AccDec_AllTheWay:=i_iTime_FastStop;
						lrFinalVelocity:=0;

						IF i_lrVel_Cur=0 THEN
							xFlag_ArrivedToTarVel:=TRUE;
						END_IF
					110:(*停止加减速*)
						xFlag_ArrivedToTarVel:=TRUE;(*停止加减速*)
				ELSE byChangVelSts:=0;
				END_CASE
			END_IF
			byPreChangVelSts:=byChangVelSts;
		END_IF
	ELSE(*急停了*)
		o_xFlag_Estop:=i_xBtnEstop;(*没有急停信号时退出该分支*)
		o_xFlag_Stop:=NOT o_xFlag_Estop;
		o_xFlag_Tension:=FALSE;
	END_IF


	IF (NOT o_xFlag_Accing AND NOT o_xFlag_Decing) OR o_xReCalc_Target THEN(*非加减速或者更新速度参数时更新目标速度*)
		o_rFinalVelocity:=LREAL_TO_REAL(lrFinalVelocity);
	END_IF

	o_xFlag_Accing:=o_xFlag_ManuAcc OR o_xFlag_AutoAcc OR o_xFlag_InkAccing;
	o_xFlag_Decing:=o_xFlag_EStoping OR o_xFlag_Stoping OR o_xFlag_FastStoping OR o_xFlag_ManuDec OR o_xFlag_AutoDec;
END_IF

(*对加减速时间进行非零保护*)
IF o_iTimeSec_AccDec_AllTheWay=0 THEN(*100S*)
	o_iTimeSec_AccDec_AllTheWay:=100;
END_IF
IF o_iTimeSec_AccDec_AllTheWay_0_1s=0 THEN(*100S*)
	o_iTimeSec_AccDec_AllTheWay_0_1s:=1000;
END_IF
(*2025.2.10.111017 该值的输出修改为了ms@为了解决急停快速停止的问题*)
IF i_xEstopTimeIsActTime OR
	i_xEstopTimeIsToMaxVel THEN
	IF o_xFlag_EStoping THEN
		o_iTimeSec_AccDec_AllTheWay_0_1s:=iTime_Estop_Set_0_1s;
	ELSE
		o_iTimeSec_AccDec_AllTheWay_0_1s:=o_iTimeSec_AccDec_AllTheWay*10;
	END_IF
ELSE(*原方式的时候统一*10*)
	o_iTimeSec_AccDec_AllTheWay_0_1s:=o_iTimeSec_AccDec_AllTheWay*10;
END_IF


(*急停停机状态以及功能块未使能时候 清除若干变量*)
IF o_xFlag_Estop OR o_xFlag_Stop OR NOT i_xEn THEN
	xFlag_ArrivedToTarVel:=TRUE;(*默认将该值写成有效 在速度功能块中不会进入加减速逻辑*)
	xFlag_KeepAlarming:=FALSE;
	xFlag_InkToPrintAutoDec:=FALSE;
	xAutoInkToPrint:=FALSE;
	o_xFlag_PreStart:=FALSE;
	o_xFlag_PreStart_Print:=FALSE;
	o_xFlag_Ink:=FALSE;
	o_xFlag_InkAccing:=FALSE;
	o_xFlag_Print:=FALSE;
	o_xFlag_AutoAcc:=FALSE;
	o_xFlag_AutoDec:=FALSE;
	o_xFlag_ManuAcc:=FALSE;
	o_xFlag_ManuDec:=FALSE;
	o_xFlag_Accing:=FALSE;
	o_xFlag_Decing:=FALSE;
	o_xFlag_Stoping:=FALSE;
	o_xFlag_FastStoping:=FALSE;
	o_xFlag_EStoping:=FALSE;
	(*o_xFlag_GotoInking:=FALSE;*)
	o_xTensionNotFinish:=FALSE;
	o_xToPrintVelTooHigh:=FALSE;
	lrFinalVelocity:=0;
	o_rFinalVelocity:=0;
	byChangVelSts:=0;
	byPreChangVelSts:=0;
	xIamRdy:=FALSE;(*2022.5.28.234611*)
	fbTon_PreStart(IN:=FALSE);
	IF NOT i_xEn THEN
		o_iIdGSE:=GSE_UNKNOWN;
		o_xFlag_Estop:=FALSE;
		o_xFlag_Stop:=FALSE;
		o_xFlag_Tension:=FALSE;
	END_IF
END_IF


i_pxFlag_ArrivedToTargetVel^:=xFlag_ArrivedToTarVel;
i_pxFlag_KeepAlarming^:=xFlag_KeepAlarming;

(*输出以前逻辑所需要的状态*)
o_iIdGSE:=GSE_UNKNOWN;
IF o_xFlag_Estop THEN
	o_iIdGSE:=GSE_ESTOP;
ELSIF o_xFlag_Stop THEN
	o_iIdGSE:=GSE_STOP;
ELSIF o_xFlag_Accing THEN
	o_iIdGSE:=GSE_ACCING;
ELSIF o_xFlag_Decing THEN
	o_iIdGSE:=GSE_DECING;
ELSIF o_xFlag_Ink THEN
	o_iIdGSE:=GSE_INK;
ELSIF o_xFlag_Print THEN
	o_iIdGSE:=GSE_PRINT;
ELSIF o_xFlag_PreStart THEN
	o_iIdGSE:=GSE_PRESTART;
ELSIF o_xFlag_PreStart_Print THEN
	o_iIdGSE:=GSE_PRINT_PRESTART;
ELSIF o_xFlag_Tension THEN
	o_iIdGSE:=GSE_KEEP_TENSION;
END_IF