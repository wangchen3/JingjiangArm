(*@CES
Name=StSts_UnitFlag
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=9b5ad9b6-6a41-49ce-aab1-12c5fd79f7c8
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
{attribute 'pack_mode' := '1'}
TYPE StSts_UnitFlag :(*2025.7.3.175755总16字节+8预留字节*)
STRUCT
	xLinkage									: BIT;
	xFlag_RollerDn_BottomRoller					: BIT;(* 底辊合压标志/底辊的胶辊 *)
	xFlag_RollerDn_PrnRoller					: BIT;(* 印辊合压标志/靠上底辊 *)
	xFlag_RollerDn_NetRoller					: BIT;(* 网辊合压标志/靠上版辊 *)
	xFlag_HorzPreRegister_ing					: BIT;(*横向预套准进行中|*)
	xFlag_HorzPreRegister_end					: BIT;(*横向预套准完成|*)
	xAxisInching								: BIT;(*版辊单运行中*)
	xAxisInching_Net							: BIT;(*网辊单运行中*)		
	xNetOffline_Horz							: BIT;
	xAxisAlarm_Horz								: BIT;
	xPosDeviationAlarm_Horz						: BIT;												
	xNetOffline_PrnRoller						: BIT;
	xAxisAlarm_PrnRoller						: BIT;
	xPosDeviationAlarm_PrnRoller				: BIT;												
	xNetOffline_NetRoller						: BIT;
	xAxisAlarm_NetRoller						: BIT;
	xPosDeviationAlarm_NetRoller				: BIT;												 
	xNetOffline_BottomRoller					: BIT;
	xAxisAlarm_BottomRoller						: BIT;
	xPosDeviationAlarm_BottomRoller				: BIT;												 
	xNetOffline_Prn_Pressure_M					: BIT;
	xAxisAlarm_Prn_Pressure_M					: BIT;
	xPosDeviationAlarm_Prn_Pressure_M			: BIT;												 
	xNetOffline_Prn_Pressure_G					: BIT;
	xAxisAlarm_Prn_Pressure_G					: BIT;
	xPosDeviationAlarm_Prn_Pressure_G			: BIT;												  
	xNetOffline_Net_Pressure_M					: BIT;
	xAxisAlarm_Net_Pressure_M					: BIT;
	xPosDeviationAlarm_Net_Pressure_M			: BIT;												
	xNetOffline_Net_Pressure_G					: BIT;
	xAxisAlarm_Net_Pressure_G					: BIT;
	xPosDeviationAlarm_Net_Pressure_G			: BIT;												  
	xNetOffline_Str_Pressure_M					: BIT;
	xAxisAlarm_Str_Pressure_M					: BIT;
	xPosDeviationAlarm_Str_Pressure_M			: BIT;												  
	xNetOffline_Str_Pressure_G					: BIT;
	xAxisAlarm_Str_Pressure_G					: BIT;
	xPosDeviationAlarm_Str_Pressure_G			: BIT;												
	xNetOffline_PHOTOCELL						: BIT;
	xAxisAlarm_PHOTOCELL						: BIT;
	xPosDeviationAlarm_PHOTOCELL				: BIT;	
	(*以上总41BIT，预留7bit+2字节*)

	xFlag_PressDn									: BIT;
	xFlag_Rsv2									: BIT;
	xFlag_Rsv3									: BIT;
	xFlag_Rsv4									: BIT;
	xFlag_Rsv5									: BIT;
	xFlag_Rsv6									: BIT;
	xFlag_Rsv7									: BIT;
	abyFlag_Rsv									: ARRAY [1..2] OF BYTE;
	
END_STRUCT
END_TYPE

{IMPLEMENTATION}
