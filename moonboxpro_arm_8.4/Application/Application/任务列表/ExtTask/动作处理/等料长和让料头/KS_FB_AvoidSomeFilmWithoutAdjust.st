(*@CES
Name=KS_FB_AvoidSomeFilmWithoutAdjust
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=8d7384df-6643-485e-aae1-7ba7202eda50
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_AvoidSomeFilmWithoutAdjust(*开机让开1个机身料长不调整|*)
(*2023.2.26.212751
Liu.yt
调整了让料头位置计算方式
@简单处理了下压辊状态下压和非下压的料长计算
@非压辊的轴计算的距离是用于合压的轴对于自己是无意义的
准备重新处理开机等料长逻辑，由于现场需要让料头暂时先搁置这部分反正以前没有也用着呢*)
(*2023.2.27.122543 更新等料长逻辑*)
(*2023.6.1.110851 将让料头功能封装成了功能块,实现同时输出等料长从前一色和第一色两种标志*)
(*2023.08.07.160622 KS_FB_WaitFilmLenth_2023函数增加i_xUseLinkageList接口输入*)
(*增加接料完成接口-将内部使用的系参数标志替换为输入的@2024.01.19.152838*)
(*2024.7.26.170545 裁切让料头,修改为一直运算方式|根据标志决定是否输出*)
(*2024.7.31.165831 让料头输入修改为幅数*)
(*2025.2.18.152942 前一色让料头增加避让的系数@先不做成保持的吧*)
VAR_INPUT
	i_xEn: BOOL; (*印刷时使能标志*)
	i_iGrpId: INT; (*系id*)
	i_iGrpAxisNum_Pu: INT; (*色组数量*)
	i_aiGrpAxisList: ARRAY [1..MAX_UNIT_NUM] OF INT; (*系的轴列表|已经按照升序排列了*)
	i_pstStSysParam: POINTER TO StSysParam;
	i_pastStIOMap_AxisBasic: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF StIOMap_Axis_FE;(*基本io|*)

	(*2023.2.26.220010增加了 等料长 让料头使能标志*)
	i_xWaitFilmLenthEn:BOOL;(*等料长使能条件@界面开关+印刷状态+至少合压一色@大条件i_xEn就是印刷状态*)
	i_xGiveupHeaderEn:BOOL;(*让料头使能条件@界面开关+印刷状态@大条件i_xEn就是印刷状态*)
	i_iGrpLinkageAxisNum_Pu: INT; (* 系的色组联动轴数量|色组按照从小到大排序了 *)
	i_aiGrpLinkageAxisList: ARRAY [1..MAX_UNIT_NUM] OF INT; (* 系的联动轴列表 *)
	i_xWaitFilmLenth_From1stLinkageAxis:BOOL;(* 等待整机料长标志@2023.3.7.150604*)
	i_xStartAutoFind:BOOL;(*全自动找标打开标志@此时不能进入等料长逻辑|2023.6.1.155755*)
	i_xFlag_Cut_end_Uw:BOOL;(*增加接料完成接口@2024.01.19.152838*)
	i_iCycleTime_Plc:INT;(*2024.01.22.142804+*)
	(*2025.1.4.111759*)
	i_paxFlag_PressDne:POINTER TO ARRAY [1..MAX_UNIT_NUM] OF BOOL;(*实际压辊完成标志*)
END_VAR
VAR_OUTPUT
	o_xEno : BOOL;
END_VAR
VAR
	iA: INT;
	iN: INT;

	iAxisId: INT;
	xInitial_WaitFilmLen: BOOL;
	dwTempVal: DWORD;
	fbRTrig_CutEnd_Uw: R_TRIG; (*用来找裁切点的标志*)
	xInitial_GiveupHeader: BOOL;
	abyRunStep_GiveUp: ARRAY [1..MAX_UNIT_NUM] OF BYTE; (*1是按直接让料走; 2是等料头那部分*)
	alrFilmLength_GiveUp: ARRAY [1..MAX_UNIT_NUM] OF LREAL; (*不调整的部分*)
	alrFilmLength_Countdown: ARRAY [1..MAX_UNIT_NUM] OF LREAL; (*让料头要倒计的米数*)

	lrCurCycleFilmDisplacement: LREAL;
	(*2023.2.26.215555*)
	xFlag_Cut_end_Uw: BOOL;(*放料裁切完成标志*)
	xRollerPressDneSts: BOOL;(*压辊状态*)
	rFilmLenth: REAL;(*料膜长度临时变量*)
	rFilmLenth_Last: REAL;(*上一色的料膜长度*)
	rFilmLenth_Var: REAL;(*可变料长*)
	rFilmLenthFromPrevUnit: REAL;(*前一色和当前色之间的料长*)
	rFilmLenth_UnwindToPU1: REAL;(*放料裁切点到1色之间的距离*)

	fbKS_FB_WaitFilmLenth_2023_Follow1U: KS_FB_WaitFilmLenth_2023;(*从1色开始等待*)
	fbKS_FB_WaitFilmLenth_2023_FollowPreU: KS_FB_WaitFilmLenth_2023;(*从前一色开始等待*)

	axFlag_WaitFilmLenth_Follow1U: ARRAY [1..MAX_UNIT_NUM] OF BOOL;(*等料长跟一色*)
	axFlag_WaitFilmLenth_FollowPreU: ARRAY [1..MAX_UNIT_NUM] OF BOOL;(*等料长跟前一色*)

	(*2024.7.31.165128@使用幅数计算|界面的系参数修改为了幅数*)
	rFilmLen_NotAdjFront:REAL;(*料前长度*)
	rFilmLen_NotAdjBack:REAL;(*料后长度*)
	
	rVel_Film:REAL;(*料膜速度*)
	
END_VAR

{IMPLEMENTATION}
Action_Input();
Action_Act();
Action_Output();