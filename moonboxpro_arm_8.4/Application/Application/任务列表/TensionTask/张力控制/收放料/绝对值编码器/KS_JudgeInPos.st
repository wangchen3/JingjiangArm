(*@CES
Name=KS_JudgeInPos
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=45bca8ac-641b-44fd-a5c0-54a9da97f6fe
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_JudgeInPos : BOOL(*判断是否到位，运动过程中跨过了目标位置|只有效一次
							|编码器线束不能到最高位*)
(*2023.08.09.191027 由1°修改到2°@宁波欣达机器抖动在0.9°接近阈值|*)
VAR_INPUT
	i_dwPos_Tar:DWORD;(*目标位置*)
	i_dwPos_Cur:DWORD;(*当前位置*)
	i_dwLastPos_Cur:DWORD;(*当前位置|上个周期*)
	i_dwPos_Cycle:DWORD;(*一圈对应的位置值*)
	i_pxInPos:POINTER TO BOOL;(*到位信号|2022.7.14.191601|超过一定角度复位到位标志*)
END_VAR
VAR

	xInpos: BOOL;(*到位标志*)
	diDeltPosToLastPos: DINT:=0;
	diDelPos_ToTarPos: DINT;
	xNextCycle: BOOL;
	(*2023.08.09.191027 由1°修改到2°@宁波欣达机器抖动在0.9°接近阈值|*)
	wAwayPos_Angel:WORD:=2;(*远离定位的角度值|单位°*)
	rTemp:REAL;
END_VAR
{IMPLEMENTATION}
IF i_pxInPos<>0 THEN
	xInPos:=i_pxInPos^;
END_IF

diDeltPosToLastPos:=DWORD_TO_DINT(i_dwPos_Cur)-i_dwLastPos_Cur;
IF ABS(diDeltPosToLastPos)>i_dwPos_Cycle/2 THEN(*如果单个周期变化量超过了半圈 我们认为数据过圈了|*)
	xNextCycle:=TRUE;(*过圈标志*)
END_IF

IF xNextCycle  THEN(*过圈了|重新计算变化量*)
	IF i_dwPos_Cur>i_dwLastPos_Cur THEN(*1-->131072*)
		diDeltPosToLastPos:=DWORD_TO_DINT(i_dwLastPos_Cur)+i_dwPos_Cycle-i_dwPos_Cur+1;
	ELSE(*131072-->1*)
		diDeltPosToLastPos:=DWORD_TO_DINT(i_dwPos_Cur)+i_dwPos_Cycle-i_dwLastPos_Cur+1;
	END_IF
END_IF


(*当前值和目标值的距离*)
diDelPos_ToTarPos:=DWORD_TO_DINT(i_dwPos_Cur)-i_dwPos_Tar;
IF ABS(diDelPos_ToTarPos)>i_dwPos_Cycle/2 THEN(*超过一半取小值*)
	IF diDelPos_ToTarPos>0 THEN
		diDelPos_ToTarPos:=i_dwPos_Cycle-diDelPos_ToTarPos+1;
		diDelPos_ToTarPos:=-diDelPos_ToTarPos;
	ELSE
		diDelPos_ToTarPos:=i_dwPos_Cycle+diDelPos_ToTarPos+1;
	END_IF
END_IF

(*2021.5.29.143327 更新判断条件为小于单个周期变化量*)
rTemp:=LREAL_TO_REAL(DWORD_TO_LREAL(i_dwPos_Cycle*wAwayPos_Angel)/360.0);
IF NOT xInPos THEN
	IF ABS(diDelPos_ToTarPos)(**2*)<=ABS(diDeltPosToLastPos) THEN(*当前值距离目标值小于单个周期变化量的一半，我们到达位置了*)
		xInpos:=TRUE;
	END_IF
ELSE(*到位了|放宽阈值判断取消到位标志*)
	IF ABS(diDelPos_ToTarPos)>=rTemp THEN
		xInpos:=FALSE;
	END_IF
END_IF


IF i_pxInPos<>0 THEN
	i_pxInPos^:=xInPos;
END_IF
(*KS_JudgeInPos:=xInpos;*)