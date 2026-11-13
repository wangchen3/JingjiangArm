(*@CES
Name=ENUM_ControlledObjType
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=c8e054b6-804a-4d86-ae05-73109a0c00ab
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
TYPE ENUM_ControlledObjType :
(
	OBJ_IS_MASTERAXIS,(*主轴*)
	OBJ_IS_UNDEFINED,
	OBJ_IS_UNWIND_A,(* 放卷A *)
	OBJ_IS_UNWIND_B,(* 放卷B *)
	OBJ_IS_REWIND_A,(* 收卷A *)
	OBJ_IS_REWIND_B,(* 收卷B *)
	OBJ_IS_INFEED,(* 放牵 *)
	OBJ_IS_OUTFEED,(* 收牵 *)
	OBJ_IS_BOTTOM_ROLLER,(* 色组底辊 *)
	OBJ_IS_PRN_ROLLER,(* 色组版辊 *)
	
	OBJ_IS_NET_ROLLER,(* 色组网辊 *)
	OBJ_IS_PRN_ROLLER_PRESSURE_M,(* 色组版辊压力M侧 *)
	OBJ_IS_PRN_ROLLER_PRESSURE_G,(* 色组版辊压力G侧 *)
	
	OBJ_IS_NET_ROLLER_PRESSURE_M,(* 色组网辊压力M侧 *)
	OBJ_IS_NET_ROLLER_PRESSURE_G,(* 色组网辊压力G侧 *)
	OBJ_IS_STR_ROLLER_PRESSURE_M,(* 色组张带辊压力M侧 *)
	OBJ_IS_STR_ROLLER_PRESSURE_G,(* 色组张带辊压力G侧 *)
	OBJ_IS_HORIZ_MOTION,(* 横向运动电机/2022.6.8.142000 *)
	OBJ_IS_CENTRAL_DRUM,(* 中心滚筒/2022.6.8.135513 *)
	OBJ_IS_PHOTOCELL(*光电眼行走机构 | 2024.04.01.092649*)

);
END_TYPE

{IMPLEMENTATION}
