(*@CES
Name=KS_FB_AxisVelCtl_PrnRoller
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=abdd25c9-7f8b-492e-b7cd-5839eca90f4a
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_AxisVelCtl_PrnRoller(*色组轴速度控制*)
(*在原来的联动状态下切换单联动状态并保持同步逻辑的基础上
兼容随时单联动切换的速度处理|目前只处理色组轴-2022.7.11.111134*)
VAR_INPUT
	i_xEn:BOOL;
	i_iGrpId: INT;
	i_xSwitchType0:BOOL;(*切换方式|TRUE：空转时候可以随时切换单联动轴的运动状态*)
	i_xSwitchType1:BOOL;(*切换方式|TRUE：空转状态下只能切换已经联动轴的运动状态|
						通过单联动旋钮处理，并能保证切换后相位能够保持之前状态*)
	i_xMotionStsSwitchEn:BOOL;(*切换使能*)
	i_xNeedKeepSync:BOOL;(*需要保证同步|在前往同步时候如果加减速有效了-则按照界面输入时间进行加减速|2022.7.21.174859*)
	i_iGrpAxisNum_Pu: INT; (*色组轴数量*)
	i_pstStSysParam: POINTER TO StSysParam;
//	i_pstStGrpParam: POINTER TO StGrpParam;(*系参数访问入口|*)
	i_paiGrpAxisList: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF INT; (*系内所有轴的列表*)
//	i_pastStAxisParam: POINTER TO ARRAY [1..MAX_STATION_NUM] OF StAxisParam;
	i_pastStIOMap_Main_FE						: POINTER TO ARRAY [1..4] OF StIOMap_Main_FE;(*轴io数据区域|AB系*)
	i_pastStIOMap_Axis_FE					: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF StIOMap_Axis_FE;(*轴io数据区域|`````````````````````````````````````````````*)
//	i_pastStIOMap_AxisBasic: POINTER TO ARRAY [1..MAX_STATION_NUM] OF StIOMap_AxisBasic;(*基础io映射表|*)
	i_pabyAxisMotionSts: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF BYTE;(*轴运动状态|*)
	i_paxAxisInching:POINTER TO ARRAY [1..MAX_UNIT_NUM] OF BOOL;(*轴在单运行|用于控制单运行指示灯显示*)
	i_paxLastAxisInchBtn:POINTER TO ARRAY [1..MAX_UNIT_NUM] OF BOOL;(*轴的单运行按钮保留值|用于判断沿*)
	i_iMaxVel_StsSwitch:INT;(*状态切换的最大速度*)


	i_palrAxisMotionVel:POINTER TO ARRAY [1..MAX_UNIT_NUM] OF LREAL;(*轴速度*)
	i_palrAcceleToSync:POINTER TO ARRAY [1..16] OF LREAL;(*用来保证同步的加速度|m/min/ms|16个轴*)
	i_palrTimeToSync:POINTER TO ARRAY [1..16] OF LREAL;(*同步加到目标速度的时间*)
	i_palrRelatePos_Final:POINTER TO ARRAY [1..16,1..16] OF LREAL;(*做成16个轴|
													记录目标轴和当前轴的相对位置值|最后恢复的位置差
													一维下标为当前轴号，二维下标为目标轴号*)
	i_palrRelatePosToSync:POINTER TO ARRAY [1..16,1..16] OF LREAL;(*做成16个轴|
												记录目标轴和当前轴的相对位置值|开始切换到同步状态时的位置差
												一维下标为当前轴号，二维下标为目标轴号*)
	i_xMotionEnabled: BOOL;(*可以规划速度已经使能|2022.7.14.133144*)
	i_xChangLinkageStsWhenPrint:BOOL;(*印刷时候可以切换单联动@2023.11.27.164606*)
	i_uiMaxVel_UseCalcAcc:UINT;(*用于计算最大加速度的最大速度@2024.04.12.180552*)
END_VAR
VAR_OUTPUT
	o_xEn:BOOL;
END_VAR
VAR
	fbKS_FB_GetAcceleToSync: KS_FB_GetAcceleToSync;
	bySwitchType: BYTE;(*切换方式|0-空转状态下不考虑单联动状态下都可以切换运动状态
								 |1-空转状态下只有处于联动状态下的轴可以切换*)
	xFlag_StsSwitchEn: BOOL;
	xVelPrfEn: BOOL;
	xNeedKeepSync: BOOL;(*需要保证位置同步|在到达同步状态时候*)
	axAxisVelPrfEn: ARRAY [1..MAX_STATION_NUM] OF BOOL;(*2022.12.26.135955+*)
END_VAR
{IMPLEMENTATION}
(*2020.12.24.145952 增加的开机后可以控制色组轴的运动速度|Liu.yt*)
bySwitchType:=255;
IF i_xSwitchType0 THEN
	bySwitchType:=0;
ELSIF i_xSwitchType1 THEN
	bySwitchType:=1;
END_IF

KS_GetMotionSts(
	i_iGrpId,
	i_xMotionStsSwitchEn AND bySwitchType<>255(*i_xMotionStsSwitchEn*),
	bySwitchType,(*I_bySwitchType*)
	i_iGrpAxisNum_Pu(*i_iGrpAxisNum_Pu*),
	i_pstStSysParam,
//i_pstStGrpParam(*i_pstStGrpParam*),
	i_paiGrpAxisList(*i_paiGrpAxisList*),
//	i_pastStAxisParam(*i_pastStAxisParam*),
	i_pastStIOMap_Main_FE,
	i_pastStIOMap_Axis_FE,
//	i_pastStIOMap_AxisBasic(*i_pastStIOMap_AxisBasic*),
	i_pabyAxisMotionSts(*i_pabyAxisMotionSts*),
	i_paxAxisInching(*i_paxAxisInching*),
	i_paxLastAxisInchBtn(*i_paxLastAxisInchBtn*),
	i_iMaxVel_StsSwitch(*i_iMaxVel_StsSwitch*),
	ADR(xFlag_StsSwitchEn)(*i_pxFlag_StsSwitchEn*),
	i_xChangLinkageStsWhenPrint(*i_xChangLinkageStsWhenPrint*));

fbKS_FB_GetAcceleToSync(
	i_xEn:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Ink ,(*只有空转才能使用*)
	i_iGrpId:= i_iGrpId,
	i_iGrpAxisNum_Pu:= i_iGrpAxisNum_Pu,
	i_pstStSysParam:= i_pstStSysParam,
	i_paiGrpAxisList:= i_paiGrpAxisList,
//	i_pastStAxisParam:= i_pastStAxisParam,
	i_pabyAxisMotionSts:= i_pabyAxisMotionSts,
	i_palrAcceleToSync:=i_palrAcceleToSync,
	i_palrTimeToSync:=i_palrTimeToSync,
	i_palrRelatePos_Final:=i_palrRelatePos_Final,
	i_palrRelatePosToSync:=i_palrRelatePosToSync,
	o_xEn=>);


(**控制速度规划*)
xNeedKeepSync:=i_xNeedKeepSync;
IF i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Accing OR
	i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Decing THEN
	xNeedKeepSync:=FALSE;(*如果有加速则取消同步*)
END_IF
KS_VelPrfByAxisMotionSts(
	i_iGrpId,
	i_iGrpAxisNum_Pu(*i_iGrpAxisNum_Pu*),
	i_pstStSysParam(*i_pstStGrpParam*),
	i_paiGrpAxisList(*i_paiGrpAxisList*),
//	i_pastStAxisParam(*i_pastStAxisParam*),
	i_pabyAxisMotionSts(*i_pabyAxisMotionSts*),
	i_palrAxisMotionVel(*i_palrAxisMotionVel*),
	i_palrAcceleToSync(*i_palrAcceleToSync*),
	i_xMotionEnabled,
	ADR(xVelPrfEn),
	xNeedKeepSync,
	ADR(axAxisVelPrfEn),
	i_uiMaxVel_UseCalcAcc);