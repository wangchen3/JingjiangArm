(*@CES
Name=KS_InitGantryAxisInf
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=ab05e6d0-ef39-4b76-beb4-016762606a5a
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_InitGantryAxisInf : BOOL
VAR_INPUT
	i_pstStGantryAxisInf :POINTER TO StGantryAxisInf;
END_VAR
VAR
	stStGantryAxisInf :StGantryAxisInf:=(
								iAxisId:=-1,(*色组号*)
								iFuncId:=FUNCID_NULL,(*版辊\网纹辊*)
								iCoreId:=-1,(*核id*)
								iLogicAxisId_M:=-1,(*操作侧逻辑轴id*)
								iLogicAxisId_G:=-1,(*操作侧逻辑轴id*)
								iLogicAxisId_SuperPos:=-1);
END_VAR
{IMPLEMENTATION}
IF i_pstStGantryAxisInf<>0 THEN
	i_pstStGantryAxisInf^:=stStGantryAxisInf;
END_IF