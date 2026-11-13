(*@CES
Name=KS_InitTensionCtl_StructParam
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=d3edacb8-afe0-4e68-804f-3598657c3108
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_InitTensionCtl_StructParam : BOOL(*初始化张力控制结构体参数*)
VAR_INPUT
	i_byInitEn:BYTE;(*初始化使能标志@按照定义顺序/.0 初始化第一个结构体。以此类推！*)
	i_xUseIMatrix_rX_DARE:BOOL;(*迭代计算的初始矩阵为单位矩阵@否则为特定初始卷径的收敛值*)
	(*/.0*)
	i_pstInitial_Model_Parameters_Input: POINTER TO Initial_Model_Parameters;(*2024.05.07.093000 调整接口名*)
	(*/.1*)
	i_pstInvariant_Parameters1: POINTER TO Invariant_Parameters;(*2024.05.07.105319 修改接口名by Liu*)
	(*/.2*)
	i_pstKalman_Status_Estimation_And_Feedback1: POINTER TO Kalman_Status_Estimation_And_Feedback;(*2024.05.07.105319 修改接口名by Liu*)
	(*/.3*)
	i_pstKalman_Status_Estimation_And_Feedback_MinBeat1: POINTER TO Kalman_Status_Estimation_And_Feedback_MinBeat;(*2024.05.07.105319 修改接口名by Liu*)
	(*/.4*)
	i_pstPI_Parameters1: POINTER TO PI_Parameters;(*2024.05.07.105319 修改接口名by Liu*)
	(*LQR迭代求解DARE@函数中初始化为了特定初始卷径的收敛值|
	如果初始化为了单位矩阵，需要迭代，第一拍迭代可能时间会长*)
	(*2024.06.08.151322 修改为了lreal类型*)
	(*/.5*)
	i_parX_DARE:POINTER TO ARRAY [1..4,1..4] OF REAL;(*上一个周期已经迭代收敛的值X_Dare*)
	i_palrX_DARE:POINTER TO ARRAY [1..4,1..4] OF LREAL;(*上一个周期已经迭代收敛的值X_Dare*)
	(*/.6@2024.05.13.181113+*)
	i_pstPI_Parameters1_AccDec: POINTER TO PI_Parameters;(*2024.05.13.181126 升降速pi参数*)
	i_iCycleTime_Plc: INT;
END_VAR
VAR
	xInit: BOOL;
	arQ:ARRAY [1..4,1..4] OF REAL;(*Q矩阵*)
	arI:ARRAY [1..4,1..4] OF REAL;(*单位矩阵*)
	arKf:ARRAY [1..4] OF REAL;
	arX_DARE:ARRAY [1..4,1..4] OF REAL;
	(*2024.06.08.151416增加lreal类型*)
	alrQ:ARRAY [1..4,1..4] OF LREAL;(*Q矩阵*)
	alrKf:ARRAY [1..4] OF LREAL;
	alrI:ARRAY [1..4,1..4] OF LREAL;(*单位矩阵*)
	alrX_DARE:ARRAY [1..4,1..4] OF LREAL;
END_VAR
{IMPLEMENTATION}
(*初始化第一个结构体*)
xInit:=i_byInitEn.0;
IF i_pstInitial_Model_Parameters_Input<>0 AND xInit THEN
   	i_pstInitial_Model_Parameters_Input^.R_0	:=0.27;             (*初始卷半径m 0.31*)

    i_pstInitial_Model_Parameters_Input^.a0_0	:=0;           	(*初始a0*)
    i_pstInitial_Model_Parameters_Input^.b1_0	:=0.07;	 			(*初始b1 0.016*)
    i_pstInitial_Model_Parameters_Input^.Wn_0	:=8.9;				(*初始Wn 4.3*)
    i_pstInitial_Model_Parameters_Input^.Beta_0	:=0.5;				(*初始Beta  0.22*)


    i_pstInitial_Model_Parameters_Input^.l_0	:=1;				(*初始调整系数l 1*)
END_IF

(*初始化第二个结构体*)
xInit:=i_byInitEn.1;
IF i_pstInvariant_Parameters1<>0 AND xInit THEN
    i_pstInvariant_Parameters1^.Ts		:=INT_TO_REAL(i_iCycleTime_Plc)/1000.0;		(*采样时间Ts*)
    i_pstInvariant_Parameters1^.Range	:=11.8;    	(*输出最大量程 13.8*)
    i_pstInvariant_Parameters1^.Theta	:=30.0;	(*摆臂偏角范围 25.64*)


    i_pstInvariant_Parameters1^.K_adj	:=1.4;		(*模型调整增益 1.3*)
END_IF

(*构造一个单位矩阵*)
arI[1,1]:=1;
arI[2,2]:=1;
arI[3,3]:=1;
arI[4,4]:=1;
alrI[1,1]:=1;
alrI[2,2]:=1;
alrI[3,3]:=1;
alrI[4,4]:=1;
(*构造一个Q矩阵*)
arQ[4,4]:=0.01;
alrQ[4,4]:=0.01;
(*构造kf矩阵*)
arKf[1]:=-0.71625816;
arKf[2]:=-14.455574;
arKf[3]:=-25.065932;
arKf[4]:=-341.98005;

alrKf[1]:=-0.71625816;
alrKf[2]:=-14.455574;
alrKf[3]:=-25.065932;
alrKf[4]:=-341.98005;

(*初始化第三个结构体*)
xInit:=i_byInitEn.2;
IF i_pstKalman_Status_Estimation_And_Feedback1<>0 AND xInit THEN
	i_pstKalman_Status_Estimation_And_Feedback1^.R_K	:=10;
	i_pstKalman_Status_Estimation_And_Feedback1^.Q		:=arQ;
	i_pstKalman_Status_Estimation_And_Feedback1^.P0		:=arI;
	i_pstKalman_Status_Estimation_And_Feedback1^.N_LQR	:=10;
	i_pstKalman_Status_Estimation_And_Feedback1^.Kf		:=arKf;

	i_pstKalman_Status_Estimation_And_Feedback1^.alrQ		:=alrQ;
	i_pstKalman_Status_Estimation_And_Feedback1^.alrP0		:=alrI;
	i_pstKalman_Status_Estimation_And_Feedback1^.alrKf		:=alrKf;
END_IF


(*初始化第四个结构体*)
xInit:=i_byInitEn.3;
IF i_pstKalman_Status_Estimation_And_Feedback_MinBeat1<>0 AND xInit THEN
	i_pstKalman_Status_Estimation_And_Feedback_MinBeat1^.R_K	:=100;
	i_pstKalman_Status_Estimation_And_Feedback_MinBeat1^.Q		:=arQ;
	i_pstKalman_Status_Estimation_And_Feedback_MinBeat1^.P0		:=arI;
	i_pstKalman_Status_Estimation_And_Feedback_MinBeat1^.N_MinBeat:=2;
	i_pstKalman_Status_Estimation_And_Feedback_MinBeat1^.Kf		:=arKf;
END_IF


(*初始化第五个结构体*)
xInit:=i_byInitEn.4;
IF i_pstPI_Parameters1<>0 AND xInit THEN
	i_pstPI_Parameters1^.K_PI	:=1;
	i_pstPI_Parameters1^.a		:=4.2;

	i_pstPI_Parameters1^.b		:=0;
END_IF

(*初始化第六个结构体*)
(*构造arX_DARE矩阵@特定初始卷径的收敛值*)

arX_DARE[1,1]:=0.5809964918;
arX_DARE[1,2]:=11.4605492993;
arX_DARE[1,3]:=19.3883120752;
arX_DARE[1,4]:=261.7670536474;

arX_DARE[2,1]:=11.4605492993;
arX_DARE[2,2]:=341.4559372966;
arX_DARE[2,3]:=273.7038620995;
arX_DARE[2,4]:=2799.1520439073;

arX_DARE[3,1]:=19.3883120752;
arX_DARE[3,2]:=273.7038620995;
arX_DARE[3,3]:=758.807264184;
arX_DARE[3,4]:=11796.8531367233;

arX_DARE[4,1]:=261.7670536474;
arX_DARE[4,2]:=2799.1520439073;
arX_DARE[4,3]:=11796.8531367233;
arX_DARE[4,4]:=347613.458626343;

(*LREAL*)
alrX_DARE[1,1]:=0.5809964918;
alrX_DARE[1,2]:=11.4605492993;
alrX_DARE[1,3]:=19.3883120752;
alrX_DARE[1,4]:=261.7670536474;

alrX_DARE[2,1]:=11.4605492993;
alrX_DARE[2,2]:=341.4559372966;
alrX_DARE[2,3]:=273.7038620995;
alrX_DARE[2,4]:=2799.1520439073;

alrX_DARE[3,1]:=19.3883120752;
alrX_DARE[3,2]:=273.7038620995;
alrX_DARE[3,3]:=758.807264184;
alrX_DARE[3,4]:=11796.8531367233;

alrX_DARE[4,1]:=261.7670536474;
alrX_DARE[4,2]:=2799.1520439073;
alrX_DARE[4,3]:=11796.8531367233;
alrX_DARE[4,4]:=347613.458626343;

xInit:=i_byInitEn.5;
IF i_parX_DARE<>0 AND xInit THEN
	IF i_xUseIMatrix_rX_DARE THEN(*初始化单位矩阵*)
		i_parX_DARE^:=arI;
	ELSE(*初始化为特定初始卷径的收敛值*)
		i_parX_DARE^:=arX_DARE;
	END_IF
END_IF
IF i_palrX_DARE<>0 AND xInit THEN
	IF i_xUseIMatrix_rX_DARE THEN(*初始化单位矩阵*)
		i_palrX_DARE^:=alrI;
	ELSE(*初始化为特定初始卷径的收敛值*)
		i_palrX_DARE^:=alrX_DARE;
	END_IF
END_IF


(*初始化第七个结构体*)
xInit:=i_byInitEn.6;
IF i_pstPI_Parameters1_AccDec<>0 AND xInit THEN
	i_pstPI_Parameters1_AccDec^.K_PI	:=1;
	i_pstPI_Parameters1_AccDec^.a		:=7.2;
	i_pstPI_Parameters1_AccDec^.b		:=0;
END_IF
