(*@CES
Name=KS_FB_Taper
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=684df15a-86b3-4c73-bdbe-f6eb8637542a
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_Taper
(*2025.1.9.162926 增加了当前卷径输入接口@写到输入输出是为了防止漏改*)
(*2025.1.15.150823 停机锥度@防止停机张力投入时收料锥度设置过小引起的料膜被放料拉走问题*)
(*2025.3.7.112920 增加了多点直线和多点曲线的实现*)
(*2025.3.29.151033 停机锥度的实现更新丢了！麻烦*)
VAR_INPUT
	i_iGrpId: INT; (*1.A系;2.B系*)
	i_xTaperCurCTLEn:BOOL;(*当前锥度控制使能|在印刷状态且收牵合压或者色组至少合压一色时进行控制
						其他状态按照最大锥度输出|2021.8.30.164822*)
//	i_pstStShmGlobalParam: POINTER TO StShmGlobalParam; (*参数地址*)
	i_xTaperAdd:BOOL;
	i_xTaperDec:BOOL;
	i_rTaperMax:REAL;(*最大锥度限值值*)
	i_rTaperValue_Stop:REAL;(*停机锥度@防止停机张力投入时收料锥度设置过小引起的料膜被放料拉走问题*)
	
	i_byTaperAdjMode: BYTE;
	i_rDiamCurAxis: REAL;
	i_rTaper_Begin_Rw: REAL;(*起始锥度*)
	i_rTaper_End_Rw: REAL;(*结束锥度*)
	i_rDiamTaper_Begin_Rw: REAL;(*起始锥度-直径*)
	i_rDiamTaper_End_Rw: REAL;(*结束锥度-直径*)	
END_VAR
VAR_OUTPUT
	o_rTaper_Cur: REAL;
END_VAR
VAR_IN_OUT
	iO_byTaperUnit: BYTE;
	io_rTaperValueBegin_Hmi: REAL;
	io_rTaperValueEnd_Hmi: REAL;
	io_astTaperPoint:ARRAY [1..10] OF StPoint_XY;
END_VAR
VAR
//	pstStGrpParam: POINTER TO StGrpParam; (*访问当前系参数的指针*)
	xTaperAdd:BOOL;
	xPreTaperAdd:BOOL;
	xTaperDec:BOOL;
	xPreTaperDec:BOOL;
	lrTemp: LREAL;
	lrCurrentTaper: LREAL;(*当前锥度值临时变量*)



	lrPreCurrentTaper: LREAL;(*上个周期的锥度*)
	lrDelTaper: LREAL;(*锥度的变化量*)
	iMaxTimeTOMaxTaper:INT:=200;(*到达最大锥度的周期次数，20ms周期时时间是4s*)
	iMaxTaper:INT:=100;(*最大锥度值*)

	(*2025.3.7.113256+byTaperAdjMode = 2*)
	xRtn: BOOL;
	iN: INT;
	iPoitMax: INT:=7;(*最大点数先按照7个*)
	iValidPoitNum: INT;(*实际有效的点数*)
	rFitCoeff_A: REAL;(*计算的二次系数*)
	rFitCoeff_B: REAL;(*计算的一次系数*)
	rFitCoeff_C: REAL;(*常量*)
	iMaxDiamIndex: INT;(*多点中卷径最大值索引*)
	iMinDiamIndex: INT;(*多点中卷径最小值索引*)
	rMinDiam: REAL;(*多点中最小卷径值*)
	rMaxDiam: REAL;(*多点中最大卷径值*)
END_VAR
{IMPLEMENTATION}
IF (i_iGrpId=1 OR i_iGrpId=2) THEN ;ELSE RETURN;END_IF

//pstStGrpParam:= ADR(i_pstStShmGlobalParam^.astStGrpParam[i_iGrpId]);

xTaperAdd:= i_xTaperAdd;
xTaperDec:= i_xTaperDec;

(*2022.2.23.112107 调整锥度界面加减逻辑*)
IF iO_byTaperUnit=1 THEN(*单位是N*)
	lrTemp:=1;
ELSIF iO_byTaperUnit=2 THEN(*单位是mpa*)
	lrTemp:=0.01;
ELSE(*单位是%*)
	lrTemp:=1;
END_IF

IF xTaperAdd AND NOT xPreTaperAdd THEN
	lrTemp:=lrTemp;
ELSIF xTaperDec AND NOT xPreTaperDec THEN
	lrTemp:=-lrTemp;
ELSE
	lrTemp:=0;
END_IF
(*
pstStGrpParam^.lrTaper_Begin_Rw:= pstStGrpParam^.lrTaper_Begin_Rw+lrTemp;
pstStGrpParam^.lrTaper_End_Rw:= pstStGrpParam^.lrTaper_End_Rw+lrTemp;
*)
(*2022.2.23.112206 处理的变量修改为带hmi界面的*)

io_rTaperValueBegin_Hmi:= io_rTaperValueBegin_Hmi+lrTemp;
io_rTaperValueEnd_Hmi:= io_rTaperValueEnd_Hmi+lrTemp;

IF 	io_rTaperValueBegin_Hmi>i_rTaperMax THEN
	io_rTaperValueBegin_Hmi:= i_rTaperMax;
ELSIF io_rTaperValueBegin_Hmi<0 THEN
	io_rTaperValueBegin_Hmi:=0;
END_IF

IF 	io_rTaperValueEnd_Hmi>i_rTaperMax THEN
	io_rTaperValueEnd_Hmi:= i_rTaperMax;
ELSIF io_rTaperValueEnd_Hmi<0 THEN
	io_rTaperValueEnd_Hmi:=0;
END_IF

xPreTaperAdd:=xTaperAdd;
xPreTaperDec:=xTaperDec;


(*
(*2019.4.11.164149 将锥度控制移植到功能块中.并额外增加了新的算法*)
CASE i_pstStShmGlobalParam^.stStSystemExtInfo.byTaperAdjMode OF
1:
	lrCurrentTaper:=KS_Taper_Curve(pstStGrpParam^.lrDiamCurAxis_Rw,pstStGrpParam);
ELSE
	lrCurrentTaper:=KS_Taper_Straight(pstStGrpParam^.lrDiamCurAxis_Rw,pstStGrpParam);
END_CASE


(*2021.8.30.164530 |*)
(*不控制的时候按照最大锥度输出*)
IF NOT i_xTaperCurCTLEn THEN
	lrCurrentTaper:=MAX(pstStGrpParam^.lrTaper_Begin_Rw,pstStGrpParam^.lrTaper_End_Rw);(*取最大值*)
	(*增加一个变量单独控制停机的锥度*)
	lrCurrentTaper:=MAX(lrCurrentTaper,i_rTaperValue_Stop);
END_IF
*)

(*2025.3.7.112958 +*)
(*2019.4.11.164149 将锥度控制移植到功能块中.并额外增加了新的算法*)
(*0--2变化*)
xRtn:=FALSE;
CASE i_byTaperAdjMode OF
1:(*2点曲线*)

	lrCurrentTaper:=KS_Taper_Curve(
			i_rDiamCurAxis,
			i_rTaper_Begin_Rw,
			i_rTaper_End_Rw,
			i_rDiamTaper_Begin_Rw,
			i_rDiamTaper_End_Rw
			);

	(*2021.8.30.164530 |*)
	(*不控制的时候按照最大锥度输出*)
	IF NOT i_xTaperCurCTLEn THEN
(*
		lrCurrentTaper:=MAX(pstStGrpParam^.lrTaper_Begin_Rw,pstStGrpParam^.lrTaper_End_Rw);(*取最大值*)
		(*增加一个变量单独控制停机的锥度*)
		lrCurrentTaper:=MAX(lrCurrentTaper,i_rTaperValue_Stop);
*)
		(*2025.3.29.151947+*)
		lrCurrentTaper:=i_rTaperValue_Stop;
	END_IF
	
2:(*多点曲线@2025.2.28.235627+*)
	(*寻找卷径锥度的最大值和最小值@限制输出使用*)
	iMinDiamIndex:=0;
	iMaxDiamIndex:=0;
	FOR iN:=1 TO iPoitMax BY 1 DO
		(*最小卷径值的索引*)
		IF iMinDiamIndex=0 THEN(*先找起始索引*)
			IF io_astTaperPoint[iN].rX<>0 THEN
				iMinDiamIndex:=iN;
			END_IF
		ELSE(*找到了第一个值*)
			IF io_astTaperPoint[iN].rX < io_astTaperPoint[iMinDiamIndex].rX THEN
				iMinDiamIndex:=iN;(*更新索引值*)
			END_IF
		END_IF

		(*最大卷径的索引*)
		IF iMaxDiamIndex=0 THEN(*先找起始索引*)
			IF io_astTaperPoint[iN].rX<>0 THEN
				iMaxDiamIndex:=iN;
			END_IF
		ELSE(*找到了第一个值*)
			IF io_astTaperPoint[iN].rX > io_astTaperPoint[iMaxDiamIndex].rX THEN
				iMaxDiamIndex:=iN;(*更新索引值*)
			END_IF
		END_IF
	END_FOR

	xRtn:=KS_GetCurveCoeff(
			1(*i_byCurveType*),
			iPoitMax(*i_iPoitNum_Max*),
			ADR(io_astTaperPoint[1])(*i_dwSaAdr_Point_XY*),
			ADR(iValidPoitNum)(*i_piValidPoitNum*),
			ADR(rFitCoeff_A)(*i_prFitCoeff_A*),
			ADR(rFitCoeff_B)(*i_prFitCoeff_B*),
			ADR(rFitCoeff_C)(*i_prFitCoeff_C*));
	(*输出的形式是a*x*x+b*x+C*)
	IF NOT xRtn THEN(*未报错@至少2个点*)
		lrCurrentTaper:=rFitCoeff_A*i_rDiamCurAxis*i_rDiamCurAxis+
						rFitCoeff_B*i_rDiamCurAxis+
						rFitCoeff_C;
		(*限值处理*)
		IF	iMinDiamIndex>0 AND iMinDiamIndex<=iPoitMax AND(*索引合法判断*)
			iMaxDiamIndex>0 AND iMaxDiamIndex<=iPoitMax THEN(*索引合法判断*)
			(*最小值处理*)
			rMinDiam:= io_astTaperPoint[iMinDiamIndex].rX;
			IF i_rDiamCurAxis<=rMinDiam THEN
				lrCurrentTaper:=rFitCoeff_A*rMinDiam*rMinDiam+
								rFitCoeff_B*rMinDiam+
								rFitCoeff_C;
			END_IF
			(*最大值处理*)
			rMaxDiam:= io_astTaperPoint[iMaxDiamIndex].rX;
			IF i_rDiamCurAxis>=rMaxDiam THEN
				lrCurrentTaper:=rFitCoeff_A*rMaxDiam*rMaxDiam+
								rFitCoeff_B*rMaxDiam+
								rFitCoeff_C;
			END_IF
(*
			(*2025.3.3.112928 调整*)
			(*2021.8.30.164530 |*)
			(*不控制的时候按照最大锥度输出*)
			IF NOT i_xTaperCurCTLEn THEN
				lrCurrentTaper:=MAX(rFitCoeff_A*rMinDiam*rMinDiam+rFitCoeff_B*rMinDiam+rFitCoeff_C,
								rFitCoeff_A*rMaxDiam*rMaxDiam+rFitCoeff_B*rMaxDiam+rFitCoeff_C);(*取最大值*)
				(*增加一个变量单独控制停机的锥度*)
				lrCurrentTaper:=MAX(lrCurrentTaper,i_rTaperValue_Stop);

			END_IF
*)
		ELSE
			lrCurrentTaper:=22.2;(*就随便给一个特殊值吧@有可能能指导查找问题*)
		END_IF
	ELSE(*拟合失败了@按照最大点输出*)
		IF iMaxDiamIndex>0 AND iMaxDiamIndex<=iPoitMax THEN(*索引合法判断*)
			lrCurrentTaper:=io_astTaperPoint[iMaxDiamIndex].rY;
		END_IF
	END_IF

	(*2025.3.29.151918+*)
	(*不控制的时候按照最大锥度输出*)
	IF NOT i_xTaperCurCTLEn THEN
		lrCurrentTaper:=i_rTaperValue_Stop;
	END_IF
ELSE(*2点直线*)
	lrCurrentTaper:=KS_Taper_Straight(
			i_rDiamCurAxis,
			i_rTaper_Begin_Rw,
			i_rTaper_End_Rw,
			i_rDiamTaper_Begin_Rw,
			i_rDiamTaper_End_Rw
			);
	
	(*2021.8.30.164530 |*)
	(*不控制的时候按照最大锥度输出*)
	IF NOT i_xTaperCurCTLEn THEN
(*
		lrCurrentTaper:=MAX(pstStGrpParam^.lrTaper_Begin_Rw,pstStGrpParam^.lrTaper_End_Rw);(*取最大值*)
		(*增加一个变量单独控制停机的锥度*)
		lrCurrentTaper:=MAX(lrCurrentTaper,i_rTaperValue_Stop);
*)
		(*2025.3.29.151937+*)
		lrCurrentTaper:=i_rTaperValue_Stop;
	END_IF
END_CASE







lrDelTaper:=INT_TO_LREAL(iMaxTaper)/INT_TO_LREAL(iMaxTimeTOMaxTaper);
(*rWatch:=lrCurrentTaper;*)
IF lrCurrentTaper> lrPreCurrentTaper THEN
	IF (lrCurrentTaper-lrPreCurrentTaper) > lrDelTaper THEN
		lrCurrentTaper:=lrPreCurrentTaper+lrDelTaper;
	ELSE;
	END_IF
ELSIF  lrCurrentTaper< lrPreCurrentTaper THEN
	IF (lrPreCurrentTaper-lrCurrentTaper) > lrDelTaper THEN
		lrCurrentTaper:=lrPreCurrentTaper-lrDelTaper;
	ELSE;
	END_IF
ELSE;
END_IF

o_rTaper_Cur:= LREAL_TO_REAL(lrCurrentTaper);
lrPreCurrentTaper:=lrCurrentTaper;