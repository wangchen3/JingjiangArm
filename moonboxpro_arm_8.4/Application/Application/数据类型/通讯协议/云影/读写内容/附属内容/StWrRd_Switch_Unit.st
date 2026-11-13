(*@CES
Name=StWrRd_Switch_Unit
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=a2047d0e-672b-403c-b194-95cddde93ad4
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
{attribute 'pack_mode' := '1'}//总16字节
TYPE StWrRd_Switch_Unit :
STRUCT
	xSwitch_CoatingPrn					: BIT;(*色组涂布开关*)
	xSwitch_CoatingRec					: BIT;(*涂布调整反向*)
	xSwitch_ScraperAuto					: BIT;(*刮刀手自动*)
	xSwitch_ScraperOn					: BIT;(*刮刀开关*)
	xSwitch_InkRollerAuto				: BIT;(*递墨辊手自动*)
	xSwitch_InkRollerCW					: BIT;(*递墨辊正转*)
	xSwitch_InkRollerCCW				: BIT;(*递墨辊反转*)
	xSwitch_HotWindOn					: BIT;(*热风开关*)
	xSwitch_HeatingOn					: BIT;(*加热开关*)
	xSwitch_Heating_I					: BIT;(*加热I档*)
	xSwitch_Heating_II					: BIT;(*加热II档*)
	xSwitch_Heating_III					: BIT;(*加热III档*)
	xSwitch_ThisUnitEna					: BIT;(*色组套印开关*)
	xSwitch_Horz						: BIT;(*横向开关*)
	xSwitch_DoorBaseLn					: BIT;(*门内基线开关*)
	
	xSwitch_SmallSignalProcessing_T1	: BIT;(*第一组波门T1内小信号处理开关*)
	xSwitch_SmallSignalProcessing_T2	: BIT;(*第一组波门T2内小信号处理开关*)
	xSwitch_Rsv_1						: BIT;
	xSwitch_Rsv_2						: BIT;
(*	2025.10.27.141051||小信号只有两个T1和T2，不用分波门
	xSwitch_SmallSignalProcessing_T1_1	: BIT;(*第一组波门T1内小信号处理开关*)
	xSwitch_SmallSignalProcessing_T2_1	: BIT;(*第一组波门T2内小信号处理开关*)
	xSwitch_SmallSignalProcessing_T1_2	: BIT;(*第二组波门T1内小信号处理开关*)
	xSwitch_SmallSignalProcessing_T2_2	: BIT;(*第二组波门T2内小信号处理开关*)
	*)
	xSwitch_AutoAdjust_V_Unit			: BIT;(*整机纵向自动调整开关*)
	xSwitch_AutoAdjust_H_Unit			: BIT;(*整机纵向自动调整开关*)
	xSwitch_NegativePolarity_T1_1		: BIT;(*第一组波门内T1信号反极性*)
	xSwitch_NegativePolarity_T2_1		: BIT;(*第一组波门内T2信号反极性*)
	xSwitch_NegativePolarity_T1_2		: BIT;(*第二组波门内T1信号反极性*)
	xSwitch_NegativePolarity_T2_2		: BIT;(*第二组波门内T2信号反极性*)
	xSwitch_AdjRev_V					: BIT;(*纵向调整反*)
	xSwitch_AdjRev_H					: BIT;(*横向调整反*)
	xSwitch_AdjRev_O					: BIT;(*单标记调整反*)
	xSwitch_Follow_1U_V_Unit			: BIT;(*纵向跟1色开关*)
	xSwitch_Follow_1U_H_Unit			: BIT;(*横向跟1色开关*)	
	xSwitch_DualPolarity				: BIT;(*双极性开关*)
	xSwitch_UnitRevPrn					: BIT;(*色组反印开关*)
	xSwitch_DualGate					: BIT;(*双波门开关*)
	xSwitch_Transfer_Err				: BIT;(*误差传递开关*)
	xSwitch_Transfer_Adj				: BIT;(*调整量传递开关*)
(*卷径估计与色组无关|2025.8.20.163318|niu.j|放出两个BIT位
	xSwitch_Estimate_Uw					: BIT;(*放料卷径估计开关*)
	xSwitch_Estimate_Rw					: BIT;(*收料卷径估计开关*)
	*)
//占用xRsv_Flag1作为印长调整开关2025.12.31.112738
	xSwitch_AdjBandLen					: BIT;
//	xRsv_Flag1							: BIT;
	xRsv_Flag2							: BIT;
	
	xSwitch_Heating_Water				: BIT;(*水加热控制开关*)
	xSwitch_Heating_Elc					: BIT;(*电加热控制开关*)
	xSwitch_ExhAir						: BIT;(*色组排风开关*)
	
	/////////////////////////////////////////////////////////////////////////////////////////////
	//以上刚好40bit，再增加11字节吧预留
	//2025.7.3.175755增加7BIT
	xCompensateEn_H						: BIT;		
	xUseAntiNotch_Arc   				: BIT;						
	xUsePeriodic    					: BIT;   						
	T1_S         						: BIT;       						
	T2_S         						: BIT;       						
	PT1000_M    						: BIT;        	
	ENCTMP_M     						: BIT;       	
	xSwitch_HorzMoveLeft_Manu_1							: BIT;(*横向左调0.01*)
	xSwitch_HorzMoveLeft_Manu_2							: BIT;(*横向左调0.02*)
	xSwitch_HorzMoveLeft_Manu_3							: BIT;(*横向左调0.05*)
	xSwitch_HorzMoveRight_Manu_1						: BIT;(*横向右调0.01*)
	xSwitch_HorzMoveRight_Manu_2						: BIT;(*横向右调0.02*)
	xSwitch_HorzMoveRight_Manu_3						: BIT;(*横向右调0.05*)
//2025.10.14.105504bit6和7用做dwControlBits.30和.31
//	xRsv_Flag6											: BIT;
//	xRsv_Flag7											: BIT;
	xSwitch_TempFromEnc_PT1000							: BIT;
	xSwitch_MotorTemp_PT1000_NTC						: BIT;
//2025.12.30.222739变量xUnitExhaustDamperCtl_Auto占用Bit8||	
	xUnitExhaustDamperCtl_Auto							: BIT;//排风风门控制自动
	//xRsv_Flag8											: BIT;
	(*2025.9.20.092456占用一个byte用于通讯界面横向手动按钮10-1=9*)
	
//2026.2.2.162623再取一个BYTE用做位处理2026.2.2.162710||niu.j||9-1=8	
//取bit00用做清除标定按钮
	xSwitch_ResetFlag_FinishCalid						: BIT;
//	xRsv_Flag00											: BIT;
//取bit01用作标定模式界面开关
//	xSwitch_ModeCalib_Press								: BIT;
//	xRsv_Flag01											: BIT;
	xSwitch_Linkage										: BIT;//色组联动开关
	xSwitch_Ink											: BIT;//匀墨开关
//	xRsv_Flag02											: BIT;
//2026.4.24.144718||程序合并||新增6bit位||预留全部占完，需要新开一个byte
	xBtn_ConfirmLimit_Left								: BIT;//横向标定左
	xBtn_ConfirmLimit_Right								: BIT;//横向标定右
	xBtn_ResetLimit_Left								: BIT;//清除标定
	xBtn_ResetLimit_Right								: BIT;//清除标定
	xBtn_MoveLeft_Horz									: BIT;//横向左移
	xBtn_MoveRight_Horz									: BIT;//横向右移
//2026.4.24.145339结束	
//2026.4.6.103029|占用两个变量处理全自动套印相关；bit3 he 4
	xSwitch_CurManuAdjust							: BIT;//(*当前色未找到，需要手动调整光电眼位置，调整好后人工置位*)
	xSwitch_PreCurManuAdjust						: BIT;//(*前一色未找到，需要观察原因调整好后，人工点确定，等一个机组料长后置位*)
//	xRsv_Flag00										    : BIT;
//	xRsv_Flag01											: BIT;
//本次占用结束2026.4.6.103323	
//占用一个，做冷风开关
//	xRsv_Flag02											: BIT;
	xSwitch_CoolWind									: BIT;
//2026.5.29.171622结束
	xRsv_Flag03											: BIT;
	xRsv_Flag04									  		: BIT;
	xRsv_Flag05											: BIT;
	xRsv_Flag06											: BIT;
	abyRsv_Flag: ARRAY [1..7] OF BYTE;	
END_STRUCT
END_TYPE

{IMPLEMENTATION}
