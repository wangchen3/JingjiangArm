(*@CES
Name=KS_CheckDDA
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=d0fb5f27-f5b4-42d1-b5c4-becbafc797f1
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_CheckDDA : BOOL(*false:DDA溢出@重新计算参数|TRUE:DDA正常*)
(*
检查dda处理的合法性@时钟运行周期时间内脉冲个数不能超过1.
获取到编码器值需要通过DDA插值处理,DDA插值的周期是时钟周期
如果时钟周期的脉冲变化量超过1,插值会出现丢失脉冲的情况
如果超过则输出不合法标志,并输出建议的编码器减速比(用于分频),编码器值@该值和库的计算公式有匹配关系
重新设置异站参数。
*)
(*
公式：dwDDAMotorEnc(DDA前分辨率)=i_dwMotorEncResolution*B/A
	  dwDDAMotorEnc(>> N@右移) = i_dwRemoteEnc
*)
(*i_dwRemoteEnc 该值是131072@和套色采样精度bit=>>5相关*)
VAR_INPUT
	i_byClock_MHZ			: BYTE:=125;(*时钟@mhz*)
	i_dwMotorEncResolution	: DWORD:=4194304;(*电机的编码器分辨率*)
	i_uiRotateSpeed_Max		: UINT:=3000;(*最大转速*)
	i_dwRemoteEnc			: DWORD:=131072;(*最终异站分辨率@131072|也是套色用的使用*)
	i_rMaxPulsePCycle		: REAL:=0.95;(*每个时钟周期最大脉冲数-不能超过1|目前125mhz即8ns的脉冲个数|适当小于1,留点余量*)
	i_puiA					: POINTER TO UINT;(*分母*)
	i_puiB					: POINTER TO UINT;(*分子*)
	i_pdwSetMotorEnc		: POINTER TO DWORD;(*设置的电机分辨率@目前等于输入的分辨率值*)
	i_pdwSetMotorEnc_DDA	: POINTER TO DWORD;(*DDA后电机分辨率@默认等于输入分辨率*)
	i_pbyRshBit				: POINTER TO BYTE;(*DDA后编码器右移位数*)
END_VAR
VAR
	iN					: INT;
	dwTmp				: DWORD;
	lrTmp				: LREAL;
	lrCoeff_Min2Ns		: LREAL;(*单位换算系数@MIN->ns*)
	byClock_ns			: BYTE;(*时间@ns*)
	rPulsePCycle		: REAL;(*每个周期的脉冲数*)
	rMaxPulsePCycle		: REAL;
	xOk					: BOOL;
	uiA					: UINT:=1;(*分母*)
	uiB					: UINT:=1;(*分子*)
	dwSetMotorEnc		: DWORD:=4194304;(*设置的电机分辨率*)
	byRshBit			: BYTE:=5;(*DDA后编码器右移位数@默认值*)
	dwDDAMotorEnc_Max	: DWORD;(*最大的dda编码器分辨率|*)
	dwDDAMotorEnc		: DWORD;(*可以用的@满足移位后的分辨率=131072*)
	dwSetMotorEnc_DDA	: DWORD;(*DDA后电机分辨率*)
	dwRemoteEnc			: DWORD:=131072;(*最终异站分辨率@131072*)
END_VAR

{IMPLEMENTATION}
(*获取单位周期脉冲的阈值*)
rMaxPulsePCycle:=i_rMaxPulsePCycle;
IF rMaxPulsePCycle>1 THEN
	rMaxPulsePCycle:=1;
END_IF
(*获取异站的最终分辨率*)
dwRemoteEnc:=i_dwRemoteEnc;
IF dwRemoteEnc=0 THEN
	dwRemoteEnc:=131072;
END_IF
(*周期时间计算*)
IF i_byClock_MHZ<>0 THEN
	lrTmp:=1000.0 / BYTE_TO_LREAL(i_byClock_MHZ) ;(*ns*)
ELSE
	lrTmp:=8;
END_IF
byClock_ns:=LREAL_TO_BYTE(lrTmp);(*周期@ns*)
(*单位周期的脉冲数*)
lrCoeff_Min2Ns:=60.0 * 1000 * 1000 * 1000;
lrTmp:=UINT_TO_LREAL(i_uiRotateSpeed_Max) * i_dwMotorEncResolution;(*脉冲p/min*)
lrTmp:=lrTmp / lrCoeff_Min2Ns;(*脉冲/ns*)
lrTmp:=lrTmp * byClock_ns;(*单位周期的脉冲数*)
rPulsePCycle:=lrTmp;
(*阈值判断*)
IF rPulsePCycle <= rMaxPulsePCycle THEN(*正常*)
	xOk:=TRUE;
ELSE(*脉冲太快了*)
	xOk:=FALSE;
	rPulsePCycle:=rMaxPulsePCycle;(*每个周期的脉冲按照最大值|用于反算参数@pulse/ns*)
END_IF
(*计算建议的分频值和配置的分辨率值*)
dwSetMotorEnc:=i_dwMotorEncResolution;
dwSetMotorEnc_DDA:=dwSetMotorEnc;
IF NOT xOk THEN
	(*重新计算设置值*)
	(*反算DDA前输入的电机分辨率*)
	lrTmp:=rPulsePCycle / byClock_ns;(*单位p/ns*)
	lrTmp:=lrTmp * lrCoeff_Min2Ns;(*单位p/min*)
	lrTmp:=lrTmp / i_uiRotateSpeed_Max;(*单位p/r@即可以用的最大电机的分辨率*)
	dwDDAMotorEnc_Max:=LREAL_TO_DWORD(lrTmp);(*写入到dword*)

	(*DDA输入的分辨率经过变比(>>N@右移)需要=dwRemoteEnc|反算改变比*)
	dwTmp:= dwDDAMotorEnc_Max / dwRemoteEnc;(*保留整数*)
	(*未找到以2为低的对数公式|用循环找吧*)
	FOR iN:=2 TO 20 BY 1 DO(*最大右移20*)
		lrTmp:=EXPT(2,iN);(*2的n次方*)
		IF lrTmp > dwTmp THEN(*超过了倍数|取上一个*)
			iN:=iN-1;
			EXIT;
		ELSIF lrTmp = dwTmp THEN(*找到了*)
			EXIT;
		END_IF
	END_FOR
	byRshBit:=INT_TO_BYTE(iN);(*2025.12.9.193202*)
	dwDDAMotorEnc:=REAL_TO_DWORD(dwRemoteEnc * EXPT(2,iN));(*反算出进入dda的电机分辨率*)
	(*使用实际分辨率计算ab*)
	dwTmp:=KS_CalcGCD(dwDDAMotorEnc,i_dwMotorEncResolution);(*计算最大共约数*)
	IF dwTmp<>0 THEN
		uiA := DWORD_TO_UINT(i_dwMotorEncResolution / dwTmp);
		uiB := DWORD_TO_UINT(dwDDAMotorEnc / dwTmp);
	ELSE
		uiA:=1;
		uiB:=1;
	END_IF
	dwSetMotorEnc_DDA:=dwDDAMotorEnc;(*输出dda后的电机分辨率*)
END_IF
IF i_puiA<>0 THEN
	i_puiA^:=uiA;
END_IF
IF i_puiB<>0 THEN
	i_puiB^:=uiB;
END_IF
IF i_pdwSetMotorEnc<>0 THEN
	i_pdwSetMotorEnc^:=dwSetMotorEnc;
END_IF
IF i_pdwSetMotorEnc_DDA<>0 THEN
	i_pdwSetMotorEnc_DDA^:=dwSetMotorEnc_DDA;
END_IF
IF i_pbyRshBit<>0 THEN
	i_pbyRshBit^:=byRshBit;
END_IF
KS_CheckDDA:=xOk;