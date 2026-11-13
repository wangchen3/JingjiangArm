(*@CES
Name=KS_GetCurveCoeff
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=9ebd4b66-811d-4a43-a8fd-0ccbf91fd938
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_GetCurveCoeff : BOOL(*锥度曲线拟合系数|支持直线和二次曲线*)
(*拟合系数-直线 Y=Ax+B
	   二次曲线 Y=Ax*x+Bx+C*)

(*支持多点计算(程序中允许100点输入)*)
(*-1 参数非法
  -2 直线拟合出错了*)
VAR_INPUT
	i_byCurveType:BYTE;(*曲线类型|=0 直线
								 |=1 二次曲线(点位太少按照直线输出)
								 |=2 三次曲线(暂不支持)*)
	i_iPoitNum_Max:INT;(*最大输入的点个数|根据这个值获取点位数据*)
	i_dwSaAdr_Point_XY:DWORD;(*点位数据的首地址|按照StPoint_XY结构体存放*)
	i_piValidPoitNum:POINTER TO INT;(*最大有效点个数*)
	(*拟合系数-直线 Y=Ax+B
		   二次曲线 Y=Ax*x+Bx+C*)
	i_prFitCoeff_A:POINTER TO REAL;(*拟合系数A*)
	i_prFitCoeff_B:POINTER TO REAL;(*拟合系数B*)
	i_prFitCoeff_C:POINTER TO REAL;(*拟合系数C*)
END_VAR
VAR
	in: INT;
	iPoitNum_Max: INT;(*最大点数*)
	astStPoint_XY:ARRAY [1..100] OF StPoint_XY;(*X轴为卷径|Y 为锥度值@按照100个点申请*)
	astValidStPoint_XY:ARRAY [1..100] OF StPoint_XY;(*X轴为卷径|Y 为锥度值@有效的点位*)
	iValidPoitNum:INT;(*有效点位的个数*)
	byCurveType: BYTE;(*曲线类型*)
	rA: REAL;
	rB: REAL;
	rC: REAL;
	xRtn: BOOL;
	iErrCode:INT;
END_VAR
{IMPLEMENTATION}
byCurveType:=i_byCurveType;
iPoitNum_Max:=i_iPoitNum_Max;
IF i_dwSaAdr_Point_XY<>0 THEN;
	SysMemCpy(ADR(astStPoint_XY),i_dwSaAdr_Point_XY,INT_TO_DWORD(iPoitNum_Max)*SIZEOF(astStPoint_XY[1]));
ELSE
	iErrCode:=-1;
END_IF

(*检查点位的合法性-X或者Y有一个=0认为是无效点*)
FOR iN:=1 TO iPoitNum_Max BY 1 DO
	IF astStPoint_XY[iN].rX=0 OR
		astStPoint_XY[iN].rY=0 THEN(*非法点，剔除*);
	ELSE
		iValidPoitNum:=iValidPoitNum+1;
		astValidStPoint_XY[iValidPoitNum]:=astStPoint_XY[iN];
	END_IF
END_FOR

(*曲线算法*)
byCurveType:=i_byCurveType;
CASE byCurveType OF
	0:(*直线拟合|*)
		xRtn:=KS_StraightLine(iValidPoitNum, ADR(astValidStPoint_XY), ADR(rA), ADR(rB));
		IF xRtn THEN
			iErrCode:=-2;
		END_IF
ELSE(*默认按照二次拟合*)
		xRtn:=KS_ParabolicLine(
					iValidPoitNum(*i_iValidPoitNum*),
					ADR(astValidStPoint_XY)(*i_pastValidStPoint_XY*),
					ADR(rA)(*i_prA*),
					ADR(rB)(*i_prB*),
					ADR(rC)(*i_prC*));
		IF xRtn THEN
			iErrCode:=-2;
		END_IF
END_CASE

IF i_piValidPoitNum<>0 THEN
	i_piValidPoitNum^:=iValidPoitNum;
END_IF
IF i_prFitCoeff_A<>0 THEN
	i_prFitCoeff_A^:=rA;
END_IF
IF i_prFitCoeff_B<>0 THEN
	i_prFitCoeff_B^:=rB;
END_IF

IF i_prFitCoeff_C<>0 THEN
	i_prFitCoeff_C^:=rC;
END_IF

KS_GetCurveCoeff:=iErrCode<>0;