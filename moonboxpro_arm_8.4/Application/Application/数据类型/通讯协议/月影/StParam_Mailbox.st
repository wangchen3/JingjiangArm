(*@CES
Name=StParam_Mailbox
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=28298cb9-a045-46a0-b057-5251b4c14df2
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
{attribute 'pack_mode' := '1'}
TYPE StParam_Mailbox :
STRUCT
	dwSemaphore						:DWORD;(*通讯旗语						*)
	dwPlateAdjustmentProf			:DWORD;(*纵向版快速调整量/bit24~bit31为请求信号/低24bit用来表示要调整的量<单位:0.01mm>/ 	*)
	iRapidAdjProf_h					:INT  ;(*横向快速对版量描述				*)
	iGateSa							:INT  ;(*第一波门位置					*)
	iGateSaEx						:INT  ;(*第二波门位置					*)
	rAdjust_V						:REAL ;(*纵向版修正量					*)
	rAdjust_H						:REAL ;(*横向版修正量					*)
	dwFlag_Ctl						:DWORD;(*套色控制标志					*)
	dwFlag_Sts						:DWORD;(*套色状态标志					*)
	wButtonFun_Lamp					:WORD ;(*HMI界面按钮及指示灯			*)
	wSwitchFun						:WORD ;(*界面开关*)
	wRsv							:WORD;
//2025.11.7.142851先把数据统一了，dwSlaveBtn_HMI分两个word,一个暂时baoliu
//	dwSlaveBtn_HMI					:DWORD;(*界面按钮						*)
	rStep_Pressure_Prn_Net			:REAL ;(*版辊网辊按钮步进量				*)
	rLong_Step_Roller_Pressure		:REAL ;(*色组压力控制长步进值			*)
	rShort_Step_Roller_Pressure		:REAL ;(*色组压力控制短步进值			*)
	wAirInletWindDoorValue			:WORD ;(*进风口风门开度值				*)
	wAirExhaustWindDoorValue		:WORD ;(*排风口风门开度值				*)
	wAirReturnWindDoorValue			:WORD ;(*回风口风门开度值				*)
	dwCtlBits_UnitBaseCraft			:DWORD;(*界面工艺开关及状态				*)
	wHz_UnitInkRoller_ManuallySet	:WORD ;(*递墨辊手动频率					*)
	wCoeff_UnitInkRoller_Auto		:WORD ;(*递墨辊自动系数					*)
	wHz_UnitScraper_ManuallySet		:WORD ;(*刮刀手动频率					*)
	wCoeff_UnitScraper_Auto			:WORD ;(*刮刀自动系数					*)
	wHz_UnitHotWind					:WORD ;(*热风频率						*)
	wHz_UnitHotWind_2				:WORD ;(*热风2频率						*)
	wSV_UnitTemCtl					:WORD ;(*加热设定温度					*)
	wUnit_output_I					:WORD ;(*IO监控输出1					*)
	wUnit_output_II					:WORD ;(*IO监控输出2					*)
	//xi.hy//新增
	bySignalSelect					:BYTE; (*光纤电眼信号选择*)
	rOffset_T1						:REAL;	//T1路光纤偏移
	rSource_Light_T1       			:REAL;  //T1路光纤光源
	rBias_T1			  			:REAL;  //T1路光纤电眼偏置
	rBrightness_Light_T1			:REAL;  //T1路光纤电眼亮度

	rOffset_T2						:REAL;  //T2路光纤偏移
	rSource_Light_T2				:REAL;  //T2路光纤光源
	rBias_T2						:REAL;  //T2路光纤电眼偏置
	rBrightness_Light_T2			:REAL;  //T2路光纤电眼亮度
	
	(*2025.8.14.143359增加一些参数*)
// 	wAccButton_Count				: WORD;
// 	wDecButton_Count			: WORD;
// 	wUpAdjButton_Count			: WORD;
// 	wDnAdjButton_Count			: WORD;
// 	wLeftAdjButton_Count			: WORD;
// 	wRightAdjButton_Count			: WORD;
// 	wAlarmButton_Count			: WORD;
	
	rHz_AxisAirBlowning_ManuallySet			: REAL;
	rHz_AxisAirExhaust_ManuallySet		: REAL;

	wSlaveBtn_HMI		: WORD;    //.0 版辊操作侧靠近
								   //.1 版辊操作侧远离
								   //.2 版辊平行靠近
								   //.3 版辊平行远离
								   //.4 版辊传动侧靠近
								   //.5 版辊传动侧远离
								   //.6 网辊操作侧靠近
								   //.7 网辊操作侧远离
								   //.8 网辊平行靠近
								   //.9 网辊平行远离
								   //.10 网辊传动侧靠近
								   //.11 网辊传动侧远离
								   //.12 版辊标定
								   //.13 网辊标定
								   //.14 张带棍标定
							 	   //.15 版辊合压
	wSlaveBtn_HMI2		: WORD;
									//. 0  版辊离压
									//. 1 网辊合压
									//. 2 网辊离压
									//. 3 版辊换版
									//. 4 网辊换版
									//. 5 自动换版
									//. 6 换版完成
									// .7 显示换版状态
	wButtonAndSwitch_ChaoXu	: WORD;	//.0 匀墨
										//.1 网辊锁轴
										//.2 充气
										//.3 墨盘电磁阀升
										//.4 照明
										//.5 显示是否修改版周
										//.6 确认修改版周
										//.7
										//.8 
										//.9 版辊单动
										//.10 底辊单动
										//.11 合压
										//.12 离压			
										//.13 横向左移
										//.14 横向右移

	uiRsv_data					: UINT;//压力电机步进量2026.02.07.143804
	iStep_Horz_Use						: INT;			
	
	//xi.hy
	wState_FiberMove:WORD;	//光纤行走状态
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
	wAlarm_FiberMove:WORD;		//光纤行走报警
	iFiberMoveDistanceIn:INT;	//光纤行走距离输入 *10
	iPosCur_FiberMove:INT;		//光纤行走当前位置*10
	iWidth_FindMarkCenter:INT;	//光纤行走 计算出来的宽度*100
	//2026.5.9.182337
	//2026.04.28.132649 xi.hy新增@七号开始
	iStsSlave_FiberMove:INT;  // 光纤行走 从站运动状态机	
	//2026.05.28.181612
	iFiberMoveBasePosFromSlave:INT;//基准位置@来自从站	
	
END_STRUCT
END_TYPE

{IMPLEMENTATION}
