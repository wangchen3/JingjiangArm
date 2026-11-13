(*@CES
Name=KS_FB_GetKpid
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=b21071f8-c6ec-480a-ba8e-e12362a853f5
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_GetKpid
VAR_INPUT
	i_xEn: BOOL;
	i_xCutFinish: BOOL;(*裁切完成标志*)
	i_iCycleTime_Plc: INT;(*周期时间*)
	i_rInitP: REAL;(*初始PID*)
	i_rInitI: REAL;
	i_rInitD: REAL;
	i_rDia_Cur: REAL;(*当前料卷卷径*)
	i_rThresholdCoeff: REAL:= 0.1;(*阈值系数*)
	i_xFlag_Cut_End: BOOL;
	i_xCutDneResetPidEn						: BOOL := FALSE;
	i_piCutDneResetPidMultiple				: POINTER TO INT;(*接料后放料PID放大倍数|单位修改为%2019.11.26.074236*)
	i_iCutDneResetPidRemainTime				: INT;(*保持时间S*)
	i_iCutDneResetPidToDefaultTime			: INT;(*恢复到默认的时间*)

	i_xSmallDiaMulEn						: BOOL:= FALSE;
	i_iSmallDiaMulSa						: INT:=200;(*进入该方式的启动卷径|大卷径*)
	i_iSmallDiaMulEd						: INT:=100;(*结束的卷径|写死为最小卷径*)
	i_iSmallDiaMulSa_Coeff					: INT:=100;(*系数|单位%*)
	i_iSmallDiaMulEd_Coeff					: INT:=300;(*系数|单位%*)
	i_xPseudoRandomTsting					: BOOL;(*伪随机测试标志||PID使用默认值*)
END_VAR
VAR_OUTPUT
	o_xEno									: BOOL;(*Indicated to i_xEn|*)
	o_iErNo									: INT;(*错误代码\-1:参数错误|*)
	o_rKp									: REAL;(*实际要使用的Kp*)
	o_rKi									: REAL;(*实际要使用的Ki*)
	o_rKd									: REAL;(*实际要使用的Kd*)
END_VAR
VAR
	iDiaStep								: INT;(*卷径区间步进*)	
	iDia_Min								: INT:=200;(*卷径区间小*)
	iDia_Max								: INT:=2000;(*卷径区间大*)
	iMaxNum									: INT;	
	aiDiaInterval							: ARRAY [0..30] OF INT;(*卷径区间数组*)
	iN										: INT;	
	axArea									: ARRAY [1..31] OF BOOL;
	rInitDia								: REAL;	
	xInit									: BOOL;
	iCurArea								: INT;	
	iMinDia									: INT;
	iMaxDia									: INT;
	rMinDiaThreshold						: REAL;
	rMaxDiaThreshold						: REAL;	
	xPreCutFinsh							: BOOL;	
	rAverageDia							: REAL;	
	arPid									: ARRAY [1..3] OF REAL;(*当前的pid*)
	arPrePid								: ARRAY [1..3] OF REAL;(*之前的pid*)
	axDne									: ARRAY [1..3] OF BOOL;(*变化完成*)
	fbKS_FB_GetPIDMul						: KS_FB_GetPIDMul;
	rCutDneResetPidMul						: REAL;
	rSmallDia_Coeff							: REAL;	
END_VAR

{IMPLEMENTATION}
o_xEno:= i_xEn;
o_iErNo:= 0;

IF i_xEn THEN
	iDiaStep:=100;(*分段区间的间隔*)
	iMaxNum:=(iDia_Max-iDia_Min)/iDiaStep+1;	
	aiDiaInterval[0]:=90;(*取一个较小的卷径值*)(*最后的区间为90，200，300，400，500。。。2000*)	
	FOR iN:=1 TO iMaxNum-1 BY 1 DO
		aiDiaInterval[iN]:=iDia_Min+iDiaStep*(iN-1);
	END_FOR
	aiDiaInterval[iMaxNum]:=iDia_Max;
	(*以小中卷径的中间值作为和初始pid对应的卷径大小*)
	rInitDia:=350;
	IF i_rDia_Cur>iDia_Max THEN(*最大输入卷径*)
		i_rDia_Cur:=iDia_Max;
	END_IF

	IF i_rDia_Cur<90 THEN(*最小输入卷径*)
		i_rDia_Cur:=90;
	END_IF

	FOR iN:=1 TO 30 BY  1 DO(*清除标志*)
		axArea[iN]:=FALSE;
	END_FOR
	IF i_rDia_Cur<=aiDiaInterval[1] THEN(*小于最小卷径的时候*)
		axArea[1]:=TRUE;
	ELSE
		FOR iN:=1 TO iMaxNum-1 BY 1 DO
			IF i_rDia_Cur>aiDiaInterval[iN] AND  i_rDia_Cur<=aiDiaInterval[iN+1] THEN
				axArea[iN+1]:=TRUE;
				EXIT;
			END_IF
		END_FOR
	END_IF
	


	FOR iN:=1 TO iMaxNum BY  1 DO(*定位上个周期卷径所在的区间*)
		IF axArea[iN] THEN
			IF NOT xInit THEN
				xInit:=TRUE;
				iCurArea:=iN;
			END_IF
			IF iCurArea>iN THEN(*卷径值从大区间变为小区间*)
				iMinDia:=aiDiaInterval[iN-1];
				iMaxDia:=aiDiaInterval[iN];
				rMinDiaThreshold:=0;
				rMaxDiaThreshold:=iMaxDia*i_rThresholdCoeff;
			ELSIF  iCurArea<iN THEN(*卷径值从大区间变为小区间*)
				iMinDia:=aiDiaInterval[iN-1];
				iMaxDia:=aiDiaInterval[iN];
				rMinDiaThreshold:=iMinDia*i_rThresholdCoeff;
				rMaxDiaThreshold:=0;
			ELSE
				iMinDia:=aiDiaInterval[iN-1];
				iMaxDia:=aiDiaInterval[iN];
				rMinDiaThreshold:=0;
				rMaxDiaThreshold:=0;
			END_IF

			IF rMaxDiaThreshold>iDiaStep/2 THEN
				rMaxDiaThreshold:=iDiaStep/2;
			END_IF

			IF rMinDiaThreshold>iDiaStep/2 THEN
				rMinDiaThreshold:=iDiaStep/2;
			END_IF
			EXIT;
		END_IF
	END_FOR
	IF i_xCutFinish AND NOT xPreCutFinsh THEN(*裁切换料完成了*)(*裁切换料完成时不再考虑阈值问题2018.9.6.210051添加by liu.yt*)
		rMinDiaThreshold:=0;
		rMaxDiaThreshold:=0;
	END_IF
	xPreCutFinsh:=i_xCutFinish;

	IF (i_rDia_Cur>(iMinDia+rMinDiaThreshold)) AND (i_rDia_Cur<=(iMaxDia-rMaxDiaThreshold)) THEN
		iCurArea:=iN;
	END_IF

	IF iCurArea>iN THEN
		iCurArea:=iN+1;
		IF iCurArea>iMaxNum THEN
			iCurArea:=iMaxNum;
		END_IF
	ELSIF  iCurArea<iN THEN
		iCurArea:=iN-1;
		IF iCurArea<1 THEN
			iCurArea:=1;
		END_IF
	ELSE;
	END_IF

	iMinDia:=aiDiaInterval[iCurArea-1];
	iMaxDia:=aiDiaInterval[iCurArea];
	rAverageDia:=INT_TO_REAL(iMinDia+iMaxDia)/2;
	IF rAverageDia<>0 THEN
		arPid[1]:=i_rInitP*rInitDia/rAverageDia;
		arPid[2]:=i_rInitI*rInitDia/rAverageDia;
		arPid[3]:=i_rInitD*rInitDia/rAverageDia;
	ELSE
		arPid[1]:=i_rInitP;
		arPid[2]:=i_rInitI;
		arPid[3]:=i_rInitD;
		o_iErNo:=o_iErNo+1;
	END_IF

	(*--------------------------------------------------|2019.11.28.152830_*)
	(*裁切换料PID放大功能|小卷径pid增大倍数|*)
	fbKS_FB_GetPIDMul(
		i_xEn:= TRUE,
		i_xCutFinish:= i_xCutFinish,
		i_xCutDneResetPidEn:= i_xCutDneResetPidEn,
		i_piCutDneResetPidMultiple:= i_piCutDneResetPidMultiple,
		i_iCutDneResetPidRemainTime:= i_iCutDneResetPidRemainTime,
		i_iCutDneResetPidToDefaultTime:= i_iCutDneResetPidToDefaultTime,
		i_xSmallDiaMulEn:= i_xSmallDiaMulEn,
		i_rDia_Cur:= i_rDia_Cur,
		i_iSmallDiaMulSa:= i_iSmallDiaMulSa,
		i_iSmallDiaMulEd:= i_iSmallDiaMulEd,
		i_iSmallDiaMulSa_Coeff:= i_iSmallDiaMulSa_Coeff,
		i_iSmallDiaMulEd_Coeff:= i_iSmallDiaMulEd_Coeff,
		i_iCycleTime_Plc:= i_iCycleTime_Plc,
		o_xEn=> ,
		o_rCutDneResetPidMul=> rCutDneResetPidMul,
		o_rSmallDia_Coeff=> rSmallDia_Coeff);
	IF rCutDneResetPidMul<>1 THEN
		arPid[1]:=arPid[1]*rCutDneResetPidMul;
(*2022.9.13.100541*)
(*
		alrPid[2]:=alrPid[2]*rCutDneResetPidMul;
		alrPid[3]:=alrPid[3]*rCutDneResetPidMul;
*)
	ELSIF rSmallDia_Coeff<>1 THEN
		arPid[1]:=arPid[1]*rSmallDia_Coeff;
(*只放大了p值*)
(*
		alrPid[2]:=alrPid[2]*rSmallDia_Coeff;
		alrPid[3]:=alrPid[3]*rSmallDia_Coeff;
*)
	END_IF
	(*--------------------------------------------------|End|*)


(*2019.4.4.114213增加了pid切换直线变换逻辑|liu.yt*)
	IF NOT xInit THEN
		xInit:=TRUE;
		arPrePid:=arPid;
	END_IF
(**********************************)
(*2019.6.12.104845|niu.j|PID切换时间由10s改成5s，现场反馈裁切后摆臂震荡*)
	IF i_iCycleTime_Plc=0 THEN
		i_iCycleTime_Plc:= 20;
	END_IF
	axDne[1]:=KS_ThisStepThatByStraightLine(
								arPrePid[1],
								arPid[1],
								ADR(o_rKp),
								5,
								i_iCycleTime_Plc,
								i_xFlag_Cut_end);
	IF axDne[1] THEN
		arPrePid[1]:=arPid[1];
	END_IF
(*\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*)
	axDne[2]:=KS_ThisStepThatByStraightLine(
								arPrePid[2],
								arPid[2],
								ADR(o_rKi),
								5,
								i_iCycleTime_Plc,
								i_xFlag_Cut_end);
	IF axDne[2] THEN
		arPrePid[2]:=arPid[2];
	END_IF
(*##################################*)
	axDne[3]:=KS_ThisStepThatByStraightLine(
								arPrePid[3],
								arPid[3],
								ADR(o_rKd),
								5,
								i_iCycleTime_Plc,
								i_xFlag_Cut_end);
	IF axDne[3] THEN
		arPrePid[3]:=arPid[3];
	END_IF
	(*2022.11.2.104544*)
	(*2022.9.10.101415 增加了伪随机的测试代码|2022.9.10.101424*)
	IF i_xPseudoRandomTsting THEN(*在处于伪随机测试|pid使用输入值*)
		o_rKp:=i_rInitP;
		o_rKi:=i_rInitI;
		o_rKd:=i_rInitD;
	END_IF
	
ELSE
	;
END_IF
