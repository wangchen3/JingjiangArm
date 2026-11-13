(*@CES
Name=RadiEst
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=78b04f11-b967-4930-a408-d7c5f7f7845f
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION RadiEst : REAL
VAR_INPUT
	i_xFilmToBig:BOOL;(*TRUE:料膜变大；FALSE:料膜变小*)
	i_Wu:REAL;(*放料转速(RPM)*)
	i_Vt:REAL;(*牵引线速度,(mm/s)*)
	i_Tf:REAL;(*张力摆臂反馈(V)*)
	i_EaL:REAL;(*i_EaL=10.08，弹性模量(N/m^2)*横截面积(m^2)/料长(mm)*)
	i_Ts:REAL;(*采样周期(s)*)
	i_Para_Tf:REAL;(*张力迭代参数|1*)
	i_Para_R:REAL;(*卷径迭代参数|100*)
	i_pPh:POINTER TO  REAL;(*二维数组Ph指针*)
	i_pXh:POINTER TO  REAL;(*上一个周期估计状态向量Xh指针*)
END_VAR
VAR
	pPtemp3_1:POINTER TO  REAL;(*一维数组临时指针*)
	pPtemp3_3a:POINTER TO  REAL;(*二维数组P和Ph的临时指针*)
	pPtemp3_3b:POINTER TO  REAL;(*二维数组P和Ph的临时指针*)
	pXtemp:POINTER TO REAL;
	pAp:POINTER TO  REAL;(*二维数组A指针*)
	pCp:POINTER TO  REAL;(*二维数组A指针*)
	pApt: POINTER TO REAL;
	pK:POINTER TO REAL;
	pX:POINTER TO REAL;(*状态向量指针*)
	pP:POINTER TO REAL;
	pTemp:POINTER TO REAL;
	Apt:ARRAY [1..3,1..3] OF REAL:=[0,0,0,0,0,0,0,0,0];
	Ap:ARRAY [1..3,1..3] OF REAL:=[0,0,0,0,0,0,0,0,0];
	Cp:ARRAY [1..3] OF REAL:=[0,0,1];
	P:ARRAY [1..3,1..3] OF REAL;(*:=0,0,0,0,0,0,0,0*)
	Ptemp3_3a:ARRAY [1..3,1..3] OF REAL;(*:=0,0,0,0,0,0,0,0*)
	Ptemp3_3b:ARRAY [1..3,1..3] OF REAL;(*:=0,0,0,0,0,0,0,0*)
	Ptemp3_1:ARRAY [1..3] OF REAL;(*:=0,0,0,0,0,0,0,0*)
	K:ARRAY [1..3] OF REAL:=[0,0,0];
	X:ARRAY [1..3] OF REAL:=[0,0,0];
	Xtemp:ARRAY [1..3] OF REAL:=[0,0,0];
	iN:INT;
	Temp:REAL;

	parTemp:POINTER TO ARRAY [1..3,1..3] OF REAL;
	iCoeff: INT;
END_VAR
{IMPLEMENTATION}
(*将函数中的数组和指针关联*)
pAp:=ADR(Ap);
pApt:=ADR(Apt);
pCp:=ADR(Cp);
pPtemp3_1:=ADR(Ptemp3_1);
pPtemp3_3a:=ADR(Ptemp3_3a);
pPtemp3_3b:=ADR(Ptemp3_3b);
pK:=ADR(K);
pXtemp:=ADR(Xtemp);
pP:=ADR(P);
pX:=ADR(X);
(*针对卷径变化方向增加|标志切换*)
IF i_xFilmToBig THEN(*卷径变大了*)
	iCoeff:=1;
ELSE(*卷径变小了*)
	iCoeff:=-1;
END_IF

(*给Ap,Apt,Cp,X赋值*)
Ap[1,1]:=1 ; Ap[1,2]:=iCoeff*i_Wu*i_Ts/60 ; Ap[2,2]:=1 ; Ap[3,1]:=LREAL_TO_REAL(iCoeff*i_EaL*i_Ts*i_Wu/60*2*gc_lrPi) ; Ap[3,3]:=1;
Apt[1,1]:=1 ; Apt[2,1]:=iCoeff*i_Wu*i_Ts/60 ; Apt[2,2]:=1 ; Apt[1,3]:=LREAL_TO_REAL(iCoeff*i_EaL*i_Ts*i_Wu/60*2*gc_lrPi) ; Apt[3,3]:=1;
Cp[3]:=1;
(*Ph=APA'+Q*)
MatProduct(3,3,3,3,pAp,i_pPh,pPtemp3_3a);
MatProduct(3,3,3,3,pPtemp3_3a,pApt,i_pPh);
pTemp:=i_pPh+REAL_TO_DWORD(8*4);
pTemp^:=pTemp^+i_Para_Tf;
(*K=Ph*C'/(R+C*Ph*C')*)
MatProduct(3,3,3,1,i_pPh,pCp,pK);
pTemp:=i_pPh+REAL_TO_DWORD(8*4);
Temp:=i_Para_R+pTemp^;
FOR iN:=1 TO 3 BY +1 DO
K[iN]:=K[iN]/Temp;
END_FOR
(*X=Ax+Bu*)
MatProduct(3,3,3,1,pAp,i_pXh,pXtemp);
Xtemp[3]:=Xtemp[3]+i_Ts*i_EaL*i_Vt*(-iCoeff);
X:=Xtemp;
(*Xh=X+K(y-CX)*)
Temp:=0;
Temp:=i_Tf-X[3];
FOR iN:=1 TO 3 BY +1 DO
pTemp:=i_pXh+INT_TO_DWORD(4*(iN-1));
pTemp^:=X[iN]+Temp*K[iN];
END_FOR
(*P=(I-KC)Ph*)
Cp[3]:=-1;
MatProduct(3,1,1,3,pK,pCp,pPtemp3_3a);
Ptemp3_3a[1,1]:=1.0+Ptemp3_3a[1,1];
Ptemp3_3a[2,2]:=1.0+Ptemp3_3a[2,2];
Ptemp3_3a[3,3]:=1.0+Ptemp3_3a[3,3];
pPtemp3_3b:=i_pPh;
(*MatProduct(3,3,3,3,pPtemp3_3a,pPtemp3_3b,i_pPh);将估计协方差矩阵传出*)
MatProduct(3,3,3,3,pPtemp3_3a,i_pPh,pP);(*将估计协方差矩阵传出*)
(*g_Ph:=P;*)
parTemp:=i_pPh;
parTemp^:=P;