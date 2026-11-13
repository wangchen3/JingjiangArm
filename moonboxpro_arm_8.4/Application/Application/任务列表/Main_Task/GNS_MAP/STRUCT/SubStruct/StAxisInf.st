(*@CES
Name=StAxisInf
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=9c09e1be-ecab-48d2-aa55-657bbbb1d5bf
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
TYPE StAxisInf :(*轴信息*)
STRUCT
	iAxisId:INT;(*轴id*)
	(*轴内的站信息*)
	stBottomRollerInf			: StStationInf;(*底辊*)
	stPrnRollerInf				: StStationInf;(*印刷辊*)
	stNetRollerInf				: StStationInf;(*网纹辊*)
	stPrnRoller_Pressure_M		: StStationInf;(*压力电机@印刷辊*)
	stPrnRoller_Pressure_G		: StStationInf;
	stNetRoller_Pressure_M		: StStationInf;(*压力电机@网纹辊*)
	stNetRoller_Pressure_G		: StStationInf;
	stHorzInf					: StStationInf;(*横向*)
END_STRUCT
END_TYPE

{IMPLEMENTATION}
