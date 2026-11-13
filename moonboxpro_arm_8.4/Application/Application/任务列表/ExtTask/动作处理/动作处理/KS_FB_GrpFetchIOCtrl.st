(*@CES
Name=KS_FB_GrpFetchIOCtrl
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=a7ec576d-c0a8-4898-9e79-82769fd09b46
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_GrpFetchIOCtrl
VAR_INPUT
	i_xEn: BOOL;
	i_iGrpId: INT;
	i_pstStEvtReq: POINTER TO StEvtReq; (* 沿触发标志 *)		
	i_pstStSysCfgStruct: POINTER TO StSysCfgStruct;		
	i_pastStIOMap_Main_FE						: POINTER TO ARRAY [1..4] OF StIOMap_Main_FE;(*轴io数据区域|AB系*)
	i_pastStIOMap_Axis_FE					: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF StIOMap_Axis_FE;(*轴io数据区域|`````````````````````````````````````````````*)
	i_pastStIOMap_Axis_Extra_FE				: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF StIOMap_Axis_Extra_FE;
	i_pastStIOMap_UwRw_FE_Uw					: POINTER TO ARRAY [1..2] OF StIOMap_UwRw_FE;(*轴io数据区域|AB系*)
	i_pastStIOMap_UwRw_FE_Rw					: POINTER TO ARRAY [1..2] OF StIOMap_UwRw_FE;(*轴io数据区域|AB系*)
	
	i_iUMax: INT;(*最大色组*)
	i_dwEquipmentProf: DWORD;(*机型：bit20:双收双放bit21:A放B收*)
	i_xUseRealStationOnRingnet: BOOL;(*使用真实站点*)
	i_axLinkage: ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	i_axThisUnitEna: ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	i_axSwitchOn_CoatingPrn: ARRAY [1..MAX_UNIT_NUM] OF BOOL;

	i_xIsValid_If_I: BOOL;
	i_xIsValid_If_II: BOOL;
	i_xIsValid_Of_I: BOOL;
	i_xIsValid_Of_II: BOOL;
//	i_pstStRingInfVer1: POINTER TO StRingInfVer1; (* 所有站点列表 *)

	//2026.5.20.133000 by liu.yt 使用map生成的系统站信息列表@根据实际站生成
	//i_pstStStationInfo_KS: POINTER TO StStationInfo_KS;
	(*输出列表*)
	i_pstStSysStationInf	: POINTER TO StSysStationInf;
	i_pxInit_StationList	: POINTER TO BOOL;
	
END_VAR
VAR_OUTPUT
	o_xEn: BOOL;
	o_iErNo: INT;
	o_iGrpAxisNum_Pu: INT; (* 系的色组数量|色组按照从小到大排序了 *)
	o_iGrpAxisTotalNum: INT; (* 系的轴数量 *)
	o_aiGrpAxisList: ARRAY [1..MAX_UNIT_NUM] OF INT; (* 系的轴列表 *)
	o_iIOGrpIdx_Uw: INT; (* 放料id *)
	o_iIOGrpIdx_Rw: INT; (* 收料id *)
	o_iAxisId_If_IOMapUse: INT; (* 放牵轴id *)
	o_iAxisId_Of_IOMapUse: INT; (* 收牵轴id *)
	o_aiGrpServoAxisList_Uw: ARRAY [1..2] OF INT := [2(-1)]; (* 2021.5.7.150202/目前仅支持双工位/[1]放置A轴/[2]放置B轴/轴id(-1)表无效 *)
	o_aiGrpServoAxisList_Rw: ARRAY [1..2] OF INT := [2(-1)]; (* 2021.5.7.150202/目前仅支持双工位/[1]放置A轴/[2]放置B轴/轴id(-1)表无效 *)

	(*2022.5.25.103645 增加联动轴*)
	o_iGrpLinkageAxisNum_Pu: INT; (* 系的色组联动轴数量|色组按照从小到大排序了 *)
	o_aiGrpLinkageAxisList: ARRAY [1..MAX_UNIT_NUM] OF INT; (* 系的联动轴列表 *)
	(*2023.09.04.131040 增加了色序列表的输出*)
	o_iGrpArcAxisNum_Pu: INT; (* 系的色联动轴套色打开数量|色组按照从小到大排序了 *)
	o_aiGrpArcAxisList: ARRAY [1..MAX_UNIT_NUM] OF INT; (* 系的联动轴套色打开列表 *)
	o_aiGrpArcIdList: ARRAY [1..MAX_UNIT_NUM] OF INT; (* 系的联动轴套色Id列表@2024.02.22.083346 套色id有可能会手动修改 *)
	o_aiGrpFollowArcIdList: ARRAY [1..MAX_UNIT_NUM] OF INT; (* 系的联动轴套色跟踪色序Id列表@2024.02.22.083346 和套色个数同步更新*)


(*运动列表*)	
	o_iAxisNum_Trap: INT;(*点位运动轴数量*)
	o_aiStationList_Trap: ARRAY [1..MAX_STATION_NUM] OF INT;(*点位运动轴列表*)
	o_iAxisNum_Gear: INT;(*电子齿轮运动轴数量*)
	o_aiStationList_Gear: ARRAY [1..MAX_STATION_NUM] OF INT;(*电子齿轮运动轴列表*)
	o_iAxisNum_GantrayTrap: INT;(*龙门点位运动组数量*)
	o_aiStationList_GantrayTrap: ARRAY [1..MAX_STATION_NUM] OF INT;(*龙门点位运动轴列表*)
	o_iAxisNum_Jog: INT;(*龙门点位运动组数量*)
	o_aiStationList_Jog: ARRAY [1..MAX_STATION_NUM] OF INT;(*龙门点位运动轴列表*)		
	o_iAxisNum_All: INT;
	o_aiStationList_All: ARRAY [1..MAX_STATION_NUM] OF INT; 
	o_aiIndexList_All_Trap: ARRAY [1..MAX_STATION_NUM] OF INT;(*点位运动轴列表*)
	o_aiIndexList_All_Gear: ARRAY [1..MAX_STATION_NUM] OF INT;(*电子齿轮运动轴列表*)
	o_aiIndexList_All_Gantray: ARRAY [1..MAX_STATION_NUM] OF INT;(*龙门点位运动轴列表*)	
	o_aiIndexList_All_Jog: ARRAY [1..MAX_STATION_NUM] OF INT;(*龙门点位运动轴列表*)	
	o_axFlag_SlaveUseCmm_Pro: ARRAY [1..MAX_UNIT_NUM] OF BOOL;(*色组使用PRO/月光宝盒*)
	//2026.04.10.145314
	o_dwAxisFlags_Estop:DWORD;(*系急停状态*)	
END_VAR
VAR_IN_OUT
	io_abyColorIdCurrent: ARRAY [1..MAX_UNIT_NUM] OF BYTE;(*色组色序*)
	io_abyFollowColorId: ARRAY [1..MAX_UNIT_NUM] OF BYTE;
END_VAR
VAR
	iN: INT;
	iK: INT;
	iTmpAxisId: INT;
	afbR_TRIG_EvtReq: ARRAY [1..17] OF R_TRIG; (* 上升沿触发器 *)
	dwMaskMonitoring_Estop: DWORD; (* 急停标志位输出 *)
	dwMaskMonitoring_Stop: DWORD;
	dwMaskMonitoring_FastStop: DWORD;
	dwMaskMonitoring_Tension: DWORD;
	dwMaskMonitoring_ManuSpdUp: DWORD;
	dwMaskMonitoring_ManuSpdDn: DWORD;
	dwMaskMonitoring_Ink: DWORD;
	dwMaskMonitoring_Prestart: DWORD;
	dwMaskMonitoring_PressAll: DWORD;
	dwMaskMonitoring_UnpressAll: DWORD;
	dwMaskMonitoring_Print: DWORD;
	dwMaskMonitoring_AlarmBell: DWORD;
	dwMaskMonitoring_AllInchRun: DWORD;
	dwMaskMonitoring_AllExhBlower: DWORD;
	dwMaskMonitoring_AllCoolBlower: DWORD;
	dwMaskMonitoring_AllHotBlower: DWORD;
	dwMaskMonitoring_AllHeating: DWORD;	
	xIsDualUwRw: BOOL := FALSE; (* 双收双放 *)
	xAsOneMachine: BOOL := FALSE; (* A放B收结构 *)
	iUnitId: INT;
	iGrpId: INT;
	iTypeId: INT;
	iAxisTypeId: INT;
	xInit_ColorId: BOOL;(*开机初始化一次色序ID*)
	byColorID: BYTE;
	pstStIOMap_AxisBasic: POINTER TO StIOMap_Axis_FE; (* 基础io *)
	pstStIOMap_AxisExtra: POINTER TO StIOMap_Axis_Extra_FE; (* 扩展io *)
	axArcEnSts_Bak:ARRAY [1..MAX_STATION_NUM] OF BOOL;
	abyArcId_Bak:ARRAY [1..MAX_STATION_NUM] OF BYTE;	
	iUnitId_Rd: INT;
	iTypeId_Rd: INT;
	//iAxisId_Rd: INT;
	//iCoreId_Rd: INT;
	//iGroupId_Rd: INT;
	//iAdjAxisId_Rd: INT;
	
	//2026.5.20.133421 by liu.yt
	pstStationInf:POINTER TO StStationInf;//每个站的信息
END_VAR

{IMPLEMENTATION}
o_xEn:= i_xEn;
o_iErNo:= 0;

(* 返回值初始化 *)
o_iIOGrpIdx_Uw:= -1; (* 放料io系id初始化 *)
o_iIOGrpIdx_Rw:= -1; (* 收料io系id初始化 *)
o_iAxisId_If_IOMapUse:= -1; (* 放牵轴id初始化 *)
o_iAxisId_Of_IOMapUse:= -1; (* 收牵轴id初始化 *)
o_iGrpAxisNum_Pu:= 0; (* 输出色组数量初始化 *)
o_iGrpAxisTotalNum:= 0; (* 输出总轴数量初始化 *)
o_iGrpLinkageAxisNum_Pu:= 0; (* 输出联动色组数量初始化 *)
o_iGrpArcAxisNum_Pu:=0;
FOR iN:=1 TO MAX_UNIT_NUM BY 1 DO(* 轴列表初始化 *)
	o_aiGrpAxisList[iN]:= -1;
	o_aiGrpLinkageAxisList[iN]:= -1;
	o_aiGrpArcAxisList[iN]:=-1;
	o_aiGrpArcIdList[iN]:=-1;(*2024.02.22.083413*)
	o_aiGrpFollowArcIdList[iN]:=-1;
END_FOR
o_aiGrpServoAxisList_Uw[1]:= -1;
o_aiGrpServoAxisList_Uw[2]:= -1;

o_aiGrpServoAxisList_Rw[1]:= -1;
o_aiGrpServoAxisList_Rw[2]:= -1;

(* 2018.9.4.162654\增加的监控初始化 *)
dwMaskMonitoring_Estop:= 0;
dwMaskMonitoring_Stop:= 0;
dwMaskMonitoring_Tension:= 0;
dwMaskMonitoring_ManuSpdUp:= 0;
dwMaskMonitoring_ManuSpdDn:= 0;
dwMaskMonitoring_Ink:= 0;
dwMaskMonitoring_Prestart:= 0;
dwMaskMonitoring_PressAll:= 0;
dwMaskMonitoring_UnpressAll:= 0;
dwMaskMonitoring_Print:= 0;
dwMaskMonitoring_AlarmBell:= 0;
dwMaskMonitoring_AllInchRun:= 0;
dwMaskMonitoring_AllExhBlower:= 0;
dwMaskMonitoring_AllCoolBlower:= 0;
dwMaskMonitoring_AllHotBlower:= 0;
dwMaskMonitoring_AllHeating:= 0;

IF i_xEn THEN
	IF (i_iGrpId=1 OR i_iGrpId=2) AND
		i_pstStEvtReq<>0 AND
		i_pastStIOMap_Main_FE<>0 AND
		i_pastStIOMap_Axis_FE<>0 AND
		i_pastStIOMap_Axis_Extra_FE<>0 AND
		i_pastStIOMap_UwRw_FE_Uw<>0 AND
		i_pastStIOMap_UwRw_FE_Rw<>0 AND
		i_pxInit_StationList<>0 THEN
		KS_InitStEvtReq(i_pstStEvtReq); (* 初始化StEvtReq@2018.7.31.094400 *)
		xIsDualUwRw:= i_dwEquipmentProf.20;
		xAsOneMachine:= i_dwEquipmentProf.21;
		IF NOT(i_iUMax>=1 AND i_iUMax<=16) THEN
			o_iErNo:=-4;
			RETURN;
		END_IF
		IF xIsDualUwRw AND xAsOneMachine AND i_iGrpId<>1 THEN(* A放B收\操作了A系以外的系 *)
			o_iErNo:= -2;
			RETURN;
		ELSIF (NOT xIsDualUwRw) AND i_iGrpId<>1 THEN(* 对于标准机型操作了A系以外的系 *)
			o_iErNo:= -3;
			RETURN;
		ELSE(* 其余正常情况 *)
			(* 生成当前系数的色组轴号列表|
			/*目前1个系内的放牵和收牵只认为各有1个,所以读取轴类型是牵引的会覆盖前面的取值 *)
			IF i_xUseRealStationOnRingnet THEN
// 				FOR iN:=1 TO i_pstStStationInfo_KS^.iStationNum BY 1 DO
// 					KS_GetAxisIdForMotByStation_V2(
// 						i_iStationId:= i_pstStStationInfo_KS^.aiStationId_List[iN],
// 						i_piAxisId:= ADR(iAxisId_Rd), 
// 						i_piTypeId:= ADR(iTypeId_Rd), 
// 						i_piUnitId:= ADR(iUnitId_Rd), 
// 						i_piCoreId:= ADR(iCoreId_Rd), 
// 						i_piGroupId:= ADR(iGroupId_Rd), 
// 						i_piAdjAxisId:= ADR(iAdjAxisId_Rd), 
// 						i_pstStSysStationInf:= ADR(g_stStSysStationInf));			
// 					IF iUnitId_Rd>=1 AND iUnitId<=MAX_UNIT_NUM THEN
// 						iGrpId:= KS_GetGrpIdByAxisId(iUnitId,ADR(g_stStSysParam),ADR(iAxisTypeId));
// 						//2026.5.12.112929就用版辊驱动器数量输出轴列表吧
// 						IF iGrpId= i_iGrpId THEN
// 							IF iTypeId_Rd=TYPE_UNIT_PRN THEN
// 								o_iGrpAxisNum_Pu:= o_iGrpAxisNum_Pu+1;
// 								o_aiGrpAxisList[o_iGrpAxisNum_Pu]:= iUnitId_Rd;								
// 							END_IF
// 						END_IF
// 					END_IF
// 				END_FOR		
				//2026.5.20.133216 by liu.yt 重新生成列表@根据实际站
				FOR iN:=1 TO BYTE_TO_INT(i_pstStSysStationInf^.byStationNum) BY 1 DO
					pstStationInf:=ADR(i_pstStSysStationInf^.astStationInf[iN]);
					
					KS_GetAxisIdForMotByStation_V2(
						i_iStationId:= pstStationInf^.iStationId,
						i_piAxisId:= 0, 
						i_piTypeId:= ADR(iTypeId_Rd), 
						i_piUnitId:= ADR(iUnitId_Rd), 
						i_piCoreId:= 0, 
						i_piGroupId:= 0, 
						i_piAdjAxisId:= 0, 
						i_pstStSysStationInf:= i_pstStSysStationInf);	
					IF iUnitId_Rd>=1 AND iUnitId_Rd<=MAX_UNIT_NUM THEN//色组id合法@1个色组可能会存在多个不同功能站号返回。我们只检查色组轴
						iGrpId:= KS_GetGrpIdByAxisId(iUnitId_Rd,ADR(g_stStSysParam),ADR(iAxisTypeId));
						//2026.5.12.112929就用版辊驱动器数量输出轴列表吧
						IF iGrpId= i_iGrpId THEN
							IF iTypeId_Rd=TYPE_UNIT_CTL THEN
								o_iGrpAxisNum_Pu:= o_iGrpAxisNum_Pu+1;
								o_aiGrpAxisList[o_iGrpAxisNum_Pu]:= iUnitId_Rd;								
							END_IF
						END_IF
					END_IF
				END_FOR
			ELSE
				(* 2020.9.11.134731
				** 按照系统配置的色组填充列表|
				** *)
				FOR iUnitId:=1 TO i_iUMax BY 1 DO
					o_iGrpAxisNum_Pu:= o_iGrpAxisNum_Pu+1;
					o_aiGrpAxisList[o_iGrpAxisNum_Pu]:= iUnitId;
				END_FOR
			END_IF
			

			(* **
			** 将牵引轴使能出来@2019.4.26.171841
			** 针对给了使能|但没有给牵引指定一个有效的轴id
			** *)
			IF NOT xIsDualUwRw THEN(* 非双收双放 *)
				(* 放牵轴id *)
				IF i_xIsValid_If_I THEN
					o_iAxisId_If_IOMapUse:= 1;
				END_IF

				(* 收牵轴id *)
				IF i_xIsValid_Of_I THEN
					o_iAxisId_Of_IOMapUse:= 2;
				END_IF
			ELSE(* 双收双放 *)
				IF xAsOneMachine THEN(* A放B收 *)
					IF i_iGrpId=1 THEN
						(* 放牵轴id *)
						IF i_xIsValid_If_I THEN
							o_iAxisId_If_IOMapUse:= 1;
						END_IF

						(* 收牵轴id *)
						IF i_xIsValid_Of_II THEN
							o_iAxisId_Of_IOMapUse:= 4;
						END_IF
					END_IF
				ELSE(* A放A收|B放B收 *)
					IF i_iGrpId=1 THEN
						(* 放牵轴id *)
						IF i_xIsValid_If_I THEN
							o_iAxisId_If_IOMapUse:= 1;
						END_IF

						(* 收牵轴id *)
						IF i_xIsValid_Of_I THEN
							o_iAxisId_Of_IOMapUse:= 2;
						END_IF
					ELSE(* B系 *)
						(* 放牵轴id *)
						IF i_xIsValid_If_II THEN
							o_iAxisId_If_IOMapUse:= 3;
						END_IF

						(* 收牵轴id *)
						IF i_xIsValid_Of_II THEN
							o_iAxisId_Of_IOMapUse:= 4;
						END_IF
					END_IF
				END_IF
			END_IF
			(* 色组按从小到大的编号排列 *)
			FOR iN:=o_iGrpAxisNum_Pu TO 2 BY -1 DO
				FOR iK:=1 TO iN BY 1 DO
					IF o_aiGrpAxisList[iN]<o_aiGrpAxisList[iK] THEN
						iTmpAxisId:= o_aiGrpAxisList[iN];
						o_aiGrpAxisList[iN]:= o_aiGrpAxisList[iK];
						o_aiGrpAxisList[iK]:= iTmpAxisId;
					END_IF
				END_FOR
			END_FOR

			(* 在色组轴号之后追加牵引轴编号 *)
			o_iGrpAxisTotalNum:= o_iGrpAxisNum_Pu;
(*2026.5.12.132915这个列表只放色组相关的
			(* 放牵 *)
			IF o_iAxisId_If_IOMapUse>=1 AND o_iAxisId_If_IOMapUse<=MAX_STATION_NUM THEN
				o_iGrpAxisTotalNum:= o_iGrpAxisTotalNum+1;
				o_aiGrpAxisList[o_iGrpAxisTotalNum]:= o_iAxisId_If_IOMapUse;
			END_IF

			(* 收牵 *)
			IF o_iAxisId_Of_IOMapUse>=1 AND o_iAxisId_Of_IOMapUse<=MAX_STATION_NUM THEN
				o_iGrpAxisTotalNum:= o_iGrpAxisTotalNum+1;
				o_aiGrpAxisList[o_iGrpAxisTotalNum]:= o_iAxisId_Of_IOMapUse;
			END_IF
*)
			(*2022.5.25.104049 增加联动轴的列表输出*)
			FOR iN:=1 TO o_iGrpAxisNum_Pu BY 1 DO
				iTmpAxisId:= o_aiGrpAxisList[iN];
				IF iTmpAxisId>0 THEN					
					IF i_axLinkage[iTmpAxisId] THEN(*联动*)
						o_iGrpLinkageAxisNum_Pu:=o_iGrpLinkageAxisNum_Pu+1;
						o_aiGrpLinkageAxisList[o_iGrpLinkageAxisNum_Pu]:=iTmpAxisId;
					END_IF
				END_IF
			END_FOR


			(*2023.09.04.131214 增加联动轴套色打开的列表输出*)
			IF xInit_ColorId THEN
				FOR iN:=1 TO o_iGrpLinkageAxisNum_Pu BY 1 DO
					iTmpAxisId:= o_aiGrpLinkageAxisList[iN];
					IF iTmpAxisId>0 THEN
						IF io_abyColorIdCurrent[iTmpAxisId]>0 AND io_abyColorIdCurrent[iTmpAxisId]<=MAX_UNIT_NUM THEN(*色序合法*)
							o_iGrpArcAxisNum_Pu:=o_iGrpArcAxisNum_Pu+1;
							o_aiGrpArcAxisList[o_iGrpArcAxisNum_Pu]:=iTmpAxisId;
							o_aiGrpArcIdList[o_iGrpArcAxisNum_Pu]:=io_abyColorIdCurrent[iTmpAxisId];(*2024.02.22.083448 套色id也统计出来*)
							o_aiGrpFollowArcIdList[o_iGrpArcAxisNum_Pu]:=io_abyFollowColorId[iTmpAxisId];(*2024.02.22.112812 界面修改或者一些开关控制*)
						END_IF
					END_IF
				END_FOR
			END_IF


			IF xIsDualUwRw THEN
				(* 双收双放 *)

				IF xAsOneMachine THEN
					(* A放B收 *)
					o_iIOGrpIdx_Uw:= 1;
					o_iIOGrpIdx_Rw:= 2;
				ELSE
					(* A/B系各自用各自的 *)
					IF i_iGrpId=1 THEN
						o_iIOGrpIdx_Uw:= 1;
						o_iIOGrpIdx_Rw:= 1;
					ELSE
						o_iIOGrpIdx_Uw:= 2;
						o_iIOGrpIdx_Rw:= 2;
					END_IF
				END_IF
			ELSE(* 普通机型\只看A系 *)
				o_iIOGrpIdx_Uw:= 1;
				o_iIOGrpIdx_Rw:= 1;
			END_IF


			(* 放料和收料的急停按钮 *)
			IF i_pastStIOMap_UwRw_FE_Uw^[o_iIOGrpIdx_Uw].i_xEstop THEN(* 放料急停 *)
				dwMaskMonitoring_Estop:= dwMaskMonitoring_Estop OR SHL(DWORD#1,20);
				i_pstStEvtReq^.xEvt_Estop:= TRUE;
			END_IF
			IF i_pastStIOMap_UwRw_FE_Rw^[o_iIOGrpIdx_Rw].i_xEstop THEN(* 收料急停 *)
				dwMaskMonitoring_Estop:= dwMaskMonitoring_Estop OR SHL(DWORD#1,21);
				i_pstStEvtReq^.xEvt_Estop:= TRUE;
			END_IF
			
			(*放牵收牵的按钮处理*)
			IF i_pastStIOMap_Main_FE^[o_iAxisId_If_IOMapUse].i_xEstop OR
				i_pastStIOMap_Main_FE^[o_iAxisId_Of_IOMapUse].i_xEstop THEN
				i_pstStEvtReq^.xEvt_Estop:= TRUE;
			END_IF
			IF i_pastStIOMap_Main_FE^[o_iAxisId_If_IOMapUse].i_xStop OR
				i_pastStIOMap_Main_FE^[o_iAxisId_Of_IOMapUse].i_xStop THEN
				i_pstStEvtReq^.xEvt_Stop:= TRUE;
			END_IF			
			IF i_pastStIOMap_Main_FE^[o_iAxisId_If_IOMapUse].i_xFastStop OR
				i_pastStIOMap_Main_FE^[o_iAxisId_Of_IOMapUse].i_xFastStop THEN
				//2026.06.04.145510 变量写错了 by liu.yt
				//i_pstStEvtReq^.xEvt_Stop:= TRUE;
				i_pstStEvtReq^.xEvt_FastStop:= TRUE;
			END_IF
			IF i_pastStIOMap_Main_FE^[o_iAxisId_If_IOMapUse].i_xTension OR
				i_pastStIOMap_Main_FE^[o_iAxisId_Of_IOMapUse].i_xTension THEN
				i_pstStEvtReq^.xEvt_Tension:= TRUE;
			END_IF			
			IF i_pastStIOMap_Main_FE^[o_iAxisId_If_IOMapUse].i_xAcc OR
				i_pastStIOMap_Main_FE^[o_iAxisId_Of_IOMapUse].i_xAcc THEN
				i_pstStEvtReq^.xEvt_ManuSpdUp:= TRUE;
			END_IF	
			IF i_pastStIOMap_Main_FE^[o_iAxisId_If_IOMapUse].i_xDec OR
				i_pastStIOMap_Main_FE^[o_iAxisId_Of_IOMapUse].i_xDec THEN
				i_pstStEvtReq^.xEvt_ManuSpdDn:= TRUE;
			END_IF	
			IF i_pastStIOMap_Main_FE^[o_iAxisId_If_IOMapUse].i_xInk OR
				i_pastStIOMap_Main_FE^[o_iAxisId_Of_IOMapUse].i_xInk THEN
				i_pstStEvtReq^.xEvt_Ink:= TRUE;
			END_IF	
			IF i_pastStIOMap_Main_FE^[o_iAxisId_If_IOMapUse].i_xPrestart OR
				i_pastStIOMap_Main_FE^[o_iAxisId_Of_IOMapUse].i_xPrestart THEN
				i_pstStEvtReq^.xEvt_Prestart:= TRUE;
			END_IF	
			IF i_pastStIOMap_Main_FE^[o_iAxisId_If_IOMapUse].i_xPrint OR
				i_pastStIOMap_Main_FE^[o_iAxisId_Of_IOMapUse].i_xPrint THEN
				i_pstStEvtReq^.xEvt_Print:= TRUE;
			END_IF	
			IF i_pastStIOMap_Main_FE^[o_iAxisId_If_IOMapUse].i_xPressAll OR
				i_pastStIOMap_Main_FE^[o_iAxisId_Of_IOMapUse].i_xPressAll THEN
				i_pstStEvtReq^.xEvt_PressAll:= TRUE;
			END_IF	
			IF i_pastStIOMap_Main_FE^[o_iAxisId_If_IOMapUse].i_xUnPressAll OR
				i_pastStIOMap_Main_FE^[o_iAxisId_Of_IOMapUse].i_xUnPressAll THEN
				i_pstStEvtReq^.xEvt_UnPressAll:= TRUE;
			END_IF	
			IF i_pastStIOMap_Main_FE^[o_iAxisId_If_IOMapUse].i_xAlarmBell OR
				i_pastStIOMap_Main_FE^[o_iAxisId_Of_IOMapUse].i_xAlarmBell THEN
				i_pstStEvtReq^.xEvt_AlarmBell:= TRUE;
			END_IF	

			IF i_pastStIOMap_Main_FE^[o_iAxisId_If_IOMapUse].i_xAllExhBlower_Up OR
				i_pastStIOMap_Main_FE^[o_iAxisId_Of_IOMapUse].i_xAllExhBlower_Up OR
				i_pastStIOMap_Main_FE^[o_iAxisId_If_IOMapUse].i_xAllExhBlower_Dn OR
				i_pastStIOMap_Main_FE^[o_iAxisId_Of_IOMapUse].i_xAllExhBlower_Dn THEN
				(* 整机排风 *)
				i_pstStEvtReq^.xEvt_AllExhBlower:= TRUE;
			END_IF

			IF i_pastStIOMap_Main_FE^[o_iAxisId_If_IOMapUse].i_xAllCoolBlower OR
				i_pastStIOMap_Main_FE^[o_iAxisId_Of_IOMapUse].i_xAllCoolBlower THEN						
				(* 整机冷风 *)
				i_pstStEvtReq^.xEvt_AllCoolBlower:= TRUE;
			END_IF
			IF i_pastStIOMap_Main_FE^[o_iAxisId_If_IOMapUse].i_xAllHotBlower OR
				i_pastStIOMap_Main_FE^[o_iAxisId_Of_IOMapUse].i_xAllHotBlower THEN				
				(* 整机热风 *)
				i_pstStEvtReq^.xEvt_AllHotBlower:= TRUE;
			END_IF
			IF i_pastStIOMap_Main_FE^[o_iAxisId_If_IOMapUse].i_xAllHeating OR
				i_pastStIOMap_Main_FE^[o_iAxisId_Of_IOMapUse].i_xAllHeating THEN					
				(* 整机加热 *)
				i_pstStEvtReq^.xEvt_AllHeating:= TRUE;
			END_IF

			(* 默认3档开关 作互斥 *)
			IF i_pastStIOMap_Main_FE^[o_iAxisId_Of_IOMapUse].i_xTapPosition_Breaking THEN(* 2018.7.16.151749\断料档位 *)
				i_pstStEvtReq^.xEvt_TapPosition_Breaking:= TRUE;
				i_pstStEvtReq^.xEvt_TapPosition_UniformInk:= FALSE;
				i_pstStEvtReq^.xEvt_TapPosition_Printing:= FALSE;
			ELSIF i_pastStIOMap_Main_FE^[o_iAxisId_Of_IOMapUse].i_xTapPosition_UniformInk THEN(* 2018.7.16.152023\匀墨档位 *)
				i_pstStEvtReq^.xEvt_TapPosition_UniformInk:= TRUE;
				i_pstStEvtReq^.xEvt_TapPosition_Breaking:= FALSE;
				i_pstStEvtReq^.xEvt_TapPosition_Printing:= FALSE;
			ELSE(* 2018.7.16.152128\印刷档位 *)
				i_pstStEvtReq^.xEvt_TapPosition_Printing:= TRUE;
				i_pstStEvtReq^.xEvt_TapPosition_Breaking:= FALSE;
				i_pstStEvtReq^.xEvt_TapPosition_UniformInk:= FALSE;
			END_IF
			
			(* 影响整机的逻辑按钮\所有轴上可能都有\就在FOR循环里面检查(当然要包含牵引) *)
			byColorID:=0;(*2022.6.8.101746*)
			FOR iN:=1 TO o_iGrpAxisNum_Pu BY 1 DO
				iUnitId:= o_aiGrpAxisList[iN]; (* 列表由于本地生成\所以iAxisId可以不检查 *)
				pstStIOMap_AxisBasic:= ADR(i_pastStIOMap_Axis_FE^[iUnitId]); (* 基础io表 *)
				pstStIOMap_AxisExtra:= ADR(i_pastStIOMap_Axis_Extra_FE^[iUnitId]); (* 扩展io表 *)

				IF pstStIOMap_AxisBasic^.i_xEstop THEN
					(* 急停 *)
					i_pstStEvtReq^.xEvt_Estop:= TRUE;
					dwMaskMonitoring_Estop:= dwMaskMonitoring_Estop OR SHL(DWORD#1,iUnitId-1);
				END_IF
				IF pstStIOMap_AxisBasic^.i_xStop THEN
					(* 停机 *)
					i_pstStEvtReq^.xEvt_Stop:= TRUE;
					dwMaskMonitoring_Stop:= dwMaskMonitoring_Stop OR SHL(DWORD#1,iUnitId-1);
				END_IF

				IF pstStIOMap_AxisBasic^.i_xAcc THEN
					(* 手动加速 *)
					i_pstStEvtReq^.xEvt_ManuSpdUp:= TRUE;
					dwMaskMonitoring_ManuSpdUp:= dwMaskMonitoring_ManuSpdUp OR SHL(DWORD#1,iUnitId-1);
				END_IF
				IF pstStIOMap_AxisBasic^.i_xDec THEN
					(* 手动减速 *)
					i_pstStEvtReq^.xEvt_ManuSpdDn:= TRUE;
					dwMaskMonitoring_ManuSpdDn:= dwMaskMonitoring_ManuSpdDn OR SHL(DWORD#1,iUnitId-1);
				END_IF

				IF pstStIOMap_AxisBasic^.i_xAlarmBell THEN
					(* 警铃 *)
					i_pstStEvtReq^.xEvt_AlarmBell:= TRUE;
					dwMaskMonitoring_AlarmBell:= dwMaskMonitoring_AlarmBell OR SHL(DWORD#1,iUnitId-1);
				END_IF
				IF pstStIOMap_AxisBasic^.i_xInch AND
					i_axLinkage[iUnitId] THEN
					(* 整机单运行 *)
					i_pstStEvtReq^.xEvt_AllInchRun:= TRUE;
					dwMaskMonitoring_AllInchRun:= dwMaskMonitoring_AllInchRun OR SHL(DWORD#1,iUnitId-1);
				END_IF
			END_FOR
			
			//2026.5.9.172930
			//2026.04.10.145142 + 系急停变量赋值
			o_dwAxisFlags_Estop:=dwMaskMonitoring_Estop;

			(*2024.02.21.084550 优化套色id逻辑*)
			KS_GetArcIdList(
				TRUE(*i_xEn*),
				o_iGrpAxisNum_Pu(*i_iGrpAxisNum_Pu*),
				o_aiGrpAxisList(*i_aiGrpAxisList*),
				ADR(axArcEnSts_Bak)(*i_paxArcEnSts_Bak*),
				ADR(abyArcId_Bak)(*i_pabyArcId_Bak*),
				0(*i_piGrpArcAxisNum_Pu*),
				i_axLinkage,
				i_axThisUnitEna,
				i_axSwitchOn_CoatingPrn,
				ADR(io_abyColorIdCurrent));
			xInit_ColorId:=TRUE;			
			
			
		END_IF		

		(*2025.6.16.165421运动所有的轴列表处理一下*)
		IF NOT i_pxInit_StationList^ THEN
			i_pxInit_StationList^:= TRUE;
			o_iAxisNum_Trap:= 0;
			o_iAxisNum_Gear:= 0;
			o_iAxisNum_GantrayTrap:= 0;		
			o_iAxisNum_Jog:= 0;		
			o_iAxisNum_All:= 0;
			FOR iN:=1 TO MAX_STATION_NUM BY 1 DO
				o_aiStationList_Trap[iN]:= 0;
				o_aiStationList_Gear[iN]:= 0;
				o_aiStationList_GantrayTrap[iN]:= 0;	
				o_aiStationList_All[iN]:= 0;		
				o_aiIndexList_All_Trap[iN]:= 0;
				o_aiIndexList_All_Gear[iN]:= 0;
				o_aiIndexList_All_Gantray[iN]:= 0;
			END_FOR			


			FOR iN:=1 TO i_pstStSysStationInf^.byStationNum BY 1 DO
				pstStationInf:=ADR(i_pstStSysStationInf^.astStationInf[iN]);
				KS_GetUnitIdAndTypeByStationId(
					pstStationInf^.iStationId ,//i_pstStRingInfVer1^.m_station_id_list[iN],//i_pstStStationInfo_KS^.aiStationId_List[iN], //,
					ADR(iUnitId),
					ADR(iTypeId),
					i_pstStSysCfgStruct);
				IF iTypeId= OBJ_IS_HORIZ_MOTION OR
					 iTypeId=OBJ_IS_PHOTOCELL THEN(*光电眼行走机构 | 2024.04.01.092649*)
					o_iAxisNum_Trap:= o_iAxisNum_Trap+1;
					IF o_iAxisNum_Trap<>0 THEN
						o_aiStationList_Trap[o_iAxisNum_Trap]:= pstStationInf^.iStationId;//i_pstStRingInfVer1^.m_station_id_list[iN];//
						o_aiIndexList_All_Trap[o_iAxisNum_Trap]:= iN;
					END_IF
				ELSIF iTypeId= OBJ_IS_PRN_ROLLER_PRESSURE_M OR
					iTypeId= OBJ_IS_PRN_ROLLER_PRESSURE_G OR
					iTypeId= OBJ_IS_NET_ROLLER_PRESSURE_M OR
					iTypeId= OBJ_IS_NET_ROLLER_PRESSURE_G OR
					iTypeId= OBJ_IS_STR_ROLLER_PRESSURE_M OR
					iTypeId= OBJ_IS_STR_ROLLER_PRESSURE_G THEN
					o_iAxisNum_GantrayTrap:= o_iAxisNum_GantrayTrap+1;
					IF o_iAxisNum_GantrayTrap<>0 THEN
						o_aiStationList_GantrayTrap[o_iAxisNum_GantrayTrap]:= pstStationInf^.iStationId;//i_pstStRingInfVer1^.m_station_id_list[iN];//;
						o_aiIndexList_All_Gantray[o_iAxisNum_GantrayTrap]:= iN;

					END_IF					
				ELSIF iTypeId= OBJ_IS_UNWIND_A OR
					iTypeId= OBJ_IS_UNWIND_B OR
					iTypeId= OBJ_IS_REWIND_A OR
					iTypeId= OBJ_IS_REWIND_B OR
					iTypeId= OBJ_IS_INFEED OR
					iTypeId= OBJ_IS_OUTFEED OR
					iTypeId= OBJ_IS_BOTTOM_ROLLER OR
					iTypeId= OBJ_IS_PRN_ROLLER OR
					iTypeId= OBJ_IS_NET_ROLLER OR
					iTypeId= OBJ_IS_CENTRAL_DRUM THEN
					o_iAxisNum_Gear:= o_iAxisNum_Gear+1;
					IF o_iAxisNum_Gear<>0 THEN
						o_aiStationList_Gear[o_iAxisNum_Gear]:= pstStationInf^.iStationId;//i_pstStRingInfVer1^.m_station_id_list[iN];//;
						o_aiIndexList_All_Gear[o_iAxisNum_Gear]:= iN;

					END_IF	

					//2026.05.08.141028 | + | 增加收放料伺服的标志
					IF iTypeId= OBJ_IS_UNWIND_A OR
						iTypeId= OBJ_IS_UNWIND_B OR
						iTypeId= OBJ_IS_REWIND_A OR
						iTypeId= OBJ_IS_REWIND_B THEN
						g_xUwRwIsServo := TRUE;
					END_IF
				//这部分的代码处理会有问题@2026.5.20.140553 by liu.yt
				ELSIF pstStationInf^.iStationId>=1 
					AND pstStationInf^.iStationId<16 
					AND (pstStationInf^.udiStationType=HY_YTPE_CMM_CR_PRO  
					OR	pstStationInf^.udiStationType=HY_YTPE_CMM_CR) THEN//色组使用月光宝盒/PRO通讯
					IF pstStationInf^.udiStationType=HY_YTPE_CMM_CR_PRO THEN
						o_axFlag_SlaveUseCmm_Pro[pstStationInf^.iStationId]:= TRUE;
					ELSE
						o_axFlag_SlaveUseCmm_Pro[pstStationInf^.iStationId]:= FALSE;
					END_IF
				END_IF
				IF iTypeId= OBJ_IS_HORIZ_MOTION OR
					iTypeId= OBJ_IS_PRN_ROLLER_PRESSURE_M OR
					iTypeId= OBJ_IS_PRN_ROLLER_PRESSURE_G OR
					iTypeId= OBJ_IS_NET_ROLLER_PRESSURE_M OR
					iTypeId= OBJ_IS_NET_ROLLER_PRESSURE_G OR
					iTypeId= OBJ_IS_UNWIND_A OR
					iTypeId= OBJ_IS_UNWIND_B OR
					iTypeId= OBJ_IS_REWIND_A OR
					iTypeId= OBJ_IS_REWIND_B OR
					iTypeId= OBJ_IS_INFEED OR
					iTypeId= OBJ_IS_OUTFEED OR
					iTypeId= OBJ_IS_BOTTOM_ROLLER OR
					iTypeId= OBJ_IS_PRN_ROLLER OR
					iTypeId= OBJ_IS_NET_ROLLER OR
					iTypeId= OBJ_IS_CENTRAL_DRUM OR//所有参与运动的轴个数
					iTypeId= OBJ_IS_PHOTOCELL OR
					iTypeId= OBJ_IS_STR_ROLLER_PRESSURE_M OR
					iTypeId= OBJ_IS_STR_ROLLER_PRESSURE_G THEN//所有参与运动的轴个数
					o_iAxisNum_All:= o_iAxisNum_All+1;
					IF o_iAxisNum_All<>0 THEN
						o_aiStationList_All[o_iAxisNum_All]:= pstStationInf^.iStationId;//i_pstStRingInfVer1^.m_station_id_list[iN];//;
					END_IF							
				END_IF
			END_FOR				
		END_IF
		
		(*-----------end--------------------------*)
		
		(* 上升沿检测 *)
		afbR_TRIG_EvtReq[1](CLK:= i_pstStEvtReq^.xEvt_Estop, Q=> i_pstStEvtReq^.xReqEstop); (* 急停 *)
		afbR_TRIG_EvtReq[2](CLK:= i_pstStEvtReq^.xEvt_Stop, Q=> i_pstStEvtReq^.xReqStop); (* 停机 *)
		afbR_TRIG_EvtReq[3](CLK:= i_pstStEvtReq^.xEvt_Tension, Q=> i_pstStEvtReq^.xReqTension); (* 张力投入 *)
		afbR_TRIG_EvtReq[4](CLK:= i_pstStEvtReq^.xEvt_ManuSpdUp, Q=> i_pstStEvtReq^.xReqManuSpdUp); (* 手动加速|按着才加速 *)
		afbR_TRIG_EvtReq[5](CLK:= i_pstStEvtReq^.xEvt_ManuSpdDn, Q=> i_pstStEvtReq^.xReqManuSpdDn); (* 手动减速|按着才减速 *)
		afbR_TRIG_EvtReq[6](CLK:= i_pstStEvtReq^.xEvt_Ink, Q=> i_pstStEvtReq^.xReqInk); (* 空转 *)
		afbR_TRIG_EvtReq[7](CLK:= i_pstStEvtReq^.xEvt_Prestart, Q=> i_pstStEvtReq^.xReqPrestart); (* 启动|预备 *)
		afbR_TRIG_EvtReq[8](CLK:= i_pstStEvtReq^.xEvt_PressAll, Q=> i_pstStEvtReq^.xReqPressAll); (* 全体合压 *)
		afbR_TRIG_EvtReq[9](CLK:= i_pstStEvtReq^.xEvt_UnpressAll, Q=> i_pstStEvtReq^.xReqUnpressAll); (* 全体离压 *)
		afbR_TRIG_EvtReq[10](CLK:= i_pstStEvtReq^.xEvt_Print, Q=> i_pstStEvtReq^.xReqPrint); (* 印刷|联动 *)
		afbR_TRIG_EvtReq[11](CLK:= i_pstStEvtReq^.xEvt_AlarmBell, Q=> i_pstStEvtReq^.xReqAlarmBell); (* 警铃|按着才响 *)
		afbR_TRIG_EvtReq[12](CLK:= i_pstStEvtReq^.xEvt_AllInchRun, Q=> i_pstStEvtReq^.xReqAllInchRun); (* 整机单运行 *)
		afbR_TRIG_EvtReq[13](CLK:= i_pstStEvtReq^.xEvt_AllExhBlower, Q=> i_pstStEvtReq^.xReqAllExhBlower); (* 排风启动 *)
		afbR_TRIG_EvtReq[14](CLK:= i_pstStEvtReq^.xEvt_AllCoolBlower, Q=> i_pstStEvtReq^.xReqAllCoolBlower); (* 冷风启动 *)
		afbR_TRIG_EvtReq[15](CLK:= i_pstStEvtReq^.xEvt_AllHotBlower, Q=> i_pstStEvtReq^.xReqAllHotBlower); (* 热风启动 *)
		afbR_TRIG_EvtReq[16](CLK:= i_pstStEvtReq^.xEvt_AllHeating, Q=> i_pstStEvtReq^.xReqAllHeating); (* 加热启动 *)
		afbR_TRIG_EvtReq[17](CLK:= i_pstStEvtReq^.xEvt_FastStop, Q=> i_pstStEvtReq^.xReqFastStop); (* 快停按钮 *)
		(*记录日志和变频报警处理稍后*)
	END_IF
END_IF