(*@CES
Name=KS_FB_AutoMaticCut_Uw
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=9df4daa9-6361-492f-aba7-7ffcd7d39a34
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_AutoMaticCut_Uw
(*自动接料被取消后就只能手动接料准备了|
弧面状态下在加减速时候不能接料*)
(*2024.02.23.115214 增加自动接料提前提示*)
VAR_INPUT
	i_xFlag_CanAutoMaticCut:BOOL;(*允许自动裁切标志|*)
	i_xAutoMaticCutEn:BOOL;(*2022.4.14.102015|全自动接料使能*)
	i_byAutoMaticCutMode:BYTE;(*放料自动裁切模式|0 按照剩余米数
											    |1 按照剩余卷径*)
	i_uiAutoMaticCutMeters: UINT;(*自动裁切米数|m*)
	i_uiAutoMaticCutDia: UINT;(*自动裁切卷径|*)
	i_xCutUseReflectionSensor:BOOL;(*使用弧面检测|在进行使用弧面检测的时候 必须保证在稳速情况下*)
	i_xEvenning:BOOL;(*匀速中标志*)
	i_xFlag_Precutting:BOOL;(*接料准备中*)
	i_xCutEnd:BOOL;(*裁切完成标志|放料-一个周期*)
	i_xPreDrvDone:BOOL;(*预驱完成|*)
	i_xCutHolderFallDone:BOOL;(*大臂下到位了*)
	i_rVel_Cur:REAL;(*当前速度|m/min*)
	i_rDia_Cur:REAL;(*当前卷径|mm*)
	i_rDia_Paper:REAL;(*纸筒直径|mm*)
	i_rFilmThickNess:REAL;(*料膜厚度|mm*)
	i_xEnCodeFailed:BOOL;(*编码器发生故障的时候取消自动接料*)
	i_prActRemainFilmLenth:POINTER TO REAL;(*实际剩余的米数*)
	i_iCutTotalTime:INT;(*裁切耗费的时间|MS*)
	(*2024.02.23.112857 修改注释 实际代表当前卷径小于该值的时候可以开始预取*)
	i_iDiam_TowerMove:REAL;(*放料翻转架运动卷径|mm 2022.6.8.161149*)
	(*2024.02.23.112945 提前提示-防止意外*)
	i_iAdvanceTipsDeltaDiam:INT;(*接料准备提前提示的卷径变化值@相对于接料开始卷径|mm*)
END_VAR
VAR_OUTPUT
	o_xAutoMaticCutTrig_Precut:BOOL;(*自动裁切触发沿|只有效一个周期|接料准备*)
	o_xAutoMaticCutTrig_CutCancel:BOOL;(*自动裁切触发沿|只有效一个周期|接料取消*)
	o_xAutoMaticCutTrig_Cut:BOOL;(*自动裁切触发沿|只有效一个周期|接料*)
	o_xFlag_AutoMaticCutting:BOOL;(*自动裁切中标志*)
	o_xFlag_AutoMaticPreCuting:BOOL;(*自动裁切准备中标志*)
	o_xFlag_AutoMaticCutDone:BOOL;(*自动裁切完成*)
	o_xLampAutoMaticCutting:BOOL;(*自动接料指示灯*)
	o_rRemainFilmLenth:REAL;(*剩余的米数值*)
	o_rRemainDia_Cur:REAL;(*剩余的卷径值|mm*)
	o_rRemainValue_CurType:REAL;(*当前模式下剩余的值*)
	o_xWillAutoMaticPreCut:BOOL;(*2024.02.23.113428 即将自动接料@自动接料开始的时候清除*)
END_VAR
VAR
	xFlag_CanAutoMaticCut: BOOL;(*允许自动裁切标志|*)
	xAutoMaticCutEn:BOOL;(*全自动接料使能*)
	byAutoMaticCutMode:BYTE;  (*自动裁切模式|0 按照剩余米数
										    |1 按照当前剩余卷径*)

	afbTrig:ARRAY [1..3] OF R_TRIG;
	byTime_TowerOneTurn: BYTE:=1;(*翻转架翻转一圈的时间|min-*)
	rDeltaFilmLenth: REAL;(*翻转架转动的最大料长变化*)

	fbLampTon: TON;(*指示灯闪烁计时器*)
	xFlag_NeedCutCancel:BOOL;(*需要接料解除*)

	rRemainFilmLenth:REAL;(*剩余的米数|m*)
	rNeedRemainFilmLenthWhenCutAccordDia: REAL;(*根据卷径接料时候需要剩余的料长*)
	iCycleCnt: INT;
	rTemp: REAL;
	rActRemainFilmLenth: REAL:=0.0;
	uiLastAutoMaticCutMeters: UINT:=65535;(*开机赋值为特殊值*)
	rFilmThickNess: REAL;
	fbTon: TON;
	xNeedTimeCntWhenCut: BOOL;(*接料后启动计时*)
	StsPrecutting: BOOL;(*获取的接料准备状态|*)
	xWaitQuit_StsPreCut: BOOL;(*裁切后收料等待退出接料准备状态*)
	rDeltaFilmLenthWhenCut: REAL;(*接料消耗的料长|M*)
	xCanAutoPreCut: BOOL;(*可以自动接料标志*)
END_VAR
{IMPLEMENTATION}
xFlag_CanAutoMaticCut:=i_xFlag_CanAutoMaticCut;
xAutoMaticCutEn:=i_xAutoMaticCutEn;
byAutoMaticCutMode:=i_byAutoMaticCutMode;
rFilmThickNess:=i_rFilmThickNess;


o_xAutoMaticCutTrig_Precut:=FALSE;
o_xAutoMaticCutTrig_CutCancel:=FALSE;
o_xAutoMaticCutTrig_cut:=FALSE;
IF i_prActRemainFilmLenth<>0 THEN
	rActRemainFilmLenth:=i_prActRemainFilmLenth^;
END_IF

(*处理界面实际米数值*)
IF uiLastAutoMaticCutMeters<>65535 AND rActRemainFilmLenth<>0 THEN
	IF i_uiAutoMaticCutMeters <> uiLastAutoMaticCutMeters THEN
		rActRemainFilmLenth:=rActRemainFilmLenth+(UINT_TO_REAL(i_uiAutoMaticCutMeters)-uiLastAutoMaticCutMeters);
		IF rActRemainFilmLenth=0 THEN
			rActRemainFilmLenth:=0.01;(*为了保证条件rActRemainFilmLenth<>0 成立*)
		END_IF
	END_IF
END_IF
uiLastAutoMaticCutMeters:=i_uiAutoMaticCutMeters;


(*计算接料准备提前时间|翻转架时间按照60s/R*)
(*先计算这段时间的长度变化|*)
rDeltaFilmLenth:=i_rVel_Cur*byTime_TowerOneTurn;(*M*)
IF i_rDia_Cur<=i_iDiam_TowerMove THEN
	xCanAutoPreCut:=TRUE;
END_IF
(*计算接料时候损耗的料长*)
rDeltaFilmLenthWhenCut:=i_rVel_Cur/60*i_iCutTotalTime/1000;(*m*)
(*当前剩余米数|M*)
rRemainFilmLenth:=
			KS_GetFilmLenthByCurDia(i_rDia_Cur, i_rDia_Paper, rFilmThickNess);
(*使用卷径方式下需要剩余的米数|用于判断接料准备的时机*)
rNeedRemainFilmLenthWhenCutAccordDia:=
			KS_GetFilmLenthByCurDia(UINT_TO_REAL(i_uiAutoMaticCutDia), i_rDia_Paper, rFilmThickNess);


IF xFlag_CanAutoMaticCut THEN
	IF xAutoMaticCutEn THEN(*自动接料使能*)
		o_xFlag_AutoMaticCutting:=TRUE;
	END_IF
END_IF


(*2024.02.23.113452+*)
IF i_iAdvanceTipsDeltaDiam<>0 THEN
	IF i_rDia_Cur<=i_iDiam_TowerMove+i_iAdvanceTipsDeltaDiam THEN
		o_xWillAutoMaticPreCut:=TRUE;
	END_IF

	IF o_xWillAutoMaticPreCut THEN
		IF xCanAutoPreCut OR(*已经自动接料的时候清除提示*)
			NOT o_xFlag_AutoMaticCutting THEN(*没有打开自动接料*)
			o_xWillAutoMaticPreCut:=FALSE;
		END_IF
	END_IF
ELSE
	o_xWillAutoMaticPreCut:=FALSE;
END_IF


(*裁切完成后10s不允许自动接料*)
(*裁切完成后清除一些标志*)
IF  i_xCutEnd THEN
	xNeedTimeCntWhenCut:=TRUE;
	(*清除标志*)
	o_xFlag_AutoMaticPreCuting:=FALSE;
	o_xFlag_AutoMaticCutDone:=FALSE;
	xFlag_NeedCutCancel:=FALSE;
	afbTrig[1](CLK:=FALSE);
	afbTrig[2](CLK:=FALSE);
	afbTrig[3](CLK:=FALSE);
	iCycleCnt:=0;
	xWaitQuit_StsPreCut:=TRUE;
	xCanAutoPreCut:=FALSE;
	o_xWillAutoMaticPreCut:=FALSE;(*2024.02.23.113624*)
END_IF

(*裁切完成后等待接料准备退出|*)
IF NOT i_xFlag_Precutting AND(*接料准备状态退出了*)
	StsPrecutting THEN
	xWaitQuit_StsPreCut:=FALSE;
END_IF
StsPrecutting:=i_xFlag_Precutting;


fbTon(IN:=xNeedTimeCntWhenCut,PT:=T#10S);
IF fbTon.Q THEN(*时间到*)
	xNeedTimeCntWhenCut:=FALSE;
END_IF

IF NOT xFlag_CanAutoMaticCut OR NOT i_xAutoMaticCutEn  OR(*自动接料不使能*)
	rFilmThickNess=0 OR(*料膜厚度=0 不允许自动接料*)
	xNeedTimeCntWhenCut THEN(*裁切后延时*)
	IF o_xFlag_AutoMaticCutting THEN
		o_xFlag_AutoMaticCutting:=FALSE;
	END_IF
END_IF

(*处于自动接料准备中*)
o_rRemainValue_CurType:=0;
IF o_xFlag_AutoMaticCutting THEN
	CASE byAutoMaticCutMode OF
		1:(*按照剩余卷径自动裁切*)
			IF NOT o_xFlag_AutoMaticPreCuting THEN
				IF (*rNeedRemainFilmLenthWhenCutAccordDia+rDeltaFilmLenth>=rRemainFilmLenth OR*)
					xCanAutoPreCut THEN
				(*剩余的米数<=裁切的剩余卷径换算的米数+翻转架转一圈需要的米数|
				 此时可以允许进入自动接料*)
					IF xWaitQuit_StsPreCut THEN;(*接料后需要等待接料准备状态退出*)
					ELSE
						o_xFlag_AutoMaticPreCuting:=TRUE;
						xCanAutoPreCut:=FALSE;
					END_IF
				END_IF
				iCycleCnt:=0;
			ELSE
				IF i_xFlag_Precutting AND
					i_xPreDrvDone AND i_xCutHolderFallDone AND(*预驱完成了并且大臂到位了|输出接料按钮*)
					NOT o_xFlag_AutoMaticCutDone AND(*放料裁切了*)
					(i_uiAutoMaticCutDia-i_rDia_Cur>=0) THEN(*小于了当前卷径值|持续1s认为到卷径了*)
					IF iCycleCnt>=50 THEN
						o_xFlag_AutoMaticCutDone:=TRUE;
					ELSE
						iCycleCnt:=iCycleCnt+1;
					END_IF
				END_IF
			END_IF
			o_rRemainValue_CurType:=i_rDia_Cur;
	ELSE(*按照剩余米数*)
		IF NOT o_xFlag_AutoMaticPreCuting THEN
			IF (*i_uiAutoMaticCutMeters+rDeltaFilmLenth>=rRemainFilmLenth OR*)
				xCanAutoPreCut THEN
				(*剩余的米数<=裁切的米数+翻转架转一圈需要的米数|
				  此时可以允许进入自动接料*)
				IF xWaitQuit_StsPreCut THEN;(*接料后需要等待接料准备状态退出*)
				ELSE
					o_xFlag_AutoMaticPreCuting:=TRUE;
					xCanAutoPreCut:=FALSE;
				END_IF
			END_IF
		ELSE(*在自动接料准备中*)
			IF i_xFlag_Precutting AND(*接料准备中*)
				i_xPreDrvDone AND i_xCutHolderFallDone AND(*预驱完成了并且大臂到位了|输出接料按钮*)
				NOT o_xFlag_AutoMaticCutDone THEN(*接料未完成*)
				(*使用实际米数进行修正*)
				rTemp:=i_uiAutoMaticCutMeters;
				IF rActRemainFilmLenth<>0 THEN
					rTemp:=UINT_TO_REAL(i_uiAutoMaticCutMeters)*2-rActRemainFilmLenth;
				END_IF
(*2022.6.8.170104 允许出现负值*)
(*
				IF rTemp<=0 THEN(*最小限制0m*)
					rTemp:=0;
				END_IF
*)

(*				IF rTemp+rDeltaFilmLenthWhenCut>=rRemainFilmLenth THEN(*减少到了需要的料长*)*)
				(*2022.6.8.165823 不考虑接料过程的损耗*)
				IF rTemp>=rRemainFilmLenth THEN(*减少到了需要的料长*)
					o_xFlag_AutoMaticCutDone:=TRUE;
				END_IF
			END_IF
		END_IF
		o_rRemainValue_CurType:=rRemainFilmLenth;
	END_CASE

	IF NOT i_xEvenning AND i_xCutUseReflectionSensor THEN(*弧面检测方式下,处于非匀速状态下不能接料*)
		o_xFlag_AutoMaticCutDone:=FALSE;
	END_IF

	IF i_xEnCodeFailed AND
		i_xFlag_Precutting THEN(*实际处于接料准备中*)
		xFlag_NeedCutCancel:=TRUE;(*取消自动接料*)
		o_xFlag_AutoMaticPreCuting:=TRUE;(*置位自动接料准备中标志|保证不会在取消后再次被触发*)
	END_IF

ELSE(*不能自动接料 清除标志*)
	o_xFlag_AutoMaticPreCuting:=FALSE;
	o_xFlag_AutoMaticCutDone:=FALSE;
	xFlag_NeedCutCancel:=FALSE;
	xCanAutoPreCut:=FALSE;
	iCycleCnt:=0;
	(*不自动接料的时候输出剩余米数值*)
	o_rRemainValue_CurType:=0;
(*
	o_rRemainValue_CurType:=rRemainFilmLenth;
*)
	o_xWillAutoMaticPreCut:=FALSE;(*2024.02.23.113649+*)
END_IF

(*输出接料准备按钮和接料按钮|只执行一次*)
afbTrig[1](CLK:=o_xFlag_AutoMaticPreCuting);
IF afbTrig[1].Q THEN
	IF NOT i_xFlag_Precutting THEN
		o_xAutoMaticCutTrig_Precut:=TRUE;
	END_IF
END_IF
afbTrig[2](CLK:=o_xFlag_AutoMaticCutDone);
IF afbTrig[2].Q THEN(*裁切完成后清除相关标志*)
	o_xAutoMaticCutTrig_Cut:=TRUE;(*
	o_xFlag_AutoMaticPreCuting:=FALSE;
	o_xFlag_AutoMaticCutDone:=FALSE;
	xFlag_NeedCutCancel:=FALSE;
	afbTrig[1](CLK:=FALSE);
	afbTrig[2](CLK:=FALSE);*)
END_IF

afbTrig[3](CLK:=xFlag_NeedCutCancel);
IF afbTrig[3].Q THEN(*因为编码器故障需要取消自动接料准备*)
	o_xAutoMaticCutTrig_CutCancel:=TRUE;
END_IF


IF i_prActRemainFilmLenth<>0 THEN
	i_prActRemainFilmLenth^:=rActRemainFilmLenth;
END_IF
o_rRemainFilmLenth:=rRemainFilmLenth;
o_rRemainDia_Cur:=i_rDia_Cur;



fbLampTon(IN:=o_xFlag_AutoMaticCutting,PT:=T#300MS);(*300MS指示灯闪烁*)
IF fbLampTon.Q THEN
	fbLampTon(IN:=FALSE);
	o_xLampAutoMaticCutting:=NOT o_xLampAutoMaticCutting;
END_IF
IF NOT o_xFlag_AutoMaticCutting THEN
	o_xLampAutoMaticCutting:=FALSE;
END_IF