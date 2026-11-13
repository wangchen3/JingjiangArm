(*@CES
Name=StHandWheel_BtnCtl
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=b84cb397-2bed-4490-8555-fa94b8c7b26f
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
TYPE StHandWheel_BtnCtl :
STRUCT
	xReq_Inch_Net: BOOL;//匀墨
	xReqSwitch_Calib: BOOL;
	xReq_Confirm_Adjust_PressDn: BOOL;//位置矫正
	lrPos_HandWheelChange: LREAL;//手轮变化量
	
	xReqMove_M: BOOL;
	xReqMove_G: BOOL;
	xReqMoveUp: BOOL;
	xReqMoveDn: BOOL;
	
	xAdjust_V_Up : BOOL;
	xAdjust_V_Dn : BOOL;
	xAdjust_H_M : BOOL;
	xAdjust_H_G : BOOL;
	
	
//下面是需要区分版辊压力、网棍压力、张带辊压力的	
	axReqLoad_Unload: ARRAY [1..gc_iMax_PressureRoller_Unit] OF BOOL;
	axReqPress_Up: ARRAY [1..gc_iMax_PressureRoller_Unit] OF BOOL;
	axReqPress_Dn: ARRAY [1..gc_iMax_PressureRoller_Unit] OF BOOL;
	
	axReqMoveFor: ARRAY [1..gc_iMax_PressureRoller_Unit] OF BOOL;
	axReqMoveRev: ARRAY [1..gc_iMax_PressureRoller_Unit] OF BOOL;
	
	axReq_Confirm_Load_Unload: ARRAY [1..gc_iMax_PressureRoller_Unit] OF BOOL;
	axReq_Confirm_press_up: ARRAY [1..gc_iMax_PressureRoller_Unit] OF BOOL;
	axReq_Confirm_press_dn: ARRAY [1..gc_iMax_PressureRoller_Unit] OF BOOL;

	axFlag_Ctl_Roller_All: ARRAY [1..gc_iMax_PressureRoller_Unit] OF BOOL;//控制的是同进同退-版辊
	axFlag_Ctl_Roller_M: ARRAY [1..gc_iMax_PressureRoller_Unit] OF BOOL;
	axFlag_Ctl_Roller_G: ARRAY [1..gc_iMax_PressureRoller_Unit] OF BOOL;
	
END_STRUCT
END_TYPE


{IMPLEMENTATION}
