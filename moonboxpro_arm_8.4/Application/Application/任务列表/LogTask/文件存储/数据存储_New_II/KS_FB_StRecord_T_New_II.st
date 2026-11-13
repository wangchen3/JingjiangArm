(*@CES
Name=KS_FB_StRecord_T_New_II
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=faba27f1-f8c3-44f6-aa1e-35d403c4c69a
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_StRecord_T_New_II
VAR_INPUT
	i_xEn: BOOL;(* 数据写入的使能条件 *)
	i_iGrpId : INT;(*系ID*)
	i_pstStTravelDataRec: POINTER TO StTravelDataRec := 0; (* 数据存储的内存池 *)
	i_pstStSysParam : POINTER TO StSysParam;
	i_pstStIOMap_Uw: POINTER TO StIOMap_UwRw_FE; (* 放料io|分A/B系 *)
	i_pstStIOMap_Rw: POINTER TO StIOMap_UwRw_FE; (* 收料io|分A/B系 *)

	i_iIOGrpIdx_Uw: INT := 1; (* 放料组id *)
	i_iIOGrpIdx_Rw: INT := 1; (* 收料组id *)
	i_xReflectionSensorValid : BOOL; //预测湖面
	i_xUseAntiNotch_If : BOOL ; //放牵使用陷波
	
	i_lrStep_Uw : LREAL;
	i_lrStep_Rw : LREAL;
	i_lrStep_If : LREAL;
	i_lrStep_Of : LREAL;
	i_wPreHotRollerFrq :WORD ; 
	i_wWaterCoolRollerFrq : WORD ;  
	
	i_lrKp_If   : LREAL;
	i_lrKi_If 	: LREAL;
	i_lrKd_If 	: LREAL; 
	
	i_lrKp_Of   : LREAL;
	i_lrKi_Of 	: LREAL;
	i_lrKd_Of 	: LREAL; 
	
	i_rMainVel_Uw : REAL; 
	i_rMainVel_Rw : REAL;
	
	i_rDiamWuCompensate_Uw : REAL; 
	i_rDiamWuCompensate_Rw : REAL; 
	
	i_rEstiDia_LowPass_Uw :REAL ; 
	
	i_rEstiDia_LowPass_Rw : REAL ;
 	
	
	i_rAntiNotch_Out_If : REAL; 
	i_rAntiNotch_Out_Uw :REAL;
	
	i_wAO_If_I : WORD;(*放牵输出模拟量*)
	i_wAO_Of_I : WORD;(*收牵输出模拟量*)
	
	i_iPromptMsgId : INT;(* 报警代码*)
	i_iMotionStepId : INT  ; (* 电机运行步骤 *)
	
	i_iGrpGearMotion_Num: INT;
	i_aiGrpGearMotion_StdList: ARRAY [1..MAX_STATION_NUM] OF INT;
	
	i_iGrpGantryTrapMotion_Num: INT;
	i_aiGrpGantryTrapMotion_StdList: ARRAY [1..MAX_STATION_NUM] OF INT;
	
	i_iGrpTrapMotion_Num: INT;
	i_aiGrpTrapMotion_StdList: ARRAY [1..MAX_STATION_NUM] OF INT;
	
	i_pastStAxis_Sts_Gear 		: POINTER TO ARRAY [1..MAX_STATION_NUM] OF StAxis_Sts_Gear;
	i_pastStAxis_Sts_GantryTrap 		: POINTER TO ARRAY [1..MAX_STATION_NUM] OF StAxis_Sts_GantryTrap;
	i_pastStAxis_Sts_Trap 		: POINTER TO ARRAY [1..MAX_STATION_NUM] OF StAxis_Sts_Trap;
END_VAR
VAR_OUTPUT
	o_xEno: BOOL;(* equal inp_parameter of 'i_xEn' *)
	o_iErNo: INT; (* -1:输入的指针型参数错误/-1001:申请的内存放不下张力结构体/-1002:无法读取到写入buf的首地址 *)
END_VAR
VAR
	iN: INT;
	iM: INT;
	NowTimeMs:STRING;
	uiWR_tmp: UINT;
	dwExtendedAddr: DWORD;
	dwPayloadFrom: DWORD;
	iPackageTotalBytes: INT;
	iBufLen_All_Tmp: INT;
	iBufLen_St_Tmp: INT;
	iBufLen_VariableSpace: INT;
	uiTmpItemMaxNum: UINT;
	puiPreambleMark: POINTER TO UINT;
	piLength_Payload: POINTER TO INT;
	pbyEndMark: POINTER TO BYTE;
	pstStRecord_T: POINTER TO StRecord_T_New_II;
	pstStTravelDataItem: POINTER TO StTravelDataItem;
	iLpMax_major: INT;(* 大指令结构体一维下标循环上限/i_pastSTSetMultiMcFunctionPrm *)
	iLpMax_minor: INT;(* 大指令结构体二维下标循环上限/i_pastSTSetMultiMcFunctionPrm *)
	byUnitNr_tmp: BYTE;
	byAxisNr_tmp: BYTE;
	iBytesRemainExt: INT;(* 扩展区域/剩余字节数 *)
	iBytes_SubPkgNeed: INT;
	xExtSpaceNotEnough: BOOL;(* 有效空间不足 *)
	//pstStPTSts_tmp: POINTER TO StPTSts;
	iAxisNum_Appended: INT;
	iAxisNum_TotalNum: INT;	
	iUnitId:INT;
	iTypeId: INT;
	dwsizeofTension:DWORD;
	dwsizeofWatch:DWORD;
	sResult: STRING;
	rVel_Cur: REAL;
	rVel_Film: REAL;
	dwTmpMask : DWORD ; 
	
	pstStAxis_Sts_Gear : POINTER TO StAxis_Sts_Gear;
	pstStAxis_Sts_GantryTrap : POINTER TO StAxis_Sts_GantryTrap;
	pstStAxis_Sts_Trap : POINTER TO StAxis_Sts_Trap;
	
	//2026.08.21.131610 增加变频器报警保存_Start
	iTemp_UwInveterAlarm:INT;
	iTemp_RwInveterAlarm:INT;
	//2026.08.21.131610 增加变频器报警保存_End
END_VAR

{IMPLEMENTATION}
o_xEno:= i_xEn;
o_iErNo:= 0;
IF i_xEn THEN
	IF	i_pstStTravelDataRec<>0 AND
		i_pstStSysParam <> 0 AND
		i_pstStIOMap_Uw <> 0 AND
		i_pstStIOMap_Rw <> 0 THEN
		(* 传入的参数地址都是ok的才能继续 *)

		uiTmpItemMaxNum:= DWORD_TO_UINT(SIZEOF(i_pstStTravelDataRec^.astStTravelDataItem)/SIZEOF(i_pstStTravelDataRec^.astStTravelDataItem[1]));
		IF i_pstStTravelDataRec^.uiWR>=1 AND i_pstStTravelDataRec^.uiWR<= uiTmpItemMaxNum THEN;
		ELSE(* 索引异常的处理 *)
			i_pstStTravelDataRec^.uiWR:= i_pstStTravelDataRec^.uiRD:= 1;
		END_IF

		pstStTravelDataItem:= ADR(i_pstStTravelDataRec^.astStTravelDataItem[i_pstStTravelDataRec^.uiWR]);(* 定位到要写入的行/程序默认对于ADR()操作符都是认为成功的/*_^ *)
	
		(* 算出标准结构以外可以追加的轴信息最大容量 *)
		iBufLen_All_Tmp:= DWORD_TO_INT(SIZEOF(pstStTravelDataItem^.abyPayload));
		iBufLen_St_Tmp:= DWORD_TO_INT(SIZEOF(pstStRecord_T^));
		iBytesRemainExt:= iBufLen_All_Tmp(*总长度 *)
								-DWORD_TO_INT(SIZEOF(puiPreambleMark^)) (*减去preamble *)
								-DWORD_TO_INT(SIZEOF(piLength_Payload^)) (*减去packagelength *)
								-DWORD_TO_INT(SIZEOF(pbyEndMark^)) (*减去endmark *)
								-iBufLen_St_Tmp; (* 减去结构体 *)
		IF iBytesRemainExt<0 THEN o_iErNo:= -1001; RETURN; END_IF(* 连基本的信息都无法容纳/那就尽快放弃/开发人员应适当开辟更大的内存用于存放数据 *)

		(* -------------------------------------------------- *)
		(* 开始处理数据保存包的内容 *)
		(* -------------------------------------------------- *)
		pstStTravelDataItem^.uiValidBytesNum:= 0;(* 字节计数清零 *)
		dwPayloadFrom:= ADR(pstStTravelDataItem^.abyPayload);(* 净荷数据的存储地址 *)

		(* 写入前导码/0xaa55 *)
		puiPreambleMark:= dwPayloadFrom;
		puiPreambleMark^:= INT_TO_UINT(PREAMBLE);
		pstStTravelDataItem^.uiValidBytesNum:= pstStTravelDataItem^.uiValidBytesNum + SIZEOF(puiPreambleMark^);(* 前导码已经包含 *)
		pstStTravelDataItem^.uiValidBytesNum:= pstStTravelDataItem^.uiValidBytesNum + SIZEOF(piLength_Payload^);(* 2023.7.27.110201/han.dp/要把长度也写入 *)

		(* 写入主结构体数据 *)
		iPackageTotalBytes:= 0; (* 数据包字节统计 *)
		pstStRecord_T:= dwPayloadFrom+SIZEOF(puiPreambleMark^)+SIZEOF(piLength_Payload^);(* 不会=0/下面不用判断pstStRecord_T<>0了 *)
		sResult:= KS_GetTimeString(TIMEFORMAT_NO_HYPHEN, FALSE, FALSE, ADR(pstStRecord_T^.dwYMD), ADR(pstStRecord_T^.dwHMSU));(* 2023.7.27.093547/han.dp *)

		//添加存储数据
		pstStRecord_T^.byGrpId:= INT_TO_BYTE(i_iGrpId); (* 系id\自动赋值|2020.1.4.171257 *)
		pstStRecord_T^.rVel_Cur:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rVel_Cur;
		pstStRecord_T^.rVel_Film:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rVel_Film;
		g_adwIndex[i_iGrpId]:= g_adwIndex[i_iGrpId]+1;
		pstStRecord_T^.dwIndex:= g_adwIndex[i_iGrpId];
		(*2022.5.4.145834  重新赋值*)
		pstStRecord_T^.uiMillimeter_Diam_PaperTube_Uw:= REAL_TO_UINT(i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rDia_PaperRoller_Uw); (* 放料卷纸卷直径|单位mm|@2019.11.28.112452 *)
		(*定义为了自动接料的厚度值@2023.12.02.110951*)
		pstStRecord_T^.uiMicron_FilmThickness:= REAL_TO_UINT(i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rFilmThickNess*1000); (* 料膜厚度|单位um|@2019.11.28.112452 *)
		
		(*修改为了自动运算的值@2023.12.02.110417*)
		pstStRecord_T^.uiMicron_FilmThickness_RevCalculated:= REAL_TO_UINT(i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rFilmThickNess_Using*1000); (* 料膜厚度的反算值|单位um|@2019.11.29.153103 *)
		pstStRecord_T^.uiMeterLength_SurplusMaterial:=
				REAL_TO_UINT(i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rAutoMaticCuttingLenth_CurMode_uw); (* 剩余料膜长度|单位m|@2019.11.28.112452
																					是会根据当前接料模式切换的*)

		(*复杂的合成标志 *)
		dwTmpMask:= 0;
		dwTmpMask.0:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].wUwRwAxisProf.0; (* 放料当前轴 *)
		dwTmpMask.1:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].wUwRwAxisProf.1; (* 收料当前轴 *)


		(*2022.11.2.104622 增加伪随机的参数*)
		dwTmpMask.2:= i_pstStSysParam^.stStSysParam_Save.xPseudoRandomEn ;
		dwTmpMask.3:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xPseudoRandomTsting;
		dwTmpMask.4:= FALSE;


		dwTmpMask.5:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].xUseDiam_LowPass_Uw;(*低通滤波使能@2023.09.26.194818*)
		dwTmpMask.6:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].xUseDiam_LowPass_Rw;(*低通滤波使能@2023.09.26.194818*)
		dwTmpMask.7:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].xUseAntiNotch_Uw;(*放料使用陷波@2024.9.10.122635*)
		dwTmpMask.8:= i_xUseAntiNotch_If;(*放牵料使用陷波@2024.9.10.122635*)

		(*2022.5.17.135316*)
		dwTmpMask.10:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFilmTouchRoller_Uw;(*料膜接触到了辊子标志*)

		dwTmpMask.16:= i_pstStIOMap_Uw^.o_xRel_TowerForeward; (* 放料翻料架正转 *)
		dwTmpMask.17:= i_pstStIOMap_Uw^.o_xRel_TowerReversal; (* 放料翻料架反转 *)
		dwTmpMask.18:= i_pstStIOMap_Rw^.o_xRel_TowerForeward; (* 收料翻料架正转 *)
		dwTmpMask.19:= i_pstStIOMap_Rw^.o_xRel_TowerReversal; (* 收料翻料架反转 *)
		dwTmpMask.20:= i_pstStIOMap_Uw^.o_xAxisAForeward; (* 放料A轴正转 *)
		dwTmpMask.21:= i_pstStIOMap_Uw^.o_xAxisBForeward; (* 放料b轴正转 *)
		dwTmpMask.22:= i_pstStIOMap_Rw^.o_xAxisAForeward; (* 收料A轴正转 *)
		dwTmpMask.23:= i_pstStIOMap_Rw^.o_xAxisBForeward; (* 收料B轴正转 *)
		dwTmpMask.26:= i_xReflectionSensorValid; (* 预测弧面 *)
		
		IF  i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xCutterOnTop_Uw THEN
			(* 放料上裁 *)
			dwTmpMask.27:= i_pstStIOMap_Uw^.i_xSensor_DiamMeasureLocating_UpCut; (* 放料对射电眼信号 *)
			dwTmpMask.28:= i_pstStIOMap_Uw^.i_xCut; (* 裁切按钮输入 *)
			dwTmpMask.29:= i_pstStIOMap_Uw^.i_xSensor_Reflex_A_Up OR i_pstStIOMap_Uw^.i_xSensor_Reflex_B_Up; (* 弧面信号 *)
			dwTmpMask.30:= i_pstStIOMap_Uw^.o_xCutter_UpCut; (* 放料裁刀 *)
			dwTmpMask.31:= i_pstStIOMap_Uw^.o_xCutCylinder_UpCut; (* 放料胶辊 *)
		ELSE
			(* 放料下裁 *)
			dwTmpMask.27:= i_pstStIOMap_Uw^.i_xSensor_DiamMeasureLocating_DnCut;
			dwTmpMask.28:= i_pstStIOMap_Uw^.i_xCut;
			dwTmpMask.29:= i_pstStIOMap_Uw^.i_xSensor_Reflex_A_Dn OR i_pstStIOMap_Uw^.i_xSensor_Reflex_B_Dn;
			dwTmpMask.30:= i_pstStIOMap_Uw^.o_xCutter_DnCut;
			dwTmpMask.31:= i_pstStIOMap_Uw^.o_xCutCylinder_DnCut;
		END_IF
		pstStRecord_T^.dwFlag:= dwTmpMask;

		//pstStRecord_T^.arAI_UwRw_IfOf[1]:= LREAL_TO_REAL(i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].lrAI_SwingArm_Uw_cur); (* 放料模拟量 *)
		//pstStRecord_T^.arAI_UwRw_IfOf[2]:= LREAL_TO_REAL(i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].lrAI_SwingArm_Rw_cur); (* 收料模拟量 *)
		//pstStRecord_T^.arAI_UwRw_IfOf[3]:= LREAL_TO_REAL(i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].lrAI_SwingArm_If_cur); (* 放牵模拟量 *)
		//pstStRecord_T^.arAI_UwRw_IfOf[4]:= LREAL_TO_REAL(i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].lrAI_SwingArm_Of_cur); (* 收牵模拟量 *)

		pstStRecord_T^.arAI_UwRw_IfOf[1]:= LREAL_TO_REAL(i_pstStSysParam^.astStGrpParam_UnSave[i_iIOGrpIdx_Uw].rAI_Uw); (* 放料模拟量 *)
		pstStRecord_T^.arAI_UwRw_IfOf[2]:= LREAL_TO_REAL(i_pstStSysParam^.astStGrpParam_UnSave[i_iIOGrpIdx_Rw].rAI_Rw);//i_pstStSysParam^.astStGrpParam_UnSave[i_iIOGrpIdx_Rw].rAI_Rw); (* 收料模拟量 *)
		pstStRecord_T^.arAI_UwRw_IfOf[3]:= LREAL_TO_REAL(i_pstStSysParam^.astStGrpParam_UnSave[i_iIOGrpIdx_Uw].rAI_If); (* 放牵模拟量 *)
		pstStRecord_T^.arAI_UwRw_IfOf[4]:= LREAL_TO_REAL(i_pstStSysParam^.astStGrpParam_UnSave[i_iIOGrpIdx_Rw].rAI_Of); (* 收牵模拟量 *)

		pstStRecord_T^.arPI_UwRw_IfOf[1]:= LREAL_TO_REAL(i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rPi_Value_Uw); (* 放料pi调整量 *)
		pstStRecord_T^.arPI_UwRw_IfOf[2]:= LREAL_TO_REAL(i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rPi_Value_Rw); (* 收料pi调整量 *)
		pstStRecord_T^.arPI_UwRw_IfOf[3]:= LREAL_TO_REAL(i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rPi_Value_If); (* 放牵pi调整量 *)
		pstStRecord_T^.arPI_UwRw_IfOf[4]:= LREAL_TO_REAL(i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rPi_Value_Of); (* 收牵pi调整量 *)
	
		pstStRecord_T^.arDiam_UwRw_Girth_IfOf[1]:= LREAL_TO_REAL(i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rDiamCurAxis_Uw); (* 放料直径 *)
		pstStRecord_T^.arDiam_UwRw_Girth_IfOf[2]:= LREAL_TO_REAL(i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rDiamCurAxis_Rw); (* 收料直径 *)
		pstStRecord_T^.arDiam_UwRw_Girth_IfOf[3]:= LREAL_TO_REAL(i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rUsingGirth_If); (* 放牵周长 *)
		pstStRecord_T^.arDiam_UwRw_Girth_IfOf[4]:= LREAL_TO_REAL(i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rUsingGirth_Of); (* 收牵周长 *)
	
		pstStRecord_T^.arStep_UwRw_IfOf[1]:= LREAL_TO_REAL(i_lrStep_Uw); (* 放料前馈 *)
		pstStRecord_T^.arStep_UwRw_IfOf[2]:= LREAL_TO_REAL(i_lrStep_Rw); (* 收料前馈 *)
		pstStRecord_T^.arStep_UwRw_IfOf[3]:= LREAL_TO_REAL(i_lrStep_If); (* 放牵前馈 *)
		pstStRecord_T^.arStep_UwRw_IfOf[4]:= LREAL_TO_REAL(i_lrStep_Of); (* 收牵前馈 *)
	
		pstStRecord_T^.arVel_UwRw_IfOf[1]:= LREAL_TO_REAL(i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rVelRPM_Cur_Uw); (* 放料转速 *)
		pstStRecord_T^.arVel_UwRw_IfOf[2]:= LREAL_TO_REAL(i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rVelRPM_Cur_Rw); (* 收料转速 *)
		pstStRecord_T^.arVel_UwRw_IfOf[3]:= LREAL_TO_REAL(i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rVel_Cur_If); (* 放牵速度 *)
		pstStRecord_T^.arVel_UwRw_IfOf[4]:= LREAL_TO_REAL(i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rVel_Cur_Of); (* 收牵速度 *)

		pstStRecord_T^.aiKpid_UwRw_IfOf[1,1]:= LREAL_TO_WORD(i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].arKpid_Current_Uw[1]*100); (* 放料PID *)
		pstStRecord_T^.aiKpid_UwRw_IfOf[1,2]:= LREAL_TO_WORD(i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].arKpid_Current_Uw[2]*100);
		pstStRecord_T^.aiKpid_UwRw_IfOf[1,3]:= LREAL_TO_WORD(i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].arKpid_Current_Uw[3]*100);

		pstStRecord_T^.aiKpid_UwRw_IfOf[2,1]:= LREAL_TO_WORD(i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].arKpid_Current_Rw[1]*100); (* 收料PID *)
		pstStRecord_T^.aiKpid_UwRw_IfOf[2,2]:= LREAL_TO_WORD(i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].arKpid_Current_Rw[2]*100);
		pstStRecord_T^.aiKpid_UwRw_IfOf[2,3]:= LREAL_TO_WORD(i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].arKpid_Current_Rw[3]*100);
	(*
		pstStRecord_T^.aiKpid_UwRw_IfOf[3,1]:= LREAL_TO_WORD(i_pstStGrpParam^.alrKpid_If[1]*100); (* 放牵PID *)
		pstStRecord_T^.aiKpid_UwRw_IfOf[3,2]:= LREAL_TO_WORD(i_pstStGrpParam^.alrKpid_If[2]*100);
		pstStRecord_T^.aiKpid_UwRw_IfOf[3,3]:= LREAL_TO_WORD(i_pstStGrpParam^.alrKpid_If[3]*100);
*)

		pstStRecord_T^.aiKpid_UwRw_IfOf[3,1]:= LREAL_TO_WORD( i_lrKp_If*100 ); 
		//LREAL_TO_WORD(PLC_PRG.afbKS_FB_GrpCentralizedProc[i_iGrpId].fbKS_FB_GrpFlowControl.fbKS_IfOf_CTL.lrKp_If*100); (* 放牵PID *)
		pstStRecord_T^.aiKpid_UwRw_IfOf[3,2]:=  LREAL_TO_WORD(  i_lrKi_If *100 );
		//LREAL_TO_WORD(PLC_PRG.afbKS_FB_GrpCentralizedProc[i_iGrpId].fbKS_FB_GrpFlowControl.fbKS_IfOf_CTL.lrKi_If*100);
		pstStRecord_T^.aiKpid_UwRw_IfOf[3,3]:=  LREAL_TO_WORD( i_lrKd_If * 100) ;
	//	LREAL_TO_WORD(PLC_PRG.afbKS_FB_GrpCentralizedProc[i_iGrpId].fbKS_FB_GrpFlowControl.fbKS_IfOf_CTL.lrKd_If*100);


		pstStRecord_T^.aiKpid_UwRw_IfOf[4,1]:=  LREAL_TO_WORD( i_lrKp_Of*100 ); 
	//	LREAL_TO_WORD(PLC_PRG.afbKS_FB_GrpCentralizedProc[i_iGrpId].fbKS_FB_GrpFlowControl.fbKS_IfOf_CTL.lrKp_Of*100); (* 收牵PID *)
		pstStRecord_T^.aiKpid_UwRw_IfOf[4,2]:=  LREAL_TO_WORD( i_lrKi_Of*100 ); 
		//LREAL_TO_WORD(PLC_PRG.afbKS_FB_GrpCentralizedProc[i_iGrpId].fbKS_FB_GrpFlowControl.fbKS_IfOf_CTL.lrKi_Of*100);
		pstStRecord_T^.aiKpid_UwRw_IfOf[4,3]:=  LREAL_TO_WORD( i_lrKd_Of*100 ); 
		//LREAL_TO_WORD(PLC_PRG.afbKS_FB_GrpCentralizedProc[i_iGrpId].fbKS_FB_GrpFlowControl.fbKS_IfOf_CTL.lrKd_Of*100);
		//2026.1.16.140655 || zhang.hz || 保存秦华目标压力和当前压力值 
		pstStRecord_T^.rPressure_Tar:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rPressure_Tar;//i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rR_K_LQR_Uw; (* 目标压力 *)
		pstStRecord_T^.rCurPressureValue:= g_lrCur_PressureValue;(*g_lrCurPressureValue*); (* 当前压力|找不到|竟然是在每个色组内的|@2019.11.29.180506 *)

		pstStRecord_T^.wAOVolt_If_inverter:= i_wAO_If_I;//i_pstStIOMap_IfOf^.o_wAO_If_I; (* 放牵变频输出 *)
		pstStRecord_T^.wAOVolt_Of_inverter:= i_wAO_Of_I;//i_pstStIOMap_IfOf^.o_wAO_Of_I; (* 收牵变频输出 *)

		pstStRecord_T^.rStdVol_AI_cur:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rAI_DiamMeasure_Uw; (* 当前卷径电压值 *)
		pstStRecord_T^.rStdVol_AI_use:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rVolt_CalcDiam_Used_Watch; (* 计算卷径使用电压|@2019.11.27.094153 *)
		pstStRecord_T^.rDia_New_Auto:= LREAL_TO_REAL(i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rDiam_NewVol_Uw); (* 放料新卷卷径|@2019.11.27.092933 *)
		pstStRecord_T^.rUwPreVel_Vol_A:= LREAL_TO_REAL(i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rAO_Inverter_Uw_AxisA); (* 放料A电压 *)
		pstStRecord_T^.rUwPreVel_Vol_B:= LREAL_TO_REAL(i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rAO_Inverter_Uw_AxisB); (* 放料B电压 *)
		pstStRecord_T^.rRwPreVel_Vol_A:= LREAL_TO_REAL(i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rAO_Inverter_Rw_AxisA); (* 收料A电压 *)
		pstStRecord_T^.rRwPreVel_Vol_B:= LREAL_TO_REAL(i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rAO_Inverter_Rw_AxisB); (* 收料B电压 *)
		pstStRecord_T^.rUwPreVel:=i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rVel_PreDrv_Uw; (* 放料预驱速度 *)
		pstStRecord_T^.rRwPreVel:=i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rVel_PreDrv_Rw; (* 收料预驱速度 *)
		pstStRecord_T^.iMotionStepId:= g_iRtn_MulFunCtl;//i_iMotionStepId;//i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].iMotionStepId; (* 电机运行步骤 *)
		pstStRecord_T^.iPromptMsgId:= i_iPromptMsgId; (* 报警代码 *)
		//2026.08.21.131610 增加变频器报警保存_Start
		//pstStRecord_T^.wPreHotRollerFrq:= i_wPreHotRollerFrq; (* 预热辊输入 *)
		IF NOT SID1_MID4_IW.0 THEN
			iTemp_UwInveterAlarm:=1;
		ELSE
			iTemp_UwInveterAlarm:=0;
		END_IF
		
		IF NOT SID0_MID0_IW_1.1 THEN
			iTemp_RwInveterAlarm:=2;
		ELSE
			iTemp_RwInveterAlarm:=0;
		END_IF
		pstStRecord_T^.wPreHotRollerFrq:=INT_TO_WORD(iTemp_UwInveterAlarm+iTemp_RwInveterAlarm);
		//2026.08.21.131610 增加变频器报警保存_End
		pstStRecord_T^.wWaterCoolRollerFrq:= i_wWaterCoolRollerFrq; (* 水冷辊输入 *)
		pstStRecord_T^.byPlcLoad:= g_abyCpu_Load[2];//DWORD_TO_BYTE(g_dwPlcLoad); (* 2020.4.14.153245 *)
(*2021.9.2.151147 自调数据屏蔽|*)(*
		(* 2020.10.8.165258|保存的两项新增 *)
		pstStRecord_T^.rVel_SelfAdjust_Uw_A:= g_astStExtroIO_Uw[1].i_rAxisAVel_AI;
		pstStRecord_T^.rVel_SelfAdjust_Uw_B:= g_astStExtroIO_Uw[1].i_rAxisBVel_AI;
*)
		(*临时先直接使用地址@如果报错就先屏蔽吧！*)
		pstStRecord_T^.awPressRollerVol[1]:=0;
		pstStRecord_T^.awPressRollerVol[2]:=0;
		pstStRecord_T^.awPressRollerVol[3]:=0;
		pstStRecord_T^.awPressRollerVol[4]:=0;

		pstStRecord_T^.rTowerThetaCur_Uw:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rTowerThetaCur_Uw;
		pstStRecord_T^.rDeltaW_RPMIN_Uw:=i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rDeltaW_RPMIN_Uw;
		(*2022.5.17.134910*)
		pstStRecord_T^.rFilmToTowerRollerDis:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rFilmToTowerRollerDis_Uw;(*料膜距离导向辊距离|mm*)

		(*卷径估计需要保存变量|2021.8.27.093826*)
		pstStRecord_T^.rEstiDia_Uw:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rEstiDia_Uw;
		pstStRecord_T^.rEstiThickNess_Uw:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rEstiThickNess_Uw;
		pstStRecord_T^.rMainVel_Uw:= i_rMainVel_Uw ; 
		 // PLC_PRG.afbKS_FB_GrpCentralizedProc[i_iGrpId].fbKS_FB_GrpFlowControl.fbKS_UwRw_CTL.rMainVel_Uw;

		pstStRecord_T^.rEstiDia_Rw:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rEstiDia_Rw;
		pstStRecord_T^.rEstiThickNess_Rw:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rEstiThickNess_Rw;
		pstStRecord_T^.rMainVel_Rw:=  i_rMainVel_Rw ; 
		//PLC_PRG.afbKS_FB_GrpCentralizedProc[i_iGrpId].fbKS_FB_GrpFlowControl.fbKS_UwRw_CTL.rMainVel_Rw;

		(*2021.9.13.111059 增加了放料接料窄方波+微分补偿*)
		(*复用了*)
		pstStRecord_T^.rUseDiamWuCompensate_Uw:= i_rDiamWuCompensate_Uw ; 
			//PLC_PRG.afbKS_FB_GrpCentralizedProc[i_iGrpId].fbKS_FB_GrpFlowControl.fbKS_UwRw_CTL.fbKS_FB_Tension_2024_Uw.rDiamWuCompensate;
		pstStRecord_T^.rUseDiamWuCompensate_Rw:= i_rDiamWuCompensate_Rw;
		 //	PLC_PRG.afbKS_FB_GrpCentralizedProc[i_iGrpId].fbKS_FB_GrpFlowControl.fbKS_UwRw_CTL.fbKS_FB_Tension_2024_Rw.rDiamWuCompensate;

		(*2022.9.7.215826|单位0.01*)
		pstStRecord_T^.uiTaper_Cur_Uw:=REAL_TO_UINT(i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rTaper_Rw*100);(*放料当前锥度*)
		pstStRecord_T^.uiTaper_Cur_Rw:=REAL_TO_UINT(i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rTaper_Rw*100);(*收料当前锥度*)
		pstStRecord_T^.uiTaper_Cur_If:=LREAL_TO_UINT(i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rTaper_Cur_If*100);(*放牵当前锥度*)
		pstStRecord_T^.uiTaper_Cur_Of:=LREAL_TO_UINT(i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rTaper_Cur_Of*100);(*收牵当前锥度*)

		pstStRecord_T^.iPidAlgorithm_Threshold		:= i_pstStSysParam^.stStSysParam_Save.iPidAlgorithm_Threshold ;(*	:INT;(*温控PDI介入阀值*)	*)
		pstStRecord_T^.iMaxOutValue				:= i_pstStSysParam^.stStSysParam_Save.iMaxOutValue ;(*	:INT;(*温控最大调整量*)		*)
		pstStRecord_T^.rKp							:= i_pstStSysParam^.stStSysParam_Save.rKp ;(*	:REAL;						*)
		pstStRecord_T^.rKi							:= i_pstStSysParam^.stStSysParam_Save.rKi ;(*	:REAL;						*)
		pstStRecord_T^.rKd							:= i_pstStSysParam^.stStSysParam_Save.rKd ;(*	:REAL;						*)
		pstStRecord_T^.uiCtlCycle_Ms				:= i_pstStSysParam^.stStSysParam_Save.uiCtrolCycle_Ms ;(*	:UINT;(*调整周期*)			*)


		(*2022.11.2.104815增加伪随机的保存*)
		pstStRecord_T^.byRoundTime:=   i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].byPseudoRandomRoundTimes_Cur;
		pstStRecord_T^.rVolAdditionValue:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rPseudoRandomRoundAmplitude_Cur;
		pstStRecord_T^.rAmplitude:=i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].byPseudoRandomId;(*替换为了当前的伪随机@2024.05.24.133327*)

		(*2023.09.08.155847*)
		pstStRecord_T^.rWuCompensate_Uw:=i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rWuCompensate_Uw;
		
		pstStRecord_T^.rDh_Uw:= 0 ; 
		//i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rDh_Uw;
		pstStRecord_T^.rWuCompensate_Act_Uw:=i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rWuCompensate_Act_Uw;
		pstStRecord_T^.rEstiDia_LowPass_Uw:= i_rEstiDia_LowPass_Uw ; 
		 //	PLC_PRG.afbKS_FB_GrpCentralizedProc[i_iGrpId].fbKS_FB_GrpFlowControl.fbKS_UwRw_CTL.rEstiDia_LowPass_Uw;
		pstStRecord_T^.rWc_LowPass_Diam_Uw:=i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rWc_LowPass_Diam_Uw;
(*			PLC_PRG.afbKS_FB_GrpCentralizedProc[i_iGrpId].fbKS_FB_GrpFlowControl.fbKS_UwRw_CTL.rWc_LowPass_Uw;(*2023.09.27.233145 低通滤波截止频率*)*)

		(*2024.01.11.154023同步增加*)
		pstStRecord_T^.byKalmanFilterType_Uw:=i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].byKalmanFilterType_Uw;
		pstStRecord_T^.rKc_Uw:=(*i_pstStGrpParam^.rKc_Uw;*) i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rKc_Uw	 ; 
				//PLC_PRG.afbKS_FB_GrpCentralizedProc[i_iGrpId].fbKS_FB_GrpFlowControl.fbKS_UwRw_CTL.fbKS_FB_Tension_2024_Uw.rKc;(*2024.05.13.182421 实际使用的kc*)
(*		pstStRecord_T^.rKc_1_Uw:=i_pstStGrpParam^.rKc_1_Uw;*)

		(*收料rWuCompensate_Rw*)
		pstStRecord_T^.byKalmanFilterType_Rw:=i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].byKalmanFilterType_Rw;
		pstStRecord_T^.rWc_LowPass_Diam_Rw:=i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rWc_LowPass_Diam_Rw;
		pstStRecord_T^.rWuCompensate_Rw:=i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rWuCompensate_Rw;
		pstStRecord_T^.rWuCompensate_Act_Rw:=i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rWuCompensate_Act_Rw;
		pstStRecord_T^.rKc_Rw:=i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rKc_Rw	;
			//PLC_PRG.afbKS_FB_GrpCentralizedProc[i_iGrpId].fbKS_FB_GrpFlowControl.fbKS_UwRw_CTL.fbKS_FB_Tension_2024_Rw.rKc;(*2024.05.13.182421 实际使用的kc*)
		pstStRecord_T^.rEstiDia_LowPass_Rw:=i_rEstiDia_LowPass_Rw;
			//PLC_PRG.afbKS_FB_GrpCentralizedProc[i_iGrpId].fbKS_FB_GrpFlowControl.fbKS_UwRw_CTL.rEstiDia_LowPass_Rw;
		(*2024.9.10.122523 经过陷波后的值*)
		pstStRecord_T^.rAntiNotch_Out_If:= i_rAntiNotch_Out_If ;
			//PLC_PRG.afbKS_FB_GrpCentralizedProc[i_iGrpId].fbKS_FB_GrpFlowControl.fbKS_IfOf_CTL.rAntiNotch_Out_If;
		pstStRecord_T^.rAntiNotch_Out_Uw:= i_rAntiNotch_Out_Uw ;
			//PLC_PRG.afbKS_FB_GrpCentralizedProc[i_iGrpId].fbKS_FB_GrpFlowControl.fbKS_UwRw_CTL.rAntiNotch_Out_Uw;


		pstStRecord_T^.byCycleTime_PlcPrg:= 0 ;
				//TIME_TO_BYTE(g_astStTaskCycleDetection[1].tmElapsed);(* 任务消耗时间 *)
		pstStRecord_T^.byIntervalTime_PlcPrg:= 0 ;
				//TIME_TO_BYTE(g_astStTaskCycleDetection[1].tmInterval);(* 任务间隔 *)
				
(*		pstStRecord_T^.bya_Youla_Uw:=REAL_TO_BYTE(i_pstStGrpParam^.ra_Youla_Uw*10);(* YOULA控制器的系统参数a|放大10倍|解析的时候记得除以10*)*)



		(*2023.6.19.162512*)
		pstStRecord_T^.xSaveFineSampleData:=i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_FilmAccDecDone;//g_xSaveFineSampleData;

		pstStRecord_T^.byTotalVariableAxisNum_Gear:= 0; (* 默认没有附加轴描述 *)
		pstStRecord_T^.dwMask_VariableAxisDetails1_Gear:= 0; (* 掩码清除 *)
		pstStRecord_T^.dwMask_VariableAxisDetails2_Gear:= 0; (* 掩码清除 *)
		
		pstStRecord_T^.byTotalVariableAxisNum_GantryTrap:= 0; (* 默认没有附加轴描述 *)
		pstStRecord_T^.dwMask_VariableAxisDetails1_GantryTrap:= 0; (* 掩码清除 *)
		pstStRecord_T^.dwMask_VariableAxisDetails2_GantryTrap:= 0; (* 掩码清除 *)
		
		pstStRecord_T^.byTotalVariableAxisNum_Trap:= 0; (* 默认没有附加轴描述 *)
		pstStRecord_T^.dwMask_VariableAxisDetails1_Trap:= 0; (* 掩码清除 *)
		pstStRecord_T^.dwMask_VariableAxisDetails2_Trap:= 0; (* 掩码清除 *)
		
		//添加存储数据
		dwsizeofTension:= SIZEOF(pstStRecord_T^);

		pstStTravelDataItem^.uiValidBytesNum:= pstStTravelDataItem^.uiValidBytesNum+SIZEOF(pstStRecord_T^);(* 主数据结构长度也包含在内 *)
		iPackageTotalBytes:= iPackageTotalBytes+UINT_TO_INT(SIZEOF(pstStRecord_T^)); (* 数据包长度增加了个结构体StRecord_T *)

		(* 接下来/如果有附加的轴信息也追加进来 *)
		dwExtendedAddr:= ADR(pstStTravelDataItem^.abyPayload)+SIZEOF(puiPreambleMark^)+SIZEOF(piLength_Payload^)+SIZEOF(pstStRecord_T^);
		
		//开始增加轴参数
		iAxisNum_Appended:= 0; (* 目前追加的轴数量 *)
		iAxisNum_TotalNum := UINT_TO_INT(SIZEOF(pstStAxis_Sts_Gear^));
		iAxisNum_TotalNum:= (*iBufLen_VariableSpace*)iBytesRemainExt/UINT_TO_INT(SIZEOF(pstStAxis_Sts_Gear^)); (* 可以追加的最大轴数量 *)

		FOR iN:=1 TO i_iGrpGearMotion_Num BY 1 DO
			pstStAxis_Sts_Gear := dwExtendedAddr;
			IF pstStAxis_Sts_Gear <> 0 THEN
				pstStRecord_T^.byTotalVariableAxisNum_Gear:= pstStRecord_T^.byTotalVariableAxisNum_Gear+1;
				IF iN<=32 THEN
					pstStRecord_T^.dwMask_VariableAxisDetails1_Gear:= pstStRecord_T^.dwMask_VariableAxisDetails1_Gear OR SHL(DWORD#1,iN-1); (* 写掩码位 *)				
				ELSIF iN<=64 THEN
					pstStRecord_T^.dwMask_VariableAxisDetails2_Gear:= pstStRecord_T^.dwMask_VariableAxisDetails2_Gear OR SHL(DWORD#1,(iN-32)-1); (* 写掩码位 *)										
				END_IF
				
				SysMemCpy(pstStAxis_Sts_Gear,ADR(i_pastStAxis_Sts_Gear^[iN]),SIZEOF(pstStAxis_Sts_Gear^));
				
				iPackageTotalBytes:= iPackageTotalBytes+DWORD_TO_INT(SIZEOF(pstStAxis_Sts_Gear^)); (* 更新报文字节计数 *)
				pstStTravelDataItem^.uiValidBytesNum:= pstStTravelDataItem^.uiValidBytesNum+DWORD_TO_UINT(SIZEOF(pstStAxis_Sts_Gear^)); (* 更新报文总字节计数 *)
			ELSE
				;	
			END_IF	

			dwExtendedAddr:= dwExtendedAddr+SIZEOF(pstStAxis_Sts_Gear^); (* 下次的添加位置 *)
			iAxisNum_Appended:= iAxisNum_Appended+1; (* 已经补充的轴细节参数计数 *)
			IF iAxisNum_Appended>=iAxisNum_TotalNum THEN
				EXIT;
			END_IF
		END_FOR
		
		//开始增加轴参数
		iAxisNum_Appended:= 0; (* 目前追加的轴数量 *)
		iAxisNum_TotalNum := UINT_TO_INT(SIZEOF(pstStAxis_Sts_GantryTrap^));
		iAxisNum_TotalNum:= (*iBufLen_VariableSpace*)iBytesRemainExt/UINT_TO_INT(SIZEOF(pstStAxis_Sts_GantryTrap^)); (* 可以追加的最大轴数量 *)

		FOR iN:=1 TO i_iGrpGantryTrapMotion_Num BY 1 DO
			pstStAxis_Sts_GantryTrap := dwExtendedAddr;
			IF pstStAxis_Sts_GantryTrap <> 0 THEN
				pstStRecord_T^.byTotalVariableAxisNum_GantryTrap:= pstStRecord_T^.byTotalVariableAxisNum_GantryTrap+1;
				IF iN<=32 THEN
					pstStRecord_T^.dwMask_VariableAxisDetails1_GantryTrap:= pstStRecord_T^.dwMask_VariableAxisDetails1_GantryTrap OR SHL(DWORD#1,iN-1); (* 写掩码位 *)				
				ELSIF iN<=64 THEN
					pstStRecord_T^.dwMask_VariableAxisDetails2_GantryTrap:= pstStRecord_T^.dwMask_VariableAxisDetails2_GantryTrap OR SHL(DWORD#1,(iN-32)-1); (* 写掩码位 *)									
				END_IF
				
				SysMemCpy(pstStAxis_Sts_GantryTrap,ADR(i_pastStAxis_Sts_GantryTrap^[iN]),SIZEOF(pstStAxis_Sts_GantryTrap^));
				
				iPackageTotalBytes:= iPackageTotalBytes+DWORD_TO_INT(SIZEOF(pstStAxis_Sts_GantryTrap^)); (* 更新报文字节计数 *)
				pstStTravelDataItem^.uiValidBytesNum:= pstStTravelDataItem^.uiValidBytesNum+DWORD_TO_UINT(SIZEOF(pstStAxis_Sts_GantryTrap^)); (* 更新报文总字节计数 *)
			ELSE
				;	
			END_IF	

			dwExtendedAddr:= dwExtendedAddr+SIZEOF(pstStAxis_Sts_GantryTrap^); (* 下次的添加位置 *)
			iAxisNum_Appended:= iAxisNum_Appended+1; (* 已经补充的轴细节参数计数 *)
			IF iAxisNum_Appended>=iAxisNum_TotalNum THEN
				EXIT;
			END_IF
		END_FOR
		
		//开始增加轴参数
		iAxisNum_Appended:= 0; (* 目前追加的轴数量 *)
		iAxisNum_TotalNum := UINT_TO_INT(SIZEOF(pstStAxis_Sts_Trap^));
		iAxisNum_TotalNum:= (*iBufLen_VariableSpace*)iBytesRemainExt/UINT_TO_INT(SIZEOF(pstStAxis_Sts_Trap^)); (* 可以追加的最大轴数量 *)

		FOR iN:=1 TO i_iGrpTrapMotion_Num BY 1 DO
			pstStAxis_Sts_Trap := dwExtendedAddr;
			IF pstStAxis_Sts_Trap <> 0 THEN
				pstStRecord_T^.byTotalVariableAxisNum_Trap:= pstStRecord_T^.byTotalVariableAxisNum_Trap+1;
				IF iN<=32 THEN
					pstStRecord_T^.dwMask_VariableAxisDetails1_Trap:= pstStRecord_T^.dwMask_VariableAxisDetails1_Trap OR SHL(DWORD#1,iN-1); (* 写掩码位 *)				
				ELSIF iN<=64 THEN
					pstStRecord_T^.dwMask_VariableAxisDetails2_Trap:= pstStRecord_T^.dwMask_VariableAxisDetails2_Trap OR SHL(DWORD#1,(iN-32)-1); (* 写掩码位 *)									
				END_IF
				
				SysMemCpy(pstStAxis_Sts_Trap,ADR(i_pastStAxis_Sts_Trap^[iN]),SIZEOF(pstStAxis_Sts_Trap^));
				
				iPackageTotalBytes:= iPackageTotalBytes+DWORD_TO_INT(SIZEOF(pstStAxis_Sts_Trap^)); (* 更新报文字节计数 *)
				pstStTravelDataItem^.uiValidBytesNum:= pstStTravelDataItem^.uiValidBytesNum+DWORD_TO_UINT(SIZEOF(pstStAxis_Sts_Trap^)); (* 更新报文总字节计数 *)
			ELSE
				;	
			END_IF	

			dwExtendedAddr:= dwExtendedAddr+SIZEOF(pstStAxis_Sts_Trap^); (* 下次的添加位置 *)
			iAxisNum_Appended:= iAxisNum_Appended+1; (* 已经补充的轴细节参数计数 *)
			IF iAxisNum_Appended>=iAxisNum_TotalNum THEN
				EXIT;
			END_IF
		END_FOR
		
		
		(* 结束符 *)
		pbyEndMark:= dwExtendedAddr;
		pbyEndMark^:= ENDMARK;
		pstStTravelDataItem^.uiValidBytesNum:= pstStTravelDataItem^.uiValidBytesNum+SIZEOF(pbyEndMark^);(* 数据包(含协议字)的总长度 *)
		
	
		(* 更新数据报的长度描述 *)
		piLength_Payload:= dwPayloadFrom+SIZEOF(puiPreambleMark^);
		piLength_Payload^:= iPackageTotalBytes;

		(* -------------------------------------------------- *)
		(* 处理下次写入的位置 *)
		(* -------------------------------------------------- *)
		uiWR_tmp:= i_pstStTravelDataRec^.uiWR+1;
		IF uiWR_tmp>uiTmpItemMaxNum THEN uiWR_tmp:= uiWR_tmp-uiTmpItemMaxNum; END_IF
		i_pstStTravelDataRec^.uiWR:= uiWR_tmp;

	ELSE o_iErNo:= -1; END_IF(* 传入参数有非法输入 *)
END_IF