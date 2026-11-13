(*@CES
Name=KS_StraightLine
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=69642510-d218-426d-a290-8472573a37ba
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_StraightLine : BOOL(*直线|Y=Ax+B@先不处理多点直线拟合|输出有效则报错*)
VAR_INPUT
	i_iValidPoitNum:INT;(*最大有效点个数*)
	i_pastValidStPoint_XY:POINTER TO ARRAY [1..100] OF StPoint_XY;(*X轴为卷径|Y 为锥度值@有效的点位*)
	i_prA:POINTER TO REAL;
	i_prB:POINTER TO REAL;
END_VAR
VAR
	xParaErr:BOOL;
	arPoint_X:ARRAY [1..100] OF REAL;
	arPoint_Y:ARRAY [1..100] OF REAL;
	rA:REAL;
	rB:REAL;
	iN: INT;
	byType: BYTE;
	pstValidStPoint_XY:POINTER TO StPoint_XY;(*X轴为卷径|Y 为锥度值@有效的点位*)
	lrTemp: LREAL;
	lrTemp1: LREAL;
	lrTemp2: LREAL;
	lrTemp3: LREAL;
	lrTemp4: LREAL;
	lrSum_X: LREAL;
	lrSum_Y: LREAL;
	lrSum_XY: LREAL;
	lrSum_XSquart2: LREAL;
END_VAR
{IMPLEMENTATION}
IF i_pastValidStPoint_XY<>0 THEN
	IF i_iValidPoitNum>=3 THEN(*3个点以上使用拟合算法*)
		byType:=2;
	ELSIF i_iValidPoitNum=2 THEN(*2个点使用直线*)
		byType:=1;
	ELSE(*点位太少*)
		xParaErr:=TRUE;
	END_IF

	IF NOT xParaErr THEN
		FOR iN:=1  TO i_iValidPoitNum BY 1 DO
			pstValidStPoint_XY:=ADR(i_pastValidStPoint_XY^[iN]);
			arPoint_X[iN]:=pstValidStPoint_XY^.rX;
			arPoint_Y[iN]:=pstValidStPoint_XY^.rY;
		END_FOR

		CASE byType OF
			1:(*直线*)
				lrTemp	:=arPoint_X[1]-arPoint_X[2];
				lrTemp1	:=arPoint_Y[1]-arPoint_Y[2];
				IF lrTemp<>0 THEN
					rA:=LREAL_TO_REAL(lrTemp1/lrTemp);

					lrTemp1:=arPoint_X[1]*arPoint_Y[2]-arPoint_X[2]*arPoint_Y[1];
					rB:=LREAL_TO_REAL(lrTemp1/lrTemp);
				ELSE
					xParaErr:=TRUE;
				END_IF

			2:(*拟合直线*)
				lrSum_X:=0;
				lrSum_Y:=0;
				lrSum_XY:=0;
				lrSum_XSquart2:=0;
				FOR iN:=1 TO i_iValidPoitNum BY 1 DO
					lrSum_X:=lrSum_X+arPoint_X[iN];
					lrSum_Y:=lrSum_Y+arPoint_Y[iN];
					lrSum_XY:=lrSum_XY+arPoint_X[iN]*arPoint_Y[iN];
					lrSum_XSquart2:=lrSum_XSquart2+arPoint_X[iN]*arPoint_X[iN];
				END_FOR

				(*计算rB*)
				lrTemp:=i_iValidPoitNum*lrSum_XSquart2-lrSum_X*lrSum_X;
				IF lrTemp<>0 THEN
					lrTemp1:=lrSum_XSquart2*lrSum_Y-lrSum_X*lrSum_XY;
					rB:=LREAL_TO_REAL(lrTemp1/lrTemp);
				ELSE
					xParaErr:=TRUE;
				END_IF

				(*计算rA*)
				IF NOT xParaErr THEN
					lrTemp:=i_iValidPoitNum*lrSum_XSquart2-lrSum_X*lrSum_X;
					IF lrTemp<>0 THEN
						lrTemp1:=i_iValidPoitNum*lrSum_XY-lrSum_X*lrSum_Y;
						rA:=LREAL_TO_REAL(lrTemp1/lrTemp);
					ELSE
						xParaErr:=TRUE;
					END_IF
				END_IF
		ELSE;
		END_CASE

	END_IF
ELSE
	xParaErr:=TRUE;
END_IF


IF i_prA<>0 THEN
	i_prA^:=rA;
END_IF

IF i_prB<>0 THEN
	i_prB^:=rB;
END_IF

KS_StraightLine:=xParaErr;