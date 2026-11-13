(*@CES
Name=StRSV_UnitParam_UnSave
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=00ed0294-80de-4273-b140-875ecf3a8946
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
{attribute 'pack_mode' := '1'}
TYPE StRSV_UnitParam_UnSave :
STRUCT
	//用两个标志处理一下网辊单动和底辊单动标志2026.2.6.233022
	xInching_NetRoller: BIT;
//	xSwitch_Flag00: BIT;
	xInching_BottomRoller: BIT;
//	xSwitch_Flag01: BIT;
	//bit2和bit3用作网辊和底辊单动开关2026.2.6.233223
	xSwitch_Inching_Net: BIT;
//	xSwitch_Flag02: BIT;
	xSwitch_Inching_Bottom: BIT;
//	xSwitch_Flag03: BIT;
//横向标志
	xBtn_FromHMI_HorMove_M: BIT;
	xBtn_FromHMI_HorMove_G: BIT;
//2026.03.11.152149 | 版辊单运行开关
	xSwitch_Inching_Prn: BIT;
	xSwitch_Flag07: BIT;
	
//2026.02.07.140659||增加变量28字节||999-28=971
	iTorque_PrnRoller: INT;
	iTorque_NetRoller: INT;
	iTorque_BottomRoller: INT;
	iTorque_Prn_Press_M: INT;
	iTorque_Prn_Press_G: INT;
	iTorque_Net_Press_M: INT;
	iTorque_Net_Press_G: INT;
	
	iRpm_PrnRoller: INT;
	iRpm_NetRoller: INT;
	iRpm_BottomRoller: INT;
	iRpm_Prn_Press_M: INT;
	iRpm_Prn_Press_G: INT;
	iRpm_Net_Press_M: INT;
	iRpm_Net_Press_G: INT;
	
	rStep_PressMove: REAL;
	rStep_Horz:REAL;
	


	xFlag_FindFirstMark						: BOOL;(*开始寻找当前色色标*)
	xFlag_FindPreMark						: BOOL;(*开始寻找前一色色标*)
	xFlag_FindFirstSuccess					: BOOL;(*找到当前色完成*)
	xFlag_FindPreSuccess					: BOOL;(*找到前一色*)
	
	byFlag_CommFromMaster				: BYTE;(*	bit0: xFlag_AutoAdj_En; bit1: xFlag_FindFirstMark; bit2: xCurManuAdjust
															bit3:xFlag_FindPreMark  bit4:xPreCurManuAdjust; bit5 波门移动完成
												bit6，当前次信息主站成功获取*)
	byWidth_Mark_Max						: BYTE;(*单个色标最大宽度-0.1mm*)
	byWidth_Mark_Min						: BYTE;(*单个色标最小宽度-0.1mm*)
// 	iKcode_Mark_Interval						: INT;(*1色Kcode标与色标间隔-0.1mm*)
// 	iTaps_Mark_Interval						: INT;(*2色Taps标与色标间隔-0.1mm*)


	byFlag_FindSuccessful					: BYTE;(*=1:单色色标找到-2:混合色标找到*)
	iError_Msg									: INT;(*0:无错误
														88 :该轴粗调未到位
														50 ：等待1.5圈中
														51 ；等待光纤空闲中
														53; //等待单色新的一圈信息来
														54; //等待前色信息来
														101当前色没有位置反馈
														102 当前色没有位置反馈	
														-1~-100:单色色标失败原因
														-101~-200:混色色标失败原因*)
	
	byMaxGap									: BYTE;(*最大间隙，-0.1mm*)
	bySimilarityThreshold						: BYTE;(*相似度阈值40%-70%,*)
// 	bySignalType								: BYTE;(*信号类型，1北人标，暂不支持其他标*)

	byDetectedSignalCount 					: BYTE;(*当前检测到色标个数*)
	
	iCurLabelPos :INT;(*本色三角标位置，点数*)
	iPreLabelPos :INT;(*前色三角标位置，点数*)
	byFlag_CommFromSlave					: BYTE;(*bit0 xFlag_FindFirstSuccess 当前色成功找到 ;
													bit1 xFlag_FindPreSuccess 前一色成功找到
													bit2 当前色寻找完成
													bit3 精采样宽度计算完成
													bit4 从站全自动套印空闲中
													bit5 从站触发找本色
													bit6 从站触发找混色*)
	byMarkStep:BYTE;(*当前全自动套印步骤*)
	rGateSignalWidth_R:REAL;(*粗采样计算波形宽度 mm*)
	xCurManuAdjust :BOOL;(*当前色未找到，需要手动调整光电眼位置，调整好后人工置位*)
	xPreCurManuAdjust :BOOL;(*前一色未找到，需要观察原因调整好后，人工点确定，等一个机组料长后置位*)
	xSpecialMarkEn:BOOL;(*特殊标有效*)
	byMeanOffset:BYTE; (*均值偏移 越大越找不到小色标，太小会出现较多信号导致直接失败*)
	iPos_Value								: INT;(*自动对版最终结果*)
	xFlag_GateMoveFinish :BOOL;// 波门移动完成信号;
	xFlag_AutoAdj_En:BOOL;(*该轴全自动套印使能*)	
	
	//xi.hy
	rFiberMoveDistanceIn:REAL;(*光纤行走行走距离输入*)
	rFiberMoveDistanceOut:REAL;(*光纤行走行走距离输出*)
	uiFiberMoveAlarm:UINT;(*光纤行走报警码*)
	rFiberMovePosCur:REAL;(*光纤行走当前位置*)
	wEncPosPulse_FiberMove:WORD;(*光纤行走反馈编码器位置*)
	byFiberMoveMode:BYTE;(*光纤行走运行模式*)
	byFiberMoveDir:BYTE;(*光纤行走方向*)
	rFiberMoveVel:REAL;(*光纤行走运行速度*)
	
	wState_FiberMove:WORD;//光纤行走状态
						//.0 行走电机运动中
						//.1 基准色位置确认
						//.2 手动左移
						//.3 手动右移
						//.4 定长运动启动使能
						//.5 回零正限位触发
						//.6 宽度计算成功标志
						//.7 电机读取回来的限位信号
						//.8 基准位置同步完成
						//.9 基准位置同步中
						//.10 从站计算宽度使能
						//.11
						//.12
						//.13
						//.14
						//.15
	rWidth_FindMarkCenter:REAL;(*光纤行走 ARM上传的色标宽度*)
	
	
	xFiberMoveIdle:BOOL;(*光纤行走状态机空闲标志*)
	rFiberMoveDistanceIn_FindSignal:REAL;(*光纤行走行全自动套印走距离输入*)
	xFiberMoveDisRunStart_FindSignal:BOOL;(*光纤行走行全自动套印使能输入*)
	
//2026.4.6.133721	增加一些状态全自动套印相关4个字节|893-4=889
	wCommFromDubheFindSignal :WORD;(*Bit0 xFlag_AutoAdj_En:BOOL;(*该轴全自动套印使能*)
									Bit1 xFlag_FindFirstSuccess					: BOOL;(*找到当前色完成*)
									Bit2 xFlag_FindPreSuccess					: BOOL;(*找到前一色*)
									Bit3 xFlag_AutoAdj_En:BOOL;(*该轴全自动套印完成*)			）
									Bit4 xCurManuAdjust :BOOL;(*当前色未找到，需要手动调整光电眼位置，调整好后人工置位*)-----------------Reset
									Bit5 xPreCurManuAdjust :BOOL;(*前一色未找到，需要观察原因调整好后，人工点确定，等一个机组料长后置位*)
									Bit6 xFindsignalNormal :BOOL; 当前色正常用于报警
	*)

	iStep_AutoAdjust:  INT;(*主站全自动套印的找标的执行状态   -------------------步骤码*)

	//2026.04.28.135156  xi.hy新增@七号开始
	iStsSlave_FiberMove:INT;(*光纤行走从站状态机*)
	//2026.05.08.111008全自动套印下发模版
	aiCurModeMidPoint: ARRAY [1..4] OF INT;//当前色模版中心
	abyCurModeRadius:ARRAY [1..4] OF BYTE;//当前色模版半径
	aiPreModeMidPoint: ARRAY [1..4] OF INT;//前一色模版中心
	abyPreModeRadius:ARRAY [1..4] OF BYTE;//前一色模版半径
	byOuterCoff :BYTE ;//外滑窗系数 *10
	byInnerCoff	:BYTE;	//内滑窗系数 *10
	bySpotWidth :BYTE;	(*光斑宽度*10*)
	
	
	xManualSingleAxisEn:BOOL;(*轴手动色标居中使能*)
	
	//2026.05.28.181139//xi.hy//基准位置@来自主站
	rFiberMoveBasePosFromSlave:REAL;

	
	abyRSV_UnitParam_UnSave: ARRAY [1..860] OF BYTE;
	
//	abyRSV_UnitParam_UnSave: ARRAY [1..865] OF BYTE;
	//2026.05.08.111042屏蔽iKcode_Mark_Interval  bySignalType iTaps_Mark_Interval 添加 aiCurModeMidPoint ->bySpotWidth 887+5-27=865
	//2026.04.28.135139 iStsSlave_FiberMove|889-2=887
	//2026.4.6.133721	增加一些状态全自动套印相关4个字节wCommFromDubheFindSignal->iStep_AutoAdjust|893-4=889
	//(*2026.03.28.113024||wang.xy xFiberMoveIdle->xFiberMoveDisRunStart_FindSignal 899-6=893*)
	(*2026.03.18.113533|rFiberMoveDistanceIn->rWidth_FindMarkCenter|927-29=899*)
	(*2026.03.16.132743 xFlag_FindFirstMark->xFlag_AutoAdj_En ||全自动套印 963-36=927*)	

	//2026.2.10.103203 增加横向步进量 967->963
	
END_STRUCT
END_TYPE


{IMPLEMENTATION}
