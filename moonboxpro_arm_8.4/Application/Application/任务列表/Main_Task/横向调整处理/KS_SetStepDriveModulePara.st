(*@CES
Name=KS_SetStepDriveModulePara
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=21a3679d-2e4f-4802-b9d7-d00f676e215d
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_SetStepDriveModulePara : BOOL(*设置步进电机脉冲输出模块脉冲方式参数*)
(*2019.5.15.112350|liu.yt|必须放在KS_FB_StepDriveCTL后执行，KS_FB_StepDriveCTL会清零，功能块再次再次赋值，反之则无效赋值*)
(*2019.4.18.130455 增加了ENCO410R型模块输入输出控制参数,主要用于高速编码器输入输出控制。MHZ频率*)
VAR_INPUT
	i_xMultiple_Input: BOOL;(*参数输入方式选择：多参数 或者 单参数*)
	i_byEncO410RInputVol:BYTE;(*模块输入的电压类型选择：0 是5v；1是24v*)
	i_byEnc0410RInPutMode:BYTE;(*模块输入方式选择 0:正交脉冲 1:脉冲+方向 2:正负脉冲*)
	i_xEnc0410RInPutPulDir:BOOL;(*模块输入脉冲方向 TRUE 取反*)
	i_byEnc0410RInPutPulCntWay:BYTE;(*模块输入脉冲计数方式 0:z信号开始 1:一直计数*)

	i_byEnc0410ROutPutMode:BYTE;(*模块输出方式选择 0:正交脉冲 1:脉冲+方向 2:正负脉冲*)
	i_pastStDigitalMicroStepDrive :POINTER TO ARRAY [1..MAX_UNIT_NUM] OF StDigitalMicroStepDrive;
	i_pastStEnc0410R:POINTER TO ARRAY [1..MAX_UNIT_NUM] OF StEnc0410R;
END_VAR
VAR
(*bit7:8 脉冲输出模式，仅限于EncO410R模块，0:正交脉冲 1:脉冲+方向 2:正负脉冲*)
	wEncO410ROutPutMode_ClrCtlBit:WORD:=16#FE7F;(*利用与运算清除7:8位*)
(*利用或运算定义控制位*)
	wEncO410ROutPutMode_QuadPul:WORD:=0;		(*正交脉冲输出模式	bit 7:8=0*)
	wEncO410ROutPutMode_PulAndDir:WORD:=16#0080;	(*脉冲+方向输出模式	bit 7:8=1*)
	wEncO410ROutPutMode_PlusMinusPul:WORD:=16#0100;(*正负脉冲输出模式	bit 7:8=2*)

(*************************************************)
(*Enc0410R 模块输入配置*)(*bit0:1 脉冲输入模式。bit2 方向取反。bit3 计数模式*)
	wEncO410RInPutMode_ClrCtlBit:WORD:=16#FFF0;(*利用与运算清除低四位*)
(*利用或运算定义控制位*)
	wEncO410RInPutMode_QuadPul:WORD:=0;		(*正交脉冲输出模式	bit 0:1=0*)
	wEncO410RInPutMode_PulAndDir:WORD:=16#0001;	(*脉冲+方向输出模式	bit 0:1=1*)
	wEncO410RInPutMode_PlusMinusPul:WORD:=16#0002;(*正负脉冲输出模式	bit 0:1=2*)
	wEncO410RInPutMode_PlusDir:WORD:=16#0004;(*bit2 脉冲方向*)
(*	wEncO410RInPutMode_PlusCntWay_Z:WORD:=0;(*脉冲计数模式：z信号开始*)*)
	wEncO410RInPutMode_PlusCntWay_All:WORD:=16#0008;(*脉冲计数模式：一直计数*)
	wEncO410RInPutMode_Vol:WORD:=16#0010;(*bit4 电压输入类型 0 是5v；1是24v*)


	iN: INT;
	wStepDriveCTL: WORD;
	wEncO410RInPutModeCfg: WORD;

	byEnc0410RInPutMode:BYTE;(*模块输入方式选择 0:正交脉冲 1:脉冲+方向 2:正负脉冲*)
	xEnc0410RInPutPulDir:BOOL;(*模块输入脉冲方向 TRUE 取反*)
	byEnc0410RInPutPulCntWay:BYTE;(*模块输入脉冲计数方式 0:z信号开始 1:一直计数*)
	byEncO410RInputVol: BYTE;(*模块输入的电压类型选择：0 是5v；1是24v*)

	byEnc0410ROutPutMode:BYTE;(*模块输出方式选择 0:正交脉冲 1:脉冲+方向 2:正负脉冲*)
END_VAR

{IMPLEMENTATION}
IF i_pastStDigitalMicroStepDrive<>0 AND i_pastStEnc0410R<>0 THEN
	FOR iN:=1 TO MAX_UNIT_NUM BY 1 DO(*针对所有轴进行控制*)
		IF i_xMultiple_Input THEN(*多参数输入*)
			byEnc0410RInPutMode:=i_pastStEnc0410R^[iN].byEnc0410RInPutMode;
			xEnc0410RInPutPulDir:=i_pastStEnc0410R^[iN].xEnc0410RInPutPulDir;
			byEnc0410RInPutPulCntWay:=i_pastStEnc0410R^[iN].byEnc0410RInPutPulCntWay;
			byEncO410RInputVol:=i_pastStEnc0410R^[iN].byEncO410RInputVol;
			byEnc0410ROutPutMode:=i_pastStEnc0410R^[iN].byEnc0410ROutPutMode;
		ELSE(*单参数输入*)
			byEnc0410RInPutMode:=i_byEnc0410RInPutMode;
			xEnc0410RInPutPulDir:=i_xEnc0410RInPutPulDir;
			byEnc0410RInPutPulCntWay:=i_byEnc0410RInPutPulCntWay;
			byEncO410RInputVol:=i_byEncO410RInputVol;
			byEnc0410ROutPutMode:=i_byEnc0410ROutPutMode;
		END_IF


		(*脉冲输出配置*)
		wStepDriveCTL:=i_pastStDigitalMicroStepDrive^[iN].wStepDriveCTL;
		wStepDriveCTL:=wStepDriveCTL AND wEncO410ROutPutMode_ClrCtlBit;(*清零相应位*)
		(*输出方式配置*)
		CASE byEnc0410ROutPutMode OF
		1:(*脉冲+方向*)
			wStepDriveCTL:=wStepDriveCTL+wEncO410ROutPutMode_PulAndDir;
		2:(*正负脉冲*)
			wStepDriveCTL:=wStepDriveCTL+wEncO410ROutPutMode_PlusMinusPul;
		ELSE(*默认输出方式是正交脉冲*)
			wStepDriveCTL:=wStepDriveCTL+wEncO410ROutPutMode_QuadPul;
		END_CASE

		i_pastStDigitalMicroStepDrive^[iN].wStepDriveCTL:=wStepDriveCTL;

		(*脉冲输入配置*)
		(*Enc0410R的输入参数配置和继电器数字量模块公用IO输入输出地址*)
		wEncO410RInPutModeCfg:=0;

		(*输入方式配置*)

		CASE byEnc0410RInPutMode OF
		1:(*脉冲+方向*)
			wEncO410RInPutModeCfg:=wEncO410RInPutModeCfg+wEncO410RInPutMode_PulAndDir;
		2:(*正负脉冲*)
			wEncO410RInPutModeCfg:=wEncO410RInPutModeCfg+wEncO410RInPutMode_PlusMinusPul;
		ELSE(*默认输出方式是正交脉冲*)
			wEncO410RInPutModeCfg:=wEncO410RInPutModeCfg+wEncO410RInPutMode_QuadPul;
		END_CASE

		(*方向取反*)
		IF xEnc0410RInPutPulDir THEN wEncO410RInPutModeCfg:=wEncO410RInPutModeCfg+wEncO410RInPutMode_PlusDir;END_IF

		(*计数方式选择*)
		IF byEnc0410RInPutPulCntWay<>0 THEN wEncO410RInPutModeCfg:=wEncO410RInPutModeCfg+wEncO410RInPutMode_PlusCntWay_All;END_IF

		(*输入电压类型 0 是5v  1是24v*)
		IF byEncO410RInputVol=1 THEN wEncO410RInPutModeCfg:=wEncO410RInPutModeCfg+wEncO410RInPutMode_Vol;END_IF


		i_pastStEnc0410R^[iN].wInputModeCfg:=wEncO410RInPutModeCfg;
	END_FOR
END_IF