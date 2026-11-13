(*@CES
Name=KS_FB_SpecialFun
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=6f24de6d-851e-4d83-be3a-73e7f4a5feb5
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_SpecialFun
VAR_INPUT
	i_xEn:BOOL;
	i_iGrpId								: INT;
	i_iGrpAxisNum_Pu: INT;(*色组轴数|*)
	i_aiGrpAxisList: ARRAY [1..MAX_UNIT_NUM] OF INT;(*轴-站映射表|*)
	i_iCustomerName							: INT;
	i_pastStIOMap_Main_FE					: POINTER TO ARRAY [1..4] OF StIOMap_Main_FE;(*轴io数据区域|*)
	i_pastStIOMap_Axis_FE					: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF StIOMap_Axis_FE;(*轴io数据区域|`````````````````````````````````````````````*)
	i_pastStIOMap_Axis_Extra_FE				: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF StIOMap_Axis_Extra_FE;
	i_pstStIOMap_UwRw_FE_Uw					: POINTER TO ARRAY [1..2] OF StIOMap_UwRw_FE;(*轴io数据区域|*)
	i_pstStIOMap_UwRw_FE_Rw					: POINTER TO ARRAY [1..2] OF StIOMap_UwRw_FE;(*轴io数据区域|*)	
	i_iIOGrpIdx_Uw: INT := 1;(*放料组id|*)
	i_iIOGrpIdx_Rw: INT := 1;(*收料组id|*)
	i_iAxisId_If			: INT 						:=-1;(*放牵轴id|*)
	i_iAxisId_Of			: INT 						:=-1;(*收牵轴id|*)
	i_pstStEvtReq: POINTER TO StEvtReq;(*按钮输入操作及边沿触发描述|*)	
	i_pstStSysParam			: POINTER TO StSysParam;
	i_pastStInteraction : POINTER TO ARRAY [1..MAX_UNIT_NUM] OF StInteraction;
	i_pstStSysStationInf			:POINTER TO StSysStationInf;
	i_pastStGetMotionSts: POINTER TO ARRAY [1..MAX_STATION_NUM] OF StGetMotionSts;
END_VAR
VAR_OUTPUT
	o_xEn: BOOL;
	o_iErNo: INT;
END_VAR
VAR
	fbKS_FB_SpecialFun_RUNXIN: KS_FB_SpecialFun_RUNXIN;
	fbKS_FB_SpecialFun_YCZB: KS_FB_SpecialFun_YCZB;
	fbKS_FB_SpecialFun_QINHUA:KS_FB_SpecialFun_QINHUA;
	fbKS_FB_SpecialFun_CHAOXU:KS_FB_SpecialFun_CHAOXU;
	fbKS_FB_MarkDetection:KS_FB_MarkDetection_2;
	//2026.04.03.085929 | + | 增加欧诺特殊功能块
	fbKS_FB_SpecialFun_OuNuo: KS_FB_SpecialFun_OuNuo;	
END_VAR

{IMPLEMENTATION}
o_xEn:= i_xEn;
o_iErNo:= 0;
IF i_xEn THEN
	IF i_pstStEvtReq<>0 AND
		i_pstStSysParam<>0 AND
		i_pastStIOMap_Main_FE<>0 AND
		i_pastStIOMap_Axis_FE<>0 AND
		i_pastStIOMap_Axis_Extra_FE<>0 AND
		i_pstStIOMap_UwRw_FE_Uw<>0 AND
		i_pstStIOMap_UwRw_FE_Rw<>0 AND
		i_iIOGrpIdx_Uw>=1 AND i_iIOGrpIdx_Uw<=4 AND
		i_iIOGrpIdx_Rw>=1 AND i_iIOGrpIdx_Rw<=4 AND
		i_iAxisId_If>=1 AND i_iAxisId_If<=4 AND
		i_iAxisId_Of>=1 AND i_iAxisId_Of<=4 
	THEN
		fbKS_FB_SpecialFun_RUNXIN(
			i_xEn:= i_iCustomerName= CUSTOMERNAME_RUNXIN,
			i_iGrpId:= i_iGrpId,	
			i_pstStSysParam:= i_pstStSysParam
		);
		fbKS_FB_SpecialFun_YCZB(
			i_xEn:= i_iCustomerName= CUSTOMERNAME_YUNCHENGZHIBAN, 
			i_iGrpId:= i_iGrpId, 
			i_iGrpAxisNum_Pu:= i_iGrpAxisNum_Pu, 
			i_aiGrpAxisList:= i_aiGrpAxisList, 
			i_pstStEvtReq:= i_pstStEvtReq, 
			i_pastStIOMap_Axis_FE:= i_pastStIOMap_Axis_FE, 
			i_pstStSysParam:= i_pstStSysParam);
			
			
		fbKS_FB_SpecialFun_QINHUA(
			i_xEn:= i_iCustomerName= CUSTOMERNAME_QINHUA, 
			i_iGrpId:= i_iGrpId, 
			i_iGrpUnitNum_Pu:= i_iGrpAxisNum_Pu, 
			i_aiGrpUnitList:= i_aiGrpAxisList, 
			i_pstStSysParam:= i_pstStSysParam, 
			i_pastStIOMap_Main_FE:= i_pastStIOMap_Main_FE, 
			i_pastStIOMap_Axis_FE:= i_pastStIOMap_Axis_FE,
			i_pastStInteraction:=i_pastStInteraction,
			i_pstStEvtReq:= i_pstStEvtReq,
			i_pstStSysStationInf := i_pstStSysStationInf,
			i_pastStGetMotionSts := i_pastStGetMotionSts);
			
		fbKS_FB_SpecialFun_CHAOXU(
			i_xEn:= i_iCustomerName= CUSTOMERNAME_CHAOXU,
			i_iGrpId:= i_iGrpId, 
			i_iGrpUnitNum_Pu:= i_iGrpAxisNum_Pu, 
			i_aiGrpUnitList:= i_aiGrpAxisList, 
			i_pstStSysParam:= i_pstStSysParam, 
			i_pastStIOMap_Main_FE:= i_pastStIOMap_Main_FE, 
			i_pastStIOMap_Axis_FE:= i_pastStIOMap_Axis_FE, 
			i_pastStInteraction:= i_pastStInteraction, 
			i_pstStEvtReq:= i_pstStEvtReq,
			i_rVel_UVstartVel:= i_pstStSysParam^.astStRSV_GrpParam_Save[i_iGrpId].rVel_UVstartVel,
			i_rVel_CoronaVel:= i_pstStSysParam^.astStRSV_GrpParam_Save[i_iGrpId].rVel_CoronaVel
			);
			
		fbKS_FB_MarkDetection(
			i_xEn :=TRUE,
			i_iGrpId:= i_iGrpId, 
			i_iGrpAxisNum_Pu:=i_iGrpAxisNum_Pu,(*色组轴数量|*)
			i_iGrpAxisTotalNum:=g_aiGrpUnitNum[i_iGrpId],(*系的总轴数量|*)
			i_paiGrpAxisList:=ADR(i_aiGrpAxisList),
			i_pstStSysParam :=i_pstStSysParam,
			i_pastStIOMap_Axis_FE:=i_pastStIOMap_Axis_FE,
			i_pastStAxisRapidAdjProf_V:=ADR(g_astStAxisRapidAdjProf_V),
			i_pstStEvtReq:= i_pstStEvtReq,
			i_xIsDebugMode:=i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xIsDebugMode_Machine
			);
		//2026.04.03.085929 | + | 增加欧诺特殊功能块
		fbKS_FB_SpecialFun_OuNuo(
			i_xEn:= i_iCustomerName= CUSTOMERNAME_ZHEJIANGOUNUO, 
			i_iGrpId:= i_iGrpId, 
			i_pstStSysParam:= i_pstStSysParam
			);
	ELSE
		o_iErNo:= -1;
	END_IF
END_IF