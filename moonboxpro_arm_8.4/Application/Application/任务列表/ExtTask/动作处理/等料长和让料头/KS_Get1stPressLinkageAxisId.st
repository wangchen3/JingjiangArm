(*@CES
Name=KS_Get1stPressLinkageAxisId
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=47f4e115-92c5-4c8e-9299-1bfec185bb0c
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_Get1stPressLinkageAxisId : INT(*获取第一个合压联动轴id*)
(*2025.1.4.111729修改合压接口*)
VAR_INPUT
	i_iCurAxisId:INT;(*当前轴id*)
	i_iGrpLinkageAxisNum_Pu: INT; (* 系的色组联动轴数量|色组按照从小到大排序了 *)
	i_paiGrpLinkageAxisList: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF INT; (* 系的联动轴列表@从小到大拍好序的 *)
	(*调整接口@使用实际合压完成标志|2025.1.4.111522*)
	i_paxFlag_PressDne:POINTER TO ARRAY [1..MAX_UNIT_NUM] OF BOOL;(*实际压辊完成标志*)
END_VAR
VAR
	i1stPressLinkageAxisId:INT;
	iN: INT;
	iAxisId: INT;
	xPressSts: BOOL;
END_VAR

{IMPLEMENTATION}
i1stPressLinkageAxisId:=-1;
IF i_paxFlag_PressDne<>0 AND
	i_paiGrpLinkageAxisList<>0 AND
	i_iGrpLinkageAxisNum_Pu>0 AND
	i_iCurAxisId>0AND i_iCurAxisId<=MAX_UNIT_NUM THEN
	FOR iN:=1 TO  i_iGrpLinkageAxisNum_Pu BY 1 DO
		iAxisId:=i_paiGrpLinkageAxisList^[iN];
		IF iAxisId>0 AND iAxisId<=MAX_UNIT_NUM THEN
			(*2025.1.4.111722 调整*)
			xPressSts:=i_paxFlag_PressDne^[iAxisId];
			IF iAxisId<i_iCurAxisId THEN
				IF xPressSts THEN(*合压了@找到了第一个了*)
					i1stPressLinkageAxisId:=iAxisId;
					EXIT;
				END_IF
			END_IF
		END_IF
	END_FOR
END_IF
KS_Get1stPressLinkageAxisId:=i1stPressLinkageAxisId;