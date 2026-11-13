(*@CES
Name=KS_FB_GetRingNetStationDetails
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=bedd8a0d-8ba2-46a3-8720-0a4b68b69907
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_GetRingNetStationDetails
VAR_INPUT
	i_xEn: BOOL;
	i_pstStRingInf :POINTER TO StRingInfVer1;(*读取的站列表信息*)
	i_pastStWatch_Sts_display	: POINTER TO ARRAY [1..MAX_STATION_NUM] OF StParam_Diamonds_Wr_RunSts ;(* pt再封装区域 *)	
(*deprecated@2025.8.27.164020/han.dp
	i_pstStTravelLogRec			: POINTER TO StTravelLogRec := 0;(* 日志入口 *)
*)
	i_pstStHYLogFifo: POINTER TO StHYLogFifo;(* 日志FIFO *)
	i_pxRequstRdAgain			: POINTER TO BOOL := 0;(* 请求重新读取1次 *)	
END_VAR
VAR_OUTPUT
	o_xEno						: BOOL;(* =i_xEn *)
	o_iErNo						: INT;(* 错误代码 *)
	o_iCaseId					: INT;(* 当前的逻辑位置 *)	
	o_xDone						: BOOL := FALSE;(* 输出TRUE表示执行完成/处于维持状态 *)
	
END_VAR
VAR
	iRtn						: INT;
	iItemMax					: INT;
	iCursor						: INT := -1;
	iCaseId						: INT := CASE_GET_RINGNET_INF;
	iStationNr					: INT;
	uiStype_Rd					: UINT;
	iItemMax_Repack				: INT;
	iEEpromAddr					: INT := 143;(* 读取的eeprom起始地址--功率板信息编码位置 *)
	iBytesNum					: INT := 4;(* 读取的字节数|编码一共4个字节 *)
	abyRdBuf					: ARRAY [1..10] OF BYTE;(* 用来存储读取的值 *)
	pdwTmp						: POINTER TO DWORD;
//	stfirmwareversion			: firmwareversion;(* 固件信息 *)
	pstStWatch_Sts_display		: POINTER TO StParam_Diamonds_Wr_RunSts;
	iDataRd						: INT;
 	dwAddrRd					: DWORD;	
	wTorque						: WORD;	
END_VAR

{IMPLEMENTATION}
o_xEno:= i_xEn;
o_iErNo:= 0;
IF i_xEn THEN
	IF i_pxRequstRdAgain<>0 THEN
		IF i_pxRequstRdAgain^ THEN
			i_pxRequstRdAgain^:= FALSE;
			o_xDone:= FALSE;
			iCursor:= -1;
			iCaseId:= CASE_GET_RINGNET_INF;(* 从读取站号开始 *)
			IF i_pstStRingInf<>0 THEN
				i_pstStRingInf^.m_device_num:= 0;
			END_IF

		END_IF
	END_IF

	IF i_pstStRingInf<>0 AND
		i_pastStWatch_Sts_display<>0 THEN

		CASE iCaseId OF
		CASE_GET_RINGNET_INF:(* 读取网络站点信息 *)
//			iRtn:= GT_RN_GetLocalInfVer1(i_pstStRingInf);
			IF iRtn<>0 THEN
(*				KS_ThrowMsg2TravelLog(
					i_pstStTravelLogRec,
					LOG_LEVEL_INFO_DBG,
					'GT_RN_GetLocalInfVer1() failed!',
					INT_TO_STRING(iRtn) );
*)
				KS_HY_AddMsgToLog(i_pstStHYLogFifo, LOG_LEVEL_INFO, 'GT_RN_GetLocalInfVer1() failed!', INT_TO_STRING(iRtn));
			ELSE
				iCursor:= 1;
				iCaseId:= CASE_GET_DRV_TYPE;

				(* iItemMax列表循环的上限/需要考虑所有内存的空间/按照最小的兼容机制循环 *)
				iItemMax:=(* 先检查站列表范围/256 *)
					MIN(DWORD_TO_INT(SIZEOF(i_pstStRingInf^.m_station_id_list)/SIZEOF(i_pstStRingInf^.m_station_id_list[1])),
						BYTE_TO_INT(i_pstStRingInf^.m_device_num) );
				iItemMax:=(* 再看系统分配的最大兼容/128 *)
					MIN(iItemMax,
						DWORD_TO_INT(SIZEOF(i_pastStWatch_Sts_display^)/SIZEOF(i_pastStWatch_Sts_display^[1])) );
			END_IF
(*先注释了2025.6.30.170147后面等指令接口确定再执行*)
(*
				(* 2021.12.22.095437/hdp *)
				o_sSummaryOfGTSD:= '';
				o_sSummaryOfGSHD:= '';
				o_sSummaryOfOTHs:= '';
			END_IF
		CASE_GET_DRV_TYPE:(* 读取驱动器类型 *)
			IF iCursor>=1 AND iCursor<=iItemMax THEN(* 在许可的列表访问范围内 *)
				(* 将站id写入/2021.12.17.114417/hdp *)

				iRtn:=
				GT_RN_MailRdMultReg(
					SHL(UINT#7,1),
					ADR(uiStype_Rd),
					1,
					1,
					i_pstStRingInf^.m_station_id_list[iCursor]);(* 读取驱动器类型字 *)
				IF iRtn<>0 THEN(* 写入日志 *)
					KS_ThrowMsg2TravelLog(
						i_pstStTravelLogRec,
						LOG_LEVEL_INFO_DBG,
						CONCAT('GT_RN_MailRdMultReg(CASE_GET_DRV_TYPE) failed.', BYTE_TO_STRING(i_pstStRingInf^.m_station_id_list[iCursor])),
						INT_TO_STRING(iRtn) );
				ELSE(* 输出对应站的固件版本信息 *)
					pstStWatch_Sts_display:= ADR(i_pastStWatch_Sts_display^[iCursor]);
					IF pstStWatch_Sts_display<>0 THEN
						pstStWatch_Sts_display^.uiStationType:= uiStype_Rd;
					END_IF
				END_IF
				IF iCursor=iItemMax THEN
					iCursor:= -1;
					iCaseId:= CASE_GET_DRV_PWR_LEVEL;
				ELSE
					iCursor:= iCursor+1;
				END_IF
			ELSIF iItemMax<1 THEN(* 范围无效 *)
				iCursor:= -1;
				iCaseId:= CASE_STANDBY;
			ELSE
				iCursor:= 1;
			END_IF

		CASE_GET_DRV_PWR_LEVEL:(* 读取功率等级 *)
			IF iCursor>=1 AND iCursor<=iItemMax THEN(* 在许可的列表访问范围内 *)
				pstStWatch_Sts_display:= ADR(i_pastStWatch_Sts_display^[iCursor]);
				IF pstStWatch_Sts_display<>0 THEN
					pstStWatch_Sts_display^.dwDrvPowerLevel:= 0;(* 默认值 *)
					IF pstStWatch_Sts_display^.uiStationType<>CONTROLLER_GTSD13 THEN
						iRtn:=
						GTD_ReadServoEEpromExt(
							1,
							iEEpromAddr,
							ADR(abyRdBuf),
							iBytesNum,
							i_pstStRingInf^.m_station_id_list[iCursor]);
						IF iRtn<>0 THEN(* 写入日志 *)
							KS_ThrowMsg2TravelLog(
								i_pstStTravelLogRec,
								LOG_LEVEL_INFO_DBG,
								CONCAT('GTD_ReadServoEEpromExt(CASE_GET_DRV_PWR_LEVEL) failed. Sid=', BYTE_TO_STRING(i_pstStRingInf^.m_station_id_list[iCursor])),
								INT_TO_STRING(iRtn) );
						ELSE(* 输出对应站的固件版本信息 *)
							pdwTmp:= ADR(abyRdBuf);
							IF pdwTmp<>0 THEN
								pstStWatch_Sts_display^.dwDrvPowerLevel:= pdwTmp^;
							END_IF
						END_IF
					END_IF
				END_IF
				IF iCursor=iItemMax THEN
					iCursor:= -1;
					iCaseId:= CASE_GET_DRV_FW_VERSION;
				ELSE
					iCursor:= iCursor+1;
				END_IF
			ELSIF iItemMax<1 THEN(* 范围无效 *)
				iCursor:= -1;
				iCaseId:= CASE_STANDBY;
			ELSE
				iCursor:= 1;
			END_IF

		CASE_GET_DRV_FW_VERSION:(* 读取驱动器固件版本信息 *)
			IF iCursor>=1 AND iCursor<=iItemMax THEN(* 在许可的列表访问范围内 *)
				iRtn:=
				GTD_GetFirmwareVersion(
					1,
					ADR(stFirmwareVersion),
					i_pstStRingInf^.m_station_id_list[iCursor]);(* 读取驱动器的固件版本 *)
				IF iRtn<>0 THEN(* 写入日志 *)
					KS_ThrowMsg2TravelLog(
						i_pstStTravelLogRec,
						LOG_LEVEL_INFO_DBG,
						CONCAT('GTD_GetFirmwareVersion() failed. Sid=', BYTE_TO_STRING(i_pstStRingInf^.m_station_id_list[iCursor])),
						INT_TO_STRING(iRtn) );
				ELSE(* 输出对应站的固件版本信息 *)
					pstStWatch_Sts_display:= ADR(i_pastStWatch_Sts_display^[iCursor]);
					IF pstStWatch_Sts_display<>0 THEN
						pstStWatch_Sts_display^.dwVersion_cpld:= SHL(INT_TO_DWORD(stfirmwareversion.cpld_ver_year), 16)+INT_TO_DWORD(stfirmwareversion.cpld_ver_md);
						pstStWatch_Sts_display^.dwVersion_dsp:= SHL(INT_TO_DWORD(stfirmwareversion.dsp_ver_year), 16)+INT_TO_DWORD(stfirmwareversion.dsp_ver_md);
						pstStWatch_Sts_display^.dwVersion_fpga:= SHL(INT_TO_DWORD(stfirmwareversion.fpga_ver_year), 16)+INT_TO_DWORD(stfirmwareversion.fpga_ver_md);
					END_IF
				END_IF
				IF iCursor=iItemMax THEN
					iCursor:= -1;
					iCaseId:= CASE_GEN_SUMMARY_OF_STATION(*CASE_GET_DRV_PARAM_NRS*);(* 2021.12.22.095656/hdp/增加一步 *)

					o_sSummaryOfGTSD:= 'GTSD: ';
					o_sSummaryOfGSHD:= 'GSHD: ';
					o_sSummaryOfOTHs:= 'OTHs: ';
				ELSE
					iCursor:= iCursor+1;
				END_IF
			ELSIF iItemMax<1 THEN
				iCursor:= -1;
				iCaseId:= CASE_STANDBY;
			ELSE
				iCursor:= 1;
			END_IF

		CASE_GEN_SUMMARY_OF_STATION:(* 生成有关站号的摘要信息/2021.12.22.094545/hdp *)
			IF iCursor>=1 AND iCursor<=iItemMax THEN(* 在许可的列表访问范围内 *)

				CASE i_pastStWatch_Sts_display^[iCursor].uiStationType OF
				CONTROLLER_GTSD15,
				CONTROLLER_GTSD13,
				CONTROLLER_GTSD16M,
				CONTROLLER_GTSD16M_II,
				CONTROLLER_GTSD16D:
					o_sSummaryOfGTSD:= CONCAT(o_sSummaryOfGTSD, INT_TO_STRING(i_pastStWatch_Sts_display^[iCursor].iStationId));
					o_sSummaryOfGTSD:= CONCAT(o_sSummaryOfGTSD, '/ ');
				CONTROLLER_GSHD2:
					o_sSummaryOfGSHD:= CONCAT(o_sSummaryOfGSHD, INT_TO_STRING(i_pastStWatch_Sts_display^[iCursor].iStationId));
					o_sSummaryOfGSHD:= CONCAT(o_sSummaryOfGSHD, '/ ');
				ELSE(* 包含[CONTROLLER_GNS]/2022.6.8.100532 *)
					o_sSummaryOfOTHs:= CONCAT(o_sSummaryOfOTHs, INT_TO_STRING(i_pastStWatch_Sts_display^[iCursor].iStationId));
					o_sSummaryOfOTHs:= CONCAT(o_sSummaryOfOTHs, '/ ');
				END_CASE

				IF iCursor=iItemMax THEN
					iCursor:= -1;
					iCaseId:= CASE_GET_DRV_PARAM_NRS;(* 2021.12.22.095716/hdp/继续读取剩余的参数信息 *)
					o_sSummaryOfGTSD:= CONCAT(o_sSummaryOfGTSD, '||');(* 2021.12.22.105301/hdp/结束增加'||'作为标记 *)
					o_sSummaryOfGSHD:= CONCAT(o_sSummaryOfGSHD, '||');
					o_sSummaryOfOTHs:= CONCAT(o_sSummaryOfOTHs, '||');
				ELSE
					iCursor:= iCursor+1;
				END_IF
			ELSIF iItemMax<1 THEN(* 范围无效 *)
				iCursor:= -1;
				iCaseId:= CASE_STANDBY;
			ELSE
				iCursor:= 1;
			END_IF

		CASE_GET_DRV_PARAM_NRS:(* 读取电机的额定转速 *)
			dwAddrRd:= 81;(* Nrs *)
			IF iCursor>=1 AND iCursor<=iItemMax THEN(* 在许可的列表访问范围内 *)
				iRtn:= GTD_GetFlashParamIndex(1, dwAddrRd, ADR(iDataRd), i_pstStRingInf^.m_station_id_list[iCursor]);
				IF iRtn<>0 THEN(* 写入日志 *)
					KS_ThrowMsg2TravelLog(
						i_pstStTravelLogRec,
						LOG_LEVEL_INFO_DBG,
						CONCAT('GTD_GetFlashParamIndex(gSev.cur.mot.Nrs) failed. Sid=', BYTE_TO_STRING(i_pstStRingInf^.m_station_id_list[iCursor])),
						INT_TO_STRING(iRtn) );
				ELSE
					pstStWatch_Sts_display:= ADR(i_pastStWatch_Sts_display^[iCursor]);
					IF pstStWatch_Sts_display<>0 THEN
						pstStWatch_Sts_display^.uiDrvParam_Nrs:= INT_TO_UINT(iDataRd);
					END_IF
				END_IF
				IF iCursor=iItemMax THEN
					iCursor:= -1;
					iCaseId:= CASE_GET_DRV_PARAM_NOS;
				ELSE
					iCursor:= iCursor+1;
				END_IF
			ELSIF iItemMax<1 THEN(* 范围无效 *)
				iCursor:= -1;
				iCaseId:= CASE_STANDBY;
			ELSE
				iCursor:= 1;
			END_IF

		CASE_GET_DRV_PARAM_NOS:(* 读取电机的过速转速 *)
			dwAddrRd:= 80;(* Nos *)
			IF iCursor>=1 AND iCursor<=iItemMax THEN(* 在许可的列表访问范围内 *)
				iRtn:= GTD_GetFlashParamIndex(1, dwAddrRd, ADR(iDataRd), i_pstStRingInf^.m_station_id_list[iCursor]);
				IF iRtn<>0 THEN(* 写入日志 *)
					KS_ThrowMsg2TravelLog(
						i_pstStTravelLogRec,
						LOG_LEVEL_INFO_DBG,
						CONCAT('GTD_GetFlashParamIndex(gSev.cur.mot.Nos) failed. Sid=', BYTE_TO_STRING(i_pstStRingInf^.m_station_id_list[iCursor])),
						INT_TO_STRING(iRtn) );
				ELSE
					pstStWatch_Sts_display:= ADR(i_pastStWatch_Sts_display^[iCursor]);
					IF pstStWatch_Sts_display<>0 THEN
						pstStWatch_Sts_display^.uiDrvParam_Nos:= INT_TO_UINT(iDataRd);
					END_IF
				END_IF
				IF iCursor=iItemMax THEN
					iCursor:= -1;
					iCaseId:= CASE_GET_DRV_PARAM_IMAX;
				ELSE
					iCursor:= iCursor+1;
				END_IF
			ELSIF iItemMax<1 THEN(* 范围无效 *)
				iCursor:= -1;
				iCaseId:= CASE_STANDBY;
			ELSE
				iCursor:= 1;
			END_IF

		CASE_GET_DRV_PARAM_IMAX:(* 读取电机的最大电流 *)
			dwAddrRd:= 82;(* Imax *)
			IF iCursor>=1 AND iCursor<=iItemMax THEN(* 在许可的列表访问范围内 *)
				iRtn:= GTD_GetFlashParamIndex(1, dwAddrRd, ADR(iDataRd), i_pstStRingInf^.m_station_id_list[iCursor]);
				IF iRtn<>0 THEN(* 写入日志 *)
					KS_ThrowMsg2TravelLog(
						i_pstStTravelLogRec,
						LOG_LEVEL_INFO_DBG,
						CONCAT('GTD_GetFlashParamIndex(gSev.cur.mot.Imax) failed. Sid=', BYTE_TO_STRING(i_pstStRingInf^.m_station_id_list[iCursor])),
						INT_TO_STRING(iRtn) );
				ELSE
					pstStWatch_Sts_display:= ADR(i_pastStWatch_Sts_display^[iCursor]);
					IF pstStWatch_Sts_display<>0 THEN
						pstStWatch_Sts_display^.uiDrvParam_Imax:= INT_TO_UINT(iDataRd);
					END_IF
				END_IF
				IF iCursor=iItemMax THEN
					iCursor:= -1;
					iCaseId:= CASE_GET_DRV_PARAM_POSOFST;
				ELSE
					iCursor:= iCursor+1;
				END_IF
			ELSIF iItemMax<1 THEN(* 范围无效 *)
				iCursor:= -1;
				iCaseId:= CASE_STANDBY;
			ELSE
				iCursor:= 1;
			END_IF

		CASE_GET_DRV_PARAM_POSOFST:(* 读取位置偏移 *)
			dwAddrRd:= 138;(* pos_ofst *)
			IF iCursor>=1 AND iCursor<=iItemMax THEN(* 在许可的列表访问范围内 *)
//				iRtn:= GTD_GetFlashParamIndex(1, DWORD_TO_UDINT(dwAddrRd), ADR(iDataRd), BYTE_TO_INT(i_pstStRingInf^.m_station_id_list[iCursor]));
				IF iRtn<>0 THEN(* 写入日志 *)
					KS_ThrowMsg2TravelLog(
						i_pstStTravelLogRec,
						LOG_LEVEL_INFO_DBG,
						CONCAT('GTD_GetFlashParamIndex(gSev.cur.rsv.pos_ofst) failed. Sid=', BYTE_TO_STRING(i_pstStRingInf^.m_station_id_list[iCursor])),
						INT_TO_STRING(iRtn) );
				ELSE
					pstStWatch_Sts_display:= ADR(i_pastStWatch_Sts_display^[iCursor]);
					IF pstStWatch_Sts_display<>0 THEN
						pstStWatch_Sts_display^.iDrvParam_PosOfst:= iDataRd;
					END_IF
				END_IF
				IF iCursor=iItemMax THEN
					iCursor:= -1;
					iCaseId:= CASE_GET_DRV_PARAM_TORQUE;//CASE_STANDBY;
					//o_xDone:= TRUE;
//					pstStWatch_Sts_display^.iTotalValidItems:= iItemMax;(* 全部读取ok以后才设置有效条目数量 *)
				ELSE
					iCursor:= iCursor+1;
				END_IF
			ELSIF iItemMax<1 THEN(* 范围无效 *)
				iCursor:= -1;
				iCaseId:= CASE_STANDBY;
			ELSE
				iCursor:= 1;
			END_IF
		CASE_GET_DRV_PARAM_TORQUE:
			IF iCursor>=1 AND iCursor<=iItemMax THEN(* 在许可的列表访问范围内 *)
				pstStWatch_Sts_display:= ADR(i_pastStWatch_Sts_display^[iCursor]);
				IF pstStWatch_Sts_display<>0 THEN
					pstStWatch_Sts_display^.rTorqueCoeff:= 0;(* 默认值 *)
					IF pstStWatch_Sts_display^.uiStationType<>CONTROLLER_GTSD13 THEN
						iRtn := GT_ReadServoParamInfo(
							axis:= 1, 
							objectIndex:= 16#2008, 
							subIndex:= 16#0, 
							pData:= ADR(wTorque), 
							byteSize:= 2, 
							memType:= 0, 
							stationId:= i_pstStRingInf^.m_station_id_list[iCursor]);
						IF iRtn<>0 THEN(* 写入日志 *)
							KS_ThrowMsg2TravelLog(
								i_pstStTravelLogRec,
								LOG_LEVEL_INFO_DBG,
								CONCAT('GT_ReadServoParamInfo(gSev.cur.mot.torque) failed. Sid=', BYTE_TO_STRING(i_pstStRingInf^.m_station_id_list[iCursor])),
								INT_TO_STRING(iRtn) );
						ELSE(* 输出对应站的扭矩系数信息 *)
// 							pdwTmp:= ADR(abyRdBuf);
// 							IF pdwTmp<>0 THEN
// 								pstStWatch_Sts_display^.rTorqueCoeff:= pdwTmp^;
// 							END_IF
							pstStWatch_Sts_display^.rTorqueCoeff:=wTorque;
						END_IF
					END_IF
				END_IF
				IF iCursor=iItemMax THEN
					iCursor:= -1;
					iCaseId:= CASE_STANDBY;
					o_xDone:= TRUE;
				ELSE
					iCursor:= iCursor+1;
				END_IF
			ELSIF iItemMax<1 THEN(* 范围无效 *)
				iCursor:= -1;
				iCaseId:= CASE_STANDBY;
			ELSE
				iCursor:= 1;
			END_IF
*)
		ELSE;
		END_CASE
		
		o_iCaseId:= iCaseId;
	ELSE
		o_iErNo:= -1;(* 传入的参数非法 *)
	END_IF
END_IF