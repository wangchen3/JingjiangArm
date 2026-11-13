(*@CES
Name=KS_FB_GetError_Arc_1
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=a8fc5d1b-180f-4776-912e-45955a246124
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_GetError_Arc_1
VAR_INPUT
	i_xEn: BOOL;(*该功能的使能条件*)
	i_iUnitMax: INT;(*有效色组范围1..MAX_UNIT_NUM*)
	i_abyGetErrMode: ARRAY [1..MAX_UNIT_NUM] OF BYTE;
	(*2026.5.10.102830/han.dp/修正接口定义方式:
	bit0 月光宝盒PRO误差源,1有效
	bit1 金刚误差源,1有效
	bit4 相机安装方向-反向/2026.5.24.173347/han.dp
	bit5 逆序/2026.5.24.173354/han.dp
	bit7 用于标记有效位标志; =0表示bit0有效,以月光宝盒PRO的误差作为调整依据; =1表示bit1有效,以金刚误差作为调整参考;
	--------------------------------------------------
	举例: 
	* 16#01来自月光宝盒PRO;
	* 16#82来自视觉,并作为调整依据;
	* 16#03金刚和月光宝盒PRO误差都读,但只以月光宝盒PRO的误差作为调整依据;
	* 16#83金刚和月光宝盒PRO误差都读,但只以金刚的误差作为调整依据;
	*)
	i_aiAlarm_V: ARRAY [1..MAX_UNIT_NUM] OF INT;(*后续换成全局输入的变量*)
	i_aiAlarm_H: ARRAY [1..MAX_UNIT_NUM] OF INT;(*后续换成全局输入的变量*)
	i_aiAdjust_V: ARRAY [1..MAX_UNIT_NUM] OF INT;(*修正量*)
	i_aiAdjust_H: ARRAY [1..MAX_UNIT_NUM] OF INT;(*修正量*)
	i_abyAverageNum_V: ARRAY [1..MAX_UNIT_NUM] OF BYTE;(*误差平均次数*)
	i_abyAverageNum_H: ARRAY [1..MAX_UNIT_NUM] OF BYTE;(*误差平均次数*)
	(*统一注释0916+2026.4.11.150236 误差显示平均*)
	i_abyAverageNum_V_Display: ARRAY [1..MAX_UNIT_NUM] OF BYTE;(*误差显示平均次数*)
	i_abyAverageNum_H_Display: ARRAY [1..MAX_UNIT_NUM] OF BYTE;(*误差显示平均次数*)	
	i_pstStSysParam								: POINTER TO StSysParam;		
	i_dwKSMatrixMark: DWORD;(*2026.5.24.173538/han.dp/科赛矩阵色标描述/高16bit和低16bit分别为ab值*)
END_VAR
VAR_OUTPUT
	o_xEno: BOOL;
	o_iErNo: INT;
	o_astStErrParam_Use: ARRAY [1..MAX_UNIT_NUM] OF StErrParam_Use;
	o_stSystimeElapsed: SYSTIME;(*2026.5.24.152004/han.dp*)
END_VAR
VAR
	xInitialized_Ref_KSMatrixMark: BOOL := FALSE;
	abyGetErrMode_Ref: ARRAY [1..MAX_UNIT_NUM] OF BYTE := [0];
	dwKSMatrixMark_Ref: DWORD := 0;
	aiRef_KSMatrixMark: ARRAY [1..MAX_UNIT_NUM,1..2] OF INT;(*16色色标的参考位置*)
	wKSMatrixMark_Hword: WORD;
	wKSMatrixMark_Lword: WORD;

	iN: INT;
	aiError_and_Sts_V: ARRAY [1..MAX_UNIT_NUM] OF INT;(*读取的来自金刚/月光宝盒PRO的误差及状态*)
	aiError_and_Sts_H: ARRAY [1..MAX_UNIT_NUM] OF INT;(*读取的来自金刚/月光宝盒PRO的误差及状态*)
	iTemp: WORD;


(*deprecated@2026.5.28.172423/han.dp
	axFlag_Refresh_V: ARRAY [1..MAX_UNIT_NUM] OF BOOL;(*误差刷新标志*)
	axFlag_Refresh_H: ARRAY [1..MAX_UNIT_NUM] OF BOOL;(*误差刷新标志*)
	axFlag_Check_V: ARRAY [1..MAX_UNIT_NUM] OF BOOL;(*误差校验位*)
	axFlag_Check_H: ARRAY [1..MAX_UNIT_NUM] OF BOOL;(*误差校验位*)
	axFlag_PreRefresh_V: ARRAY [1..MAX_UNIT_NUM] OF BOOL;(*误差有效性*)
	axFlag_PreRefresh_H: ARRAY [1..MAX_UNIT_NUM] OF BOOL;(*误差有效性*)
*)	afbKS_FB_PickOutFakePoint_V: ARRAY [1..MAX_UNIT_NUM] OF KS_FB_PickOutFakePoint;(*误差飞点处理*)
	afbKS_FB_PickOutFakePoint_H: ARRAY [1..MAX_UNIT_NUM] OF KS_FB_PickOutFakePoint;	
	afbKS_FB_AverageErr_Arc_V: ARRAY [1..MAX_UNIT_NUM] OF KS_FB_AverageErr_Arc;(*误差平均处理*)
	afbKS_FB_AverageErr_Arc_H: ARRAY [1..MAX_UNIT_NUM] OF KS_FB_AverageErr_Arc;	
	axFakePoint_V: ARRAY [1..MAX_UNIT_NUM] OF BOOL := [MAX_UNIT_NUM(FALSE)];
	axFakePoint_H: ARRAY [1..MAX_UNIT_NUM] OF BOOL := [MAX_UNIT_NUM(FALSE)];

	aiError_V_Res: ARRAY [1..MAX_UNIT_NUM] OF INT := [MAX_UNIT_NUM(0)];(*处理完成后的纵向误差列表*)
	aiError_H_Res: ARRAY [1..MAX_UNIT_NUM] OF INT := [MAX_UNIT_NUM(0)];(*处理完成后的横向误差列表*)
	abyIndex_V_Pre: ARRAY [1..MAX_UNIT_NUM] OF BYTE := [MAX_UNIT_NUM(0)];(*处理完成后的索引*)
	abyIndex_H_Pre: ARRAY [1..MAX_UNIT_NUM] OF BYTE := [MAX_UNIT_NUM(0)];(*处理完成后的索引*)

	iUnitNR: INT;
	iStationId: INT;
	dwOFST2: DWORD;
	
	iRtn: INT;
	stStProtocol_PDU_Up_Rd: StParam_PDU_Up;
	pstStCMD_F05_: POINTER TO StPdu_Up_05;
	pbyTemp: POINTER TO BYTE;
	wCHK_Up_Calc: WORD;
	dwCheckSumVal: DWORD;
(*	abyBuf_PduCmd_rcv: ARRAY [1..MAX_PDU_CMD_BYTES_UP] OF BYTE; (* 2021.12.4.163129/hdp/读取 *)*)
(*	xtest: BOOL;*)
	aiResult_VFollowpre_1stDerivate: ARRAY [1..MAX_UNIT_NUM] OF INT := [MAX_UNIT_NUM(0)];

	(*统一注释0916+alTime: ARRAY [1..10] OF LTIME;*)
	abyBuf_PduCmd_rcv_All: ARRAY [1..1000] OF BYTE;
	
	
	
	
	(*start___@2026.5.10.135832/han.dp
	视觉误差相关的补充变量*)
	adwErrMix_RdVision: ARRAY [1..MAX_UNIT_NUM] OF DWORD := [0];(*来自视觉的复合误差*)
	aiRtnMatrix: ARRAY [1..MAX_UNIT_NUM,1..2] OF INT := [0];(*处理误差解析的返回值矩阵*)
	aiErr_v_pure: ARRAY [1..MAX_UNIT_NUM] OF INT := [0];(*纵向实际误差/从金刚传来/未处理物理坐标系*)
	aiErr_h_pure: ARRAY [1..MAX_UNIT_NUM] OF INT := [0];(*横向实际误差/从金刚传来/未处理物理坐标系*)
(*	adwERR_VisionGave: ARRAY [1..MAX_UNIT_NUM] OF DWORD := [0];(*纵横向误差在一起*)*)

	axFlag_valid_v_tmp: ARRAY [1..MAX_UNIT_NUM] OF BOOL := [MAX_UNIT_NUM(FALSE)];(*纵向有效标志*)
	axFlag_update_v_tmp: ARRAY [1..MAX_UNIT_NUM] OF BOOL := [MAX_UNIT_NUM(FALSE)];(*纵向更新标志*)
	axFlag_update_v_rec: ARRAY [1..MAX_UNIT_NUM] OF BOOL := [MAX_UNIT_NUM(FALSE)];(*纵向上次更新标志*)
	axFlag_bitchk_v_tmp: ARRAY [1..MAX_UNIT_NUM] OF BOOL := [MAX_UNIT_NUM(FALSE)];(*纵向校验位*)

	axFlag_valid_h_tmp: ARRAY [1..MAX_UNIT_NUM] OF BOOL := [MAX_UNIT_NUM(FALSE)];(*横向有效标志*)
	axFlag_update_h_tmp: ARRAY [1..MAX_UNIT_NUM] OF BOOL := [MAX_UNIT_NUM(FALSE)];(*横向更新标志*)
	axFlag_update_h_rec: ARRAY [1..MAX_UNIT_NUM] OF BOOL := [MAX_UNIT_NUM(FALSE)];(*横向上次更新标志*)
	axFlag_bitchk_h_tmp: ARRAY [1..MAX_UNIT_NUM] OF BOOL := [MAX_UNIT_NUM(FALSE)];(*横向校验位*)

	pawErr_tmp: POINTER TO ARRAY [1..2] OF WORD := 0;
	(*___end@2026.5.10.135850*)

	
	stSystimeDelta,stSystimeStart,stSystimeEnd:SYSTIME;(*获取us时间差*)
	abyVisionErrIdx_V: ARRAY [1..MAX_UNIT_NUM] OF BYTE := [MAX_UNIT_NUM(0)];(*视觉误差索引-纵向*)
	abyVisionErrIdx_H: ARRAY [1..MAX_UNIT_NUM] OF BYTE := [MAX_UNIT_NUM(0)];(*视觉误差索引-横向*)
	
	xDoNothing: BOOL := FALSE;(*什么都不做*)
	xNeedRead_gLinkII_I_Err: BOOL:= FALSE;
	xNeedRead_gLinkII_II_Err: BOOL:= FALSE;
	iRtn_Rd_I: INT;
	iRtn_Rd_II: INT;
	aiError_V_I: ARRAY [1..MAX_UNIT_NUM] OF INT;(*处理完成后的纵向误差列表*)
	aiError_H_I: ARRAY [1..MAX_UNIT_NUM] OF INT;(*处理完成后的横向误差列表*)
	abyIndex_V_I: ARRAY [1..MAX_UNIT_NUM] OF BYTE;(*处理完成后的索引*)
	abyIndex_H_I: ARRAY [1..MAX_UNIT_NUM] OF BYTE;(*处理完成后的索引*)
	aiError_V_II: ARRAY [1..MAX_UNIT_NUM] OF INT;(*处理完成后的纵向误差列表*)
	aiError_H_II: ARRAY [1..MAX_UNIT_NUM] OF INT;(*处理完成后的横向误差列表*)
(*统一注释0916+	abyErrSts_II: ARRAY [1..MAX_UNIT_NUM] OF BYTE;(*处理完成后的纵横向误差状态*)*)
	abyIndex_V_II: ARRAY [1..MAX_UNIT_NUM] OF BYTE;(*处理完成后的索引*)
	abyIndex_H_II: ARRAY [1..MAX_UNIT_NUM] OF BYTE;(*处理完成后的索引*)
(*统一注释0916+	axValid_V_II: ARRAY [1..MAX_UNIT_NUM] OF BOOL;(*误差有效性*)*)
(*统一注释0916+	axValid_H_II: ARRAY [1..MAX_UNIT_NUM] OF BOOL;(*误差有效性*)	*)
	abyErrSts: ARRAY [1..MAX_UNIT_NUM] OF BYTE;(*处理完成后的纵横向误差状态*)
	axValid_V: ARRAY [1..MAX_UNIT_NUM] OF BOOL;(*误差有效性*)
	axValid_H: ARRAY [1..MAX_UNIT_NUM] OF BOOL;(*误差有效性*)
	aiError_V: ARRAY [1..MAX_UNIT_NUM] OF INT;(*处理完成后的纵向误差列表*)
	aiError_H: ARRAY [1..MAX_UNIT_NUM] OF INT;(*处理完成后的横向误差列表*)
	abyIndex_V: ARRAY [1..MAX_UNIT_NUM] OF BYTE;(*处理完成后的索引*)
	abyIndex_H: ARRAY [1..MAX_UNIT_NUM] OF BYTE;(*处理完成后的索引*)
	xChange_GetErrMode: BOOL;
	(*统一注释0916+2026.4.11.150050+*)
	afbKS_FB_AverageErr_Arc_V_Display: ARRAY [1..MAX_UNIT_NUM] OF KS_FB_AverageErr_Arc;(*误差平均处理@界面显示*)
	afbKS_FB_AverageErr_Arc_H_Display: ARRAY [1..MAX_UNIT_NUM] OF KS_FB_AverageErr_Arc;	
	
	aiError_V_Res_Display: ARRAY [1..MAX_UNIT_NUM] OF INT;(*处理完成后的纵向显示误差列表*)
	aiError_H_Res_Display: ARRAY [1..MAX_UNIT_NUM] OF INT;(*处理完成后的横向显示误差列表*)
	//新飞点剔除:每色组纵横各一个独立实例(总开关gc_xUseNewFlyRemove在GCL)|Yang.zj+用于新飞点检测 2026.10.27.105623
	afbKS_FlyRemove_V: ARRAY [1..MAX_UNIT_NUM] OF KS_FlyRemove;
	afbKS_FlyRemove_H: ARRAY [1..MAX_UNIT_NUM] OF KS_FlyRemove;
	aiError_V_Fly: ARRAY [1..MAX_UNIT_NUM] OF INT;(*剔除后送平均的纵向误差*)
	aiError_H_Fly: ARRAY [1..MAX_UNIT_NUM] OF INT;(*剔除后送平均的横向误差*)
	xFlyNewFrame_V: BOOL;(*本周期该色组纵向是否来了新帧(视觉源纵横索引独立变化,分开判定)*)
	xFlyNewFrame_H: BOOL;(*本周期该色组横向是否来了新帧*)
	xFlyReset: BOOL;(*该色组剔除器复位请求*)
	aiFlyMarkModePre: ARRAY [1..MAX_UNIT_NUM] OF INT;(*上次色标排列模式*)
	abyFlySignalPre: ARRAY [1..MAX_UNIT_NUM] OF BYTE;(*上次RGB信号通道*)
	axFlyHorEnPre: ARRAY [1..MAX_UNIT_NUM] OF BOOL;(*上次横向开关*)
	abyFlyGetErrModePre: ARRAY [1..MAX_UNIT_NUM] OF BYTE;(*上次误差源模式,月光宝盒/金刚切换时复位*)
	axFlyRollPre: ARRAY [1..MAX_UNIT_NUM] OF BOOL;(*上次压辊输出位(g_astStIOMap_Axis_FE[iN].o_xRel_Press,合压继电器原始输出),压下/抬起沿都触发剔除器复位|Yang.zj+ 2026.10.27.210459*)

	
END_VAR
{IMPLEMENTATION}
SysTimeGetUs(stSystimeStart);(*2026.5.24.152052/han.dp/获取开始时间*)

(*revision by han.dp@2026.5.10.134238*)
o_xEno:= i_xEn;
o_iErNo:= 0;
IF i_xEn THEN
	xChange_GetErrMode:= FALSE;
	FOR iN:=1 TO i_iUnitMax BY 1 DO
		IF abyGetErrMode_Ref[iN]<>i_abyGetErrMode[iN] THEN
			xChange_GetErrMode:= TRUE;
		END_IF
		abyGetErrMode_Ref[iN]:= i_abyGetErrMode[iN];
	END_FOR

	IF xChange_GetErrMode OR
		dwKSMatrixMark_Ref<>i_dwKSMatrixMark THEN
		dwKSMatrixMark_Ref:= i_dwKSMatrixMark;
		IF xInitialized_Ref_KSMatrixMark THEN
			xInitialized_Ref_KSMatrixMark:= FALSE;
		END_IF
	END_IF


	IF NOT xInitialized_Ref_KSMatrixMark THEN
		xInitialized_Ref_KSMatrixMark:= TRUE;

		FOR iN:=1 TO MAX_UNIT_NUM BY 1 DO
			aiRef_KSMatrixMark[iN,1]:= aiRef_KSMatrixMark[iN,2]:= 0;
		END_FOR
		(*生成aiRef_KSMatrixMark*)
		wKSMatrixMark_Hword:= DWORD_TO_WORD(SHR(dwKSMatrixMark_Ref,16) AND 16#FFFF);
		wKSMatrixMark_Lword:= DWORD_TO_WORD(dwKSMatrixMark_Ref AND 16#FFFF);
		IF wKSMatrixMark_Hword=wKSMatrixMark_Lword AND
			wKSMatrixMark_Lword<>0 THEN
			;
		ELSE
			wKSMatrixMark_Hword:= wKSMatrixMark_Lword:= 400;(*默认按1mm直径/1mm间距*)
		END_IF
		
		(*2026.5.27.100608/han.dp
		*反装顺序和正装逆序/相机成图是一致的
		*按成像后的参考点预置各个色组的0坐标
		*)
		FOR iN:=2 TO 8 BY 1 DO 
			IF ((NOT abyGetErrMode_Ref[iN].4) AND abyGetErrMode_Ref[iN].5) OR(*相机正向安装+逆序*)
				(abyGetErrMode_Ref[iN].4 AND (NOT abyGetErrMode_Ref[iN].5)) THEN(*相机反向安装+顺序*)
				IF iN=2 THEN
					aiRef_KSMatrixMark[2,1]:= 0;
					aiRef_KSMatrixMark[2,2]:= WORD_TO_INT(wKSMatrixMark_Hword/2)*(-1);
				END_IF
				IF iN=3 THEN
					aiRef_KSMatrixMark[3,1]:= WORD_TO_INT(wKSMatrixMark_Hword/2)*(-1);
					aiRef_KSMatrixMark[3,2]:= WORD_TO_INT(wKSMatrixMark_Hword/2)*(-1);
				END_IF
				IF iN=4 THEN
					aiRef_KSMatrixMark[4,1]:= WORD_TO_INT(wKSMatrixMark_Hword/2);
					aiRef_KSMatrixMark[4,2]:= 0;
				END_IF
				IF iN=5 THEN
					aiRef_KSMatrixMark[5,1]:= 0;
					aiRef_KSMatrixMark[5,2]:= 0;
				END_IF
				IF iN=6 THEN
					aiRef_KSMatrixMark[6,1]:= WORD_TO_INT(wKSMatrixMark_Hword/2)*(-1);
					aiRef_KSMatrixMark[6,2]:= 0;
				END_IF
				IF iN=7 THEN
					aiRef_KSMatrixMark[7,1]:= WORD_TO_INT(wKSMatrixMark_Hword/2);
					aiRef_KSMatrixMark[7,2]:= WORD_TO_INT(wKSMatrixMark_Hword/2);
				END_IF
				IF iN=8 THEN
					aiRef_KSMatrixMark[8,1]:= 0;
					aiRef_KSMatrixMark[8,2]:= WORD_TO_INT(wKSMatrixMark_Hword/2);
				END_IF
			ELSE
				IF iN=2 THEN	
					aiRef_KSMatrixMark[2,1]:= 0;
					aiRef_KSMatrixMark[2,2]:= WORD_TO_INT(wKSMatrixMark_Hword/2);
				END_IF
	
				IF iN=3 THEN
					aiRef_KSMatrixMark[3,1]:= WORD_TO_INT(wKSMatrixMark_Hword/2);
					aiRef_KSMatrixMark[3,2]:= WORD_TO_INT(wKSMatrixMark_Hword/2);
				END_IF
	
				IF iN=4 THEN
					aiRef_KSMatrixMark[4,1]:= WORD_TO_INT(wKSMatrixMark_Hword/2)*(-1);
					aiRef_KSMatrixMark[4,2]:= 0;
				END_IF
	
				IF iN=5 THEN
					aiRef_KSMatrixMark[5,1]:= 0;
					aiRef_KSMatrixMark[5,2]:= 0;
				END_IF
	
				IF iN=6 THEN
					aiRef_KSMatrixMark[6,1]:= WORD_TO_INT(wKSMatrixMark_Hword/2);
					aiRef_KSMatrixMark[6,2]:= 0;
				END_IF
	
				IF iN=7 THEN
					aiRef_KSMatrixMark[7,1]:= WORD_TO_INT(wKSMatrixMark_Hword/2)*(-1);
					aiRef_KSMatrixMark[7,2]:= WORD_TO_INT(wKSMatrixMark_Hword/2)*(-1);
				END_IF

				IF iN=8 THEN
					aiRef_KSMatrixMark[8,1]:= 0;
					aiRef_KSMatrixMark[8,2]:= WORD_TO_INT(wKSMatrixMark_Hword/2)*(-1);
				END_IF
			END_IF
		END_FOR
	END_IF
	
(*统一注释0916+重新整理一下逻辑*)
	xNeedRead_gLinkII_I_Err:=FALSE;
	xNeedRead_gLinkII_II_Err:= FALSE;
	IF (i_iUnitMax>0 AND i_iUnitMax<=MAX_UNIT_NUM) THEN

		FOR iN:= 1 TO i_iUnitMax BY 1 DO
			IF i_abyGetErrMode[iN].0 THEN(*统一注释0916+有一个色组打开了读取月光宝盒误差*)
				xNeedRead_gLinkII_I_Err:= TRUE;
			END_IF
		END_FOR
		FOR iN:= 1 TO i_iUnitMax BY 1 DO
			IF i_abyGetErrMode[iN].1 THEN(*统一注释0916+有一个色组打开了读取金刚误差*)
				xNeedRead_gLinkII_II_Err:= TRUE;
			END_IF
		END_FOR		
	END_IF
(*统一注释0916+读取地址*)
iRtn_Rd_I:= -1;
iRtn_Rd_II:= -1;
	IF (NOT xNeedRead_gLinkII_II_Err) AND (NOT xNeedRead_gLinkII_I_Err) THEN(*统一注释0916+2026.5.30.090808都没有默认读一下一套网内容*)
		iRtn_Rd_I := 
			GTN_RN_UserPCRdLocalFPGA(
				1(*cardIndex*),
				1(*busIndex*),
				0(*stationId*),
				ADR(abyBuf_PduCmd_rcv_All)(*pData*),
				0(*startAddr*),
				KS_GetNumOfDwordUsed(INT_TO_DWORD(i_iUnitMax)*MAX_PDU_CMD_BYTES_DN)(*dwordNum*));

	ELSE
		IF xNeedRead_gLinkII_I_Err THEN
			iRtn_Rd_I := 
				GTN_RN_UserPCRdLocalFPGA(
					1(*cardIndex*),
					1(*busIndex*),
					0(*stationId*),
					ADR(abyBuf_PduCmd_rcv_All)(*pData*),
					0(*startAddr*),
					KS_GetNumOfDwordUsed(INT_TO_DWORD(i_iUnitMax)*MAX_PDU_CMD_BYTES_DN)(*dwordNum*));
			
		END_IF
		IF xNeedRead_gLinkII_II_Err THEN
			iRtn_Rd_II:= 
				GTN_RN_GetVisualControllerValue(
					1(*cardIndex*),
					2(*busIndex*),
					ADR(adwErrMix_RdVision)(*pData*),
					MAX_UNIT_NUM(*dwordNum*));				
		END_IF
	END_IF
(*统一注释0916+地址读取完成，把读到的内容处理一遍	*)
	IF iRtn_Rd_I=0 THEN(*统一注释0916+这里先这样处理吧？一套网的协议解析一下*)
		FOR iN:=1 TO i_iUnitMax BY 1 DO
			iUnitNR:= iN;(*通讯轴号也需要根据后续系统配置处理*)
			iStationId:= g_stStSysParam.stStSysParam_UnSave.aiStationList_UnitController[iN];(*统一注释0916+g_abyStationList_CommKSCR[iN];(*站号*)*)
			IF KS_IsValidStationNR(iStationId) THEN(*站号有效*)
				dwOFST2 := MAX_PDU_CMD_BYTES_DN*(iUnitNR-1);(*偏移量*)
				SysMemCpy(
					ADR(stStProtocol_PDU_Up_Rd),
					ADR(abyBuf_PduCmd_rcv_All)+dwOFST2,
					SIZEOF(stStProtocol_PDU_Up_Rd));

				(*2026.5.10.143526/han.dp/从16#5号命令解析内部移出来*)
				aiError_V_I[iN]:= stStProtocol_PDU_Up_Rd.iErr_V_Raw;
				aiError_H_I[iN]:= stStProtocol_PDU_Up_Rd.iErr_H_Raw;
				abyIndex_V_I[iN]:= stStProtocol_PDU_Up_Rd.byIDX_V;
				abyIndex_H_I[iN]:= stStProtocol_PDU_Up_Rd.byIDX_H;
				
				
				(*2026.10.24.180455+*)
				o_astStErrParam_Use[iN].uiFSampleCounter:=stStProtocol_PDU_Up_Rd.uiFSampleCounter;
				i_pstStSysParam^.astStUnitParam_UnSave[iN].uiFSampleCounter:=stStProtocol_PDU_Up_Rd.uiFSampleCounter;
				
				
				(*2026.09.15.134645//xi.hy//增加月光宝盒Pro另一路误差的保存*)
				g_aiError_V_Other[iN]:=stStProtocol_PDU_Up_Rd.iErr_V_Raw_1;
				g_aiError_H_Other[iN]:=stStProtocol_PDU_Up_Rd.iErr_H_Raw_1;

				(*如果附加的报文是命令/如下便是解析过程*)
				pbyTemp:= ADR(stStProtocol_PDU_Up_Rd.byPkgId);
				wCHK_Up_Calc:= KS_CRC(pbyTemp, 46, ADR(dwCheckSumVal));(*46=byPkgId+abyPayLoad的长度*)
				IF wCHK_Up_Calc=stStProtocol_PDU_Up_Rd.wCHK THEN(*CRC校验OK*)
					CASE stStProtocol_PDU_Up_Rd.byPkgId OF
					16#5:(*command of 'StPdu_Up_05'*)
						pstStCMD_F05_:= ADR(stStProtocol_PDU_Up_Rd.abyPayload);
						IF pstStCMD_F05_<>0 THEN
							o_astStErrParam_Use[iN].iResult_VFollowpre_1stDerivate:= pstStCMD_F05_^.iResult_VFollowpre_1stDerivate;
							aiResult_VFollowpre_1stDerivate[iN]:= pstStCMD_F05_^.iResult_VFollowpre_1stDerivate;
							o_astStErrParam_Use[iN].uiBaseUse_t1:= pstStCMD_F05_^.uiBaseUse_t1;
							o_astStErrParam_Use[iN].uiBaseUse_t2:= pstStCMD_F05_^.uiBaseUse_t2;
							o_astStErrParam_Use[iN].uiPeakValue_t1:= pstStCMD_F05_^.uiPeakValue_t1;
							o_astStErrParam_Use[iN].uiPeakValue_t2:= pstStCMD_F05_^.uiPeakValue_t2;
						(*统一注释0916+2026.5.9.110642	*)
							i_pstStSysParam^.astStRSV_UnitParam_UnSave[iN].iCurLabelPos:= pstStCMD_F05_^.iCurLabelPos;(*本色三角标位置，点数*)
							i_pstStSysParam^.astStRSV_UnitParam_UnSave[iN].iPreLabelPos:= pstStCMD_F05_^.iPreLabelPos;(*前色三角标位置，点数*)
							i_pstStSysParam^.astStRSV_UnitParam_UnSave[iN].byFlag_CommFromSlave:= pstStCMD_F05_^.byFlag_CommFromSlave;(*bit0 xFlag_FindFirstSuccess;bit1 xFlag_FindPreSuccess*)
							i_pstStSysParam^.astStRSV_UnitParam_UnSave[iN].xFlag_FindFirstSuccess:= i_pstStSysParam^.astStRSV_UnitParam_UnSave[iN].byFlag_CommFromSlave.0;
							i_pstStSysParam^.astStRSV_UnitParam_UnSave[iN].xFlag_FindPreSuccess:= i_pstStSysParam^.astStRSV_UnitParam_UnSave[iN].byFlag_CommFromSlave.1;
							i_pstStSysParam^.astStRSV_UnitParam_UnSave[iN].byDetectedSignalCount:= pstStCMD_F05_^.byDetectedSignalCount;(*当前检测到色标个数*)
							i_pstStSysParam^.astStRSV_UnitParam_UnSave[iN].byMarkStep:= pstStCMD_F05_^.byMarkStep;(*当前全自动套印步骤*)
							i_pstStSysParam^.astStRSV_UnitParam_UnSave[iN].rGateSignalWidth_R:= BYTE_TO_REAL (pstStCMD_F05_^.byWidthRS) /10.0;(*粗采样计算波形宽度*)	
							
						END_IF
					ELSE;
					END_CASE
				END_IF
			END_IF
		END_FOR(*end?'FOR iN:=1 TO i_iUnitMax BY 1 DO'*)	
	ELSE;	
	END_IF
	
	IF iRtn_Rd_II=0 THEN
		(*开始逐色组处理读取的内容*)
		FOR iN:=2 TO i_iUnitMax BY 1 DO(*2026.5.24.212501/han.dp/套色误差是从2色开始的*)
			pawErr_tmp:= ADR(adwErrMix_RdVision[iN-1]);

			(*纵向误差*)
			aiRtnMatrix[iN,1]:= 
			KS_UnPack_VisionERR(
				pawErr_tmp^[1],(*2026.5.27.102650/han.dp/按原理梳理/第1个数值是相机检测的X距离/顺时针90度旋转成了Y*)
				ADR(axFlag_valid_v_tmp[iN]), 
				ADR(axFlag_update_v_tmp[iN]), 
				ADR(axFlag_bitchk_v_tmp[iN]), 
				ADR(aiERR_v_pure[iN]));
			IF aiRtnMatrix[iN,1]=0 THEN(*转换ok*)
				IF axFlag_update_v_tmp[iN]<>axFlag_update_v_rec[iN] THEN(*误差更新了*)
					o_astStErrParam_Use[iN].uiV_cam_raw:= pawErr_tmp^[1];
					IF axFlag_valid_v_tmp[iN] THEN(*误差有效*)
						aiError_V_II[iN]:= -aiERR_v_pure[iN] - aiRef_KSMatrixMark[iN,2];(*2026.5.27.110642/han.dp/方向修订*)
					ELSE(*误差无效*)
						aiError_V_II[iN]:= gc_iValueReferToLost;
					END_IF
					abyIndex_V_II[iN]:= abyIndex_V_II[iN]+1;
				END_IF
				axFlag_update_v_rec[iN]:= axFlag_update_v_tmp[iN];
			END_IF


			(*横向误差*)
			aiRtnMatrix[iN,2]:= 
			KS_UnPack_VisionERR(
				pawErr_tmp^[2],
				ADR(axFlag_valid_h_tmp[iN]), 
				ADR(axFlag_update_h_tmp[iN]), 
				ADR(axFlag_bitchk_h_tmp[iN]), 
				ADR(aiERR_h_pure[iN]));
			IF aiRtnMatrix[iN,2]=0 THEN(*转换ok*)
				IF axFlag_update_h_tmp[iN]<>axFlag_update_h_rec[iN] THEN(*误差更新了*)
					axFlag_update_h_rec[iN]:= axFlag_update_h_tmp[iN];
					o_astStErrParam_Use[iN].uiH_cam_raw:= pawErr_tmp^[2];
					IF axFlag_valid_h_tmp[iN] THEN(*误差有效*)
						aiError_H_II[iN]:= -aiERR_h_pure[iN] - aiRef_KSMatrixMark[iN,1];(*2026.5.27.132504/han.dp/修订方向*)
					ELSE(*误差无效*)
						aiError_H_II[iN]:= gc_iValueReferToLost;
					END_IF
					abyIndex_H_II[iN]:= abyIndex_H_II[iN]+1;
				END_IF
			END_IF	
		END_FOR	
	ELSE;
	END_IF
	(*统一注释0916+2026.5.30.094300*)
	FOR iN:=1 TO i_iUnitMax BY 1 DO
		IF i_abyGetErrMode[iN].1 AND i_abyGetErrMode[iN].7 THEN(*统一注释0916+指定了金刚并且打开了金刚误差调整*)
			abyIndex_V[iN]:= abyIndex_V_II[iN];
			abyIndex_H[iN]:= abyIndex_H_II[iN];
			aiError_V[iN]:= aiError_V_II[iN];
			aiError_H[iN]:= aiError_H_II[iN];	
		ELSE(*统一注释0916+其他全部按月光宝盒误差处理吧*)
			abyIndex_V[iN]:= abyIndex_V_I[iN];
			abyIndex_H[iN]:= abyIndex_H_I[iN];
			aiError_V[iN]:= aiError_V_I[iN];
			aiError_H[iN]:= aiError_H_I[iN];		
		END_IF
		
(*统一注释0916+加保存吧2026.5.30.095819*)
		o_astStErrParam_Use[iN].iV_cam_pure:= aiError_V_II[iN];	
		o_astStErrParam_Use[iN].iH_cam_pure:= aiError_H_II[iN];	
		o_astStErrParam_Use[iN].iErr_V_I_:= aiError_V_I[iN];	
		o_astStErrParam_Use[iN].iErr_H_I_:= aiError_H_I[iN];		
(*统一注释0916+到这里误差已经有了，处理各种标志*)
		(*新飞点剔除:误差平均之前对原始逐帧误差剔除,飞点/暂缓用锁存值(上一好值)替换,必须先剔除再平均,否则飞点被N幅平均稀释后可能低于门限漏掉*
		 *本版纵/横索引可能独立变化(金刚视觉源),故按各自索引变化判定新帧;总开关gc_xUseNewFlyRemove在GCL,置FALSE并重编译即回退旧逻辑*
		 *飞点/暂缓帧置axFakePoint_V/H(byErrSts.2/6),阶跃(真实变化)不置位|Yang.zj+用于新飞点检测 2026.10.27.105623*)
		IF gc_xUseNewFlyRemove THEN
			xFlyNewFrame_V:= (abyIndex_V_Pre[iN]<>abyIndex_V[iN]);
			xFlyNewFrame_H:= (abyIndex_H_Pre[iN]<>abyIndex_H[iN]);
			(*工况切换检测:色标排列模式/RGB信号通道/横向开关/误差源模式任一变化,该色组剔除器可信历史不可信,复位重新暖机*)
			xFlyReset:= FALSE;
			IF i_pstStSysParam<>0 THEN
				IF (aiFlyMarkModePre[iN]<>i_pstStSysParam^.astStUnitParam_Save[iN].iMarkArrangeMode)
					OR (abyFlySignalPre[iN]<>i_pstStSysParam^.astStUnitParam_Save[iN].bySignalSelect)
					OR (axFlyHorEnPre[iN]<>i_pstStSysParam^.astStUnitParam_Save[iN].dwFlag_Ctl.0)
					OR (abyFlyGetErrModePre[iN]<>i_abyGetErrMode[iN])
					OR (axFlyRollPre[iN]<>g_astStIOMap_Axis_FE[iN].o_xRel_Press) THEN(*压辊沿:合压/抬起双向变化都复位——停机/急停同样引起压辊变化,一并覆盖;安静期旧σ与历史对压辊后快速爬坡完全不适用,不复位会陷入"确认→观察失败"两帧循环,输出冻结(实测4U开机压辊冻结15帧/约47秒)|Yang.zj+ 2026.10.27.210459*)
					aiFlyMarkModePre[iN]:= i_pstStSysParam^.astStUnitParam_Save[iN].iMarkArrangeMode;
					abyFlySignalPre[iN]:= i_pstStSysParam^.astStUnitParam_Save[iN].bySignalSelect;
					axFlyHorEnPre[iN]:= i_pstStSysParam^.astStUnitParam_Save[iN].dwFlag_Ctl.0;
					abyFlyGetErrModePre[iN]:= i_abyGetErrMode[iN];
					axFlyRollPre[iN]:= g_astStIOMap_Axis_FE[iN].o_xRel_Press;
					xFlyReset:= TRUE;
				END_IF
			END_IF
			afbKS_FlyRemove_V[iN](
				i_iErr:= aiError_V[iN],
				i_xErrValid:= xFlyNewFrame_V AND (aiError_V[iN]<>gc_iValueReferToLost),
				i_xLost:= xFlyNewFrame_V AND (aiError_V[iN]=gc_iValueReferToLost),
				i_xReset:= xFlyReset,
				o_iErrResult=> aiError_V_Fly[iN],
				o_xFake=> axFakePoint_V[iN]);
			afbKS_FlyRemove_H[iN](
				i_iErr:= aiError_H[iN],
				i_xErrValid:= xFlyNewFrame_H AND (aiError_H[iN]<>gc_iValueReferToLost),
				i_xLost:= xFlyNewFrame_H AND (aiError_H[iN]=gc_iValueReferToLost),
				i_xReset:= xFlyReset,
				o_iErrResult=> aiError_H_Fly[iN],
				o_xFake=> axFakePoint_H[iN]);
		ELSE
			aiError_V_Fly[iN]:= aiError_V[iN];(*旧路径:不剔除,原值送平均*)
			aiError_H_Fly[iN]:= aiError_H[iN];
		END_IF
		IF abyIndex_V_Pre[iN]<>abyIndex_V[iN] OR abyIndex_H_Pre[iN]<>abyIndex_H[iN] THEN
			abyErrSts[iN]:= 0;
			axValid_V[iN]:= FALSE;
			axValid_H[iN]:= FALSE;

			IF aiError_V[iN]=gc_iValueReferToLost THEN
				abyErrSts[iN].1:= TRUE;(*纵向丢失*)
			ELSE
				axValid_V[iN]:= TRUE;
			END_IF

			IF aiError_H[iN]=gc_iValueReferToLost THEN
				abyErrSts[iN].5:= TRUE;(*横向丢失*)	
			ELSE
				axValid_H[iN]:= TRUE;
			END_IF
			
			
			o_astStErrParam_Use[iN].byIDX_V:= abyIndex_V[iN];
			o_astStErrParam_Use[iN].byIDX_H:= abyIndex_H[iN];

			(*误差平均-纵向*)
			afbKS_FB_AverageErr_Arc_V[iN](
				i_xEn:= TRUE,
				i_iErr:= aiError_V_Fly[iN],(*新飞点:喂剔除后的值|Yang.zj+用于新飞点检测 2026.10.27.105623*)
				i_xErrValid:= axValid_V[iN],(*2025.01.03.110017*)
				i_byAverageNum:= i_abyAverageNum_V[iN],
				o_iErrResult=>aiError_V_Res[iN]);

			IF NOT gc_xUseNewFlyRemove THEN(*旧飞点判断:新算法启用时整块跳过|Yang.zj+用于新飞点检测 2026.10.27.105623*)
			(*飞点剔除-纵向*)
			axFakePoint_V[iN]:= FALSE;
			afbKS_FB_PickOutFakePoint_V[iN](
				i_xIsValidError:= axValid_V[iN],
				i_iError_0_01mm:= aiError_V_Res[iN],
				i_iVariationBaseValue:= 50,(*2025.01.03.110017*)
				i_iBoundaryError_0_01mm:= 20,
				i_iErrorLevel_0_01mm:= 25,
				i_iVariationVariationMin:= 5,
				i_iVariationVariationMax:= 50,
				o_xFakeIsConfirmed=> axFakePoint_V[iN]);
			END_IF
			
			(*误差平均-横向*)
			afbKS_FB_AverageErr_Arc_H[iN](
				i_xEn:= TRUE,
				i_iErr:= aiError_H_Fly[iN],(*新飞点:喂剔除后的值|Yang.zj+用于新飞点检测 2026.10.27.105623*)
				i_xErrValid:= axValid_H[iN],(*2025.01.03.110017*)
				i_byAverageNum:= i_abyAverageNum_H[iN],
				o_iErrResult=>aiError_H_Res[iN]);			

			IF NOT gc_xUseNewFlyRemove THEN(*旧飞点判断:新算法启用时整块跳过|Yang.zj+用于新飞点检测 2026.10.27.105623*)
			(*飞点剔除-横向*)
			axFakePoint_H[iN]:= FALSE;
			afbKS_FB_PickOutFakePoint_H[iN](
				i_xIsValidError:= axValid_H[iN],
				i_iError_0_01mm:= aiError_H_Res[iN],
				i_iVariationBaseValue:= 50,
				i_iBoundaryError_0_01mm:= 20,
				i_iErrorLevel_0_01mm:= 25,
				i_iVariationVariationMin:= 5,
				i_iVariationVariationMax:= 50,
				o_xFakeIsConfirmed=> axFakePoint_H[iN]);
			END_IF
			(*统一注释0916+显示平均@2026.4.11.150119+	*)
			afbKS_FB_AverageErr_Arc_V_Display[iN](
				i_xEn:= TRUE,
				i_iErr:= aiError_V_Fly[iN],(*新飞点:喂剔除后的值|Yang.zj+用于新飞点检测 2026.10.27.105623*)
				i_xErrValid:= axValid_V[iN],(*2025.01.03.110017*)
				i_byAverageNum:= i_abyAverageNum_V_Display[iN],
				o_iErrResult=>aiError_V_Res_Display[iN]);
	
			afbKS_FB_AverageErr_Arc_H_Display[iN](
				i_xEn:= TRUE,
				i_iErr:= aiError_H_Fly[iN],(*新飞点:喂剔除后的值|Yang.zj+用于新飞点检测 2026.10.27.105623*)
				i_xErrValid:= axValid_H[iN],(*2025.01.03.110017*)
				i_byAverageNum:= i_abyAverageNum_H_Display[iN],
				o_iErrResult=>aiError_H_Res_Display[iN]);	
				
		END_IF
		(*到这里误差的飞点和平均都处理完了，该处理其他东西了*)
		o_astStErrParam_Use[iN].iErr_V_Unprocessed:= aiError_V[iN];(*原始误差*)
		o_astStErrParam_Use[iN].iErr_H_Unprocessed:= aiError_H[iN];

		o_astStErrParam_Use[iN].byErrSts:= 0;
		o_astStErrParam_Use[iN].byErrSts:= abyErrSts[iN];(*现在的状态*)
		
(*统一注释0916+2026.5.9.110835处理一下显示平均相关			*)
		IF NOT o_astStErrParam_Use[iN].byErrSts.1 THEN(*纵向未丢失*)
			o_astStErrParam_Use[iN].iErr_V:= aiError_V_Res[iN]-i_aiAdjust_V[iN];
			(*统一注释0916+2026.4.11.150603+*)
			o_astStErrParam_Use[iN].iErr_V_Display:= aiError_V_Res_Display[iN]-i_aiAdjust_V[iN];
			IF axFakePoint_V[iN] THEN(*飞点*)
				o_astStErrParam_Use[iN].byErrSts.2:= TRUE;
			END_IF
			(*报警标志检查*)
			IF ABS(o_astStErrParam_Use[iN].iErr_V_Display)>ABS(i_aiAlarm_V[iN]) THEN
				o_astStErrParam_Use[iN].byErrSts.0:= TRUE;
			END_IF
		ELSE
			o_astStErrParam_Use[iN].iErr_V:= gc_iValueReferToLost;
			o_astStErrParam_Use[iN].iErr_V_Display:= gc_iValueReferToLost;					
		END_IF
		IF NOT o_astStErrParam_Use[iN].byErrSts.5 THEN(*横向未丢失*)
			o_astStErrParam_Use[iN].iErr_H:= aiError_H_Res[iN]-i_aiAdjust_H[iN];(*处理完的误差-修正量*)	
			(*统一注释0916+2026.4.11.150603+*)
			o_astStErrParam_Use[iN].iErr_H_Display:= aiError_H_Res_Display[iN]-i_aiAdjust_H[iN];		
			IF axFakePoint_H[iN] THEN(*飞点*)
				o_astStErrParam_Use[iN].byErrSts.6:= TRUE;
			END_IF
			(*报警标志检查*)
			IF ABS(o_astStErrParam_Use[iN].iErr_H_Display)>ABS(i_aiAlarm_H[iN]) THEN
				o_astStErrParam_Use[iN].byErrSts.4:= TRUE;
			END_IF		
		ELSE
			o_astStErrParam_Use[iN].iErr_H:= gc_iValueReferToLost;	
			(*统一注释0916+2026.4.11.150603+*)
			o_astStErrParam_Use[iN].iErr_H_Display:= gc_iValueReferToLost;			
		END_IF				
		abyIndex_V_Pre[iN]:= abyIndex_V[iN];
		abyIndex_H_Pre[iN]:= abyIndex_H[iN];	
	END_FOR
END_IF	
			
	
SysTimeGetUs(stSystimeEnd);(*2026.5.24.152052/han.dp/获取结束时间*)
o_stSystimeElapsed:= stSystimeEnd-stSystimeStart;(*耗时/单位us*)