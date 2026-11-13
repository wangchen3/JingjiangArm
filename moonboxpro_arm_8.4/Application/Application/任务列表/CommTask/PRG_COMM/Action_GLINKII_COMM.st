(*@CES
Name=Action_GLINKII_COMM
Type=Action
TypeGuid=8ac092e5-3128-4e26-9e7e-11016c6684f2
Guid=d0921674-03aa-48cd-942a-bf6130ef7c95
HasDeclaration=False
HasImplementation=True
*)
{DECLARATION}

{IMPLEMENTATION}
(* ************************************************** *)
(* 命令轮询队列的初始化 *)
(* ************************************************** *)
IF NOT xFlag_CmdQueueInitialized THEN
	FOR iN:=1 TO MAX_UNIT_NUM BY 1 DO
		astStUnitCmdQueue[iN].aiCmdId[1]:= 91;
		astStUnitCmdQueue[iN].aiCmdId[2]:= 92;
		astStUnitCmdQueue[iN].aiCmdId[3]:= 93;
		astStUnitCmdQueue[iN].aiCmdId[4]:= 94;
		astStUnitCmdQueue[iN].aiCmdId[5]:= 95;
		
		astStUnitCmdQueue[iN].byCmdNum:= 5; 
											
		astStUnitCmdQueue[iN].byCmdIdx:= 1;
	END_FOR
	xFlag_CmdQueueInitialized:= TRUE;
	tmPduSnt_LastTime:= tmCURR;
ELSE
	;
END_IF
(* 有个内存需要申请 *)
IF pastStParam_Mailbox_proof=0 THEN
	pastStParam_Mailbox_proof:= SysMemAllocData('',SIZEOF(pastStParam_Mailbox_proof^),ADR(udiresult));
ELSE
	;
END_IF
(* h/
/pdu通讯/(广播命令)
/每次调用对列表中所有的站只处理各自的1条广播命令
*)

tmCURR:= TIME();
IF (tmCURR-tmPduSnt_LastTime)>=TIMEOUTS_PDU_CMD_CHG THEN(* 时间到/开始处理pdu命令轮询 *)
	FOR iN:=1 TO MAX_UNIT_NUM BY 1 DO(* 为了保证让所有的都能同步轮询命令id/这里把所有色组都循环上 *)
		iUnitId:= iN;(*通讯轴号也需要根据后续系统配置处理*)
		pstStUnitCmdQueue_Tmp:= ADR(astStUnitCmdQueue[iUnitId]);
		iGrpId := KS_GetGrpIdByAxisId(iUnitId,ADR(g_stStSysParam),ADR(iAxisTypeId));
		iStationId := g_stStSysParam.stStSysParam_UnSave.aiStationList_UnitController[iN];
		IF pstStUnitCmdQueue_Tmp<>0 AND
			KS_IsValidStationNR(iStationId) AND
			(iGrpId=1 OR iGrpId=2) AND (* 已经明确分配AB系 *)
			iStationId<>g_stStStationInfo_KS.iSid_Device THEN(*2024.1.3.200526/+ *)
			
			byIDX_Tmp:= pstStUnitCmdQueue_Tmp^.byCmdIdx;
			byMAX_Tmp:= pstStUnitCmdQueue_Tmp^.byCmdNum;
			IF (byIDX_Tmp>=1 AND byIDX_Tmp<=byMAX_Tmp) AND
				(byMAX_Tmp<=MAX_CMD_NUM_PDU) THEN(* 命令轮询范围有效 *)		
				iRtn:=
				KS_FillUnitPduCmd_DN(
					iUnitId,
					iGrpId,
					astStUnitCmdQueue[iUnitId].aiCmdId[byIDX_Tmp],
					wAxis_RollerDn,
					wAxis_Alarm_Prn,
					wComplexFlag_AxisInching,
					wComplexFlag_Linkage,
					ADR(g_stStSysParam),
					ADR(abyBuf_PduCmd_snd));
				IF iRtn=0 THEN
					dwOFST:= 0;
					dwOFST.14:= TRUE;(* 绝对地址访问 *)

					(* pdu发送 *)
					iRtn:=
					GTN_RN_UserPCWrNetFPGA(
						1,(*卡号，先只写1*)
						1,(*总线ID，第一套等环网写1，第二套等环网写2*)
						iStationId,(*物理站号*)
						ADR(abyBuf_PduCmd_snd),	(*有效数据*)				
						DWORD_TO_WORD(dwOFST),(*地址*)
						KS_GetNumOfDwordUsed(SIZEOF(abyBuf_PduCmd_snd)) );
					IF iRtn<>0 THEN
						(*写日志2023.3.31.095202*)
						;
					ELSE
						//2026.04.03.114245PDU只要通讯正常，Mailbox不需要考虑强制10s更新参数
						atmUnitMailboxLastSynchronized[iUnitId]:= tmCURR;
						
					END_IF
				ELSE
					;
				END_IF
				IF byIDX_Tmp>=byMAX_Tmp THEN
					byIDX_Tmp:=1;
				ELSE
					byIDX_Tmp:= byIDX_Tmp+1;
				END_IF
				pstStUnitCmdQueue_Tmp^.byCmdIdx:= byIDX_Tmp;				
			ELSE
				pstStUnitCmdQueue_Tmp^.byCmdIdx:= 1;	
			END_IF
		ELSE
			;
		END_IF
	END_FOR
	tmPduSnt_LastTime:= tmCURR;(* 更新时间戳 *)
