(*@CES
Name=KS_RstSysParam
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=f9e1f4e0-8736-47b6-9a7b-51fe01553e23
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_RstSysParam : INT
VAR_INPUT
	i_pstStSysParam: POINTER TO StSysParam;
	i_xResetAllParam: BOOL;(*全部参数初始化*)
END_VAR
VAR
	iResult: INT;
	iUnit:INT;
END_VAR

{IMPLEMENTATION}
iResult:= 0;
IF i_pstStSysParam<>0 THEN
	IF i_xResetAllParam THEN
		KS_RstSysParam_Save(ADR(i_pstStSysParam^.stStSysParam_Save),
				ADR(i_pstStSysParam^.stStRSV_SysParam_Save),
	(*2026.5.28.150112增加预套准结构初始化*)			
				g_pstStMechanicalParam_01,
				g_pstStMechanicalParam_02,
				g_pstStMechanicalParam_03,
				g_pstStMechanicalParam_05);
		KS_RstGrpParam_Save(ADR(i_pstStSysParam^.astStGrpParam_Save),
				ADR(i_pstStSysParam^.astStRSV_GrpParam_Save));		
		KS_RstUnitParam_Save(i_pstStSysParam,
				ADR(i_pstStSysParam^.astStUnitParam_Save),
				ADR(i_pstStSysParam^.astStRSV_UnitParam_Save));		
	ELSE
		KS_RstSysParam_UnSave(ADR(i_pstStSysParam^.stStSysParam_UnSave),
				ADR(i_pstStSysParam^.stStRSV_SysParam_UnSave));
		KS_RstGrpParam_UnSave(ADR(i_pstStSysParam^.astStGrpParam_UnSave),
				ADR(i_pstStSysParam^.astStRSV_GrpParam_UnSave));		
		KS_RstUnitParam_UnSave(ADR(i_pstStSysParam^.astStUnitParam_UnSave),
				ADR(i_pstStSysParam^.astStRSV_UnitParam_UnSave));		
	
	END_IF
	(*再清除一些原来保持的东西@2026.06.03.194958+ by liu.yt*)
	IF i_pstStSysParam<>0 THEN
		FOR iUnit:=1 TO MAX_UNIT_NUM BY 1 DO
			(*初始化为纵横向手动*)
			i_pstStSysParam^.astStUnitParam_Save[iUnit].dwFlag_Sts.0:= FALSE;
			i_pstStSysParam^.astStUnitParam_Save[iUnit].dwFlag_Sts.1:= FALSE;
		END_FOR
	END_IF
	
	iResult:= 1;
ELSE
	iResult:= -1;
END_IF
KS_RstSysParam:= iResult;