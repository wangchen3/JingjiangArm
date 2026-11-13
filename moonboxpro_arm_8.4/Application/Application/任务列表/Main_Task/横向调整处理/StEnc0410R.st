(*@CES
Name=StEnc0410R
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=6f80462c-d6b3-455f-883a-2142632bafb1
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
TYPE StEnc0410R :
STRUCT
	wInputModeCfg:WORD;(*模块输入配置*)
	wInputEncValue:WORD;(*模块输入的编码器个数*)
	wInputEncValue_Bak:WORD;(*上个周期模块输入的编码器个数*)
	diInputEncValue_Total:DINT;(*总的编码器输入个数*)
	diEncValue_Middle:DINT;(*中位临时值*)

	byEnc0410RInPutMode:BYTE;(*模块输入方式选择 0:正交脉冲 1:脉冲+方向 2:正负脉冲*)
	xEnc0410RInPutPulDir:BOOL;(*模块输入脉冲方向 TRUE 取反*)
	byEnc0410RInPutPulCntWay:BYTE;(*模块输入脉冲计数方式 0:z信号开始 1:一直计数*)
	byEncO410RInputVol:BYTE;(*模块输入的电压类型*)

	byEnc0410ROutPutMode:BYTE;(*模块是输出方式选择0:正交脉冲 1:脉冲+方向 2:正负脉冲*)
END_STRUCT
END_TYPE

{IMPLEMENTATION}
