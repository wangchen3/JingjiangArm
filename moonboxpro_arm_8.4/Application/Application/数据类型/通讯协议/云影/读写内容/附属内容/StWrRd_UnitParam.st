(*@CES
Name=StWrRd_UnitParam
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=921fa842-8dc1-46c6-9dca-e62db1c4c4c1
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
{attribute 'pack_mode' := '1'}
TYPE StWrRd_UnitParam :
STRUCT
	stBitStWrRd_Switch_Unit							: StWrRd_Switch_Unit;(*总16*16字节*)
	rGirth_Using_CoatingPrn							: REAL;(*涂布周长*)
	byBtn_AdjModeSwitch_CoatingPrn					: BYTE;(*涂布调整方式切换按钮*)
	rStep_OfChangeGirth								: REAL;(*涂布版轴修改步幅*)
	rHz_UnitScraper_ManuallySet						: REAL;(*刮刀手动频率*)
	rCoeff_UnitScraper_Auto							: REAL;(*刮刀自动系数*)
	rHz_UnitInkRoller_ManuallySet					: REAL;(*递墨辊手动频率*)
	rCoeff_UnitInkRoller_Auto						: REAL;(*递墨辊自动系数*)
	rHz_UnitHotWind_ManuallySet						: REAL;(*热风手动频率*)
	rSV_UnitTemCtl									: REAL;(*加热设定温度*)
	iGateWidthPhy									: INT;(*波门宽度*)
	rAlarm_V										: REAL;(*纵向报警值*)
	rAlarm_H										: REAL;(*横向报警值*)
	rAdjust_V										: REAL;(*纵向修正量*)
	rAdjust_H										: REAL;(*横向修正量*)
	rDeadzoneMax_H									: REAL;(*横向最大不动作区*)
	rDeadzoneMin_H									: REAL;(*横向最小不动作区*)
	iCoefOfCoupling_V								: INT;(*纵向传递2系数*)
	byAverage_V										: BYTE;(*纵向平均值*)
	byAverage_H										: BYTE;(*横向平均值*)
	(*2025.8.20.161154|这里重新分配输出测试吧2025.8.20.161207|niu.j|先释放这里的空间*)
	(*awOutput_IOtestDO_Axis							: ARRAY [1..8] OF WORD;(*主面板IO测试输出*)
	awOutput_IOtestAO_Axis							: ARRAY [1..16] OF WORD;(*主面板IO测试输出*)*)
	
	(*2025.9.19.123648|niu.j|增加色组顺逆序选择|48-2=46*)
	iMarkArrangeMode							: INT;(* 标记排列方式 *)
	
//2025.10.20.151240||增加预套准相关参数|niu.j|46-10=36
	rPreReg_Adjust							: REAL;(*预套准调整量|*)
	rPreReg_ConstVal						: REAL;(*预套准色组间固定料长部分|单位:mm*)	
	uiTurnOverFilmLenth						: UINT;(*翻料架料膜长度@mm*)	
//2025.10.20.153028增加横向预套准参数36-12=24
	diPreReg_RepeatVal_H					: DINT;(*预套准重复值-横向|单位:mm|*)
	diPreReg_SetupVal_H						: DINT;(*预套准设定值-横向|单位:mm|*)
	diPreReg_AdjustVal_H					: DINT;(*预套准修正值*)
	
//2025.10.23.104815||增加一些配方里需要保存的内容24-14=10
	rGirth_PrnRoller					: REAL;
	iMarkTypeId_Pu						: INT;
	byAirInletWindDoorValue				: BYTE;
	byOvensAirOutWindDoorValue			: BYTE;
	byAirExhaustWindDoorValue			: BYTE;
	byAirReturnWindDoorValue			: BYTE;
	rHz_UnitHotWind_2_ManuallySet		: REAL;
	
	
	
//2025.12.30.223020|增加排风风门位置手动设定值||10-4=6
	rUnitExhaustDamperPos_ManuallySet		: REAL;(*排风风门位置手动设置值*)
//2025.12.31.112556增加带长调整一些参数|2字节|6-2=4
	iBandLengthFilterCnt					: INT;//带长滤波次数
	abyRsvData_2										: ARRAY [1..4] OF BYTE;
	
	
	uiTimeMs_RollerPressUpKeep						: UINT;(*压辊双气缸-离压保持时间*)
	uiAxisNum										: UINT;(*色组单独减速比分子*)
	uiAxisDen										: UINT;(*色组单独减速比分母*)
	rHz_UnitExhaust_ManuallySet						: REAL;(*色组排风设定频率*)
	
//9905界面内容
	
	rAxisVelPrf_Coeff1								: REAL;
	rAxisVelPrf_Coeff2             					: REAL;
	rAxisVelPrf_Coeff3             					: REAL;
	rMargin_Mag_Arc                					: REAL;
	//2026.05.13.091818+变量替换
	//rMargin_Phi_Arc                					: REAL;
	rKadj_I_Mol                					: REAL;
//	rMargin_Phi_Arc                					: REAL;
//2026.5.13.144804
//2026.4.25.142452结束
///	rKp_MolCal                     					: REAL;
///	rKi_MolCal                     					: REAL;
	abyRsv_Data_2									: ARRAY [1..8] OF BYTE;
//2026.4.25.142452结束
	rFilmLengthFromPrevPressUnit   					: REAL;
	byCompensateValue_Hor							: BYTE;
	byMaxAddValue_Total_Hor							: BYTE;
	rWn_Arc											: REAL;
	rBw_Arc											: REAL;
	rDp_Arc											: REAL;
	rK     											: REAL;
	rA2    											: REAL;
	rA1    											: REAL;
	rA0    											: REAL;	
	rG_Periodic  									: REAL;
	rW_Periodic  									: REAL;
	byCnt_Comm2ARM									: BYTE;

	
//2025.7.3.175755以上总共208字节
////////////////////////////////////////////////////////////分割线///////////////////////////////////////////////
	(*增加一个波门位置2025.8.25.151314*)	
	iGateSa											: INT;
	iGateSaEx										: INT;
//2025.10.20.142338增加纵横向飞点阈值|8-2=6
	byFakeThreshold_V				:BYTE;(*纵向飞点阀值@丝			*)
	byFakeThreshold_H				:BYTE;(*横向飞点阀值@丝			*)
//2025.10.20.143054增加界面显示误差平均次数6-1=5
	byAve_v_extra							: BYTE;(*界面误差显示平均值*)

	abyRsvData_0										: ARRAY [1..5] OF BYTE;

/////////////////////////////////////////////////////2025.7.3.175755新增12字节，总大小220byte//////////////////////////////////////////////////////////////	
	abyRsvData_1										: ARRAY [1..440] OF BYTE;
	//2025.8.20.161050|niu.j|增加色组输出测试
	awOutput_IOtestDO_Axis							: ARRAY [1..4] OF WORD;(*主面板IO测试输出*)
	awOutput_IOtestAO_Axis							: ARRAY [1..6] OF WORD;(*主面板IO测试输出*)
	awOutput_IOtestDO_Axis_Extra					: ARRAY [1..6] OF WORD;(*主面板IO测试输出*)
	awOutput_IOtestAO_Axis_Extra					: ARRAY [1..24] OF WORD;(*主面板IO测试输出*)
//2026.1.5.175104||增加一些变量总共16字节，140-16=124
	rGirth_BottomGirth								: REAL;
	rGirth_NetGirth									: REAL;
	uiNum_Bottom									: UINT;
	uiDen_Bottom									: UINT;
	uiNum_Net										: UINT;
	uiDen_Net										: UINT;
	//2026.2.2.161811增加界面的一些开关|niu.j|总4*3个字节12||124-12=112
	adwPressureMotor_Move_MasterHMI					: ARRAY [1..3] OF DWORD;
	//2026.04.02.191022 增加横向限位实时位置|Hou.N|112-12=100
 	diPos_LimitLeft									:DINT;
 	diPos_LimitRight								:DINT;
	
	abyData_rsv_h									: ARRAY [1..4] OF BYTE;
 	//diPos_Horz										:DINT;
	//2026.05.24.135408增加光纤行走变量|xi.hy|100-12=88
	rFiberMoveAdjust								:REAL;(*光纤行走色组修正量*)
	rFiberMoveAdjust_ByOnlie						:REAL;(*光纤行走在线修正量*)
	uiFiberMove_SoftLimit_Min						:UINT;(*光纤行走左限位*)
	uiFiberMove_SoftLimit_Max						:UINT;(*光纤行走右限位*)
	
	//2026.5.29.172149增加金刚火眼误差/月光宝盒误差获取与调整选择||88-1=87
	byGetErrMode									: BYTE;
	//2026.06.15.183819 增加电压设定值 0-220V | 87-3=84
	abyVoltage_SV:ARRAY [1..3] OF BYTE;
	abyRsvData_3									: ARRAY [1..84] OF BYTE;
	
//	abyRsvData_3									: ARRAY [1..100] OF BYTE;
END_STRUCT
END_TYPE

{IMPLEMENTATION}
