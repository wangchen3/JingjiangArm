(*@CES
Name=KS_FB_Coating_Tension
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=b2750bde-e2fb-4c3e-bf55-6bf4b42d8bc9
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_Coating_Tension(*涂布张力算法|传感器有两种：1是使用PI调整计算周长调整周长；2是使用周长调整*)
(*张力调整方式:
0-手动调整周长
1-摆臂调整方式下,稳定后调整周长
2-张力传感器方式下,稳定后调整周长
3-张力传感器下直接调整周长
4-摆臂方式下,一直使用pid(2022.10.24.205316)*)
(*调整速度限值值修改到2--10m/min*)
VAR_INPUT
	i_xEn:BOOL;(*涂布张力使能*)
	i_xCoatingAdjDir:BOOL;(*涂布调整方向*)
	i_byCoatingAdjWay:BYTE;(*调整方式:0为不自动调整；1为摆臂模式*)
	i_lrCurrentVel:LREAL;(*当前速度*)
	i_lrFilmVel:LREAL;(*料膜速度*)
	i_lrCoatingGirth:LREAL;(*涂布版周长*)
	i_lrAnalog:LREAL;(*相对于中位的模拟量值*)
	i_lrP:LREAL;
	i_lrD:LREAL;
	(*pi限制值单位%|2022.10.13.124543*)
	i_byVelLimit_PerCent:BYTE;(*速度限制百分比%*)
END_VAR
VAR_OUTPUT
	o_xEn:BOOL;(**)
	o_lrCoatingVel:LREAL;(*涂布速度*)
	o_lrCoatingUsingGirth:LREAL;(*涂布使用的版周长*)
END_VAR
VAR


	alrArrDataBak			: ARRAY [1..10] OF LREAL;

	lrCoatingPI_Value		: LREAL;
	iCoeff					: INT;
	rMaxDelVel				: REAL;(*单个周期最大的调整量*)
	lrAddValue				: LREAL:=0;(*叠加的调整量*)
	iVelocityLimit			: INT:=10;(*速度限值 *)
	xCoatingPIAdj			: BOOL:=FALSE;
	fbKS_FB_CalGirthLogic	: KS_FB_CalGirthLogic_Coating;(*周长调整功能块*)
	iN						: INT;
	xCoatAdjFlag			: BOOL;(*涂布调整标志*)

	xGirthCalFinish			: BOOL;
	lrDel					: LREAL:=0;
	iDataBak_Index: INT;
END_VAR

{IMPLEMENTATION}
(*根据调整速度计算版周长 并进行补偿*)
fbKS_FB_CalGirthLogic(
	i_xEn:=TRUE,
	i_xAdjNewWay:=i_xEn AND (i_byCoatingAdjWay=1 OR i_byCoatingAdjWay=2) ,
						(*进行摆臂涂布调整或者张力传感器1的时候 才进行周长的计算以及补偿*)
	i_xGirthAdj:=i_xEn AND (i_byCoatingAdjWay=3),(*张力传感器2的方式直接调整版周长*)
	i_xCompensate_Dir:= (NOT i_xCoatingAdjDir),
	i_iCycleTime:=gc_TENSION_TSK_CYCLE_TIME ,
	i_lrAnalog:=i_lrAnalog ,
	i_rAnalogLimit:=0.1,
	i_lrFilmVel:=i_lrFilmVel ,
	i_lrVel:=o_lrCoatingVel,
	i_lrActualGirth:=i_lrCoatingGirth ,
	o_xEn=> ,
	o_xGirthCalFinish=>xGirthCalFinish,
	o_lrUsingGirth=>o_lrCoatingUsingGirth );

xCoatingPIAdj:=i_byCoatingAdjWay=4 OR(*2022.10.24.205601 增加了摆臂方式下pi常调整方式*)
			((i_byCoatingAdjWay=1 OR i_byCoatingAdjWay=2) AND NOT xGirthCalFinish);(*摆臂调整时 并且周长未计算完成则进行调整*)

(*涂布调整手动调整会保存在周长值中。若是自动调整的周长值则不会保存*)
IF i_byCoatingAdjWay=0 OR (*涂布周长手动调整*)
	i_byCoatingAdjWay=4 THEN(*2022.10.24.205710 增加*)
	o_lrCoatingUsingGirth:=i_lrCoatingGirth;
ELSIF i_byCoatingAdjWay=1 OR i_byCoatingAdjWay=2(*涂布摆臂调整或者)*)
		OR i_byCoatingAdjWay=3 THEN(*张力传感器方式1时*);
