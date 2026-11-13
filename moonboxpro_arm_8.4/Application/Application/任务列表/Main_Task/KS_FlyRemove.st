(*@CES
Name=KS_FlyRemove
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=ea8acba0-5633-4be0-8daa-610d8883b0ed
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FlyRemove
VAR_INPUT
	i_iErr			: INT;	(*原始误差|丝*)
	i_xErrValid		: BOOL;	(*TRUE=本帧为有效新帧(喂入剔除);FALSE=不喂*)
	i_xLost			: BOOL;	(*TRUE=本帧为丢失帧(原样上报-32768,不算飞点)*)
	i_xReset		: BOOL;	(*TRUE=复位全部状态(工况切换时给一拍)*)
END_VAR
VAR_OUTPUT
	o_iErrResult	: INT;	(*剔除后输出:好=原值,飞点/暂缓=锁存值,丢失=原值原样*)
	o_byJudge		: BYTE;	(*0首帧 1好 2好(观察) 3飞点 4暂缓 5阶跃 6丢失*)
	o_xFake			: BOOL;	(*本帧输出被替换(飞点/暂缓)=TRUE;阶跃/丢失/好=FALSE*)
END_VAR
VAR
	KS_FLY_TRUST_WIN	: INT	:= 9;	(*趋势窗:Theil-Sen用最近N个可信点*)
	KS_FLY_NOISE_WIN	: INT	:= 31;	(*噪声窗:差分rSigma用最近N个可信值*)
	KS_FLY_DIFF_MIN		: INT	:= 8;	(*差分数不足N不用MAD(防越剔越紧螺旋)*)
	KS_FLY_SIG_PROV		: REAL	:= 2.0;	(*暖机rSigma倍数(尺度自举,量纲无关)*)
	KS_FLY_K			: REAL	:= 5.0;	(*外门槛倍数:T_out=K*rSigma*)
	KS_FLY_RET_FRAC		: REAL	:= 0.5;	(*回归门槛=该比例*外门槛(5rSigma/2.5rSigma)*)
	KS_FLY_STEP_CONFIRM	: INT	:= 2;	(*阶跃确认:连续强超门满N帧判阶跃*)
	KS_FLY_QUAR_N		: INT	:= 1;	(*阶跃确认后的观察帧数*)
	KS_FLY_HOLD_MAX		: INT	:= 3;	(*迟滞带内暂缓上限(暂缓不等于剔除)*)
	KS_FLY_OSC_WIN		: INT	:= 64;	(*振荡自愈:统计近N帧判非好占比*)
	KS_FLY_OSC_IN		: REAL	:= 0.25;	(*振荡模式进入门限*)
	KS_FLY_OSC_OUT		: REAL	:= 0.10;	(*振荡模式退出门限*)
	KS_FLY_MAD_C		: REAL	:= 1.4826;		(*MAD->正态标准差一致性系数*)
	KS_FLY_SQRT2		: REAL	:= 1.414213562;	(*根2:Var(差分)=2*rSigma^2的归一*)
	KS_FLY_EPS			: REAL	:= 1.0E-12;		(*rSigma=0保护*)
	(*状态:逐项对应C版KsFlyRemover结构体*)
	arHistVal	: ARRAY[0..30] OF REAL;		(*可信历史值:只有真实测量进*)
	auiHistIdx	: ARRAY[0..30] OF UDINT;	(*各历史点帧号(内部稠密计数,严格递增)*)
	iHistCnt	: INT;						(*历史点数(<=31)*)
	xStarted	: BOOL;						(*启动态:前2帧无条件采信;阶跃重建不回退此标志*)
	rLatch		: REAL;						(*锁存:最近好值,飞点替换用它;只被好帧更新*)
	xLatchValid	: BOOL;
	rSigma		: REAL;						(*差分MAD的rSigma估计*)
	xSigmaValid	: BOOL;						(*未估出时用暖机rSigma;阶跃只换电平不换噪声*)
	iConsec		: INT;						(*连续强超门计数(阶跃确认用)*)
	iQuar		: INT;						(*阶跃确认后的观察帧余数*)
	iHold		: INT;						(*候选期暂缓计数*)
	abyJudged	: ARRAY[0..63] OF BYTE;		(*近64帧是否判非好(振荡自愈检测用)*)
	iJudgedCnt	: INT;
	arAllDev	: ARRAY[0..15] OF REAL;		(*近16帧|新值-带中心|(含被拒帧,振荡模式估幅用)*)
	iAllDevCnt	: INT;
	xOscOn		: BOOL;						(*振荡模式开关(生效时门放宽到全幅MAD)*)
	udiIdxNext	: UDINT;					(*下一帧帧号(丢失帧不占号)*)
	(*中位数运算暂存区*)
	arSlope		: ARRAY[0..35] OF REAL;		(*Theil-Sen两两斜率(9点36对)*)
	arExt		: ARRAY[0..8] OF REAL;		(*趋势带:外推值/水平值的中位数暂存*)
	arDiff		: ARRAY[0..29] OF REAL;		(*可信历史相邻差分(<=30个)*)
	arDev		: ARRAY[0..15] OF REAL;		(*全幅偏差中位数暂存(振荡模式)*)
	(*工作变量*)
	rX			: REAL;
	rOut		: REAL;
	rA			: REAL;
	rB			: REAL;
	rD			: REAL;
	rS			: REAL;
	rTOut		: REAL;
	rTRet		: REAL;
	rRatio		: REAL;
	rTmp		: REAL;
	rMed		: REAL;
	fV			: REAL;
	fP			: REAL;
	fL			: REAL;
	i			: INT;
	j			: INT;
	n			: INT;
	m			: INT;
	iSum		: INT;
	udiIdx		: UDINT;
	udiDt		: UDINT;
	iBase		: INT;
	byJudge		: BYTE;
	(*为了加 Quantum 去处理稳态的小范围波动不报飞点*)
	arQdq		: ARRAY[0..15] OF REAL;		(*近16个非零相邻差分,数据分辨率quantum用|Yang.zj 2026.10.27+*)
	iQdqCnt		: INT;
	rPval		: REAL;						(*上一有效输入值(含被拒帧,算分辨率用)*)
	xPvalValid	: BOOL;
	udiPidx		: UDINT;					(*上一有效输入帧号(跨丢失段的差分不入分辨率)*)
	rQuantum	: REAL;						(*数据分辨率=近16个非零相邻差分最小值(需>=2个样本)*)
	xQuantumValid	: BOOL;
END_VAR

{IMPLEMENTATION}
(*==================== 复位:清零全部状态(工况切换时) ====================*)
IF i_xReset THEN
	iHistCnt:= 0;
	xStarted:= FALSE;
	rLatch:= 0.0;
	xLatchValid:= FALSE;
	rSigma:= 0.0;
	xSigmaValid:= FALSE;
	iConsec:= 0;
	iQuar:= 0;
	iHold:= 0;
	iJudgedCnt:= 0;
	iAllDevCnt:= 0;
	xOscOn:= FALSE;
	udiIdxNext:= 0;
	iQdqCnt:= 0;(*分辨率窗一并清空(工况切换)|Yang.zj 2026.10.27+*)
	xPvalValid:= FALSE;
END_IF

(*==================== 丢失帧:不喂模块,原样直通 ====================*)
IF i_xLost THEN
	o_iErrResult:= i_iErr;
	o_byJudge:= 6;(*丢失:没测到不算飞点,锁存不占位*)
	o_xFake:= FALSE;
	RETURN;
END_IF

(*==================== 非新帧周期:全部输出保持上一帧 ====================*)
IF NOT i_xErrValid THEN
	o_iErrResult:= o_iErrResult;
	o_byJudge:= o_byJudge;
	o_xFake:= o_xFake;
	RETURN;
END_IF

byJudge:= 1;(*好,默认*)
rX:= INT_TO_REAL(i_iErr);

udiIdx:= udiIdxNext;
udiIdxNext:= udiIdxNext + 1;

(*==================== 0.数据分辨率quantum:近16个非零相邻差分最小值 ====================*)
(*量化/整数数据上差分MAD可塌缩到0->门限约0,台阶式漂移被判飞点爬行;以分辨率兜底后
 *门限>=5x分辨率,台阶漂移交回趋势带原生跟随;取min对大差分(飞点)免疫,滑窗自适应;
 *连续噪声数据quantum约0不起作用|Yang.zj 2026.10.27+*)
IF xPvalValid AND (udiIdx = udiPidx + 1) THEN(*仅相邻帧的差分入分辨率,跨丢失段不作数*)
	rTmp:= ABS(rX - rPval);
	IF rTmp > 0.0 THEN
		IF iQdqCnt >= 16 THEN
			FOR i:= 0 TO 14 DO
				arQdq[i]:= arQdq[i+1];
			END_FOR
			iQdqCnt:= 15;
		END_IF
		arQdq[iQdqCnt]:= rTmp;
		iQdqCnt:= iQdqCnt + 1;
	END_IF
END_IF
rPval:= rX;
udiPidx:= udiIdx;
xPvalValid:= TRUE;
xQuantumValid:= (iQdqCnt >= 2);
IF xQuantumValid THEN
	rQuantum:= arQdq[0];
	FOR i:= 1 TO iQdqCnt-1 DO
		IF arQdq[i] < rQuantum THEN
			rQuantum:= arQdq[i];
		END_IF
	END_FOR
END_IF

(*==================== 启动期:前2帧无条件采信 ====================*)
IF NOT xStarted THEN
	(*--- 值进可信历史并刷新差分rSigma ---*)
	IF iHistCnt >= KS_FLY_NOISE_WIN THEN
		FOR i:= 0 TO KS_FLY_NOISE_WIN-2 DO
			arHistVal[i]:= arHistVal[i+1];
			auiHistIdx[i]:= auiHistIdx[i+1];
		END_FOR
		iHistCnt:= KS_FLY_NOISE_WIN - 1;
	END_IF
	arHistVal[iHistCnt]:= rX;
	auiHistIdx[iHistCnt]:= udiIdx;
	iHistCnt:= iHistCnt + 1;
	m:= iHistCnt - 1;
	IF m >= KS_FLY_DIFF_MIN THEN
		FOR i:= 0 TO m-1 DO
			arDiff[i]:= arHistVal[i+1] - arHistVal[i];
		END_FOR
		rMed:= KS_FlyMedian(ADR(arDiff), m);
		FOR i:= 0 TO m-1 DO
			arDiff[i]:= ABS(arDiff[i] - rMed);
		END_FOR
		rMed:= KS_FLY_MAD_C / KS_FLY_SQRT2 * KS_FlyMedian(ADR(arDiff), m);
		IF rMed > KS_FLY_EPS THEN
			rSigma:= rMed;
		ELSE
			rSigma:= KS_FLY_EPS;
		END_IF
		xSigmaValid:= TRUE;
	END_IF
	(*--- end push ---*)
	rLatch:= rX;
	xLatchValid:= TRUE;
	IF iHistCnt >= 2 THEN
		xStarted:= TRUE;
	END_IF
	o_iErrResult:= i_iErr;
	o_byJudge:= 0;(*首帧*)
	o_xFake:= FALSE;
	RETURN;
END_IF

(*==================== 1.趋势带参照,量出带外距离rD ====================*)
n:= KS_FLY_TRUST_WIN;
IF iHistCnt < n THEN
	n:= iHistCnt;
END_IF
IF n <= 1 THEN(*阶跃重建后的单点历史:带退化为该点*)
	rA:= arHistVal[iHistCnt-1];
	rB:= rA;
	fP:= rA;(*单点时外推P=该点,与Python _band一致(守卫>=3点时用不到)|Yang.zj 2026.10.27+*)
ELSE
	iBase:= iHistCnt - n;
	m:= 0;
	FOR i:= iBase TO iHistCnt-1 DO
		FOR j:= i+1 TO iHistCnt-1 DO
			udiDt:= auiHistIdx[j] - auiHistIdx[i];(*帧号严格递增,dt>0*)
			IF udiDt > 0 THEN
				arSlope[m]:= (arHistVal[j] - arHistVal[i]) / UDINT_TO_REAL(udiDt);
				m:= m + 1;
			END_IF
		END_FOR
	END_FOR
	IF m > 0 THEN
		fV:= KS_FlyMedian(ADR(arSlope), m);
	ELSE
		fV:= 0.0;
	END_IF
	FOR i:= iBase TO iHistCnt-1 DO
		arExt[i-iBase]:= arHistVal[i] + fV * UDINT_TO_REAL(udiIdx - auiHistIdx[i]);
	END_FOR
	fP:= KS_FlyMedian(ADR(arExt), n);(*外推预测P*)
	FOR i:= iBase TO iHistCnt-1 DO
		arExt[i-iBase]:= arHistVal[i];
	END_FOR
	fL:= KS_FlyMedian(ADR(arExt), n);(*近期水平L*)
	IF fP < fL THEN
		rA:= fP;
		rB:= fL;
	ELSE
		rA:= fL;
		rB:= fP;
	END_IF
END_IF
rD:= 0.0;
IF rX < rA THEN
	rD:= rA - rX;
ELSIF rX > rB THEN
	rD:= rX - rB;
END_IF

(*==================== 2.振荡自愈 ====================*)
rRatio:= 0.0;
IF iJudgedCnt > 0 THEN
	iSum:= 0;
	FOR i:= 0 TO iJudgedCnt-1 DO
		iSum:= iSum + abyJudged[i];
	END_FOR
	rRatio:= INT_TO_REAL(iSum) / INT_TO_REAL(iJudgedCnt);
END_IF
IF iJudgedCnt >= KS_FLY_OSC_WIN THEN
	IF (NOT xOscOn) AND (rRatio > KS_FLY_OSC_IN) THEN
		xOscOn:= TRUE;
	ELSIF xOscOn AND (rRatio < KS_FLY_OSC_OUT) THEN
		xOscOn:= FALSE;
	END_IF
END_IF

(*==================== 3.确定rSigma与两道门槛 ====================*)
IF xSigmaValid THEN
	rS:= rSigma;
	(*σ以数据分辨率兜底(此读取点兜底与Python在push写入时兜底可观测等价:σ仅此处被读)
	 *量化/整数数据门限>=5x分辨率,台阶式漂移交回趋势带原生跟随|Yang.zj 2026.10.27+*)
	IF xQuantumValid AND (rQuantum > rS) THEN
		rS:= rQuantum;
	END_IF
	IF rS < KS_FLY_EPS THEN
		rS:= KS_FLY_EPS;
	END_IF
ELSE
	m:= iHistCnt - 1;
	rTmp:= 0.0;
	IF m > 0 THEN
		FOR i:= 0 TO m-1 DO
			arDiff[i]:= ABS(arHistVal[i+1] - arHistVal[i]);
		END_FOR
		rTmp:= KS_FlyMedian(ADR(arDiff), m);
	END_IF
	(*暖机σ同样以分辨率兜底*)
	IF xQuantumValid AND (rQuantum > rTmp) THEN
		rTmp:= rQuantum;
	END_IF
	IF rTmp < KS_FLY_EPS THEN
		rTmp:= KS_FLY_EPS;
	END_IF
	rS:= KS_FLY_SIG_PROV * rTmp;
END_IF
IF xOscOn AND (iAllDevCnt >= 8) THEN
	FOR i:= 0 TO iAllDevCnt-1 DO
		arDev[i]:= arAllDev[i];
	END_FOR
	rTmp:= KS_FLY_MAD_C * KS_FlyMedian(ADR(arDev), iAllDevCnt);
	IF rTmp > rS THEN
		rS:= rTmp;
	END_IF
END_IF
rTOut:= KS_FLY_K * rS;						(*外门槛*)
rTRet:= KS_FLY_RET_FRAC * KS_FLY_K * rS;	(*回归门槛*)

(*==================== 4.判定状态机(按优先级) ====================*)
IF iQuar > 0 THEN
	(*观察期(刚确认过阶跃):过门进历史但输出/锁存仍是旧电平;未过门撤销观察记1次强超门*)
	IF rD <= rTOut THEN
		iQuar:= iQuar - 1;
		(*--- push ---*)
		IF iHistCnt >= KS_FLY_NOISE_WIN THEN
			FOR i:= 0 TO KS_FLY_NOISE_WIN-2 DO
				arHistVal[i]:= arHistVal[i+1];
				auiHistIdx[i]:= auiHistIdx[i+1];
			END_FOR
			iHistCnt:= KS_FLY_NOISE_WIN - 1;
		END_IF
		arHistVal[iHistCnt]:= rX;
		auiHistIdx[iHistCnt]:= udiIdx;
		iHistCnt:= iHistCnt + 1;
		m:= iHistCnt - 1;
		IF m >= KS_FLY_DIFF_MIN THEN
			FOR i:= 0 TO m-1 DO
				arDiff[i]:= arHistVal[i+1] - arHistVal[i];
			END_FOR
			rMed:= KS_FlyMedian(ADR(arDiff), m);
			FOR i:= 0 TO m-1 DO
				arDiff[i]:= ABS(arDiff[i] - rMed);
			END_FOR
			rMed:= KS_FLY_MAD_C / KS_FLY_SQRT2 * KS_FlyMedian(ADR(arDiff), m);
			IF rMed > KS_FLY_EPS THEN
				rSigma:= rMed;
			ELSE
				rSigma:= KS_FLY_EPS;
			END_IF
			xSigmaValid:= TRUE;
		END_IF
		(*--- end push ---*)
		rOut:= rLatch;
		byJudge:= 2;(*好(观察)*)
	ELSE
		iQuar:= 0;
		iConsec:= 1;
		rOut:= rLatch;(*观察失败一律锁存,不用P*)
		byJudge:= 3;(*飞点*)
	END_IF
ELSIF iConsec > 0 THEN
	(*候选期(已出现强异常):迟滞判回归/续强/暂缓*)
	IF rD <= rTRet THEN
		(*明确回到原趋势:此前强超门判定为飞点,本帧按好点*)
		IF iHistCnt >= KS_FLY_NOISE_WIN THEN
			FOR i:= 0 TO KS_FLY_NOISE_WIN-2 DO
				arHistVal[i]:= arHistVal[i+1];
				auiHistIdx[i]:= auiHistIdx[i+1];
			END_FOR
			iHistCnt:= KS_FLY_NOISE_WIN - 1;
		END_IF
		arHistVal[iHistCnt]:= rX;
		auiHistIdx[iHistCnt]:= udiIdx;
		iHistCnt:= iHistCnt + 1;
		m:= iHistCnt - 1;
		IF m >= KS_FLY_DIFF_MIN THEN
			FOR i:= 0 TO m-1 DO
				arDiff[i]:= arHistVal[i+1] - arHistVal[i];
			END_FOR
			rMed:= KS_FlyMedian(ADR(arDiff), m);
			FOR i:= 0 TO m-1 DO
				arDiff[i]:= ABS(arDiff[i] - rMed);
			END_FOR
			rMed:= KS_FLY_MAD_C / KS_FLY_SQRT2 * KS_FlyMedian(ADR(arDiff), m);
			IF rMed > KS_FLY_EPS THEN
				rSigma:= rMed;
			ELSE
				rSigma:= KS_FLY_EPS;
			END_IF
			xSigmaValid:= TRUE;
		END_IF
		rLatch:= rX;
		xLatchValid:= TRUE;
		iConsec:= 0;
		iHold:= 0;
		rOut:= rX;
	ELSIF rD > rTOut THEN
		iHold:= 0;
		iConsec:= iConsec + 1;
		IF iConsec >= KS_FLY_STEP_CONFIRM THEN
			(*连续强超门满确认帧数->确认阶跃:历史重建为新电平单点,锁存不动,rSigma沿用*)
			arHistVal[0]:= rX;
			auiHistIdx[0]:= udiIdx;
			iHistCnt:= 1;
			iConsec:= 0;
			iQuar:= KS_FLY_QUAR_N;
			rOut:= rLatch;
			byJudge:= 5;(*阶跃*)
		ELSE
			(*替换值:账本>=3点且非振荡模式用趋势外推fP(斜坡上比锁存新鲜)并同步刷锁存,否则退回锁存|Yang.zj 2026.10.27+*)
			IF (iHistCnt >= 3) AND (NOT xOscOn) THEN
				rOut:= fP;
				rLatch:= fP;(*刷锁存:后续阶跃确认/观察帧沿同一条趋势线输出,消除台阶*)
			ELSE
				rOut:= rLatch;
			END_IF
			byJudge:= 3;(*飞点*)
		END_IF
	ELSE
		(*迟滞带内:暂缓不等于判死;连续暂缓满KS_FLY_HOLD_MAX帧按正常值吸收*)
		iHold:= iHold + 1;
		IF iHold >= KS_FLY_HOLD_MAX THEN
			IF iHistCnt >= KS_FLY_NOISE_WIN THEN
				FOR i:= 0 TO KS_FLY_NOISE_WIN-2 DO
					arHistVal[i]:= arHistVal[i+1];
					auiHistIdx[i]:= auiHistIdx[i+1];
				END_FOR
				iHistCnt:= KS_FLY_NOISE_WIN - 1;
			END_IF
			arHistVal[iHistCnt]:= rX;
			auiHistIdx[iHistCnt]:= udiIdx;
			iHistCnt:= iHistCnt + 1;
			m:= iHistCnt - 1;
			IF m >= KS_FLY_DIFF_MIN THEN
				FOR i:= 0 TO m-1 DO
					arDiff[i]:= arHistVal[i+1] - arHistVal[i];
				END_FOR
				rMed:= KS_FlyMedian(ADR(arDiff), m);
				FOR i:= 0 TO m-1 DO
					arDiff[i]:= ABS(arDiff[i] - rMed);
				END_FOR
				rMed:= KS_FLY_MAD_C / KS_FLY_SQRT2 * KS_FlyMedian(ADR(arDiff), m);
				IF rMed > KS_FLY_EPS THEN
					rSigma:= rMed;
				ELSE
					rSigma:= KS_FLY_EPS;
				END_IF
				xSigmaValid:= TRUE;
			END_IF
			rLatch:= rX;
			xLatchValid:= TRUE;
			iConsec:= 0;
			iHold:= 0;
			rOut:= rX;
		ELSE
			(*替换值:账本>=3点且非振荡模式用趋势外推fP并同步刷锁存,否则退回锁存|Yang.zj 2026.10.27+*)
			IF (iHistCnt >= 3) AND (NOT xOscOn) THEN
				rOut:= fP;
				rLatch:= fP;
			ELSE
				rOut:= rLatch;
			END_IF
			byJudge:= 4;(*暂缓*)
		END_IF
	END_IF
ELSIF rD <= rTOut THEN
	(*正常态:带内即好,原值输出*)
	IF iHistCnt >= KS_FLY_NOISE_WIN THEN
		FOR i:= 0 TO KS_FLY_NOISE_WIN-2 DO
			arHistVal[i]:= arHistVal[i+1];
			auiHistIdx[i]:= auiHistIdx[i+1];
		END_FOR
		iHistCnt:= KS_FLY_NOISE_WIN - 1;
	END_IF
	arHistVal[iHistCnt]:= rX;
	auiHistIdx[iHistCnt]:= udiIdx;
	iHistCnt:= iHistCnt + 1;
	m:= iHistCnt - 1;
	IF m >= KS_FLY_DIFF_MIN THEN
		FOR i:= 0 TO m-1 DO
			arDiff[i]:= arHistVal[i+1] - arHistVal[i];
		END_FOR
		rMed:= KS_FlyMedian(ADR(arDiff), m);
		FOR i:= 0 TO m-1 DO
			arDiff[i]:= ABS(arDiff[i] - rMed);
		END_FOR
		rMed:= KS_FLY_MAD_C / KS_FLY_SQRT2 * KS_FlyMedian(ADR(arDiff), m);
		IF rMed > KS_FLY_EPS THEN
			rSigma:= rMed;
		ELSE
			rSigma:= KS_FLY_EPS;
		END_IF
		xSigmaValid:= TRUE;
	END_IF
	rLatch:= rX;
	xLatchValid:= TRUE;
	iConsec:= 0;
	iHold:= 0;
	rOut:= rX;
ELSE
	(*记1次强超门(下一帧来对质)*)
	iConsec:= 1;
	(*替换值:账本>=3点且非振荡模式用趋势外推fP并同步刷锁存,否则退回锁存|Yang.zj 2026.10.27+*)
	IF (iHistCnt >= 3) AND (NOT xOscOn) THEN
		rOut:= fP;
		rLatch:= fP;
	ELSE
		rOut:= rLatch;
	END_IF
	byJudge:= 3;(*飞点*)
END_IF

(*==================== 5.帧末记账(供振荡检测) ====================*)
IF iJudgedCnt >= KS_FLY_OSC_WIN THEN
	FOR i:= 0 TO KS_FLY_OSC_WIN-2 DO
		abyJudged[i]:= abyJudged[i+1];
	END_FOR
	iJudgedCnt:= KS_FLY_OSC_WIN - 1;
END_IF
IF (byJudge <> 1) AND (byJudge <> 2) THEN
	abyJudged[iJudgedCnt]:= 1;
ELSE
	abyJudged[iJudgedCnt]:= 0;
END_IF
iJudgedCnt:= iJudgedCnt + 1;

IF iAllDevCnt >= 16 THEN
	FOR i:= 0 TO 14 DO
		arAllDev[i]:= arAllDev[i+1];
	END_FOR
	iAllDevCnt:= 15;
END_IF
arAllDev[iAllDevCnt]:= ABS(rX - (rA + rB) * 0.5);
iAllDevCnt:= iAllDevCnt + 1;

(*==================== 输出(四舍五入到丝) ====================*)
o_byJudge:= byJudge;
o_xFake:= (byJudge = 3) OR (byJudge = 4);
o_iErrResult:= REAL_TO_INT(rOut);