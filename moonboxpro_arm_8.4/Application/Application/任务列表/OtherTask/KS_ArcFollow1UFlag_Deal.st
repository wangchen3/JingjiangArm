(*@CES
Name=KS_ArcFollow1UFlag_Deal
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=d7f43731-9672-42b8-a130-8c9a3b5ea44f
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_ArcFollow1UFlag_Deal : BOOL(*所有套色跟踪第一色标志处理@优化为了跟踪任意色@2024.02.22.102708*)
(*输出的标志可能决定了是否打开双波门*)
(*套色误差到达一定阈值时输出跟踪第一色标志-置位后就不再复位除非关闭使能
@用于解决在拉伸比较大的材料上后面色组找不到1色的问题。
@最大16个轴@c_byAxisNum_Max 确定*)
(*2024.02.22.085437 将检查第一个套色轴修改为检查跟踪的套色轴的下一个轴的误差*)
(*2025.1.9.145517 增加套色轴到达误差范围标志*)
VAR_INPUT
	i_xEn:BOOL;(*处理使能*)
	i_byArcNum_Max:BYTE;(*最大套色轴个数@最大16个*)
	i_byGrpAxisNum_Pu:BYTE;(*系中色组轴个数*)
	i_pabyGrpAxisList:POINTER TO BYTE;(*系的轴ID列表首地址*)
	i_byArcNum:BYTE;(*当前套色轴个数*)
	i_pabyArcAxisList:POINTER TO BYTE;(*套色的轴列表首地址@2024.02.22.084654*)
	i_pabyArcIdList:POINTER TO BYTE;(*套色的ID列表首地址*)
	i_byArcErr_Threshold:BYTE:=50;(*套色误差阈值@单位丝*)
	i_byContinuousCycleCnt:BYTE:=10;(*持续的圈数@持续这么多幅误差都在阈值以内就认为可以输出标志*)
	i_paxArcErrValid:POINTER TO ARRAY [1..c_byAxisNum_Max] OF BOOL;(*误差值有效了*)
	i_aiArcErr:ARRAY [1..c_byAxisNum_Max] OF INT;(*套色误差值(在让料头未到达的时候误差值写成最大值)@索引为色组号*)
	i_pabyCycleCnt:POINTER TO ARRAY [1..c_byAxisNum_Max] OF BYTE;(*满足条件后的圈数计数值@索引为色组号*)
	i_paxArcReachRangeFlag:POINTER TO ARRAY [1..c_byAxisNum_Max] OF BOOL;(*套色到达阈值标志@用于判断是否要输出跟踪第一色标志*)
	i_paxArcFollow1UFlag:POINTER TO ARRAY [1..c_byAxisNum_Max] OF BOOL;(*输出跟踪第一色标志@索引为色组号*)
	i_pabyFollowArcId:POINTER TO ARRAY [1..c_byAxisNum_Max] OF BYTE;(*2024.02.22.100117 跟踪的套色id@索引为轴id*)
	i_pxArcErrInRange:POINTER TO BOOL;(*套色误差在范围内@2025.1.9.145628+*)
END_VAR
VAR
	iN: INT;
	iM: INT;
	iAxisId: INT;
	iArcId: INT;
	byArcNum_Max: BYTE;
	byArcErr_Threshold: BYTE;(*丝单位*)
	byContinuousCycleCnt: BYTE;(*持续的幅数计数值*)

	byGrpAxisNum_Pu: BYTE;
	pabyGrpAxisList_Tmp:POINTER TO ARRAY [1..c_byAxisNum_Max] OF BYTE;(*系轴id列表*)
	abyGrpAxisList:ARRAY [1..c_byAxisNum_Max] OF BYTE;(*系轴id列表*)

	byArcNum: BYTE;
	pabyArcAxisList_Tmp:POINTER TO ARRAY [1..c_byAxisNum_Max] OF BYTE;(*套色轴id列表*)
	abyArcAxisList:ARRAY [1..c_byAxisNum_Max] OF BYTE;(*套色轴id列表*)
	pabyArcIdList_Tmp:POINTER TO ARRAY [1..c_byAxisNum_Max] OF BYTE;(*套色轴色序id列表*)
	abyArcIdList:ARRAY [1..c_byAxisNum_Max] OF BYTE;(*套色轴色序id列表*)
	axArcReachRangeFlag:ARRAY [1..c_byAxisNum_Max] OF BOOL;(*套色到达阈值标志*)
	axArcFollow1UFlag:ARRAY [1..c_byAxisNum_Max] OF BOOL;(*输出跟踪第一色标志@索引为色组号*)
	abyCycleCnt:ARRAY [1..c_byAxisNum_Max] OF BYTE;(*每个轴的循环计数*)
	aiArcErr:ARRAY [1..c_byAxisNum_Max] OF INT;(*套色误差*)
	axNeedRstAxisId: ARRAY [1..c_byAxisNum_Max] OF BOOL;(*需要复位参数的轴id|默认写true'*)
	axArcErrValid: ARRAY [1..c_byAxisNum_Max] OF BOOL;(*套色误差有效标志位*)
	xArvErrValid: BOOL;(*误差都有效了-可以检查标志*)
	xFollow1UEn: BOOL;(*跟踪第一色使能了*)

	abyFollowArcId:ARRAY [1..c_byAxisNum_Max] OF BYTE;(*2024.02.22.100 跟踪的套色id*)
	iFollowArcId:INT;
	iCheckArcIdSa:INT;(*开始检查的套色id*)
	iIndex: INT;
	iArcErrInRangeAxisCnt: INT;(*在范围的轴个数@2025.1.9.145758*)
END_VAR

VAR CONSTANT
	(*修改的时候谨慎点@外面输入的都是16个轴*)
	c_byAxisNum_Max:BYTE:=16;(*最大的轴个数@直接写死*)
END_VAR
{IMPLEMENTATION}
byArcNum_Max:=i_byArcNum_Max;
IF byArcNum_Max=0 OR
	byArcNum_Max>c_byAxisNum_Max THEN
	byArcNum_Max:=c_byAxisNum_Max;
END_IF

byArcNum:=i_byArcNum;
IF byArcNum>c_byAxisNum_Max THEN
	byArcNum:=c_byAxisNum_Max;
END_IF

byGrpAxisNum_Pu:=i_byGrpAxisNum_Pu;
IF byGrpAxisNum_Pu>c_byAxisNum_Max THEN
	byGrpAxisNum_Pu:=c_byAxisNum_Max;
END_IF

byArcErr_Threshold:=i_byArcErr_Threshold;
byContinuousCycleCnt:=i_byContinuousCycleCnt;

IF i_paxArcErrValid<>0 THEN
	axArcErrValid:=i_paxArcErrValid^;
END_IF
aiArcErr:=i_aiArcErr;

(*获取系轴列表信息*)
IF i_pabyGrpAxisList<>0 THEN
	pabyGrpAxisList_Tmp:=i_pabyGrpAxisList;
	abyGrpAxisList:=pabyGrpAxisList_Tmp^;
END_IF

(*获取套色轴列表信息*)
IF i_pabyArcAxisList<>0 THEN
	pabyArcAxisList_Tmp:=i_pabyArcAxisList;
	abyArcAxisList:=pabyArcAxisList_Tmp^;
END_IF

IF i_pabyArcIdList<>0 THEN
	pabyArcIdList_Tmp:=i_pabyArcIdList;
	abyArcIdList:=pabyArcIdList_Tmp^;
END_IF

IF i_pabyCycleCnt<>0 THEN
	abyCycleCnt:=i_pabyCycleCnt^;
END_IF
IF i_paxArcReachRangeFlag <>0 THEN
	axArcReachRangeFlag:=i_paxArcReachRangeFlag^;
END_IF
IF i_paxArcFollow1UFlag<>0 THEN
	axArcFollow1UFlag:=i_paxArcFollow1UFlag^;
END_IF

IF i_pabyFollowArcId<>0 THEN
	abyFollowArcId:=i_pabyFollowArcId^;
END_IF


(*只处理当前系的轴*)
FOR iN:=1 TO c_byAxisNum_Max BY 1 DO(*iN为系id索引*)
	iAxisId:=abyGrpAxisList[iN];
	IF iAxisId>0 AND iAxisId<c_byAxisNum_Max THEN
		axNeedRstAxisId[iAxisId]:=TRUE;
	ELSE;(*不在这个系的轴就不管了*)
	END_IF
END_FOR

iArcErrInRangeAxisCnt:=0;
FOR iN:=2 TO byArcNum BY 1 DO(*iN为索引@从第二个套色轴开始*)
	iAxisId:=abyArcAxisList[iN];(*套色的轴id*)
	iArcId:=abyArcIdList[iN];(*套色的色序id*)
	iFollowArcId:=abyFollowArcId[iN];(*跟踪的套色Id@2024.02.22.100304*)

	IF iAxisId>=2 AND iAxisId<=c_byAxisNum_Max AND(*轴号合法@从2号轴开始*)
		iArcId>=2 AND iArcId<=c_byAxisNum_Max THEN(*色序id合法*)
		xArvErrValid:=axArcErrValid[iAxisId];(*获取误差是否有效标志位*)
		axArcErrValid[iAxisId]:=FALSE;(*使用完了就复位*)
		(*检查各个色组是否到达阈值*)
		KS_ArcAxisReachRange(
			i_xEn (*i_xEn*),
			INT_TO_BYTE(iArcId)(*i_byArcId*),
			byArcErr_Threshold(*i_byArcErr_Threshold*),
			byContinuousCycleCnt(*i_byContinuousCycleCnt*),
			xArvErrValid(*i_xArcErrValid*),
			aiArcErr[iAxisId](*i_iArcErr*),
			ADR(abyCycleCnt[iAxisId])(*i_pbyCycleCnt*),
			ADR(axArcReachRangeFlag[iAxisId])(*i_xArcReachRangeFlag*));

		(*2025.1.9.145715+*)
		IF axArcReachRangeFlag[iAxisId] THEN
			iArcErrInRangeAxisCnt:=iArcErrInRangeAxisCnt+1;
		END_IF

		(*当前色已经到达阈值了@检查之前的套色轴是否到达。确定是否要输出跟踪第一色标志*)
		IF iFollowArcId<>0 THEN(*跟踪任意色@色序id*)
			IF iArcId>2 THEN(*色序超过3的才检查别的色*)
				IF axArcReachRangeFlag[iAxisId] THEN
					(*找到跟踪的套色id在套色id列表的索引值@2024.02.22.101030+*)
					iIndex:=iN;(*非法处理@未找到色序下面判断的循环就直接跳出*)
					FOR iM:=1 TO iN-1 BY 1 DO
						IF iFollowArcId = abyArcIdList[iM]THEN
							iIndex:=iM;
							EXIT;
						END_IF
					END_FOR

					(*如果找不到,会进入下面的else分支,但是iIndex=iN|所以也不会进入循环-也就是标志不会被置位*)
					iCheckArcIdSa:=2;
					IF iIndex<>In THEN(*找到了*)
						iIndex:=iIndex+1;(*从跟踪的下一个开始检查@索引值为开始检索的值*)
						iCheckArcIdSa:=abyArcIdList[iIndex];
					END_IF

					IF iCheckArcIdSa>=iArcId THEN(*检查的值和当前的色序一样@就直接输出标志*)
						axArcFollow1UFlag[iAxisId]:=TRUE;
					ELSE(*需要经过下面的检查输出*)
						(*修改为了跟踪色+1开始@2024.02.22.104458*)
						FOR iM:=iIndex TO iN-1  BY 1 DO(*从2色色序开始检查-自己在外围条件已经检查了@im也是色序*)
							IF axArcReachRangeFlag[abyArcAxisList[iM]] THEN(*到达阈值范围了*)
								IF iM=iN-1 THEN(*前一个也到达了则输出跟踪第一色标志*)
									axArcFollow1UFlag[iAxisId]:=TRUE;
								END_IF
							ELSE(*未到达则退出循环*)
								EXIT;
							END_IF
						END_FOR
					END_IF
				ELSE
					axArcFollow1UFlag[iAxisId]:=FALSE;
				END_IF
			ELSE
				axArcFollow1UFlag[iAxisId]:=axArcReachRangeFlag[iAxisId];(*只关心自己*)
			END_IF
		ELSE(*不跟踪任意色*)
			axArcFollow1UFlag[iAxisId]:=FALSE;
		END_IF
		(*处理未套色轴-复位标志@套色轴辅助变量已经在上面清除处理了*)
		axNeedRstAxisId[iAxisId]:=FALSE;
	ELSE;(*不做处理*)
	END_IF
END_FOR
(*检查所有轴是不是都在范围内@2025.1.9.145846*)
IF i_pxArcErrInRange<>0 THEN
	IF	(iArcErrInRangeAxisCnt+1) = byArcNum AND byArcNum>1 THEN
		i_pxArcErrInRange^:=TRUE;
	ELSE
		i_pxArcErrInRange^:=FALSE;
	END_IF
END_IF

(*没处理的轴数据清除*)
FOR iAxisId:=1 TO c_byAxisNum_Max BY 1 DO
	IF axNeedRstAxisId[iAxisId] THEN
		abyCycleCnt[iAxisId]:=0;
		axArcReachRangeFlag[iAxisId]:=FALSE;
		axArcFollow1UFlag[iAxisId]:=FALSE;
		axArcErrValid[iAxisId]:=FALSE;
	END_IF
END_FOR

IF i_pabyCycleCnt<>0 THEN
	i_pabyCycleCnt^:=abyCycleCnt;
END_IF
IF i_paxArcReachRangeFlag <>0 THEN
	i_paxArcReachRangeFlag^:=axArcReachRangeFlag;
END_IF
IF i_paxArcFollow1UFlag<>0 THEN
	i_paxArcFollow1UFlag^:=axArcFollow1UFlag;
END_IF

IF i_paxArcErrValid<>0 THEN
	i_paxArcErrValid^:=axArcErrValid;
END_IF