(*@CES
Name=KS_ArcAxisReachRange
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=66d8455d-5d38-4db4-a051-65983b6f267b
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_ArcAxisReachRange : BOOL(*套色单轴误差到达阈值内*)
(*置位后就不再复位除非关闭使能*)
VAR_INPUT
	i_xEn:BOOL;(*处理使能*)
	i_byArcId:BYTE;(*套色的ID*)
	i_byArcErr_Threshold:BYTE:=50;(*套色误差阈值@单位丝*)
	i_byContinuousCycleCnt:BYTE:=10;(*持续的圈数@持续这么多幅误差都在阈值以内就认为可以输出标志*)
	i_xArcErrValid:BOOL;(*误差有效标志@误差有效才能比较 否者等等吧*)
	i_iArcErr:INT;(*套色误差值(在让料头未到达的时候误差值写成最大值)*)
	i_pbyCycleCnt:POINTER TO BYTE;(*满足条件后的圈数计数值*)
	i_pxArcReachRangeFlag:POINTER TO BOOL;(*套色到达阈值标志*)
END_VAR
VAR
	iN: INT;
	byArcErr_Threshold: BYTE;(*丝单位*)
	byContinuousCycleCnt: BYTE;(*持续的幅数计数值*)
	xArcReachRangeFlag:BOOL;(*套色到达阈值标志*)
	byCycleCnt:BYTE;(*每个轴的循环计数*)
	iArcErr:INT;(*套色误差*)
END_VAR
VAR_INPUT
END_VAR
VAR
END_VAR

{IMPLEMENTATION}
IF i_pxArcReachRangeFlag<>0 THEN
	xArcReachRangeFlag:=i_pxArcReachRangeFlag^;
END_IF
IF i_pbyCycleCnt<>0 THEN
	byCycleCnt:=i_pbyCycleCnt^;
END_IF


(*阈值参数*)
byArcErr_Threshold:=i_byArcErr_Threshold;
IF byArcErr_Threshold<=0 THEN
	byArcErr_Threshold:=50;
END_IF

(*持续的幅数参数*)
byContinuousCycleCnt:=i_byContinuousCycleCnt;
IF byContinuousCycleCnt=0 THEN
	byContinuousCycleCnt:=10;
END_IF
iArcErr:=i_iArcErr;

IF i_xEn THEN
	IF i_byArcId>=2 AND i_byArcId<=16 THEN(*从2色开始到最后|检查误差值是否在阈值范围以内*)
		IF NOT xArcReachRangeFlag THEN
			IF i_xArcErrValid THEN
				IF ABS(iArcErr)<=byArcErr_Threshold THEN(*在范围内*)
					byCycleCnt:=byCycleCnt+1;
				ELSE(*有一次跳出，就清零*)
					byCycleCnt:=0;
				END_IF
			ELSE(*等等吧*);
			END_IF


			(*检查是否足够设定的幅数@*)
			IF byCycleCnt>byContinuousCycleCnt THEN
				xArcReachRangeFlag:=TRUE;
			END_IF
		ELSE;
		END_IF
	ELSE
		xArcReachRangeFlag:=FALSE;
		byCycleCnt:=0;
	END_IF
ELSE
	(*复位参数*)
	xArcReachRangeFlag:=FALSE;
	byCycleCnt:=0;
END_IF



IF i_pxArcReachRangeFlag<>0 THEN
	i_pxArcReachRangeFlag^:=xArcReachRangeFlag;
END_IF
IF i_pbyCycleCnt<>0 THEN
	i_pbyCycleCnt^:=byCycleCnt;
END_IF