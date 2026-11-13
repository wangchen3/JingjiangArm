(*@CES
Name=KS_CalcGatePos_Follow
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=4fe415d3-d686-4f37-995a-ecb110eaba4a
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_CalcGatePos_Follow : INT(*计算跟踪某一个色方式计算该色的波门位置@单位是粗采样点数*)
(*-1 参数错误
-2 标记非法
-3 未隔色*)
(*2024.02.21.130156 输出第二波们的位置@出错则输出=0*)
(*2024.7.30.144846 计算方法有问题取巧未使用实际距离使用了波门宽度@波门宽度变化为非20后就会出错了
处理为根据实际距离计算*)
(*2024.7.31.075422 2色按照波门宽度偏移*)
VAR_INPUT
	i_byUnitId_Follow:BYTE;(*跟踪的色组id*)
	i_byUnitId_Cur:BYTE;(*当前的色组id*)
	i_iGateSa:INT;(*当前波门位置*)
	i_iGateWidthRondPt:INT;(*波门宽度的粗采样点数@使用改变量需要波门宽度为20mm*)
	i_iGatePoint_Max:INT;(*最大粗采样点数*)
	i_iMarkArrangeId:INT;(*标记类型*)

	i_rGirth:REAL;(*版辊周长@mm*)
END_VAR
VAR
	byDeltaId: BYTE;
	iGateSaEx: INT;
	iRtn: INT;
	iDeltaRondPt: INT;(*间隔的粗采样点数*)
END_VAR
{IMPLEMENTATION}
IF i_iGatePoint_Max=0 THEN
	i_iGatePoint_Max:=4000;
END_IF
IF i_byUnitId_Follow>0 AND
	i_byUnitId_Cur>=2 AND(*条件修改*)
	i_byUnitId_Follow<i_byUnitId_Cur AND
	i_iGateSa>=0 AND i_iGateSa<i_iGatePoint_Max THEN

	IF i_byUnitId_Cur>i_byUnitId_Follow THEN
		byDeltaId:=i_byUnitId_Cur-i_byUnitId_Follow;(*间隔*)
	ELSE
		byDeltaId:=0;
	END_IF

	IF byDeltaId<>0 THEN;
	ELSE(*不隔色*)
		iGateSaEx:= 0;
		iRtn:=-3;
		RETURN;
	END_IF


	IF i_rGirth<>0 THEN;
	ELSE
		i_rGirth:=500;
	END_IF
	IF i_byUnitId_Cur=2 THEN(*2色按照波门宽度偏移@2024.7.31.075310*)
		iDeltaRondPt:=i_iGateWidthRondPt;
	ELSE
		iDeltaRondPt:=REAL_TO_INT(BYTE_TO_REAL(byDeltaId)*20.0/i_rGirth*i_iGatePoint_Max)+1;(*按照间隔n*20mm计算|稍微离远点@主要是1 2色的波门*)
	END_IF


	IF i_iMarkArrangeId= MARK_ARRANGE_VFOR THEN(*顺序*)
		iGateSaEx:=i_iGateSa-(*byDeltaId*i_iGateWidthRondPt*)iDeltaRondPt;
		IF iGateSaEx<0 THEN
			iGateSaEx:= iGateSaEx+i_iGatePoint_Max;
		END_IF
	ELSIF i_iMarkArrangeId= MARK_ARRANGE_VREV THEN(*逆序*)
		iGateSaEx:=i_iGateSa+(*byDeltaId*i_iGateWidthRondPt*)iDeltaRondPt;
		IF iGateSaEx>i_iGatePoint_Max THEN
			iGateSaEx:= iGateSaEx-i_iGatePoint_Max;
		END_IF
	ELSE
		iGateSaEx:= 0;
		iRtn:=-2;
	END_IF
ELSE
	iGateSaEx:= 0;
	iRtn:=-1;
END_IF
(*
IF iRtn<0 THEN
	KS_CalcGatePos_Follow:=iRtn;
ELSE*)
	KS_CalcGatePos_Follow:=iGateSaEx;
(*END_IF*)