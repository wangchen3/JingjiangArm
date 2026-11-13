(*@CES
Name=StPdu_Dn_95
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=8cf234ae-5b35-4b85-a488-2096eed3c062
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
{attribute 'pack_mode' := '1'}
TYPE StPdu_Dn_95 :
STRUCT
	//全自动套印代码
	byWidth_Mark_Max						: BYTE;(*单个色标最大宽度-0.1mm*)
	byWidth_Mark_Min						: BYTE;(*单个色标最小宽度-0.1mm*)
	byMaxGap								: BYTE;(*最大间隙，-0.1mm*)
	bySimilarityThreshold					: BYTE;(*相似度阈值40%-70%,*)
	bySpotWidth								: BYTE;(*光斑宽度*10*)

	byFlag_CommFromMaster					: BYTE;(*	bit0: xFlag_AutoAdj_En; bit1: xFlag_FindFirstMark; bit2: xCurManuAdjust
														bit3:xFlag_FindPreMark  bit4:xPreCurManuAdjust ;bit5xFlag_GateMoveFinish*)
// 	iKcode_Mark_Interval					: INT;(*1色Kcode标与色标间隔- 单位 0.1mm*)
// 	iTaps_Mark_Interval						: INT;(*2色Taps标与色标间隔-单位0.1mm*)


	byMeanOffset							: BYTE; (*均值偏移 越大越找不到小色标，太小会出现较多信号导致直接失败*)
//2026.4.30.161528增加波形美化使能|占用5字节\|46-5=41
	xRsMorphFilter 								: BOOL;//美化标志
	abyRsMorphFilter_Rsv						: ARRAY [1..4] OF BYTE;	
	//全自动套印下发模版
	aiCurModeMidPoint: ARRAY [1..4] OF INT;//当前色模版中心
	abyCurModeRadius:ARRAY [1..4] OF BYTE;//当前色模版半径
	aiPreModeMidPoint: ARRAY [1..4] OF INT;//前一色模版中心
	abyPreModeRadius:ARRAY [1..4] OF BYTE;//前一色模版半径
	byOuterCoff :BYTE ;//外滑窗系数 *10
	byInnerCoff	:BYTE;	//内滑窗系数 *10
	abyRsv_95		: ARRAY [1..19] OF BYTE;
	//2026.05.08.111411 屏蔽 iKcode_Mark_Interval iTaps_Mark_Interval 添加 aiCurModeMidPoint-> byInnerCoff 41+4-26=19
	//2026.4.30.161528 xRsMorphFilter->abyRsMorphFilter_Rsv |46-5=41

	//2026.03.17.133427 byWidth_Mark_Max->byMeanOffset 57-11=46
END_STRUCT
END_TYPE


{IMPLEMENTATION}
