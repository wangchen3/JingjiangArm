(*@CES
Name=KS_FB_IOConfig
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=7c1e02cd-630c-49cf-bc81-9650f662c25f
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_IOConfig
VAR_INPUT
	i_xEn										: BOOL;(*功能块使能|*)
	i_xRdInput									: BOOL;(*读io输入|*)
	i_xWrOutput									: BOOL;(*写io输出|*)
//	i_iCustomerId								: INT;
	i_pstStSysParam								: POINTER TO StSysParam;
	i_pastStIOMap_Main_FE						: POINTER TO ARRAY [1..4] OF StIOMap_Main_FE;(*轴io数据区域|AB系*)
	i_pastStIOMap_Axis_FE					: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF StIOMap_Axis_FE;(*轴io数据区域|`````````````````````````````````````````````*)
	i_pastStIOMap_Axis_Extra_FE				: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF StIOMap_Axis_Extra_FE;
	i_pastStIOMap_UwRw_FE_Uw					: POINTER TO ARRAY [1..2] OF StIOMap_UwRw_FE;(*轴io数据区域|AB系*)
	i_pastStIOMap_UwRw_FE_Rw					: POINTER TO ARRAY [1..2] OF StIOMap_UwRw_FE;(*轴io数据区域|AB系*)

	i_pastStProgMonitoring						: POINTER TO ARRAY [1..2] OF StProgMonitoring;	
	
	i_dwInput_IO_GNS_P6P8: DWORD;
	i_dwInput_IO_GNS_P4P3: DWORD;
END_VAR
VAR_OUTPUT
	o_xEno										: BOOL;(*indicated to i_xEn|*)
	o_iErNo										: INT;(*0.no err\-1.bad parameter|*)
	o_dwOutput_IO_GNS_P5P7: DWORD;	
END_VAR
VAR
	fbKS_FB_IOMAP_AIAO_KS:KS_FB_IOMAP_AIAO;
	fbKS_FB_IOMAP_Axis_KS:KS_FB_IOMAP_Axis;
	fbKS_FB_IOMAP_AxisExtra_KS:KS_FB_IOMAP_AxisExtra;
	fbKS_FB_IOMAP_Main_KS:KS_FB_IOMAP_Main;
	fbKS_FB_IOMAP_UwRw_KS:KS_FB_IOMAP_UwRw;
	fbKS_FB_StepDriveIODeal_KS : KS_FB_StepDriveIODeal ;

END_VAR

{IMPLEMENTATION}
o_xEno:= i_xEn;
o_iErNo:= 0;
IF i_xEn THEN
	IF i_pastStIOMap_Main_FE<>0 AND
		i_pastStIOMap_Axis_FE<>0 AND
		i_pastStIOMap_Axis_Extra_FE<>0 AND
		i_pastStIOMap_UwRw_FE_Uw<>0 AND
		i_pastStIOMap_UwRw_FE_Rw<>0  THEN
		

		IF i_xRdInput THEN
			fbKS_FB_StepDriveIODeal_KS(
				i_xInputEn:= i_xRdInput, 
				i_xOutPutEn:= i_xWrOutput, 
				i_pastStDigitalMicroStepDrive:= ADR(g_astStDigitalMicroStepDrive),
				i_pastStStepDriveIOModule:=  ADR(g_astStStepDriveIOModule),
				i_pastStEnc0410R:= ADR(g_astStEnc0410R));	
		END_IF
		fbKS_FB_IOMAP_AIAO_KS(
			i_xEn:= TRUE, 
			i_xRdInput:= i_xRdInput, 
			i_xWrOutput:= i_xWrOutput, 
			i_pstStSysParam := i_pstStSysParam,
			i_pastStProgMonitoring := i_pastStProgMonitoring,
			o_xEno=> , 
			o_iErNo=> );	
		fbKS_FB_IOMAP_Main_KS(
			i_xEn:= TRUE, 
			i_xRdInput:= i_xRdInput, 
			i_xWrOutput:= i_xWrOutput, 
			i_pastStIOMap_Main_FE:= i_pastStIOMap_Main_FE, 
			//i_pstStSysParam:= i_pstStSysParam,
			o_xEno=> , 
			o_iErNo=> );
		fbKS_FB_IOMAP_UwRw_KS(
			i_xEn:= TRUE, 
			i_xRdInput:= i_xRdInput, 
			i_xWrOutput:= i_xWrOutput, 
			i_pastStIOMap_UwRw_FE_Uw:= i_pastStIOMap_UwRw_FE_Uw, 
			i_pastStIOMap_UwRw_FE_Rw:= i_pastStIOMap_UwRw_FE_Rw, 
			o_xEno=> , 
			o_iErNo=> );	
		fbKS_FB_IOMAP_Axis_KS(
			i_xEn:= TRUE, 
			i_xRdInput:= i_xRdInput, 
			i_xWrOutput:= i_xWrOutput, 
			i_pastStIOMap_Axis_FE:= i_pastStIOMap_Axis_FE, 
			o_xEno=> , 
			o_iErNo=> );
			
		fbKS_FB_IOMAP_AxisExtra_KS(
			i_xEn:= TRUE, 
			i_xRdInput:= i_xRdInput, 
			i_xWrOutput:= i_xWrOutput, 
			i_pastStIOMap_Axis_Extra_FE:= i_pastStIOMap_Axis_Extra_FE, 
			i_pstStSysParam:= i_pstStSysParam,
			o_xEno=> , 
			o_iErNo=> );
			
		IF i_xWrOutput THEN
			fbKS_FB_StepDriveIODeal_KS(
				i_xInputEn:= i_xRdInput, 
				i_xOutPutEn:= i_xWrOutput, 
				i_pastStDigitalMicroStepDrive:= ADR(g_astStDigitalMicroStepDrive),
				i_pastStStepDriveIOModule:=  ADR(g_astStStepDriveIOModule),
				i_pastStEnc0410R:= ADR(g_astStEnc0410R));	
		END_IF			
	END_IF
END_IF