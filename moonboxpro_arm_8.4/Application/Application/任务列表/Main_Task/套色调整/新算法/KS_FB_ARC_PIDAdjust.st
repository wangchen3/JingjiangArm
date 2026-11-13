(*@CES
Name=KS_FB_ARC_PIDAdjust
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=59760fa8-fe6e-4e2f-af44-67c784013cfb
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
(* 2016年9月7日 21:01:07
* 经过最终确认 CHEN.L
* 调整量输出单位为:um
*)
(*2023.6.6.114636 横向增加了快速调整逻辑@超过30丝限值使用单圈调整的量*)
(*2023.6.19.150310 将三段限值从<20<30修改为了<10<30*)
(*2023.07.27.173038 丢失后不再重新判断稳态*)
(*2023.08.10.101928-提前进入加速状态的时候|提前进入稳态@*)
(*2023.09.04.121600 扩展第3 4 5种计算方式@其中4 5为黄设计控制器
Kp Kd 输入值修改为了地址输入*)
(*2023.09.19.174407 替换第5种套色控制算法@LQR*)
(*2023.10.31.163658 输出调整量在非印刷状态下未被清除*)
(*2023.11.03.102625 增加了ki接口以及处理*)
(*2024.01.02.134324 检查套色误差是否到达一定范围，如果是则升速打开放大功能*)
(*2024.03.06.150648新的pid控制方案-增加飞点处理以及输出限值|输入误差使用剔除飞点后的。采样间隔再控制速度=0时使用当前速度*)
(*2024.03.24.153813 增加了纵向手动和自动才计算误差的条件*)
(*2024.03.24.204607 重新处理第三种套色方法@增量式pid|增加压辊合压输入
增加丢失3次后重新判定稳态逻辑
增加标志切换在稳态时第一个误差不做限制输出-且使增量式Kp的前一副误差为0
2024.03.26.120328 增加了在丢失多次时复位控制器,重新开始计算误差*)
(*2024.04.06.144325 gc_PID增加了最大输出的限值|*)
(*2024.04.09.084738 最大输出强制是1mm*)
(*2024.05.15.162716 增加加减速时候的调整量补偿值输入和叠加逻辑*)
(*2024.7.24.074359 将原来套色方式的p和i强制写成0,测试使用这两个值作为小黄算法中的pi@原来的i作为p值,d值作为i值*)
(*2024.7.25.163833 替换为Gc_PID_2024*)
(*2024.9.2.130103 增加KS_GetArcKAdjBySts函数调用*)
(*2024.12.7.160329 纵横向调整限值输入数据类型调整@原类型在低速大版辊,快调整速度时会有溢出风险*)
(*2025.1.2.155328 Cal_Kp_Ki_V2和Cal_Kp_Ki实现界面i_byArcPidGetType切换*)
(*2025.3.21.001325 等料长的时候不计算调整量@如果计算了而实际不执行则新的跟前一色解耦算法会计算解耦量*)
(*2025.5.15.225039  将NOT i_xUseGc_PID_2025条件下的套色算法优化了绝对值限值方法*)
(*2026.5.14.144234+ 删除无用的代码,同步小郭算法逻辑|方式7*)
FUNCTION_BLOCK KS_FB_ARC_PIDAdjust
VAR_INPUT
	i_byStateOfMotion:BYTE;(*机器运行状态，1印刷，0非印刷*)
	i_byModeOfAdjust :BYTE;(*调整方式选择，2表示变化量PID,1表示普通PID|3表示pd方式@2023.08.28.195231新增*)
	i_wErProf: WORD; (*误差点描述信息; bit0=1丢失; bit1=1飞点; bit2=1让料头*)
//	i_pstStAxisParam: POINTER TO StAxisParam; (*han.dp@2017-07-23 22:22:02*)
	i_iError_v: INT; (*当前色误差*)
	i_iError_h: INT; (*当前色误差*)
	i_xAccSpeedFlag:BOOL;(*加速标志@输入同样包含减速*)
	i_lrCurrVelocity:LREAL;(*当前线速度*)
(*	i_iMaxAdjustVal: INT;(*每幅的最大调整量，单位：um，且>0*)*)
	(*调整输入的数据类型@2024.12.7.154512|低速大版直径这个值类型转换时有概率溢出*)
	i_rMaxAdjustVal: REAL;(*每幅的最大调整量，单位：um，且>0*)
	i_xArcTest: BOOL := FALSE; (* 套色测试使能开关|liu.yt知道|@2020.7.15.151000 *)
	i_xArcTest_H:BOOL;(*2023.6.6.113741 横向套色调整算法测试标志@在大误差时候使用pid*)
(*	i_iMaxAdjustVal_H: INT;(*每幅的最大调整量，单位：um，且>0*)*)
	(*调整输入的数据类型@2024.12.7.154512|低速大版直径这个值类型转换时有概率溢出*)
	i_rMaxAdjustVal_H:REAL;
	i_rAcceleration_Max:REAL;(*最大加速度@m/min/s|正值*)
	i_rAcceleration_Cur:REAL;(*当前加速度@m/min/s|带符号*)
	(*2023.09.04.121636 增加pid的参数地址输入*)
	i_byParamIndex:BYTE;
	(*2023.09.02.133910 小黄测试控制器需要的保持变量*)
	i_uiControllerVel_Huang			:UINT:=30;(*控制器速度值|用于选择控制的速度项@取值30 100 200 260*)
	i_byFilmType					:BYTE;(*材料@=0 pet | =1 opp |=3 PE*)

	(*2024.7.26.143638|原套色算法*)
	i_pbyKp:POINTER TO BYTE;(*界面可以修改处理@2023.08.28.195000*)
	i_pbyKi:POINTER TO BYTE;(*界面可以修改处理@2023.11.03.102557*)
	i_pbyKd:POINTER TO BYTE;(*界面可以修改处理@2023.08.28.195000*)
	i_iError_Act_v: INT; (*当前色误差@没有飞点剔除*)

	i_iCustomId:INT;(*用户id*)
(*	i_byCanUseAccDecPid:BYTE;(*使用加速减速pid|=1 加速度系数补偿|=2 delta速度系数补偿*)*)
	(*2023.09.14.095050@输入色序id*)
	i_byArcId_Cur:BYTE;(*套色id*)
	i_byArcNum:BYTE;(*套色个数*)
	(*2023.09.19.094128*)
	(*2024.01.02.134433 这个标志临时用作加速时候使用新的切换pid方式@保证误差在一定范围内再切换*)
	(*2024.03.24.155512 标志作为第四种算法备份值更新方式切换标志*)
(*	i_xUseArcEst:BOOL;(*使用套色估计方法*)*)
	i_xFlag_RollerPressDne:BOOL;(*压辊合压标志@有效了才能计算调整量@2024.03.24.214610+*)
	i_xInitArcErr_AjdImmediately:BOOL;(*套色初始误差立刻调整,不再等待一幅后调整@2024.04.09.105623*)

(*	i_rErr_ArcAccOrDecCompensate:REAL;(*补偿的值@2024.05.15.161754*)*)
	i_byUseArcAccOrDecCompensate:BYTE;(*=3 =5 =6@Gc_TAOSE_SpeedUp*)
(*	i_rVResultCoeff_Follow1:REAL;(*跟踪第一色纵向结果系数@2024.05.19.141135*)*)
	i_rTarVel_ThisTime:REAL;(*加减速目标速度*)
	(**)
	i_xFlag_Acc:BOOL;
	i_xFlag_Dec:BOOL;
	i_rFilmLenth_InUnit:REAL;(*当前色机组料长@从上一个色开始mm|2024.7.26.134959*)
	(*新控制器的pid*)
	i_rKp_Gc:REAL;
	i_rKi_Gc:REAL;
	i_rKd_Gc:REAL;
	i_rN_Gc:REAL;

	i_byArcErrLimitToCtl_P:BYTE;(*输入到控制器的套色误差限制值@mm*)
	i_byArcErrLimitToCtl_I:BYTE;(*输入到控制器的套色误差限制值@mm*)
	(**横向补偿需要@2024.8.1.113359*)
	i_xCompensateEn_Hor:BOOL;(*横向补偿使能*)
	i_xCut_Uw:BOOL;(*放料裁切了@需要再收放料张力处理处获取*)
	i_xCut_Rw:BOOL;(*收料裁切了@需要再收放料张力处理处获取*)
	i_byCompensateValue_Hor:BYTE;(*横向补偿量@丝*)
	i_byMaxAddValue_Total_Hor:BYTE;(*补偿的最大阀值@MM*)
	(*2024.9.2.131404+*)
	i_byKadj_SetType:BYTE;(*套色K值设置方式@ =0|使用初始增益|=1根据状态设置*)
	(*2024.9.11.084123*)
	i_rTotalAdjustValue_Act:REAL;(*套色调整的总量@电机实际输出*)
	i_rFilmLenth_Eyes:REAL;(*到光电眼的距离@m*)
	i_uiArcSysDelayTime_ms:UINT;(*套色系统时延@ms*)
	(*2025.1.2.132826+*)
	i_byArcPidGetType:BYTE;(*套色pid获取获取方式|默认=Cal_Kp_Ki_V2|1=Cal_Kp_Ki_V3|2=Cal_Kp_Ki *)
	(*2025.1.15.175616+*)
	i_xUseGc_PID_2025:BOOL;
	i_xFlag_AdjValid_V: BOOL;(* 纵向自动 *)
	i_xFlag_AdjValid_H: BOOL;(* 横向开且自动 *)
	i_rDeadzoneMin_H: REAL;(* 横向不工作区/小/pdu通信协议采用x100整型传输 *)
	i_rDeadzoneMax_H: REAL;(* 横向不工作区/大/pdu通信协议采用x100整型传输 *)

	i_xWaitFilmLenth_FollowPreU:BOOL;(*等前色料长*)
	i_rGirth_Arc: REAL;
	(* 2021.12.3.121253/hdp/+入口参数 *)
	i_iKp_V: INT;(* 纵向Kp *)
	i_iKi_V: INT;(* 纵向Ki *)
	i_iKd_V: INT;(* 纵向Kd *)
	i_iKp_H: INT;(* 横向Kp *)
	i_iKi_H: INT;(* 横向Ki *)
	i_iKd_H: INT;(* 横向Kd *)	
	i_iMarkArrangeModal: INT;(*标序*)
	i_xAdjREV_V: BOOL;(* 纵向调整反向 *)
	i_xAdjREV_H: BOOL;(* 横向调整反向 *)
	i_xFollow_1U: BOOL;(*纵向跟踪第一色算误差*)
	i_xWaitFilmLenth_Follow1U: BOOL;(*等料长|1色*)
	i_xWaitFilmLength: BOOL;(*等料长-与原来一样*)
//	i_xWaitFilmLenth_FollowPreU: BOOL;(*不在等前一色料长的时候|进入计算调整逻辑中*)
	i_stStArc_Mol_Param	: StArc_Mol_Param;(*套色PID控制模型需要的参数-在轴参数里*)
	i_xFilmArrived_Cut:BOOL;
END_VAR

VAR_OUTPUT
	o_iVResult:INT; (*纵向调整量*)
	o_iVKp: INT; (*输出当前用的纵向Kp*)
	o_iVKi:INT;(*输出当前使用的纵向Ki*)
	o_iVKd: INT; (*输出当前用的纵向Kd*)
	o_iHResult:INT; (*横向调整量*)
	o_rKp_MolCal:REAL;
	o_rKi_MolCal:REAL;
END_VAR

VAR
	xWaitFilmLenth_V: BOOL;
	xWaitFilmLenth_H: BOOL;//2025.9.11.111950+
	aiKpKiKd_V: ARRAY [1..3] OF INT;(*纵向套色pid|*)
	aiKpKiKd_H: ARRAY [1..3] OF INT;(*横向套色pid|*)


	iPreVError: INT;		(*记录上次误差*)
	(*******************)
	(* follow added by HAN.DP @ 2016年9月7日 18:03:24 *)
	iPreHError: INT;		(*横向误差*)

	(*added by WU.XP @ 2016年9月18日 18:32:33*)
	i:INT;
	iErrorNum:INT:=3;
	aiPreVErrorArr: ARRAY[1..5] OF INT;		(*记录上次误差*)
	iGoalVErrorVal :INT;(*目标变化量*)
	iPreGoalVErrorVal :INT;(*上次误差的目标变化量*)
	xValidError :BOOL;(*有效误差*)
	iFirstRun :INT:=0;
	udiRunTime:UDINT:=0;(*记录执行次数*)


	aiPerPDChangeVError:ARRAY[1..30] OF INT:=[30(20)];
	iRemOverNum:INT;(*记录误差在10丝范围的点数*)
	xChangePDFlag:BOOL;(*PD值改变标志*)
	iCurrKp:INT;(*当前使用的P值*)
	iCurrKi:INT;(*当前使用的I值*)
	iCurrKd:INT;(*当前使用的D值*)
	iGoalVErrorChangeVal:INT;(*当前目标变化量的变化量*)
	aiPreGoalChangeVal:ARRAY[1..10] OF INT:=[10(0)];

	xPreAccSpeedFlag:BOOL;(*记录升速下降沿的*)
	xDelayAccLengFlag:BOOL;(*升速延时标志*)
	uiDelayAccLengNum:UINT;(*记录当前延时的幅数*)
	iMaxGoalErr_V:INT:=30;(*最大纵向误差目标变化量|单位丝*)

	(*2020.4.15.084027|增加了误差数组aiPreVErrorArr，实际有效误差的计数值，
	用来确定是否使用调整量计算公式中的变化量部分的量|Liu.yt*)
	iErrCnt_CalVResult:INT;
	iErrNum_CanCalVResult:INT:=2;(*能计算变化量增加的调整的误差个数*)
	iCoeff: INT;
	rTemp: REAL;
	uiAutoPIDChangNum: UINT;
	xPreErrInit_H: BOOL;(*2023.6.6.114858 横向的前一幅误差初始化*)
	iMaxAdjustVal_H: INT;(*2023.6.6.135805 横向最大调整量*)
	iLimitValue: INT;
	iKp_3rd: INT;(*实际使用*0.1*)
	iKi_3rd: INT;(*实际使用*0.1*)
	iKd_3rd: INT;(*实际使用*0.9*)

	(*小黄算法需要的变量*)
	rAcceleration:REAL:=0;(*加速度@m/min/s*)
	arEk_huang:ARRAY [1..2] OF REAL;(*误差寄存器 [e(k);e(k-1)]*)
(*2024.04.08.110810*)
(*	rYPk_huang:REAL;(*比例控制输出寄存器*)*)
	arYPk_huang:ARRAY [1..2] OF REAL;(*比例控制输出寄存器*)
	arYIk_huang:ARRAY [1..2] OF REAL;(*积分控制输出寄存器*)
	arYDk_huang:ARRAY [1..2] OF REAL;(*微分控制输出寄存器*)
	(*二次积分@2023.09.04.152516*)
	arYPIDk_Huang:ARRAY [1..2] OF REAL;(*PID控制器输出寄存器*)
(*2024.7.26.154730 屏蔽*)
	rYP2k_Huang:REAL;(*比例控制输出寄存器*)
	arYI2k_Huang:ARRAY [1..2] OF REAL;(*二次积分控制器输出寄存器*)

	rKp_GC: REAL;
	rKI_GC: REAL;
	rKD_GC: REAL;
	rN_GC: REAL;

	rLastResult_Huang:REAL;(*上个周期的结果*)
	rLastAcceleration_Max: REAL;

	(*2023.09.19.094021*)
	iK:INT;(*拍数计数*)
(*输出变量指针*)
	rWf:REAL;(*补偿量*)
	rLastWf:REAL;(*补偿量*)
	rDh:REAL;(*扰动估计量*)
(*上一拍的状态误差协方差矩阵Ph和状态矩阵Xh*)
	arPh:ARRAY [1..3,1..3] OF REAL;(*上一个周期的先验状态误差协方差矩阵*)
	arXh:ARRAY [1..3] OF REAL;(*上一个周期估计状态向量Xh指针*)

(*
	(*LQR套色控制需要@第5种*)
	arYout_BUF_LQR: ARRAY [1..2] OF REAL;(*控制器输出寄存器*)
	rLastYout_LQR: REAL;(*LQR控制器输出|上个周期*)
	rX2_LQR: REAL;(*X2状态寄存器，开始时清零*)

	(*MPC套色控制需要@第6种*)
	rLastYout_MPC: REAL;(*MPC控制器输出|上个周期*)
	rX2_MPC: REAL;(*X2状态寄存器，开始时清零*)
	rYout: REAL;(*控制器输出@LQR/MPC*)
*)
	(*2024.01.02.135532*)
	byCycleCnt: BYTE;
	xArcReachRangeFlag: BOOL;

	byLostCnt:BYTE;(*丢失计数@2024.03.24.215007+*)
	byLostNum:BYTE:=3;(*丢失次数|超过该值重新判定稳态*)
	xUseResultLimit: BOOL;(*控制是否使用调整量限制@纵向*)

	(*2024.04.06.143932 最大输出*)
	iMaxAdjustValue:INT;(*最大调整量@um*)


	(*控制器寄存器@2024.05.17.123933*)
	arGc_Uk:ARRAY [1..3] OF REAL;(*输入寄存器*)
	arGc_Yk:ARRAY [1..3] OF REAL;(*输出寄存器*)


	xGc_TAOSE_SpeedUp_Init: BOOL;
	xGc_Pid_Init: BOOL;
	xUseGc_TAOSE_SpeedUp: BOOL;

	xUseGc_Pid: BOOL;
	iErrValue_Use:INT;(*使用的误差值*)
	rErrValue_Use_4:REAL;(*第4种套色方法使用的误差值@2024.9.9.134142*)

(*
	(*Gc_Doubl_I 需要*)
	rYout_Double_I:REAL;
	rLastYout_Double_I:REAL;
	arGc_Uk_Double_I:ARRAY [1..3] OF REAL;(*输入寄存器*)
	arGc_Yk_Double_I:ARRAY [1..3] OF REAL;(*输出寄存器*)

	(*补偿计算出来的@SpliceCom*)
	rVResult_new: REAL;
*)
	(*横向补偿@2024.8.1.113608*)
	aiAdjValueList_Hor	: ARRAY [1..10] OF INT;(*调整量列表*)
	aiArcErrList_Hor	: ARRAY [1..10] OF INT;(*误差列表*)
	xWatching_Hor		: BOOL;(*横向补偿监控中@是否有丢失*)
	xOuting_Hor			: BOOL;(*横向补偿中*)
	xOutDne_Hor			: BOOL;(*横向补偿完成*)
	byLostCnt_Hor		: BYTE;(*横向丢失次数*)
	rResult_Total_Hor	: REAL;(*补偿的总量*)
	rCompensateValue_Hor: REAL;(*接料后补偿的值*)
	xArcCompensateEn_Hor: BOOL;(*横向补偿使能*)

	(*2024.9.2.124636*)
	xCutting: BOOL;
	aiErrValueList: ARRAY [0..20] OF INT;
	rKadj_Pid: REAL;
	rKadj_I: REAL;
	rCurrVelocity_Ki: REAL;(*Ki的当前速度@根据状态可以切换*)
	(*2024.9.9.121205+*)
	arAntiNotchU_Uk: ARRAY [1..3] OF REAL;
	arAntiNotchU_Yk: ARRAY [1..3] OF REAL;
	rTs: REAL;(*采样周期-单位s@版辊转动一圈的时间*)
	rAntiNotch_Out: REAL;(*经过陷波器的输出值*)

	(*2024.9.11.084531+SMITH环节*)
	xSmithInit: BOOL;(*初始化标志*)
	rSmith_Out: REAL;(*输出*)
	rTotalAdjustValue_Act: REAL;
(*寄存器  初始值0*)
(*0.1a/(s+a)*)
	arTF1Uk_Smith: ARRAY [1..2] OF REAL;(*输入寄存器*)
	arTF1Yk_Smith: ARRAY [1..2] OF REAL;(*输出寄存器*)
(*滑动滤波器(长度3) 1/3(z^2+z+1)/z^2*)
	arTF2Uk_Smith: ARRAY [1..3] OF REAL;(*输入寄存器*)
	arTF2Yk_Smith: ARRAY [1..3] OF REAL;(*输出寄存器*)
(*纯时延*)
	arDELUk_Smith: ARRAY [1..gc_iNDEL] OF REAL;(*输入寄存器*)
	iNDEL: INT;(*到光电眼位置间隔幅数*)

	(*SMITH-PI*)

	rSmith_Out_PI: REAL;(*输出*)
(*寄存器  初始值0*)
	arPIUk_SmithPI: ARRAY [1..2] OF REAL;(*输入寄存器*)
	arPIYk_SmithPI: ARRAY [1..2] OF REAL;(*输出寄存器*)
(*0.1a/(s+a)*)
	arTF1Uk_SmithPI: ARRAY [1..2] OF REAL;(*输入寄存器*)
	arTF1Yk_SmithPI: ARRAY [1..2] OF REAL;(*输出寄存器*)
(*滑动滤波器(长度3) 1/3(z^2+z+1)/z^2*)
	arTF2Uk_SmithPI: ARRAY [1..3] OF REAL;(*输入寄存器*)
	arTF2Yk_SmithPI: ARRAY [1..3] OF REAL;(*输出寄存器*)
(*纯时延*)
	arDELUk_SmithPI: ARRAY [1..gc_iNDEL] OF REAL;(*输入寄存器*)
	byPrevModeOfAdjust: BYTE;
	(*2024.9.12.175547+*)
	xAvoidFilmHead: BOOL;
	xPrevAvoidFilmHead: BOOL;
	iErrValueDir: INT;(*误差方向=1 为正|=-1 为负*)
	iAvoidFilmHeadEndCnt: INT;		(*避让料头结束计数*)
	iAvoidFilmHeadEndNum_Max: INT:=3;

(*2024.9.13.105607+Periodic*)
	rTk: REAL;(*时间寄存器*)
	rTheta1k: REAL;(*Theta1寄存器*)
	rTheta2k: REAL;(*Theta2寄存器*)
	rYout_Periodic: REAL;
	iUseMaxAdjValue: INT:=0;(*使用最大调整量@1 为正|-1为负|0 无效*)
	
//2025.03.20.170045 | 升降速过程中需要实时修改裕值
	rMargin_Mag_Arc : REAL;	
	rSigema_PID: REAL;(*pid累计限值@2025.5.15.224315*)
	rReal_Delta_PID:REAL;(*实际的增量值@2025.5.15.230603*)	
	
	//2026.5.14.144159+ 小郭算法增加
    arrE    : ARRAY[1..2] OF LREAL; (* 指向输入历史, 大小 2 *)
    arrU    : ARRAY[1..2] OF LREAL; (* 指向状态历史, 大小 3 *)
END_VAR

VAR CONSTANT
	c_PIDAutoChangNum:UINT:=20;(*判断进去稳态的幅数*)
	c_DelayAccLeng:UINT:=20;(*加速延时幅数*)
END_VAR
{IMPLEMENTATION}
IF i_xFollow_1U THEN(*纵向跟踪第一色色标计算误差*)
	xWaitFilmLenth_V:= i_xWaitFilmLenth_Follow1U;
ELSE(*跟踪前一色色标计算误差*)
	xWaitFilmLenth_V:= i_xWaitFilmLength;	(*和以前一样*)
END_IF
xWaitFilmLenth_H:=xWaitFilmLenth_V;//2025.9.11.111904+横向让料头

aiKpKiKd_V[1]:= i_iKp_V;
(*强制将原来方式的i和d写成0@2024.7.24.074336*)
aiKpKiKd_V[2]:= 0;
aiKpKiKd_V[3]:= 0;
(*
aiKpKiKd_V[2]:= BYTE_TO_INT(DWORD_TO_BYTE(SHR(i_pstStAxisParam^.dwKpid_V, 8)));
aiKpKiKd_V[3]:= BYTE_TO_INT(DWORD_TO_BYTE(i_pstStAxisParam^.dwKpid_V));
*)

aiKpKiKd_H[1]:= i_iKp_H;
aiKpKiKd_H[2]:= i_iKi_H;
aiKpKiKd_H[3]:= i_iKd_H;

(*pid获取方式重新处理下@2023.08.28.194612*)
iKp_3rd:=2;
IF i_pbyKp<>0 THEN
	iKp_3rd:=BYTE_TO_INT(i_pbyKp^);
END_IF

(*2023.11.03.102658调整*)
iKi_3rd:=0;
IF i_pbyKi<>0 THEN
	iKi_3rd:=BYTE_TO_INT(i_pbyKi^);
END_IF


iKd_3rd:=0;
IF i_pbyKd<>0 THEN
	iKd_3rd:=BYTE_TO_INT(i_pbyKd^);
END_IF

IF i_rGirth_Arc<>0 THEN
	IF ABS(i_rFilmLenth_Eyes/i_rGirth_Arc)<0.5 THEN
		iNDEL:=1;
	ELSE
		iNDEL:=LREAL_TO_INT(i_rFilmLenth_Eyes/i_rGirth_Arc-0.5)+1;
	END_IF
ELSE
	iNDEL:=1;
END_IF



rLastAcceleration_Max:=i_rAcceleration_Max;
rAcceleration:=i_rAcceleration_Cur;
(*2024.03.24.154002 |套色自动的时候才能进入调整量计算case*)
IF i_xFlag_AdjValid_V AND(*自动才进入调整|*)
	(*2025.3.6.100432先屏蔽了，没有合压和让料头*)
	(NOT i_xWaitFilmLenth_FollowPreU) AND(*不在等前一色料长的时候|进入计算调整逻辑中*)
	i_xFlag_RollerPressDne THEN;(*压辊合压了才能计算调整量*)
ELSE(*套色手动了或者在等料长呢|将状态变量i_byStateOfMotion强制写成非1*)
	i_byStateOfMotion:=0;
END_IF
xUseResultLimit:=TRUE;(*默认是使用的*)

(*2024.04.06.144240+*)
(*2024.12.7.160442 优化处理*)
IF i_rMaxAdjustVal>g_uiArcAdjValue_Max THEN
	iMaxAdjustValue:= UINT_TO_INT(g_uiArcAdjValue_Max);
ELSE
	iMaxAdjustValue:= REAL_TO_INT(i_rMaxAdjustVal);
END_IF


iErrValue_Use:=i_iError_v;(*获取使用的误差变量*)

(*2024.9.9.120736 增加了反陷波器*)
IF i_lrCurrVelocity<>0 THEN
	rTs:= LREAL_TO_REAL(i_rGirth_Arc/1000.0/i_lrCurrVelocity*60.0);
ELSE(*按照10m/min计算一个值*)
	rTs:= i_rGirth_Arc/1000.0/10.0*60.0;
END_IF
(*
(*2024.9.2.084107 增加根据状态切换增益的实现*)
IF i_stStArc_Mol_Param.rKadj_PID_Mol=0 THEN
	i_stStArc_Mol_Param.rKadj_PID_Mol:=20;
END_IF
IF i_stStArc_Mol_Param.rKadj_I_Mol=0 THEN
	i_stStArc_Mol_Param.rKadj_I_Mol:=1.5;
END_IF
IF i_stStArc_Mol_Param.rKadj_PID_Mol_SteadySts=0 THEN
	i_stStArc_Mol_Param.rKadj_PID_Mol_SteadySts:=20;
END_IF
IF i_stStArc_Mol_Param.rKadj_I_Mol_SteadySts=0 THEN
	i_stStArc_Mol_Param.rKadj_I_Mol_SteadySts:=1;
END_IF
KS_GetArcKAdjBySts(
	i_byStateOfMotion<>0(*i_xEn*),
	i_byKadj_SetType(*i_byKadj_SetType*),
	i_stStArc_Mol_Param.rKadj_PID_Mol(*i_rKadj_PID_Mol_Init*),
	i_stStArc_Mol_Param.rKadj_I_Mol(*i_rKadj_I_Mol_Init*),
	i_stStArc_Mol_Param.rKadj_PID_Mol_SteadySts(*i_rKadj_PID_Mol_SteadySts*),
	i_stStArc_Mol_Param.rKadj_I_Mol_SteadySts(*i_rKadj_I_Mol_SteadySts*),
	i_xCut_Uw(*i_xCut*),
	(*即使让料头不使能也会输出*)
	i_xFilmArrived_Cut,
	NOT(i_xFlag_Acc OR i_xFlag_Dec)(*i_xEvenning*),
	LREAL_TO_INT(i_lrCurrVelocity)(*i_iVel_Cur*),
	iErrValue_Use(*i_iErrValue*),
	30(*i_byErrThreshold*),
	10(*i_byDeltaErrThreshold*),
	100(*i_iVelThreshold*),
	ADR(xCutting)(*i_pxCutting*),
	ADR(aiErrValueList)(*i_paiErrValueList*),
	ADR(i_stStArc_Mol_Param.byArcAdjSts)(*i_pbyArcAdjSts*),
	ADR(rKadj_Pid)(*i_prKadj_Pid*),
	ADR(rKadj_I)(*i_prKadj_I*),
	ADR(rCurrVelocity_Ki)(*i_prVel_Ki*));
*)
(*2025.1.2.130733 增加V2*)
(*2025.1.11.170708 增加V3*)
IF i_stStArc_Mol_Param.rMargin_Mag_Arc=0 THEN
	i_stStArc_Mol_Param.rMargin_Mag_Arc:=20;
END_IF
IF i_stStArc_Mol_Param.rMargin_Phi_Arc=0 THEN
	i_stStArc_Mol_Param.rMargin_Phi_Arc:=50;
END_IF
IF i_stStArc_Mol_Param.rKadj_I_Mol=0 THEN
	i_stStArc_Mol_Param.rKadj_I_Mol:=1.5;
END_IF
(*2026.5.14.192142+ 小郭算法需要的参数初值处理*)
IF i_stStArc_Mol_Param.rPM_deg = 0 THEN
	i_stStArc_Mol_Param.rPM_deg:=60;
END_IF
IF i_stStArc_Mol_Param.rWc_Ts = 0 THEN
	i_stStArc_Mol_Param.rWc_Ts:=0.3;
END_IF

(*
(*2024.7.28.105603*)
IF i_byArcPidGetType=2 THEN
	(*rKadj_Pid 越大越强*)
	Cal_Kp_Ki(
		(*2024.9.6.123526 写入定值*)
		LREAL_TO_REAL(i_lrCurrVelocity)(*i_rV*),
		rCurrVelocity_Ki(*i_rV_Ki*),
		400(*i_pstStAxisParam^.lrGirth*)(*i_rCL*),(*版辊周长写死@按照现场测试的值输入*)
		i_rFilmLenth_InUnit/1000(*i_rL*),
		(*2024.9.2.124758 替换*)
		rKadj_Pid(*i_pstStAxisParam^.rKadj_PID_Mol*)(*i_rKadj_all*),
		rKadj_I(*i_pstStAxisParam^.rKadj_I_Mol*)(*i_rKadj_i*),
		ADR(i_stStArc_Mol_Param.rKp_MolCal)(*i_prKp*),
		ADR(i_stStArc_Mol_Param.rKi_MolCal)(*i_prKi*));
ELSIF i_byArcPidGetType=1 THEN
	(*保守点i_rMargin_Mag默认取了20db@l.yt*)
	(*默认i_rMargin_Phi取50度*)
	Cal_Kp_Ki_V3(
		LREAL_TO_REAL(i_lrCurrVelocity)(*i_rV*),
		i_rFilmLenth_Eyes(*i_rLTao*),
		i_rFilmLenth_InUnit/1000(*i_rL*),
		i_stStArc_Mol_Param.rMargin_Mag_Arc,//2025.03.20.170350 | 升降速需要实时修改| i_stStArc_Mol_Param.rMargin_Mag_Arc(*i_rMargin_Mag*),
		i_stStArc_Mol_Param.rMargin_Phi_Arc(*i_rMargin_Phi*),
		ADR(i_stStArc_Mol_Param.rKp_MolCal)(*i_prKp*),
		ADR(i_stStArc_Mol_Param.rKi_MolCal)(*i_prKi*));
ELSE
*)
	(*rKadj_Pid 越小越强*)
	Cal_Kp_Ki_V2(
		LREAL_TO_REAL(i_lrCurrVelocity)(*i_rV*),
		i_rFilmLenth_Eyes(*i_rLTao*),
		i_rFilmLenth_InUnit/1000(*i_rL*),
		(*pt执行的0.1+固定的0.6*)
		UINT_TO_REAL(i_uiArcSysDelayTime_ms)/1000(*0.7*)(*i_rDelay*),(*增加了时延参数输入@2025.1.15.123529*)
		i_stStArc_Mol_Param.rMargin_Mag_Arc,//2025.03.20.170350 | 升降速需要实时修改| i_stStArc_Mol_Param.rMargin_Mag_Arc(*i_rMargin_Mag*),
		i_stStArc_Mol_Param.rKadj_I_Mol(*i_rKadj_i*),
		ADR(i_stStArc_Mol_Param.rKp_MolCal)(*i_prKp*),
		ADR(i_stStArc_Mol_Param.rKi_MolCal)(*i_prKi*));
(*END_IF*)

(*
(*结构体参数非法初始化@2024.05.19.105724*)
IF i_stStArc_Mol_Param.stStArcSpeedUpParam.rK=0 THEN
	i_stStArc_Mol_Param.stStArcSpeedUpParam.rK:=1;
END_IF
IF i_stStArc_Mol_Param.stStArcSpeedUpParam.rA2=0 THEN
	i_stStArc_Mol_Param.stStArcSpeedUpParam.rA2:=40;
END_IF
IF i_stStArc_Mol_Param.stStArcSpeedUpParam.rA1=0 THEN
	i_stStArc_Mol_Param.stStArcSpeedUpParam.rA1:=6;
END_IF
IF i_stStArc_Mol_Param.stStArcSpeedUpParam.rA0=0 THEN
	i_stStArc_Mol_Param.stStArcSpeedUpParam.rA0:=0.01;
END_IF

(*参数初始化@2024.9.9.123138+*)
IF i_stStArc_Mol_Param.rWn_Arc=0 THEN
	i_stStArc_Mol_Param.rWn_Arc:=0.08;
END_IF
IF i_stStArc_Mol_Param.rBw_Arc=0 THEN
	i_stStArc_Mol_Param.rBw_Arc:=0.08;
END_IF
IF i_stStArc_Mol_Param.rDp_Arc=0 THEN
	i_stStArc_Mol_Param.rDp_Arc:=10;
END_IF

(*2024.9.13.110747+*)
(*参数初始化*)
IF i_stStArc_Mol_Param.rG_Periodic=0 THEN
	i_stStArc_Mol_Param.rG_Periodic:=0.5;
END_IF
IF i_stStArc_Mol_Param.rW_Periodic=0 THEN
	i_stStArc_Mol_Param.rW_Periodic:=2;
END_IF
(*
(*不用的时候清零临时变量*)
IF NOT i_pstStAxisParam^.xUsePeriodic THEN
	rYout_Periodic:=0;
	rTk:=0;
	rTheta1k:=0;
	rTheta2k:=0;
END_IF
*)

(*陷波器一直运算@2024.9.9.124745*)
IF i_byStateOfMotion=1 AND NOT i_wErProf.0 AND(*套色调整并,未丢失的时候*)
	i_lrCurrVelocity > 10 THEN
	AntiNotch(
		INT_TO_REAL(i_iError_v)(*i_rU*),
		ADR(rAntiNotch_Out)(*i_prYout*),
		i_stStArc_Mol_Param.rWn_Arc(*i_rWn*),
		i_stStArc_Mol_Param.rBw_Arc(*i_rBw*),
		i_stStArc_Mol_Param.rDp_Arc(*i_rDp*),
		rTs(*i_rTs*),
		ADR(arAntiNotchU_Uk)(*i_prUk*),
		ADR(arAntiNotchU_Yk)(*i_prYk*));
ELSE
	(*2024.9.9.124630+*)
	IF i_byStateOfMotion=0 THEN
		SysMemSet(ADR(arAntiNotchU_Uk),0,SIZEOF(arAntiNotchU_Uk));
		SysMemSet(ADR(arAntiNotchU_Yk),0,SIZEOF(arAntiNotchU_Yk));
	END_IF
END_IF
*)

(*让料头@检索变相时退出|2024.9.12.182058*)
IF i_byStateOfMotion=1 THEN
	IF i_wErProf.2 AND NOT xPrevAvoidFilmHead THEN(*开始让料头了|*)
		xAvoidFilmHead:=TRUE;
		iErrValueDir:=0;
		iAvoidFilmHeadEndCnt:=0;
	END_IF

	(*处于让料头的时候记录误差正负*)
	IF xAvoidFilmHead THEN
		IF iErrValueDir=0 THEN(*直到找到符号*)
			IF iErrValue_Use>0 THEN
				iErrValueDir:=1;
			ELSIF iErrValue_Use<0 THEN
				iErrValueDir:=-1;
			END_IF
		END_IF

		(*退出让料头了|等待变相后再退出|临时先定最多等5幅*)
		IF NOT i_wErProf.2 THEN
			iAvoidFilmHeadEndCnt:=iAvoidFilmHeadEndCnt+1;
			IF iErrValueDir=1 THEN(*误差是正值*)
				IF iErrValue_Use<=0 THEN(*变为负值*)
					xAvoidFilmHead:=FALSE;
				END_IF
			ELSIF iErrValueDir=-1 THEN(*误差是负值*)
				IF iErrValue_Use>=0 THEN(*变为正值*)
					xAvoidFilmHead:=FALSE;
				END_IF
			END_IF
			IF iAvoidFilmHeadEndCnt>=iAvoidFilmHeadEndNum_Max THEN
				xAvoidFilmHead:=FALSE;
			END_IF
		END_IF
	ELSE
		iAvoidFilmHeadEndCnt:=0;
	END_IF
	xPrevAvoidFilmHead:=i_wErProf.2;
ELSE
	xPrevAvoidFilmHead:=FALSE;
	iAvoidFilmHeadEndCnt:=0;
	iErrValueDir:=0;
END_IF
xAvoidFilmHead:=FALSE;(*2025.1.12.004531 相当于把上面的逻辑屏蔽了*)


iUseMaxAdjValue:=0;(*2025.2.8.092826 初始化*)
CASE i_byModeOfAdjust OF (*PID算法选择*)
	1: (*普通PID*)
		IF i_wErProf.0 OR i_wErProf.1 OR i_wErProf.2 THEN (*丢失和飞点/让料头 都放弃处理*)
			o_iVResult :=0;
			iPreVError:=0;
		ELSE (*有效误差*)

			o_iVResult:=aiKpKiKd_V[1]*iErrValue_Use/2+aiKpKiKd_V[3]*(iErrValue_Use-iPreVError)/2;
			iPreVError:=iErrValue_Use;
		END_IF

	2,(*3,*)4,7:(*5,6,7:*) (*变化量PID@算法扩展*)
		CASE i_byStateOfMotion OF (*印刷状态*)
			1:(*印刷*)

				(*丢失达到3幅-重新判断稳态@2024.03.24.211343*)
				IF i_wErProf.0 THEN(*丢失*)
					IF byLostCnt<byLostNum THEN
						byLostCnt:=byLostCnt+1;
					END_IF
				ELSE(*偶尔丢失一次则不重新判断*)
					byLostCnt:=0;
				END_IF
				(*2024.9.12.181713 增加xAvoidFilmHead标志@让料头*)
				IF (i_wErProf.0 OR i_wErProf.1 OR i_wErProf.2 OR xAvoidFilmHead OR xAvoidFilmHead) OR
					xWaitFilmLenth_V THEN(*2025.3.21.001233 增加纵向等料长时候不计算*)
					(*丢失达到3幅-重新判断稳态@2024.03.24.211343*)
					(*2024.8.1.154609 让料头不复位控制器*)
					IF (byLostCnt>=byLostNum) OR i_wErProf.2 OR xAvoidFilmHead OR
					 xWaitFilmLenth_V THEN(*2025.3.21.001233 增加纵向等料长时候不计算*)
						o_iVResult:=0;
						IF (byLostCnt>=byLostNum) THEN(*只有丢失才清除*)
							iFirstRun:=0;(*清空标志*)
							udiRunTime:=0;
							xValidError:=FALSE;

							(*清空PID值变化标志*)
							FOR i:=1 TO 30 BY 1 DO
								aiPerPDChangeVError[i]:=100;
							END_FOR
							iRemOverNum:=0;
							xChangePDFlag:=FALSE;
						END_IF

						(*2016年10月14日 13:44:53 清空目标变化量*)
						FOR i:=1 TO 10 BY 1 DO
							aiPreGoalChangeVal[i]:=0;
							(*2024.03.26.113305|清零*)
							IF i<=2 THEN(*2023.08.29.161511*)
								arEk_huang[i]:=0;
								arYPk_huang[i]:=0;
								arYIk_huang[i]:=0;
								arYDk_huang[i]:=0;
								(*二次积分*)
								arYPIDk_Huang[i]:=0;
								arYI2k_Huang[i]:=0;
								
								(*小郭双积分代码@2026.5.14.144658+*)
								arrE[i]:=0;
								arrU[i]:=0;
							END_IF
							
						END_FOR


						(*2024.03.26.115617同步清除*)
						rYP2k_Huang:=0;(*二次积分*)
						rLastResult_Huang:=0;
						rSigema_PID:=0;(*清零绝对值限值@2025.5.15.225514*)
						rReal_Delta_PID:=0;

						(*套色补偿算法中变量@2023.09.19.095515*)
						iK:=0;
						rWf:=0;
						rLastWf:=0;
						rDh:=0;
						SysMemSet(ADR(arPh),0,SIZEOF(arPh));
						SysMemSet(ADR(arXh),0,SIZEOF(arXh));

(*
						(*LQR*)
						rX2_LQR:=0;
						arYout_BUF_LQR[1]:=0;
						arYout_BUF_LQR[2]:=0;
						rLastYout_LQR:=0;
						(*mpc算法*)
						rX2_MPC:=0;
						rLastYout_MPC:=0;
						rYout:=0;

						(*2024.7.26.141031+*)
						SysMemSet(ADR(arGc_Uk_Double_I),0,SIZEOF(arGc_Uk_Double_I));
						SysMemSet(ADR(arGc_Yk_Double_I),0,SIZEOF(arGc_Yk_Double_I));
						rYout_Double_I:=0;
						rLastYout_Double_I:=0;
*)
						(*升速控制器@2024.05.17.132443*)
						SysMemSet(ADR(arGc_Uk),0,SIZEOF(arGc_Uk));
						SysMemSet(ADR(arGc_Yk),0,SIZEOF(arGc_Yk));

						xArcReachRangeFlag:=FALSE;
						byCycleCnt:=0;

						(*2024.9.12.155429*)
						xSmithInit:=TRUE;
						rSmith_Out:=0;
						rTotalAdjustValue_Act:=0;
						SysMemSet(ADR(arTF1Uk_Smith),0,SIZEOF(arTF1Uk_Smith));
						SysMemSet(ADR(arTF1Yk_Smith),0,SIZEOF(arTF1Yk_Smith));
						SysMemSet(ADR(arTF2Uk_Smith),0,SIZEOF(arTF2Uk_Smith));
						SysMemSet(ADR(arTF2Yk_Smith),0,SIZEOF(arTF2Yk_Smith));
						SysMemSet(ADR(arDELUk_Smith),0,SIZEOF(arDELUk_Smith));
						(*2024.9.13.110903 也清除吧*)
						rYout_Periodic:=0;
						rTk:=0;
						rTheta1k:=0;
						rTheta2k:=0;
					ELSE (*飞点处理*)
						o_iVResult:=0;
						iFirstRun:=0;(*清空标志*)
						iGoalVErrorChangeVal:=0;(*当前目标变化量*)
					END_IF

					(*2024.04.09.110816*)
					IF i_xInitArcErr_AjdImmediately THEN
						iErrCnt_CalVResult:=1;(*写成1,不会等待一副后调整*)
					ELSE
						(*2020.7.9.124302|增加在非有效误差时清零该新增计数|Liu.yt*)
						(*导入的时候忘记写入了*)
						iErrCnt_CalVResult:=0;
					END_IF
				ELSE (*有效误差*)
					(*开始前三幅误差变化量不能超30*)
					udiRunTime:=udiRunTime+1;

					IF NOT xValidError AND udiRunTime>=3THEN
						FOR i:=1 TO iErrorNum-2 BY 1 DO
							IF ABS(aiPreVErrorArr[i+1]-aiPreVErrorArr[i+2])<=30(*30*) AND ABS(aiPreVErrorArr[iErrorNum]-iErrValue_Use)<=30THEN
								xValidError:=TRUE;
(*
								(*2024.03.24.211457 清除稳态判断的误差列表@保证第一个调整量可以调整*)
								IF i_xUseArcEst THEN(*标志复用@清零储存的误差数组*)
									SysMemSet(ADR(aiPreVErrorArr),0,SIZEOF(aiPreVErrorArr));
									iErrCnt_CalVResult:=1;(*计数强制写1,保证这个周期可以输出调整量*)
									xUseResultLimit:=FALSE;(*这次调整量不限值*)
								END_IF
*)
							ELSE
								xValidError:=FALSE;
								EXIT;
							END_IF
						END_FOR
					END_IF

					IF xValidError THEN
						(*检查色组是否到达阈值@到达范围后再启动升速pid放大功能*)
						KS_ArcAxisReachRange(
							TRUE (*i_xEn*),
							i_byArcId_Cur(*i_byArcId*),
							30(*i_byArcErr_Threshold*),
							10(*i_byContinuousCycleCnt*),
							TRUE(*i_xArcErrValid*),
							iErrValue_Use(*i_iArcErr*),
							ADR(byCycleCnt)(*i_pbyCycleCnt*),
							ADR(xArcReachRangeFlag)(*i_xArcReachRangeFlag*));

						(*一直执行满足一定条件后放大pid-i_xUseArcEst 做别的应用了@2024.03.24.155440*)
						(*IF NOT i_xUseArcEst THEN(*复用了标志@2023.12.25.111355*)
							xArcReachRangeFlag:=TRUE;(*一直升速放大*)
						END_IF*)


						(*计算当前误差的目标变化值*)
						IF NOT xChangePDFlag THEN (*误差没有稳定*)
							IF iFirstRun=0 THEN (*第一次调整D值为0*)
								iFirstRun:=iFirstRun+1;
								iCurrKp:=aiKpKiKd_V[1]*10;
								iCurrKi:=0;
								iCurrKd:=0;
							ELSE
								iCurrKp:=aiKpKiKd_V[1]*10;
								iCurrKi:=0;
								iCurrKd:=aiKpKiKd_V[3]*10;
							END_IF
						ELSE (*连续八幅误差在10丝内*)

							IF i_lrCurrVelocity>150 THEN
								iCurrKp:=LREAL_TO_INT(aiKpKiKd_V[1]*2.5);
								iCurrKi:=0;
								iCurrKd:=aiKpKiKd_V[3]*5;
							ELSIF i_lrCurrVelocity<=20 THEN
								iCurrKp:=aiKpKiKd_V[1]*5;
								iCurrKi:=0;
								iCurrKd:=aiKpKiKd_V[3]*5;
							ELSE
								iCurrKp:=LREAL_TO_INT(aiKpKiKd_V[1]*5-(i_lrCurrVelocity-20)/(150-20)*(aiKpKiKd_V[1]*(5-2.5)));
								iCurrKi:=0;
								iCurrKd:=aiKpKiKd_V[3]*5;
							END_IF

							(*2016年10月25日11:42:11 add by WU.XP 增加加速延时标志*)
							IF NOT i_xAccSpeedFlag AND xPreAccSpeedFlag THEN (*沿判断加减速结束，开始延时*)
								xDelayAccLengFlag:=TRUE;
								uiDelayAccLengNum:=0;
							END_IF
							xPreAccSpeedFlag:=i_xAccSpeedFlag;

							IF xDelayAccLengFlag THEN
								uiDelayAccLengNum:=uiDelayAccLengNum+1;
								IF uiDelayAccLengNum>c_DelayAccLeng THEN
									xDelayAccLengFlag:=FALSE;
									uiDelayAccLengNum:=0;
								END_IF
							END_IF

							(*2023.12.25.110717 加速时放大pid增加了条件限制@误差到达一定范围内,未考虑误差变化量*)
							IF (i_xAccSpeedFlag OR xDelayAccLengFlag)AND (*加速中*)
								xArcReachRangeFlag THEN(*2023.12.25.110849*)
								iCurrKp:=iCurrKp*2;
								iCurrKi:=iCurrKi*2;
								iCurrKd:=iCurrKd*2;
							END_IF

							(*80m/min之前调整量翻倍*)

							(*|2019.06.26.084724|Niu.j|之前是*2|80米之前加速过程PID值线性减小*)
							(*2023.12.25.110717 加速时放大pid增加了条件限制@误差到达一定范围内,未考虑误差变化量*)
							IF (*TRUE*)xArcReachRangeFlag THEN
								IF i_xAccSpeedFlag AND i_lrCurrVelocity<80 AND i_lrCurrVelocity>=10 THEN
									iCurrKp:=LREAL_TO_INT(INT_TO_LREAL(iCurrKp)*(2-(i_lrCurrVelocity-10)/(80-10)));
									iCurrKi:=LREAL_TO_INT(INT_TO_LREAL(iCurrKi)*(2-(i_lrCurrVelocity-10)/(80-10)));
									iCurrKd:=LREAL_TO_INT(INT_TO_LREAL(iCurrKd)*(2-(i_lrCurrVelocity-10)/(80-10)));
								END_IF
							END_IF
						END_IF


(*						IF i_byModeOfAdjust=3 THEN(*2023.08.28.200414 新增加*);*)
						IF i_byModeOfAdjust=4 (*OR i_byModeOfAdjust=3*) OR(*小黄绝对pid的测试pid@=6增加了Smith环节*)
i_byModeOfAdjust=7 THEN
(*
IF i_stStArc_Mol_Param.xUseAntiNotch_Arc THEN(*使用陷波器*)
	rErrValue_Use_4:=rAntiNotch_Out;
ELSE
*)
	rErrValue_Use_4:=INT_TO_REAL(iErrValue_Use);
(*END_IF*)
(*
IF i_byModeOfAdjust=3 THEN
	(*增加smith环节@2024.9.11.084813*)
	(*方向处理*)
	IF i_iMarkArrangeModal=MARK_ARRANGE_VREV OR
		i_iMarkArrangeModal=MARK_ARRANGE_HREV THEN;
	ELSE
		i_rTotalAdjustValue_Act:=-i_rTotalAdjustValue_Act;
	END_IF

	rTotalAdjustValue_Act:=rTotalAdjustValue_Act+i_rTotalAdjustValue_Act;
	Smith(
		rTotalAdjustValue_Act(*i_rU*),
		ADR(rSmith_Out)(*i_prYout*),
		i_rGirth_Arc(*i_rC*),
		LREAL_TO_REAL(i_lrCurrVelocity)(*i_rV*),
		i_rFilmLenth_InUnit(*i_rL*),
		iNDEL(*i_iNDEL*),
		ADR(arTF1Uk_Smith)(*i_prTF1Uk*),
		ADR(arTF1Yk_Smith)(*i_prTF1Yk*),
		ADR(arTF2Uk_Smith)(*i_prTF2Uk*),
		ADR(arTF2Yk_Smith)(*i_prTF2Yk*),
		ADR(arDELUk_Smith)(*i_prDELUk*));

	IF xSmithInit THEN(*第一拍的运算不输出*)
		xSmithInit:=FALSE;
(*		rSmith_Out:=0;*)
	END_IF

	rErrValue_Use_4:=rErrValue_Use_4+rSmith_Out;(*叠加输出量到误差*)
ELSE
	xSmithInit:=TRUE;
	rSmith_Out:=0;
	rTotalAdjustValue_Act:=0;
	SysMemSet(ADR(arTF1Uk_Smith),0,SIZEOF(arTF1Uk_Smith));
	SysMemSet(ADR(arTF1Yk_Smith),0,SIZEOF(arTF1Yk_Smith));
	SysMemSet(ADR(arTF2Uk_Smith),0,SIZEOF(arTF2Uk_Smith));
	SysMemSet(ADR(arTF2Yk_Smith),0,SIZEOF(arTF2Yk_Smith));
	SysMemSet(ADR(arDELUk_Smith),0,SIZEOF(arDELUk_Smith));
END_IF
*)


							KS_GetPidParam(
								i_byFilmType(*i_byFilmType*),
								i_byParamIndex(*i_byParamIndex*),
								i_rKp_Gc(*i_iKp_Hmi*),
								i_rKi_Gc(*i_iKi_Hmi*),
								i_rKd_Gc(*i_iKd_Hmi*),
								i_rN_Gc(*i_iN_Hmi*),
								(*模型输出的pid@2024.7.28.111537*)
								i_stStArc_Mol_Param.rKp_MolCal(*rKp_MolCal*),
								i_stStArc_Mol_Param.rKi_MolCal(*rKi_MolCal*),
								ADR(rKp_GC)(*i_prKp*),
								ADR(rKI_GC)(*i_prKI*),
								ADR(rKD_GC)(*i_prKD*),
								ADR(rN_GC)(*i_prN*));

							(*2024.03.06.151303*)
							IF i_uiControllerVel_Huang=0 THEN(*使用当前速度输入计算采样周期*)
								i_uiControllerVel_Huang:=LREAL_TO_UINT(i_lrCurrVelocity);
								IF i_uiControllerVel_Huang<=10 THEN(*最小输入速度先设置未20吧*)
									i_uiControllerVel_Huang:=10;
								END_IF
							ELSE(*使用界面输入的速度对应的参数@修改为了最小值@2024.7.30.163102*)
								IF i_lrCurrVelocity>=i_uiControllerVel_Huang THEN
									i_uiControllerVel_Huang:=LREAL_TO_UINT(i_lrCurrVelocity);
								END_IF
							END_IF

(*
							(*2024.05.17.122541 +升速双积分控制器*)
							xUseGc_TAOSE_SpeedUp:=i_byUseArcAccOrDecCompensate=1 OR
													i_byUseArcAccOrDecCompensate=3;
							xUseGc_TAOSE_SpeedUp:=xUseGc_TAOSE_SpeedUp AND i_lrCurrVelocity>=30;
							xUseGc_TAOSE_SpeedUp:=xUseGc_TAOSE_SpeedUp AND
														((i_xFlag_Acc  AND i_lrCurrVelocity<=i_rTarVel_ThisTime*1) OR
														(i_xFlag_Dec AND i_lrCurrVelocity>=i_rTarVel_ThisTime));

							xUseGc_TAOSE_SpeedUp:=xUseGc_TAOSE_SpeedUp OR i_byUseArcAccOrDecCompensate=4;(*双积分直接打开@2024.7.25.093110*)
							IF xUseGc_TAOSE_SpeedUp THEN(*使用套色升速控制器*)
								IF NOT xGc_TAOSE_SpeedUp_Init  THEN(*初始化控制器参数*)
									xGc_TAOSE_SpeedUp_Init:=TRUE;
									rLastResult_Huang:=0;
									rSigema_PID:=0;(*清零绝对值限值@2025.5.15.225514*)
									rReal_Delta_PID:=0;
									IF i_xInitArcErr_AjdImmediately THEN
										iErrCnt_CalVResult:=1;(*写成1,不会等待一副后调整*)
									ELSE
										iErrCnt_CalVResult:=0;(*初始这一拍不输出*)
									END_IF
									SysMemSet(ADR(arGc_Uk),0,SIZEOF(arGc_Uk));
									SysMemSet(ADR(arGc_Yk),0,SIZEOF(arGc_Yk));
								END_IF



								Gc_TAOSE_SpeedUp(
									iErrValue_Use(*i_rU*),
									i_lrCurrVelocity(*i_rVel*),
									i_rGirth_Arc(*i_rGirth*),
									ADR(rTemp)(*i_prYout*),
									i_stStArc_Mol_Param.stStArcSpeedUpParam.rK(*i_rK*),
									i_stStArc_Mol_Param.stStArcSpeedUpParam.rA2(*50*)				(*25*)	(*40*)		(*60*)		(*40*)		(*i_ra2*),
									i_stStArc_Mol_Param.stStArcSpeedUpParam.rA1(*2/rTime_s_1R*)	(*3*)	(*4*)		(*4*)		(*6	*)	(*i_ra1*),
									i_stStArc_Mol_Param.stStArcSpeedUpParam.rA0(*0*)				(*0.1*)	(*0.001*)	(*0.005*)	(*0.01*)	(*i_ra0*),
									ADR(arGc_Uk)(*i_prGc_Uk*),
									ADR(arGc_Yk)(*i_prGc_Yk*));
							END_IF
							xGc_TAOSE_SpeedUp_Init:=xUseGc_TAOSE_SpeedUp;



							xUseGc_Pid:=
								(i_byUseArcAccOrDecCompensate<>1 AND i_byUseArcAccOrDecCompensate<>3) OR
								((i_byUseArcAccOrDecCompensate=1 OR i_byUseArcAccOrDecCompensate=3)AND NOT xUseGc_TAOSE_SpeedUp);

							IF xUseGc_Pid THEN(*不使用套色升速控制器*)
								IF NOT xGc_Pid_Init OR
									(byPrevModeOfAdjust=7 AND i_byModeOfAdjust=4) OR
									(byPrevModeOfAdjust=4 AND i_byModeOfAdjust=7) THEN
									xGc_Pid_Init:=TRUE;
									rLastResult_Huang:=0;

									rSigema_PID:=0;(*清零绝对值限值@2025.5.15.225514*)
									rReal_Delta_PID:=0;

									IF i_xInitArcErr_AjdImmediately THEN
										iErrCnt_CalVResult:=1;(*写成1,不会等待一副后调整*)
									ELSE
										iErrCnt_CalVResult:=0;(*初始这一拍不输出*)
									END_IF

									SysMemSet(ADR(arEk_huang),0,SIZEOF(arEk_huang));
									SysMemSet(ADR(arYPk_huang),0,SIZEOF(arYPk_huang));
									SysMemSet(ADR(arYIk_huang),0,SIZEOF(arYIk_huang));
									SysMemSet(ADR(arYDk_huang),0,SIZEOF(arYDk_huang));
									SysMemSet(ADR(arYPIDk_Huang),0,SIZEOF(arYPIDk_Huang));
									SysMemSet(ADR(arYI2k_Huang),0,SIZEOF(arYI2k_Huang));
									rYP2k_Huang:=0;


									SysMemSet(ADR(arPIUk_SmithPI),0,SIZEOF(arPIUk_SmithPI));
									SysMemSet(ADR(arPIYk_SmithPI),0,SIZEOF(arPIYk_SmithPI));
									SysMemSet(ADR(arTF1Uk_SmithPI),0,SIZEOF(arTF1Uk_SmithPI));
									SysMemSet(ADR(arTF1Yk_SmithPI),0,SIZEOF(arTF1Yk_SmithPI));
									SysMemSet(ADR(arTF2Uk_SmithPI),0,SIZEOF(arTF2Uk_SmithPI));
									SysMemSet(ADR(arTF2Yk_SmithPI),0,SIZEOF(arTF2Yk_SmithPI));
									SysMemSet(ADR(arDELUk_SmithPI),0,SIZEOF(arDELUk_SmithPI));
								END_IF
								*)

								//算法切换的时候恢复下参数
								IF (byPrevModeOfAdjust=7 AND i_byModeOfAdjust=4) OR
									(byPrevModeOfAdjust=4 AND i_byModeOfAdjust=7) THEN
									
 									rLastResult_Huang:=0;

									IF i_xInitArcErr_AjdImmediately THEN
										iErrCnt_CalVResult:=1;(*写成1,不会等待一副后调整*)
									ELSE
										iErrCnt_CalVResult:=0;(*初始这一拍不输出*)
									END_IF

									SysMemSet(ADR(arEk_huang),0,SIZEOF(arEk_huang));
									SysMemSet(ADR(arYPk_huang),0,SIZEOF(arYPk_huang));
									SysMemSet(ADR(arYIk_huang),0,SIZEOF(arYIk_huang));
									SysMemSet(ADR(arYDk_huang),0,SIZEOF(arYDk_huang));
									SysMemSet(ADR(arYPIDk_Huang),0,SIZEOF(arYPIDk_Huang));
									SysMemSet(ADR(arYI2k_Huang),0,SIZEOF(arYI2k_Huang));
									rYP2k_Huang:=0;
									
									//2026.5.14.152350 小郭算法需要的变量
									arrE[1]:=0;
									arrE[2]:=0;
									arrU[1]:=0;
									arrU[2]:=0;
									
								END_IF
								IF i_byModeOfAdjust=7 THEN(*SMITH-PI*)
									(*
									SmithPI(
											rErrValue_Use_4(*i_rU*),
											ADR(rSmith_Out_PI)(*i_prYout*),
											i_rGirth_Arc(*i_rC*),
											i_lrCurrVelocity(*i_rV*),
											i_rFilmLenth_InUnit(*i_rL*),
											iNDEL(*i_iNDEL*),
											rKp_GC(*i_rKp*),
											rKi_GC(*i_rKi*),
											ADR(arPIUk_SmithPI)(*i_prPIUk*),
											ADR(arPIYk_SmithPI)(*i_prPIYk*),
											ADR(arTF1Uk_SmithPI)(*i_prTF1Uk*),
											ADR(arTF1Yk_SmithPI)(*i_prTF1Yk*),
											ADR(arTF2Uk_SmithPI)(*i_prTF2Uk*),
											ADR(arTF2Yk_SmithPI)(*i_prTF2Yk*),
											ADR(arDELUk_SmithPI)(*i_prDELUk*));
									rTemp:=rSmith_Out_PI;
									*)

									(*2026.5.14.142720 +小郭实现的双积分pid*)
									rTemp:=
										DOUBLE_INTER(
											lrV_m_min:= i_uiControllerVel_Huang, 
											lrY_Meas:= rErrValue_Use_4, 
											bEnable:= TRUE, 
											lrPM_deg:= i_stStArc_Mol_Param.rPM_deg, 
											lrWc_Ts:= i_stStArc_Mol_Param.rWc_Ts, 
											lrL:= 4.67, (*2026.05.21.220823||  10.92  wang.xy*)
											lrK_M:=1.214, (*2026.05.21.220839||  2.094  wang.xy*)
											lrNK1:=0.886, (*2026.05.21.220856||   0.306  wang.xy*)



											lrC_SP:= i_rGirth_Arc, 
											parrE:= ADR(arrE), 
											parrU:= ADR(arrU));
											
								ELSE
									(*2025.1.15.130353 调整修改@还要测试*)
									(*i_byArcErrLimitToCtl_P 单位是mm*)
									iUseMaxAdjValue:=0;
									IF ABS(rErrValue_Use_4)/100>=i_byArcErrLimitToCtl_P THEN(*范围外按照限值输出*)
										IF rErrValue_Use_4>0 THEN
											iUseMaxAdjValue:=1;
										ELSE
											iUseMaxAdjValue:=-1;
										END_IF
									ELSE(*范围内使用pid*)
										Gc_PID_2025(
											i_rGirth_Arc/(i_uiControllerVel_Huang*1000.0/60.0)(*i_rTs*),
											rKp_GC(*i_rP*),
											rKi_GC(*i_rI*),
											rKd_GC(*i_rD*),
											rN_GC(*i_rN*),
											rErrValue_Use_4(*i_rU*),
											ADR(rTemp)(*i_prYout*),
											ADR(arEk_huang)(*i_parEk*),
											ADR(arYPk_huang)(*i_parYPk*),
											ADR(arYIk_huang)(*i_parYIk*),
											ADR(arYDk_huang)(*i_parYDk*),
											ADR(arYPIDk_Huang)(*i_parYPIDk*));
									END_IF

									(*2025.1.15.175645  增加切换标志*)
									rReal_Delta_PID:=0;
									IF i_xUseGc_PID_2025 THEN;(*输出不做限值|控制器输出的绝对值=rTemp*)
									ELSE
										(*限值处理*)
										(*直接输出增量误差*)
										Gc_Delta_PID_OutPut(
											rTemp(*i_rCal_PID*),
											iMaxAdjustValue(*i_rLimit_Delta*),
											ADR(rReal_Delta_PID)(*i_prReal_Delta_PID*),
											ADR(rSigema_PID)(*i_prSigema_PID*));
									END_IF
(*
									IF i_stStArc_Mol_Param.xUsePeriodic THEN
										Periodic(
											rErrValue_Use_4(*i_rU*),
											ADR(rYout_Periodic)(*i_prYout*),
											i_rGirth_Arc(*i_rC*),
											i_lrCurrVelocity(*i_rV*),
											i_stStArc_Mol_Param.rG_Periodic(*i_rG*),
											i_stStArc_Mol_Param.rW_Periodic(*i_rW*),
											ADR(rTk)(*i_prTk*),
											ADR(rTheta1k)(*i_prTheta1k*),
											ADR(rTheta2k)(*i_prTheta2k*));											
									END_IF	
*)								
											
									iCurrKp:=REAL_TO_INT(rKp_GC*100);
									iCurrKI:=REAL_TO_INT(rKi_GC*100);
									iCurrKD:=REAL_TO_INT(rKd_GC*100);
								END_IF
							(*END_IF*)
							byPrevModeOfAdjust:=i_byModeOfAdjust;
							xGc_Pid_Init:=xUseGc_Pid;


							(*控制器输出为绝对式的@电机控制确实增量的，这里需要对输出量做差计算增量值*)
							(*计算控制器输出调整量的增量*)
							(*通iUseMaxAdjValue控制输出值@2025.1.15.175024*)
							IF iUseMaxAdjValue=0 THEN(*使用控制器输出@2025.5.15.225208*)
								IF i_xUseGc_PID_2025 THEN(*默认方法@未用绝对值限幅*)
									o_iVResult:=REAL_TO_INT(rTemp-rLastResult_Huang);
								ELSE(*使用限幅函数|直接计算除了增量值*)
									o_iVResult:=REAL_TO_INT(rReal_Delta_PID);
								END_IF
							ELSE
								o_iVResult:=iUseMaxAdjValue * iMaxAdjustValue;
							END_IF

							o_iVResult:=o_iVResult;(*叠加补偿量*)

							o_iVResult:=-o_iVResult;(*需要取反才能和以前一致*)

							rLastResult_Huang:=rTemp;(*保留上个周期的结果*)
							rLastWf:=rWf;(*保留上个周期的结果*)

						ELSE
							(*2020.7.13.102005 在大误差时增大变化量的目标值|Liu.yt|还需要测试*)
							iCoeff:=10;
							IF ABS(iErrValue_Use)>20 AND
								i_xArcTest THEN(*误差超过0.2mm时，误差变化量的目标值增大到1/6*)
								iCoeff:=6;
							END_IF

							(*2020.7.15.113752 目标值的变化量取值修改为上副误差的变化量|Liu.yt*)
							rTemp:=aiPreVErrorArr[iErrorNum]*(-1.0);(*公式为：前次误差/iCoeff。放大了iCoeff倍，最后再除。*)
							(*目标变化量进行限值,不能超过30丝|同样放大了iCoeff倍*)
							IF rTemp>iMaxGoalErr_V*iCoeff THEN
								rTemp:=iMaxGoalErr_V*iCoeff;
							ELSIF rTemp<-iMaxGoalErr_V*iCoeff THEN
								rTemp:=-iMaxGoalErr_V*iCoeff;
							END_IF
							(*计算规划变化量和实际变化量的误差*)
							(*目标变化量放大了iCoeff倍|这里误差的变化量也放大iCoeff倍*)
							rTemp:=rTemp-(iErrValue_Use-aiPreVErrorArr[iErrorNum])*iCoeff;
							o_iVResult:=REAL_TO_INT(iCurrKp*rTemp/iCoeff);(*除以放大的iCoeff倍*)
						END_IF

						(*切换算法的时候 初始化这两种算法的数组变量*)
						IF (i_byModeOfAdjust<>3 AND i_byModeOfAdjust<>4 AND i_byModeOfAdjust<>7)THEN
							arYPk_huang[1]:=0;
							arYPk_huang[2]:=0;
							arEk_huang[1]:=0;
							arEk_huang[2]:=0;
							arYIk_huang[1]:=0;
							arYIk_huang[2]:=0;
							arYDk_huang[1]:=0;
							arYDk_huang[2]:=0;
							(*二次积分*)
							arYPIDk_Huang[1]:=0;
							arYPIDk_Huang[2]:=0;
							rYP2k_Huang:=0;
							arYI2k_Huang[1]:=0;
							arYI2k_Huang[2]:=0;
							
							(*小郭双积分代码@2026.5.14.144658+*)
							arrE[1]:=0;
							arrE[2]:=0;
							arrU[1]:=0;
							arrU[2]:=0;


							rLastResult_Huang:=0;
							rSigema_PID:=0;(*清零绝对值限值@2025.5.15.225514*)
							rReal_Delta_PID:=0;
							
							(*套色补偿算法中变量*)
							iK:=0;
							rWf:=0;
							rLastWf:=0;
							rDh:=0;
							SysMemSet(ADR(arPh),0,SIZEOF(arPh));
							SysMemSet(ADR(arXh),0,SIZEOF(arXh));

							(*升速控制器@2024.05.17.132443*)
							SysMemSet(ADR(arGc_Uk),0,SIZEOF(arGc_Uk));
							SysMemSet(ADR(arGc_Yk),0,SIZEOF(arGc_Yk));
						END_IF
(*
						IF i_byModeOfAdjust<>5 THEN(*DOUBLE_I算法*)
							SysMemSet(ADR(arGc_Uk_Double_I),0,SIZEOF(arGc_Uk_Double_I));
							SysMemSet(ADR(arGc_Yk_Double_I),0,SIZEOF(arGc_Yk_Double_I));
							rYout_Double_I:=0;
							rLastYout_Double_I:=0;
						END_IF

						IF i_byModeOfAdjust<>6 THEN(*mpc算法*)
							rX2_MPC:=0;
							rLastYout_MPC:=0;
							rYout:=0;
						END_IF
*)
						o_iVKp:=iCurrKp;
						o_iVKi:=iCurrKi;
						o_iVKd:=iCurrKd;




						(*2020.4.15.083956 增加了判断有效误差计数的逻辑|
						必须超过iErrNum_CanCalVResult个才能使能变化量的计算部分|Liu.yt*)
						iErrNum_CanCalVResult:=2;
						IF iErrCnt_CalVResult<iErrorNum THEN
							iErrCnt_CalVResult:=iErrCnt_CalVResult+1;
						END_IF
						IF iErrCnt_CalVResult>=iErrNum_CanCalVResult THEN;
						ELSE(*数据不足 就不调整*)
							o_iVResult:=0;
						END_IF

						IF xUseResultLimit THEN(*增加了使用限值的标志@2024.03.24.220514*)
							(*套色调整速度的限值|*)
							IF o_iVResult>iMaxAdjustValue THEN
								o_iVResult:=iMaxAdjustValue;
							ELSIF o_iVResult<-iMaxAdjustValue THEN
								o_iVResult:=-iMaxAdjustValue;
							END_IF
						END_IF

(*2025.1.3.133417 屏蔽*)
(*
						SpliceCom(
							o_iVResult(*i_rPI*),
							i_pstStAxisParam^.rEstValue_ArcCompensate_UwCut(*i_rD_hat_Cal*),
							i_pstStAxisParam^.rKadj_ArcCompensate_UwCut(*i_rKadj*),
							i_pstStAxisParam^.xEn_ArcCompensate_UwCut AND(*使能了*)
							i_pstStAxisParam^.xCalcDne_ArcCompensate_UwCut(*i_bEn*),(*计算完成了*)
							ADR(rVResult_new)(*i_prPI_new*));
						IF i_pstStAxisParam^.xCalcDne_ArcCompensate_UwCut THEN(*计算完成了|按照输出值执行*)
							o_iVResult:=REAL_TO_INT(rVResult_new);
							i_pstStAxisParam^.xCalcDne_ArcCompensate_UwCut:=FALSE;
						END_IF
*)

						iPreGoalVErrorVal := iGoalVErrorVal;



						(*连续N个点误差小于10丝，p=2,d=0*)
						IF NOT xChangePDFlag THEN
							FOR i:=1 TO c_PIDAutoChangNum-1 BY 1 DO
								aiPerPDChangeVError[i]:=aiPerPDChangeVError[i+1];
							END_FOR
							aiPerPDChangeVError[c_PIDAutoChangNum]:=iErrValue_Use;

							FOR i:=1 TO c_PIDAutoChangNum BY 1 DO
								IF ABS(aiPerPDChangeVError[i])<10 THEN
									iRemOverNum:=iRemOverNum+1;
								END_IF
							END_FOR
							IF iRemOverNum=c_PIDAutoChangNum OR
								i_xAccSpeedFlag THEN(*提前进入加速状态的时候|提前进入稳态@2023.08.10.101928*)
								xChangePDFlag:=TRUE;
								iRemOverNum:=0;
							ELSE
								iRemOverNum:=0;
							END_IF
						END_IF

					ELSE
						iGoalVErrorChangeVal:=0;
						o_iVResult:=0;
					END_IF

				END_IF

				(*保存前几次的误差*)
				FOR i:=1 TO iErrorNum-1 BY 1 DO
					aiPreVErrorArr[i]:=aiPreVErrorArr[i+1];
				END_FOR
				aiPreVErrorArr[iErrorNum]:=iErrValue_Use;

				(*记录前10次的目标变化值*)
				FOR i:=1 TO 9 BY 1 DO
					aiPreGoalChangeVal[i]:=aiPreGoalChangeVal[i+1];
				END_FOR
				aiPreGoalChangeVal[10]:=iGoalVErrorChangeVal;

				(********************************************)
				(*2016年10月21日 16:03:56 add by wu.xp 80幅PID值自动改变*)
				IF NOT i_wErProf.2 AND NOT xChangePDFlag THEN
					uiAutoPIDChangNum:=uiAutoPIDChangNum+1;

					IF uiAutoPIDChangNum>=80 THEN
						xChangePDFlag:=TRUE;
					END_IF
				ELSE
					uiAutoPIDChangNum:=0;
				END_IF

			ELSE (*非印刷状态-清标志*)
				iFirstRun:=0;
				udiRunTime:=0;
				xValidError:=FALSE;
				FOR i:=1 TO iErrorNum BY 1 DO
					aiPreVErrorArr[i]:=0;
				END_FOR

				FOR i:=1 TO 30 BY 1 DO
					aiPerPDChangeVError[i]:=20;
				END_FOR
				iRemOverNum:=0;
				xChangePDFlag:=FALSE;

				FOR i:=1 TO 10 BY 1 DO
					aiPreGoalChangeVal[i]:=0;
					IF i<=2 THEN(*2023.08.29.161511*)
						arEk_huang[i]:=0;
						arYPk_huang[i]:=0;
						arYIk_huang[i]:=0;
						arYDk_huang[i]:=0;
						(*二次积分*)
						arYPIDk_Huang[i]:=0;
						arYI2k_Huang[i]:=0;
						(*小郭双积分代码@2026.5.14.144658+*)
						arrE[i]:=0;
						arrU[i]:=0;
					END_IF
					
				END_FOR
				rYP2k_Huang:=0;(*二次积分*)
				rLastResult_Huang:=0;
				rSigema_PID:=0;(*清零绝对值限值@2025.5.15.225514*)
				rReal_Delta_PID:=0;

				(*套色补偿算法中变量@2023.09.19.095515*)
				iK:=0;
				rWf:=0;
				rLastWf:=0;
				rDh:=0;
				SysMemSet(ADR(arPh),0,SIZEOF(arPh));
				SysMemSet(ADR(arXh),0,SIZEOF(arXh));

(*
				(*LQR*)
				rX2_LQR:=0;
				arYout_BUF_LQR[1]:=0;
				arYout_BUF_LQR[2]:=0;
				rLastYout_LQR:=0;
				(*mpc算法*)
				rX2_MPC:=0;
				rLastYout_MPC:=0;
				rYout:=0;
				(*double_i*)
				SysMemSet(ADR(arGc_Uk_Double_I),0,SIZEOF(arGc_Uk_Double_I));
				SysMemSet(ADR(arGc_Yk_Double_I),0,SIZEOF(arGc_Yk_Double_I));
				rYout_Double_I:=0;
				rLastYout_Double_I:=0;
*)
				(*升速控制器@2024.05.17.132443*)
				SysMemSet(ADR(arGc_Uk),0,SIZEOF(arGc_Uk));
				SysMemSet(ADR(arGc_Yk),0,SIZEOF(arGc_Yk));
				uiAutoPIDChangNum:=0;

				xDelayAccLengFlag:=FALSE;
				uiDelayAccLengNum:=0;
				o_iVResult:=0;(*2023.10.31.163644 忘记清除了*)
				xGc_Pid_Init:=FALSE;

				xSmithInit:=TRUE;
				rSmith_Out:=0;
				rTotalAdjustValue_Act:=0;(*累加值*)
				SysMemSet(ADR(arTF1Uk_Smith),0,SIZEOF(arTF1Uk_Smith));
				SysMemSet(ADR(arTF1Yk_Smith),0,SIZEOF(arTF1Yk_Smith));
				SysMemSet(ADR(arTF2Uk_Smith),0,SIZEOF(arTF2Uk_Smith));
				SysMemSet(ADR(arTF2Yk_Smith),0,SIZEOF(arTF2Yk_Smith));
				SysMemSet(ADR(arDELUk_Smith),0,SIZEOF(arDELUk_Smith));


				SysMemSet(ADR(arPIUk_SmithPI),0,SIZEOF(arPIUk_SmithPI));
				SysMemSet(ADR(arPIYk_SmithPI),0,SIZEOF(arPIYk_SmithPI));
				SysMemSet(ADR(arTF1Uk_SmithPI),0,SIZEOF(arTF1Uk_SmithPI));
				SysMemSet(ADR(arTF1Yk_SmithPI),0,SIZEOF(arTF1Yk_SmithPI));
				SysMemSet(ADR(arTF2Uk_SmithPI),0,SIZEOF(arTF2Uk_SmithPI));
				SysMemSet(ADR(arTF2Yk_SmithPI),0,SIZEOF(arTF2Yk_SmithPI));
				SysMemSet(ADR(arDELUk_SmithPI),0,SIZEOF(arDELUk_SmithPI));

				(*2024.9.13.105832+*)
				rYout_Periodic:=0;
				rTk:=0;
				rTheta1k:=0;
				rTheta2k:=0;
				(*2024.8.30.150146+*)
				IF i_xInitArcErr_AjdImmediately THEN
					iErrCnt_CalVResult:=1;(*写成1,不会等待一副后调整*)
				ELSE
					(*2020.7.9.124302|增加在非有效误差时清零该新增计数|Liu.yt*)
					(*导入的时候忘记写入了*)
					iErrCnt_CalVResult:=0;
				END_IF


				(*2024.01.02.135607*)
				xArcReachRangeFlag:=FALSE;
				byCycleCnt:=0;
				(*2024.03.24.215201+*)
				byLostCnt:=0;

				iUseMaxAdjValue:=0;(*2025.1.15.175717+*)
		END_CASE

	ELSE
		o_iVResult:=0;
		RETURN;
END_CASE

(*纵向*)







(*******************)
iLimitValue:=10;(*
IF i_xChangeLimit_H_CutDne THEN(*裁切完成后修改限值值*)
	iLimitValue:=3;
END_IF*)

(* follow added by HAN.DP @ 2016年9月7日 18:03:24 *)
(*横向*)
(*最大限值为了1mm*)
(*优化处理@2024.12.7.160559*)
IF i_rMaxAdjustVal_H=0 OR
	i_rMaxAdjustVal_H>1000 THEN
	iMaxAdjustVal_H:=1000;
ELSE
	iMaxAdjustVal_H:=REAL_TO_INT(i_rMaxAdjustVal_H);
END_IF

IF i_xFlag_AdjValid_H THEN (*横向开*)
	IF i_wErProf.8 OR i_wErProf.9 OR i_wErProf.10 OR
		xWaitFilmLenth_H THEN//2025.9.11.112014 横向让料头的时候不计算调整量@2025.9.11.112132+ by liu.yt
		o_iHResult:= 0;
		IF NOT i_wErProf.9 THEN
			xPreErrInit_H:=FALSE;
		END_IF
	ELSE
		(*2023.6.6.114936 增加了打开横向初始化动作*)
		IF NOT xPreErrInit_H THEN
			iPreHError:= 0;//i_iError_h;// 开始计算的调整量初值修改为0
			xPreErrInit_H:=TRUE;
		END_IF
		(*按照浮点数运算@2024.7.25.151935*)
		o_iHResult:= LREAL_TO_INT(aiKpKiKd_H[1] * i_iError_h / 2.0 + aiKpKiKd_H[3] * (i_iError_h - iPreHError) / 2.0);
		iPreHError:= i_iError_h;


		(*2016年9月20日09:48:55 by wu.xp 横向调整限值*)
		(*2016年10月7日 11:13:15 wu.xp*)
		IF ABS(i_iError_h)<=LREAL_TO_INT(i_rDeadzoneMin_H*100) OR
			ABS(i_iError_h)>=LREAL_TO_INT(i_rDeadzoneMax_H*100) THEN (*横向不工作区之外不调整*)
			o_iHResult:=0;
		ELSE
(*			IF i_xArcTest_H AND ABS(i_iError_h)>30 THEN(*超过30丝限值使用单圈调整的量@2023.6.6.114217*)*)
			IF i_xArcTest_H AND ABS(i_iError_h)>20 THEN(*2025.9.11.131948改为20*)
				IF o_iHResult>iMaxAdjustVal_H THEN(*变量替换*)
					o_iHResult:=iMaxAdjustVal_H;
				ELSIF o_iHResult<-iMaxAdjustVal_H THEN(*变量替换*)
					o_iHResult:=-iMaxAdjustVal_H;
				END_IF
			ELSIF ABS(i_iError_h)>10 THEN (*10丝*)
				IF o_iHResult>30 THEN
					o_iHResult:=30;
				ELSIF o_iHResult<-30 THEN
					o_iHResult:=-30;
				END_IF
			ELSE (*误差小于20丝，最大调整量为1丝*)
				IF o_iHResult>10 THEN
					o_iHResult:=10;
				ELSIF o_iHResult<-10 THEN
					o_iHResult:=-10;
				END_IF
			END_IF
		END_IF
	END_IF
	(************************)
ELSE
	o_iHResult:= 0;
	xPreErrInit_H:=FALSE;
END_IF

(*2024.8.1.111329 横向补偿算法*)
xArcCompensateEn_Hor:=i_byStateOfMotion=1 AND i_xFlag_AdjValid_H;(*印刷并且横向自动*)

KS_ArcCompensate_Hor(
	xArcCompensateEn_Hor(*i_xEn*),
	FALSE(*i_xDirRev*),
	i_xCut_Uw(*i_xCut_Uw*),
	i_xCut_Rw(*i_xCut_Rw*),
	i_wErProf.8(*i_xLost*),
	5(*3*)(*i_byOutEnLostNum*),
	i_byCompensateValue_Hor(*i_byAddValue*),
	i_byMaxAddValue_Total_Hor(*i_byMaxAddValue_Total*),
	o_iHResult(*i_iAdjValue*),
	i_iError_h(*i_iArcErr*),
(*	i_iMaxAdjustVal_H(*i_iMaxAdjustVal*),*)
	iMaxAdjustVal_H(*i_iMaxAdjustVal*),(*2024.12.7.160656 修改输入*)
	150(*i_iMinArcErr_Compensate*),(*暂定1.5mm@150丝*)
	ADR(aiAdjValueList_Hor)(*i_paiAdjValueList*),
	ADR(aiArcErrList_Hor)(*i_paiArcErrList*),
	ADR(xWatching_Hor)(*i_pxWatching*),
	ADR(xOuting_Hor)(*i_pxOuting*),
	ADR(xOutDne_Hor)(*i_pxOutDne*),
	ADR(byLostCnt_Hor)(*i_pbyLostCnt*),
	ADR(rResult_Total_Hor)(*i_prResult_Total*),
	ADR(rCompensateValue_Hor)(*i_prResult*));
IF i_xCompensateEn_Hor THEN(*打开了才真正输出*)
	o_iHResult:=o_iHResult+REAL_TO_INT(rCompensateValue_Hor);(*叠加补偿量*)
END_IF




(*---------------------------2017-08-25 13:06:15
/.最终的输出量处理
/.根据电机正反和顺逆序进行了方向转换
.----------------------------------------------*)
(*
/.纵向*)
(*IF i_pstStAxisParam^.wStatusRef.0 THEN
*)IF i_xFlag_AdjValid_V THEN
	(*自动*)
	IF i_iMarkArrangeModal=MARK_ARRANGE_VREV OR
		i_iMarkArrangeModal=MARK_ARRANGE_HREV THEN
		(*逆序*)
		o_iVResult:= -o_iVResult;
	END_IF

(*	IF i_pstStAxisParam^.wSwitchRef.4 THEN
*)	IF i_xAdjREV_V THEN
		(*调整反向*)
		o_iVResult:= -o_iVResult;
	END_IF
ELSE
	(*手动*)
	o_iVResult:= 0;
END_IF

(*
/.横向*)
IF i_xFlag_AdjValid_H THEN
(*IF i_pstStAxisParam^.wSwitchRef.0 AND
	i_pstStAxisParam^.wStatusRef.1 THEN
*)	(*自动*)
	IF i_iMarkArrangeModal=MARK_ARRANGE_VREV OR
		i_iMarkArrangeModal=MARK_ARRANGE_HREV THEN

		(*逆序*)
		o_iHResult:= -o_iHResult;
	END_IF

(*	IF i_pstStAxisParam^.wSwitchRef.5 THEN
*)	IF i_xAdjREV_H THEN
		(*调整反向*)
		o_iHResult:= -o_iHResult;
	END_IF
ELSE
	(*手动*)
	o_iHResult:= 0;
END_IF
o_rKp_MolCal:= i_stStArc_Mol_Param.rKp_MolCal;
o_rKi_MolCal:= i_stStArc_Mol_Param.rKi_MolCal;
