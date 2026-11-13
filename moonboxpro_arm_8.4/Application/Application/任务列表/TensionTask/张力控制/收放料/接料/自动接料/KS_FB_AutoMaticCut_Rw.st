(*@CES
Name=KS_FB_AutoMaticCut_Rw
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=038de2ec-c845-4e0f-ae6f-7ee3d5147bf3
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_AutoMaticCut_Rw
(*自动接料被取消后就只能手动接料准备了*)
(*2023.3.11.180211 接料后退出接料准备状态的条件修改为大臂下压延时时间后*)
(*2023.12.27.162745增加放料裁切后，统计收料接料后整机料长米数-并自动写入到整机料长参数中@该功能有效时不执行自动接料*)
(*2024.02.23.115214 增加自动接料提前提示*)
(*2024.02.24.100539 计米提前报警增加了几个条件|之前不太完善*)
VAR_INPUT
	i_xFlag_CanAutoMaticCut:BOOL;(*允许自动裁切标志|*)
	i_xAutoMaticCutEn:BOOL;(*2022.4.14.102015|全自动接料使能*)
	i_byAutoMaticCutMode:BYTE;(*自动裁切模式|0 按照计米长度-在上次接料完成后启动
									        |1 按照放料裁切后整机长度-在放料接料完成后启动
										    |2 按照当前卷径-在上次接料完成后启动-这种方式先不做*)
	i_uiAutoMaticCutMeters: UINT;(*自动裁切米数|m*)
	i_uiAutoMaticCutDia_Rw: UINT;(*自动裁切卷径|*)
(*2023.12.27.163031@修改为输入输出型*)
(*
	i_byLenth_Machine: BYTE;(*整机长度|m*)
*)	

	i_xFlag_Precutting_Uw:BOOL;(*接料准备中*)
	i_xCutEnd_Uw:BOOL;(*裁切完成标志|放料-一个周期*)
	i_xFlag_Precutting_Rw:BOOL;(*接料准备中*)
	i_xCutEnd_Rw:BOOL;(*裁切完成标志|收料-一个周期*)
	i_xPreDrvDone_Rw:BOOL;(*收料预驱完成|*)
	i_xCutHolderFallDone_Rw:BOOL;(*收料大臂下到位了*)
	i_rVel_Cur:REAL;(*当前速度|m/min*)
	i_rDia_Cur:REAL;(*当前卷径|mm*)
	i_lrTotalPrnLenth:LREAL;(*印刷的总计长|m*)
	i_xEnCodeFailed:BOOL;(*编码器发生故障的时候取消自动接料*)
	i_iCutTotalTime:INT;(*裁切耗费的时间|MS*)
	i_uiTimeCutHolderDne_ms:UINT;(*大臂下的时间@ms*)
	i_xWillAutoMaticPreCut_Uw:BOOL;(*2024.02.23.122832|放料即将自动接料*)
	i_iAdvanceTipsDeltaMeters:INT;(*2024.02.23.122914 距离最终米数提前提示的米数@m*)
END_VAR
VAR_OUTPUT
	o_xAutoMaticCutTrig_Precut:BOOL;(*自动裁切触发沿|只有效一个周期|接料准备*)
	o_xAutoMaticCutTrig_CutCancel:BOOL;(*自动裁切触发沿|只有效一个周期|接料取消*)
	o_xAutoMaticCutTrig_Cut:BOOL;(*自动裁切触发沿|只有效一个周期|接料*)
	o_xFlag_AutoMaticCutting:BOOL;(*自动裁切中标志*)
	o_xFlag_AutoMaticPreCuting:BOOL;(*自动裁切准备中标志*)
	o_xFlag_AutoMaticCutDone:BOOL;(*自动裁切完成*)
	o_byFlag_AutoMaticCutting: BYTE;(*3种模式自动接料条件|.0 第零种
													   .1 第一种
													   .2 第二种*)
	o_xLampAutoMaticCutting:BOOL;(*自动接料指示灯*)


	o_rLenth_CurType:REAL;(*当前自动裁切方式下的计米值*)
	o_xWillAutoMaticPreCut:BOOL;(*2024.02.23.113428 即将自动接料*)
END_VAR
VAR_IN_OUT
	(*2023.12.27.163135*)
	io_xGetLenthMachine:BOOL;
	io_byLenth_Machine: BYTE;(*整机长度|m*)
END_VAR
VAR
	xFlag_CanAutoMaticCut: BOOL;(*允许自动裁切标志|*)
	xAutoMaticCutEn:BOOL;(*全自动接料使能*)
	byAutoMaticCutMode:BYTE;  (*自动裁切模式|0 按照计米长度-在上次接料完成后启动
									        |1 按照放料裁切后整机长度-在放料接料完成后启动
										    |2 按照当前卷径-在上次接料完成后启动*)
	rLenthWhenCut_Uw: REAL;(*放料裁切后计长*)
	lrLastTotalPrnLenthWhenCut_Uw: LREAL;(*上个周期总印刷长度|*)
	rPrnLenthWhenCut_Rw: REAL;
	lrLastTotalPrnLenthWhenCut_Rw: LREAL;(*上个周期总印刷长度|*)
	afbTrig:ARRAY [1..3] OF R_TRIG;
	byTime_TowerOneTurn: BYTE:=1;(*翻转架翻转一圈的时间|min-*)
	rDeltaFilmLenth: REAL;(*翻转架转动的最大料长变化*)
	fbLampTon: TON;(*指示灯闪烁计时器*)
	xFlag_NeedCutCancel:BOOL;(*需要接料解除*)
(*	StsPrecutting_Rw: BOOL;(*获取的接料准备状态|收料*)*)
	xWaitQuit_StsPreCut: BOOL;(*裁切后收料等待退出接料准备状态*)
	rDeltaFilmLenthWhenCut: REAL;(*接料消耗的料长|M*)
	fbWaitQuit_StsPrecut: TON;(*2023.3.11.180046 等待退出接料准备计时*)
	byLenth_Machine: BYTE;(*2023.12.27.163203*)
	xGetLenthMachineEn: BOOL;(*获取机器长度使能@用于启动计米*)
END_VAR

{IMPLEMENTATION}
xFlag_CanAutoMaticCut:=i_xFlag_CanAutoMaticCut;
xAutoMaticCutEn:=i_xAutoMaticCutEn;
byAutoMaticCutMode:=i_byAutoMaticCutMode;
o_xAutoMaticCutTrig_Precut:=FALSE;
o_xAutoMaticCutTrig_CutCancel:=FALSE;
o_xAutoMaticCutTrig_cut:=FALSE;
o_rLenth_CurType:=0;


(*2023.12.27.162908*)
IF io_xGetLenthMachine THEN
	xAutoMaticCutEn:=FALSE;(*强制关闭使能@下面逻辑会计算长度值*)
	xFlag_CanAutoMaticCut:=FALSE;
	IF i_xCutEnd_Uw THEN(*放料裁切完成*)
		xGetLenthMachineEn:=TRUE;(*启动计米测试*)
	END_IF

	IF i_xCutEnd_Rw AND xGetLenthMachineEn THEN(*收料裁切的时候写入*)
		io_byLenth_Machine:=REAL_TO_BYTE(rLenthWhenCut_Uw);
		io_xGetLenthMachine:=FALSE;(*写入的时候清除*)
		xGetLenthMachineEn:=FALSE;(*计米结束*)
	END_IF
	o_rLenth_CurType:=rLenthWhenCut_Uw;
ELSE
	xGetLenthMachineEn:=FALSE;
END_IF
byLenth_Machine:=io_byLenth_Machine;(*2023.12.27.163220*)



(*计算接料准备提前时间|翻转架时间按照60s/R*)
(*先计算这段时间的长度变化|*)
rDeltaFilmLenth:=i_rVel_Cur*byTime_TowerOneTurn;(*M*)

(*计算接料时候损耗的料长*)
rDeltaFilmLenthWhenCut:=i_rVel_Cur/60*i_iCutTotalTime/1000;(*m*)


(*写在条件外围可以保证随时切换进入自动接料动作，就可以有必要的数据执行动作*)
(*检查3中模式进入自动接料的条件是否满足*)
IF i_xCutEnd_Uw THEN(*放料裁切完成*)
	rLenthWhenCut_Uw:=0;
	lrLastTotalPrnLenthWhenCut_Uw:= LREAL_TO_REAL(i_lrTotalPrnLenth);
	o_byFlag_AutoMaticCutting.1:=TRUE;(*第一种方式有效了*)

END_IF
(*按照放料裁切后整机长度|*)
IF o_byFlag_AutoMaticCutting.1 OR(*可以按照这种方式计算并启动接料了*)
	xGetLenthMachineEn THEN(*计米测试@2023.12.27.170400*)
	IF i_lrTotalPrnLenth-lrLastTotalPrnLenthWhenCut_Uw>=0 THEN
		rLenthWhenCut_Uw:= LREAL_TO_REAL(rLenthWhenCut_Uw+i_lrTotalPrnLenth-lrLastTotalPrnLenthWhenCut_Uw);
	END_IF
ELSE
	rLenthWhenCut_Uw:=0;
END_IF
lrLastTotalPrnLenthWhenCut_Uw:= LREAL_TO_REAL(i_lrTotalPrnLenth);(*更新last值*)

IF i_xCutEnd_Rw THEN(*收料裁切完成*)
	rPrnLenthWhenCut_Rw:=0;
	lrLastTotalPrnLenthWhenCut_Rw:= LREAL_TO_REAL(i_lrTotalPrnLenth);
	o_byFlag_AutoMaticCutting.0:=TRUE;(*第零种方式有效了*)
	o_byFlag_AutoMaticCutting.2:=TRUE;(*第二种方式有效了*)

	(*裁切完成了 清除一些标志*)
	o_xFlag_AutoMaticPreCuting:=FALSE;
	o_xFlag_AutoMaticCutDone:=FALSE;
	xFlag_NeedCutCancel:=FALSE;
	afbTrig[1](CLK:=FALSE);
	afbTrig[2](CLK:=FALSE);
	afbTrig[3](CLK:=FALSE);
	o_byFlag_AutoMaticCutting.1:=FALSE;(*第一种方式标志复位*)
	xWaitQuit_StsPreCut:=TRUE;
	o_xWillAutoMaticPreCut:=FALSE;
END_IF

(*裁切完成后等待接料准备退出|*)
(*
IF NOT i_xFlag_Precutting_Rw AND(*接料准备状态退出了*)
	StsPrecutting_Rw THEN
	xWaitQuit_StsPreCut:=FALSE;
END_IF
StsPrecutting_Rw:=i_xFlag_Precutting_Rw;
*)
(*2023.3.11.175740 等待退出接料准备的方式修改为延时处理
时间=大臂下的时间*)

IF i_uiTimeCutHolderDne_ms=0 THEN
	i_uiTimeCutHolderDne_ms:=3000;
END_IF
fbWaitQuit_StsPrecut(IN:=xWaitQuit_StsPreCut,PT:=UINT_TO_TIME(i_uiTimeCutHolderDne_ms));
IF fbWaitQuit_StsPrecut.Q THEN(*延时到了*)
	xWaitQuit_StsPreCut:=FALSE;
END_IF

(*按照计米长度*)
IF o_byFlag_AutoMaticCutting.0 THEN
	IF i_lrTotalPrnLenth-lrLastTotalPrnLenthWhenCut_Rw>=0 THEN
		rPrnLenthWhenCut_Rw:= LREAL_TO_REAL(rPrnLenthWhenCut_Rw+i_lrTotalPrnLenth-lrLastTotalPrnLenthWhenCut_Rw);
	END_IF
END_IF
lrLastTotalPrnLenthWhenCut_Rw:=i_lrTotalPrnLenth;

IF xFlag_CanAutoMaticCut THEN
	IF xAutoMaticCutEn THEN(*自动接料使能*)
		CASE byAutoMaticCutMode OF
			1:(*按照放料裁切后整机长度-在放料接料完成后启动*)
				o_xFlag_AutoMaticCutting:=i_xFlag_Precutting_Uw OR (*放料处于接料准备中|输出自动接料准备中标志*)
									o_byFlag_AutoMaticCutting.1;(**)
			2:(*按照当前卷径-在上次接料完成后启动-这种方式先不做*);
		ELSE(*按照计米长度-在上次接料完成后启动*)
			o_xFlag_AutoMaticCutting:=o_byFlag_AutoMaticCutting.0;(*收料处于接料准备中|输出自动接料准备中标志*)
		END_CASE
	END_IF
END_IF

IF NOT xFlag_CanAutoMaticCut OR NOT i_xAutoMaticCutEn  THEN(*自动接料不使能*)
	IF o_xFlag_AutoMaticCutting THEN
		o_xFlag_AutoMaticCutting:=FALSE;
	END_IF
END_IF

(*2024.02.23.122941+提前提示处理*)
IF xFlag_CanAutoMaticCut AND  xAutoMaticCutEn THEN(*自动接料开关都打开了@条件也满足了*)
	IF byAutoMaticCutMode=1 THEN(*按照放料裁切后整机长度-在放料接料完成后启动*)
		IF i_xWillAutoMaticPreCut_Uw THEN(*放料没开自动接料时,收料等整机料长方式下的提示还没想好怎么处理*)
			o_xWillAutoMaticPreCut:=TRUE;
		ELSE
			o_xWillAutoMaticPreCut:=FALSE;
		END_IF
	ELSIF byAutoMaticCutMode=2 THEN(*按照当前卷径-在上次接料完成后启动-这种方式先不做*)
		o_xWillAutoMaticPreCut:=FALSE;
	ELSE(*按照计米长度-在上次接料完成后启动*)
		IF o_xFlag_AutoMaticCutting THEN(*没开始就先不提示*)
			IF i_iAdvanceTipsDeltaMeters<>0 THEN(*缺少点条件@2024.02.24.100327*)
				IF i_iAdvanceTipsDeltaMeters<i_uiAutoMaticCutMeters THEN(*缺少点条件@2024.02.24.100327*)
					IF rPrnLenthWhenCut_Rw+rDeltaFilmLenth>=UINT_TO_INT(i_uiAutoMaticCutMeters)-i_iAdvanceTipsDeltaMeters THEN
						o_xWillAutoMaticPreCut:=TRUE;
					ELSE
						o_xWillAutoMaticPreCut:=FALSE;
					END_IF
				ELSE
					o_xWillAutoMaticPreCut:=FALSE;
				END_IF
			ELSE
				o_xWillAutoMaticPreCut:=FALSE;
			END_IF
		ELSE
			o_xWillAutoMaticPreCut:=FALSE;
		END_IF
	END_IF
ELSE
	o_xWillAutoMaticPreCut:=FALSE;
END_IF


(*处于自动接料准备中*)
IF o_xFlag_AutoMaticCutting THEN
	CASE byAutoMaticCutMode OF
		1:(*按照放料裁切后整机长度-在放料接料完成后启动*)
			IF NOT o_xFlag_AutoMaticPreCuting THEN
				IF xWaitQuit_StsPreCut THEN;(*接料后需要等待接料准备状态退出*)
				ELSE
					o_xFlag_AutoMaticPreCuting:=TRUE;
				END_IF
			ELSE
				IF i_xFlag_Precutting_rw AND
					i_xPreDrvDone_Rw AND i_xCutHolderFallDone_Rw AND(*预驱完成了并且大臂到位了|输出接料按钮*)
					NOT o_xFlag_AutoMaticCutDone AND (*没有自动接料完成*)
					o_byFlag_AutoMaticCutting.1 AND(*放料裁切了*)
					(rLenthWhenCut_Uw-BYTE_TO_REAL(byLenth_Machine)>=0) THEN(*超过了一个机身长度*)
					o_xFlag_AutoMaticCutDone:=TRUE;
				END_IF
			END_IF
			o_rLenth_CurType:=rLenthWhenCut_Uw;
		2:(*按照当前卷径-在上次接料完成后启动-这种方式先不做*);
	ELSE(*按照计米长度-在上次接料完成后启动*)
		IF NOT o_xFlag_AutoMaticPreCuting THEN
			IF i_uiAutoMaticCutMeters-rPrnLenthWhenCut_Rw<=rDeltaFilmLenth THEN(*收料的米数接近需要的米数时-启动接料准备*)
				IF xWaitQuit_StsPreCut THEN;(*接料后需要等待接料准备状态退出*)
				ELSE
					o_xFlag_AutoMaticPreCuting:=TRUE;
				END_IF
			END_IF
		ELSE(*在自动接料准备中*)
			IF i_xFlag_Precutting_Rw AND(*接料准备中*)
				i_xPreDrvDone_Rw AND i_xCutHolderFallDone_Rw AND(*预驱完成了并且大臂到位了|输出接料按钮*)
				NOT o_xFlag_AutoMaticCutDone THEN(*接料未完成*)
				IF rPrnLenthWhenCut_Rw>=i_uiAutoMaticCutMeters-rDeltaFilmLenthWhenCut THEN(*超过需要的料长-接料消耗的*)
					o_xFlag_AutoMaticCutDone:=TRUE;
				END_IF
			END_IF
		END_IF
		o_rLenth_CurType:=rPrnLenthWhenCut_Rw;
	END_CASE


	IF i_xEnCodeFailed AND
		i_xFlag_Precutting_Rw THEN(*实际处于接料准备中*)
		xFlag_NeedCutCancel:=TRUE;(*取消自动接料*)
		o_xFlag_AutoMaticPreCuting:=TRUE;(*置位自动接料准备中标志|保证不会在取消后再次被触发*)
	END_IF

ELSE(*不能自动接料 清除标志*)
	o_xFlag_AutoMaticPreCuting:=FALSE;
	o_xFlag_AutoMaticCutDone:=FALSE;
	xFlag_NeedCutCancel:=FALSE;
	o_byFlag_AutoMaticCutting.1:=FALSE;(*只清除放料接料后使能标志*)
	(*不自动接料的时候输出接料后的计米值*)
	IF xGetLenthMachineEn THEN;(*测试长度的时候不清除@2023.12.27.174554*)
	ELSE
		o_rLenth_CurType:=0;
	END_IF

	(*2024.02.23.163128+*)
	IF byAutoMaticCutMode=1 THEN;(*整机料长时,根据放料提示输出控制输出*)
	ELSE(**)
		o_xWillAutoMaticPreCut:=FALSE;
	END_IF
(*	o_rLenth_CurType:=rPrnLenthWhenCut_Rw;*)
END_IF

(*输出接料准备按钮和接料按钮|只执行一次*)
afbTrig[1](CLK:=o_xFlag_AutoMaticPreCuting);
IF afbTrig[1].Q THEN
	IF NOT i_xFlag_Precutting_Rw THEN
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
	afbTrig[2](CLK:=FALSE);
	o_byFlag_AutoMaticCutting:=0;*)
END_IF

afbTrig[3](CLK:=xFlag_NeedCutCancel);
IF afbTrig[3].Q THEN(*因为编码器故障需要取消自动接料准备*)
	o_xAutoMaticCutTrig_CutCancel:=TRUE;
END_IF



fbLampTon(IN:=o_xFlag_AutoMaticCutting,PT:=T#300MS);(*300MS指示灯闪烁*)
IF fbLampTon.Q THEN
	fbLampTon(IN:=FALSE);
	o_xLampAutoMaticCutting:=NOT o_xLampAutoMaticCutting;
END_IF
IF NOT o_xFlag_AutoMaticCutting THEN
	o_xLampAutoMaticCutting:=FALSE;
END_IF