ELSE
	;
END_IF


(* ************************************************** *)
(* 开始处理mailbox通讯 *)
(* MAILbox处理机制: *)
(* 按照16个色组(MAX_UNIT_NUM)来均分8k区域/每区域512字节 *)
(* 按照最大Mailbox单包最大字节480字节进行约束 *)
(* 每个区域都是按照轴进行分配的 *)
(* ************************************************** *)
FOR iN:=1 TO MAX_UNIT_NUM BY 1 DO
	iUnitId:= iN;
	dwOFST:= INT_TO_DWORD((iUnitId-1))*INT_TO_DWORD(MAILBOX_PKG_MAX_BYTES);
	iStationId := g_stStSysParam.stStSysParam_UnSave.aiStationList_UnitController[iUnitId];
	pstStUnitParam_Save:= ADR(g_stStSysParam.astStUnitParam_Save[iUnitId]);
	pstStUnitParam_UnSave:= ADR(g_stStSysParam.astStUnitParam_UnSave[iUnitId]);

	IF pstStUnitParam_Save<>0 AND(* 色组id访问有效 *)
		KS_IsValidStationNR(iStationId) AND(*2024.1.3.200526/+ *)
		iUnitId<=MIN(MAX_UNIT_NUM,g_stStSysParam.stStSysParam_Save.iUnitMaxNum) AND
		iStationId<>g_stStStationInfo_KS.iSid_Device THEN(* 色组有效范围内/循环最少的数量/2023.11.22.102021/han.dp *)
														//增加判断-不与自身站通讯
		(* 本地读取/1次多读1点/万一是需要的就不用再读了 *)
		pDataTest:= adr(abyBuf_MailboxPkg_rcv);
		iRtn:= GTN_RN_DevicePcMailRd(
								1,
								1,
								0,
								ADR(abyBuf_MailboxPkg_rcv), 
								DWORD_TO_WORD(dwOFST), 
								KS_GetNumOfDwordUsed(SIZEOF(pstStParam_Mailbox_Tmp^)),
								RN_ARD);
		//2023.12.26.163244通讯长度改为实际长度2023.12.26.163251
		(* 套用协议/2021.12.21.114854/hdp *)
		pstStParam_Mailbox_Tmp:= ADR(abyBuf_MailboxPkg_rcv);
		(* gt指令执行成功且协议套用成功/2021.12.21.114917/hdp *)
		IF iRtn=0 AND pstStParam_Mailbox_Tmp<>0 THEN
			CASE pstStParam_Mailbox_Tmp^.dwSemaphore OF
			SEMA_UPLOAD:(* 来自从站的数据更新/没什么问题就同步到本地数据结构中 *)

				(* 判断一下参数的合理性/如果有问题/强行同步到从站去 *)
				IF (pstStParam_Mailbox_Tmp^.iGateSa>=0 AND pstStParam_Mailbox_Tmp^.iGateSa<=3999) AND
					(pstStParam_Mailbox_Tmp^.iGateSaEx>=0 AND pstStParam_Mailbox_Tmp^.iGateSaEx<=3999) AND
					(pstStParam_Mailbox_Tmp^.rAdjust_V>=-80.00 AND pstStParam_Mailbox_Tmp^.rAdjust_V<=80.00) AND
					(pstStParam_Mailbox_Tmp^.rAdjust_H>=-20.00 AND pstStParam_Mailbox_Tmp^.rAdjust_H<=20.00) AND
					(NOT (pstStParam_Mailbox_Tmp^.wSV_UnitTemCtl=0 AND pstStUnitParam_Save^.rSV_UnitTemCtl<>0)) 
					 THEN//参数
							(*2023.12.26.150253增加保护-设定温度不会主动设定为0取*)
							(* 重要的几个参数检查/合法通过后 *)
					axNeedUpdateParam_Malilbox[iUnitId]:= TRUE;
