(*@CES
Name=KS_FB_Func_UwRw
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=2b84a56d-4eb9-45ed-80f1-633cb5fda350
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_Func_UwRw
VAR_INPUT
	i_xEn : BOOL;
	i_iGrpId : INT;
	i_pstStSysParam: POINTER TO StSysParam;
	i_pstStEvtReq : POINTER TO StEvtReq;
	i_iId_Uw_IO: INT;
	i_iId_Rw_IO: INT;
	i_iGrpAxisNum_Pu: INT;
	i_aiGrpAxisList: ARRAY [1..MAX_UNIT_NUM] OF INT;			
	i_pstStIOMap_Uw: POINTER TO StIOMap_UwRw_FE; (*放料io*)
	i_pstStIOMap_Rw: POINTER TO StIOMap_UwRw_FE; (*收料io*)
	
END_VAR
VAR_OUTPUT
END_VAR
VAR
	fbKS_FB_Func_Uw: KS_FB_Func_Uw;
	fbKS_FB_Func_Rw: KS_FB_Func_Rw;
	stStEvtReq_Uw: StEvtReq_UwRw;
	stStEvtReq_Rw: StEvtReq_UwRw;
	
	fbKS_FB_Stiffen: KS_FB_Stiffen;
	fbKS_FB_StiffenTestNew: KS_FB_StiffenTest_NEW;	
	
	xInverterCW_UW: BOOL;
	xInverterCW_RW: BOOL;
	
	rVel_Stiffen_Uw: REAL;
	rVel_Stiffen_Rw: REAL;
	
END_VAR

{IMPLEMENTATION}
IF i_xEn THEN
	IF i_pstStSysParam <> 0 AND i_pstStEvtReq<>0 AND
		i_pstStIOMap_Uw<>0 AND i_pstStIOMap_Uw<>0 THEN
		Action_Stiffen();
		
		(*一放*)
		Action_Uw();
		(*二放*)
		(*Action_Uw_2;*)
		(*收料*)
		Action_Rw();
	ELSE;
	END_IF
ELSE;
END_IF