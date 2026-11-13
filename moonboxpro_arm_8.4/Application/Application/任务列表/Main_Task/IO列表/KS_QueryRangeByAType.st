(*@CES
Name=KS_QueryRangeByAType
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=eff421d0-eb21-45f6-be1b-43a1b515e8bd
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_QueryRangeByAType : INT
VAR_INPUT
	i_byType_AnglogIO: BYTE; (* 1:0~10v; 2:4~20mA; 3:-5~5v; 4:0~5v; 5:0~20mA/ 0:-10v~10v(默认)*)
	i_plrRange_Min: POINTER TO LREAL;
	i_plrRange_Max: POINTER TO LREAL;
	i_pdiRange_Min: POINTER TO DINT;
	i_pdiRange_Max: POINTER TO DINT;
END_VAR
VAR
	lrN_min: LREAL;
	lrN_max: LREAL;
	diN_min: DINT;
	diN_max: DINT;
END_VAR
{IMPLEMENTATION}
CASE i_byType_AnglogIO OF
1:(*0~10v|*)
	lrN_min:= 0;
	lrN_max:= 10;
	diN_min:= 0;
	diN_max:= 32767;
2:(*4~20mA|*)
	lrN_min:= 4;
	lrN_max:= 20;
	diN_min:= 6553(*0*); (* 修复xie.gc测试lel时期更新的问题|@2020.12.19.101658 *)
	diN_max:= 32767;

3:(*-5~5v|*)
	lrN_min:= -5;
	lrN_max:= 5;
	diN_min:= -32767;
	diN_max:= 32767;
4:(*0~5v|*)
	lrN_min:= 0;
	lrN_max:= 5;
	diN_min:= 0;
	diN_max:= 32767;
5:(*0~20mA|*)
	lrN_min:= 0;
	lrN_max:= 20;
	diN_min:= 0;
	diN_max:= 32767;
ELSE(*所有默认就当正负10v处理|*)
	lrN_min:= -10;
	lrN_max:= 10;
	diN_min:= -32767;
	diN_max:= 32767;
END_CASE

IF i_plrRange_Min<>0 THEN
	i_plrRange_Min^:= lrN_min;
END_IF
IF i_plrRange_Max<>0 THEN
	i_plrRange_Max^:= lrN_max;
END_IF
IF i_pdiRange_Min<>0 THEN
	i_pdiRange_Min^:= diN_min;
END_IF
IF i_pdiRange_Max<>0 THEN
	i_pdiRange_Max^:= diN_max;
END_IF

KS_QueryRangeByAType:= 0;