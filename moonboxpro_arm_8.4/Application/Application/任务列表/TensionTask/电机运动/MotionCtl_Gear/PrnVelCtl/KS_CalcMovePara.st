(*@CES
Name=KS_CalcMovePara
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=11217540-9eff-4725-bda6-b930b9e4eccf
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_CalcMovePara : LREAL(*计算运动时间参数|
								控制为even段|只考虑了目标轴匀速、当前轴加速
								返回值作为最终的加速时间s|
								如果时间不能被运动时间间隔整除则会存在pt写入按照整数个
								时间间隔，这里监控的p是使用实际时间的，但是对最终的位置偏差
								没影响。
								负值为返回错误
								-1 参数错误*)
VAR_INPUT
	i_lrVelSa:LREAL;(*启动速度m/min|V0*)
	i_lrVelTar:LREAL;(*目标速度m/min|Vt*)
	i_iDeltime:INT:=21;(*速度规划间隔时间ms|pt运动时间*)
	i_lrGirth_Axis:LREAL;(*轴周长|mm*)
	i_lrReductionRatio:LREAL;(*减速比|电机侧/版辊侧*)
	i_lrDeltPos_Init:LREAL;(*初始位置偏差Pul|开始运动时目标轴和当前轴的位置p偏差*)
	i_lrDeltPos_Final:LREAL;(*最终偏差Pul|最终的目标轴和当前轴的p偏差*)
	i_dwMotorPPR:DWORD:=2097152;(*电机运动一圈的值*)
	i_iSetTime:INT;(*用来计算模数s|*)
END_VAR
VAR
	lrDeltV: LREAL;(*mm/ms*)
	uiTime_N: UINT;(**)
	iDeltT: INT;(*ms*)
	lrCoeff_Axis: LREAL;(*当前轴的比例|Pul/mm*)
	lrRtnValue: LREAL:=0;(*返回值*)
	lrVt: LREAL;(*mm/ms*)
	lrVo: LREAL;(*mm/ms*)
	lrGirth_Axis: LREAL;
	lrDeltPos_Init: LREAL;(*Pul*)
	lrDeltPos_Final:LREAL;(*Pul*)
	(*计算临时变量*)
	uiModCoeff: UINT;(*圈数取整值*)

	lrTemp: LREAL;
	lrTemp1: LREAL;



	(*目标轴位移|mm*)
	lrS_Tar: LREAL;
	(*当前轴位移|mm*)
	lrS_Cur: LREAL;
	dwTime_ms:DWORD;
	lrDelP: LREAL;
	lrDeltS: LREAL;
	lrTime:LREAL;

	lrWatchS_Tar: LREAL;
	lrWatchS_Cur: LREAL;
	lrWatchP_Tar: LREAL;
	lrWatchP_Cur: LREAL;
	lrA: LREAL;
	uiN: UINT;
	iSetTime: INT;
END_VAR
{IMPLEMENTATION}
IF i_lrVelTar<=i_lrVelSa THEN
	lrRtnValue:=-1;
END_IF
lrVt:=i_lrVelTar/60;
lrVo:=i_lrVelSa/60;
lrDeltV:=lrVt-lrVo;

iDeltT:=i_iDeltime;
IF i_iDeltime<=0 THEN
	lrRtnValue:=-1;
END_IF

(*当前轴周长*)
lrGirth_Axis:=i_lrGirth_Axis;
IF lrGirth_Axis<=0 THEN
	lrRtnValue:=-1;
END_IF


IF i_dwMotorPPR<=0 THEN
	lrRtnValue:=-1;
END_IF

IF i_lrReductionRatio<=0 THEN
	lrRtnValue:=-1;
END_IF

(*初始位置偏差Pul|开始运动时目标轴和当前轴的位置p偏差*)
lrDeltPos_Init:=i_lrDeltPos_Init;
lrDeltPos_Init:=KS_MOD_LREAL(lrDeltPos_Init,(i_dwMotorPPR*i_lrReductionRatio));



(*最终偏差Pul|最终的目标轴和当前轴的p偏差*)
lrDeltPos_Final:=i_lrDeltPos_Final;
lrDeltPos_Final:=KS_MOD_LREAL(lrDeltPos_Final,(i_dwMotorPPR*i_lrReductionRatio));


iSetTime:=i_iSetTime;
IF i_iSetTime>=500 THEN(*防止溢出*)
	iSetTime:=500;
END_IF


IF lrRtnValue=0 THEN(*未有错误*)
	dwTime_ms:=(iSetTime)*1000;
	uiTime_N:=(iSetTime)*1000/iDeltT;
	lrA:=lrDeltV/dwTime_ms;

	(*当前轴比例|版辊距离mm转换为电机脉冲值*)
	lrCoeff_Axis:=i_lrReductionRatio*i_dwMotorPPR/i_lrGirth_Axis;(*Pul/mm*)

	(*计算模数值*)
	(*运动的位移*)
	lrS_Tar:=lrVt*dwTime_ms;(*mm*)
	lrS_Cur:=uiTime_N*lrVo*iDeltT+0.5*lrA*iDeltT*iDeltT*uiTime_N*(1+uiTime_N)+
			lrVt*(dwTime_ms-uiTime_N*iDeltT);(*mm*)
	lrDeltS:=lrS_Tar-lrS_Cur;
	IF lrDeltS<=0 THEN
		lrRtnValue:=-2;
	END_IF

	(*转换为电机侧的脉冲*)
	lrDelP:=lrDeltS*lrCoeff_Axis;

	lrTemp:=lrDeltPos_Init+lrDelP-lrDeltPos_Final;
	IF lrTemp<=0 THEN
		lrRtnValue:=-3;
	END_IF
	lrTemp1:=i_dwMotorPPR*i_lrReductionRatio;

	lrTemp:=lrTemp/lrTemp1;
	(*取整数*)

	(*圈数值取整数|版辊圈数*)
	uiModCoeff:=LREAL_TO_UINT(lrTemp);
	IF uiModCoeff<lrTemp THEN
		uiModCoeff:=uiModCoeff+1;
	END_IF

	(*计算需要的时间|按照这个时间可以在目标速度时达到位置同步*)
	IF lrRtnValue=0 THEN
		(*反算时间*)
		lrDelP:=lrDeltPos_Final+uiModCoeff*i_lrReductionRatio*i_dwMotorPPR-lrDeltPos_Init;
		lrDeltS:=lrDelP/lrCoeff_Axis;

		(*寻找复合条件的时间|时间/21的余数小于21*)
		FOR uiN:=uiTime_N TO uiTime_N+10000  BY 1 DO
			lrTemp:=lrDeltV*iDeltT*iDeltT*(1+uiN)*uiN*0.5;
			lrTemp1:=(-lrDeltS-uiN*lrVo*iDeltT+uiN*iDeltT*lrVt);
			lrTime:=lrTemp/lrTemp1;

			IF lrTime-uiN*iDeltT<=iDeltT THEN
				EXIT;
			END_IF

			IF uiN=uiTime_N+10000 THEN(*没有找到|输出负值 标记*)
				lrTime:=-4;
			END_IF
		END_FOR

	END_IF

	IF lrRtnValue=0 THEN
		lrRtnValue:=LREAL_TO_REAL(lrTime/1000);

		(*用于监控*)
		lrWatchS_Tar:=lrVt*lrTime;(*mm*)
		uiTime_N:=uiN;
		lrA:=lrDeltV/lrTime;
		lrWatchS_Cur:=uiTime_N*lrVo*iDeltT+0.5*lrA*iDeltT*iDeltT*uiTime_N*(1+uiTime_N)+
					lrVt*(lrTime-uiTime_N*iDeltT);(*mm*)
		lrWatchP_Tar:=lrWatchS_Tar*lrCoeff_Axis;
		lrWatchP_Cur:=lrWatchS_Cur*lrCoeff_Axis;
	END_IF
END_IF
KS_CalcMovePara:=lrRtnValue;