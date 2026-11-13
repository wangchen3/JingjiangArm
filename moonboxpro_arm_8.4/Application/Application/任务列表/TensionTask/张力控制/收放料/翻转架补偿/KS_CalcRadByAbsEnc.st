(*@CES
Name=KS_CalcRadByAbsEnc
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=0e1ec2d5-a158-4810-bac7-8538ad8533d7
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_CalcRadByAbsEnc : LREAL(*返回当前弧度|需要标定0弧度对应的绝对位置值*)
VAR_INPUT
	i_xDir_Rev:BOOL;(*方向取反|默认翻转架运动和绝对值位置变化方向一致|逆时针转动为正方向。*)
	i_dwAbsPos_0Rad:DWORD;(*0弧度对应的绝对值位置*)
	i_dwAbsPos_Cur:DWORD;(*当前绝对位置*)
	i_dwAbsPos_Cycle:DWORD:=131072;(*编码器线束*)
END_VAR
VAR
	dwTemp:DWORD;
	lrTemp:LREAL;
	dwAbsPos_Cycle:DWORD;
	lrTheta_Cur: LREAL;
END_VAR
{IMPLEMENTATION}
dwAbsPos_Cycle:=i_dwAbsPos_Cycle;
dwTemp:=(i_dwAbsPos_Cur+dwAbsPos_Cycle-i_dwAbsPos_0Rad) MOD (dwAbsPos_Cycle);
IF dwAbsPos_Cycle<>0 THEN
	lrTemp:=2*gc_lrPI/dwAbsPos_Cycle*dwTemp;(*变化的角度*)
END_IF


IF i_xDir_Rev THEN
	lrTemp:=-lrTemp;
END_IF

lrTheta_Cur:=lrTemp;
IF lrTemp>2*gc_lrPI THEN
	lrTheta_Cur:=lrTemp-2*gc_lrPI;
ELSIF lrTemp<0 THEN
	lrTheta_Cur:=lrTemp+2*gc_lrPI;
END_IF

KS_CalcRadByAbsEnc:=lrTheta_Cur;