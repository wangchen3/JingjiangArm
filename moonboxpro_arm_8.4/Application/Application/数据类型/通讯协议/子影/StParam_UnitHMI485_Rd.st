(*@CES
Name=StParam_UnitHMI485_Rd
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=b1f3dc45-0cc5-41fd-a54e-f4937ddba804
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
{attribute 'pack_mode' := '1'}
TYPE StParam_UnitHMI485_Rd :
STRUCT
//每个包240字节
//新增读取内容||工艺控制相关2025.12.31.135951||总共24字节||120-24=96
	rHz_UnitInkRoller_CurrRD: REAL;
	wSts_UnitInkRoller: WORD;
	rHz_UnitScraper_CurrRD: REAL;
	wSts_UnitScraper: WORD;
	rHz_UnitHotWind_CurrRd: REAL;
	wSts_UnitHotWind: WORD;
	rHz_UnitHotWind_CurrRd_2: REAL;
	wSts_UnitHotWind_2: WORD;
	
	abyRsv_Rd: ARRAY [1..96] OF BYTE;(*只读通讯保留位*)
	
//第二个人机通讯内容2025.12.31.154101
	rHz_UnitInkRoller_CurrRD_OtherUnit: REAL;
	wSts_UnitInkRoller_OtherUnit: WORD;
	rHz_UnitScraper_CurrRD_OtherUnit: REAL;
	wSts_UnitScraper_OtherUnit: WORD;
	rHz_UnitHotWind_CurrRd_OtherUnit: REAL;
	wSts_UnitHotWind_OtherUnit: WORD;
	rHz_UnitHotWind_CurrRd_2_OtherUnit: REAL;
	wSts_UnitHotWind_2_OtherUnit: WORD;
	abyRsv_Rd_OtherUnit: ARRAY [1..96] OF BYTE;(*只读通讯保留位*)
	
END_STRUCT
END_TYPE

{IMPLEMENTATION}
