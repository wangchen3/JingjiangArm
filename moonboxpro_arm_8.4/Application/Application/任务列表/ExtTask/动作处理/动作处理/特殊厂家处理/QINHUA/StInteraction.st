(*@CES
Name=StInteraction
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=92655e52-0a81-42c1-97b4-09e52fb18b53
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
TYPE StInteraction :
STRUCT
	i_xPressEngageSignal:BOOL;(*色组压力合压信号*)
	i_xPressWarningSignal:BOOL;(*色组压力报警信号*)
	i_xPressRetractionPositionSignal:BOOL;(*色组压力退版到位信号*)
	i_xRsvdDI1:BOOL;(*拓展输入1*)
	i_xRsvdDI2:BOOL;(*拓展输入2*)
	i_xRsvdDI3:BOOL;(*拓展输入3*)
	
	o_xCoarseAdjStart:BOOL;(*色组粗调开始*)
	o_xCoarseAdjEnd:BOOL;(*色组粗调结束*)
	o_xUnitWarningSignal:BOOL;(*色组报警信号*)
	o_xRsvdDO1:BOOL;(*拓展输出1*)
	o_xRsvdDO2:BOOL;(*拓展输出2*)
	o_xRsvdDO3:BOOL;(*拓展输出3*)
END_STRUCT
END_TYPE
{IMPLEMENTATION}
