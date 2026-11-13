(*@CES
Name=KS_FB_TravelFileService
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=9263010e-7967-4803-a57a-bbeff11eb4c3
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_TravelFileService
(* 运行文件服务/包含日志和实时保存的数据 *)
VAR_INPUT
	i_xEn: BOOL;(* 总使能标志 *)
	i_xLog_need: BOOL;(* 置TRUE表示需要保存日志 *)
	i_xDat_need: BOOL;(* 置TRUE表示需要保存数据/可以绑定印刷条件等等 *)
	i_xReq_safeclose: BOOL;(* 请求安全关闭文件/关注本地驱动器的缺相和欠压报警标志 *)
	i_pxRst_protect: POINTER TO BOOL;(* 复位紧急保护的标志/由于在驱动器出现缺相或者欠压报警会触发紧急关闭文件/一旦出现报警/必须置复位标志才能继续保存新的文件 *)
(*deprecate@2025.8.27.164512/han.dp
	i_pstStTravelLogRec: POINTER TO StTravelLogRec;(* 完整日志区域/对应g_apstStTravelLogRec[1] *)
*)
	i_pstStTravelDataRec: POINTER TO StTravelDataRec;(* 后台记录的运行数据区域/对应g_pstStTravelDataRec *)
	i_pstStSysParam: POINTER TO StSysParam;
END_VAR
VAR_OUTPUT
	o_xEno: BOOL;
	o_sFilename_datfile: STRING;
	o_sFilename_logfile: STRING;
	o_iErNo_datfile: INT;
	o_iErNo_logfile: INT;
	o_xFileClosed_BecauseEmergency: BOOL := FALSE;
END_VAR
VAR
	sFilename: STRING;
	uiR_tmp: UINT;
	uiW_tmp: UINT;
	dwTmp: DWORD;
	dwBytesWrote_total: DWORD;
	dwHdl_logfile: DWORD := 0;(* 日志文件句柄 *)
	dwHdl_datfile: DWORD := 0;(* 数据文件句柄 *)
	xReqCloseLogfile_tmp: BOOL;
	xReqCloseDatfile_tmp: BOOL;
	iMaxDataItemsNum: INT;
	LINETAIL: BYTE := 13;(* 文本换行 *)
	pResult: RTS_IEC_RESULT;
	iRtn : INT;
	sFileName_test: STRING;
	time1:TIME;
	time2:TIME;
	adwNumByteOfFile : ARRAY[1..10] OF DWORD;
	sYMDHtemp:STRING;
	iN: INT;
	uiIdx_R_tmp:UINT;
	udiTmpOfst: UDINT;
	uiTmpRdNum: UINT;(* 2025.10.14.142248/han.dp/读取数量临时变量 *)

	pstStGrpParam_Save : POINTER TO StGrpParam_Save;
	
END_VAR
VAR CONSTANT
	DATFILE_MAXBYTES: DWORD := 16777216;(* 16*1024*1024字节/16MB *)
	//DATFILE_MAXBYTES: DWORD := 33554432;(* 32*1024*1024字节/16MB *)
END_VAR
{IMPLEMENTATION}
o_xEno:= i_xEn;
o_iErNo_datfile:= 0;
o_iErNo_logfile:= 0;
xReqCloseLogfile_tmp:= FALSE;
xReqCloseDatfile_tmp:= FALSE;
IF i_xEn THEN
	pstStGrpParam_Save := ADR(i_pstStSysParam^.astStGrpParam_Save[1]);
	(* 一旦紧急情况发生/开始触发文件安全关闭 *)
	IF i_xReq_safeclose AND (NOT o_xFileClosed_BecauseEmergency) THEN
		o_xFileClosed_BecauseEmergency:= TRUE;

	END_IF
	IF o_xFileClosed_BecauseEmergency THEN
		xReqCloseLogfile_tmp:= TRUE;
		xReqCloseDatfile_tmp:= TRUE;
	END_IF

	(* 可以人工启动文件保存功能 *)
	IF i_pxRst_protect<>0 THEN
		IF i_pxRst_protect^ AND (NOT i_xReq_safeclose) AND o_xFileClosed_BecauseEmergency THEN
			o_xFileClosed_BecauseEmergency:= FALSE;
		END_IF
		i_pxRst_protect^:= FALSE;(* 2023.7.26.175651/han.dp *)
	END_IF

	(* 所有的文件操作都需要在非紧急情况下进行/紧急情况一般为缺相或者欠压等供电异常状态/防止对DOM盘和OS文件造成破坏 *)
	IF NOT o_xFileClosed_BecauseEmergency THEN

(* deprecated@2025.8.27.161857/han.dp
		(* -------------------------------------------------- *)
		(* 处理日志 *)
		(* -------------------------------------------------- *)
		IF i_xLog_need THEN(* 需要保存日志 *)
			IF i_pstStTravelLogRec<>0 AND dwHdl_logfile<>0 THEN(* 写数据 *)
				uiR_tmp:= i_pstStTravelLogRec^.uiIndex_Rd;(* 读取位置 *)
				uiW_tmp:= i_pstStTravelLogRec^.uiIndex_Wr;(* 写入位置 *)
				iMaxDataItemsNum:= DWORD_TO_INT(SIZEOF(i_pstStTravelLogRec^.astStTravelLogItem)/SIZEOF(i_pstStTravelLogRec^.astStTravelLogItem[1]));(* 位置上限 *)
				IF (uiR_tmp>=1 AND uiR_tmp<=iMaxDataItemsNum) AND (uiW_tmp>=1 AND uiW_tmp<=iMaxDataItemsNum) THEN
					WHILE uiR_tmp<>uiW_tmp DO
						adwNumByteOfFile[1] := SysFileWrite(dwHdl_logfile,
							ADR(i_pstStTravelLogRec^.astStTravelLogItem[uiR_tmp].sInfo),
							LEN(i_pstStTravelLogRec^.astStTravelLogItem[uiR_tmp].sInfo), 0);
						adwNumByteOfFile[2] := SysFileWrite(dwHdl_logfile, ADR(LINETAIL), SIZEOF(LINETAIL), 0);

						uiR_tmp:= uiR_tmp+1;
						IF uiR_tmp>iMaxDataItemsNum THEN uiR_tmp:= uiR_tmp-iMaxDataItemsNum; END_IF

							uiIdx_R_tmp:= uiR_tmp;					
							FOR iN:=1 TO MIN(MAX_LOG_ITEM_VIEW,GC_LOG_ITEM_MAX_NUM) BY 1 DO
								uiIdx_R_tmp:= uiIdx_R_tmp-1;
								IF uiIdx_R_tmp<1 THEN
									uiIdx_R_tmp:= uiIdx_R_tmp+GC_LOG_ITEM_MAX_NUM;
									IF NOT gvl.g_pstStTravelLogRec^.xOverwrite THEN(* 未过圈/不要复制之前的 *)
										EXIT;
									END_IF
								END_IF
								gvl.g_astStTravelLogItem_view[iN]:= gvl.g_pstStTravelLogRec^.astStTravelLogItem[uiIdx_R_tmp];
							END_FOR							
						END_WHILE
					
					i_pstStTravelLogRec^.uiIndex_Rd:= uiR_tmp;
				ELSE
					i_pstStTravelLogRec^.uiIndex_Rd:= 1;
					i_pstStTravelLogRec^.uiIndex_Wr:= 1;
				END_IF
			ELSIF i_pstStTravelLogRec<>0 THEN(* 创建文件 *)
				sFilename:= PATH_HOME_LOG;
				sFilename:= CONCAT(sFilename, KS_GetTimeString(TIMEFORMAT_NO_HYPHEN,FALSE,FALSE,0,0));
				sFilename:= CONCAT(sFilename, '.txt');
				dwHdl_logfile:= SysFileOpen(sFilename, SysFile.AM_APPEND_PLUS, ADR(pResult));(* 以追加方式打开文件(未使用AM_WRITE模式)/失败了就会创建新的文件 *)
				IF dwHdl_logfile<>0 THEN o_sFilename_logfile:= sFilename; END_IF
			ELSE(* 关闭文件 *)
				o_iErNo_logfile:= -1;
				xReqCloseLogfile_tmp:= TRUE;
			END_IF
		ELSE xReqCloseLogfile_tmp:= TRUE; END_IF
*)

		(* -------------------------------------------------- *)
		(* 处理数据 *)
		(* -------------------------------------------------- *)
		IF i_xDat_need THEN(* 需要保存数据 *)
			IF i_pstStTravelDataRec<>0 AND dwHdl_datfile<>0 THEN(* 写数据 *)
				uiR_tmp:= i_pstStTravelDataRec^.uiRD;
				uiW_tmp:= i_pstStTravelDataRec^.uiWR;
				iMaxDataItemsNum:= DWORD_TO_INT(SIZEOF(i_pstStTravelDataRec^.astStTravelDataItem)/SIZEOF(i_pstStTravelDataRec^.astStTravelDataItem[1]));
				IF (uiR_tmp>=1 AND uiR_tmp<=iMaxDataItemsNum) AND (uiW_tmp>=1 AND uiW_tmp<=iMaxDataItemsNum) THEN
					WHILE uiR_tmp<>uiW_tmp DO


(* 2025.10.14.142930/han.dp/
/ 在写文件前把这个fifo给网络上也写一份
/ udp自动会搬到金刚主机
/ 原先的存储逻辑就会触发生效
/ 以FE_yyyymmdd.MIX文件呈现
*)
udiTmpOfst:= 0;
uiTmpRdNum:= i_pstStTravelDataRec^.astStTravelDataItem[uiR_tmp].uiValidBytesNum;
WHILE uiTmpRdNum>=1020 DO
	KS_PushDataToFifo(TRUE, 
		ADR(i_pstStTravelDataRec^.astStTravelDataItem[uiR_tmp].abyPayload)+udiTmpOfst,
		1020,
		g_pstStUdpOnlySendFifo);
	uiTmpRdNum:= uiTmpRdNum-1020;
	udiTmpOfst:= udiTmpOfst+1020;
END_WHILE
IF uiTmpRdNum<>0 THEN
	KS_PushDataToFifo(TRUE, 
		ADR(i_pstStTravelDataRec^.astStTravelDataItem[uiR_tmp].abyPayload)+udiTmpOfst,
		uiTmpRdNum,
		g_pstStUdpOnlySendFifo);
END_IF

						IF pstStGrpParam_Save^.dwExtBitCtlFlag.22 THEN
							dwTmp:= SysFileWrite(dwHdl_datfile,
								ADR(i_pstStTravelDataRec^.astStTravelDataItem[uiR_tmp].abyPayload),
								i_pstStTravelDataRec^.astStTravelDataItem[uiR_tmp].uiValidBytesNum, ADR(pResult));
						END_IF
						uiR_tmp:= uiR_tmp+1;
						IF uiR_tmp>iMaxDataItemsNum THEN uiR_tmp:= uiR_tmp-iMaxDataItemsNum; END_IF
						dwBytesWrote_total:= dwBytesWrote_total+dwTmp;
						IF dwBytesWrote_total>=DATFILE_MAXBYTES THEN(* 文件写够约定的大小就切换/请注意:要保证最后1包数据是完整的/并不是按照文件严格的定长来切换文件的 *)
							xReqCloseDatfile_tmp:= TRUE;
							EXIT;
						END_IF
					END_WHILE
					i_pstStTravelDataRec^.uiRD:= uiR_tmp;
				ELSE
					i_pstStTravelDataRec^.uiRD:= 1;
					i_pstStTravelDataRec^.uiWR:= 1;
				END_IF
			ELSIF i_pstStTravelDataRec<>0 THEN(* 创建文件 *)
				(*sYMDHtemp:=KS_GetTimeString(TIMEFORMAT_MMDDHH, FALSE, FALSE);
				PATH_HOME_DATA:=concat('/opt/codesyscontrol/kesai/data/',KS_GetTimeString(TIMEFORMAT_MMDDHH,TRUE,FALSE,0,0));
				PATH_HOME_DATA:=concat(PATH_HOME_DATA,'/');
				*)
				sFilename:= PATH_HOME_DATA;
				sFilename:= CONCAT(sFilename, KS_GetTimeString(TIMEFORMAT_NO_HYPHEN,TRUE,FALSE,0,0));(* 精确到s就可以 *)
				
				//使用新系统之后路径发生变化  /opt/codesyscontrol/---->/data/
				//sFilename:= MID(sFilename,41,1);
				sFilename:= MID(sFilename,27,1);
				sFilename:= CONCAT(sFilename,'/');
				sFilename:= CONCAT(sFilename, KS_GetTimeString(TIMEFORMAT_NO_HYPHEN,TRUE,FALSE,0,0));(* 精确到s就可以 *)
				
				sFilename:= CONCAT(sFilename, '.MIX');
				dwBytesWrote_total:= 0;(* 总计写入字节数量清零 *)
				dwHdl_datfile:= SysFileOpen(sFilename, SysFile.AM_WRITE, ADR(pResult));
				IF dwHdl_datfile<>0 THEN o_sFilename_datfile:= sFilename; END_IF
			ELSE(* 关闭文件 *)
				o_iErNo_datfile:= -1;
				xReqCloseDatfile_tmp:= TRUE;
			END_IF
		ELSE xReqCloseDatfile_tmp:= TRUE; END_IF
	END_IF
	
ELSE
	xReqCloseLogfile_tmp:= TRUE;
	xReqCloseDatfile_tmp:= TRUE;
END_IF

IF xReqCloseLogfile_tmp AND dwHdl_logfile<>0 THEN(* 关闭日志文件 *)
	SysFileClose(dwHdl_logfile);
	dwHdl_logfile:= 0;
	o_sFilename_logfile:= '';
END_IF

IF xReqCloseDatfile_tmp AND dwHdl_datfile<>0 THEN(* 关闭数据文件 *)
	SysFileClose(dwHdl_datfile);
	dwHdl_datfile:= 0;
	o_sFilename_datfile:= '';
END_IF