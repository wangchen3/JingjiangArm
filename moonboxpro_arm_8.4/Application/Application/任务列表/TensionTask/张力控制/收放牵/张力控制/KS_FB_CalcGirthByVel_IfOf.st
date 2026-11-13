(*@CES
Name=KS_FB_CalcGirthByVel_IfOf
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=2b108746-d302-40a1-8059-c5776d7629bb
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_CalcGirthByVel_IfOf
VAR_INPUT
	i_xEn: BOOL;
	i_xCalcGirthEn:BOOL;(**)
	i_rVel_Film:REAL;(*料膜速度*)
	i_iCycleTime_Plc:INT;(*程序执行周期*)
	i_rAnalogLimit:REAL;(*模拟量的限值*)
	i_rUsingGirth:REAL;(*使用的周长值*)
	i_rAnalogSumLimit:REAL;(*模拟量累计值的限值*)
	i_rAxisVel_Cur:REAL;(*当前轴速度*)
	i_rAi_Swing: REAL; (*摆臂当前值*)
END_VAR
VAR_OUTPUT
	o_xEno:BOOL;
	o_iErNo: INT;
	o_xGirthCaled:BOOL;(*周长计算完成了~*)
	o_rGirth:REAL;(*计算出来的周长值*)
END_VAR
VAR
	rAver_CurrentVel: REAL;
	rCurrentVelSum:LREAL;(*当前速度累计值*)
	rAnalogSum: REAL; (*当前模拟量累计值*)
	iCycleCount: INT;
	arDataFifo:ARRAY [1..2,1..c_iArrNum] OF REAL;(*用来存放每个周期速度以及模拟量的值。一维数组代表速度值，二维数组代表模拟量值*)
	xArrInited: BOOL;		(*数组初始化完成*)
	iDelayCount: INT;
	iN: INT;
	xAnalogValue: BOOL;(*放牵模拟量有效*)
	iLastIndex: INT;
END_VAR
VAR CONSTANT
	c_iArrNum:INT:=300;(*数组大小暂定为100个 按20ms周期算就是2s的数据*)
								(*2019.7.25.125733 将计算周期拉长了！|Liu.yt*)
END_VAR
{IMPLEMENTATION}
o_xEno:= i_xEn;
o_iErNo:= 0;
IF i_xEn THEN

	o_xGirthCaled:=FALSE;(*该标志只有效一个周期*)
	o_rGirth:=0;
	rAver_CurrentVel:=0;
	rCurrentVelSum:=0;
	rAnalogSum:=0;

	IF i_xCalcGirthEn  THEN(*使能计算周长功能*)

		(*保存一定时间的速度值，用来进行平均速度计算。时间暂定为2s*)
		iCycleCount:=iCycleCount+1;(*计数+1*)
		IF iCycleCount>c_iArrNum THEN(*循环存储*)
			iCycleCount:=1;
		END_IF
		arDataFifo[1,iCycleCount]:=i_rAxisVel_Cur;(*速度值*)
		arDataFifo[2,iCycleCount]:=i_rAi_Swing;(*模拟量值*)

		(*周长计算*)
		IF iCycleCount>=c_iArrNum OR xArrInited THEN (*累计足够次数的速度值*)

			xArrInited:=TRUE;
			iDelayCount:=iDelayCount+1;
		(*计算模拟量累计值和速度累计值*)
			FOR iN:=1 TO c_iArrNum BY 1 DO
				rCurrentVelSum:=rCurrentVelSum+arDataFifo[1,iN];
				IF ABS(arDataFifo[2,iN])>i_rAnalogLimit AND iDelayCount<=500 THEN(*累计的这段时间里的模拟量值必须都小于等于模拟量限值才有效
												iDelayCount 是用来保证在极端情况下不能满足条件也可以进入计算逻辑*)
					rAnalogSum:=i_rAnalogSumLimit+1;(*给模拟量累计值一个大于模拟量累计限值的值，这样我们在下面的判断中则会认为无效*)
					xAnalogValue:=FALSE;
					EXIT;
				ELSE
					xAnalogValue:=TRUE;
					rAnalogSum:=rAnalogSum+arDataFifo[2,iN];
				END_IF
			END_FOR

			iLastIndex:=(iCycleCount+1) MOD c_iArrNum;

			IF ABS((arDataFifo[2,iCycleCount])-(arDataFifo[2,iLastIndex])) >0.005 OR NOT  xAnalogValue THEN(*模拟量2S的变化量超过范围，则认为无效*);
			ELSE(*模拟量累计值在一定范围内求取速度平均值*)
				rAver_CurrentVel:=rCurrentVelSum/INT_TO_REAL(c_iArrNum);
			END_IF
		END_IF

		IF rAver_CurrentVel<>0 AND i_rVel_Film<>0 THEN (*平均速度不等于0 我们认为已经计算出了满足条件的平均速度值*)
			o_rGirth:=i_rVel_Film*i_rUsingGirth/rAver_CurrentVel;(*计算出理论周长值*)
			o_xGirthCaled:=TRUE;
		END_IF
	ELSE
		iDelayCount:=0;
		iCycleCount:=0;
		xArrInited:=FALSE;
	END_IF
ELSE
	;
END_IF