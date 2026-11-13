(*@CES
Name=KS_InitStationInf
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=78672f31-3286-4bff-bedb-6c7e7d7440a9
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_InitStationInf : BOOL
(*初始化结构体*)
VAR_INPUT
	i_pstInf:POINTER TO StStationInf;
END_VAR
VAR
	stInf:StStationInf:=(xValid:=FALSE,
						iAxisId:=AXISID_INVALID,
						iStationId:=-1,
						iFuncId:=FUNCID_NULL,
						iMoveType:=MOVETYPE_NULL,
						udiStationType:=0,
						iCoreId_LogicAxis:=-1,
						iCoreId_LogicAxisSuperPos:=-1,
						iLogicAxisId:=-1,
						iLogicAxisIdSuperPos:=-1,
						xRemoteEncValid:=FALSE,
						iRemoteSrcId:=-1);
END_VAR
{IMPLEMENTATION}
IF i_pstInf<>0 THEN
	i_pstInf^:=stInf;
END_IF