END_IF





o_xEn:=i_xEn;
rMaxDelVel:=0.3;(*=300/20/50 20S加速到300m/min的时候一个周期速度的变化量*)(*2018.5.22.115216 增加调整量限值*)

(*2022.10.13.124549 速度限制使用%|最小2m/min 最大10m/min*)
IF i_byVelLimit_PerCent<>0 THEN
	iVelocityLimit:=LREAL_TO_INT(i_byVelLimit_PerCent*i_lrFilmVel/100);
ELSE(*等于0按照10m/min限制-以前一直使用该值*)
	iVelocityLimit:=10;
END_IF

IF iVelocityLimit<2 THEN
	iVelocityLimit:=2;
ELSIF iVelocityLimit>10 THEN
	iVelocityLimit:=10;
END_IF

IF i_lrFilmVel=0 THEN(*料膜速度为0速的时候，调整牵引到中位。对速度进行限值*)(*2018.7.11.223054*)
	iVelocityLimit:=2;
END_IF

FOR iN:=10 TO 2 BY -1 DO
	alrArrDataBak[iN]:=alrArrDataBak[iN-1];
END_FOR
alrArrDataBak[1]:=i_lrAnalog;


IF i_xEn THEN(*涂布调整使能*)
	(*2020.5.11.163738 尝试将pd值的输入值
	相比以前放大10倍。并将d值的差值改为和上个周期的。*)
	iDataBak_Index:=5;
	IF i_byCoatingAdjWay=2 THEN
		i_lrP:=i_lrP/100;
		i_lrD:=i_lrD/100;
		iDataBak_Index:=2;
	END_IF

	lrCoatingPI_Value:=i_lrP/1000*(i_lrAnalog)+
						i_lrD/100*(alrArrDataBak[1]-alrArrDataBak[iDataBak_Index]);


	iCoeff:=1;
	IF i_xCoatingAdjDir THEN iCoeff:=-1; END_IF(*控制pi调整方向*)

	lrCoatingPI_Value:=lrCoatingPI_Value*iCoeff;


	IF i_byCoatingAdjWay=0 OR i_byCoatingAdjWay=3 THEN(*若为手动调整或者张力传感器方式2。不改变速度*)
		lrCoatingPI_Value:=0;
	END_IF

	IF ABS(lrCoatingPI_Value)>rMaxDelVel THEN(*对调整量进行限值*)
		lrCoatingPI_Value:=rMaxDelVel*lrCoatingPI_Value/ABS(lrCoatingPI_Value);
	END_IF

	lrAddValue:=lrAddValue+lrCoatingPI_Value;
	IF ABS(lrAddValue)>iVelocityLimit THEN
		lrAddValue:=iVelocityLimit*ABS(lrAddValue)/lrAddValue;
	END_IF

	o_lrCoatingVel:=i_lrCurrentVel+lrAddValue;

	IF xCoatingPIAdj THEN(*涂布速度pi调整*);
	ELSE(*不再速度pi调整，使用调整周长的方式*)
		IF i_byCoatingAdjWay=1 OR i_byCoatingAdjWay=2 THEN
			o_lrCoatingVel:=i_lrCurrentVel;
			lrAddValue:=0;
		END_IF
	END_IF
	xCoatAdjFlag:=TRUE;
	lrDel:=(lrAddValue)/1000;(*1s减速到0*)
ELSE(**)
	IF i_lrCurrentVel=0 THEN
		IF xCoatAdjFlag THEN xCoatAdjFlag:=FALSE; END_IF
	END_IF


	IF lrAddValue>0 THEN
		lrAddValue:=lrAddValue-lrDel*gc_TENSION_TSK_CYCLE_TIME;
		IF lrAddValue <0 THEN
			lrAddValue:=0;
		END_IF
	ELSIF lrAddValue<0 THEN
		lrAddValue:=lrAddValue-lrDel*gc_TENSION_TSK_CYCLE_TIME;
		IF lrAddValue >0 THEN
			lrAddValue:=0;
		END_IF
	ELSE
		lrDel:=0;
	END_IF
	o_lrCoatingVel:=i_lrCurrentVel+lrAddValue;
END_IF

IF o_lrCoatingVel<0 THEN o_lrCoatingVel:=0;END_IF