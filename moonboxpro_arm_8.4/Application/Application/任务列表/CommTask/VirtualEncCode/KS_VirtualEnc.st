(*@CES
Name=KS_VirtualEnc
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=5627e767-02e8-4aa3-9f8c-fcee9956db26
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_VirtualEnc :  INT(*虚拟码盘异站输出处理|错误码-1 没有合适源轴号
														-2 手动的目标轴号不存在
														-3 自动找到的轴号非法
														-4 源站号和目标站号相同
														-5 源轴的虚拟码盘未同步
														-6 目标站ehmi未打开*)

VAR_INPUT
	i_xWrEn:BOOL;(*异站虚拟码盘参数写入使能|参数变化了可以进行写入动作*)
	i_pxReSetEncCfg:POINTER TO BOOL;(*重新设置异站编码器函数|在返回错误时候使用*)
	i_byGrpId:INT;(*系id*)
	i_xIsDualUwRw:BOOL;(*是否双收双放机型*)
	i_xAsOneMachine:BOOL;(*作为一台机器使用*)
	i_iAxisIdManu:BYTE;(*手动输入的虚拟码盘目标输出轴号*)
	i_iGrpAxisNum_Pu: INT;(*色组轴*)
	i_paiGrpAxisList: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF INT;(*轴列表|有排序规则|*)
	i_pstStSysParam: POINTER TO StSysParam;(*系统参数*)
	//i_pastStPTSts: POINTER TO ARRAY [1..MAX_STATION_NUM] OF StPTSts;(*PT运动轴信息地址|2020.11.3.153017增加*)
	i_pstStVirtualParamBak:POINTER TO StVirtualParam;(*异站输出虚拟码盘参数备份|用来检查是否发生了变化*)
	i_piAxisId_Src:POINTER TO INT;(*目标轴号*)
	i_piAxisId_Des:POINTER TO INT;(*目标轴号*)
	(*2020.11.10.091558 增加了返回*)
	i_puiSetEncCfgCnt:POINTER TO UINT;(*设置异站虚拟码盘函数的执行的次数计数值*)
	i_piSetEncCfgRtn:POINTER TO INT;(*设置异站虚拟码盘函数错误返回值*)
	(*获取ehmi是否打开信息*)
	//i_pstStPTStsFields_Repacked: POINTER TO StPTStsFields_Repacked := 0;
END_VAR
VAR
	//aiGrpAxisList_Valid: ARRAY [1..MAX_UNIT_NUM] OF INT;(*新的轴列表|所有轴都有对应站存在*)
	stStVirtualParam:StVirtualParam;(*异站输出虚拟码盘参数*)
	pstStUnitParam_Save: POINTER TO StUnitParam_Save;(*轴参数*)
	pstStUnitParam_UnSave: POINTER TO StUnitParam_UnSave;(*轴参数*)
	iAxisId_Src: INT;
	iAxisId_Des: INT;
	iStationId_Src: INT;
	iStationId_Des: INT;
	iErrCode: INT;
	uiDircRev_Des: UINT;(*根据源站号轴的旋转方向决定控制目标轴是否需要进行取反。|*)
	iAxisTotalNum: INT;
	xVirtualSync_Src: BOOL;(*源虚拟码盘同步了*)
	iRtn: INT;(*函数执行返回*)
	xSetRemoteVirtualEnc: BOOL;
	xReSetEncCfg: BOOL;
END_VAR

{IMPLEMENTATION}

IF i_pxReSetEncCfg<>0 THEN
	xReSetEncCfg:=i_pxReSetEncCfg^;
END_IF
// 
// (*生成新的对应列表|所有轴对应的站都有效|没有实际站的轴必须写-1*)
// iAxisTotalNum:=KS_CreatAxisList(
// 					i_iGrpAxisTotalNum,
// 					i_paiGrpAxisList,
// 					i_pstStSysParam,
// 					ADR(aiGrpAxisList_Valid));
// 					
iAxisTotalNum := i_iGrpAxisNum_Pu;

(*得到源站号和目标站号*)
iErrCode:=KS_GetStationId_Src_Des(
				i_byGrpId(*i_byGrpId*),
				i_xIsDualUwRw(*i_xIsDualUwRw*),
				i_xAsOneMachine(*i_xAsOneMachine*),
				i_iAxisIdManu(*i_iAxisIdManu*),
				iAxisTotalNum(*i_iGrpAxisTotalNum*),
				(i_paiGrpAxisList)(*i_paiGrpAxisList*),
				i_pstStSysParam,
				ADR(iAxisId_Src)(*i_piAxisId_Src*),
				ADR(iAxisId_Des)(*i_piAxisId_Des*),
				ADR(iStationId_Src)(*i_piStationId_Src*),
				ADR(iStationId_Des)(*i_piStationId_Des*));

IF i_pstStSysParam<>0 AND
	//i_paiGrpAxisList<>0 AND
	//i_pastStPTSts<>0 AND
	(i_byGrpId=1 OR i_byGrpId=2) THEN
	(*2025.12.1.154349 站号扩展到USER_MAX_STATION_NUM_V1*)
	IF iStationId_Src>=0 AND iStationId_Src<USER_MAX_STATION_NUM_V1(*MAX_STATION_NUM*) AND(*站号合法|*)
		iStationId_Des>=0 AND iStationId_Des<USER_MAX_STATION_NUM_V1(*MAX_STATION_NUM*) AND
		iAxisId_Src>0 AND iAxisId_Src<=MAX_UNIT_NUM AND(*轴号合法|*)
		iAxisId_Des>0 AND iAxisId_Des<=MAX_UNIT_NUM  AND
		i_iAxisIdManu<=MAX_UNIT_NUM THEN(*轴号小于MAX_STATION_NUM的时候我们打开该功能*)
(*		IF iAxisId_Src<>iAxisId_Des THEN(*源轴号和目标轴号是同一个*)*)

			pstStUnitParam_Save:=ADR(i_pstStSysParam^.astStUnitParam_Save[iAxisId_Src]);
			pstStUnitParam_UnSave:=ADR(i_pstStSysParam^.astStUnitParam_UnSave[iAxisId_Src]);

			(*不调整的电机，或者原计划出虚拟码盘站的电机规划脉冲，现在默认为2^21;*)
			stStVirtualParam.srcPfrMotorPulse:=LREAL_TO_UDINT(GC_LRMOTORPPR);

			(*结构体中的减速比命名写反了*)
			(*不调整的电机，或者原计划出虚拟码盘站的电机侧速比;*)
			stStVirtualParam.srcPfrPrinterN:=UINT_TO_UDINT(pstStUnitParam_Save^.uiNum_Sam);(*电机侧减速比*)
			(*不调整的电机，或者原计划出虚拟码盘站的印刷侧速比;*)
			stStVirtualParam.srcPfrMotorM:=UINT_TO_UDINT(pstStUnitParam_Save^.uiDen_Sam);(*印刷侧减速比*)
			(*不调整的电机，或者原计划出虚拟码盘的站站的站号;*)
			stStVirtualParam.srcPfrId:=INT_TO_UDINT(iStationId_Src);
			(*可以出虚拟码盘的站点，参考该站点的虚拟码盘值为绝对值*)
			stStVirtualParam.srcVirtualId:=INT_TO_UDINT(iStationId_Src);
			(*源站点输出虚拟码盘的点数*)
			stStVirtualParam.srcVirtualPanPoint:=INT_TO_UDINT(gc_iVirEncPPR);

			(*目标站点输出虚拟码盘的点数*)
			stStVirtualParam.desVirtualPanPoint:=INT_TO_UDINT(gc_iVirEncPPR);
			(*目标站点ID*)
			stStVirtualParam.desId:=INT_TO_UDINT(iStationId_Des);
			(*输出AB脉冲是否需要取反,bit8要根据源轴号电机正反转赋值，电机正转0，电机反转1*)
			uiDircRev_Des:=0;
			uiDircRev_Des.8:=FALSE;
			stStVirtualParam.desDircReverse:=UINT_TO_UDINT(uiDircRev_Des);


			(*虚拟码盘同步标志|同步后才能进行异站设置*)
			//xVirtualSync_Src:=i_pastStPTSts^[iAxisId_Src].virtualSts.12;
// 			xVirtualSync_Src:=TRUE;(*2022.9.15.182249 取消检查源站的虚拟码盘同步|2022.9.15.182347*)
// 			IF NOT xVirtualSync_Src THEN(*未同步则报错*)
// 				iErrCode:=-5;
// 				(*2020.11.12.104747-如果同步标志因为采样配置被复位了
// 				我们清零备份数据，这样在正常之后可以再进行一次参数配置*)
// 				IF i_pstStVirtualParamBak<>0 THEN
// 					SysMemSet(i_pstStVirtualParamBak,0,SIZEOF(i_pstStVirtualParamBak));
// 				END_IF
// 			ELSIF NOT KS_CheckEhmiSts(iStationId_Des, i_pstStPTStsFields_Repacked,0) THEN(*检查ehmi是否被打开*)
// 				iErrCode:=-6;
// 				IF i_pstStVirtualParamBak<>0 THEN
// 					SysMemSet(i_pstStVirtualParamBak,0,SIZEOF(i_pstStVirtualParamBak));
// 				END_IF
// 			ELSE
				(*执行指令写入虚拟码盘参数|参数发生变化了写入*)
				IF i_pstStVirtualParamBak<>0 THEN
					IF i_xWrEn THEN
(*						IF SysMemCmp(ADR(stStVirtualParam),i_pstStVirtualParamBak,SIZEOF(stStVirtualParam))<>0 OR(*发生了变化了*)*)
						IF stStVirtualParam.srcPfrId <> i_pstStVirtualParamBak^.srcPfrId OR
							stStVirtualParam.desId <> i_pstStVirtualParamBak^.desId OR
							stStVirtualParam.srcPfrMotorPulse <> i_pstStVirtualParamBak^.srcPfrMotorPulse OR
							xReSetEncCfg THEN(*重新设置*)
(*							iRtn:=GT_RN_SampleSetVitualEncCfg(ADR(stStVirtualParam));*)
							xSetRemoteVirtualEnc:=TRUE;
							(*复位所有站的码盘输出使能|*)
							(*iRtn:=KS_RemoteVirtualEncDisEn(iAxisTotalNum, ADR(aiGrpAxisList_Valid), i_pastStAxisParam,i_pstStPTStsFields_Repacked);*)

							(*2025.9.8.082647 优化为只关闭之前异站的源和目标*)
							IF NOT xReSetEncCfg THEN(*重新设置则不需要关闭吧*)
								IF i_pstStVirtualParamBak^.srcPfrMotorPulse<>0 THEN(*用来标记之前已经设置过异站*)
									iRtn:=
										GTN_RN_SampleCfgRemoteVirtualEnc(
											cardIndex:= 1, 
											des_id:= UDINT_TO_BYTE(i_pstStVirtualParamBak^.desId),//INT_TO_BYTE(iStationId_Des), 
											virtual_enc_src_id:= UDINT_TO_BYTE(i_pstStVirtualParamBak^.srcPfrId),//INT_TO_BYTE(iStationId_Src), 
											virtualPanPoint:= INT_TO_UINT(gc_iVirEncPPR), 
											remote_enc_reverse:= 0, 
											enable:= 0);
								END_IF
							END_IF

							IF iStationId_Des=iStationId_Src THEN;
							ELSE(*源和目标不同需要配置*)
								iRtn:=
									GTN_RN_SampleCfgRemoteVirtualEnc(
										cardIndex:= 1, 
										des_id:= INT_TO_BYTE(iStationId_Des), 
										virtual_enc_src_id:= INT_TO_BYTE(iStationId_Src), 
										virtualPanPoint:= INT_TO_UINT(gc_iVirEncPPR), 
										remote_enc_reverse:= 0, 
										enable:= 1);

							END_IF
							i_pstStVirtualParamBak^:=stStVirtualParam;
							(*2020.11.10.091649 增加了函数执行次数计数值*)
							IF i_puiSetEncCfgCnt<>0 THEN
								i_puiSetEncCfgCnt^:=i_puiSetEncCfgCnt^+1;
							END_IF
						END_IF
					END_IF
				END_IF
			//END_IF
(*
		ELSE(*源轴号和目标轴号一致*)
			iErrCode:=-4;
		END_IF
*)
	ELSE(*2022.9.7.213855 在源站号或者目标站号非法的时候|清除备份的参数值*)
		iAxisId_Src:=-1;
		iAxisId_Des:=-1;
		IF i_pstStVirtualParamBak<>0 THEN
			IF i_pstStVirtualParamBak^.srcPfrMotorPulse<>0 OR(*码盘脉冲非零|说明执行了异站设置*)
				i_pstStVirtualParamBak^.srcPfrPrinterN<>0 THEN(*减速比不为0|说明执行了异站设置*)
				(*说明执行了异站设置|复位驱动器为本地输出|同时清除备份值*)
				(*iRtn:=KS_RemoteVirtualEncDisEn(iAxisTotalNum, ADR(aiGrpAxisList_Valid), i_pastStAxisParam,i_pstStPTStsFields_Repacked);*)
				(*昨天处理的内容遗留这部分处理@2025.9.9.084256+*)
				(*2025.9.8.082647 优化为只关闭之前异站的源和目标*)
				iRtn:=
					GTN_RN_SampleCfgRemoteVirtualEnc(
						cardIndex:= 1, 
						des_id:= UDINT_TO_BYTE(i_pstStVirtualParamBak^.desId),//INT_TO_BYTE(iStationId_Des), 
						virtual_enc_src_id:= UDINT_TO_BYTE(i_pstStVirtualParamBak^.srcPfrId),//INT_TO_BYTE(iStationId_Src),
						virtualPanPoint:= INT_TO_UINT(gc_iVirEncPPR), 
						remote_enc_reverse:= 0, 
						enable:= 0);
				(*2026.09.04.142530 |+|只清了4个字节，会一直执行*)
				(*SysMemSet(i_pstStVirtualParamBak,0,SIZEOF(i_pstStVirtualParamBak));*)
				SysMemSet(i_pstStVirtualParamBak,0,SIZEOF(i_pstStVirtualParamBak^));
			END_IF
		END_IF
		(*2023.3.7.173333*)
		IF i_iAxisIdManu>MAX_UNIT_NUM THEN(*关闭了功能@清除报警输出*)
			iErrCode:=0;
		END_IF
	END_IF
END_IF

(*将源轴号输出*)
IF i_piAxisId_Src<>0 THEN
	i_piAxisId_Src^:=iAxisId_Src;
END_IF
(*将目标轴号输出*)
IF i_piAxisId_Des<>0 THEN
	i_piAxisId_Des^:=iAxisId_Des;
END_IF

IF xSetRemoteVirtualEnc THEN
	IF i_piSetEncCfgRtn<>0 THEN
		i_piSetEncCfgRtn^:=iRtn;(*函数返回失败|输出返回码*)
	END_IF
END_IF

xReSetEncCfg:=FALSE;(*清除标志*)
IF i_pxReSetEncCfg<>0 THEN
	i_pxReSetEncCfg^:=xReSetEncCfg;
END_IF
KS_VirtualEnc:=iErrCode;