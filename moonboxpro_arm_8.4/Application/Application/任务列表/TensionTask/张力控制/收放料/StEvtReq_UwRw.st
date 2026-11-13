(*@CES
Name=StEvtReq_UwRw
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=5715f174-feea-429a-a472-843deab1b726
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
{attribute 'pack_mode' := '1'}
TYPE StEvtReq_UwRw :
STRUCT
	xEvt_IsUpCut: BOOL;(*上下裁切换*)
	xReq_IsUpCut: BOOL;
	
	xEvt_PreCut: BOOL;(*预备接料*)
	xReq_PreCut: BOOL;
	
	xEvt_CutCancel: BOOL;(*接料解除*)
	xReq_CutCancel: BOOL;
	
	xEvt_Cut: BOOL;(*接料按钮*)
	xReq_Cut: BOOL;
	
	xReq_AxisExchange: BOOL;(*轴切换*)
	xEvt_AxisExchange: BOOL;(*轴切换*)
	
	xReq_AxisInch: BOOL;(*单运行*)
	xEvt_AxisInch: BOOL;(*单运行*)
	
	xReq_Forward: BOOL;(*转架正转*)
	xEvt_Forward: BOOL;(*转架正转*)
	xReq_Reversal: BOOL;(*转架正转*)
	xEvt_Reversal: BOOL;(*转架正转*)
	
	xReq_Estop: BOOL;(*急停*)
	xEvt_Estop: BOOL;
	
	xReq_Inch: BOOL;
	xEvt_Inch: BOOL;
	xReq_RevInch: BOOL;
	xEvt_RevInch: BOOL;
		
	xReq_UwMeasureSensor: BOOL;(*包含了对射电眼检测和接近开关检测*)
	xEvt_UwMeasureSensor: BOOL;(*包含了对射电眼检测和接近开关检测*)
	
	xReq_AxisA_Locating_Up: BOOL;(*上裁A定位*)
	xEvt_AxisA_Locating_Up: BOOL;
	xReq_AxisB_Locating_Up: BOOL;(*上裁B定位*)
	xEvt_AxisB_Locating_Up: BOOL;
	xReq_AxisA_Locating_UpCut_PaperCore6Inch	: BOOL; (* 上裁A轴6寸定位 *)
	xEvt_AxisA_Locating_UpCut_PaperCore6Inch	: BOOL; (* 上裁A轴6寸定位 *)
	xReq_AxisB_Locating_UpCut_PaperCore6Inch	: BOOL; (* 上裁B轴6寸定位 *)
	xEvt_AxisB_Locating_UpCut_PaperCore6Inch	: BOOL; (* 上裁B轴6寸定位 *)
	
	
	xReq_MinimumDiamProtect_Up: BOOL;(*上裁最小定位*)
	xEvt_MinimumDiamProtect_Up: BOOL;
	xReq_Sensor_DiamMeasureLocating_Up: BOOL;(*上裁对射*)
	xEvt_Sensor_DiamMeasureLocating_Up: BOOL;
	xReq_Sensor_Reflex_Up_AxisA: BOOL;(*反射电眼-弧面*)
	xEvt_Sensor_Reflex_Up_AxisA: BOOL;(*反射电眼-弧面*)
	xReq_Sensor_Reflex_Dn_AxisA: BOOL;(*反射电眼-弧面*)
	xEvt_Sensor_Reflex_Dn_AxisA: BOOL;(*反射电眼-弧面*)
	xReq_Sensor_Reflex_Up_AxisB: BOOL;(*反射电眼-弧面*)
	xEvt_Sensor_Reflex_Up_AxisB: BOOL;(*反射电眼-弧面*)
	xReq_Sensor_Reflex_Dn_AxisB: BOOL;(*反射电眼-弧面*)
	xEvt_Sensor_Reflex_Dn_AxisB: BOOL;(*反射电眼-弧面*)
	
	
	xReq_AxisA_Locating_Dn: BOOL;(*下裁A定位*)
	xEvt_AxisA_Locating_Dn: BOOL;
	xReq_AxisB_Locating_Dn: BOOL;(*下裁B定位*)
	xEvt_AxisB_Locating_Dn: BOOL;
	xReq_AxisA_Locating_DnCut_PaperCore6Inch	: BOOL; (* 下裁A轴6寸定位 *)
	xEvt_AxisA_Locating_DnCut_PaperCore6Inch	: BOOL; (* 下裁A轴6寸定位 *)
	xReq_AxisB_Locating_DnCut_PaperCore6Inch	: BOOL; (* 下裁B轴6寸定位 *)
	xEvt_AxisB_Locating_DnCut_PaperCore6Inch	: BOOL; (* 下裁B轴6寸定位 *)
	
	xReq_MinimumDiamProtect_Dn: BOOL;(*下裁最小定位*)
	xEvt_MinimumDiamProtect_Dn: BOOL;
	xReq_Sensor_DiamMeasureLocating_Dn: BOOL;(*下裁对射*)
	xEvt_Sensor_DiamMeasureLocating_Dn: BOOL;
	
	xEvt_PaperCoreSelect6Inch: BOOL;(*6吋纸芯有效*)
	xReq_PaperCoreSelect6Inch: BOOL;(*6吋纸芯有效*)
	
	xEvt_Taper_Incr: BOOL;
	xReq_Taper_Incr: BOOL;
	xEvt_Taper_Decr: BOOL;
	xReq_Taper_Decr: BOOL;
	
	
	xOutEstop: BOOL;(*急停*)
	xOutCutOnTop: BOOL;(*上裁指示*)
	xOutSafeTyGrating: BOOL;(*安全光栅*)
	
	xOutCutHolder: BOOL;(*大臂输出*)
	xOutCutHolder_Up: BOOL;
	xOutCutHolder_Dn: BOOL;
	xOutCutCylinder: BOOL;(*大臂压辊*)
	xOutCutCylinder_Up: BOOL;	
	xOutCutCylinder_Dn: BOOL;
	xOutCutter: BOOL;(*裁刀*)
	xOutCutter_Up: BOOL;(*裁刀*)
	xOutCutter_Dn: BOOL;(*裁刀*)
	
	xOutTowerFor: BOOL;(*翻转架正转*)
	xOutTowerRev: BOOL;(*翻转架反转*)
	
	xOutAxisAFor: BOOL;(*A轴正转*)
	xOutAxisARev: BOOL;(*A轴反转*)
	xOutAxisAZeroServo: BOOL;(*A轴零伺服*)
	xOutAxisBFor: BOOL;(*B轴正转*)
	xOutAxisBRev: BOOL;(*B轴反转*)
	xOutAxisBZeroServo: BOOL;(*B轴零伺服*)	
	xOutAxisALamp: BOOL;(*A轴指示*)
	xOutAxisBLamp: BOOL;(*B轴指示*)
	
	xOutAxisATorqueCancel: BOOL;(*转矩取消*)
	xOutAxisBTorqueCancel: BOOL;(*转矩取消*)
	wOutAxisATorqueVolt: WORD;(*转矩*)
	wOutAxisBTorqueVolt: WORD;(*转矩*)
	
	xOutLamp_SafeTyGrating_Out: BOOL;(*光栅保护*)
	xOutLampAxisInching: BOOL;(*轴单运行指示*)
	xOutLampPreDrive: BOOL;(*预驱完成指示灯*)
	xOutAlarmBell: BOOL;(*报警铃*)
	xOutLamp_PaperCoreSelect6Inch: BOOL;(*6吋纸筒*)
END_STRUCT
END_TYPE

{IMPLEMENTATION}
