(*@CES
Name=KS_FB_CalGirthByVel
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=9f5d0384-92e8-4505-b8ed-e463be3a3529
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_CalGirthByVel
VAR_INPUT
	i_xEn:BOOL;(**)
	i_iCycleTime:INT;(*程序执行周期*)
	i_lrAnalog: LREAL;(*模拟量输入相对于中位差值变量*)
	i_rAnalogLimit:REAL;(*模拟量的限值*)
	i_lrFilmVel:LREAL;(*料膜速度值*)
	i_lrVel:LREAL;(*当前周期的调整速度值*)
	i_lrUsingGirth:LREAL;(*使用的周长值*)
	i_rAnalogSumLimit:REAL;(*模拟量累计值的限值*)
END_VAR
VAR_OUTPUT
	o_xEn:BOOL;
	o_xGirthCaled:BOOL;(*周长计算完成了~*)
	o_lrGirth:LREAL;(*计算出来的周长值*)
END_VAR
VAR


	iCycleCount: INT:=0;(*周期计数值*)
	lrCurrentVelSum:LREAL;(*当前速度累计值*)
	iN: INT;
	lrAnalogSum: LREAL;(*当前模拟量的累计值*)
	lrAver_CurrentVel: LREAL;

	alrDataFifo:ARRAY [1..2,1..c_iArrNum] OF LREAL;(*用来存放每个周期速度以及模拟量的值。一维数组代表速度值，二维数组代表模拟量值*)
	xArrInited: BOOL;(*数组初始完成*)
	iLastIndex: INT;(*100个周期之前的模拟量数据索引*)
	xAnalogValue: BOOL;(*模拟量有效*)
	iDelayCount: INT;
END_VAR
VAR CONSTANT
	c_iArrNum:INT:=100;(*数组大小暂定为100个 按20ms周期算就是2s的数据*)
END_VAR

{IMPLEMENTATION}
o_xGirthCaled:=FALSE;(*该标志只有效一个周期*)
o_lrGirth:=0;
lrAver_CurrentVel:=0;
lrCurrentVelSum:=0;
lrAnalogSum:=0;
IF i_xEn  THEN(*使能计算周长功能*)

(*保存一定时间的速度值，用来进行平均速度计算。时间暂定为2s*)
	iCycleCount:=iCycleCount+1;(*计数+1*)
	IF iCycleCount>c_iArrNum THEN(*循环存储*)
		iCycleCount:=1;
	END_IF
	alrDataFifo[1,iCycleCount]:=i_lrVel;(*速度值*)
	alrDataFifo[2,iCycleCount]:=i_lrAnalog;(*模拟量值*)

	IF iCycleCount>=c_iArrNum OR xArrInited THEN (*累计足够次数的速度值*)
		xArrInited:=TRUE;
		iDelayCount:=iDelayCount+1;
	(*计算模拟量累计值和速度累计值*)
		FOR iN:=1 TO c_iArrNum BY 1 DO
			lrCurrentVelSum:=lrCurrentVelSum+alrDataFifo[1,iN];
			IF ABS(alrDataFifo[2,iN])>i_rAnalogLimit AND iDelayCount<=500 THEN
				(*2020.3.5.104548_|iDelayCount<=300修改到500|*)
					(*累计的这段时间里的模拟量值必须都小于等于模拟量限值才有效
											iDelayCount 是用来保证在极端情况下不能满足条件也可以进入计算逻辑*)
				lrAnalogSum:=i_rAnalogSumLimit+1;(*给模拟量累计值一个大于模拟量累计限值的值，这样我们在下面的判断中则会认为无效*)
				xAnalogValue:=FALSE;
				EXIT;
			ELSE
				xAnalogValue:=TRUE;
				lrAnalogSum:=lrAnalogSum+alrDataFifo[2,iN];
			END_IF
		END_FOR

(*修改计算平均速度的条件2018.5.8.121744*)
(*(*原条件*)
		IF ABS(lrAnalogSum)>i_rAnalogSumLimit THEN(*模拟量累计值超过范围，则认为无效*);
		ELSE(*模拟量累计值在一定范围内求取速度平均值*)
			lrAver_CurrentVel:=lrCurrentVelSum/INT_TO_LREAL(c_iArrNum);
		END_IF
*)	
		iLastIndex:=(iCycleCount+1) MOD c_iArrNum;

		IF (ABS((alrDataFifo[2,iCycleCount])-(alrDataFifo[2,iLastIndex])) >0.005) OR (NOT  xAnalogValue) THEN(*模拟量2S的变化量超过范围，则认为无效*);
		ELSE(*模拟量累计值在一定范围内求取速度平均值*)
			lrAver_CurrentVel:=lrCurrentVelSum/INT_TO_LREAL(c_iArrNum);
		END_IF
	END_IF

	IF lrAver_CurrentVel<>0 AND i_lrFilmVel<>0 THEN (*平均速度不等于0 我们认为已经计算出了满足条件的平均速度值*)
		o_lrGirth:=i_lrFilmVel*i_lrUsingGirth/lrAver_CurrentVel;(*计算出理论周长值*)
		o_xGirthCaled:=TRUE;
	END_IF

ELSE
	iDelayCount:=0;
	iCycleCount:=0;
	xArrInited:=FALSE;
END_IF
o_xEn:=i_xEn;