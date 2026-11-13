(*@CES
Name=StWrRd_AxisCfg
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=0dd870ae-2077-401c-9916-294cbac50220
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
{attribute 'pack_mode' := '1'}//系统配置
TYPE StWrRd_AxisCfg :
STRUCT
	xAxisProf_Enable: BIT;(*轴打开*)
	xAxisProf_MotRev: BIT;(*运动反向*)
	xAxisProf_SamRev: BIT;(*采样方向*)
	xAxisProf_Rsv1: BIT;(*预留*)
	xAxisProf_Rsv2: BIT;(*预留*)
	xAxisProf_Rsv3: BIT;(*预留*)
	xAxisProf_Rsv4: BIT;(*预留*)
	xAxisProf_Rsv5: BIT;(*预留*)
	
	//2025.11.1.104728两个字节作为站号通讯
	iSid: INT;
//	abyRsv: ARRAY [1..2] OF BYTE;(*预留两个字节方便增加其他内容*)
END_STRUCT
END_TYPE

{IMPLEMENTATION}
