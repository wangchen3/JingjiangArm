(*@CES
Name=KS_FB_GetPIDMul
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=0d44f791-d70b-4464-9f10-fe1428a728b2
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_GetPIDMul
VAR_INPUT
	i_xEn:BOOL;
	i_xCutFinish:BOOL;(*裁切完成标志*)
	i_xCutDneResetPidEn:BOOL;
	i_piCutDneResetPidMultiple:POINTER TO INT;(*接料后放料PID放大倍数|单位修改为%2019.11.26.074236*)
	i_iCutDneResetPidRemainTime:INT;(*保持时间S*)
	i_iCutDneResetPidToDefaultTime:INT;(*恢复到默认的时间*)

	(*2019.11.22.084326  增加小卷径时pid放大一定倍数的逻辑|按照直线方式变化|大卷径小系数，小卷径大系数*)
	i_xSmallDiaMulEn:BOOL;
	i_rDia_Cur:LREAL;
	i_iSmallDiaMulSa:INT:=200;(*进入该方式的启动卷径|大卷径*)
	i_iSmallDiaMulEd:INT:=100;(*结束的卷径|写死为最小卷径*)
	i_iSmallDiaMulSa_Coeff:INT:=100;(*系数|单位%*)
	i_iSmallDiaMulEd_Coeff:INT:=300;(*系数|单位%*)
	i_iCycleTime_Plc: INT;(*周期时间*)
END_VAR
VAR_OUTPUT
	o_xEn:BOOL;
	o_rCutDneResetPidMul:REAL;(*接料后倍数|单位是1*)
	o_rSmallDia_Coeff: REAL;(*小卷径倍数|单位是%*)
END_VAR
VAR
	xCutDneCanResetPid: BOOL:=FALSE;(*可以放大pid标志*)
	xCutDneResetPidResume: BOOL:=FALSE;(*pid恢复标志*)
	iCutDneResetPidMaxMul:INT:=2;(*最大倍数*)
	lrCutDneResetPidMul: LREAL;
	iCnt: INT;

	(*小卷启动pid增大一定倍数逻辑使用的变量*)
	lrCoeff: LREAL;
	xCoeffEn: BOOL;
	lrK: LREAL;
END_VAR
{IMPLEMENTATION}
(*2019.10.12.212315 裁切完成后pid值增大一定的倍数功能*)
IF i_piCutDneResetPidMultiple<>0 THEN
	IF i_piCutDneResetPidMultiple^>1000 THEN(*倍数最大10倍  最小1倍*)
		 i_piCutDneResetPidMultiple^:=1000;
	ELSIF i_piCutDneResetPidMultiple^<=0 THEN
		i_piCutDneResetPidMultiple^:=100;
	END_IF
	iCutDneResetPidMaxMul:=i_piCutDneResetPidMultiple^;(*PID放大的最大倍数*)
ELSE
	iCutDneResetPidMaxMul:=100;
END_IF

IF i_xCutFinish AND NOT xCutDneCanResetPid THEN(*裁切完成*)
	xCutDneCanResetPid:=TRUE;
END_IF

IF i_iCycleTime_Plc=0 THEN
	i_iCycleTime_Plc:= 20;
END_IF
lrCutDneResetPidMul:=100;
IF i_xCutDneResetPidEn THEN
	IF xCutDneCanResetPid THEN
		lrCutDneResetPidMul:=INT_TO_LREAL(iCutDneResetPidMaxMul);
		iCnt:=iCnt+1;
		IF iCnt>=i_iCutDneResetPidRemainTime*1000/i_iCycleTime_Plc THEN(*持续时间.若为0则从最大倍数开始递减*)
			xCutDneCanResetPid:=FALSE;
			xCutDneResetPidResume:=TRUE;
			iCnt:=0;
		END_IF
	ELSE
		IF xCutDneResetPidResume THEN
			IF iCnt>=i_iCutDneResetPidToDefaultTime*1000/i_iCycleTime_Plc THEN
				xCutDneResetPidResume:=FALSE;
			ELSE
				iCnt:=iCnt+1;
				IF i_iCutDneResetPidToDefaultTime<>0 THEN
					lrCutDneResetPidMul:=INT_TO_LREAL(iCutDneResetPidMaxMul)-
						INT_TO_LREAL(iCutDneResetPidMaxMul-100)/
						i_iCutDneResetPidToDefaultTime/1000*i_iCycleTime_Plc*iCnt;
				END_IF
			END_IF
		ELSE
			iCnt:=0;
		END_IF
	END_IF
ELSE
	xCutDneCanResetPid:=FALSE;
	xCutDneResetPidResume:=FALSE;
	iCnt:=0;
END_IF
o_rCutDneResetPidMul:=LREAL_TO_REAL(lrCutDneResetPidMul/100);
IF lrCutDneResetPidMul=100 THEN o_rCutDneResetPidMul:=1;END_IF


(*2019.10.7.093811 在小卷径的时候针对pid增加了系数|200直径--->100直径|Liu.yt*)
IF i_rDia_Cur<=i_iSmallDiaMulSa THEN
	xCoeffEn:=TRUE;
ELSIF i_rDia_Cur>=i_iSmallDiaMulSa+20 THEN(*增加了浮动区间20mm*)
	xCoeffEn:=FALSE;
END_IF

IF i_xSmallDiaMulEn THEN;
ELSE
	xCoeffEn:=FALSE;
END_IF

IF xCoeffEn THEN
	IF i_iSmallDiaMulEd<>i_iSmallDiaMulSa THEN(*起始和结束的卷径不相等*)
		(*2023.2.17.151740*)
		lrK:=INT_TO_LREAL(i_iSmallDiaMulEd_Coeff-i_iSmallDiaMulSa_Coeff)/(i_iSmallDiaMulEd-i_iSmallDiaMulSa);
	ELSE
		lrK:=0;(*卷径一样的时候 按照大卷径系数输出！*)
	END_IF

	lrCoeff:=lrK*i_rDia_Cur+(i_iSmallDiaMulSa_Coeff-lrK*i_iSmallDiaMulSa);
	IF lrCoeff>i_iSmallDiaMulEd_Coeff THEN lrCoeff:=i_iSmallDiaMulEd_Coeff;END_IF
	IF lrCoeff<i_iSmallDiaMulSa_Coeff THEN lrCoeff:=i_iSmallDiaMulSa_Coeff;END_IF
ELSE
	lrCoeff:=100;
END_IF
o_rSmallDia_Coeff:= LREAL_TO_REAL(lrCoeff/100.0);
IF lrCoeff=100 THEN o_rSmallDia_Coeff:=1;END_IF