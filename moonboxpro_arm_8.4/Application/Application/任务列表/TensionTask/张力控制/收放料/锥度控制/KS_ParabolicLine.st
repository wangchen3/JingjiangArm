(*@CES
Name=KS_ParabolicLine
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=32bb2783-1164-4a85-bd37-5e8616daa227
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_ParabolicLine : BOOL(*二次抛物线|Y=Ax^2+Bx+C@先不处理多点直线拟合|输出有效则报错*)
VAR_INPUT
	i_iValidPoitNum:INT;(*最大有效点个数*)
	i_pastValidStPoint_XY:POINTER TO ARRAY [1..100] OF StPoint_XY;(*X轴为卷径|Y 为锥度值@有效的点位*)
	i_prA:POINTER TO REAL;
	i_prB:POINTER TO REAL;
	i_prC:POINTER TO REAL;
END_VAR
VAR
	xParaErr:BOOL;
	arPoint_X:ARRAY [1..100] OF REAL;
	arPoint_Y:ARRAY [1..100] OF REAL;
	lrATemp:LREAL;
	lrBTemp:LREAL;
	rA:REAL;
	rB:REAL;
	rC:REAL;
	iN: INT;
	byType: BYTE;
	pstValidStPoint_XY:POINTER TO StPoint_XY;(*X轴为卷径|Y 为锥度值@有效的点位*)
	lrTemp: LREAL;
	lrTemp1: LREAL;
	lrTemp2: LREAL;
	lrTemp3: LREAL;
	lrTemp4: LREAL;
	lrTemp5: LREAL;
	lrTemp6: LREAL;
	lrTemp7: LREAL;
	lrAverage_X: LREAL;(*X的平均值*)
	lrAverage_Y: LREAL;(*Y的平均值*)
	lrAverage_XY: LREAL;(*XY的平均值*)
	lrAverage_X_Square2: LREAL;(*X^2的平均值*)
	lrAverage_X_Square3: LREAL;(*X^3的平均值*)
	lrAverage_X_Square4: LREAL;(*X^4的平均值*)
	lrAverage_XSquare2Y: LREAL;(*X^2*Y的平均值*)
END_VAR
{IMPLEMENTATION}
IF i_pastValidStPoint_XY<>0 THEN
	IF i_iValidPoitNum>=4 THEN(*4个点以上使用拟合算法*)
		byType:=3;
	ELSIF i_iValidPoitNum=3 THEN(*3个点使用抛物线*)
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
					rB:=lrTemp1/lrTemp;
				ELSE
					xParaErr:=TRUE;
				END_IF

			2:(*抛物线*)
				(*计算rB*)
				lrTemp1:=(arPoint_X[2]*arPoint_X[2]-arPoint_X[3]*arPoint_X[3]);(*X2^2-X3^2*)
				lrTemp1:=lrTemp1*(arPoint_X[1]-arPoint_X[2]);(*lrTemp1*(X1-X2)*)
				lrTemp2:=(arPoint_X[1]*arPoint_X[1]-arPoint_X[2]*arPoint_X[2]);(*X1^2-X2^2*)
				lrTemp2:=lrTemp2*(arPoint_X[2]-arPoint_X[3]);(*lrTemp2*(X2-X3)*)
				lrTemp:=lrTemp1-lrTemp2;(*rB的分母*)

				IF lrTemp<>0 THEN
					lrTemp1:=(arPoint_X[2]*arPoint_X[2]-arPoint_X[3]*arPoint_X[3]);(*X2^2-X3^2*)
					lrTemp1:=lrTemp1*(arPoint_Y[1]-arPoint_Y[2]);(*lrTemp1*(Y1-Y2)*)
					lrTemp2:=(arPoint_X[1]*arPoint_X[1]-arPoint_X[2]*arPoint_X[2]);(*X1^2-X2^2*)
					lrTemp2:=lrTemp2*(arPoint_Y[2]-arPoint_Y[3]);(*lrTemp1*(Y2-Y3)*)

					rB:=(lrTemp1-lrTemp2)/lrTemp;
				ELSE
					xParaErr:=TRUE;
				END_IF

				(*计算rA*)
				IF NOT xParaErr THEN
					lrTemp:=(arPoint_X[1]*arPoint_X[1]-arPoint_X[2]*arPoint_X[2]);(*X1^2-X2^2*)
					IF lrTemp<>0 THEN
						lrTemp1:=arPoint_Y[1]-arPoint_Y[2]-rB*(arPoint_X[1]-arPoint_X[2]);(*Y1-Y2-rB*(X1-X2)*)
						rA:=lrTemp1/lrTemp;
					ELSE
						xParaErr:=TRUE;
					END_IF
				END_IF
				(*计算rC*)
				IF NOT xParaErr THEN
					rC:=arPoint_Y[1]-rA*(arPoint_X[1]*arPoint_X[1])-rB*arPoint_X[1];
				END_IF

			3:(*拟合曲线|*)
				lrTemp:=0;
				lrTemp1:=0;
				lrTemp2:=0;
				lrTemp3:=0;
				lrTemp4:=0;
				lrTemp5:=0;
				lrTemp6:=0;
				lrTemp7:=0;
				FOR iN:=1 TO i_iValidPoitNum BY 1 DO
					lrTemp1:=lrTemp1+arPoint_X[iN];
					lrTemp2:=lrTemp2+arPoint_Y[iN];
					lrTemp3:=lrTemp3+arPoint_X[iN]*arPoint_Y[iN];
					lrTemp4:=lrTemp4+arPoint_X[iN]*arPoint_X[iN];
					lrTemp5:=lrTemp5+arPoint_X[iN]*arPoint_X[iN]*arPoint_X[iN];
					lrTemp6:=lrTemp6+arPoint_X[iN]*arPoint_X[iN]*arPoint_X[iN]*arPoint_X[iN];
					lrTemp7:=lrTemp7+arPoint_X[iN]*arPoint_X[iN]*arPoint_Y[iN];
				END_FOR

				(*计算X Y的平均值*)
				lrAverage_X			:=lrTemp1/i_iValidPoitNum;
				lrAverage_Y			:=lrTemp2/i_iValidPoitNum;
				lrAverage_XY		:=lrTemp3/i_iValidPoitNum;
				lrAverage_X_Square2	:=lrTemp4/i_iValidPoitNum;
				lrAverage_X_Square3	:=lrTemp5/i_iValidPoitNum;
				lrAverage_X_Square4	:=lrTemp6/i_iValidPoitNum;
				lrAverage_XSquare2Y	:=lrTemp7/i_iValidPoitNum;

				(*计算拟合的rA*)
				lrTemp1:=lrAverage_X_Square3-lrAverage_X*lrAverage_X_Square2;
				lrTemp1:=lrTemp1*lrTemp1;
				lrTemp2:=lrAverage_X_Square4-lrAverage_X_Square2*lrAverage_X_Square2;
				lrTemp2:=lrTemp2*(lrAverage_X_Square2-lrAverage_X*lrAverage_X);
				lrTemp:=lrTemp1-lrTemp2;(*计算分母*)
				IF lrTemp<>0 THEN
					lrTemp1:=lrAverage_XY-lrAverage_X*lrAverage_Y;
					lrTemp1:=lrTemp1*(lrAverage_X_Square3-lrAverage_X*lrAverage_X_Square2);

					lrTemp2:=lrAverage_XSquare2Y-lrAverage_X_Square2*lrAverage_Y;
					lrTemp2:=lrTemp2*(lrAverage_X_Square2-lrAverage_X*lrAverage_X);
					lrATemp:=(lrTemp1-lrTemp2)/lrTemp;
					rA:=lrATemp;
				ELSE
					xParaErr:=TRUE;
				END_IF
				(*计算rB*)
				IF NOT xParaErr THEN
					lrTemp:=lrAverage_X_Square2-lrAverage_X*lrAverage_X;
					IF lrTemp<>0 THEN
						lrTemp1:=lrAverage_XY-lrAverage_X*lrAverage_Y-lrATemp*(lrAverage_X_Square3-lrAverage_X*lrAverage_X_Square2);
						lrBTemp:=lrTemp1/lrTemp;
						rB:=lrBTemp;
					ELSE
						xParaErr:=TRUE;
					END_IF
				END_IF

				(*计算rC*)
				IF NOT xParaErr THEN
					lrTemp:=lrAverage_Y-lrATemp*lrAverage_X_Square2-lrBTemp*lrAverage_X;
					rC:=lrTemp;
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

IF i_prC<>0 THEN
	i_prC^:=rC;
END_IF

KS_ParabolicLine:=xParaErr;