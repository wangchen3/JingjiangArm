(*@CES
Name=StRd_PhaseRead
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=cc9a816d-b51c-4791-9ed9-abce420ba21a
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
{attribute 'pack_mode' := '1'}//配方保存内容
TYPE StRd_PhaseRead :
STRUCT
	arGirth_Pu: ARRAY [1..2] OF REAL;//整机周长
	aiMarkTypeId: ARRAY [1..2] OF INT;//色标形式
	aiMarkArrangeId: ARRAY [1..2] OF INT;//色标排列顺序
	abyTriMark_SideC: ARRAY [1..2] OF BYTE;//梯形色标横边长
	abyTriMark_SideB: ARRAY [1..2] OF BYTE;//梯形色标边长
	abyRsv_Data0: ARRAY [1..2] OF BYTE;//预留	一些位置
	arTaper_Begin_If: ARRAY [1..2] OF REAL;//放牵锥度起始
	arTaper_End_If: ARRAY [1..2] OF REAL;//放牵锥度结束
	arTaper_Begin_Of: ARRAY [1..2] OF REAL;//收牵锥度起始
	arTaper_End_Of: ARRAY [1..2] OF REAL;//收牵锥度结束
	arTaper_Begin_Uw: ARRAY [1..2] OF REAL;//放料锥度起始
	arTaper_End_Uw: ARRAY [1..2] OF REAL;//放料锥度结束
	arTaper_Begin_Rw: ARRAY [1..2] OF REAL;//收料锥度起始
	arTaper_End_Rw: ARRAY [1..2] OF REAL;//收料锥度结束	
	abyRsv_Data1: ARRAY [1..22] OF BYTE;//预留	一些位置
	arGirth: ARRAY [1..MAX_UNIT_NUM] OF REAL;//色组版周长
	axEnable_Arc: ARRAY [1..MAX_UNIT_NUM] OF BOOL;//色组套印使能
	aiMarkTypeId_Pu: ARRAY [1..MAX_UNIT_NUM] OF INT;//色组色标形式
(*以上220个字节*)
	aiMarkArrangeId_Pu: ARRAY [1..MAX_UNIT_NUM] OF INT;//色组色标排列顺序
	aiGateWidthPhy: ARRAY [1..MAX_UNIT_NUM] OF INT;//色组波门宽度
	aiGateSa: ARRAY [1..MAX_UNIT_NUM] OF INT;//色组波门位置
	aiGateSaEx: ARRAY [1..MAX_UNIT_NUM] OF INT;//色组第二波门位置
	//部分色组使能开关用做byte型吧2025.10.11.141041
	abySwitch_Unit_Phase: ARRAY [1..MAX_UNIT_NUM] OF BYTE;
	(*
		bit0:色组横向开关
		bit1:色组波门1T1反极性
		bit2:色组波门1T2反极性
		bit3:色组波门2T1反极性
		bit4:色组波门2T2反极性		
		2025.10.23.111502
		bit5:用作涂布开关
	*)

	arAdj_V: ARRAY [1..MAX_UNIT_NUM] OF REAL;//色组纵向修正量
	abyRsv_Data2: ARRAY [1..12] OF BYTE;//预留	一些位置
(*以上220个字节*)
	arAdj_H: ARRAY [1..MAX_UNIT_NUM] OF REAL;//色组横向修正量
	aiPhase_RegisterOK: ARRAY [1..MAX_UNIT_NUM] OF INT;//色组相位
	arSV_TemCtl: ARRAY [1..MAX_UNIT_NUM] OF REAL;//色组温度设定SV
	abyAiirInletWindDoorValue: ARRAY [1..MAX_UNIT_NUM] OF BYTE;//色组风门开度	
	abyOvensAirOutWindDoorValue: ARRAY [1..MAX_UNIT_NUM] OF BYTE;//色组风门开度
	abyAirExhaustWindDoorValue: ARRAY [1..MAX_UNIT_NUM] OF BYTE;//色组排风风门开度
	abyRsv_Data3: ARRAY [1..12] OF BYTE;//预留	一些位置
(*以上220个字节*)	
	abyAirReturnWindDoorValue: ARRAY [1..MAX_UNIT_NUM] OF BYTE;//色组回风风门开度
	arHz_UnitInkRoller_ManuallySet: ARRAY [1..MAX_UNIT_NUM] OF REAL;//色组递墨辊手动输入频率
	arCoeff_UnitInkRoller_Auto: ARRAY [1..MAX_UNIT_NUM] OF REAL;//色组递墨辊自动系数
	arHz_UnitScraper_ManuallySet: ARRAY [1..MAX_UNIT_NUM] OF REAL;//色组刮刀手动输入频率
	abyRsv_Data4: ARRAY [1..12] OF BYTE;//预留	一些位置
(*以上220个字节*)
	arCoeff_UnitScraper_Auto: ARRAY [1..MAX_UNIT_NUM] OF REAL;//色组刮刀自动系数
	arHz_UnitHotWind_ManuallySet: ARRAY [1..MAX_UNIT_NUM] OF REAL;//色组热风手动频率
	arHz_UnitHotWind_2_ManuallySet: ARRAY [1..MAX_UNIT_NUM] OF REAL;//色组热风2手动频率
	abyRsv_Data5: ARRAY [1..28] OF BYTE;//预留	一些位置
	
(*以上220个字节*)
	arHz_UnitExhaust_ManuallySet: ARRAY [1..MAX_UNIT_NUM] OF REAL;//色组排风手动输入频率
	abyRsv_Data6: ARRAY [1..156] OF BYTE;//预留	一些位置
(*以上220个字节*)

//////////////////////在这里增加一些预留	
	abyRsv_Data: ARRAY [1..874] OF BYTE;//预留	一些位置
	
	//2026.5.15.114131增加了CRC校验占用6字节-上面就剩880-6=874
	wChk: WORD;
	dwSum: DWORD;
//以上总共2200字节，10个数据包
	
END_STRUCT
END_TYPE

{IMPLEMENTATION}
