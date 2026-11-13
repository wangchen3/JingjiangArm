(*@CES
Name=PRG_COMM
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=489c5597-ab28-4682-ade4-96da00764186
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
PROGRAM PRG_COMM
VAR
	iN:INT;(*循环变量*)
	iStationId:INT;(*通信站号*)
	stStProtocol_PDU_Up_Rd:StParam_Pdu_Up;//当前收到的实时数据PDU
	pstStCMD_F05_: POINTER TO StPdu_Up_05;
	pbyTemp:POINTER TO BYTE := 0;
	dwCheckSumVal:DWORD;
	wCHK_Up_Calc:WORD;
	diTempVal:DINT;
	tmCURR: TIME;
	tmPduSnt_LastTime: TIME; (* pdu发送的最后时间 *)
	xFlag_CmdQueueInitialized: BOOL := FALSE; (* 命令轮询初始化标志 *)
	pstStUnitCmdQueue_Tmp: POINTER TO StUnitCmdQueue; (* 命令轮询体 *)
	astStUnitCmdQueue: ARRAY [1..MAX_UNIT_NUM] OF StUnitCmdQueue := [MAX_UNIT_NUM((byCmdNum:= 0, byCmdIdx:= 1))]; (* 命令轮询结构 *)
	byIDX_Tmp: BYTE;
	byMAX_Tmp: BYTE;
	iRtn: INT;
//	iUnitNR: INT;
	abyBuf_PduCmd_snd: ARRAY [1..MAX_PDU_CMD_BYTES_DN] OF BYTE; (* 2021.12.4.154353/hdp/写入 *)
	dwDO_Tmp: DWORD; (* 数字量输出临时变量 *)	
	dwOFST: DWORD;
	dwOFST2: DWORD;
	pstStUnitParam_Save: POINTER TO StUnitParam_Save;	
	pstStUnitParam_UnSave: POINTER TO StUnitParam_UnSave;	
	
	pastStParam_Mailbox: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF StParam_Mailbox := 0;
	pstStParam_Mailbox_Tmp: POINTER TO StParam_Mailbox; (* 用以套用Mailbox通讯协议/2021.12.4.135959/hdp *)
	abyBuf_MailboxPkg_rcv: ARRAY [1..MAILBOX_PKG_MAX_BYTES] OF BYTE; (* Mailbox通讯的接收内存空间 *)
	axNeedUpdateParam_Malilbox: ARRAY [1..MAX_UNIT_NUM] OF BOOL:= [MAX_UNIT_NUM(0)];
	stStParam_Mailbox_Tmp: StParam_Mailbox;
	astStParam_Mailbox_snd: ARRAY [1..MAX_UNIT_NUM] OF StParam_Mailbox;
	astStParam_Mailbox_out: ARRAY [1..MAX_UNIT_NUM] OF StParam_Mailbox;
	abyBuf_MailboxPkg_snd: ARRAY [1..MAILBOX_PKG_MAX_BYTES] OF BYTE; (* Mailbox通讯的发送内存空间 *)
	pstStParam_Mailbox: POINTER TO StParam_Mailbox;	
	pastStParam_Mailbox_proof: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF StParam_Mailbox := 0;
	pdwSEMA: POINTER TO DWORD := 0;	
	atmUnitMailboxLastSynchronized: ARRAY [1..MAX_UNIT_NUM] OF TIME := [MAX_UNIT_NUM(T#0MS)];
	diTMP: DINT;	
	iUnitId_Tmp: INT;(* 色组id *)
	diValue_Tmp: DINT;(* 提交的数据 *)	
	pastStProtocol_Mailbox_proof: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF StParam_Mailbox := 0;
	i_xRunlogEnable: BOOL := FALSE;(* 2021.12.29.200725/hdp/增加的运行日志使能标志/不影响单次gt指令调用失败的打印信息 *)
//	i_pstStTravelLogRec: POINTER TO StTravelLogRec := 0; (* 日志入口 *)
	xSynchronized_SpecialParam: BOOL;	
	udiresult : UDINT;
	iUnitId: INT;
	iGrpId: INT;
	iAxisTypeId: INT;
	axFlag_Comm_ReadEn: ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	xInit_Comm_HMI: BOOL;
	abyBuf_UDP_Unit_rec: ARRAY [1..MAX_UNIT_NUM,1..MAILBOX_PKG_MAX_BYTES] OF BYTE; 
	abyBuf_UDP_Unit_snd: ARRAY [1..MAX_UNIT_NUM,1..MAILBOX_PKG_MAX_BYTES] OF BYTE;
	abyBuf_UDP_Unit_rcv: ARRAY [1..MAX_UNIT_NUM,1..MAILBOX_PKG_MAX_BYTES] OF BYTE; 
	abyBuf_UDP_Unit_rcv_Use_Tmp: ARRAY [1..MAILBOX_PKG_MAX_BYTES] OF BYTE; 
	
	axFlag_DataCmd: ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	abyRdDataNum: ARRAY [1..MAX_UNIT_NUM] OF BYTE;
	astStParam_UnitHMI485_Wr_81: ARRAY [1..MAX_UNIT_NUM] OF StParam_UnitHMI485_Wr_81;
	astStParam_UnitHMI485_Wr_82: ARRAY [1..MAX_UNIT_NUM] OF StParam_UnitHMI485_Wr_82;
	astStParam_UnitHMI485_Wr_83: ARRAY [1..MAX_UNIT_NUM] OF StParam_UnitHMI485_Wr_83;
	
	astStParam_UnitHMI485_WrRd: ARRAY [1..MAX_UNIT_NUM] OF StParam_UnitHMI485_WrRd;
	astStParam_UnitHMI485_WrRd_Rec: ARRAY [1..MAX_UNIT_NUM] OF StParam_UnitHMI485_WrRd;
	astStParam_UnitHMI485_Rd: ARRAY [1..MAX_UNIT_NUM] OF StParam_UnitHMI485_Rd;
	axFlag_Rd_OR_WrRd: ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	aiStep_Comm: ARRAY [1..MAX_UNIT_NUM] OF INT;
	diTemp: DINT;
	xInit:BOOL:=FALSE;
	dwTest:DWORD;
	iRtn1: INT;
	iRtn2: INT;
	iCnt_Comm_To_gLink_II: INT;
	iCnt_Comm_To_UdpHmi: INT;
	iUnitId_To_Hmi: INT;
	xPreAcc_Ratio: BOOL;
	xPreDec_Ratio: BOOL;
	(*读取粗采样数据2025.8.14.094918*)
	iUMax_Tmp: INT;
	iUid_Tmp: INT;
	iLastId: INT;
	xReDirectedCurrUnit: BOOL;
	aiRtnCode: ARRAY [1..20] OF INT;
	iRoundSampleFlag: INT;	
	pDataTest:POINTER TO BYTE;
	iM: INT;
	iGrp: INT;
	aiMarkTypeId: ARRAY [1..2] OF INT := [2(-1)]; (* A/B系标记排列选择 *)
	aiMarkArrangeId: ARRAY [1..2] OF INT := [2(-1)]; (* A/B系标记排列 *)	
	lrTempVal: LREAL;
	pstStGrpParam_Save: POINTER TO StGrpParam_Save;
	pstStGrpParam_UnSave: POINTER TO StGrpParam_UnSave;
	wAxis_RollerDn				:WORD  ;(*轴压辊状态(bit0-1U,bit15-16U)*)
	wAxis_Alarm_Prn				:WORD  ;(*色组版辊报警状态(bit0-1U,bit15-16U)*)
	dwAlarmCode					:DWORD ;(*轴报警码*)
	wComplexFlag_AxisInching	:WORD  ;(*所有轴的单运行状态*)
	wComplexFlag_Linkage		:WORD  ;(*所有轴的联动状态*)
	wComplexFlag_Estop			:DWORD ;(*所有轴的急停状态*)
	byGrpId: BYTE;
	axSynchronizedFlag			: ARRAY [1..MAX_UNIT_NUM] OF BOOL:= [MAX_UNIT_NUM(FALSE)];
	abyHorzManu_HMI_Pre			: ARRAY [1..MAX_UNIT_NUM] OF BYTE;
	adwCtlBits_UnitBaseCraft_Temp	: ARRAY [1..MAX_UNIT_NUM] OF DWORD;
	
	aiCntInch : ARRAY [1..MAX_UNIT_NUM] OF INT;
	
	(*月光宝盒、月光宝盒pr设置标志@2025.8.7.220536+*)
	axRemoteSetDne				: ARRAY [1..MAX_STATION_NUM] OF  BOOL;
	axRemotSetFailed			: ARRAY [1..MAX_STATION_NUM] OF BOOL;
	
	adwMotorEncoder : ARRAY [1..MAX_UNIT_NUM] OF DWORD := [MAX_UNIT_NUM(4194304)];
	
	auiAllowMotorRpm_Max : ARRAY [1..MAX_UNIT_NUM] OF UINT := [MAX_UNIT_NUM(5000)];

	
//2026.1.4.175023增加子影人机通讯内容2026.1.4.175033
	iGrpIdTmp: INT;	
	
	pdata1: POINTER TO BYTE;
	pdata2: POINTER TO BYTE;
	iK: INT;
	iLength: INT;
	xFlag_MasterChange: BOOL;
	aiCntPress : ARRAY [1..MAX_UNIT_NUM] OF INT;
	aiCntUnPress : ARRAY [1..MAX_UNIT_NUM] OF INT;
aiTime: ARRAY [1..max_unit_num] OF INT;
aiTime1: ARRAY [1..max_unit_num] OF INT;
	udiAddrRd:UDINT;
	
			//xi.hy
	pstStRSVUnitParam_UnSave:POINTER TO StRSV_UnitParam_UnSave;
	pstStRSVUnitParam_Save:POINTER TO StRSV_UnitParam_Save;
	xTest:BOOL;
	awState_FiberMove_bak:ARRAY [1..MAX_UNIT_NUM] OF WORD;
	fbKS_FB_ExportRSFifo2File: KS_FB_ExportRSFifo2File;(*2026.03.23.162629||wang.xy*)
	
	(*2026.5.7.183226lhy+*)
	dwNetTime_Act:ARRAY [1..MAX_STATION_NUM] OF DWORD;
	
	
	//2026.08.06.203155
	aiCntStop: ARRAY [1..MAX_UNIT_NUM] OF INT;
END_VAR

{IMPLEMENTATION}
IF g_iRunStepId=RUNSTEP_NormalWork AND g_dwTensionRunNum>=5 THEN
	;
ELSE
	RETURN;
END_IF
iCnt_Comm_To_gLink_II:= iCnt_Comm_To_gLink_II+1;
iCnt_Comm_To_UdpHmi:= iCnt_Comm_To_UdpHmi+1;
(*金刚通讯5ms执行周期*)
Action_Udp_Diamonds();

IF g_stStSysParam.stStSysParam_Save.dwEquipmentProf.3 THEN
(*凹印的套色用值就用版辊吧2025.9.12.163315*)

	FOR iN:= 1 TO MAX_UNIT_NUM BY 1 DO
		g_stStSysParam.astStUnitParam_Save[iN].rGirth_Sam := g_stStSysParam.astStUnitParam_Save[iN].rGirth_PrnRoller;
		g_stStSysParam.astStUnitParam_Save[iN].uiNum_Sam := g_stStSysParam.astStUnitParam_Save[iN].uiNum_PrnRoller;
		g_stStSysParam.astStUnitParam_Save[iN].uiDen_Sam := g_stStSysParam.astStUnitParam_Save[iN].uiDen_PrnRoller;	
	END_FOR


	IF iCnt_Comm_To_gLink_II>= 3 THEN
		iCnt_Comm_To_gLink_II:= 0;
Action_gLink_II_Input();
		
		Action_GLINKII_COMM();
Action_gLink_II_Output();

		Action_RdSampleData();//S2025.08.23.200014+

	END_IF
	iCnt_Comm_To_UdpHmi:= 0;
ELSIF g_stStSysParam.stStSysParam_Save.dwEquipmentProf.2 OR g_stStSysParam.stStSysParam_Save.dwEquipmentProf.5 THEN
	
	//2025.12.24.162857 | + | bai.zy | 秦华的采样周长比较特殊
	IF g_stStSysParam.stStSysParam_Save.iCustomerId = CUSTOMERNAME_QINHUA THEN
		FOR iN:= 1 TO MAX_UNIT_NUM BY 1 DO
			g_stStSysParam.astStUnitParam_Save[iN].rGirth_Sam := g_stStSysParam.astStUnitParam_Save[iN].rGirth_PrnRoller;
			g_stStSysParam.astStUnitParam_Save[iN].uiNum_Sam := REAL_TO_UINT(UINT_TO_REAL(g_stStSysParam.astStUnitParam_Save[iN].uiNum_BottomRoller) * g_stStSysParam.astStUnitParam_Save[iN].rGirth_PrnRoller *1000/
								g_stStSysParam.astStGrpParam_Save[1].rGirth_BottomRoller);(* 减速比-电机端 *);//g_stStSysParam.astStUnitParam_Save[iN].uiNum_PrnRoller;
			g_stStSysParam.astStUnitParam_Save[iN].uiDen_Sam := 1000;//g_stStSysParam.astStUnitParam_Save[iN].uiDen_PrnRoller;	
		END_FOR
	ELSE
		//2025.12.01.164356 | + 
		FOR iN:= 1 TO MAX_UNIT_NUM BY 1 DO
			g_stStSysParam.astStUnitParam_Save[iN].rGirth_Sam := g_stStSysParam.astStUnitParam_Save[iN].rGirth_PrnRoller;
			g_stStSysParam.astStUnitParam_Save[iN].uiNum_Sam := g_stStSysParam.astStUnitParam_Save[iN].uiNum_PrnRoller;
			g_stStSysParam.astStUnitParam_Save[iN].uiDen_Sam := g_stStSysParam.astStUnitParam_Save[iN].uiDen_PrnRoller;	
		END_FOR
	END_IF
	
	IF iCnt_Comm_To_gLink_II>= 3 THEN
		iCnt_Comm_To_gLink_II:= 0;
Action_gLink_II_Input();
		
		Action_GLINKII_COMM();
Action_gLink_II_Output();

		Action_RdSampleData();//S2025.08.23.200014+

	END_IF
	
	IF iCnt_Comm_To_UdpHmi>= 2 THEN
		//Action_Udp_UnitHMI();
		iCnt_Comm_To_UdpHmi:= 0;
	END_IF
	//iCnt_Comm_To_gLink_II:= 0;
END_IF
Action_SyncParamToSample();


(*2026.5.14.091424屏蔽了
//2025.12.16.154650 | 异站编码器新增加的功能测试，目前先放在这里，暂时还没有库，等待中。。。。。。
FOR iN:=1 TO g_stStSysParam.stStSysParam_Save.iUnitMaxNum BY 1 DO
	pstStUnitParam_Save:=ADR(g_stStSysParam.astStUnitParam_Save[iN]);
	IF 	pstStUnitParam_Save^.iStationId<>-1 THEN(*存在控制站号*)
//2026.03.11.093012 | + | 同步获取编码器位数和最大转速的功能 下面的这一段改成自动的，不使用强制了，已经在秦华验证过
		IF NOT axRemoteSetDne[iN] THEN
			//2026.02.23.161037 | + | 通过flash获取编码器位数
			udiAddrRd:= 289;(* Nos *)
			iRtn :=GTN_RN_GetFlashParamInfo(
					cardIndex:= 1, 
					station_id:= pstStUnitParam_Save^.iStationId, 
					axis:= 1, 
					addr:= udiAddrRd, 
					pData:= ADR(adwMotorEncoder[iN]));
			(*目前只支持这两种编码器@2025.12.5.151451*)
			IF adwMotorEncoder[iN]<>4194304 AND
				adwMotorEncoder[iN]<>16777216 THEN
				adwMotorEncoder[iN]:=4194304;
			END_IF
			
			//2026.02.23.161037 | + | 通过flash获取最高转速
			udiAddrRd:= 80;(* Nos *)
			iRtn :=GTN_RN_GetFlashParamInfo(
					cardIndex:= 1, 
					station_id:= pstStUnitParam_Save^.iStationId, 
					axis:= 1, 
					addr:= udiAddrRd, 
					pData:= ADR(auiAllowMotorRpm_Max[iN]));
		END_IF
		KS_SetRemoteEncParam(FALSE,(*使用异站编码器@true 使用本地编码器*)
						g_abyStationList_CommKSCR[iN],//pstStUnitParam_Save^.iStationId,
						adwMotorEncoder[iN],
						auiAllowMotorRpm_Max[iN],//REAL_TO_UINT(pstStAxisParam^.rAllowMotorRpm_Max),
						DINT_TO_DWORD(gc_diVirEncPPR_New),(*有可能根据套色采样精度修改*)
						ADR(axRemoteSetDne[iN]),
						ADR(axRemotSetFailed[iN]));

	ELSE
		axRemoteSetDne[iN]:=FALSE;
		axRemotSetFailed[iN]:=FALSE;
	END_IF
END_FOR
*)