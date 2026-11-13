(*@CES
Name=KS_FB_Exchange
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=72852f5d-8de1-4e86-9ad2-e4d3bdb444a6
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_Exchange
VAR_INPUT
	i_xCut_end: BOOL;	
END_VAR
VAR_OUTPUT
END_VAR
VAR
	lrPreDia: LREAL;
	lrVel_Temp: LREAL;
	PI: LREAL:=3.1415926;
	xParamExchanged: BOOL;
END_VAR
VAR_IN_OUT
	io_rDiam_Cur: REAL;(*当前卷径*)
	io_rDiam_New: REAL;(*新卷径，单位是mm*)
	io_rVel_UwRw: REAL;(* 当前速度*)
	io_rVel_PreDrv: REAL;(*预驱速度*)

END_VAR
{IMPLEMENTATION}
(*该功能块在裁切换料完成之后进行预驱以及当前轴的卷径切换*
*同时要放在收放料裁切换料标志清零之前 *)(*当前速度的单位是R/MIN 预驱的速度单位是M/MIN*)

IF i_xCut_end AND NOT xParamExchanged THEN(*裁切完成后进行卷径，速度切换*)

	lrVel_Temp:=io_rVel_UwRw*io_rDiam_Cur*PI/1000;	(*将输入的当前速度转换为预驱速度 M/MIN*)
	io_rVel_UwRw:=io_rVel_PreDrv/io_rDiam_New/PI*1000;(*将预驱线速度转换为角速度R/MIN赋值给当前速度*)
	io_rVel_PreDrv:=lrVel_Temp;

(*将新卷径值赋给当前卷径值，将当前卷径值赋给新卷径值*)
	lrPreDia:=io_rDiam_Cur;
	io_rDiam_Cur:=io_rDiam_New;
	io_rDiam_New:=lrPreDia;
	xParamExchanged:=TRUE;
ELSIF NOT i_xCut_end THEN
	lrPreDia:=io_rDiam_New;
	xParamExchanged:=FALSE;
END_IF