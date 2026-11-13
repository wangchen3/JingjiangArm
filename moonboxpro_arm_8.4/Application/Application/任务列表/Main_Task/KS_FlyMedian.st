(*@CES
Name=KS_FlyMedian
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=38054e60-5949-4eec-bd09-7b0f80079a4b
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_FlyMedian : REAL
(*中位数:与Python statistics.median语义一致——奇数取正中,偶数取中间两值的平均*)
(*插入排序会打乱入参缓冲区,窗口<=64,代价可忽略|Yang.zj+用于新飞点检测 2026.10.24.191149*)
VAR_INPUT
	pBuf	: POINTER TO REAL;(*缓冲区指针*)
	iCnt	: INT;			(*元素个数*)
END_VAR
VAR
	i		: INT;
	j		: INT;
	rTmp	: REAL;
END_VAR

{IMPLEMENTATION}
IF iCnt <= 0 THEN
	KS_FlyMedian:= 0.0;
	RETURN;
END_IF
FOR i:= 1 TO iCnt-1 DO(*插入排序*)
	rTmp:= pBuf[i];
	j:= i-1;
	WHILE (j >= 0) DO
		IF pBuf[j] > rTmp THEN
			pBuf[j+1]:= pBuf[j];
			j:= j-1;
		ELSE 
			EXIT;
		END_IF
	END_WHILE
	pBuf[j+1]:= rTmp;
END_FOR
IF (iCnt MOD 2) = 1 THEN
	KS_FlyMedian:= pBuf[iCnt/2];
ELSE
	KS_FlyMedian:= (pBuf[iCnt/2-1] + pBuf[iCnt/2]) * 0.5;
END_IF