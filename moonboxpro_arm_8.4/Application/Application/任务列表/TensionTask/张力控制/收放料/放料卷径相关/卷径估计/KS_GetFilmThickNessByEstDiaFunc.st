(*@CES
Name=KS_GetFilmThickNessByEstDiaFunc
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=9700b421-fab0-4030-bfa4-7fb145ef1e2a
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_GetFilmThickNessByEstDiaFunc : BOOL
(*2023.12.02.095036 通过估计函数获取料膜厚度@目前主要只应用于接料时的10s不进行卷径补偿部分。
自动获取的方式是
*在开机印刷后超过一定的速度并且处于匀速段
*等待一定的时间后
*持续运行一定的时间后计算这段时间的平均值作为自动的厚度值*)
(*2024.03.16.101611 在停止计算的时候写入初始厚度值|
防止上次料膜太厚计算出的值和本次的薄料厚度差别太大引起异常。厚度值比实际小,对于接料影响会小一些*)
(*2024.7.24.124217 逻辑优化*)
VAR_INPUT
	i_xGetFilmThicknessEn:BOOL;(*自动获取厚度使能@印刷到达一定速度-非调试模式*)
	i_xGetFilmThickNessAuto:BOOL;(*自动获取标志@有效了就通过估计的厚度值获得。无效则通过手动输入获取*)

	i_byWaitTime_Min:BYTE:=1;(*自动满足条件后等待的时间@经过这段时间后开始计算@min*)
	i_byContinuousTime_Min:BYTE:=5;(*持续计算的时间@min*)
	i_byShakeThreshold:BYTE:=10;(*抖动阈值(最值差值法)@丝*)

	i_xEstiThikcknessValid:BOOL;(*估计的厚度值有效*)
	i_rEstiThickness:REAL;(*估计的厚度值@mm*)

	(*2024.03.16.101417*)
	i_rThickness_Init:REAL;(*初始厚度@用于初始化|在退出计算的时候写入该值*)

	i_pxAutoGetDne:POINTER TO BOOL;(*自动获取成功了*)
	i_prThickness:POINTER TO REAL;(*获取的厚度值@mm*)
	i_prTotalThickness:POINTER TO REAL;(*统计的总的厚度值@用于平均处理*)
	i_pudiTotalNum:POINTER TO UDINT;(*统计的次数值@用于平均处理*)
	i_prThickness_Max:POINTER TO REAL;
	i_prThickness_Min:POINTER TO REAL;
	i_ptLastTime:POINTER TO TIME;(*计时使用*)
END_VAR
VAR
	xAutoGetDne: BOOL;
	rThickness: REAL;
	rEstiThickness: REAL;
	rTotalThickness: REAL;
	udiTotalNum: UDINT;
	rThickness_Max: REAL;
	rThickness_Min: REAL;
	rThickness_Manu: REAL;
	tLastTime: TIME;
	tTemp:TIME;
	xEstiThikcknessValid: BOOL;
	rThickness_Init: REAL;(*2024.03.16.101525*)
END_VAR
{IMPLEMENTATION}
(*指针变量写入到临时变量*)
IF i_pxAutoGetDne <>0 THEN
	xAutoGetDne:=i_pxAutoGetDne^;
END_IF
IF i_prThickness<>0 THEN
	rThickness:=i_prThickness^;
END_IF
IF i_prTotalThickness<>0 THEN
	rTotalThickness:=i_prTotalThickness^;
END_IF
IF i_pudiTotalNum<>0 THEN
	udiTotalNum:=i_pudiTotalNum^;
END_IF
IF i_prThickness_Max<>0 THEN
	rThickness_Max:=i_prThickness_Max^;
END_IF
IF i_prThickness_Min<>0 THEN
	rThickness_Min:=i_prThickness_Min^;
END_IF
IF i_ptLastTime<>0 THEN
	tLastTime:=i_ptLastTime^;
END_IF

xEstiThikcknessValid:=i_xEstiThikcknessValid;
rEstiThickness:=i_rEstiThickness;
IF rEstiThickness<=0 OR
	rEstiThickness>=1 THEN(*1MM厚度的几乎没见过，这个只是为了别错的太离谱*)
	xEstiThikcknessValid:=FALSE;(*认为无效|复位所有内容,如果恢复了则重新计算-已经计算完成了就保持吧*)
END_IF

(*2024.03.16.101532*)
rThickness_Init:=i_rThickness_Init;
IF rThickness_Init=0 THEN
	rThickness_Init:=0.02;
END_IF



(*通过估计获取到的厚度值计算*)
(*逻辑处理*)
IF i_xGetFilmThickNessAuto AND(*使用自动获取的方式*)
	xEstiThikcknessValid THEN(*获取估计的厚度值@无效就按照手动输入处理*)
	IF i_xGetFilmThicknessEn AND(*可以自动运算了*)
		NOT xAutoGetDne THEN(*未完成*)
		(*2024.03.16.101150*)
		IF tLastTime=T#0MS THEN(*开始的时候记录时间*)
			tLastTime:=TIME();
		END_IF


		tTemp:=DWORD_TO_TIME(BYTE_TO_DWORD(i_byWaitTime_Min)*60*1000);(*转换为ms*)
		IF TIME()-tLastTime>tTemp THEN(*等待时间够了*)
			tTemp:=DWORD_TO_TIME(BYTE_TO_DWORD(i_byWaitTime_Min+i_byContinuousTime_Min)*60*1000);(*转换为ms*)
			(*累计厚度值*)
			udiTotalNum:=udiTotalNum+1;
			rTotalThickness:=rTotalThickness+rEstiThickness;
			(*记录最大值和最小值*)
			IF rThickness_Max<rEstiThickness THEN
				rThickness_Max:=rEstiThickness;
			END_IF
			IF rThickness_Min>rEstiThickness THEN
				rThickness_Min:=rEstiThickness;
			END_IF

			(*记录的时间到了@检查最大和最小值偏差是否符合要求*)
			IF TIME()-tLastTime>tTemp THEN
				(*符和要求|写入*)
				IF (rThickness_Max-rThickness_Min)<=BYTE_TO_REAL(i_byShakeThreshold)/100.0 THEN
					IF udiTotalNum<>0 THEN
						rThickness:=LREAL_TO_REAL(rTotalThickness/UDINT_TO_LREAL(udiTotalNum));
					ELSE;(*保持之前的值*)
					END_IF
					xAutoGetDne:=TRUE;(*都认为完成了*)
				ELSE(*数据不可靠@重新统计|更新记录的时间信息*)
					tLastTime:=TIME();
				END_IF
			END_IF
		ELSE(*时间还没等够呢|清除无用的变量*)
			udiTotalNum:=0;
			rTotalThickness:=0;
			rThickness_Max:=0;
			rThickness_Min:=999;(*初始化为了较大值*)
		END_IF
	ELSE(*状态还不合适的时候|清除无用的变量*)
		udiTotalNum:=0;
		rTotalThickness:=0;
		rThickness_Max:=0;
		rThickness_Min:=999;(*初始化为了较大值*)
		(*2024.03.16.101249  清零时间@开始的时候会记录*)
(*		tLastTime:=TIME();*)
		(*不再运算的时候复位下*)
		(*2024.7.24.130213 优化*)
		IF NOT i_xGetFilmThicknessEn THEN
			xAutoGetDne:=FALSE;
			IF tLastTime<>T#0MS THEN(*用于标记进入过计算逻辑*)
				tLastTime:=T#0MS;
				rThickness:=rThickness_Init;(*退出运算的时候写入初始厚度值*)
			END_IF
		END_IF
	END_IF
ELSE(*非自动获取的@手动输入*)
	udiTotalNum:=0;
	rTotalThickness:=0;
	rThickness_Max:=0;
	rThickness_Min:=999;(*初始化为了较大值*)
	IF NOT i_xGetFilmThickNessAuto THEN(*不自动获取的时候复位*)
		xAutoGetDne:=FALSE;
		(*2024.7.24.125804|*)
		IF tLastTime<>T#0MS THEN(*用于标记进入过计算逻辑*)
			tLastTime:=T#0MS;
			rThickness:=rThickness_Init;(*退出运算的时候写入初始厚度值*)
		END_IF
	END_IF
END_IF

(*1MM厚度的几乎没见过，这个只是为了别错的太离谱*)
IF rThickness<=0 OR
	rThickness>=1 THEN
	rThickness:=rThickness_Init;
END_IF


(*临时变量写入到指针变量*)
IF i_pxAutoGetDne <>0 THEN
	i_pxAutoGetDne^:=xAutoGetDne;
END_IF
IF i_prThickness<>0 THEN
	i_prThickness^:=rThickness;
END_IF
IF i_prTotalThickness<>0 THEN
	i_prTotalThickness^:=rTotalThickness;
END_IF
IF i_pudiTotalNum<>0 THEN
	i_pudiTotalNum^:=udiTotalNum;
END_IF
IF i_prThickness_Max<>0 THEN
	i_prThickness_Max^:=rThickness_Max;
END_IF
IF i_prThickness_Min<>0 THEN
	i_prThickness_Min^:=rThickness_Min;
END_IF
IF i_ptLastTime<>0 THEN
	i_ptLastTime^:=tLastTime;
END_IF