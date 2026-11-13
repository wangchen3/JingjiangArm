(*@CES
Name=KS_FB_COMM_DIAMONDS
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=ca122bdf-6b23-47cf-8d13-4022b551bd4c
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_COMM_DIAMONDS
VAR_INPUT
	i_xEn: BOOL;
	i_xEnableHeartbeat: BOOL:= FALSE;(*启动心跳检查/组态HMI不支持*)
	i_xEnableRealtime: BOOL := FALSE;(*使能实时数据发送/组态HMI不支持*)
	i_pstStParam_Diamonds_WrRd: POINTER TO StParam_Diamonds_WrRd := 0;(*读写区域的数据首地址*)
	i_pstStParam_Diamonds_Wr: POINTER TO StParam_Diamonds_Wr := 0;(*只写区域的数据首地址*)
	i_pstStUdpOnlySendFifo: POINTER TO StUdpOnlySendFifo := 0;(*发送的实时数据fifo*)
	i_pstStHYLogFifo: POINTER TO StHYLogFifo := 0;(* 2025.8.27.154748/han.dp/增加火眼日志接口/日志可以发给金刚 *)
END_VAR
VAR_OUTPUT
	o_xEno: BOOL;(*=i_xEn*)
	o_iErNo: INT;(*当o_xEno=TRUE时,该参数返回执行的错误代码*)
	o_iCaseId: INT;(*只反馈本次调用的case分支/在o_xEno和o_iErNo有效时返回值可信*)
END_VAR
VAR
	iN: INT;
	iK: INT;
	uiN: UINT;
	iRtn: INT;
	xRtn: BOOL;
	iNum_UnSynchronizedNode: INT;(*未同步的节点数量*)
	iCaseId: INT:= RUN_CASE_ALLOCATE_MEMORY;(*分支id*)
	tmpInvocation: UINT := 0;
	dwDlen_tmp: DWORD;

	(*计数+索引*)
	iDataNodeNum_CurrCycleInserted: INT;(*2025.8.4.163915*)
	iDlen_TxPayload: INT;
	uiCurIdx_tmp: UINT;
	xLeaveLoopwhile: BOOL;
	dwResult: DWORD;

	(*ModBus读写数据区域*)
	stStDataZone_RW: StDataZone;(*读写区域*)
	uiNodeCurrIndex_RW: UINT := 0;(*读写区域的当前操作id*)
	uiInvocation_RW: UINT := 0;
	iMaxNodeNum_RW: INT;
	pstStADU_RW: POINTER TO StADU;
	xWaitResp_RW: BOOL := FALSE;


	(*ModBus只写数据区域*)
	stStDataZone_W: StDataZone;(*只写区域*)
	uiNodeCurrIndex_W: UINT := 0;(*只写区域的当前操作id*)
	uiInvocation_W: UINT := 0;
	iMaxNodeNum_W: INT;
	pstStADU_W: POINTER TO StADU;

	(*证据链列表*)
	stStProofList_: StProofList;
	xReqSend_tmp: BOOL;
	pstStADU_tmp: POINTER TO StADU;
	uiDlen_desired: UINT;(*期望的长度*)
	pstStMBAP_tmp: POINTER TO StMBAP;
	pbyFunction_tmp: POINTER TO BYTE;
	pbyByteCount_tmp: POINTER TO BYTE;

	ipUdpServer: NBS.IP_ADDR:= (sAddr:= '192.168.1.200');(*组态hmi*)
	ipUdpClient: NBS.IP_ADDR:= (sAddr:= '192.168.1.2');(*天枢ip*)
	
	hPeer_alter: CAA.HANDLE;
	hPeer_send: CAA.HANDLE;
	hPeer_heartbeat: CAA.HANDLE;

	hPeer_send_ex: CAA.HANDLE;(*只发送*)
	fbPeer_send_ex: NBS.UDP_Peer;(*发送套接字创建*)
	fbSend_send_ex: NBS.UDP_Send;(*发送套接字-发送功能*)

	fbPeer_alter: NBS.UDP_Peer;
	fbPeer_send: NBS.UDP_Peer;
	fbPeer_heartbeat: NBS.UDP_Peer;
	
	fbSend_alter: NBS.UDP_Send;
	fbReceive_alter: NBS.UDP_Receive;
	fbReceive_heartbeat: NBS.UDP_Receive;
	fbSend_send: NBS.UDP_Send;

	uiClientPort_send_ex: UINT := 9999;(*天枢客户端/发送只写报文端口*)
	uiPort_alter: UINT := 502;(*收发*)
	uiPort_heartbeat: UINT := 6060;(*收*)
	uiPort_send: UINT := 6062;(*发*)
	
	(* 日志发送功能 *)
	hPeer_sendlog: CAA.HANDLE;(* 日志发送套接字/2025.8.23.173038/han.dp *)
	fbPeer_sendlog: NBS.UDP_Peer;(* 创建日志发送套接字/2025.8.23.173038/han.dp *)
	fbSend_sendlog: NBS.UDP_Send;(* 日志套接字发送功能/2025.8.23.173038/han.dp *)
	uiPort_sendlog_cli: UINT := 9998;(* 天枢端port/2025.8.23.173038/han.dp *)
	uiPort_sendlog_srv: UINT := 6061;(* 服务器端port/2025.8.23.173038/han.dp *)
 
	abyTx: ARRAY [1..MAX_KS_UDPPKG_BYTES] OF BYTE;
	abyRx: ARRAY [1..MAX_KS_UDPPKG_BYTES] OF BYTE;
	lenRx: CAA.SIZE;
	ipRx_alter: NBS.IP_ADDR;
	portRx_alter: UINT;

	ipRx_heartbeat: NBS.IP_ADDR;
	portRx_heartbeat: UINT;
	
	dwInvocation_heartbeat: DWORD;
	pstStUdpHeartbeat: POINTER TO StUdpHeartbeat;
	xTON_offline_active: BOOL;
	fbTON_offline: TON;

	byR_tmp: BYTE;
	byW_tmp: BYTE;

	(*2025.8.5.090845/han.dp/以下内存需要动态申请/用来做chk参考的*)
	pstStParam_Diamonds_WrRd_chkref: POINTER TO StParam_Diamonds_WrRd := 0;
END_VAR
VAR CONSTANT
	RUN_CASE_ALLOCATE_MEMORY: INT := 1;(*申请内存*)
	RUN_CASE_INITIAL_MEMORY: INT := 2;(*初始化内存*)
	RUN_CASE_CONSTRUCT_SOC_HANDLE: INT := 3;(*创建socket对象阶段*)
	RUN_CASE_COMM_SOC: INT := 4;(*socket通讯阶段*)
	RUN_CASE_UPDATE_DIAMONDS_FORCED: INT := 5;(*强制更新金刚的读写数据*)
	MAX_RT_FIFO_ITEMS: INT := 10;(*每个周期可处理的最大RealTime数据报文数量上限*)

	MB_FUNC_READ_MULTI_REGS: BYTE := 3;(*读多个寄存器*)
	MB_FUNC_WRITE_MULTI_REGS: BYTE := 16;(*写多个寄存器*)
END_VAR

{IMPLEMENTATION}
o_xEno:= i_xEn;
o_iErNo:= 0;
IF i_xEn THEN
	o_iCaseId:= iCaseId;

	(*
	* 状态机
	*)
	CASE iCaseId OF
	RUN_CASE_ALLOCATE_MEMORY:(*申请内存*)
		(*申请参考内存*)
		IF pstStParam_Diamonds_WrRd_chkref=0 THEN
			pstStParam_Diamonds_WrRd_chkref:= SysMemAlloc(SIZEOF(pstStParam_Diamonds_WrRd_chkref^));
		END_IF

		(*初始化交互区域*)
		iRtn:= 
		KS_InitStZone(
			i_pstStParam_Diamonds_WrRd, 
			ADR(stStDataZone_RW),
			i_pstStParam_Diamonds_Wr, 
			ADR(stStDataZone_W));
		IF iRtn<>0 THEN
			(*如果需要处理错误返回/在这里完善*)
			;
		END_IF
		iCaseId:= RUN_CASE_INITIAL_MEMORY;

	RUN_CASE_INITIAL_MEMORY:(*初始化内存*)
		iCaseId:= RUN_CASE_CONSTRUCT_SOC_HANDLE;

	RUN_CASE_CONSTRUCT_SOC_HANDLE:(*创建socket对象阶段*)
		(*ModbusUDP交互*)
		fbPeer_alter(xEnable:= TRUE,
			ipAddr:= ipUdpClient,
			uiPort:= uiPort_alter);
		IF fbPeer_alter.xActive THEN
			hPeer_alter:= fbPeer_alter.hPeer;
		END_IF

		(*2025.7.31.191743/han.dp*)
		(*ModBusUDP的补充*)
		(*这个套接字处理只写数据/i_pstStParam_Diamonds_Wr*)
		fbPeer_send_ex(xEnable:= TRUE,
			ipAddr:= ipUdpClient,
			uiPort:= uiClientPort_send_ex);
		IF fbPeer_send_ex.xActive THEN
			hPeer_send_ex:= fbPeer_send_ex.hPeer;
		END_IF

		(*发送的套接字*)
		fbPeer_send(xEnable:= TRUE,
			ipAddr:= ipUdpClient,
			uiPort:= uiPort_send);
		IF fbPeer_send.xActive THEN
			hPeer_send:= fbPeer_send.hPeer;
		END_IF
		
		(*心跳的套接字*)
		fbPeer_heartbeat(xEnable:= TRUE,
			ipAddr:= ipUdpClient,
			uiPort:= uiPort_heartbeat);
		IF fbPeer_heartbeat.xActive THEN
			hPeer_heartbeat:= fbPeer_heartbeat.hPeer;
		END_IF
		
		(* 2025.8.27.155113/han.dp
		/ 增加_sendlog日志发送套接字端口
		*)
		fbPeer_sendlog(xEnable:= TRUE,
			ipAddr:= ipUdpClient,
			uiPort:= uiPort_sendlog_cli);
		IF fbPeer_sendlog.xActive THEN
			hPeer_sendlog:= fbPeer_sendlog.hPeer;
		END_IF
		
		IF hPeer_alter<>CAA.gc_hINVALID AND
			hPeer_send<>CAA.gc_hINVALID AND
			hPeer_send_ex<>CAA.gc_hINVALID AND
			hPeer_heartbeat<>CAA.gc_hINVALID AND
			hPeer_sendlog<>CAA.gc_hINVALID  THEN(* 2025.8.27.155204/han.dp/+/hPeer_sendlog *)
			(*通讯套接字ok以后/就进入和金刚的交互数据同步状态*)
			iCaseId:= RUN_CASE_UPDATE_DIAMONDS_FORCED;
			uiNodeCurrIndex_RW:= 0;
			uiInvocation_RW:= 0;
			xWaitResp_RW:= FALSE;(*第1次要发送/从第2次才处理响应信息*)
			KS_Reset_StZone_SynchronizedFlag(ADR(stStDataZone_RW));(*节点同步标志全部清除*)
		END_IF


	RUN_CASE_UPDATE_DIAMONDS_FORCED:(*强制更新金刚数据/读写区域的数据*)
		(*================================================================================*)
		(*2025.7.31.203443/han.dp/处理响应报文*)
		(*================================================================================*)
		IF xWaitResp_RW THEN
			(*处理响应报文*)
			FOR iN:=1 TO MAX_MB_FIFO_ITEMS*2 BY 1 DO
				(*避免响应滞后/读取的最大数量扩大至2倍的MAX_MB_FIFO_ITEMS*)
				fbReceive_alter(
					xEnable:= hPeer_alter<>CAA.gc_hINVALID,
					hPeer:= hPeer_alter,
					szSize:= MAX_KS_UDPPKG_BYTES,
					pData:= ADR(abyRx),
					ipFrom=> ipRx_alter,
					uiPortFrom=> portRx_alter,
					szCount=> lenRx);
				IF lenRx>0 THEN
					(*接收数据有效*)
					IF lenRx=12 THEN
						(*7(MBAP)+5(Function+StartingAddress+RegsQuantity)*)
						(*在检查队列中找到对应的报文/把对应的标志清除掉*)
						(*如果超过4个周期还未收到响应码/把这个数据变更uiInvocation后重新发送*)

						pstStADU_tmp:= ADR(abyRx);

						FOR iK:=1 TO MAX_MB_FIFO_ITEMS BY 1 DO(*遍历证据链列表*)
							IF stStProofList_.astStProofItem[iK].iWaitRespCycles>0 THEN(*等于0表示正在等待响应*)
								IF stStProofList_.astStProofItem[iK].stStADU.stStMBAP.uiInvocation = pstStADU_tmp^.stStMBAP.uiInvocation AND
									stStProofList_.astStProofItem[iK].stStADU.stStMBAP.uiProtocol = pstStADU_tmp^.stStMBAP.uiProtocol AND 
									pstStADU_tmp^.stStMBAP.uiLength = bswap_16(6)(*stStProofList_.astStProofItem[iK].stStADU.stStMBAP.uiLength*) AND 
									stStProofList_.astStProofItem[iK].stStADU.stStMBAP.byUnit = pstStADU_tmp^.stStMBAP.byUnit AND 
									stStProofList_.astStProofItem[iK].stStADU.stStPDU_Header.byFunction = pstStADU_tmp^.stStPDU_Header.byFunction AND 
									stStProofList_.astStProofItem[iK].stStADU.stStPDU_Header.uiAddress = pstStADU_tmp^.stStPDU_Header.uiAddress AND 
									stStProofList_.astStProofItem[iK].stStADU.stStPDU_Header.uiQuantity = pstStADU_tmp^.stStPDU_Header.uiQuantity THEN

									FOR uiN:=1 TO stStDataZone_RW.uiNodeNum BY 1 DO(*遍历节点列表*)
										IF stStDataZone_RW.astStDataNode[uiN].uiAddress=bswap_16(stStProofList_.astStProofItem[iK].stStADU.stStPDU_Header.uiAddress) AND
											stStDataZone_RW.astStDataNode[uiN].uiQuantity=bswap_16(stStProofList_.astStProofItem[iK].stStADU.stStPDU_Header.uiQuantity) THEN

											(*将这个节点设为同步状态*)
											stStDataZone_RW.astStDataNode[uiN].bySynchronized:= SINT_TO_BYTE(-1);

											(*证据链上这个节点就可以放出来了*)
											stStProofList_.astStProofItem[iK].iWaitRespCycles:= 0;
											EXIT;
										END_IF
									END_FOR
								END_IF
							END_IF
						END_FOR

					ELSE
						(*如果对非想要的响应报文感兴趣/可以在这里增加处理代码*)
						;
					END_IF
				ELSE
					EXIT;
				END_IF
			END_FOR

		ELSE
			(*让过1个周期/好先让发送执行/然后从第2个周期才有可能接收到数据*)
			xWaitResp_RW:= TRUE;

			(*清除证据链列表*)
			KS_InitStProofList(ADR(stStProofList_));

			(*将当前内存拷贝一份到_chkref区域*)
			IF pstStParam_Diamonds_WrRd_chkref<>0 AND i_pstStParam_Diamonds_WrRd<>0 THEN
				SysMemCpy(
					pstStParam_Diamonds_WrRd_chkref, 
					i_pstStParam_Diamonds_WrRd, 
					SIZEOF(i_pstStParam_Diamonds_WrRd^));
			END_IF

		END_IF


		(*================================================================================*)
		(*2025.7.31.211652/han.dp/检查所有节点的同步标志*)
		(*如果全部同步/则就可以去下一个步骤*)
		(*================================================================================*)
		iNum_UnSynchronizedNode:= KS_CheckAll_StZone_UnSynchronized(ADR(stStDataZone_RW));
		IF iNum_UnSynchronizedNode=0 THEN
			(*没有错误且全部同步了*)

			(*进入到正常通讯环节*)
			iCaseId:= RUN_CASE_COMM_SOC;

			(*清除证据链列表*)
			KS_InitStProofList(ADR(stStProofList_));

			(*复位读写数据区域的数据节点标志*)
			KS_Reset_StZone_SynchronizedFlag(ADR(stStDataZone_RW));

			uiNodeCurrIndex_RW:= 0;(*从头开始*)

			uiInvocation_RW:= 0;(*读写交互区域的id*)

			xWaitResp_RW:= FALSE;(*第1次要发送/从第2次才处理响应信息*)

			(*2025.8.4.203533/han.dp/复位心跳包的超时检查定时器*)
			fbTON_offline(IN:= FALSE);
		END_IF

		(*处理超时*)
		FOR iK:=1 TO MAX_MB_FIFO_ITEMS BY 1 DO(*遍历证据链列表*)
			IF stStProofList_.astStProofItem[iK].iWaitRespCycles>0 THEN(*非(0和255)表示正在等待响应*)
				stStProofList_.astStProofItem[iK].iWaitRespCycles:= stStProofList_.astStProofItem[iK].iWaitRespCycles+1;

				IF stStProofList_.astStProofItem[iK].iWaitRespCycles>=5 THEN(*发送的那个周期=1/=2过了25ms/../=5过了100ms*)
					(*以超时处理*)
					IF stStProofList_.astStProofItem[iK].stStADU.stStPDU_Header.byFunction=MB_FUNC_WRITE_MULTI_REGS THEN(*确认是等待写操作的响应代码*)
						FOR uiN:=1 TO stStDataZone_RW.uiNodeNum BY 1 DO(*遍历节点列表*)
							IF stStDataZone_RW.astStDataNode[uiN].uiAddress=bswap_16(stStProofList_.astStProofItem[iK].stStADU.stStPDU_Header.uiAddress) AND
								stStDataZone_RW.astStDataNode[uiN].uiQuantity=bswap_16(stStProofList_.astStProofItem[iK].stStADU.stStPDU_Header.uiQuantity) THEN

								(*这个节点超时了/就将这个节点重新放入循环队列/再处理一次*)
								IF stStDataZone_RW.astStDataNode[uiN].bySynchronized<>SINT_TO_BYTE(-1) THEN
									stStDataZone_RW.astStDataNode[uiN].bySynchronized:= 0;
								END_IF

								EXIT;
							END_IF
						END_FOR
					END_IF

					(*证据链上这个节点就可以放出来了*)
					stStProofList_.astStProofItem[iK].iWaitRespCycles:= 0;
				END_IF
			END_IF
		END_FOR


		(*================================================================================*)
		(*2025.7.31.191918/han.dp/处理发送*)
		(*================================================================================*)
		IF NOT (uiNodeCurrIndex_RW>0 AND uiNodeCurrIndex_RW<=stStDataZone_RW.uiNodeNum) THEN
			(*如果当前操作的id不在范围内/则重新开始*)
			uiNodeCurrIndex_RW:= 1;
		END_IF
		iMaxNodeNum_RW:= MIN(MAX_MB_FIFO_ITEMS, UINT_TO_INT(stStDataZone_RW.uiNodeNum));

		iDataNodeNum_CurrCycleInserted:= 0;(*当前周期插入的新数据节点数量*)
		FOR iN:=1 TO iMaxNodeNum_RW BY 1 DO
			(*开始找空位放新的报文/放的报文需要避免重复放入*)

			(*在证据链列表中找到空位来写新的报文*)
			(*按照从头开始查找*)
			IF stStProofList_.astStProofItem[iN].iWaitRespCycles=0 THEN(*0的区域是可以被写入数据的/发送后就把iWaitRespCycles+1处理/*)

				(*当前操作的数据节点位置*)
				uiCurIdx_tmp:= uiNodeCurrIndex_RW;

				FOR uiN:=1 TO stStDataZone_RW.uiNodeNum BY 1 DO(*遍历节点列表*)

					IF stStDataZone_RW.astStDataNode[uiCurIdx_tmp].bySynchronized=0 THEN(*找到未同步的节点*)

						iRtn:= 
						KS_GenTxData_(
							ADR(abyTx),
							ADR(stStDataZone_RW.astStDataNode[uiCurIdx_tmp]),
							pstStParam_Diamonds_WrRd_chkref,(*i_pstStParam_Diamonds_WrRd,这里换成也样本内存/可以保证同步的这个时刻是一份完整的/正好也省去更新_chkref*)
							uiInvocation_RW,
							MB_FUNC_WRITE_MULTI_REGS,(*写寄存器*)
							ADR(iDlen_TxPayload),
							FALSE);(*读写区域/OFST偏移0*)

						(*生成发送报文成功/且长度是ok的*)
						IF iRtn=0 AND 
							(iDlen_TxPayload>0 AND iDlen_TxPayload<=MAX_KS_UDPPKG_BYTES) THEN

							(*发送*)
							fbSend_alter(
								xExecute:= hPeer_alter<>CAA.gc_hINVALID,
								hPeer:= hPeer_alter,
								ipAddr:= ipUdpServer,
								uiPort:= uiPort_alter,
								szSize:= INT_TO_UDINT(iDlen_TxPayload),
								pData:= ADR(abyTx));
							fbSend_alter(
								xExecute:= FALSE);

							stStDataZone_RW.astStDataNode[uiCurIdx_tmp].bySynchronized:= 1;(*这个节点写入fifo*)
							iDataNodeNum_CurrCycleInserted:= iDataNodeNum_CurrCycleInserted+1;(*当前新插入的数据节点计数+1*)

							(*下一个报文的Invocation/0~65535/自然溢出/不用判断范围*)
							uiInvocation_RW:= uiInvocation_RW+1;

							(*更新证据链列表节点*)
							SysMemCpy(
								ADR(stStProofList_.astStProofItem[iN].stStADU),
								ADR(abyTx),
								SIZEOF(stStProofList_.astStProofItem[iN].stStADU));

							stStProofList_.astStProofItem[iN].iWaitRespCycles:= stStProofList_.astStProofItem[iN].iWaitRespCycles+1;
						ELSE
							(*可以考虑打印日志*)
							(*写到日志fifo中/后续可以考虑网络通讯的方式或者本地存储文件的方式记录下来*)
							;
						END_IF


						EXIT;
					END_IF

					(*下次循环的数据节点*)
					uiCurIdx_tmp:= uiCurIdx_tmp+1;
					IF uiCurIdx_tmp>stStDataZone_RW.uiNodeNum THEN
						uiCurIdx_tmp:= uiCurIdx_tmp-stStDataZone_RW.uiNodeNum;
					END_IF

				END_FOR

				(*更新数据节点位置*)
				uiNodeCurrIndex_RW:= uiCurIdx_tmp;
			END_IF

		END_FOR


	RUN_CASE_COMM_SOC:(*socket通讯阶段*)

		(*================================================================================*)
		(*和金刚的心跳交互/如果在指定的时间内未收到金刚的心跳包*)
		(*则认为金刚程序异常或者出现离线状态*)
		(*金刚端的数据就有很大可能不可信/需要由火眼系统的控制中心(天枢)重新同步一份数据到金刚上*)
		(*心跳机制如果在使用组态人机交互的时候/可以单独通过输入参数i_xEnableHeartbeat来关闭功能*)
		(*================================================================================*)
		IF i_xEnableHeartbeat THEN 
			fbReceive_heartbeat(
				xEnable:= hPeer_heartbeat<>CAA.gc_hINVALID,
				hPeer:= hPeer_heartbeat,
				szSize:= MAX_KS_UDPPKG_BYTES,
				pData:= ADR(abyRx),
				ipFrom=> ipRx_heartbeat,
				uiPortFrom=> portRx_heartbeat,
				szCount=> lenRx);
			xTON_offline_active:= TRUE;
			pstStUdpHeartbeat:= ADR(abyRx);
			IF lenRx=SIZEOF(pstStUdpHeartbeat^) THEN
				IF dwInvocation_heartbeat <> pstStUdpHeartbeat^.dwInvocation THEN
					dwInvocation_heartbeat:= pstStUdpHeartbeat^.dwInvocation;
					xTON_offline_active:= FALSE;
				END_IF
			END_IF
			fbTON_offline(
				IN:= xTON_offline_active,
				PT:= T#3S);(*3s不交互心跳/就强制同步金刚*)
			IF fbTON_offline.Q THEN
				iCaseId:= RUN_CASE_UPDATE_DIAMONDS_FORCED;
				uiNodeCurrIndex_RW:= 0;
				uiInvocation_RW:= 0;
				xWaitResp_RW:= FALSE;(*第1次要发送/从第2次才处理响应信息*)
				KS_Reset_StZone_SynchronizedFlag(ADR(stStDataZone_RW));(*节点同步标志全部清除*)
			END_IF
		END_IF


		(*================================================================================*)
		(*2025.7.31.195658/han.dp/处理双向通讯数据*)
		(*以天枢作为数据中心*)
		(*步骤:*)
		(*1.先检测本地数据是否发生修改?*)
		(*2.本地未修改就先发读请求*)
		(*3.读到的请求数据修改就更新本地*)
		(*================================================================================*)
		IF xWaitResp_RW THEN
			(*让过第1个周期/先发送/才能继续收到数据*)

			(*处理响应报文*)
			FOR iN:=1 TO MAX_MB_FIFO_ITEMS*2 BY 1 DO
				(*避免响应滞后/读取的最大数量扩大至2倍的MAX_MB_FIFO_ITEMS*)
				fbReceive_alter(
					xEnable:= hPeer_alter<>CAA.gc_hINVALID,
					hPeer:= hPeer_alter,
					szSize:= MAX_KS_UDPPKG_BYTES,
					pData:= ADR(abyRx),
					ipFrom=> ipRx_alter,
					uiPortFrom=> portRx_alter,
					szCount=> lenRx);
				IF lenRx>0 THEN
					(*接收数据有效*)

					(*写寄存器的返回值/7(MBAP)+5(Function+StartingAddress+RegsQuantity)*)
					(*读寄存器的返回值/7(MBAP)+2(Function+ByteCount)+2*RegsQuantity*)
					IF lenRx>=11 THEN(*按最小接收的有效MB报文来判断*)

						(*7(MBAP)+5(Function+StartingAddress+RegsQuantity)*)
						(*在检查队列中找到对应的报文/把对应的标志清除掉*)
						(*如果超过4个周期还未收到响应码/把这个数据变更uiInvocation后重新发送*)

						FOR iK:=1 TO MAX_MB_FIFO_ITEMS BY 1 DO(*遍历证据链列表*)
							IF stStProofList_.astStProofItem[iK].iWaitRespCycles>0 THEN(*非(0和255)表示正在等待响应*)

								CASE stStProofList_.astStProofItem[iK].stStADU.stStPDU_Header.byFunction OF
								MB_FUNC_WRITE_MULTI_REGS:(*写多个寄存器*)
									uiDlen_desired:= 7+5;
									pstStADU_tmp:= ADR(abyRx);
									IF lenRx=uiDlen_desired AND
										stStProofList_.astStProofItem[iK].stStADU.stStMBAP.uiInvocation = pstStADU_tmp^.stStMBAP.uiInvocation AND
										stStProofList_.astStProofItem[iK].stStADU.stStMBAP.uiProtocol = pstStADU_tmp^.stStMBAP.uiProtocol AND 
										pstStADU_tmp^.stStMBAP.uiLength = bswap_16(6) AND
										stStProofList_.astStProofItem[iK].stStADU.stStMBAP.byUnit = pstStADU_tmp^.stStMBAP.byUnit AND 
										stStProofList_.astStProofItem[iK].stStADU.stStPDU_Header.byFunction = pstStADU_tmp^.stStPDU_Header.byFunction AND 
										stStProofList_.astStProofItem[iK].stStADU.stStPDU_Header.uiAddress = pstStADU_tmp^.stStPDU_Header.uiAddress AND 
										stStProofList_.astStProofItem[iK].stStADU.stStPDU_Header.uiQuantity = pstStADU_tmp^.stStPDU_Header.uiQuantity THEN

										FOR uiN:=1 TO stStDataZone_RW.uiNodeNum BY 1 DO(*遍历节点列表*)
											IF stStDataZone_RW.astStDataNode[uiN].uiAddress=bswap_16(stStProofList_.astStProofItem[iK].stStADU.stStPDU_Header.uiAddress) AND
												stStDataZone_RW.astStDataNode[uiN].uiQuantity=bswap_16(stStProofList_.astStProofItem[iK].stStADU.stStPDU_Header.uiQuantity) THEN

												(*更新chk参考*)
												SysMemCpy(
													pstStParam_Diamonds_WrRd_chkref+(stStDataZone_RW.astStDataNode[uiN].uiAddress-PARAM_ZONE_ALTERNATE_OFST)*2,
													i_pstStParam_Diamonds_WrRd+(stStDataZone_RW.astStDataNode[uiN].uiAddress-PARAM_ZONE_ALTERNATE_OFST)*2,
													stStDataZone_RW.astStDataNode[uiN].uiQuantity*2);

												(*清除数据节点的写入状态*)
												IF stStDataZone_RW.astStDataNode[uiN].xWr_ing THEN
													stStDataZone_RW.astStDataNode[uiN].xWr_ing:= FALSE;
												END_IF

												EXIT;
											END_IF
										END_FOR

										(*证据链上这个节点就可以放出来了*)
										stStProofList_.astStProofItem[iK].iWaitRespCycles:= 0;
									END_IF

								MB_FUNC_READ_MULTI_REGS:(*读多个寄存器*)
									uiDlen_desired:= bswap_16(stStProofList_.astStProofItem[iK].stStADU.stStPDU_Header.uiQuantity)*2+9;
									pstStMBAP_tmp:= ADR(abyRx);
									pbyFunction_tmp:= ADR(abyRx[SIZEOF(pstStMBAP_tmp^)+1]);
									pbyByteCount_tmp:= ADR(abyRx[SIZEOF(pstStMBAP_tmp^)+SIZEOF(pbyFunction_tmp^)+1]);

									IF lenRx=uiDlen_desired AND
										stStProofList_.astStProofItem[iK].stStADU.stStMBAP.uiInvocation = pstStMBAP_tmp^.uiInvocation AND
										stStProofList_.astStProofItem[iK].stStADU.stStMBAP.uiProtocol = pstStMBAP_tmp^.uiProtocol AND 
										pstStADU_tmp^.stStMBAP.uiLength = bswap_16(uiDlen_desired-6) AND(*-6(uiInvocation+uiProtocol+uiLength)*)
										stStProofList_.astStProofItem[iK].stStADU.stStMBAP.byUnit = pstStMBAP_tmp^.byUnit AND 
										stStProofList_.astStProofItem[iK].stStADU.stStPDU_Header.byFunction = (pbyFunction_tmp^) AND 
										bswap_16(stStProofList_.astStProofItem[iK].stStADU.stStPDU_Header.uiQuantity)*2 = BYTE_TO_UINT(pbyByteCount_tmp^) THEN

										FOR uiN:=1 TO stStDataZone_RW.uiNodeNum BY 1 DO(*遍历节点列表*)
											IF stStDataZone_RW.astStDataNode[uiN].uiAddress=bswap_16(stStProofList_.astStProofItem[iK].stStADU.stStPDU_Header.uiAddress) AND
												stStDataZone_RW.astStDataNode[uiN].uiQuantity=bswap_16(stStProofList_.astStProofItem[iK].stStADU.stStPDU_Header.uiQuantity) THEN

												(*更新本地内存*)
												SysMemCpy(
													i_pstStParam_Diamonds_WrRd+(stStDataZone_RW.astStDataNode[uiN].uiAddress-PARAM_ZONE_ALTERNATE_OFST)*2,
													ADR(abyRx[SIZEOF(pstStMBAP_tmp^)+SIZEOF(pbyFunction_tmp^)+2]),
													stStDataZone_RW.astStDataNode[uiN].uiQuantity*2);

												(*更新chk参考*)
												SysMemCpy(
													pstStParam_Diamonds_WrRd_chkref+(stStDataZone_RW.astStDataNode[uiN].uiAddress-PARAM_ZONE_ALTERNATE_OFST)*2,
													ADR(abyRx[SIZEOF(pstStMBAP_tmp^)+SIZEOF(pbyFunction_tmp^)+2]),
													stStDataZone_RW.astStDataNode[uiN].uiQuantity*2);

												(*清除数据节点的读取状态*)
												IF stStDataZone_RW.astStDataNode[uiN].xRd_ing THEN
													stStDataZone_RW.astStDataNode[uiN].xRd_ing:= FALSE;
												END_IF
				
												EXIT;
											END_IF
										END_FOR

										(*证据链上这个节点就可以放出来了*)
										stStProofList_.astStProofItem[iK].iWaitRespCycles:= 0;
									END_IF

								ELSE;
								END_CASE

							END_IF
						END_FOR

					ELSE
						(*如果对非想要的响应报文感兴趣/可以在这里增加处理代码*)
						;
					END_IF
				ELSE
					(*无有效数据接收到/就结束循环*)
					EXIT;
				END_IF
			END_FOR

		ELSE
			xWaitResp_RW:= TRUE;
		END_IF


		(*================================================================================*)
		(*处理超时/找到对应的内容/把xRd_ing/xWr_ing复位*)
		(*================================================================================*)
		FOR iK:=1 TO MAX_MB_FIFO_ITEMS BY 1 DO(*遍历证据链列表*)
			IF stStProofList_.astStProofItem[iK].iWaitRespCycles>0 THEN(*非(0和255)表示正在等待响应*)
				stStProofList_.astStProofItem[iK].iWaitRespCycles:= stStProofList_.astStProofItem[iK].iWaitRespCycles+1;

				IF stStProofList_.astStProofItem[iK].iWaitRespCycles>=5 THEN(*发送的那个周期=1/=2过了25ms/../=5过了100ms*)
					FOR uiN:=1 TO stStDataZone_RW.uiNodeNum BY 1 DO(*遍历节点列表*)
						IF stStDataZone_RW.astStDataNode[uiN].uiAddress=bswap_16(stStProofList_.astStProofItem[iK].stStADU.stStPDU_Header.uiAddress) AND
							stStDataZone_RW.astStDataNode[uiN].uiQuantity=bswap_16(stStProofList_.astStProofItem[iK].stStADU.stStPDU_Header.uiQuantity) THEN

							IF stStDataZone_RW.astStDataNode[uiN].xRd_ing THEN
								stStDataZone_RW.astStDataNode[uiN].xRd_ing:= FALSE;
							END_IF

							IF stStDataZone_RW.astStDataNode[uiN].xWr_ing THEN
								stStDataZone_RW.astStDataNode[uiN].xWr_ing:= FALSE;
							END_IF

							EXIT;
						END_IF
					END_FOR

					(*证据链上这个节点就可以放出来了*)
					stStProofList_.astStProofItem[iK].iWaitRespCycles:= 0;
				END_IF
			END_IF
		END_FOR


		(*================================================================================*)
		(*处理数据通讯*)
		(*================================================================================*)
		IF NOT (uiNodeCurrIndex_RW>0 AND uiNodeCurrIndex_RW<=stStDataZone_RW.uiNodeNum) THEN
			(*如果当前操作的id不在范围内/则重新开始*)
			uiNodeCurrIndex_RW:= 1;
		END_IF
		iMaxNodeNum_RW:= MIN(MAX_MB_FIFO_ITEMS, UINT_TO_INT(stStDataZone_RW.uiNodeNum));


		(*在列表中找到空闲的位置写入新的mb报文*)
		FOR iK:=1 TO MAX_MB_FIFO_ITEMS BY 1 DO
			IF stStProofList_.astStProofItem[iK].iWaitRespCycles=0 THEN(*找到空位*)

				(*处理数据节点从上次的位置开始循环*)
				uiCurIdx_tmp:= uiNodeCurrIndex_RW;

				(*开始从节点列表中找没有处于发送和等待读取的节点/写入新的请求*)
				xLeaveLoopwhile:= FALSE;
				FOR uiN:=1 TO stStDataZone_RW.uiNodeNum BY 1 DO(*遍历节点列表*)

					IF stStDataZone_RW.astStDataNode[uiCurIdx_tmp].xRd_ing OR 
						stStDataZone_RW.astStDataNode[uiCurIdx_tmp].xWr_ing THEN;
					ELSE
						(*只处理没有操作的区域*)
						(*先比对样本和实际数据有无变化*)
						dwResult:= 
						SysMemCmp(
							i_pstStParam_Diamonds_WrRd+(stStDataZone_RW.astStDataNode[uiCurIdx_tmp].uiAddress-PARAM_ZONE_ALTERNATE_OFST)*2,
							pstStParam_Diamonds_WrRd_chkref+(stStDataZone_RW.astStDataNode[uiCurIdx_tmp].uiAddress-PARAM_ZONE_ALTERNATE_OFST)*2,
							stStDataZone_RW.astStDataNode[uiCurIdx_tmp].uiQuantity*2);

						IF dwResult<>0 THEN
							(*写操作*)
							iRtn:= 
							KS_GenTxData_(
								ADR(abyTx),
								ADR(stStDataZone_RW.astStDataNode[uiCurIdx_tmp]),
								i_pstStParam_Diamonds_WrRd,(*i_pstStParam_Diamonds_WrRd,这里换成也样本内存/可以保证同步的这个时刻是一份完整的/正好也省去更新_chkref*)
								uiInvocation_RW,
								MB_FUNC_WRITE_MULTI_REGS,(*写寄存器*)
								ADR(iDlen_TxPayload),
								FALSE);(*读写区域/OFST偏移0*)
						ELSE
							(*读操作*)
							iRtn:= 
							KS_GenTxData_(
								ADR(abyTx),
								ADR(stStDataZone_RW.astStDataNode[uiCurIdx_tmp]),
								i_pstStParam_Diamonds_WrRd,(*i_pstStParam_Diamonds_WrRd,这里换成也样本内存/可以保证同步的这个时刻是一份完整的/正好也省去更新_chkref*)
								uiInvocation_RW,
								MB_FUNC_READ_MULTI_REGS,(*读寄存器*)
								ADR(iDlen_TxPayload),
								FALSE);(*读写区域/OFST偏移0*)
						END_IF

						(*生成发送报文成功/且长度是ok的*)
						IF iRtn=0 AND 
							(iDlen_TxPayload>0 AND iDlen_TxPayload<=MAX_KS_UDPPKG_BYTES) THEN

							(*发送*)
							fbSend_alter(
								xExecute:= hPeer_alter<>CAA.gc_hINVALID,
								hPeer:= hPeer_alter,
								ipAddr:= ipUdpServer,
								uiPort:= uiPort_alter,
								szSize:= INT_TO_UDINT(iDlen_TxPayload),
								pData:= ADR(abyTx));
							fbSend_alter(
								xExecute:= FALSE);

							IF dwResult<>0 THEN
								stStDataZone_RW.astStDataNode[uiCurIdx_tmp].xWr_ing:= TRUE;
							ELSE
								stStDataZone_RW.astStDataNode[uiCurIdx_tmp].xRd_ing:= TRUE;
							END_IF

(*							stStDataZone_RW.astStDataNode[uiCurIdx_tmp].bySynchronized:= 1;(*这个节点写入fifo*)
							iDataNodeNum_CurrCycleInserted:= iDataNodeNum_CurrCycleInserted+1;(*当前新插入的数据节点计数+1*)
*)
							(*下一个报文的Invocation/0~65535/自然溢出/不用判断范围*)
							uiInvocation_RW:= uiInvocation_RW+1;

							(*更新证据链列表节点*)
							SysMemCpy(
								ADR(stStProofList_.astStProofItem[iK].stStADU),
								ADR(abyTx),
								SIZEOF(stStProofList_.astStProofItem[iK].stStADU));

							stStProofList_.astStProofItem[iK].iWaitRespCycles:= stStProofList_.astStProofItem[iK].iWaitRespCycles+1;

							xLeaveLoopwhile:= TRUE;
						ELSE
							(*错误看是否要记录到日志或者做其它处理*)
							(*在这里增加代码*)
							;
						END_IF
					END_IF

					uiCurIdx_tmp:= uiCurIdx_tmp+1;
					IF uiCurIdx_tmp>stStDataZone_RW.uiNodeNum THEN
						uiCurIdx_tmp:= uiCurIdx_tmp-stStDataZone_RW.uiNodeNum;
					END_IF

					(*操作了位置后/再判断是否要离开for*)
					IF xLeaveLoopwhile THEN
						EXIT;
					END_IF
				END_FOR
				uiNodeCurrIndex_RW:= uiCurIdx_tmp;
			ELSE
				(*没有找到空位*)
				;
			END_IF
		END_FOR


		(*================================================================================*)
		(*2025.7.31.191918/han.dp/处理只写的数据/不读取返回值*)
		(*证据链列表只能应用于双向通讯*)
		(*================================================================================*)
		IF NOT (uiNodeCurrIndex_W>0 AND uiNodeCurrIndex_W<=stStDataZone_W.uiNodeNum) THEN
			(*如果当前操作的id不在范围内/则重新开始*)
			uiNodeCurrIndex_W:= 1;
		END_IF
		iMaxNodeNum_W:= MIN(MAX_MB_FIFO_ITEMS, UINT_TO_INT(stStDataZone_W.uiNodeNum));

		FOR iN:=1 TO iMaxNodeNum_W BY 1 DO

			(*整合生成要发送的报文*)
			iRtn:= 
			KS_GenTxData_(
				ADR(abyTx),
				ADR(stStDataZone_W.astStDataNode[uiNodeCurrIndex_W]),
				i_pstStParam_Diamonds_Wr,
				uiInvocation_W,
				MB_FUNC_WRITE_MULTI_REGS,(*写寄存器*)
				ADR(iDlen_TxPayload),
				TRUE);(*只写区域/OFST偏移16384*)

			(*生成发送报文成功/且长度是ok的*)
			IF iRtn=0 AND 
				(iDlen_TxPayload>0 AND iDlen_TxPayload<=MAX_KS_UDPPKG_BYTES) THEN

				(*发送*)
				fbSend_send_ex(
					xExecute:= hPeer_send_ex<>CAA.gc_hINVALID,
					hPeer:= hPeer_send_ex,
					ipAddr:= ipUdpServer,
					uiPort:= uiPort_alter,
					szSize:= INT_TO_UDINT(iDlen_TxPayload),
					pData:= ADR(abyTx));
				fbSend_send_ex(
					xExecute:= FALSE);

				stStDataZone_W.astStDataNode[uiNodeCurrIndex_W].bySynchronized:= 1;(*这个节点写入fifo*)
				iDataNodeNum_CurrCycleInserted:= iDataNodeNum_CurrCycleInserted+1;(*当前新插入的数据节点计数+1*)

				(*下一个报文的Invocation/0~65535/自然溢出/不用判断范围*)
				uiInvocation_W:= uiInvocation_W+1;

				(*下次循环的节点*)
				uiNodeCurrIndex_W:= uiNodeCurrIndex_W+1;
				IF uiNodeCurrIndex_W>stStDataZone_W.uiNodeNum THEN
					uiNodeCurrIndex_W:= uiNodeCurrIndex_W-stStDataZone_W.uiNodeNum;
				END_IF

			ELSE
				(*可以考虑打印日志*)
				(*写到日志fifo中/后续可以考虑网络通讯的方式或者本地存储文件的方式记录下来*)
				;
			END_IF
		END_FOR


		(*================================================================================*)
		(*实时数据发送/这个通讯和标准ModBus不兼容*)
		(*检查fifo是否有数据要发送/主要是实时的监控信息/文件数据等*)
		(*如果采用组态方案/请将输入参数i_xEnableRealtime置FALSE即可关闭该部分*)
		(*================================================================================*)
		IF i_xEnableRealtime THEN
			IF i_pstStUdpOnlySendFifo<>0 THEN
				byR_tmp:= i_pstStUdpOnlySendFifo^.byR;
				byW_tmp:= i_pstStUdpOnlySendFifo^.byW;

				iN:= 0;(*此处用iN作为计数变量*)
				WHILE (byR_tmp<>byW_tmp) AND (iN<MAX_RT_FIFO_ITEMS) DO(*循环到结束或者最大单次处理的上限就停*)
					(*发送*)
					fbSend_send(
						xExecute:= hPeer_send<>CAA.gc_hINVALID,
						hPeer:= hPeer_send,
						ipAddr:= ipUdpServer,
						uiPort:= uiPort_send,
						szSize:= i_pstStUdpOnlySendFifo^.astStUdpOnlySend[byR_tmp].uiDlen+4,
						pData:= ADR(i_pstStUdpOnlySendFifo^.astStUdpOnlySend[byR_tmp]));
					fbSend_send(
						xExecute:= FALSE);
				
					(*处理索引*)
					byR_tmp:= byR_tmp+1;(*下次要读取的位置*)
					iN:= iN+1;(*已处理的fifo数量*)
				END_WHILE
				
				(*更新下次读的索引值*)
				i_pstStUdpOnlySendFifo^.byR:= byR_tmp;

			END_IF
		END_IF

	ELSE;
	END_CASE
	
	
	(* 2025.8.27.155412/han.dp
	/ 在如下两种情况将日志Fifo的内容发出去
	*)
	IF iCaseId=RUN_CASE_UPDATE_DIAMONDS_FORCED OR
		iCaseId=RUN_CASE_COMM_SOC THEN
		IF i_pstStHYLogFifo<>0 THEN
			byR_tmp:= i_pstStHYLogFifo^.byIdxR;
			byW_tmp:= i_pstStHYLogFifo^.byIdxW;
			WHILE byR_tmp<>byW_tmp DO
				(*发送*)
				fbSend_sendlog(
					xExecute:= hPeer_sendlog<>CAA.gc_hINVALID,
					hPeer:= hPeer_sendlog,
					ipAddr:= ipUdpServer,
					uiPort:= uiPort_sendlog_srv,
					szSize:= LEN(i_pstStHYLogFifo^.astStHYLogItem[byR_tmp].sDetails),
					pData:= ADR(i_pstStHYLogFifo^.astStHYLogItem[byR_tmp].sDetails));
				fbSend_sendlog(
					xExecute:= FALSE);

				byR_tmp:= byR_tmp+1;
			END_WHILE
			i_pstStHYLogFifo^.byIdxR:= byR_tmp;
		END_IF
	END_IF
	
ELSE
(* 先放弃释放/该功能块暂时不会调用i_xEn=FALSE的情况
	IF pstStParam_Diamonds_WrRd_chkref<>0 THEN
		SysMemFree(pstStParam_Diamonds_WrRd_chkref, SIZEOF(pstStParam_Diamonds_WrRd_chkref^));
		pstStParam_Diamonds_WrRd_chkref:= 0;
	END_IF
*)
	IF iCaseId<>RUN_CASE_ALLOCATE_MEMORY THEN
		iCaseId:= RUN_CASE_ALLOCATE_MEMORY;
	END_IF
END_IF
