(*@CES
Name=KS_ArcCompensate_Hor
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=22f1b56e-db40-40dc-a19f-6fb25d07bc3f
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_ArcCompensate_Hor : BOOL
(*套色的横向补偿@针对裁切后横向跑出波门位置丢失*)
VAR_INPUT
	i_xEn					:BOOL;(*补偿使能*)
	i_xDirRev				:BOOL;(*方向取反@默认是误差和调整量同向*)
	i_xCut_Uw				:BOOL;(*裁切标志@放料*)
	i_xCut_Rw				:BOOL;(*裁切标志@收料*)
	i_xLost					:BOOL;(*丢失标志*)
	i_byOutEnLostNum		:BYTE;(*丢失次数@超过该值认为需要补偿输出*)
	i_byAddValue			:BYTE;(*叠加的调整量@丝*)
	i_byMaxAddValue_Total	:BYTE;(*叠加的最大调整量@mm*)
	i_iAdjValue				:INT;(*横向调整量*)
	i_iArcErr				:INT;(*横向误差*)
	i_iMaxAdjustVal			:INT;(*横向最大调整量@um*)
	i_iMinArcErr_Compensate	:INT;(*横向补偿启用的最小误差@丝*)
	i_paiAdjValueList		:POINTER TO ARRAY [1..10] OF INT;(*10幅调整量列表@[10]最新*)
	i_paiArcErrList			:POINTER TO ARRAY [1..10] OF INT;(*10幅套色误差列表@[10]最新*)
	i_pxWatching			:POINTER TO BOOL;(*监控中标志*)
	i_pxOuting				:POINTER TO BOOL;(*输出中标志*)
	i_pxOutDne				:POINTER TO BOOL;(*输出完成*)
	i_pbyLostCnt			:POINTER TO BYTE;(*丢失次数*)
	i_prResult_Total		:POINTER TO REAL;(*总的补偿值@mm*)
	i_prResult				:POINTER TO REAL;(*输出补偿结果值@um*)
END_VAR
VAR
	aiAdjValueList		:ARRAY [1..10] OF INT;(*10幅调整量列表@[10]最新*)
	aiArcErrList		:ARRAY [1..10] OF INT;(*10幅套色误差列表@[10]最新*)
	xWatching			:BOOL;(*监控中标志*)
	xOuting				:BOOL;(*输出中标志*)
	xOutDne				:BOOL;(*输出完成*)
	byLostCnt			:BYTE;(*丢失次数*)
	rResult_Total		:REAL;(*总的补偿值@mm*)
	rResult				:REAL;(*输出补偿结果值@um*)
	iN					:INT;
	iDelta				:INT;
	iNum0				:INT;
	iNum1				:INT;
	rSum				:REAL;
	iCoeff				:INT;(*方向系数*)
	xGTMinArcErr		:BOOL;(*大于最小误差标志@有效了可以输出补偿*)
END_VAR
{IMPLEMENTATION}
IF i_prResult_Total<>0 THEN
	rResult_Total:=i_prResult_Total^;(*重新统计的时候再清除*)
END_IF
IF i_xEn THEN
	(*放到en的好处就是else会直接清除这些变量*)
	IF i_paiAdjValueList<>0 THEN
		aiAdjValueList:=i_paiAdjValueList^;
	END_IF
	IF i_paiArcErrList<>0 THEN
		aiArcErrList:=i_paiArcErrList^;
	END_IF
	IF i_pxWatching<>0 THEN
		xWatching:=i_pxWatching^;
	END_IF
	IF i_pxOuting<>0 THEN
		xOuting:=i_pxOuting^;
	END_IF
	IF i_pxOutDne<>0 THEN
		xOutDne:=i_pxOutDne^;
	END_IF
	IF i_pbyLostCnt<>0 THEN
		byLostCnt:=i_pbyLostCnt^;
	END_IF


	IF i_xCut_Uw AND NOT xWatching THEN(*裁切标志有效@c初始化参数*)
		xWatching:=TRUE;
		xOuting:=FALSE;
		xOutDne:=FALSE;
		byLostCnt:=0;
		rResult_Total:=0;(*清零统计值*)
		FOR iN:=1 TO 10 BY 1 DO
			aiAdjValueList[iN]:=0;
			aiArcErrList[iN]:=0;
		END_FOR
	END_IF

	IF xWatching THEN
		IF i_xLost THEN
			IF byLostCnt<i_byOutEnLostNum THEN
				byLostCnt:=byLostCnt+1;
			ELSE
				xOuting:=TRUE;
			END_IF
		ELSE(*未丢失*)
			byLostCnt:=0;(*重新统计@只要有正常的就重新统计*)
			(*更新误差和调整量列表*)
			KS_PushValueToList(i_iAdjValue, 10, TYPE_INT, ADR(aiAdjValueList));
			KS_PushValueToList(i_iArcErr, 10, TYPE_INT, ADR(aiArcErrList));
		END_IF

		IF xOuting THEN(*计算一次*)
(*
			(*计算调整量方向*)
			(*看前6个点|5个变化量*)
			iNum:=0;
			FOR iN:=10 TO 6 BY -1 DO
				iDelta:=aiArcErrList[iN]-aiArcErrList[iN-1];
				IF iDelta>=0 THEN(*=0 也算有效*)
					iNum:=iNum+1;
				ELSIF iDelta<0 THEN
					iNum:=iNum-1;
				END_IF
			END_FOR

			IF ABS(iNum)>=3 THEN(*50%的数据都是朝一个方向的|我们触发输出*);
			ELSE
				xOuting:=FALSE;
				xOutDne:=TRUE;(*就直接结束吧*)
			END_IF
*)
			xWatching:=FALSE;(*不再监控了*)
			byLostCnt:=0;
		END_IF
	END_IF

	(*输出中*)
	IF xOuting THEN
		(*计算调整量方向*)
		(*看前6个点|5个变化量*)
		iNum0:=0;
		iNum1:=0;
		xGTMinArcErr:=FALSE;
		FOR iN:=10 TO 6 BY -1 DO
			iDelta:=aiArcErrList[iN]-aiArcErrList[iN-1];
			IF iDelta>0 THEN
				iNum0:=iNum0+1;
			ELSIF iDelta<0 THEN
				iNum1:=iNum1+1;
			ELSE;
			END_IF

			(*2024.8.6.172305+误差队列中的误差存在比最小值大的就可以输出补偿*)
			(*用于弥补误差不大的时候由于色标信号消失引起的误动作*)
			IF ABS(aiArcErrList[iN])>i_iMinArcErr_Compensate THEN
				xGTMinArcErr:=TRUE;
			END_IF
		END_FOR

		IF xGTMinArcErr THEN(*有大于最小误差值的*)
			IF iNum0 > iNum1 THEN(*正的多*)
				iCoeff:=1;
			ELSIF iNum0 < iNum1 THEN(*负的多*)
				iCoeff:=-1;
			ELSE(*这次退出*)
				iCoeff:=0;
				xOuting:=FALSE;
				xOutDne:=TRUE;(*就直接结束吧*)
			END_IF
		ELSE(*没有则退出不补偿@省的误动作*)
			iCoeff:=0;
			xOuting:=FALSE;
			xOutDne:=TRUE;(*就直接结束吧*)
		END_IF

		(*计算补偿量*)
		IF FALSE THEN
			(*计算累计调整量的方向作为我补偿的方向*)
			rSum:=0;
			FOR iN:=1 TO 10 BY 1 DO
				rSum:=rSum+aiAdjValueList[iN];
			END_FOR
			IF rSum>0 THEN
				rResult:=BYTE_TO_REAL(i_byAddValue)*10;(*um值*)
			ELSIF rSum<0 THEN
				rResult:=-BYTE_TO_REAL(i_byAddValue)*10;(*um值*)
			ELSE
				rResult:=0;(*um值*)
			END_IF
		ELSE
			rResult:=BYTE_TO_REAL(i_byAddValue)*10;(*um值*)
			rResult:=iCoeff*rResult;
			IF i_xDirRev THEN
				rResult:=-rResult;
			END_IF
		END_IF

		(*做单圈最大输出限制@2024.8.4.195257*)
		IF rResult<>0 THEN
			IF ABS(rResult)>ABS(i_iMaxAdjustVal) THEN
				rResult:=i_iMaxAdjustVal*rResult/ABS(rResult);
			END_IF
		END_IF

		(*检查丢失状态*)
		IF NOT i_xLost THEN(*连续2幅未丢失则交给自动*)
			byLostCnt:=byLostCnt+1;
		END_IF

		rResult_Total:=rResult_Total+rResult;(*累加*)
		IF ABS(rResult_Total)/1000>=i_byMaxAddValue_Total OR
			byLostCnt>=2 THEN(*连续2幅未丢失就结束,则交给自动@byLostCnt 这里做未丢失统计数目使用*)
			xOuting:=FALSE;
			xOutDne:=TRUE;
		END_IF
	END_IF

	(*收料裁切就强制结束*)
	IF i_xCut_Rw THEN
		xOuting:=FALSE;
		xOutDne:=TRUE;
		xWatching:=FALSE;(*不再监控了*)
	END_IF
ELSE;
END_IF

IF i_paiAdjValueList<>0 THEN
	i_paiAdjValueList^:=aiAdjValueList;
END_IF
IF i_paiArcErrList<>0 THEN
	i_paiArcErrList^:=aiArcErrList;
END_IF
IF i_pxWatching<>0 THEN
	i_pxWatching^:=xWatching;
END_IF
IF i_pxOuting<>0 THEN
	i_pxOuting^:=xOuting;
END_IF
IF i_pxOutDne<>0 THEN
	i_pxOutDne^:=xOutDne;
END_IF
IF i_pbyLostCnt<>0 THEN
	i_pbyLostCnt^:=byLostCnt;
END_IF
IF i_prResult_Total<>0 THEN
	i_prResult_Total^:=rResult_Total;
END_IF
IF i_prResult<>0 THEN
	i_prResult^:=rResult;
END_IF