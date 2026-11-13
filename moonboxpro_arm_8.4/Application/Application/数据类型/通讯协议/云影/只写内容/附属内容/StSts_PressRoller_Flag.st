(*@CES
Name=StSts_PressRoller_Flag
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=b94585e0-0f14-4a6e-b8de-4e371f1e83a5
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
{attribute 'pack_mode' := '1'}
TYPE StSts_PressRoller_Flag :(*2025.7.3.175755总2字节+2预留字节*)
STRUCT
	xConfirmAbsEncZeroPosDne_PrnRoller_Pressure_M		: BIT;(* 版辊压力电机绝对值位置M侧/零位确认完成 *)
	xConfirmAbsEncZeroPosDne_PrnRoller_Pressure_G		: BIT;(* 版辊压力电机绝对值位置G侧/零位确认完成 *)
	xConfirmAbsEncZeroPosDne_NetRoller_Pressure_M		: BIT;(* 网辊压力电机绝对值位置M侧/零位确认完成 *)
	xConfirmAbsEncZeroPosDne_NetRoller_Pressure_G		: BIT;(* 网辊压力电机绝对值位置G侧/零位确认完成 *)

(* 2021.12.29.140315/hdp/lyt *)
	xConfirmload_unloadPosDne_PrnRoller_Pressure_M		: BIT;(* 版辊压力电机换版位置M侧/确认完成 *)
	xConfirmload_unloadPosDne_PrnRoller_Pressure_G		: BIT;(* 版辊压力电机换版位置G侧/确认完成 *)
	xConfirmload_unloadPosDne_NetRoller_Pressure_M		: BIT;(* 网辊压力电机换版位置M侧/确认完成 *)
	xConfirmload_unloadPosDne_NetRoller_Pressure_G		: BIT;(* 网辊压力电机换版位置G侧/确认完成 *)

	xConfirmDnPosDne_PrnRoller_Pressure_M				: BIT;(* 版辊压力电机合压位置M侧/确认完成 *)
	xConfirmDnPosDne_PrnRoller_Pressure_G				: BIT;(* 版辊压力电机合压位置G侧/确认完成 *)
	xConfirmDnPosDne_NetRoller_Pressure_M				: BIT;(* 网辊压力电机合压位置M侧/确认完成 *)
	xConfirmDnPosDne_NetRoller_Pressure_G				: BIT;(* 网辊压力电机合压位置G侧/确认完成 *)	
	
	xConfirmDnPosDne_StrRoller_Pressure_M				: BIT;(* 张带辊压力电机合压位置M侧/确认完成 *)
	xConfirmDnPosDne_StrRoller_Pressure_G				: BIT;(* 张带辊压力电机合压位置G侧/确认完成 *)	
		
	xFlag_Rsv0											: BIT;
	xFlag_Rsv1											: BIT;
	abyFlag_Rsv											: ARRAY [1..2] OF BYTE;//预留两个空间
END_STRUCT
END_TYPE

{IMPLEMENTATION}
