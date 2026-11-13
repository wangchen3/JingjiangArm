(*@CES
Name=StParam_Diamonds_Wr_RdSam
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=d5890945-3b62-4357-b858-6a28eabdfa06
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
{attribute 'pack_mode' := '1'}
TYPE StParam_Diamonds_Wr_RdSam :
STRUCT
	abyDataRsv						: ARRAY [1..196] OF BYTE;
	byAxisId_HMI_RdSamData: BYTE;(*当前界面显示的粗采样波形机组ID；*)
	byGrpId_HMI_RdSamData: BYTE;(*当前界面显示的粗采样波形系组ID；*)
	byCurSignal_Main: BYTE;(*确定当前主显通道-=0/=1主显R通道，=2主显G通道，=3主显B通道*)
	byCurSignal_RGB: BYTE;(*当前数据所属ID---bit0~bit2分别对应T2-RGB/bit4~bit6分别对应T1-RGB
例如：byCurSignal_RGB=0x05则表示本组数据为T1的R通道和T1的B通道，*)
	abyData_RoundSample_TA: ARRAY [1..1000] OF BYTE;
	abyData_RoundSample_TB: ARRAY [1..1000] OF BYTE;

END_STRUCT
END_TYPE

{IMPLEMENTATION}
