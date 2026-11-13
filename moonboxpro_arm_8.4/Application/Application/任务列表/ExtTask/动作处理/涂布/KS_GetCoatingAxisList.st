(*@CES
Name=KS_GetCoatingAxisList
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=8bc67aac-0c7f-4420-a195-db7a2a94b6c1
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_GetCoatingAxisList : BOOL
VAR_INPUT
	i_iGrpAxisNum_Pu: INT;(*色组轴数量|*)
	i_paiGrpAxisList: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF INT;(*系轴列表|有排序规则|*)
	i_pstStCoatingAxisInf:POINTER TO StCoatingAxisInf;	
	i_axSwitchOn_CoatingPrn: ARRAY [1..MAX_UNIT_NUM] OF BOOL;
END_VAR
VAR
	iN: INT;
	iUnitId: INT;
	aiAxisIdList:ARRAY [1..gc_byCoatingMaxSum_New] OF INT;(*2024.01.18.104002*)
	byCoatingNum: BYTE;	
END_VAR

{IMPLEMENTATION}
IF i_pstStCoatingAxisInf<>0 AND	
	i_paiGrpAxisList<>0THEN;
ELSE
	RETURN;
END_IF

(*处理涂布轴列表*)
byCoatingNum:=0;
FOR iN:=1 TO gc_byCoatingMaxSum_New BY 1 DO
	aiAxisIdList[iN]:=-1;
END_FOR

FOR iN:=1 TO i_iGrpAxisNum_Pu BY 1 DO
	iUnitId:=i_paiGrpAxisList^[iN];
	IF iUnitId>0 AND iUnitId<=MAX_UNIT_NUM THEN
		IF i_axSwitchOn_CoatingPrn[iUnitId] THEN(*涂布打开*)
			byCoatingNum:=byCoatingNum+1;
			IF byCoatingNum<=gc_byCoatingMaxSum_New THEN(*不能超过可以处理的个数*)
				aiAxisIdList[byCoatingNum]:=iUnitId;
				IF byCoatingNum=gc_byCoatingMaxSum_New THEN
					EXIT;
				END_IF
			END_IF
		END_IF
	END_IF
END_FOR
(*写入到结构体中*)
i_pstStCoatingAxisInf^.byCoatingAxisNum:=byCoatingNum;
i_pstStCoatingAxisInf^.aiAxisIdList:=aiAxisIdList;