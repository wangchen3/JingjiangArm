(*@CES
Name=StProgMonitoring
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=212a47fe-cf90-4c52-849d-68b6b927c1da
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
{attribute 'pack_mode' := '1'}
TYPE StProgMonitoring :
STRUCT
	i_lrUw_real				: LREAL; (* 放料摆臂真实值/2019.1.25.091316 *)
	i_lrUw_cur				: LREAL; (* 放料摆臂电压值/相对中位 *)
	i_wUw_cur				: WORD; (* 放料摆臂数字值 *)
	i_lrIf_real				: LREAL; (* 放牵摆臂真实值/2019.1.25.091307 *)
	i_lrIf_cur				: LREAL; (* 放牵摆臂电压值/相对中位 *)
	i_wIf_cur				: WORD; (* 放牵摆臂数字值 *)
	i_lrOf_real				: LREAL; (* 收牵摆臂真实值/2019.1.25.091256 *)
	i_lrOf_cur				: LREAL; (* 收牵摆臂电压值/相对中位 *)
	i_wOf_cur				: WORD; (* 收牵摆臂数字值 *)
	i_lrRw_real				: LREAL; (* 收料摆臂真实值/2019.1.25.091233 *)
	i_lrRw_cur				: LREAL; (* 收料摆臂数字值/相对中位 *)
	i_wRw_cur				: WORD; (* 收料摆臂电压值 *)
	i_lrPressure_Vol		: LREAL; (* 压力传感器电压值 *)
	i_wPressure_Vol			: WORD; (* 压力传感器数字值 *)
	o_wUwAxisA_cur			: WORD; (* 放料A轴数值 *)
	o_lrUwAxisA_Vol			: LREAL; (* 放料A轴电压值 *)
	o_lrUwAxisA_Feq			: LREAL; (* 放料A轴频率 *)
	o_wUwAxisB_cur			: WORD; (* 放料B轴数值 *)
	o_lrUwAxisB_Vol			: LREAL; (* 放料B轴电压值 *)
	o_lrUwAxisB_Feq			: LREAL; (* 放料B轴频率 *)
	o_wRwAxisA_cur			: WORD; (* 收料A轴数值 *)
	o_lrRwAxisA_Vol			: LREAL; (* 收料A轴电压值 *)
	o_lrRwAxisA_Feq			: LREAL; (* 收料A轴频率 *)
	o_wRwAxisB_cur			: WORD; (* 收料B轴数值 *)
	o_lrRwAxisB_Vol			: LREAL; (* 收料B轴电压值 *)
	o_lrRwAxisB_Feq			: LREAL; (* 收料B轴频率 *)
	o_wVelocity_cur			: WORD; (* 线速度表数值 *)
	o_lrVelocity_Vol		: LREAL; (* 线速度表电压值 *)
	o_wTaper_cur			: WORD; (* 电控比例阀数值 *)
	o_lrTaper_Vol			: LREAL; (* 电控比例阀电压值 *)
	o_wIf_cur				: WORD; (* 放牵数值 *)
	o_lrIf_Vol				: LREAL; (* 放牵电压值 *)
	o_lrIf_Feq				: LREAL; (* 放牵频率 *)
	o_wOf_cur				: WORD; (* 收牵数值 *)
	o_lrOf_Vol				: LREAL; (* 收牵电压值 *)
	o_lrOf_Feq				: LREAL; (* 收牵频率 *)
	o_wPreHotRoller_Vol		: WORD; (* 传动辊/预热辊数字值 *)
	o_lrPreHotRoller_Vol	: LREAL; (* 传动辊/预热辊电压值 *)
	i_wDiamMeasureUpCut		: WORD; (* 上裁卷径电位器/2018.11.22.103723 *)
	i_lrDiamMeasureUpCut	: LREAL; (* 上裁卷径电位器/2018.11.22.103723 *)
	i_wDiamMeasureDnCut		: WORD; (* 下裁卷径电位器/2018.11.22.103730 *)
	i_lrDiamMeasureDnCut	: LREAL; (* 上裁卷径电位器/2018.11.22.103723 *)

	(*2023.09.04.144717@20bytes*)
	i_wDiamMeasureAxisA		: WORD; (* A轴卷径超声波/ *)
	i_lrDiamMeasureAxisA	: LREAL; (* A轴卷径超声波/*)
	i_wDiamMeasureAxisB		: WORD; (* B轴卷径超声波/*)
	i_lrDiamMeasureAxisB	: LREAL; (* B轴卷径超声波/*)
	abyReservedFields		: ARRAY [1..20] OF BYTE; (* 预留空间 *)	
END_STRUCT
END_TYPE

{IMPLEMENTATION}
