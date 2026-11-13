(*@CES
Name=KS_SIG_SIN
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=c56967f0-af3c-4951-929b-0432ccffd3b8
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_SIG_SIN : BOOL
(*正弦信号*)
VAR_INPUT
	i_xEn:BOOL;(*使能*)
	i_rFreq:REAL;(*频率@hz*)
	i_rAmplitude:REAL;(*幅值*)
	i_uiTotalTime:UINT;(*输出的总时间|=0 代表一直输出@s*)
	i_iCycleTime_Plc:INT;(*程序时间@ms*)
	i_pxOuting:POINTER TO BOOL;(*输出中@如果取消使能,停止到0时结束*)
	i_plrX:POINTER TO LREAL;(*X轴的值*)
	i_prResult:POINTER TO REAL;(*结果值*)
END_VAR
VAR
	xOuting:BOOL;
	lrX:LREAL;(*x值*)
	rResult: REAL;
	lrW:LREAL;(*角速度@rad/s*)
	lrpi: LREAL := 3.1415926;(*圆周率*)
	lrTs: LREAL;(*周期@s*)
	lrTmp: LREAL;
	lrTotalTime:LREAL;(*输出的总时间@ms*)
	xStopOuting: BOOL;
END_VAR
{IMPLEMENTATION}
IF i_rFreq<>0 AND i_rAmplitude<>0 AND i_iCycleTime_Plc<>0 THEN;
ELSE
	RETURN;
END_IF

IF i_pxOuting<>0 THEN
	xOuting:=i_pxOuting^;
END_IF
IF i_plrX<>0 THEN
	lrX:=i_plrX^;
END_IF
IF i_prResult<>0 THEN
	rResult:=i_prResult^;
END_IF

(*使能*)
IF i_xEn THEN
	IF NOT xOuting AND
		lrX = 0 THEN(*lrx用来控制区分是使能取消还是输出完成使用@取消使能才清零*)
		xOuting:=TRUE;
		lrX:=0;(*从0开始*)
	END_IF
END_IF

lrW:=2*lrpi*i_rFreq;(*rad/s*)
lrTs:=1/i_rFreq;(*周期@s*)
lrTotalTime:=UINT_TO_LREAL(i_uiTotalTime)*1000;
IF xOuting THEN
	lrTmp:=lrX / 1000.0;(*s*)
(*
	IF lrTmp>lrTs THEN(*过周期@拉回到一个周期内防止溢出*)
		lrTmp:=lrTmp-lrTs;
	END_IF
*)
	rResult:=LREAL_TO_REAL(i_rAmplitude*SIN(lrW*lrTmp));

	(*更新*)
	xStopOuting:=FALSE;
	IF lrTotalTime<>0 THEN
		IF lrX>=lrTotalTime THEN(*超过了输出的时间*)
			xStopOuting:=TRUE;(*停止输出了*)
		END_IF
	ELSE(*一直输出*);
	END_IF

	lrX:=lrX + i_iCycleTime_Plc;(*ms@也是有可能溢出的|按照pt的经验 先不考虑*)

	IF NOT i_xEn OR xStopOuting THEN(*停止使能\或者停止输出*)
		IF rResult*i_prResult^<=0 THEN(*过零*)
			xOuting:=FALSE;
			rResult:=0;
		END_IF
	END_IF
ELSE
	(*lrx用来控制区分是使能取消还是输出完成使用@取消使能才清零*)
	IF NOT i_xEn THEN
		lrX:=0;
	END_IF
	rResult:=0;
END_IF

IF i_pxOuting<>0 THEN
	i_pxOuting^:=xOuting;
END_IF
IF i_plrX<>0 THEN
	i_plrX^:=lrX;
END_IF
IF i_prResult<>0 THEN
	i_prResult^:=rResult;
END_IF