aiTime1[iUnitId]:= aiTime1[iUnitId]+1;
					SysMemCpy(ADR(astStParam_Mailbox_out[iUnitId]),
							pstStParam_Mailbox_Tmp,
							SIZEOF(astStParam_Mailbox_out[iUnitId]));
											
					diTMP:= DWORD_TO_DINT(pstStParam_Mailbox_Tmp^.dwPlateAdjustmentProf);
					iUnitId_Tmp:= DWORD_TO_INT(DINT_TO_DWORD(diTMP) AND DWORD#255);(* 色组id *)
					diValue_Tmp:= SHR(diTMP, 8);(* 提交的数据 *)
					
					iRtn:=	KS_PushRapidAdjValue_V(ADR(g_astStAxisRapidAdjProf_V), iUnitId_Tmp, diValue_Tmp);
					IF iRtn <> 0 THEN
						(*2023.3.31.100107写日志2023.3.31.100110
						IF i_xRunlogEnable AND(* 2021.12.30.151304/日志使能 *)
							KS_IsValidUnitNR(iUnitId_Tmp) THEN
							sMsg_:= CONCAT('#SEMA_UPLOAD|KS_PushRapidAdjValue_V(Uid=', INT_TO_STRING(iUnitId_Tmp));
							sMsg_:= CONCAT(sMsg_, ')');
							KS_ThrowMsg2TravelLog(
								i_pstStTravelLogRec,
								LOG_LEVEL_INFO_DBG,
								sMsg_,
								DINT_TO_STRING(diValue_Tmp));
						END_IF
						*)
					ELSE
						;
					END_IF
IF pstStParam_Mailbox_Tmp^.iRapidAdjProf_h<>0 THEN
					(* 横向快速对版量 *)
					iRtn := KS_PushRapidAdjValue_H(ADR(g_astStAxisRapidAdjProf_H), iUnitId, pstStParam_Mailbox_Tmp^.iRapidAdjProf_h);

					IF iRtn <> 0 THEN
						(*2023.3.31.100107写日志2023.3.31.100110
						IF i_xRunlogEnable AND(* 2021.12.30.151345/日志使能 *)
							KS_IsValidUnitNR(iUnitNR) AND
							pstStProtocol_Mailbox_Tmp^.iRapidAdjProf_h<>0 THEN
							sMsg_:= CONCAT('#SEMA_UPLOAD|KS_PushRapidAdjValue_H(Uid=', INT_TO_STRING(iUnitNR));
							sMsg_:= CONCAT(sMsg_, ')');
							KS_ThrowMsg2TravelLog(
								i_pstStTravelLogRec,
								LOG_LEVEL_INFO_DBG,
								sMsg_,
								INT_TO_STRING(pstStProtocol_Mailbox_Tmp^.iRapidAdjProf_h));
						END_IF
						*)
					ELSE
						;	
					END_IF
END_IF
					IF pastStParam_Mailbox_proof<>0 THEN(* 留存证据/下次比对用 *)
						SysMemCpy(ADR(pastStParam_Mailbox_proof^[iUnitId]), pstStParam_Mailbox_Tmp, SIZEOF(pstStParam_Mailbox_Tmp^));
					END_IF

					(* 正常接收的内容/就重新复位向量即可 *)
					pdwSEMA:= ADR(abyBuf_MailboxPkg_snd);
					IF pdwSEMA<>0 THEN
						pdwSEMA^:= SEMA_STANDBY;
//						iRtn:= GT_RN_DeviceLocalPcRamWr(pdwSEMA, DWORD_TO_WORD(dwOFST), KS_GetNumOfDwordUsed(SIZEOF(pdwSEMA^)));
						//SysMemCpy(ADR(abyBuf_MailboxPkg_snd), 1, SIZEOF(stStParam_Mailbox_Tmp));//2025.08.19 | TEST_
						iRtn:= GTN_RN_DevicePcMailWr(
								1,1,
								0,
								pdwSEMA,
								DWORD_TO_WORD(dwOFST),
								KS_GetNumOfDwordUsed(SIZEOF(pdwSEMA^)),
								16#1,0
								);

					END_IF
				ELSE
					(* 从站的参数非法/主动同步给从站/2021.12.4.142033/hdp *)
					SysMemCpy(ADR(stStParam_Mailbox_Tmp),ADR(astStParam_Mailbox_snd[iUnitId]),SIZEOF(stStParam_Mailbox_Tmp));
					//iRtn:= KS_FillUnitMailboxCmd_DN(ADR(stStParam_Mailbox_Tmp), pstStUnitParam_Save,pstStUnitParam_UnSave);
					SysMemSet(ADR(abyBuf_MailboxPkg_snd), 0, SIZEOF(abyBuf_MailboxPkg_snd));
					SysMemCpy(ADR(abyBuf_MailboxPkg_snd), ADR(stStParam_Mailbox_Tmp), SIZEOF(stStParam_Mailbox_Tmp));
//					iRtn:= GT_RN_DeviceLocalPcRamWr(ADR(abyBuf_MailboxPkg_snd), DWORD_TO_WORD(dwOFST), KS_GetNumOfDwordUsed(SIZEOF(pstStParam_Mailbox_Tmp)));
					//SysMemCpy(ADR(abyBuf_MailboxPkg_snd), 1, SIZEOF(stStParam_Mailbox_Tmp));//2025.08.19 | TEST_
					iRtn:= GTN_RN_DevicePcMailWr(
							1,1,
							0,
							ADR(abyBuf_MailboxPkg_snd),
							DWORD_TO_WORD(dwOFST),
							KS_GetNumOfDwordUsed(SIZEOF(pstStParam_Mailbox_Tmp)),
							16#1,0
							);
					IF iRtn<>0 THEN
						(*IF i_xRunlogEnable THEN(* 2021.12.21.133247/hdp *)
							KS_ThrowMsg2TravelLog(
								g_pstStTravelLogRec,
								LOG_LEVEL_INFO_DBG,
								'#SEMA_UPLOAD|Failed downloading...',
								INT_TO_STRING(iRtn));
						END_IF
						*);
					ELSE
						IF pastStParam_Mailbox_proof<>0 THEN(* 更新证据 *)
							(* 2023.11.22.093131/han.dp/已经修正过src地址和大小 *)
							SysMemCpy(ADR(pastStParam_Mailbox_proof^[iUnitId]), ADR(stStParam_Mailbox_Tmp), SIZEOF(stStParam_Mailbox_Tmp));
						END_IF
					END_IF

				END_IF

				(* 只要是约定的状态之一/就更新Mailbox通讯的超时时间/2021.12.21.135901/hdp *)
				atmUnitMailboxLastSynchronized[iUnitId]:= tmCURR;

			SEMA_DOWNLOAD:(* 主站下发的/从站还没有读取/要不再等等 *)
				(* 如果从站长时间不读取/本地数据又更新了/我们是不是考虑也把发送的内容更新一下 *)
				;

				(* 只要是约定的状态之一/就更新Mailbox通讯的超时时间/2021.12.21.135901/hdp *)
				atmUnitMailboxLastSynchronized[iUnitId]:= tmCURR;

			SEMA_PLS_REQ_DISPATCH:(* 请从站主动来请求 *)
				(* 等从站修改状态 *)
				;

				(* 只要是约定的状态之一/就更新Mailbox通讯的超时时间/2021.12.21.135901/hdp *)
				atmUnitMailboxLastSynchronized[iUnitId]:= tmCURR;

			SEMA_REQ_DISPATCH:(* 从站已经来请求了 *)
				(* 从站的参数非法/主动同步给从站/2021.12.4.142033/hdp *)
				SysMemCpy(ADR(stStParam_Mailbox_Tmp),ADR(astStParam_Mailbox_snd[iUnitId]),SIZEOF(stStParam_Mailbox_Tmp));
				
			//	iRtn:= KS_FillUnitMailboxCmd_DN(ADR(stStParam_Mailbox_Tmp), pstStUnitParam_Save,pstStUnitParam_UnSave);
				
				SysMemSet(ADR(abyBuf_MailboxPkg_snd), 0, SIZEOF(abyBuf_MailboxPkg_snd));
				SysMemCpy(ADR(abyBuf_MailboxPkg_snd), ADR(stStParam_Mailbox_Tmp), SIZEOF(stStParam_Mailbox_Tmp));

				//iRtn:= GT_RN_DeviceLocalPcRamWr(ADR(abyBuf_MailboxPkg_snd),
				//								DWORD_TO_WORD(dwOFST),
				//								KS_GetNumOfDwordUsed(SIZEOF(abyBuf_MailboxPkg_snd)));
				//改为实际长度2023.12.26.163451
// 				iRtn:= GTN_RN_DeviceLocalPcRamWr(ADR(abyBuf_MailboxPkg_snd),
// 												DWORD_TO_WORD(dwOFST),
// 												KS_GetNumOfDwordUsed(SIZEOF(stStParam_Mailbox_Tmp)));  
				iRtn:= GTN_RN_DevicePcMailWr(
						1,1,
						0,
						ADR(abyBuf_MailboxPkg_snd),
						DWORD_TO_WORD(dwOFST),
						KS_GetNumOfDwordUsed(SIZEOF(stStParam_Mailbox_Tmp)),
						16#1,0
						);
(*
FUNCTION GTN_RN_DevicePcMailWr : INT
VAR_INPUT  
	cardIndex:INT;
	busIndex:INT;
	stationId:INT;
	pData:POINTER TO UDINT;
	startAddr:UINT;
	dwordNum:UINT;
	cmdType:BYTE;
	respReq:BYTE;
END_VAR
VAR
END_VAR
*)
												
				IF iRtn<>0 THEN
					(*IF i_xRunlogEnable THEN(* 2021.12.21.132943/hdp *)
						KS_ThrowMsg2TravelLog(
							g_pstStTravelLogRec,
							LOG_LEVEL_INFO_DBG,
							'#SEMA_REQ_DISPATCH|Failed downloading...',
							INT_TO_STRING(iRtn));
					END_IF
					*);
				ELSE
					IF pastStParam_Mailbox_proof<>0 THEN(* 更新证据 *)
						(* 2023.11.22.093131/han.dp/已经修正过src地址和大小 *)
						SysMemCpy(ADR(pastStParam_Mailbox_proof^[iUnitId]), ADR(stStParam_Mailbox_Tmp), SIZEOF(stStParam_Mailbox_Tmp));
					END_IF
				END_IF


				(* 只要是约定的状态之一/就更新Mailbox通讯的超时时间/2021.12.21.135901/hdp *)
				atmUnitMailboxLastSynchronized[iUnitId]:= tmCURR;
			ELSE
				(* 剩余的情况/就定期扫描看主站数据是否有更新 *)
				(* 定期强行同步的机制取消掉/改为从站60s(暂定)没有收到主站的数据/主动发送SEMA_REQ_DISPATCH信号过来要参数 *)
				IF pastStParam_Mailbox_proof<>0 THEN(* 证据可以访问 *)
					
					pdata1:= ADR(astStParam_Mailbox_snd[iUnitId]);
					pdata2:= ADR(pastStParam_Mailbox_proof^[iUnitId]);
					
					pdata1:= pdata1+4;
					pdata2:= pdata2+4;
					xFlag_MasterChange:= FALSE;
					iLength:= SIZEOF(astStParam_Mailbox_snd[iUnitId])-4;
					FOR iK:=1 TO iLength BY 1 DO
						IF pdata1^<>pdata2^ THEN
							xFlag_MasterChange:=TRUE;
							EXIT;
						END_IF
						pdata1:= pdata1+1;
						pdata2:= pdata2+1;						
					END_FOR
					IF 	xFlag_MasterChange THEN
						SysMemCpy(ADR(stStParam_Mailbox_Tmp),ADR(astStParam_Mailbox_snd[iUnitId]),SIZEOF(stStParam_Mailbox_Tmp));
					//	iRtn:= KS_FillUnitMailboxCmd_DN(ADR(stStParam_Mailbox_Tmp), pstStUnitParam_Save,pstStUnitParam_UnSave);
				
						SysMemSet(ADR(abyBuf_MailboxPkg_snd), 0, SIZEOF(abyBuf_MailboxPkg_snd));
						SysMemCpy(ADR(abyBuf_MailboxPkg_snd), ADR(stStParam_Mailbox_Tmp), SIZEOF(stStParam_Mailbox_Tmp));

						//SysMemCpy(ADR(abyBuf_MailboxPkg_snd), 1, SIZEOF(stStParam_Mailbox_Tmp));//2025.08.19 | TEST_
						iRtn:= GTN_RN_DevicePcMailWr(
									1,1,0,
									ADR(abyBuf_MailboxPkg_snd),
									DWORD_TO_WORD(dwOFST), 
									KS_GetNumOfDwordUsed(SIZEOF(stStParam_Mailbox_Tmp)),
									RN_AWR,
									0);
						IF iRtn<>0 THEN
							(*IF i_xRunlogEnable THEN(* 2021.12.21.132817/hdp *)
								KS_ThrowMsg2TravelLog(
									g_pstStTravelLogRec,
									LOG_LEVEL_INFO_DBG,
									'#ELSE|Failed downloading...',
									INT_TO_STRING(iRtn));
							END_IF
							*);
						ELSE
							IF pastStParam_Mailbox_proof<>0 THEN(* 更新证据 *)
								SysMemCpy(ADR(pastStParam_Mailbox_proof^[iUnitId]), ADR(stStParam_Mailbox_Tmp), SIZEOF(stStParam_Mailbox_Tmp));
							END_IF
						END_IF

						(* 只要是约定的状态之一/就更新Mailbox通讯的超时时间/2021.12.21.135901/hdp *)
						atmUnitMailboxLastSynchronized[iUnitId]:= tmCURR;
	

					ELSE(* 主站的参数一直没发生修改/超过3s从站不响应/就让从站重新请求 *)
						IF tmCURR-atmUnitMailboxLastSynchronized[iUnitId]>=TIMEOUTS_MAILBOX_FORCESYNC THEN
							pdwSEMA:= ADR(abyBuf_MailboxPkg_snd);
							IF pdwSEMA<>0 THEN
								pdwSEMA^:= SEMA_PLS_REQ_DISPATCH;
								//SysMemCpy(ADR(abyBuf_MailboxPkg_snd), 1, SIZEOF(stStParam_Mailbox_Tmp));//2025.08.19 | TEST_
								iRtn:= GTN_RN_DevicePcMailWr(
										1,1,0,
										pdwSEMA, 
										DWORD_TO_WORD(dwOFST), 
										KS_GetNumOfDwordUsed(SIZEOF(pdwSEMA^)),
										RN_AWR,
										0);
							END_IF

							(* 只要是约定的状态之一/就更新Mailbox通讯的超时时间/2021.12.21.135901/hdp *)
							atmUnitMailboxLastSynchronized[iUnitId]:= tmCURR;
						END_IF
					END_IF
				ELSE
					(* 作为存档的参考内存无法申请到/pastStProtocol_Mailbox_proof *)
					(*IF i_xRunlogEnable THEN(* 2021.12.21.133109/hdp *)
						KS_ThrowMsg2TravelLog(
							g_pstStTravelLogRec,
							LOG_LEVEL_INFO_DBG,
							'#BAD POINTER',
							'pastStProtocol_Mailbox_proof');
					END_IF
					*);
				END_IF
			END_CASE
		ELSE
			;
		END_IF
	ELSE
		;
	END_IF
END_FOR