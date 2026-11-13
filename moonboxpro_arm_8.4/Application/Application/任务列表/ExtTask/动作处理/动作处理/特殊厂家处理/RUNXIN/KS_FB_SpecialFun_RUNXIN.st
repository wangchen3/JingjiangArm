(*@CES
Name=KS_FB_SpecialFun_RUNXIN
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=aa96c82c-f3ee-4e9b-95e5-44b58294ec73
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_SpecialFun_RUNXIN
VAR_INPUT
	i_xEn:BOOL;
	i_iGrpId								: INT;
	i_pstStSysParam			: POINTER TO StSysParam;

END_VAR
VAR_OUTPUT
	o_xEn: BOOL;
	o_iErNo: INT;	
END_VAR
VAR
END_VAR

{IMPLEMENTATION}
o_xEn:= i_xEn;
o_iErNo:= 0;
IF i_xEn THEN
	IF i_pstStSysParam<>0 THEN
		i_pstStSysParam^.stStSysParam_Save.xAllPressOneBtn:= TRUE;
		i_pstStSysParam^.stStSysParam_Save.xPreCutOneBtn_Uw:= FALSE;
		i_pstStSysParam^.stStSysParam_Save.xPreCutOneBtn_Rw:= FALSE;
		i_pstStSysParam^.stStSysParam_Save.xUnitPressOneBtn:= FALSE;
	ELSE
		o_iErNo:= -1;
	END_IF
END_IF